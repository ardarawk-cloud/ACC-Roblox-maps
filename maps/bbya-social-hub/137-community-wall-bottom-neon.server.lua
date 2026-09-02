-- BBYA SOCIAL HUB — COMMUNITY WALL BOTTOM NEON v1
-- Makes the lower neon edge of both entrance community walls clearly visible.
-- Geometry/board size remains unchanged.

local Workspace = game:GetService("Workspace")

local function applyTo(holder)
    if not holder or not holder:IsA("Model") then return false end
    local bottom = holder:FindFirstChild("BottomTrim")
    if not bottom or not bottom:IsA("BasePart") then return false end

    -- The original trim sits almost flush with the floor. Lift it slightly,
    -- thicken it, and pull it forward so the neon reads clearly from outside.
    if bottom:GetAttribute("BBYABottomNeonVisibleV1") ~= true then
        bottom.Size = Vector3.new(bottom.Size.X, 0.18, 0.18)
        bottom.CFrame = bottom.CFrame * CFrame.new(0, 0.18, -0.10)
        bottom.Material = Enum.Material.Neon
        bottom.Transparency = 0
        bottom:SetAttribute("BBYABottomNeonVisibleV1", true)
    end
    return true
end

local function apply()
    local root = Workspace:FindFirstChild("BBYA_ZERO_BUILD")
    local dashboard = root and root:FindFirstChild("SupportDashboard")
    if not dashboard then return false end

    local left = dashboard:FindFirstChild("TopSupportersWall")
    local right = dashboard:FindFirstChild("LiveCommunityWall")
    local a = applyTo(left)
    local b = applyTo(right)
    return a and b
end

task.spawn(function()
    for _ = 1, 100 do
        if apply() then return end
        task.wait(0.1)
    end
end)

local root = Workspace:FindFirstChild("BBYA_ZERO_BUILD")
if root then
    root.ChildAdded:Connect(function(child)
        if child.Name == "SupportDashboard" then
            task.delay(0.2, apply)
        end
    end)
end

print("[BBYA] Community wall bottom neon v1 armed")
