-- BBYA SOCIAL HUB — DJ WALL FINAL MOUNT v1
-- Single-purpose final geometry pass. It does NOT rebuild message logic or monetization.
-- It moves the already-built DJWallUI + prompt onto one physical panel mounted to the rear portal.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",20)
if not root then return end
local system=root:WaitForChild("DJWallMessageSystem",20)
if not system then warn("[BBYA] Final DJ wall: message system missing") return end

-- Let the message UI / typography / random visual scripts finish decorating first.
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

-- Clean only old presentation geometry. Message system itself stays intact.
local oldFinal=system:FindFirstChild("FinalMountedWall")
if oldFinal then oldFinal:Destroy() end
local oldReinforcement=system:FindFirstChild("VisibilityReinforcement")
if oldReinforcement then oldReinforcement:Destroy() end

local final=Instance.new("Model")
final.Name="FinalMountedWall"
final:SetAttribute("Pass","DJ_WALL_FINAL_MOUNT_V1")
final.Parent=system

local C={
 black=Color3.fromRGB(3,3,6),
 screen=Color3.fromRGB(14,5,20),
 metal=Color3.fromRGB(48,45,54),
 pink=Color3.fromRGB(255,38,155),
 cyan=Color3.fromRGB(0,210,238),
 gold=Color3.fromRGB(238,190,94),
}

local function part(name,size,cf,color,material,transparency,parent)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=size
 p.CFrame=cf
 p.Color=color or C.metal
 p.Material=material or Enum.Material.Metal
 p.Transparency=transparency or 0
 p.Anchored=true
 p.CanCollide=false
 p.CanTouch=false
 p.CanQuery=false
 p.CastShadow=false
 p.TopSurface=Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or final
 return p
end

-- Stage audience is at lower Z. PortalBack is centered around Z=48 with a front face near Z=47.5.
-- Keep the entire wall within ~0.35 stud of that architectural face.
local mount=part("MountPlate",Vector3.new(58.0,13.25,.10),CFrame.new(3,10,47.44),C.black,Enum.Material.Metal,0)
local screen=part("PrestigeLED",Vector3.new(56.9,12.35,.12),CFrame.new(3,10,47.30),C.screen,Enum.Material.Neon,0)
screen.CanQuery=true
screen.Reflectance=0

-- Thin real bezel so the screen remains visually obvious even before UI finishes rendering.
part("TopBezel",Vector3.new(57.4,.24,.14),CFrame.new(3,16.28,47.20),C.pink,Enum.Material.Neon,.02)
part("BottomBezel",Vector3.new(57.4,.20,.14),CFrame.new(3,3.72,47.20),C.cyan,Enum.Material.Neon,.02)
part("LeftBezel",Vector3.new(.22,12.3,.14),CFrame.new(-25.58,10,47.20),C.metal,Enum.Material.Metal,0)
part("RightBezel",Vector3.new(.22,12.3,.14),CFrame.new(31.58,10,47.20),C.metal,Enum.Material.Metal,0)

-- Small physical header; this guarantees players can identify the wall even if a visual mode is dark.
local header=part("Header",Vector3.new(18,.72,.12),CFrame.new(3,16.78,47.20),C.black,Enum.Material.SmoothPlastic,0)
local hg=Instance.new("SurfaceGui")
hg.Name="HeaderUI"
hg.Face=Enum.NormalId.Front
hg.AlwaysOnTop=false
hg.LightInfluence=0
hg.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
hg.PixelsPerStud=55
hg.Parent=header
local ht=Instance.new("TextLabel")
ht.Size=UDim2.fromScale(1,1)
ht.BackgroundTransparency=1
ht.Text="BBYA  //  LIVE WALL"
ht.TextColor3=Color3.fromRGB(245,243,248)
ht.Font=Enum.Font.GothamBlack
ht.TextScaled=true
ht.Parent=hg
local hs=Instance.new("UIStroke")
hs.Color=C.gold
hs.Thickness=1.2
hs.Transparency=.20
hs.Parent=ht

-- Move the live UI object rather than cloning the logic. Existing Lua references remain valid.
gui.Parent=screen
gui.Adornee=screen
gui.Enabled=true
gui.Face=Enum.NormalId.Front
gui.AlwaysOnTop=false
gui.LightInfluence=0
gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
gui.PixelsPerStud=50
pcall(function() gui.MaxDistance=350 end)

-- Remove stale opposite-face clone and recreate it from the final decorated UI.
local staleMirror=legacy:FindFirstChild("DJWallUI_OppositeFace") or screen:FindFirstChild("DJWallUI_OppositeFace")
if staleMirror then staleMirror:Destroy() end
local mirror=gui:Clone()
mirror.Name="DJWallUI_OppositeFace"
mirror.Adornee=screen
mirror.Face=Enum.NormalId.Back
mirror.AlwaysOnTop=false
mirror.LightInfluence=0
mirror.Parent=screen

-- Preserve the existing paid-message proximity prompt by moving it to the final panel.
for _,child in ipairs(legacy:GetChildren()) do
 if child:IsA("ProximityPrompt") then
  child.Parent=screen
 end
end

-- Remove only the obsolete physical part after live UI/prompt have been transferred.
legacy.Name="LegacyPrestigeLED"
legacy:Destroy()

print("[BBYA] DJ Wall FINAL MOUNT online: physical neon panel + live UI attached to rear portal")
