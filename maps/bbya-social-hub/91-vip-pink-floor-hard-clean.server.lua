-- BBYA SOCIAL HUB — VIP PINK FLOOR HARD CLEAN v1
-- Final late guard for the VIP screenshot issue: remove the bright magenta floor strip
-- around the central VIP opening. This does NOT touch ceiling lights or the blue guide.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then return end
local upper = root:WaitForChild("UpperLevels", 30)
if not upper then return end
local vip = upper:WaitForChild("L2_VIP_Level", 30)
if not vip then return end
local active = vip:WaitForChild("VIPMinimalStanding", 30)
if not active then return end

local function isPinkFloorNeon(obj)
    if not obj:IsA("BasePart") then return false end
    if obj.Material ~= Enum.Material.Neon then return false end
    local y = obj.Position.Y
    if y < 24.4 or y > 25.6 then return false end

    local c = obj.Color
    -- Covers the BBYA magenta/pink family without matching the cyan/blue guide.
    return c.R > 0.72 and c.G < 0.48 and c.B > 0.35
end

local function clean()
    local removed = 0

    -- The legacy v5 builder owns this duplicate boundary model. The current
    -- precision pass owns the wanted BLUE guide, so delete this model wholesale.
    local oldBoundary = active:FindFirstChild("FloorBoundaryNeon")
    if oldBoundary then
        oldBoundary:Destroy()
        removed += 1
    end

    -- Catch any late-created legacy segments or duplicates by name/color/height.
    for _, obj in ipairs(vip:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name
            local legacyName = n == "OuterNorth" or n == "OuterEast" or n == "InnerSouth" or n == "InnerWest"
            if legacyName or isPinkFloorNeon(obj) then
                obj:Destroy()
                removed += 1
            end
        end
    end

    return removed
end

-- ServerScripts start in parallel, so run after the VIP builders and keep guarding
-- briefly against a late race. This is intentionally scoped only to L2 VIP floor neon.
local total = 0
for _ = 1, 12 do
    task.wait(0.75)
    total += clean()
end

active:SetAttribute("PinkFloorHardClean", true)
active:SetAttribute("PinkFloorHardCleanRemoved", total)
active:SetAttribute("PinkFloorHardCleanScope", "VIP_FLOOR_ONLY")

print(string.format("[BBYA] VIP pink floor hard-clean complete: %d legacy/pink floor objects removed", total))
