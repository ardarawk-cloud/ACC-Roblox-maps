-- BBYA SOCIAL HUB — BUILD VALIDATION v1.3
-- Runtime health check for premium build 4.6.1, including playtest harness and legacy-regression guards.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

task.wait(7)

local remotes = ReplicatedStorage:FindFirstChild("BBYA_Remotes")
local checks = {
 {label="Clean Core", instance=workspace:GetAttribute("BBYACleanCore")=="3.0" and workspace or nil},
 {label="Visual Rebuild", instance=workspace:FindFirstChild("BBYA Premium Visual Rebuild v4")},
 {label="Venue Polish", instance=workspace:FindFirstChild("BBYA Premium Venue Polish v4.1")},
 {label="Phase 3", instance=workspace:FindFirstChild("BBYA Premium Phase 3 v4.3")},
 {label="Phase 4", instance=workspace:FindFirstChild("BBYA Premium Phase 4 v4.4")},
 {label="Phase 5", instance=workspace:FindFirstChild("BBYA Premium Phase 5 v4.5")},
 {label="Phase 6", instance=workspace:FindFirstChild("BBYA Premium Phase 6 v4.6")},
 {label="Main Floor", instance=workspace:FindFirstChild("Main Floor",true)},
 {label="Dance Floor", instance=workspace:FindFirstChild("Dance Floor",true)},
 {label="DJ Booth", instance=workspace:FindFirstChild("DJ Booth",true)},
 {label="Left VIP Platform", instance=workspace:FindFirstChild("Left VIP Platform",true)},
 {label="Right VIP Platform", instance=workspace:FindFirstChild("Right VIP Platform",true)},
 {label="Rooftop Floor", instance=workspace:FindFirstChild("Rooftop Floor",true)},
 {label="Rooftop Pool", instance=workspace:FindFirstChild("Rooftop Pool",true)},
 {label="Wayfinding", instance=workspace:GetAttribute("BBYAWayfindingReady")==true and workspace or nil},
 {label="Final Spawn", instance=workspace:GetAttribute("BBYAFinalSpawnReady")==true and workspace or nil},
 {label="BBYA Remotes", instance=remotes},
 {label="Playtest Harness", instance=remotes and remotes:FindFirstChild("RunPlaytestCheck")},
 {label="Monetization Config", instance=ReplicatedStorage:FindFirstChild("BBYA_Monetization")},
}

local missing = {}
for _,check in ipairs(checks) do
 if not check.instance then table.insert(missing,check.label) end
end

local legacy = {}
for _,name in ipairs({
 "BBYA Visual v1.2",
 "BBYA Social Systems",
 "BBYA Arrival Neon Box",
 "BBYA Mega Architecture v2",
 "BBYA Master Plan Completion v3",
}) do
 if workspace:FindFirstChild(name) then table.insert(legacy,name) end
end

local status = (#missing == 0 and #legacy == 0) and "PASS" or "WARN"
workspace:SetAttribute("BBYABuildVersion","4.6.1-playtest")
workspace:SetAttribute("BBYABuildValidation",status)
workspace:SetAttribute("BBYABuildMissingCount",#missing)
workspace:SetAttribute("BBYALegacyRegressionCount",#legacy)
workspace:SetAttribute("BBYABuildCheckedAt",os.time())

if #missing > 0 then warn("[BBYA BUILD VALIDATION] Missing: "..table.concat(missing,", ")) end
if #legacy > 0 then warn("[BBYA BUILD VALIDATION] Legacy regression: "..table.concat(legacy,", ")) end
if status == "PASS" then print("[BBYA BUILD VALIDATION] PASS • premium build 4.6.1 playtest") end
