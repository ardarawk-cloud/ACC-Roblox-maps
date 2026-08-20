-- BBYA SOCIAL HUB — DJ WALL VISIBILITY REINFORCEMENT v3
-- Flushes the prestige wall into the architectural rear portal and restores real depth occlusion.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",20)
if not root then warn("[BBYA] DJ Wall visibility: BBYA_ZERO_BUILD missing") return end
local system=root:WaitForChild("DJWallMessageSystem",20)
if not system then warn("[BBYA] DJ Wall visibility: DJWallMessageSystem missing") return end
local screen=system:FindFirstChild("PrestigeLED",true)
if not screen or not screen:IsA("BasePart") then warn("[BBYA] DJ Wall visibility: PrestigeLED missing") return end

-- Remove presentation layers from earlier passes so the wall becomes one architectural surface.
for _,name in ipairs({"VisibilityReinforcement","WallRecess","TopTrim","BottomTrim"}) do
 local obj=system:FindFirstChild(name)
 if obj then obj:Destroy() end
end

-- Remove the legacy tiled LED/logo directly behind the prestige wall. The portal structure remains.
local club=root:FindFirstChild("MainClubRealism")
if club then
 for _,obj in ipairs(club:GetDescendants()) do
  if obj.Name=="LEDWall" or obj.Name=="LogoDisplay" then
   obj:Destroy()
  end
 end
end

local rig=Instance.new("Model")
rig.Name="VisibilityReinforcement"
rig:SetAttribute("Pass","DJ_WALL_VISIBILITY_V3_FLUSH")
rig.Parent=system

local PINK=Color3.fromRGB(255,38,155)
local CYAN=Color3.fromRGB(0,210,238)
local METAL=Color3.fromRGB(44,43,50)

-- PortalBack is centered at Z=48 with 1 stud depth; its audience-facing surface is ~Z=47.5.
-- Place the LED only a few hundredths in front of that surface so it reads as wall-mounted, not floating.
screen.CFrame=CFrame.new(3,10,47.36)
screen.Size=Vector3.new(56.8,12.55,.10)
screen.Color=Color3.fromRGB(9,7,13)
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

-- Thin recessed mounting plate and bezel, all within ~0.2 studs of the portal face.
part("MountPlate",Vector3.new(57.6,13.25,.08),CFrame.new(3,10,47.45),Color3.fromRGB(3,3,5),Enum.Material.Metal,0)
part("TopBezel",Vector3.new(57.5,.22,.10),CFrame.new(3,16.38,47.27),PINK,Enum.Material.Neon,.05)
part("BottomBezel",Vector3.new(57.5,.18,.10),CFrame.new(3,3.62,47.27),CYAN,Enum.Material.Neon,.05)
part("LeftBezel",Vector3.new(.20,12.65,.10),CFrame.new(-25.66,10,47.27),METAL,Enum.Material.Metal,0)
part("RightBezel",Vector3.new(.20,12.65,.10),CFrame.new(31.66,10,47.27),METAL,Enum.Material.Metal,0)

-- Important: do NOT render through avatars/booth. LightInfluence 0 keeps it bright while real depth stays intact.
local gui=screen:FindFirstChild("DJWallUI")
if gui and gui:IsA("SurfaceGui") then
 gui.Enabled=true
 gui.Face=Enum.NormalId.Front
 gui.AlwaysOnTop=false
 gui.LightInfluence=0
 gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
 gui.PixelsPerStud=48
 pcall(function() gui.MaxDistance=300 end)

 local oldMirror=screen:FindFirstChild("DJWallUI_OppositeFace")
 if oldMirror then oldMirror:Destroy() end
 local mirror=gui:Clone()
 mirror.Name="DJWallUI_OppositeFace"
 mirror.Face=Enum.NormalId.Back
 mirror.AlwaysOnTop=false
 mirror.LightInfluence=0
 mirror.Parent=screen
end

print("[BBYA] DJ Wall visibility v3 online: portal-flush mount + proper avatar depth")
