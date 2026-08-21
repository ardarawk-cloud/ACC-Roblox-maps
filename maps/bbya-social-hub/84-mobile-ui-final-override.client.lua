-- BBYA SOCIAL HUB — MOBILE UI FINAL OVERRIDE v1
-- Final mobile-safe placement pass. Runs after all other UI scripts so DANCE/CARRY
-- cannot be enlarged/repositioned again by legacy layout code.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera

local function round(obj,r)
    local c=obj:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,r)
    c.Parent=obj
end

local function styleSocial()
    local gui=pg:FindFirstChild("BBYASocialHangoutUI")
    if not gui then return end

    local dance,carry
    for _,obj in ipairs(gui:GetChildren()) do
        if obj:IsA("TextButton") then
            local t=string.upper(obj.Text or "")
            if t=="DANCE" then dance=obj elseif t=="CARRY" then carry=obj end
        end
    end
    if not dance or not carry then return end

    local vp=(camera and camera.ViewportSize) or Vector2.new(1280,720)
    local size=42
    local left=3
    local lower=math.clamp(math.floor(vp.Y*.22),150,184)

    -- User-requested vertical stack, pushed hard against the left edge.
    dance.AnchorPoint=Vector2.new(0,1)
    carry.AnchorPoint=Vector2.new(0,1)
    dance.Size=UDim2.fromOffset(size,size)
    carry.Size=UDim2.fromOffset(size,size)
    dance.Position=UDim2.new(0,left,1,-lower-size-6)
    carry.Position=UDim2.new(0,left,1,-lower)
    dance.TextSize=8
    carry.TextSize=8
    dance.ZIndex=70
    carry.ZIndex=70
    round(dance,10);round(carry,10)

    -- Compact drawers: wide enough for a thumb list, never a half-screen modal.
    local panelW=math.clamp(math.floor(vp.X*.38),246,300)
    local panelH=math.clamp(math.floor(vp.Y*.43),220,286)
    for _,name in ipairs({"DancePanel","CarryPanel"}) do
        local p=gui:FindFirstChild(name)
        if p and p:IsA("Frame") then
            p.AnchorPoint=Vector2.new(0,1)
            p.Size=UDim2.fromOffset(panelW,panelH)
            p.Position=UDim2.new(0,left,1,-lower-size-12)
            p.ClipsDescendants=true
            p.ZIndex=60
            round(p,12)
        end
    end
end

local function compactTravel()
    local gui=pg:FindFirstChild("BBYAClubUI")
    if not gui then return end
    local panel=gui:FindFirstChild("HubPanel")
    if not panel or not panel:IsA("Frame") then return end
    local vp=(camera and camera.ViewportSize) or Vector2.new(1280,720)
    if vp.X>=900 then return end

    -- Make the unified panel genuinely phone-sized instead of a desktop panel scaled down.
    local w=math.clamp(math.floor(vp.X*.76),430,620)
    local h=math.clamp(math.floor(vp.Y*.70),310,430)
    panel.AnchorPoint=Vector2.new(.5,.5)
    panel.Position=UDim2.fromScale(.5,.52)
    panel.Size=UDim2.fromOffset(w,h)

    local content=panel:FindFirstChildWhichIsA("Frame",true)
    local travelScroller=panel:FindFirstChild("TravelDestinationScroller",true)
    if travelScroller and travelScroller:IsA("ScrollingFrame") then
        travelScroller.ScrollBarThickness=2
        local grid=travelScroller:FindFirstChildOfClass("UIGridLayout")
        if grid then
            grid.CellPadding=UDim2.fromOffset(6,6)
            local cols=2
            local available=math.max(300,travelScroller.AbsoluteSize.X)
            local cellW=math.floor((available-6)/cols)
            grid.CellSize=UDim2.fromOffset(cellW,76)
        end
    end
end

local function compactGearBackpack()
    -- Roblox Backpack buttons are CoreGui-controlled; do not fight CoreGui layout.
    -- Keep this hook intentionally empty so club tools remain usable without a custom
    -- permanent overlay competing with DANCE/CARRY.
end

local function apply()
    pcall(styleSocial)
    pcall(compactTravel)
    pcall(compactGearBackpack)
end

apply()
pg.ChildAdded:Connect(function()task.defer(apply)end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    camera=workspace.CurrentCamera
    task.defer(apply)
end)

task.spawn(function()
    -- Re-assert after late UI injections/legacy patches finish their own startup pass.
    for _=1,40 do
        task.wait(.35)
        apply()
    end
end)

print("[BBYA] Mobile UI final override online: vertical left-edge DANCE/CARRY + compact panels")
