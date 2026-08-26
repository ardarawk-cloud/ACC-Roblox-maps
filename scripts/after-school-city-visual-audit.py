import json
import os
import subprocess
import sys
import time
import traceback
from pathlib import Path

from PIL import Image
from pywinauto import Desktop
from pywinauto.keyboard import send_keys

WORKSPACE = Path(os.environ["GITHUB_WORKSPACE"])
PLACE = Path(os.environ["ASC_VISUAL_PLACE"])
OUT = WORKSPACE / "deploy-status" / "after-school-city-visual"
OUT.mkdir(parents=True, exist_ok=True)
for old in OUT.glob("*"):
    if old.is_file():
        old.unlink()

STATE = {
    "status": "STARTED",
    "stage": "bootstrap",
    "sourceCommit": os.environ.get("GITHUB_SHA", ""),
    "runId": os.environ.get("GITHUB_RUN_ID", ""),
    "place": str(PLACE),
    "publishPerformed": False,
}


def checkpoint(stage: str, **extra):
    STATE["stage"] = stage
    STATE.update(extra)
    (OUT / "diagnostic.json").write_text(json.dumps(STATE, indent=2) + "\n", encoding="utf-8")
    print(f"[ASC VISUAL] {stage}: {extra}", flush=True)


def unhandled(exc_type, exc_value, exc_tb):
    payload = dict(STATE)
    payload.update(
        {
            "status": "FAILED",
            "errorType": getattr(exc_type, "__name__", str(exc_type)),
            "error": str(exc_value),
            "traceback": "".join(traceback.format_exception(exc_type, exc_value, exc_tb)),
            "failedAtEpoch": int(time.time()),
            "publishPerformed": False,
        }
    )
    try:
        (OUT / "error.json").write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
        (OUT / "diagnostic.json").write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    finally:
        traceback.print_exception(exc_type, exc_value, exc_tb)


sys.excepthook = unhandled
checkpoint("bootstrap-ready", python=sys.executable, cwd=str(Path.cwd()), placeExists=PLACE.exists())


def find_studio_exe() -> Path:
    local = Path(os.environ["LOCALAPPDATA"])
    candidates = list((local / "Roblox" / "Versions").glob("*/RobloxStudioBeta.exe"))
    candidates = [p for p in candidates if p.is_file()]
    checkpoint("studio-search", candidateCount=len(candidates))
    if not candidates:
        raise RuntimeError("RobloxStudioBeta.exe not found")
    return max(candidates, key=lambda p: p.stat().st_mtime)


def find_window(timeout: int = 50):
    deadline = time.time() + timeout
    last_titles = []
    while time.time() < deadline:
        windows = Desktop(backend="uia").windows()
        last_titles = []
        preferred = []
        fallback = []
        for w in windows:
            try:
                title = w.window_text() or ""
                last_titles.append(title)
                low = title.lower()
                if "after-school-city-visual" in low or "after school city" in low:
                    preferred.append(w)
                elif "roblox studio" in low or "studio" in low:
                    fallback.append(w)
            except Exception:
                pass
        if preferred:
            checkpoint("studio-window-found", title=preferred[0].window_text(), mode="preferred")
            return preferred[0]
        if fallback:
            checkpoint("studio-window-found", title=fallback[0].window_text(), mode="fallback")
            return fallback[0]
        time.sleep(1)
    checkpoint("studio-window-timeout", windowTitles=last_titles[-30:])
    raise RuntimeError("Roblox Studio window not found; titles=" + repr(last_titles[-20:]))


def invoke_lua(win, source: str, marker: str):
    checkpoint("commandbar-locate", marker=marker)
    edit = win.child_window(auto_id="commandBarScriptEditor").wrapper_object()
    run = win.child_window(auto_id="multiLineRunButtonContainer.commandBarRunButton").wrapper_object()
    checkpoint("commandbar-found", marker=marker)
    try:
        edit.iface_value.SetValue(source)
    except Exception:
        edit.set_edit_text(source)
    time.sleep(0.25)
    try:
        run.invoke()
    except Exception:
        run.click_input()
    time.sleep(1.2)
    checkpoint("commandbar-invoked", marker=marker)


def capture_view(win, name: str):
    checkpoint("capture-begin", view=name)
    win.set_focus()
    time.sleep(0.45)
    image = win.capture_as_image().convert("RGB")
    w, h = image.size
    checkpoint("capture-window", view=name, width=w, height=h)
    left = int(w * 0.30)
    top = int(h * 0.18)
    right = min(w, int(w * 0.80))
    bottom = min(h, int(h * 0.82))
    crop = image.crop((left, top, right, bottom))
    target_w = 1000
    target_h = max(1, round(crop.height * target_w / crop.width))
    crop = crop.resize((target_w, target_h), Image.Resampling.LANCZOS)
    target = OUT / f"{name}.jpg"
    crop.save(target, "JPEG", quality=84, optimize=True)
    checkpoint("capture-saved", view=name, bytes=target.stat().st_size)


checkpoint("studio-cleanup")
subprocess.run(["taskkill", "/IM", "RobloxStudioBeta.exe", "/F"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
time.sleep(1)

studio = find_studio_exe()
checkpoint("studio-launch", studioExe=str(studio), place=str(PLACE))
subprocess.Popen([str(studio), str(PLACE)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
win = find_window()
try:
    win.maximize()
except Exception as exc:
    checkpoint("studio-maximize-warning", warning=str(exc))
win.set_focus()
time.sleep(5)
checkpoint("studio-ready", title=win.window_text())

send_keys("+{F5}")
time.sleep(1)
send_keys("{F5}")
time.sleep(13)
checkpoint("play-wait-complete")

views = [
    ("01-school-spawn", (0, 6, 310), (0, 12, 210), 20),
    ("02-downtown", (0, 6, 115), (0, 11, 0), 22),
    ("03-skate-park", (335, 7, 82), (235, 7, 0), 20),
    ("04-city-park", (0, 7, -108), (0, 6, -210), 20),
    ("05-residential", (-335, 8, 80), (-235, 12, 0), 20),
    ("06-sports-field", (340, 9, 300), (235, 7, 210), 22),
    ("07-city-overview", (0, 65, 390), (0, 4, 0), 36),
]

invoke_lua(
    win,
    "local r=workspace:FindFirstChild('AfterSchoolCity'); print('[ASC_VISUAL] ROOT='..tostring(r~=nil)..' DISTRICTS='..tostring(r and r:FindFirstChild('Districts') and #r.Districts:GetChildren() or 0))",
    "diagnostic",
)

for name, pos, look, zoom in views:
    p = ",".join(str(v) for v in pos)
    l = ",".join(str(v) for v in look)
    lua = (
        "local P=game:GetService('Players'):GetPlayers()[1];"
        "if P then "
        f"P.CameraMinZoomDistance={zoom};P.CameraMaxZoomDistance={zoom};"
        "local C=P.Character;local H=C and C:FindFirstChild('HumanoidRootPart');"
        "local U=C and C:FindFirstChildOfClass('Humanoid');"
        "if U then U.AutoRotate=false end;"
        f"if H then H.Anchored=true;H.CFrame=CFrame.lookAt(Vector3.new({p}),Vector3.new({l}));"
        "H.AssemblyLinearVelocity=Vector3.zero;H.AssemblyAngularVelocity=Vector3.zero end end"
    )
    invoke_lua(win, lua, name)
    time.sleep(0.9)
    capture_view(win, name)

status = {
    "status": "CAPTURED",
    "sourceCommit": os.environ.get("GITHUB_SHA", ""),
    "runId": os.environ.get("GITHUB_RUN_ID", ""),
    "capturedAtEpoch": int(time.time()),
    "place": PLACE.name,
    "views": [v[0] for v in views],
    "imageCount": len(list(OUT.glob("*.jpg"))),
    "publishPerformed": False,
    "studioWindow": win.window_text(),
}
(OUT / "audit.json").write_text(json.dumps(status, indent=2) + "\n", encoding="utf-8")
checkpoint("audit-written", imageCount=status["imageCount"])

if status["imageCount"] != len(views):
    raise RuntimeError(f"Expected {len(views)} screenshots, got {status['imageCount']}")

try:
    win.set_focus()
    send_keys("+{F5}")
    time.sleep(2)
except Exception as exc:
    checkpoint("stop-play-warning", warning=str(exc))

checkpoint("complete", status="CAPTURED", imageCount=status["imageCount"])
print(json.dumps(status, indent=2))
