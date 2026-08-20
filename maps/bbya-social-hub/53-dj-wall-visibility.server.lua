-- BBYA SOCIAL HUB — DJ WALL VISIBILITY REINFORCEMENT v1
-- Guarantees the prestige wall reads as a physical LED screen from the dance floor.
-- Keeps the existing DJ Wall message system/queue intact; this pass only fixes presentation.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",20)
if not root then
 warn("[BBYA] DJ Wall visibility: BBYA_ZERO_BUILD missing")
 return
end

local system=root:WaitForChild("DJWallMessageSystem",20)
if not system then
 warn("[BBYA] DJ Wall visibility: DJWallMessageSystem missing")
 return
end

local screen=system:FindFirstChild("PrestigeLED",true)
if not screen or not screen:IsA("BasePart") then
 warn("[BBYA] DJ Wall visibility: PrestigeLED missing")
 return
end

local old=system:FindFirstChild("VisibilityReinforcement")
if old then old:Destroy() end
local rig=Instance.new("Model")
rig.Name="VisibilityReinforcement"
rig:SetAttribute("Pass","DJ_WALL_VISIBILITY_V1")
rig.Parent=system

local PINK=Color3.fromRGB(255,38,155)
local CYAN=Color3.fromRGB(0,210,238)
local GOLD=Color3.fromRGB(238,190,94)
local WHITE=Color3.fromRGB(245,243,248)
local DARK=Color3.fromRGB(7,6,10)

-- Pull the screen clearly in front of the legacy tiled LED wall to eliminate depth ambiguity.
screen.CFrame=CFrame.new(3,10,45.90)
screen.Size=Vector3.new(57.2,12.8,.18)
screen.Color=Color3.fromRGB(13,5,18)
screen.Material=Enum.Material.SmoothPlastic
screen.Transparency=0
screen.Reflectance=.02
screen.CastShadow=false

local function part(name,size,cf,color,material,transparency)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=size
 p.CFrame=cf
 p.Color=color
 p.Material=material or Enum.Material.Metal
 p.Transparency=transparency or 0
 p.Anchored=true
 p.CanCollide=false
 p.CanTouch=false
 p.CanQuery=false
 p.CastShadow=false
 p.Parent=rig
 return p
end

-- Physical bezel: obvious even before the SurfaceGui finishes rendering.
part("BackPlate",Vector3.new(59.0,14.1,.16),CFrame.new(3,10,46.05),Color3.fromRGB(4,4,7),Enum.Material.Metal,0)
part("TopBezel",Vector3.new(59.0,.38,.26),CFrame.new(3,16.58,45.74),PINK,Enum.Material.Neon,.02)
part("BottomBezel",Vector3.new(59.0,.28,.26),CFrame.new(3,3.42,45.74),CYAN,Enum.Material.Neon,.02)
part("LeftBezel",Vector3.new(.32,13.0,.26),CFrame.new(-25.72,10,45.74),Color3.fromRGB(65,48,67),Enum.Material.Metal,0)
part("RightBezel",Vector3.new(.32,13.0,.26),CFrame.new(31.72,10,45.74),Color3.fromRGB(45,63,70),Enum.Material.Metal,0)
part("LeftGlow",Vector3.new(.065,10.8,.08),CFrame.new(-25.88,10,45.57),PINK,Enum.Material.Neon,.14)
part("RightGlow",Vector3.new(.065,10.8,.08),CFrame.new(31.88,10,45.57),CYAN,Enum.Material.Neon,.14)

local topGlow=part("TopGlowSource",Vector3.new(42,.08,.08),CFrame.new(3,16.35,45.56),PINK,Enum.Material.Neon,.15)
local light=Instance.new("PointLight")
light.Color=PINK
light.Brightness=.42
light.Range=18
light.Shadows=false
light.Parent=topGlow

-- Force the live SurfaceGui to render independent of nightclub darkness.
local gui=screen:FindFirstChild("DJWallUI")
if gui and gui:IsA("SurfaceGui") then
 gui.Enabled=true
 gui.Face=Enum.NormalId.Front
 gui.AlwaysOnTop=true
 gui.LightInfluence=0
 gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
 gui.PixelsPerStud=48
 pcall(function() gui.MaxDistance=300 end)

 local oldMirror=screen:FindFirstChild("DJWallUI_OppositeFace")
 if oldMirror then oldMirror:Destroy() end
 local mirror=gui:Clone()
 mirror.Name="DJWallUI_OppositeFace"
 mirror.Face=Enum.NormalId.Back
 mirror.AlwaysOnTop=true
 mirror.LightInfluence=0
 mirror.Parent=screen
end

-- A small physical header guarantees players immediately read the object as the DJ wall.
local header=part("HeaderPlate",Vector3.new(20,.82,.18),CFrame.new(3,17.04,45.68),DARK,Enum.Material.SmoothPlastic,0)
local headerGui=Instance.new("SurfaceGui")
headerGui.Name="HeaderUI"
headerGui.Face=Enum.NormalId.Front
headerGui.AlwaysOnTop=true
headerGui.LightInfluence=0
headerGui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
headerGui.PixelsPerStud=55
headerGui.Parent=header
local headerText=Instance.new("TextLabel")
headerText.Size=UDim2.fromScale(1,1)
headerText.BackgroundTransparency=1
headerText.Text="BBYA  //  LIVE WALL"
headerText.Font=Enum.Font.GothamBlack
headerText.TextScaled=true
headerText.TextColor3=WHITE
headerText.Parent=headerGui
local hs=Instance.new("UIStroke")
hs.Color=GOLD
hs.Thickness=1.3
hs.Transparency=.18
hs.Parent=headerText

print("[BBYA] DJ Wall visibility v1 online: foreground screen + dual-face UI + physical LED bezel")
