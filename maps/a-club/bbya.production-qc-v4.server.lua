-- BBYA SOCIAL HUB — PRODUCTION QC v4.3
-- Runtime hygiene for premium rebuild: anchor validation, decorative collision cleanup,
-- conservative light budget, and preservation of the active v4 post-processing stack.

local Lighting = game:GetService("Lighting")

task.wait(3)

local required = {
 "Main Floor",
 "Dance Floor",
 "DJ Booth",
 "Left VIP Platform",
 "Right VIP Platform",
 "Rooftop Floor",
 "Rooftop Pool",
}

local missing = {}
for _, name in ipairs(required) do
 if not workspace:FindFirstChild(name, true) then table.insert(missing, name) end
end

-- Remove obsolete visual roots if any delayed legacy script recreated them.
for _, name in ipairs({"BBYA Mega Architecture v2","BBYA Master Plan Completion v3","BBYA Visual v1.2"}) do
 local o = workspace:FindFirstChild(name)
 if o then o:Destroy() end
end

local lightCount = 0
local removedSkyLights = 0
local decorativeCollisionCleared = 0

for _, obj in ipairs(workspace:GetDescendants()) do
 if obj:IsA("BasePart") then
  local n = string.lower(obj.Name)
  if string.find(n,"neon") or string.find(n,"accent") or string.find(n,"logo") or string.find(n,"sign") or string.find(n,"window") or string.find(n,"glow") then
   if obj.CanCollide then
    obj.CanCollide = false
    decorativeCollisionCleared += 1
   end
  end
 end

 if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
  lightCount += 1
  obj.Shadows = false
  if obj.Range > 22 then obj.Range = 22 end
  if obj.Brightness > 2.2 then obj.Brightness = 2.2 end
  local parentName = obj.Parent and string.lower(obj.Parent.Name) or ""
  if string.find(parentName,"sky window") then
   obj:Destroy()
   removedSkyLights += 1
  end
 end
end

-- Preserve the current premium v4 stack. Disable only obsolete duplicate effects.
local allowedBloom = {
 ["BBYA_Bloom_v4"] = true,
 ["BBYA_PremiumBloom"] = true,
}
local allowedColor = {
 ["BBYA_Color_v4"] = true,
 ["BBYA_PremiumColor"] = true,
}
for _, effect in ipairs(Lighting:GetChildren()) do
 if effect:IsA("BloomEffect") and not allowedBloom[effect.Name] then
  effect.Enabled = false
 elseif effect:IsA("ColorCorrectionEffect") and not allowedColor[effect.Name] then
  effect.Enabled = false
 end
end

workspace:SetAttribute("BBYAProductionQC","4.3")
workspace:SetAttribute("BBYAMissingAnchors",#missing)
workspace:SetAttribute("BBYALightCountAfterQC",math.max(0,lightCount-removedSkyLights))

if #missing > 0 then
 warn("[BBYA QC] Missing anchors: "..table.concat(missing,", "))
else
 print("[BBYA QC] Required anchors OK")
end
print(string.format("[BBYA QC] v4.3 loaded — decorative collisions cleared %d, skyline lights removed %d",decorativeCollisionCleared,removedSkyLights))
