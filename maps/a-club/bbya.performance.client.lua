-- BBYA SOCIAL HUB — ADAPTIVE PERFORMANCE CLIENT v1.0
-- Keeps premium look while trimming only decorative lighting on mobile/small viewports.

local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local camera = Workspace.CurrentCamera
local profile = "DESKTOP"

local function detectProfile()
 local width = camera and camera.ViewportSize.X or 1280
 if UserInputService.TouchEnabled or width < 800 then
  return "MOBILE"
 end
 return "DESKTOP"
end

local processed = setmetatable({}, {__mode="k"})
local decorativeIndex = 0

local function tuneLight(light)
 if processed[light] then return end
 processed[light] = true
 if not (light:IsA("PointLight") or light:IsA("SpotLight") or light:IsA("SurfaceLight")) then return end
 local parent = light.Parent
 if not parent or not parent:GetAttribute("BBYADecorativeLight") then return end
 decorativeIndex += 1
 light.Shadows = false
 if profile == "MOBILE" then
  light.Range = math.min(light.Range, 7)
  light.Brightness = math.min(light.Brightness, .45)
  -- Keep alternating lights so the venue still reads premium on phones.
  if decorativeIndex % 2 == 0 then light.Enabled = false end
 else
  light.Range = math.min(light.Range, 10)
  light.Brightness = math.min(light.Brightness, .75)
  light.Enabled = true
 end
end

local function tunePostFX()
 local bloom = Lighting:FindFirstChild("BBYA_Bloom_v4") or Lighting:FindFirstChild("BBYA_PremiumBloom")
 if bloom and bloom:IsA("BloomEffect") then
  if profile == "MOBILE" then
   bloom.Intensity = math.min(bloom.Intensity,.38)
   bloom.Size = math.min(bloom.Size,22)
  else
   bloom.Intensity = math.max(bloom.Intensity,.5)
  end
 end
 local atmosphere = Lighting:FindFirstChild("BBYA_Atmosphere_v4")
 if atmosphere and atmosphere:IsA("Atmosphere") and profile == "MOBILE" then
  atmosphere.Density = math.min(atmosphere.Density,.16)
  atmosphere.Haze = math.min(atmosphere.Haze,.8)
 end
end

local function apply()
 profile = detectProfile()
 decorativeIndex = 0
 for _,obj in ipairs(Workspace:GetDescendants()) do
  tuneLight(obj)
 end
 tunePostFX()
 Workspace:SetAttribute("BBYAClientPerformanceProfile",profile)
end

apply()
Workspace.DescendantAdded:Connect(function(obj)
 task.defer(function() tuneLight(obj) end)
end)

if camera then
 camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
  local nextProfile = detectProfile()
  if nextProfile ~= profile then
   processed = setmetatable({}, {__mode="k"})
   apply()
  end
 end)
end

print("[BBYA] Adaptive Performance Client v1.0 loaded • "..profile)
