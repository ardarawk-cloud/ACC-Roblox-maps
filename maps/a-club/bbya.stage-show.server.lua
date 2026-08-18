-- BBYA SOCIAL HUB — STAGE SHOW SYSTEM v1.0
-- Crowd-reactive main club show layer. Keeps lobby/rooftop independent.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local ROOT = "BBYA Stage Show v1"
local old = workspace:FindFirstChild(ROOT)
if old then old:Destroy() end
local root = Instance.new("Folder")
root.Name = ROOT
root.Parent = workspace

local C = {
    pink = Color3.fromRGB(255,45,165),
    blue = Color3.fromRGB(30,145,255),
    cyan = Color3.fromRGB(40,235,255),
    purple = Color3.fromRGB(105,55,210),
    gold = Color3.fromRGB(255,190,75),
    dark = Color3.fromRGB(10,10,16),
}

local function part(name,size,cf,color,material,transparency,collide)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=cf
    p.Anchored=true
    p.CanCollide=collide~=false
    p.Material=material or Enum.Material.SmoothPlastic
    p.Color=color or C.dark
    p.Transparency=transparency or 0
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=root
    return p
end

local function neon(name,size,cf,color)
    local p=part(name,size,cf,color,Enum.Material.Neon,0,false)
    local light=Instance.new("PointLight")
    light.Color=color
    light.Brightness=1.6
    light.Range=24
    light.Shadows=false
    light.Parent=p
    return p
end

local function sign(name,text,cf,size,color)
    local b=part(name,size,cf,C.dark,Enum.Material.SmoothPlastic,0,false)
    local gui=Instance.new("SurfaceGui")
    gui.Face=Enum.NormalId.Front
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=32
    gui.LightInfluence=0
    gui.Parent=b
    local t=Instance.new("TextLabel")
    t.Size=UDim2.fromScale(1,1)
    t.BackgroundTransparency=1
    t.Font=Enum.Font.GothamBlack
    t.Text=text
    t.TextScaled=true
    t.TextColor3=color
    t.TextStrokeTransparency=.25
    t.Parent=gui
    return b
end

-- Main dance floor reactive ring
local danceCenter = Vector3.new(0,2,-10)
for i=0,23 do
    local a=(math.pi*2)*(i/24)
    local x=math.cos(a)*42
    local z=math.sin(a)*28
    local p=neon("Dance Ring "..i,Vector3.new(3,.25,.7),CFrame.new(danceCenter+Vector3.new(x,0,z))*CFrame.Angles(0,-a,0),i%2==0 and C.pink or C.blue)
    p:SetAttribute("BBYA_ShowLight",true)
end

-- Stage vertical pixel ribs
for _,x in ipairs({-34,-24,-14,14,24,34}) do
    for y=5,23,3 do
        local p=neon("Stage Pixel "..x.." "..y,Vector3.new(2.2,1.4,.5),CFrame.new(x,y,-54),((x+y)%2==0) and C.cyan or C.pink)
        p:SetAttribute("BBYA_ShowLight",true)
    end
end

sign("Stage Hero Message","BBYA • FEEL THE NIGHT",CFrame.new(0,21,-58),Vector3.new(48,6,.6),C.pink)

-- Crowd zones
local crowdZone = part("Crowd Reactive Zone",Vector3.new(96,10,68),CFrame.new(0,6,-8),Color3.new(1,1,1),Enum.Material.SmoothPlastic,1,false)
local vipZone = part("VIP Reactive Zone",Vector3.new(150,12,30),CFrame.new(0,11,23),Color3.new(1,1,1),Enum.Material.SmoothPlastic,1,false)
local roofCueZone = part("Rooftop Cue Zone",Vector3.new(28,10,22),CFrame.new(52,7,48),Color3.new(1,1,1),Enum.Material.SmoothPlastic,1,false)

local function playersInside(partObj)
    local count=0
    local pos=partObj.Position
    local half=partObj.Size/2
    for _,plr in ipairs(Players:GetPlayers()) do
        local char=plr.Character
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local p=hrp.Position
            if math.abs(p.X-pos.X)<=half.X and math.abs(p.Y-pos.Y)<=half.Y and math.abs(p.Z-pos.Z)<=half.Z then
                count+=1
            end
        end
    end
    return count
end

local showParts={}
for _,o in ipairs(root:GetDescendants()) do
    if o:IsA("BasePart") and o:GetAttribute("BBYA_ShowLight") then
        table.insert(showParts,o)
    end
end

local stageMode="IDLE"
local lastRoofCue=0

local function applyMode(mode,crowdCount,vipCount)
    if stageMode==mode then return end
    stageMode=mode

    local brightness = mode=="HYPE" and 3.8 or (mode=="ACTIVE" and 2.6 or 1.4)
    local pulse = mode=="HYPE" and .14 or (mode=="ACTIVE" and .28 or .7)

    for i,p in ipairs(showParts) do
        local targetColor
        if mode=="HYPE" then
            targetColor = (i%3==0) and C.gold or ((i%2==0) and C.pink or C.cyan)
        elseif mode=="ACTIVE" then
            targetColor = (i%2==0) and C.pink or C.blue
        else
            targetColor = (i%2==0) and C.purple or C.blue
        end
        TweenService:Create(p,TweenInfo.new(.45,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Color=targetColor}):Play()
        local l=p:FindFirstChildOfClass("PointLight")
        if l then
            l.Brightness=brightness
            l.Color=targetColor
        end
    end

    root:SetAttribute("StageMode",mode)
    root:SetAttribute("CrowdCount",crowdCount)
    root:SetAttribute("VIPCount",vipCount)
    root:SetAttribute("PulseSeconds",pulse)
end

-- Soft club bloom owned by this layer only
local bloom=Lighting:FindFirstChild("BBYAStageBloom") or Instance.new("BloomEffect")
bloom.Name="BBYAStageBloom"
bloom.Intensity=.5
bloom.Size=28
bloom.Threshold=1.2
bloom.Parent=Lighting

-- Pulse loop
local beat=false
task.spawn(function()
    while root.Parent do
        local crowd=playersInside(crowdZone)
        local vip=playersInside(vipZone)
        local mode="IDLE"
        if crowd>=8 or (crowd>=5 and vip>=2) then mode="HYPE"
        elseif crowd>=2 then mode="ACTIVE" end
        applyMode(mode,crowd,vip)

        beat=not beat
        for _,p in ipairs(showParts) do
            local l=p:FindFirstChildOfClass("PointLight")
            if l then
                local base=(mode=="HYPE" and 3.8 or (mode=="ACTIVE" and 2.6 or 1.4))
                l.Brightness=beat and base or math.max(.8,base*.55)
            end
        end
        bloom.Intensity = mode=="HYPE" and (beat and .95 or .55) or (mode=="ACTIVE" and .6 or .35)

        local roofCount=playersInside(roofCueZone)
        if roofCount>0 and os.clock()-lastRoofCue>8 then
            lastRoofCue=os.clock()
            for _,p in ipairs(showParts) do
                local l=p:FindFirstChildOfClass("PointLight")
                if l then
                    local original=l.Brightness
                    l.Brightness=original+1.4
                    task.delay(.8,function()
                        if l and l.Parent then l.Brightness=original end
                    end)
                end
            end
            root:SetAttribute("LastRooftopCue",os.time())
        end

        local waitTime = mode=="HYPE" and .16 or (mode=="ACTIVE" and .3 or .75)
        task.wait(waitTime)
    end
end)

print("[BBYA] Stage Show System v1 loaded")
