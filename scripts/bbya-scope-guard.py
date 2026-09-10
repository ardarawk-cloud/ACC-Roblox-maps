#!/usr/bin/env python3
"""Fail-closed BBYA release scope and baseline invariant guard.

This guard does not decide visual quality. It prevents a candidate for one BBYA
work scope from silently changing source owned by another scope, and verifies
that critical already-approved authorities are still present before any build.
"""
from __future__ import annotations

import argparse
import fnmatch
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
POLICY_PATH = ROOT / ".github" / "bbya-release-policy.json"


def fail(message: str, code: int = 2) -> None:
    print(f"BBYA RELEASE GUARD: FAIL — {message}", file=sys.stderr)
    raise SystemExit(code)


def git(*args: str) -> str:
    proc = subprocess.run(
        ["git", *args],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if proc.returncode != 0:
        fail(f"git {' '.join(args)} failed: {proc.stderr.strip()}")
    return proc.stdout.strip()


def matches(path: str, patterns: list[str]) -> bool:
    return any(fnmatch.fnmatchcase(path, pattern) for pattern in patterns)


def load_policy() -> dict:
    if not POLICY_PATH.is_file():
        fail(f"missing policy {POLICY_PATH.relative_to(ROOT)}")
    try:
        return json.loads(POLICY_PATH.read_text(encoding="utf-8"))
    except Exception as exc:
        fail(f"invalid policy JSON: {exc}")


def verify_invariants(policy: dict) -> None:
    for name, rule in policy.get("invariants", {}).items():
        rel = rule.get("path")
        if not rel:
            fail(f"invariant {name} has no path")
        path = ROOT / rel
        if not path.is_file():
            fail(f"invariant {name}: missing {rel}")
        text = path.read_text(encoding="utf-8", errors="replace")
        missing = [token for token in rule.get("mustContain", []) if token not in text]
        if missing:
            fail(f"invariant {name}: {rel} lost required tokens: {missing}")
        print(f"INVARIANT PASS: {name} -> {rel}")


def verify_entrance_car_reproducibility(policy: dict) -> None:
    car = policy.get("entranceCars", {})
    mode = car.get("mode")
    if mode != "LOCKED_RUNTIME_ASSETS":
        fail(f"entranceCars.mode must be LOCKED_RUNTIME_ASSETS, got {mode!r}")

    rel = car.get("authorityPath")
    if not rel:
        fail("entranceCars.authorityPath is not configured")
    source = ROOT / rel
    if not source.is_file() or source.stat().st_size == 0:
        fail(f"entrance-cars release blocked: missing runtime authority {rel}")

    text = source.read_text(encoding="utf-8", errors="replace")
    required = [str(v) for v in car.get("requiredAssetIds", [])] + list(car.get("requiredTokens", []))
    missing = [token for token in required if token not in text]
    if missing:
        fail(f"entrance-cars release blocked: runtime authority lost locked tokens: {missing}")

    forbidden = [token for token in car.get("forbiddenTokens", []) if token in text]
    if forbidden:
        fail(f"entrance-cars release blocked: stale baked-only failure path still present: {forbidden}")

    print("INVARIANT PASS: entrance cars use locked runtime assets with exact IDs")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--scope", required=True)
    ap.add_argument("--baseline-ref", required=True)
    ap.add_argument("--candidate-ref", default="HEAD")
    args = ap.parse_args()

    policy = load_policy()
    scopes = policy.get("scopes", {})
    if args.scope not in scopes:
        fail(f"unknown scope {args.scope!r}; allowed={sorted(scopes)}")

    git("rev-parse", "--verify", args.baseline_ref)
    git("rev-parse", "--verify", args.candidate_ref)
    if git("merge-base", "--is-ancestor", args.baseline_ref, args.candidate_ref) != "":
        pass

    diff = git(
        "diff",
        "--name-only",
        "--diff-filter=ACMRTUXB",
        f"{args.baseline_ref}...{args.candidate_ref}",
    )
    changed = [line.strip() for line in diff.splitlines() if line.strip()]
    print(f"BBYA scope={args.scope}")
    print(f"baseline={git('rev-parse', args.baseline_ref)}")
    print(f"candidate={git('rev-parse', args.candidate_ref)}")
    print(f"changed-files={len(changed)}")
    for path in changed:
        print(f"  {path}")

    protected_roots = tuple(policy.get("protectedRoots", []))
    governed_exact = set(policy.get("governedExactPaths", []))
    allowed = scopes[args.scope]
    violations: list[str] = []

    for path in changed:
        governed = path in governed_exact or path.startswith(protected_roots)
        if governed and not matches(path, allowed):
            violations.append(path)

    if violations:
        fail(
            f"scope {args.scope} attempted to touch protected source outside its allowlist: "
            + ", ".join(violations)
        )

    verify_invariants(policy)
    if args.scope == "entrance-cars":
        verify_entrance_car_reproducibility(policy)

    print("BBYA RELEASE GUARD: PASS — scope isolated; baseline invariants intact")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
