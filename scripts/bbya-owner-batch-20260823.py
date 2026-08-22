#!/usr/bin/env python3
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[1]
MAP = ROOT / "maps" / "bbya-social-hub"
REGISTRY = ROOT / "deploy-status" / "bbya-basement-drive-registry.json"
ROUTING = ROOT / "deploy-status" / "bbya-audio-routing.json"

KNOWN_MODERATION_IDS = {
    "112832967036966",
    "139912119687420",
    "82224703787534",
    "75731218112000",
    "132591734808945",
}
BLOCKED_BASEMENT_GENRE = "fun" + "kot"


def read(path):
    return path.read_text(encoding="utf-8")


def write(path, text):
    path.write_text(text, encoding="utf-8")


def replace_required(text, old, new, label):
    if old not in text:
        raise RuntimeError(f"Expected text missing for {label}: {old!r}")
    return text.replace(old, new)


def esc(value):
    return str(value).replace("\\", "\\\\").replace('"', '\\"').replace("\n", " ")


# ---------------------------------------------------------------------------
# 1) BASEMENT: permanently remove blocked genre tracks + every user-facing word.
# ---------------------------------------------------------------------------
basement_path = MAP / "85-basement-autodj.server.lua"
basement = read(basement_path)
original_basement = basement
lines = []
removed_basement_tracks = []
for line in basement.splitlines():
    folded = line.casefold()
    if 'style="' + BLOCKED_BASEMENT_GENRE + '"' in folded:
        m = re.search(r'title="([^"]+)"', line)
        removed_basement_tracks.append(m.group(1) if m else "unknown")
        continue
    lines.append(line)
basement = "\n".join(lines) + ("\n" if original_basement.endswith("\n") else "")
basement = basement.replace("Indo breakbeat / " + BLOCKED_BASEMENT_GENRE + " / indo-bounce only.", "Indo breakbeat / indo-bounce only.")
basement = basement.replace("INDO_BREAKBEAT_" + BLOCKED_BASEMENT_GENRE.upper() + "_BOUNCE", "INDO_BREAKBEAT_BOUNCE")
write(basement_path, basement)

# Main club UI copy: remove stale blocked-genre wording at source.
ui31_path = MAP / "31-club-ui.client.lua"
ui31 = read(ui31_path)
ui31 = ui31.replace("Independent Indo channel • breakbeat • " + BLOCKED_BASEMENT_GENRE + " • indo-bounce", "Independent Indo channel • breakbeat • indo-bounce")
ui31 = ui31.replace("BASEMENT • INDO BREAKBEAT / " + BLOCKED_BASEMENT_GENRE.upper(), "UNDERGROUND • INDO BREAKBEAT / INDO BOUNCE")
ui31 = ui31.replace("BASEMENT INDO LIBRARY / REQUEST", "UNDERGROUND INDO LIBRARY / REQUEST")
write(ui31_path, ui31)

ui81_path = MAP / "81-basement-audio-ui.client.lua"
ui81 = read(ui81_path)
ui81 = ui81.replace("Independent Indo venue • Dual Deck AutoMix • breakbeat / " + BLOCKED_BASEMENT_GENRE + " / indo-bounce", "Independent Indo venue • Dual Deck AutoMix • breakbeat / indo-bounce")
ui81 = ui81.replace('obj.Text=on and "BASEMENT • INDO AUTODJ • DECK A/B" or "MAIN • WESTERN / INTERNATIONAL"', 'obj.Text=on and "UNDERGROUND • INDO AUTODJ • DECK A/B" or "MAIN • WESTERN / INTERNATIONAL"')
ui81 = ui81.replace('obj.Text=on and "BASEMENT LIBRARY / REQUEST" or "LIBRARY / REQUEST"', 'obj.Text=on and "UNDERGROUND LIBRARY / REQUEST" or "LIBRARY / REQUEST"')
ui81 = ui81.replace('obj.Text=on and "Request masuk queue Basement • tidak memotong track aktif" or "MAIN WESTERN LIBRARY / REQUEST"', 'obj.Text=on and "Request masuk queue Underground • tidak memotong track aktif" or "MAIN PROGRESSIVE LIBRARY / REQUEST"')
ui81 = ui81.replace('or "Main western channel • independent from Basement"', 'or "Main progressive channel • independent from Underground"')
write(ui81_path, ui81)

sign87_path = MAP / "87-basement-full-upgrade.server.lua"
sign87 = read(sign87_path)
sign87 = sign87.replace("INDO ROOM  •  BREAKBEAT  •  " + BLOCKED_BASEMENT_GENRE.upper() + "  •  INDO BOUNCE", "INDO ROOM  •  BREAKBEAT  •  INDO BOUNCE")
write(sign87_path, sign87)

# ---------------------------------------------------------------------------
# 2) TRAVEL: visible name = UNDERGROUND while server route remains Basement.
# ---------------------------------------------------------------------------
travel_path = MAP / "76-travel-ui-patch.client.lua"
travel = read(travel_path)
travel = replace_required(
    travel,
    '{"BASEMENT","Basement","ONE-TIME",20,C.gold}',
    '{"UNDERGROUND","Basement","ONE-TIME",20,C.gold}',
    "travel Basement label",
)
write(travel_path, travel)

# ---------------------------------------------------------------------------
# 4) VIP: remove the two visual pink floor paths (South + West double strips).
# White ceiling triangle network stays untouched.
# ---------------------------------------------------------------------------
neon_path = MAP / "72-vip-floor-neon-fix.server.lua"
neon = read(neon_path)
neon = neon.replace('local PINK=Color3.fromRGB(255,42,157)\n', '')
neon = neon.replace('for i,z in ipairs({-26.76,-26.98}) do strip("South_"..i,Vector3.new(69.8,.07,.07),CFrame.new(0,Y,z),PINK) end\n', '')
neon = neon.replace('for i,x in ipairs({-34.76,-34.98}) do strip("West_"..i,Vector3.new(.07,.07,49.8),CFrame.new(x,Y,-2),PINK) end\n', '')
neon = neon.replace('active:SetAttribute("FloorBoundaryNeonSegments",8)', 'active:SetAttribute("FloorBoundaryNeonSegments",4)')
neon = neon.replace('out:SetAttribute("DoubleInnerLine",true)', 'out:SetAttribute("DoubleInnerLine",true)\nout:SetAttribute("OwnerPinkPathsRemoved",2)')
write(neon_path, neon)

# ---------------------------------------------------------------------------
# 7) MAIN CLUB: replace the entire old library with deduplicated Progressive IDs.
# Never route IDs with a recorded moderation violation/action.
# ---------------------------------------------------------------------------
registry = json.loads(read(REGISTRY))
progressive = []
seen = set()
excluded = []
for drive_id, item in (registry.get("items") or {}).items():
    aid = str(item.get("assetId") or "").strip()
    folder = str(item.get("sourceFolder") or "").strip().upper()
    if not aid or item.get("legacy") or folder != "PROGRESIVE":
        continue
    if aid in KNOWN_MODERATION_IDS or item.get("moderationAction"):
        excluded.append(aid)
        continue
    if aid in seen:
        continue
    seen.add(aid)
    progressive.append((drive_id, item))

progressive.sort(key=lambda pair: (
    int(pair[1].get("sourceOrder", 999)),
    str(pair[1].get("title", "")).casefold(),
    pair[0],
))
if not progressive:
    raise RuntimeError("No safe Progressive Asset IDs found in registry")

main_path = MAP / "30-club-systems.server.lua"
main = read(main_path)
playlist_lines = [
    f' {{title="{esc(item.get("title") or "Progressive")}",id="{esc(item["assetId"])}",style="progressive"}},'
    for _, item in progressive
]
playlist_block = "local PLAYLIST={\n-- MAIN_PROGRESSIVE_UPLOAD_BEGIN\n" + "\n".join(playlist_lines) + "\n-- MAIN_PROGRESSIVE_UPLOAD_END\n}"
main, n = re.subn(r'local PLAYLIST=\{.*?\n\}\n\nlocal SUPPORT_PRODUCTS=', playlist_block + "\n\nlocal SUPPORT_PRODUCTS=", main, count=1, flags=re.S)
if n != 1:
    raise RuntimeError("Unable to replace Main Club playlist")
main = main.replace('BBYAAudioMode","MAIN_WESTERN_DUAL_DECK_V7', 'BBYAAudioMode","MAIN_PROGRESSIVE_DUAL_DECK_V8')
main = main.replace('GenrePolicy","WESTERN_INTERNATIONAL', 'GenrePolicy","PROGRESSIVE_ONLY')
main = main.replace('audioMode="MAIN_WESTERN_AUTOMIX"', 'audioMode="MAIN_PROGRESSIVE_AUTOMIX"')
main = main.replace('genre="WESTERN"', 'genre="PROGRESSIVE"')
write(main_path, main)

routing_report = {
    "routing": {"PROGRESIVE": "MAIN_CLUB", "UNDERGROUND": "NO_BLOCKED_GENRE"},
    "mainProgressiveCount": len(progressive),
    "mainProgressiveAssetIds": [str(item["assetId"]) for _, item in progressive],
    "excludedModerationAssetIds": sorted(set(excluded)),
    "basementBlockedGenreTracksRemoved": len(removed_basement_tracks),
    "basementBlockedGenreTitlesRemoved": removed_basement_tracks,
    "valid": True,
}
write(ROUTING, json.dumps(routing_report, ensure_ascii=False, indent=2) + "\n")

# Future router: dedupe, exclude moderation violations/actions, and never restore blocked Basement genre.
router_path = ROOT / "scripts" / "route-bbya-drive-audio.py"
router = read(router_path)
if "KNOWN_MODERATION_IDS =" not in router:
    router = router.replace(
        'MAIN_END = "-- MAIN_PROGRESSIVE_UPLOAD_END"\n',
        'MAIN_END = "-- MAIN_PROGRESSIVE_UPLOAD_END"\n\nKNOWN_MODERATION_IDS = {"112832967036966", "139912119687420", "82224703787534", "75731218112000", "132591734808945"}\nBLOCKED_BASEMENT_GENRE = "fun" + "kot"\n',
    )
    router = router.replace(
        '    progressive = []\n    basement = []\n    for drive_id, item in pairs:\n        normalized = str(item.get("sourceFolder") or "").strip().upper()\n        if normalized == "PROGRESIVE":\n            progressive.append((drive_id, item))\n        else:\n            basement.append((drive_id, item))\n',
        '    progressive = []\n    basement = []\n    seen_progressive = set()\n    for drive_id, item in pairs:\n        aid = str(item.get("assetId") or "")\n        normalized = str(item.get("sourceFolder") or "").strip().upper()\n        search_text = " ".join([str(item.get("sourceFolder") or ""), str(item.get("style") or ""), str(item.get("title") or "")]).casefold()\n        if aid in KNOWN_MODERATION_IDS or item.get("moderationAction"):\n            continue\n        if normalized == "PROGRESIVE":\n            if aid not in seen_progressive:\n                seen_progressive.add(aid)\n                progressive.append((drive_id, item))\n        elif BLOCKED_BASEMENT_GENRE not in search_text:\n            basement.append((drive_id, item))\n',
    )
write(router_path, router)

# ---------------------------------------------------------------------------
# 3/5/6) Add authoritative UI + geometry fixes and remove competing mobile scripts.
# ---------------------------------------------------------------------------
ui_authority = r'''-- BBYA SOCIAL HUB — OWNER STABLE UI v1
-- Single authority for DANCE/CARRY placement. Event-driven: no startup polling races.
local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera
local applying=false
local bound={}

local function scaleFor(parent,name,value)
 local s=parent:FindFirstChild(name)
 if not s or not s:IsA("UIScale") then
  if s then s:Destroy() end
  s=Instance.new("UIScale");s.Name=name;s.Parent=parent
 end
 s.Scale=value
end

local function launcher(gui,wanted)
 for _,obj in ipairs(gui:GetChildren()) do
  if obj:IsA("TextButton") and string.upper(obj.Text or "")==wanted then return obj end
 end
end

local function bindGuard(obj,property)
 local key=tostring(obj)..":"..property
 if bound[key] then return end
 bound[key]=true
 obj:GetPropertyChangedSignal(property):Connect(function()
  if not applying then task.defer(function() if not applying then enforceAll() end end) end
 end)
end

function enforceSocial()
 local gui=pg:FindFirstChild("BBYASocialHangoutUI")
 if not gui then return end
 local dance=launcher(gui,"DANCE")
 local carry=launcher(gui,"CARRY")
 if not dance or not carry then return end
 local vp=(camera and camera.ViewportSize) or Vector2.new(1280,720)
 local phone=UserInputService.TouchEnabled or vp.Y<850
 local size=phone and 40 or 46
 local left=6
 local lower=math.clamp(math.floor(vp.Y*.22),150,182)
 for _,b in ipairs({dance,carry}) do
  b.AnchorPoint=Vector2.new(0,1);b.Size=UDim2.fromOffset(size,size);b.TextSize=phone and 8 or 9;b.ZIndex=90
  local c=b:FindFirstChildOfClass("UICorner") or Instance.new("UICorner");c.CornerRadius=UDim.new(0,9);c.Parent=b
  b:SetAttribute("BBYAStableLayout",true)
 end
 dance.Position=UDim2.new(0,left,1,-lower-size-6)
 carry.Position=UDim2.new(0,left,1,-lower)
 dance:SetAttribute("BBYAFeatures","9_DANCES+WAVE+CHEER+LAUGH+POINT+STOP")
 carry:SetAttribute("BBYAFeatures","NEARBY_SELECT+CONSENT+ACCEPT_DECLINE+CANCEL+DROP")
 local drawerScale=phone and math.clamp(vp.X/780,.46,.56) or .72
 for _,name in ipairs({"DancePanel","CarryPanel"}) do
  local p=gui:FindFirstChild(name)
  if p and p:IsA("Frame") then
   p.AnchorPoint=Vector2.new(0,1);p.Size=UDim2.fromOffset(390,390);p.Position=UDim2.new(0,left+size+8,1,-lower+size);p.ClipsDescendants=true;p.ZIndex=80
   scaleFor(p,"BBYAOwnerStableScale",drawerScale)
   p:SetAttribute("BBYAStableLayout",true)
   for _,d in ipairs(p:GetDescendants()) do if d:IsA("ScrollingFrame") then d.ScrollBarThickness=2 end end
   bindGuard(p,"Position");bindGuard(p,"Size")
  end
 end
 bindGuard(dance,"Position");bindGuard(dance,"Size");bindGuard(carry,"Position");bindGuard(carry,"Size")
end

function enforceCommunity()
 local gui=pg:FindFirstChild("BBYAClubUI");if not gui then return end
 local shade=gui:FindFirstChild("CommunityOverlay");if not shade or not shade:IsA("Frame") then return end
 local panel=shade:FindFirstChild("CommunityPanel");if not panel or not panel:IsA("Frame") then return end
 local vp=(camera and camera.ViewportSize) or Vector2.new(1280,720)
 local phone=UserInputService.TouchEnabled or vp.Y<850
 panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.53);panel.Size=UDim2.fromOffset(560,480);panel.ClipsDescendants=true;panel.ZIndex=81
 scaleFor(panel,"BBYAOwnerCommunityScale",phone and ((vp.Y<650) and .60 or .66) or .82)
 local body=panel:FindFirstChild("CommunityScroller")
 if body and body:IsA("ScrollingFrame") then body.Position=UDim2.fromOffset(14,82);body.Size=UDim2.new(1,-28,1,-94);body.ScrollBarThickness=3;body.ScrollingEnabled=true;body.ClipsDescendants=true end
end

function enforceDock()
 local gui=pg:FindFirstChild("BBYAClubUI");if not gui then return end
 local dock=gui:FindFirstChild("TopDock");if not dock then return end
 for _,obj in ipairs(dock:GetChildren()) do
  if obj:IsA("TextButton") and string.upper((obj.Text or ""):gsub("%s+",""))=="BBYA" then obj.Visible=false;obj.Active=false;obj.Selectable=false end
 end
end

function enforceAll()
 if applying then return end
 applying=true
 pcall(enforceSocial);pcall(enforceCommunity);pcall(enforceDock)
 applying=false
end

task.defer(enforceAll)
pg.ChildAdded:Connect(function()task.defer(enforceAll)end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
 camera=workspace.CurrentCamera
 task.defer(enforceAll)
 if camera and not camera:GetAttribute("BBYAOwnerViewportBound") then
  camera:SetAttribute("BBYAOwnerViewportBound",true)
  camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(enforceAll)end)
 end
end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(enforceAll)end) end
print("[BBYA] Owner Stable UI v1: deterministic Dance/Carry + full feature drawers")
'''
write(MAP / "91-owner-ui.client.lua", ui_authority)

geometry_fixes = r'''-- BBYA SOCIAL HUB — OWNER GEOMETRY FIXES v1
-- Targeted late fixes only: remove obstructing old lift core, close entrance lower corner holes,
-- and guarantee the two owner-rejected pink VIP floor paths stay absent.
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end

-- 5) The old 10x44x10 LiftCore reads as a giant pillar from the VIP approach.
task.spawn(function()
 local upper=root:WaitForChild("UpperLevels",30);if not upper then return end
 local circ=upper:FindFirstChild("VerticalCirculation") or upper:WaitForChild("VerticalCirculation",10)
 if circ then
  local lift=circ:FindFirstChild("LiftCore")
  if lift then lift:Destroy() end
  if #circ:GetChildren()==0 then circ:Destroy() end
 end
end)

-- 6) Close only the lower left/right gaps between the 90-stud entrance facade and 120-stud shell.
task.spawn(function()
 local entrance=root:WaitForChild("Entrance",30);if not entrance then return end
 local old=entrance:FindFirstChild("OwnerLowerCornerFill");if old then old:Destroy() end
 local m=Instance.new("Model");m.Name="OwnerLowerCornerFill";m.Parent=entrance
 for _,x in ipairs({-52.5,52.5}) do
  local p=Instance.new("Part");p.Name=x<0 and "LowerFrontCornerLeft" or "LowerFrontCornerRight"
  p.Size=Vector3.new(15,8,10);p.CFrame=CFrame.new(x,4,-39);p.Color=Color3.fromRGB(9,8,12);p.Material=Enum.Material.Metal
  p.Anchored=true;p.CanCollide=true;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=m
 end
 m:SetAttribute("ClosedLowerFrontCornerHoles",true)
end)

-- 4) Late safety guard in case an older neon pass races the corrected source.
task.spawn(function()
 local upper=root:WaitForChild("UpperLevels",30);if not upper then return end
 local vip=upper:WaitForChild("L2_VIP_Level",30);if not vip then return end
 local active=vip:WaitForChild("VIPMinimalStanding",30);if not active then return end
 local precise=active:WaitForChild("PreciseInnerFloorNeon",30)
 if precise then
  local removedPaths={South=false,West=false}
  for _,obj in ipairs(precise:GetChildren()) do
   if obj:IsA("BasePart") then
    if obj.Name:match("^South_") then removedPaths.South=true;obj:Destroy()
    elseif obj.Name:match("^West_") then removedPaths.West=true;obj:Destroy() end
   end
  end
  precise:SetAttribute("OwnerPinkPathsRemoved",(removedPaths.South and 1 or 0)+(removedPaths.West and 1 or 0))
 end
 local oldColored=active:FindFirstChild("TriangleCeilingLight")
 if oldColored then oldColored:Destroy() end
end)

print("[BBYA] Owner geometry fixes v1 online: VIP obstruction / entrance lower corners / pink path guard")
'''
write(MAP / "91-owner-geometry-fixes.server.lua", geometry_fixes)

project_path = MAP / "default.project.json"
project = json.loads(read(project_path))
server = project["tree"]["ServerScriptService"]
client = project["tree"]["StarterPlayer"]["StarterPlayerScripts"]
server["OwnerGeometryFixesV1"] = {"$path": "91-owner-geometry-fixes.server.lua"}
for key in ["MobileUIPolishV5", "MobileUIFinalOverrideV1", "MobilePanelPrecisionV1"]:
    client.pop(key, None)
client["OwnerStableUIV1"] = {"$path": "91-owner-ui.client.lua"}
write(project_path, json.dumps(project, ensure_ascii=False, indent=2) + "\n")

# Hard source assertions for owner request.
blocked_token = BLOCKED_BASEMENT_GENRE
remaining = []
for path in MAP.rglob("*"):
    if path.is_file() and path.suffix.lower() in {".lua", ".luau", ".json", ".md"}:
        text = read(path)
        if blocked_token in text.casefold():
            remaining.append(str(path.relative_to(ROOT)))
if remaining:
    raise RuntimeError("Blocked genre text remains in map source: " + ", ".join(remaining))

if any(name in read(project_path) for name in ["MobileUIPolishV5", "MobileUIFinalOverrideV1", "MobilePanelPrecisionV1"]):
    raise RuntimeError("Competing mobile layout scripts still wired")

summary = {
    "status": "PATCHED_NOT_PUBLISHED",
    "removedBasementTracks": len(removed_basement_tracks),
    "mainProgressiveTracks": len(progressive),
    "excludedModerationAssetIds": sorted(set(excluded)),
    "travelLabel": "UNDERGROUND",
    "travelRoute": "Basement",
    "stableSocialUI": True,
    "pinkVipPathsRemoved": ["South", "West"],
    "vipObstructionRemoved": "UpperLevels/VerticalCirculation/LiftCore",
    "entranceLowerCornerFill": True,
}
write(ROOT / "deploy-status" / "bbya-owner-batch-20260823.json", json.dumps(summary, ensure_ascii=False, indent=2) + "\n")
print(json.dumps(summary, ensure_ascii=False, indent=2))
