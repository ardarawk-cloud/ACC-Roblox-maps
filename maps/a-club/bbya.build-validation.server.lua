-- BBYA SOCIAL HUB — BUILD VALIDATION v1.0
-- Lightweight runtime health check for the premium build. No visual side effects.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

task.wait(6)

local checks = {
 {label="Visual Rebuild", instance=workspace:FindFirstChild("BBYA Premium Visual Rebuild v4")},
 {label="Venue Polish", instance=workspace:FindFirstChild("BBYA Premium Venue Polish v4.1")},
 {label="Phase 3", instance=workspace:FindFirstChild("BBYA Premium Phase 3 v4.3")},
 {label="Phase 4", instance=workspace:FindFirstChild("BBYA Premium Phase 4 v4.4")},
 {label="Phase 5", instance=workspace:FindFirstChild("BBYA Premium Phase 5 v4.5")},
 {label="Main Floor", instance=workspace:FindFirstChild("Main Floor",true)},
 {label="Dance Floor", instance=workspace:FindFirstChild("Dance Floor",true)},
 {label="DJ Booth", instance=workspace:FindFirstChild("DJ Booth",true)},
 {label="Left VIP Platform", instance=workspace:FindFirstChild("Left VIP Platform",true)},
 {label="Right VIP Platform", instance=workspace:FindFirstChild("Right VIP Platform",true)},
 {label="Rooftop Floor", instance=workspace:FindFirstChild("Rooftop Floor",true)},
 {label="Rooftop Pool", instance=workspace:FindFirstChild("Rooftop Pool",true)},
 {label="BBYA Remotes", instance=ReplicatedStorage:FindFirstChild("BBYA_Remotes")},
 {label="Monetization Config", instance=ReplicatedStorage:FindFirstChild("BBYA_Monetization")},
}

local missing = {}
for _,check in ipairs(checks) do
 if not check.instance then table.insert(missing,check.label) end
end

local status = #missing == 0 and "PASS" or "WARN"
workspace:SetAttribute("BBYABuildVersion","4.5.1")
workspace:SetAttribute("BBYABuildValidation",status)
workspace:SetAttribute("BBYABuildMissingCount",#missing)
workspace:SetAttribute("BBYABuildCheckedAt",os.time())

if #missing > 0 then
 warn("[BBYA BUILD VALIDATION] Missing: "..table.concat(missing,", "))
else
 print("[BBYA BUILD VALIDATION] PASS • premium build 4.5.1")
end
