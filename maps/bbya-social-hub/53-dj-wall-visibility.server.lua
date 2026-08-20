-- BBYA SOCIAL HUB — DJ WALL VISIBILITY REINFORCEMENT v2
-- Keeps the prestige wall clearly visible without intersecting the DJ/avatar camera zone.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",20)
if not root then warn("[BBYA] DJ Wall visibility: BBYA_ZERO_BUILD missing") return end
local system=root:WaitForChild("DJWallMessageSystem",20)
if not system then warn("[BBYA] DJ Wall visibility: DJWallMessageSystem missing") return end
local screen=system:FindFirstChild("PrestigeLED",true)
if not screen or not screen:IsA("BasePart") then warn("[BBYA] DJ Wall visibility: PrestigeLED missing") return end

local old=system:FindFirstChild("VisibilityReinforcement")
if old then old:Destroy() end
local rig=Instance.new("Model")
rig.Name="VisibilityReinforcement"
rig:SetAttribute("Pass","DJ_WALL_VISIBILITY_V2")
rig.Parent=system

local PINK=Color3.fromRGB(255,38,155)
local CYAN=Color3.fromRGB(0,210,238)
local GOLD=Color3.fromRGB(238,190,94)
local WHITE=Color3.fromRGB(245,243,248)
local DARK=Color3.fromRGB(7,6,10)

-- Safe position: close to the architectural rear wall, behind the DJ booth/avatar.
-- Original stage LED tiles sit around Z=46.75, so this remains readable without entering the booth zone.
screen.CFrame=CFrame.new(3,10,46.34)
screen.Size=Vector3.new(57.2,12.8,.10)
screen.Color=Color3.fromRGB(13,5,18)
screen.Material=Enum.Material.SmoothPlastic
screen.Transparency=0
screen.Reflectance=.01
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

-- Bezel stays nearly flush to the rear wall so it cannot hide player heads/cameras.
part("BackPlate",Vector3.new(59.0,14.1,.10),CFrame.new(3,10,46.58),Color3.fromRGB(4,4,7),Enum.Material.Metal,0)
part("TopBezel",Vector3.new(59.0,.34,.12),CFrame.new(3,16.58,46.22),PINK,Enum.Material.Neon,.02)
part("BottomBezel",Vector3.new(59.0,.26,.12),CFrame.new(3,3.42,46.22),CYAN,Enum.Material.Neon,.02)
part("LeftBezel",Vector3.new(.28,13.0,.12),CFrame.new(-25.72,10,46.22),Color3.fromRGB(65,48,67),Enum.Material.Metal,0)
part("RightBezel",Vector3.new(.28,13.0,.12),CFrame.new(31.72,10,46.22),Color3.fromRGB(45,63,70),Enum.Material.Metal,0)
part("LeftGlow",Vector3.new(.055,10.8,.06),CFrame.new(-25.88,10,46.14),PINK,Enum.Material.Neon,.14)
part("RightGlow",Vector3.new(.055,10.8,.06),CFrame.new(31.88,10,46.14),CYAN,Enum.Material.Neon,.14)

local topGlow=part("TopGlowSource",Vector3.new(42,.06,.06),CFrame.new(3,16.35,46.12),PINK,Enum.Material.Neon,.15)
local light=Instance.new("PointLight");light.Color=PINK;light.Brightness=.28;light.Range=15;light.Shadows=false;light.Parent=topGlow

-- Force the live SurfaceGui to read clearly in the dark venue.
local gui=screen:FindFirstChild("DJWallUI")
if gui and gui:IsA("SurfaceGui") then
 gui.Enabled=true;gui.Face=Enum.NormalId.Front;gui.AlwaysOnTop=true;gui.LightInfluence=0
 gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=48
 pcall(function() gui.MaxDistance=300 end)
 local oldMirror=screen:FindFirstChild("DJWallUI_OppositeFace")
 if oldMirror then oldMirror:Destroy() end
 local mirror=gui:Clone();mirror.Name="DJWallUI_OppositeFace";mirror.Face=Enum.NormalId.Back;mirror.AlwaysOnTop=true;mirror.LightInfluence=0;mirror.Parent=screen
end

local header=part("HeaderPlate",Vector3.new(20,.70,.10),CFrame.new(3,17.00,46.20),DARK,Enum.Material.SmoothPlastic,0)
local headerGui=Instance.new("SurfaceGui");headerGui.Name="HeaderUI";headerGui.Face=Enum.NormalId.Front;headerGui.AlwaysOnTop=true;headerGui.LightInfluence=0;headerGui.PixelsPerStud=55;headerGui.Parent=header
local headerText=Instance.new("TextLabel");headerText.Size=UDim2.fromScale(1,1);headerText.BackgroundTransparency=1;headerText.Text="BBYA  //  LIVE WALL";headerText.Font=Enum.Font.GothamBlack;headerText.TextScaled=true;headerText.TextColor3=WHITE;headerText.Parent=headerGui
local hs=Instance.new("UIStroke");hs.Color=GOLD;hs.Thickness=1.2;hs.Transparency=.18;hs.Parent=headerText

print("[BBYA] DJ Wall visibility v2 online: wall-safe position + dual-face UI")
