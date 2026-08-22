-- BBYA SOCIAL HUB — VIP PINK FLOOR HARD CLEAN v2
-- Late guard: remove only PINK/magenta floor neon in VIP.
-- Never delete FloorBoundaryNeon wholesale and never remove BLUE/cyan trim.

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
    return c.R > 0.72 and c.G < 0.48 and c.B > 0.35
end

local function clean()
    local removed = 0
    for _, obj in ipairs(vip:GetDescendants()) do
        if isPinkFloorNeon(obj) then
            obj:Destroy()
            removed += 1
        end
    end
    return removed
end

local total = 0
for _ = 1, 12 do
    task.wait(0.75)
    total += clean()
end

active:SetAttribute("PinkFloorHardClean", true)
active:SetAttribute("PinkFloorHardCleanRemoved", total)
active:SetAttribute("BlueFloorTrimPreserved", true)
active:SetAttribute("PinkFloorHardCleanScope", "VIP_PINK_FLOOR_ONLY")

print(string.format("[BBYA] VIP pink floor hard-clean v2: %d pink objects removed / blue trim preserved", total))
