-- BBYA SOCIAL HUB — UI CLARITY PATCH v1
-- Moves the animated music visualizer into the upper-right header space and
-- replaces generic TRAVEL "GO" buttons with the destination names themselves.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local camera=workspace.CurrentCamera
local pg=player:WaitForChild("PlayerGui")

local ui=pg:WaitForChild("BBYAClubUI",20)
if not ui then return end
local panel=ui:WaitForChild("HubPanel",10)
if not panel then return end

local function findHeader()
    for _,obj in ipairs(panel:GetChildren()) do
        if obj:IsA("Frame") then
            for _,child in ipairs(obj:GetChildren()) do
                if child:IsA("TextButton") and child.Text=="×" then
                    return obj
                end
            end
        end
    end
end

local function findVisualizer(playerCard)
    if not playerCard then return nil end
    for _,obj in ipairs(playerCard:GetChildren()) do
        if obj:IsA("Frame") then
            local barCount=0
            for _,child in ipairs(obj:GetChildren()) do
                if child:IsA("Frame") then barCount+=1 end
            end
            if barCount>=12 then return obj end
        end
    end
end

local header
local playerCard
local visualizer
local deadline=os.clock()+10
repeat
    header=findHeader()
    playerCard=panel:FindFirstChild("PlayerCard",true)
    visualizer=findVisualizer(playerCard)
    if header and visualizer then break end
    task.wait(.1)
until os.clock()>deadline

local function styleVisualizer()
    if not header or not visualizer or not visualizer.Parent then return end
    visualizer.Name="LiveWaveVisualizer"
    visualizer.Parent=header
    visualizer.AnchorPoint=Vector2.new(0,0)
    visualizer.Position=UDim2.new(.47,0,0,1)
    visualizer.Size=UDim2.new(.405,-10,0,52)
    visualizer.BackgroundColor3=Color3.fromRGB(8,10,14)
    visualizer.BackgroundTransparency=.02
    visualizer.ClipsDescendants=true
    visualizer.ZIndex=4

    local oldTag=visualizer:FindFirstChild("LiveWaveTag")
    if not oldTag then
        local tag=Instance.new("TextLabel")
        tag.Name="LiveWaveTag"
        tag.BackgroundTransparency=1
        tag.Position=UDim2.fromOffset(9,3)
        tag.Size=UDim2.new(1,-18,0,12)
        tag.Text="LIVE WAVE  •  SYNCED FEED"
        tag.TextColor3=Color3.fromRGB(68,225,244)
        tag.Font=Enum.Font.GothamBold
        tag.TextSize=8
        tag.TextXAlignment=Enum.TextXAlignment.Left
        tag.ZIndex=7
        tag.Parent=visualizer
    end

    local index=0
    for _,bar in ipairs(visualizer:GetChildren()) do
        if bar:IsA("Frame") and bar.Name~="LiveWaveTag" then
            index+=1
            bar.ZIndex=6
            bar.BackgroundColor3=(index%3==0) and Color3.fromRGB(54,225,247) or Color3.fromRGB(255,63,167)
            local grad=bar:FindFirstChild("WaveGradient")
            if not grad then
                grad=Instance.new("UIGradient")
                grad.Name="WaveGradient"
                grad.Rotation=90
                grad.Parent=bar
            end
            if index%3==0 then
                grad.Color=ColorSequence.new(Color3.fromRGB(31,174,225),Color3.fromRGB(150,247,255))
            else
                grad.Color=ColorSequence.new(Color3.fromRGB(205,32,134),Color3.fromRGB(255,134,208))
            end
            local glow=bar:FindFirstChild("WaveStroke")
            if not glow then
                glow=Instance.new("UIStroke")
                glow.Name="WaveStroke"
                glow.Thickness=1
                glow.Transparency=.18
                glow.Parent=bar
            end
            glow.Color=bar.BackgroundColor3
        end
    end

    -- Keep the visualizer usable on genuinely narrow layouts.
    visualizer.Visible=header.AbsoluteSize.X>=560
end

if header and visualizer then
    styleVisualizer()
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        task.defer(styleVisualizer)
    end)
end

-- Travel: the destination itself is the button. No more repeated "GO" labels.
local destinationNames={
    [1]="ARRIVAL",
    [2]="PHOTO STUDIO",
    [3]="LOOK LAB",
    [4]="MAIN CLUB",
    [5]="VIP LEVEL",
    [6]="ROOFTOP",
}

local function patchTravel()
    for i,name in ipairs(destinationNames) do
        local card=panel:FindFirstChild("Destination"..i,true)
        if card then
            for _,child in ipairs(card:GetChildren()) do
                if child:IsA("TextLabel") then
                    child.Visible=false
                elseif child:IsA("TextButton") then
                    child.Text=name
                    child.TextWrapped=true
                    child.TextSize=15
                    child.Font=Enum.Font.GothamBold
                    child.Position=UDim2.fromOffset(20,11)
                    child.Size=UDim2.new(1,-32,1,-22)
                    child.BackgroundColor3=Color3.fromRGB(30,27,35)
                end
            end
        end
    end
end

task.wait(.35)
patchTravel()
print("[BBYA] UI clarity patch online: header Live Wave + destination-first Travel cards")
