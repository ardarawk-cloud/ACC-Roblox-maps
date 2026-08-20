-- BBYA SOCIAL HUB — DJ BOOTH ORIENTATION FIX v1
-- Keeps audience-facing cubbies in front while turning the actual controls/screens toward the DJ side.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",20)
if not root then return end
local club=root:WaitForChild("MainClubRealism",20)
if not club then return end
local av=club:FindFirstChild("AudioVisual")
if not av then return end
local booth=av:WaitForChild("DJBoothPremium",20)
if not booth then warn("[BBYA] DJ booth orientation: booth missing") return end

booth:SetAttribute("OrientationPass","DJ_SIDE_POSITIVE_Z_V1")

-- 1) Rotate the complete console layout 180 degrees around its own center.
-- This moves screens/buttons/faders to the DJ-facing (+Z) edge without moving the cabinet/cubbies.
local gear=booth:FindFirstChild("DJEquipment")
if gear then
 local pivot=CFrame.new(3,0,31.68)
 local turn=CFrame.Angles(0,math.pi,0)
 for _,obj in ipairs(gear:GetDescendants()) do
  if obj:IsA("BasePart") then
   local relative=pivot:ToObjectSpace(obj.CFrame)
   obj.CFrame=pivot*turn*relative
  end
 end
end

-- 2) Laptop stays on the rear shelf, but its display must face the DJ (+Z), not the dance floor.
local shelf=booth:FindFirstChild("TechShelf")
if shelf then
 local laptop=shelf:FindFirstChild("LaptopScreen")
 if laptop and laptop:IsA("BasePart") then
  laptop.CFrame=CFrame.new(3,10.05,35.05)*CFrame.Angles(math.rad(-9),math.pi,0)
  local gui=laptop:FindFirstChildWhichIsA("SurfaceGui")
  if gui then gui.Face=Enum.NormalId.Front;gui.AlwaysOnTop=false;gui.LightInfluence=0 end
 end
end

-- 3) Studio monitor drivers belong on the DJ-facing (+Z) side of each cabinet.
local function faceMonitor(model)
 if not model then return end
 local cab=model:FindFirstChild("Cabinet")
 if not cab or not cab:IsA("BasePart") then return end
 local x=cab.Position.X
 local woofer=model:FindFirstChild("Woofer")
 if woofer and woofer:IsA("BasePart") then woofer.CFrame=CFrame.new(x,10.05,36.31)*CFrame.Angles(0,0,math.rad(90)) end
 local inner=model:FindFirstChild("WooferInner")
 if inner and inner:IsA("BasePart") then inner.CFrame=CFrame.new(x,10.05,36.42)*CFrame.Angles(0,0,math.rad(90)) end
 local tweeter=model:FindFirstChild("Tweeter")
 if tweeter and tweeter:IsA("BasePart") then tweeter.CFrame=CFrame.new(x,11.52,36.31)*CFrame.Angles(0,0,math.rad(90)) end
 local led=model:FindFirstChild("PowerLED")
 if led and led:IsA("BasePart") then led.CFrame=CFrame.new(x-.95,8.65,36.28) end
end
faceMonitor(booth:FindFirstChild("MonitorLeft"))
faceMonitor(booth:FindFirstChild("MonitorRight"))

-- Guest request interaction remains audience-side by design (Floor1Features at Z~28.6).
print("[BBYA] DJ booth orientation v1 online: cubbies to audience, controls/screens to DJ")
