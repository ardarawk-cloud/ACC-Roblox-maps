-- BBYA SOCIAL HUB — DJ WALL FINAL MOUNT v2
-- Single final geometry owner for the rear DJ wall.
-- Preserves message/monetization logic while removing legacy geometry that can occlude the live panel.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",20)
if not root then return end
local system=root:WaitForChild("DJWallMessageSystem",20)
if not system then warn("[BBYA] Final DJ wall: message system missing") return end

-- Let message UI / typography / random visuals finish constructing.
task.wait(2.5)

local legacy=system:FindFirstChild("PrestigeLED",true)
if not legacy or not legacy:IsA("BasePart") then
 warn("[BBYA] Final DJ wall: legacy PrestigeLED missing")
 return
end

local gui=legacy:FindFirstChild("DJWallUI")
if not gui or not gui:IsA("SurfaceGui") then
 warn("[BBYA] Final DJ wall: DJWallUI missing")
 return
end

-- IMPORTANT: MainClubRealism still creates an older tiled LED layer at Z~46.75.
-- That layer sits closer to the audience than the final wall and can physically hide the new SurfaceGui.
-- Remove only those two known presentation objects; portal/stage/booth remain untouched.
local club=root:FindFirstChild("MainClubRealism")
if club then
 for _,obj in ipairs(club:GetDescendants()) do
  if obj.Name=="LEDWall" or obj.Name=="LogoDisplay" then
   obj:Destroy()
  end
 end
end

-- Clean only previous wall presentation geometry.
local oldFinal=system:FindFirstChild("FinalMountedWall")
if oldFinal then oldFinal:Destroy() end
local oldReinforcement=system:FindFirstChild("VisibilityReinforcement")
if oldReinforcement then oldReinforcement:Destroy() end
local oldRecess=system:FindFirstChild("WallRecess")
if oldRecess then oldRecess:Destroy() end
for _,name in ipairs({"TopTrim","BottomTrim"}) do
 local obj=system:FindFirstChild(name)
 if obj then obj:Destroy() end
end

local final=Instance.new("Model")
final.Name="FinalMountedWall"
final:SetAttribute("Pass","DJ_WALL_FINAL_MOUNT_V2")
final.Parent=system

local C={
 black=Color3.fromRGB(3,3,6),
 screen=Color3.fromRGB(14,5,20),
 metal=Color3.fromRGB(48,45,54),
 pink=Color3.fromRGB(255,38,155),
 cyan=Color3.fromRGB(0,210,238),
 gold=Color3.fromRGB(238,190,94),
 white=Color3.fromRGB(245,243,248),
}

local function part(name,size,cf,color,material,transparency,parent)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.metal;p.Material=material or Enum.Material.Metal
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or final
 return p
end

-- Audience is toward lower Z. PortalBack front face is near Z=47.5.
-- Keep all final geometry within a few tenths of that face.
part("MountPlate",Vector3.new(58.0,13.25,.10),CFrame.new(3,10,47.44),C.black,Enum.Material.Metal,0)
local screen=part("PrestigeLED",Vector3.new(56.9,12.35,.12),CFrame.new(3,10,47.30),C.screen,Enum.Material.SmoothPlastic,0)
screen.CanQuery=true
screen.Reflectance=0

part("TopBezel",Vector3.new(57.4,.24,.14),CFrame.new(3,16.28,47.20),C.pink,Enum.Material.Neon,.02)
part("BottomBezel",Vector3.new(57.4,.20,.14),CFrame.new(3,3.72,47.20),C.cyan,Enum.Material.Neon,.02)
part("LeftBezel",Vector3.new(.22,12.3,.14),CFrame.new(-25.58,10,47.20),C.metal,Enum.Material.Metal,0)
part("RightBezel",Vector3.new(.22,12.3,.14),CFrame.new(31.58,10,47.20),C.metal,Enum.Material.Metal,0)

local header=part("Header",Vector3.new(18,.72,.12),CFrame.new(3,16.78,47.20),C.black,Enum.Material.SmoothPlastic,0)
local hg=Instance.new("SurfaceGui")
hg.Name="HeaderUI";hg.Face=Enum.NormalId.Front;hg.AlwaysOnTop=false;hg.LightInfluence=0
hg.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;hg.PixelsPerStud=55;hg.Parent=header
local ht=Instance.new("TextLabel")
ht.Size=UDim2.fromScale(1,1);ht.BackgroundTransparency=1;ht.Text="BBYA  //  LIVE WALL";ht.TextColor3=C.white
ht.Font=Enum.Font.GothamBlack;ht.TextScaled=true;ht.Parent=hg
local hs=Instance.new("UIStroke");hs.Color=C.gold;hs.Thickness=1.2;hs.Transparency=.20;hs.Parent=ht

-- Move the live UI object rather than cloning the message logic.
gui.Parent=screen
gui.Adornee=nil
gui.Enabled=true
gui.Face=Enum.NormalId.Front
gui.AlwaysOnTop=false
gui.LightInfluence=0
gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
gui.PixelsPerStud=50
pcall(function() gui.MaxDistance=350 end)

-- Ensure idle mode is visible immediately whenever no paid message is active.
local idle=gui:FindFirstChild("IdleVisuals",true)
local message=gui:FindFirstChild("MessageMode",true)
if idle and idle:IsA("GuiObject") and (not message or not message.Visible) then
 idle.Visible=true
end

-- Mirror for debugging/viewing from the rear; normal audience sees Front.
local staleMirror=legacy:FindFirstChild("DJWallUI_OppositeFace") or screen:FindFirstChild("DJWallUI_OppositeFace")
if staleMirror then staleMirror:Destroy() end
local mirror=gui:Clone()
mirror.Name="DJWallUI_OppositeFace"
mirror.Adornee=nil
mirror.Face=Enum.NormalId.Back
mirror.AlwaysOnTop=false
mirror.LightInfluence=0
mirror.Parent=screen

-- Preserve paid-message prompt on the final panel.
for _,child in ipairs(legacy:GetChildren()) do
 if child:IsA("ProximityPrompt") then child.Parent=screen end
end

legacy.Name="LegacyPrestigeLED"
legacy:Destroy()

print("[BBYA] DJ Wall FINAL MOUNT v2 online: legacy occluder removed + live UI visible")
