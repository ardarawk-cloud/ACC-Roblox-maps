-- AFTER SCHOOL CITY — V1.3.8 Sports Visual Correction
-- Runtime-evidence correction after LIVE v61.
-- Fixes only the screenshot-proven defects:
-- 1) restore the imported basketball chain-link fence pieces V1.3.7 hid,
-- 2) remove the old gray native sports obstruction/fence layer,
-- 3) remove the giant prototype Bleachers block that reads as a gray wall,
-- 4) rotate the legacy skate/sports benches 180 degrees so they face the activity area.
-- Basketball hoops, imported court geometry, skate ramps, economy, BAG/data, music,
-- quests, dedication, gameplay and monetization remain unchanged.

local Workspace = game:GetService("Workspace")

local VERSION = "1.3.8-sports-visual-correction-1"

local function waitUntil(predicate, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 60)
    repeat
        local ok, value = pcall(predicate)
        if ok and value then
            return value
        end
        task.wait(0.1)
    until os.clock() >= deadline
    return nil
end

local root = Workspace:WaitForChild("AfterSchoolCity", 30)
if not root then
    warn("[ASC V138] AfterSchoolCity root missing")
    return
end

if root:GetAttribute("ASC_RuntimeCorrectionV138") == VERSION then
    return
end

waitUntil(function()
    return root:GetAttribute("ASC_RuntimeCleanupV137") ~= nil
end, 60)

local districts = root:FindFirstChild("Districts")
local sports = districts and districts:FindFirstChild("SportsField")
local skate = districts and districts:FindFirstChild("SkatePark")
local sportsLayer = root:FindFirstChild("V136_SportsAssets")
local basketLayer = sportsLayer and sportsLayer:FindFirstChild("BasketballImportedCourt")

-- Restore only the imported basketball fence/barrier pieces that V1.3.7 made invisible.
-- The imported court already has its own entrance, so V1.3.8 does not cut a second gate.
local restoredBasketFenceParts = 0
if basketLayer then
    for _, obj in ipairs(basketLayer:GetDescendants()) do
        if obj:IsA("BasePart") and obj:GetAttribute("ASC_V137_GatePieceHidden") == true then
            obj.Transparency = 0
            obj.CanCollide = true
            obj.CanTouch = false
            obj.CanQuery = true
            obj:SetAttribute("ASC_V138_RestoredBasketFence", true)
            restoredBasketFenceParts += 1
        end
    end
end

-- Remove the old native gray sports obstruction. The imported basketball asset is now
-- the visible court/fence authority, so the prototype Bleachers block and V03 fence are redundant.
local removedBleachers = false
local removedLegacyFenceParts = 0
if sports then
    local bleachers = sports:FindFirstChild("Bleachers")
    if bleachers and bleachers:IsA("BasePart") then
        bleachers:Destroy()
        removedBleachers = true
    end

    local sportsLife = sports:FindFirstChild("V03_SportsLife")
    if sportsLife then
        for _, obj in ipairs(sportsLife:GetChildren()) do
            if obj:IsA("BasePart") and (
                obj.Name == "FenceNorth"
                or obj.Name == "FenceSouth"
                or obj.Name == "FenceRailNorth"
                or obj.Name == "FenceRailSouth"
            ) then
                obj:Destroy()
                removedLegacyFenceParts += 1
            end
        end
    end
end

local function flipBenchGroups(container)
    if not container then
        return 0
    end

    local seats = {}
    for _, obj in ipairs(container:GetChildren()) do
        if obj:IsA("BasePart") and obj.Name == "BenchSeat" then
            table.insert(seats, obj)
        end
    end

    local flipped = 0
    for _, seat in ipairs(seats) do
        if seat:GetAttribute("ASC_V138_BenchFacingFixed") ~= true then
            local pivot = seat.Position
            local rotate = CFrame.new(pivot) * CFrame.Angles(0, math.rad(180), 0) * CFrame.new(-pivot)
            local members = {}

            for _, obj in ipairs(container:GetChildren()) do
                if obj:IsA("BasePart") and (
                    obj.Name == "BenchSeat"
                    or obj.Name == "BenchBack"
                    or obj.Name == "BenchLegL"
                    or obj.Name == "BenchLegR"
                ) then
                    local dx = obj.Position.X - seat.Position.X
                    local dz = obj.Position.Z - seat.Position.Z
                    if math.sqrt(dx * dx + dz * dz) <= 5.5 then
                        table.insert(members, obj)
                    end
                end
            end

            for _, obj in ipairs(members) do
                obj.CFrame = rotate * obj.CFrame
                obj:SetAttribute("ASC_V138_BenchFacingFixed", true)
            end

            if #members >= 2 then
                flipped += 1
            end
        end
    end

    return flipped
end

-- Both legacy activity benches were authored with their backs toward the activity area.
local flippedSkateBenches = 0
local flippedSportsBenches = 0
if skate then
    flippedSkateBenches = flipBenchGroups(skate:FindFirstChild("V03_SkateLife"))
end
if sports then
    flippedSportsBenches = flipBenchGroups(sports:FindFirstChild("V03_SportsLife"))
end

root:SetAttribute("ASC_RuntimeCorrectionV138", VERSION)
root:SetAttribute("ASC_V138_RestoredBasketFenceParts", restoredBasketFenceParts)
root:SetAttribute("ASC_V138_RemovedPrototypeBleachers", removedBleachers)
root:SetAttribute("ASC_V138_RemovedLegacySportsFenceParts", removedLegacyFenceParts)
root:SetAttribute("ASC_V138_FlippedSkateBenches", flippedSkateBenches)
root:SetAttribute("ASC_V138_FlippedSportsBenches", flippedSportsBenches)
Workspace:SetAttribute("ASC_RuntimeCorrectionV138", VERSION)

print(string.format(
    "[AFTER SCHOOL CITY] V1.3.8 sports visual correction complete; restoredBasketFence=%d removedBleachers=%s removedLegacyFence=%d flippedSkateBenches=%d flippedSportsBenches=%d",
    restoredBasketFenceParts,
    tostring(removedBleachers),
    removedLegacyFenceParts,
    flippedSkateBenches,
    flippedSportsBenches
))