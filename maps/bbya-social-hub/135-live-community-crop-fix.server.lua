-- BBYA SOCIAL HUB — LIVE COMMUNITY BOARD CROP FIX v1
-- Narrow runtime correction for the entrance Live Community board only.
-- Keeps v6 board size; shifts the board 0.45 stud inward so the outer/left visual edge is not clipped.

local Workspace=game:GetService("Workspace")

local SHIFT_X=-0.45

local function apply()
    local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
    local dashboard=root and root:FindFirstChild("SupportDashboard")
    local holder=dashboard and dashboard:FindFirstChild("LiveCommunityWall")
    if not holder or not holder:IsA("Model") then return false end
    if holder:GetAttribute("BBYALiveCommunityCropFixV1")==true then return true end

    holder:PivotTo(CFrame.new(SHIFT_X,0,0)*holder:GetPivot())
    holder:SetAttribute("BBYALiveCommunityCropFixV1",true)
    return true
end

task.spawn(function()
    for _=1,80 do
        if apply() then return end
        task.wait(0.1)
    end
end)

local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
if root then
    root.ChildAdded:Connect(function(child)
        if child.Name=="SupportDashboard" then
            task.delay(0.15,apply)
        end
    end)
end

print("[BBYA] Live Community board crop fix v1 armed")
