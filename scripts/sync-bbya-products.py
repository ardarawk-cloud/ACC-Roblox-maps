#!/usr/bin/env python3
import json
import os
import subprocess
import time
import urllib.parse
from pathlib import Path

KEY = os.environ["ROBLOX_API_KEY"]
UNIVERSE = os.environ.get("UNIVERSE_ID", "8116636513")
BASE = f"https://apis.roblox.com/developer-products/v2/universes/{UNIVERSE}/developer-products"
LIST_BASE = BASE + "/creator"

DESIRED = [
    ("BBYA DJ Wall Message", 2, "Display one filtered custom message on the BBYA DJ wall. Messages enter a queue and are shown for a limited time."),
    ("BBYA Support 10", 10, "Support BBYA Social Hub with 10 Robux."),
    ("BBYA Support 25", 25, "Support BBYA Social Hub with 25 Robux."),
    ("BBYA Support 50", 50, "Support BBYA Social Hub with 50 Robux."),
    ("BBYA Support 100", 100, "Support BBYA Social Hub with 100 Robux."),
    ("BBYA Support 250", 250, "Support BBYA Social Hub with 250 Robux."),
    ("BBYA Support 500", 500, "Support BBYA Social Hub with 500 Robux."),
    ("BBYA Support 1000", 1000, "Support BBYA Social Hub with 1000 Robux."),
    ("BBYA Support 2000", 2000, "Support BBYA Social Hub with 2000 Robux."),
]

STATUS_PATH = Path("deploy-status/bbya-products-sync.json")
MODULE_PATH = Path("maps/bbya-social-hub/monetization/products.luau")
STATUS_PATH.parent.mkdir(parents=True, exist_ok=True)
MODULE_PATH.parent.mkdir(parents=True, exist_ok=True)


def request(method, url, fields=None, retries=6):
    last = ("", {}, "")
    for attempt in range(retries + 1):
        cmd = ["curl", "-sS", "-w", "\n%{http_code}", "-X", method, "-H", f"x-api-key: {KEY}"]
        for key, value in (fields or {}).items():
            cmd += ["-F", f"{key}={value}"]
        cmd.append(url)
        proc = subprocess.run(cmd, capture_output=True, text=True)
        raw = proc.stdout
        if "\n" in raw:
            body_text, status = raw.rsplit("\n", 1)
        else:
            body_text, status = raw, ""
        try:
            body = json.loads(body_text) if body_text.strip() else {}
        except Exception:
            body = {"raw": body_text[:1800]}
        last = (status, body, proc.stderr[:1200])
        if status != "429":
            return last
        time.sleep(min(2 ** attempt, 12))
    return last


def items_from(body):
    if not isinstance(body, dict):
        return []
    for key in ("data", "developerProducts", "products"):
        if isinstance(body.get(key), list):
            return body[key]
    return []


def next_token(body):
    if not isinstance(body, dict):
        return None
    for key in ("nextPageToken", "nextPageCursor", "next_page_cursor"):
        token = body.get(key)
        if token:
            return str(token)
    return None


def product_id(item):
    if not isinstance(item, dict):
        return 0
    for key in ("id", "productId", "developerProductId", "ProductId"):
        value = item.get(key)
        try:
            if value is not None:
                return int(value)
        except Exception:
            pass
    return 0


def list_all():
    all_items = []
    token = None
    pages = []
    for _ in range(20):
        params = {"pageSize": "50"}
        if token:
            params["pageToken"] = token
        url = LIST_BASE + "?" + urllib.parse.urlencode(params)
        status, body, stderr = request("GET", url)
        pages.append({"http": status, "count": len(items_from(body)), "token": token})
        if not status.startswith("2"):
            return status, all_items, pages, {"body": body, "stderr": stderr}
        all_items.extend(items_from(body))
        token = next_token(body)
        if not token:
            return status, all_items, pages, None
    return "200", all_items, pages, {"body": {"message": "pagination safety limit reached"}, "stderr": ""}


def by_name(items):
    return {str(item.get("name", "")).lower(): item for item in items if isinstance(item, dict) and item.get("name")}


def get_product(pid):
    return request("GET", f"{BASE}/{pid}/creator", retries=4)


def verify_named_product(expected_name, pid):
    status, body, _ = get_product(pid)
    if status.startswith("2") and isinstance(body, dict) and str(body.get("name", "")).lower() == expected_name.lower():
        return body
    return None


result = {
    "api_ok": False,
    "complete": False,
    "created": [],
    "verified_by_id": [],
    "duplicates_waiting_visibility": [],
    "errors": [],
    "pages": [],
    "products": [],
}

status, items, pages, error = list_all()
result["list_http"] = status
result["pages"] = pages
if error or not status.startswith("2"):
    result["errors"].append({"stage": "list", "http": status, **(error or {})})
else:
    result["api_ok"] = True
    remote = by_name(items)

    # Validate IDs returned by the successful creation responses from the first direct sync.
    known_hints = {
        "BBYA Support 500": 3709047107,
        "BBYA Support 1000": 3709047109,
    }
    for name, hint in known_hints.items():
        if name.lower() not in remote:
            body = verify_named_product(name, hint)
            if body:
                remote[name.lower()] = body
                result["verified_by_id"].append({"name": name, "id": hint})

    # Support 2000 was created by a concurrent legacy sync. Resolve its exact ID through
    # the official universe-scoped GET endpoint; accept an ID only when the returned name matches.
    if "bbya support 2000" not in remote:
        for candidate in range(3709047110, 3709047121):
            body = verify_named_product("BBYA Support 2000", candidate)
            if body:
                remote["bbya support 2000"] = body
                result["verified_by_id"].append({"name": "BBYA Support 2000", "id": candidate})
                break

    created_ids = {}
    for name, price, description in DESIRED:
        if name.lower() in remote:
            continue
        http, body, stderr = request("POST", BASE, {"name": name, "price": price, "description": description})
        if http.startswith("2"):
            pid = product_id(body)
            created_ids[name] = pid
            result["created"].append({"name": name, "price": price, "id": pid})
        elif isinstance(body, dict) and body.get("errorCode") == "DuplicateProductName":
            result["duplicates_waiting_visibility"].append(name)
        else:
            result["errors"].append({"stage": "create", "name": name, "http": http, "body": body, "stderr": stderr})

    # Short eventual-consistency reconciliation after any new creations.
    final_remote = dict(remote)
    final_pages = pages
    for attempt in range(5):
        if all(name.lower() in final_remote or name in created_ids for name, _, _ in DESIRED):
            break
        time.sleep(2 + attempt)
        st, listed, pg, err = list_all()
        final_pages = pg
        if st.startswith("2"):
            final_remote.update(by_name(listed))
        if err and attempt == 4:
            result["errors"].append({"stage": "relist", "http": st, **err})

    result["pages"] = final_pages
    for name, price, _ in DESIRED:
        remote_id = product_id(final_remote.get(name.lower(), {}))
        pid = remote_id or created_ids.get(name, 0)
        result["products"].append({
            "name": name,
            "price": price,
            "id": pid,
            "verified": bool(remote_id) or bool(created_ids.get(name, 0)),
        })

result["complete"] = result["api_ok"] and not result["errors"] and len(result["products"]) == len(DESIRED) and all(p["id"] > 0 for p in result["products"])
STATUS_PATH.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")

ids = {item["name"]: item.get("id", 0) for item in result.get("products", [])}
lines = [
    "-- Generated by scripts/sync-bbya-products.py",
    "return {",
    f"    DJ_MESSAGE = {ids.get('BBYA DJ Wall Message', 0)},",
    "    SUPPORT = {",
]
for price in (10, 25, 50, 100, 250, 500, 1000, 2000):
    lines.append(f"        [{price}] = {ids.get(f'BBYA Support {price}', 0)},")
lines += ["    },", "}"]
MODULE_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")

print(json.dumps({"api_ok": result["api_ok"], "complete": result["complete"], "products": result["products"], "errors": result["errors"]}))
