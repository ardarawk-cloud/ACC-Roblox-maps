import json
import os
import subprocess
import time
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


def find_studio_exe() -> Path:
    local = Path(os.environ["LOCALAPPDATA"])
    candidates = list((local / "Roblox" / "Versions").glob("*/RobloxStudioBeta.exe"))
    candidates = [p for p in candidates if p.is_file()]
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
            return preferred[0]
        if fallback:
            return fallback[0]
        time.sleep(1)
    raise RuntimeError("Roblox Studio window not found; titles=" + repr(last_titles[-20:]))


def invoke_lua(win, source: str):
    edit = win.child_window(auto_id="commandBarScriptEditor").wrapper_object()
    run = win.child_window(auto_id="multiLineRunButtonContainer.commandBarRunButton").wrapper_object()
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


def capture_view(win, name: str):
    win.set_focus()
    time.sleep(0.45)
    image = win.capture_as_image().convert("RGB")
    w, h = image.size
    # Calibrated crop for the 3D viewport on the ACC Studio worker.
    left = int(w * 0.30)
    top = int(h * 0.18)
    right = min(w, int(w * 0.80))
    bottom = min(h, int(h * 0.82))
    crop = image.crop((left, top, right, bottom))
    target_w = 1000
    target_h = max(1, round(crop.height * target_w / crop.width))
    crop = crop.resize((target_w, target_h), Image.Resampling.LANCZOS)
    crop.save(OUT / f"{name}.jpg", "JPEG", quality=84, optimize=True)


# This runner is single-job; remove any stale Studio window left by a prior failed audit.
subprocess.run(["taskkill", "/IM", "RobloxStudioBeta.exe", "/F"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
time.sleep(1)

studio = find_studio_exe()
subprocess.Popen([str(studio), str(PLACE)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
win = find_window()
try:
    win.maximize()
except Exception:
    pass
win.set_focus()
time.sleep(5)

# Run the generated place so the scaffold server script materializes the 3D city.
send_keys("+{F5}")
time.sleep(1)
send_keys("{F5}")
time.sleep(13)

views = [
    ("01-school-spawn", (0, 6, 310), (0, 12, 210), 20),
    ("02-downtown", (0, 6, 115), (0, 11, 0), 22),
    ("03-skate-park", (335, 7, 82), (235, 7, 0), 20),
    ("04-city-park", (0, 7, -108), (0, 6, -210), 20),
    ("05-residential", (-335, 8, 80), (-235, 12, 0), 20),
    ("06-sports-field", (340, 9, 300), (235, 7, 210), 22),
    ("07-city-overview", (0, 65, 390), (0, 4, 0), 36),
]

# Diagnostic marker confirms the generated runtime root exists.
invoke_lua(
    win,
    "local r=workspace:FindFirstChild('AfterSchoolCity'); print('[ASC_VISUAL] ROOT='..tostring(r~=nil)..' DISTRICTS='..tostring(r and r:FindFirstChild('Districts') and #r.Districts:GetChildren() or 0))",
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
    invoke_lua(win, lua)
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

if status["imageCount"] != len(views):
    raise RuntimeError(f"Expected {len(views)} screenshots, got {status['imageCount']}")

try:
    win.set_focus()
    send_keys("+{F5}")
    time.sleep(2)
except Exception:
    pass

print(json.dumps(status, indent=2))
