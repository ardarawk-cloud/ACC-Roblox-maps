-- BBYA SOCIAL HUB — SKATEPARK EXPOSURE FIX v2
-- Keeps the park bright and readable without washing the floor/avatar to pure white.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local park=root:WaitForChild("RearSkatepark",30)
if not park then return end

-- Wait for both lighting passes to finish building before tuning them.
local upgrade=park:WaitForChild("SkateparkUpgradeV2",30)
local stadium=park:WaitForChild("SkateparkStadiumLightingV1",30)
if not upgrade or not stadium then return end

task.wait(.65)

local SOFT_WHITE=Color3.fromRGB(238,241,238)
local WARM_WHITE=Color3.fromRGB(248,238,218)

local fence=upgrade:FindFirstChild("FenceRoadLights")
if fence then
 for _,obj in ipairs(fence:GetDescendants()) do
  if obj:IsA("SpotLight") and obj.Name=="RoadWash" then
   obj.Color=SOFT_WHITE
   obj.Brightness=3.0
   obj.Range=48
   obj.Angle=84
   obj.Shadows=false
  elseif obj:IsA("PointLight") and obj.Name=="FloodFill" then
   obj.Color=WARM_WHITE
   obj.Brightness=.55
   obj.Range=25
   obj.Shadows=false
  elseif obj:IsA("BasePart") and obj.Name:match("Lens$") then
   obj.Color=WARM_WHITE
   obj.Transparency=.18
  end
 end
end

for _,obj in ipairs(stadium:GetDescendants()) do
 if obj:IsA("SpotLight") and obj.Name=="StadiumFlood" then
  obj.Color=SOFT_WHITE
  obj.Brightness=4.0
  obj.Range=62
  obj.Angle=92
  obj.Shadows=false
 elseif obj:IsA("PointLight") and obj.Name=="TowerFill" then
  obj.Color=WARM_WHITE
  obj.Brightness=.45
  obj.Range=28
  obj.Shadows=false
 elseif obj:IsA("PointLight") and obj.Name=="AmbientWash" then
  obj.Color=SOFT_WHITE
  obj.Brightness=.32
  obj.Range=22
  obj.Shadows=false
 elseif obj:IsA("BasePart") and obj.Name:match("Lens%d+$") then
  obj.Color=WARM_WHITE
  obj.Transparency=.20
 end
end

stadium:SetAttribute("Profile","BALANCED_BRIGHT_V2")
park:SetAttribute("LightingBrightnessProfile","BALANCED_BRIGHT_V2")
park:SetAttribute("ExposureFix","NO_WHITEOUT_V2")

print("[BBYA] Skatepark exposure v2 online: bright coverage without whiteout")
