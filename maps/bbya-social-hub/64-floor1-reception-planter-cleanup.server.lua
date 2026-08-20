-- BBYA SOCIAL HUB — FLOOR 1 RECEPTION PLANTER CLEANUP v1
-- Removes only the two decorative planter/tree props behind the Floor 1 reception area.
-- Reception desk, signage, transition portal, lighting and all other props remain untouched.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then
    warn("[BBYA] Floor 1 planter cleanup: BBYA_ZERO_BUILD unavailable")
    return
end

local front = root:WaitForChild("Floor1FrontPremium", 30)
if not front then
    warn("[BBYA] Floor 1 planter cleanup: Floor1FrontPremium unavailable")
    return
end

local removed = 0
for _, name in ipairs({"FrontPlanterL", "FrontPlanterR"}) do
    local obj = front:FindFirstChild(name)
    if obj then
        obj:Destroy()
        removed += 1
    end
end

front:SetAttribute("ReceptionRearPlantersRemoved", true)
front:SetAttribute("ReceptionRearPlanterCount", 0)

print(string.format("[BBYA] Floor 1 reception cleanup complete: removed %d rear planters", removed))
