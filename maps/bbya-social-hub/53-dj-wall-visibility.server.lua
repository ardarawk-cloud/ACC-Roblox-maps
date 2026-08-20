-- BBYA SOCIAL HUB — DJ WALL VISIBILITY REINFORCEMENT v4
-- Final architectural flush mount. Does not touch the DJ booth.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",20)
if not root then warn("[BBYA] DJ Wall visibility: BBYA_ZERO_BUILD missing") return end
local system=root:WaitForChild("DJWallMessageSystem",20)
if not system then warn("[BBYA] DJ Wall visibility: DJWallMessageSystem missing") return end
local screen=system:FindFirstChild("PrestigeLED",true)
if not screen or not screen:IsA("BasePart") then warn("[BBYA] DJ Wall visibility: PrestigeLED missing") return end

for _,name in ipairs({"VisibilityReinforcement","WallRecess","TopTrim","BottomTrim"}) do
 local obj=system:FindFirstChild(name)
 if obj then obj:Destroy() end
end

-- The prestige wall replaces only the old tile/logo surface. Portal structure stays intact.
local club=root:FindFirstChild("MainClubRealism")
if club then
 for _,obj in ipairs(club:GetDescendants()) do
  if obj.Name=="LEDWall" or obj.Name=="LogoDisplay" then obj:Destroy() end
 end
end

local rig=Instance.new("Model")
rig.Name="VisibilityReinforcement"
rig:SetAttribute("Pass","DJ_WALL_VISIBILITY_V4_FINAL_FLUSH")
rig.Parent=system

local PINK=Color3.fromRGB(255,38,155)
local CYAN=Color3.fromRGB(0,210,238)
local METAL=Color3.fromRGB(36,35,42)
local BLACK=Color3.fromRGB(3,3,5)

-- PortalBack center Z=48, depth=1 => audience face is ~47.50.
-- LED face sits only ~0.07 studs forward: visually part of the wall, not a floating object.
screen.CFrame=CFrame.new(3,10,47.43)
screen.Size=Vector3.new(56.9,12.58,.055)
screen.Color=Color3.fromRGB(8,6,12)
screen.Material=Enum.Material.SmoothPlastic
screen.Transparency=0
screen.Reflectance=0
screen.CastShadow=false
screen.CanCollide=false
screen.CanTouch=false
screen.CanQuery=false

local function part(name,size,cf,color,material,transparency)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.Metal
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=rig
 return p
end

-- Recess + bezel share the portal plane. Side reveals make the screen read as built-in architecture.
part("Recess",Vector3.new(57.7,13.32,.055),CFrame.new(3,10,47.485),BLACK,Enum.Material.Metal,0)
part("TopReveal",Vector3.new(57.7,.30,.16),CFrame.new(3,16.53,47.40),METAL,Enum.Material.Metal,0)
part("BottomReveal",Vector3.new(57.7,.28,.16),CFrame.new(3,3.47,47.40),METAL,Enum.Material.Metal,0)
part("LeftReveal",Vector3.new(.30,12.78,.16),CFrame.new(-25.82,10,47.40),METAL,Enum.Material.Metal,0)
part("RightReveal",Vector3.new(.30,12.78,.16),CFrame.new(31.82,10,47.40),METAL,Enum.Material.Metal,0)
part("TopAccent",Vector3.new(54,.055,.055),CFrame.new(3,16.35,47.305),PINK,Enum.Material.Neon,.07)
part("BottomAccent",Vector3.new(54,.055,.055),CFrame.new(3,3.65,47.305),CYAN,Enum.Material.Neon,.07)

-- Real depth only. Never draw through avatar, DJ booth, or stage props.
local gui=screen:FindFirstChild("DJWallUI")
if gui and gui:IsA("SurfaceGui") then
 gui.Enabled=true
 gui.Face=Enum.NormalId.Front
 gui.AlwaysOnTop=false
 gui.LightInfluence=0
 gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
 gui.PixelsPerStud=50
 pcall(function() gui.MaxDistance=320 end)
 local oldMirror=screen:FindFirstChild("DJWallUI_OppositeFace")
 if oldMirror then oldMirror:Destroy() end
end

print("[BBYA] DJ Wall visibility v4 online: final portal-flush architecture; booth untouched")
