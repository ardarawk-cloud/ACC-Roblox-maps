-- BBYA SOCIAL HUB — DJ REQUEST COMPACT UI PATCH v1
-- Keeps the DJ request panel compact on mobile/landscape without affecting other feature panels.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")

local function findTitle(frame)
    for _,obj in ipairs(frame:GetChildren()) do
        if obj:IsA("TextLabel") and obj.Text=="REQUEST TO DJ" then
            return obj
        end
    end
    return nil
end

local function patchPanel(frame)
    if not frame:IsA("Frame") or frame:GetAttribute("BBYADJCompact") then return end
    if not findTitle(frame) then return end
    frame:SetAttribute("BBYADJCompact",true)

    -- Roughly 15–18% narrower than the generic modal while keeping touch targets comfortable.
    frame.Size=UDim2.new(.68,0,0,388)
    local limit=frame:FindFirstChildOfClass("UISizeConstraint")
    if limit then
        limit.MinSize=Vector2.new(276,300)
        limit.MaxSize=Vector2.new(360,410)
    end

    -- Tighten title/subtitle block a little.
    for _,obj in ipairs(frame:GetChildren()) do
        if obj:IsA("TextLabel") then
            if obj.Text=="REQUEST TO DJ" then
                obj.Position=UDim2.fromOffset(16,13)
                obj.Size=UDim2.new(1,-64,0,24)
                obj.TextSize=17
            elseif string.find(obj.Text,"Request masuk antrean",1,true) then
                obj.Position=UDim2.fromOffset(16,39)
                obj.Size=UDim2.new(1,-32,0,38)
                obj.TextSize=10
            end
        elseif obj:IsA("TextButton") and obj.Text=="×" then
            obj.Position=UDim2.new(1,-43,0,10)
            obj.Size=UDim2.fromOffset(31,31)
        end
    end

    -- Find playlist scroller and compact rows/gaps.
    for _,obj in ipairs(frame:GetChildren()) do
        if obj:IsA("ScrollingFrame") then
            obj.Position=UDim2.fromOffset(16,84)
            obj.Size=UDim2.new(1,-32,1,-98)
            obj.ScrollBarThickness=2
            local layout=obj:FindFirstChildOfClass("UIListLayout")
            if layout then layout.Padding=UDim.new(0,6) end
            for _,row in ipairs(obj:GetChildren()) do
                if row:IsA("TextButton") then
                    row.Size=UDim2.new(1,-3,0,38)
                    row.TextSize=12
                end
            end
            obj.ChildAdded:Connect(function(row)
                if row:IsA("TextButton") then
                    row.Size=UDim2.new(1,-3,0,38)
                    row.TextSize=12
                elseif row:IsA("UIListLayout") then
                    row.Padding=UDim.new(0,6)
                end
            end)
        end
    end
end

local function watchFeatureGui(gui)
    if not gui:IsA("ScreenGui") or gui.Name~="BBYAFloor1FeaturesUI" then return end
    for _,child in ipairs(gui:GetChildren()) do patchPanel(child) end
    gui.ChildAdded:Connect(function(child)
        task.defer(function() patchPanel(child) end)
    end)
end

for _,gui in ipairs(playerGui:GetChildren()) do watchFeatureGui(gui) end
playerGui.ChildAdded:Connect(function(gui)
    task.defer(function() watchFeatureGui(gui) end)
end)

print("[BBYA] DJ request compact UI patch online")
