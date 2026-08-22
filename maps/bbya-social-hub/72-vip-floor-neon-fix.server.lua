-- BBYA SOCIAL HUB — VIP FLOOR NEON FIX v6
-- Owner lock: BLUE/cyan VIP floor trim must never be deleted or rebuilt here.
-- This pass removes only PINK/magenta neon at VIP floor height.

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

local function removePinkOnly()
    local removed = 0
    for _, obj in ipairs(vip:GetDescendants()) do
        if isPinkFloorNeon(obj) then
            obj:Destroy()
            removed += 1
        end
    end
    return removed
end

-- Run once immediately and again shortly after the VIP builder finishes.
local removed = removePinkOnly()
task.wait(0.35)
removed += removePinkOnly()
task.wait(0.75)
removed += removePinkOnly()

active:SetAttribute("PinkFloorNeonRemoved", true)
active:SetAttribute("BlueFloorTrimPreserved", true)
active:SetAttribute("FloorLightingProfile", "PINK_ONLY_REMOVAL_V6")
active:SetAttribute("PinkRemovedByV6", removed)

print(string.format("[BBYA] VIP floor neon v6: removed %d pink floor parts; BLUE trim untouched", removed))
