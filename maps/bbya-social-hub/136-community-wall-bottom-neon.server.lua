-- BBYA SOCIAL HUB — COMMUNITY WALL BOTTOM NEON VISIBILITY v1
-- Keeps both entrance boards unchanged and lifts only their existing bottom neon trim
-- slightly above the floor line so it stays visible in-game.

local Workspace=game:GetService("Workspace")

local function liftBottomTrim(holder)
    if not holder or not holder:IsA("Model") then return end
    local trim=holder:FindFirstChild("BottomTrim")
    if not trim or not trim:IsA("BasePart") then return end
    if trim:GetAttribute("BBYABottomNeonLiftV1")==true then return end
    trim.CFrame=trim.CFrame*CFrame.new(0,0.28,0)
    trim.Size=Vector3.new(trim.Size.X,math.max(trim.Size.Y,0.12),trim.Size.Z)
    trim:SetAttribute("BBYABottomNeonLiftV1",true)
end

local function apply()
    local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
    local dashboard=root and root:FindFirstChild("SupportDashboard")
    if not dashboard then return false end
    liftBottomTrim(dashboard:FindFirstChild("TopSupportersWall"))
    liftBottomTrim(dashboard:FindFirstChild("LiveCommunityWall"))
    return true
end

task.spawn(function()
    for _=1,100 do
        if apply() then return end
        task.wait(0.1)
    end
end)

local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
if root then
    root.ChildAdded:Connect(function(child)
        if child.Name=="SupportDashboard" then task.delay(0.2,apply) end
    end)
end

print("[BBYA] Community wall bottom neon visibility v1 armed")
