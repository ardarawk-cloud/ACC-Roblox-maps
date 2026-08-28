local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local premium = playerGui:WaitForChild("WonderPocketPremiumUI",20)
if not premium then return end

local dexPanel = premium:WaitForChild("DexPanel",10)
local dexContent = dexPanel and dexPanel:FindFirstChild("Content")
if not dexContent then return end

for _,child in ipairs(dexContent:GetChildren()) do
    if child:IsA("TextLabel") and (child.Text == "Loading WonderDex..." or child.Text:find("COLLECTION PROGRESS",1,true)) then
        child.Name = "LegacyDexText"
        child.Visible = false
    end
end

local old = dexContent:FindFirstChild("WonderDexVisualRoot")
if old then old:Destroy() end

local root = Instance.new("Frame")
root.Name = "WonderDexVisualRoot"
root.Size = UDim2.fromScale(1,1)
root.BackgroundTransparency = 1
root.Parent = dexContent

local summary = Instance.new("TextLabel")
summary.Name = "Summary"
summary.Size = UDim2.new(1,0,0,28)
summary.BackgroundTransparency = 1
summary.Font = Enum.Font.GothamSemibold
summary.TextSize = 13
summary.TextColor3 = Color3.fromRGB(48,58,96)
summary.TextXAlignment = Enum.TextXAlignment.Left
summary.Text = "COLLECTION • Loading..."
summary.Parent = root

local tabs = Instance.new("Frame")
tabs.Name = "Tabs"
tabs.Position = UDim2.fromOffset(0,30)
tabs.Size = UDim2.new(1,0,0,34)
tabs.BackgroundTransparency = 1
tabs.Parent = root

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0,4)
tabLayout.Parent = tabs

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "CollectionGrid"
scroll.Position = UDim2.fromOffset(0,70)
scroll.Size = UDim2.new(1,0,1,-70)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.CanvasSize = UDim2.fromOffset(0,0)
scroll.Parent = root

local grid = Instance.new("UIGridLayout")
grid.CellPadding = UDim2.fromOffset(6,6)
grid.CellSize = UDim2.new(.333,-4,0,92)
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
grid.VerticalAlignment = Enum.VerticalAlignment.Top
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = scroll

grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.fromOffset(0,grid.AbsoluteContentSize.Y + 4)
end)

local categories = {
    Wondies = {
        label="WONDI", title="Wondies",
        items={{"Bubbi","Bubbi"},{"Flamo","Flamo"},{"Mossy","Mossy"},{"Lumi","Lumi"},{"Zappy","Zappy"},{"Puffy","Puffy"}},
    },
    Plants = {
        label="PLANT", title="Plants",
        items={{"Carrot","Carrot"},{"Strawberry","Strawberry"},{"Sunflower","Sunflower"}},
    },
    Furniture = {
        label="DECOR", title="Furniture",
        items={{"CloudBed","Cloud Bed"},{"StarLamp","Star Lamp"},{"RainbowSofa","Rainbow Sofa"},{"BunnyChair","Bunny Chair"},{"ToyChest","Toy Chest"},{"MiniAquarium","Mini Aquarium"}},
    },
    Badges = {
        label="BADGE", title="Badges",
        items={{"TreasureIsland","Treasure Island"}},
    },
    Biomes = {
        label="WORLD", title="Worlds",
        items={{"MeadowPocket","Meadow Pocket"},{"BeachIsland","Beach Island"},{"SnowWorld","Snow World"},{"CandyWorld","Candy World"},{"SpaceWorld","Space World"}},
    },
}

local categoryOrder = {"Wondies","Plants","Furniture","Badges","Biomes"}
local activeCategory = "Wondies"
local snapshot
local tabButtons = {}

local function corner(parent,radius)
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,radius)
    c.Parent=parent
end

local function makePart(parent,size,pos,color,shape,transparency)
    local p=Instance.new("Part")
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=false
    p.Size=size
    p.CFrame=CFrame.new(pos)
    p.Color=color
    p.Material=Enum.Material.SmoothPlastic
    p.Transparency=transparency or 0
    if shape then p.Shape=shape end
    p.Parent=parent
    return p
end

local function makeBlock(parent,size,pos,color)
    return makePart(parent,size,pos,color,Enum.PartType.Block)
end

local function makeBall(parent,size,pos,color)
    return makePart(parent,size,pos,color,Enum.PartType.Ball)
end

local function buildWondi(world,id)
    local colors={
        Bubbi=Color3.fromRGB(99,235,166), Flamo=Color3.fromRGB(255,120,94), Mossy=Color3.fromRGB(95,180,104),
        Lumi=Color3.fromRGB(255,226,112), Zappy=Color3.fromRGB(174,123,255), Puffy=Color3.fromRGB(154,215,255),
    }
    local color=colors[id] or Color3.fromRGB(150,200,200)
    makeBall(world,Vector3.new(1.55,1.55,1.55),Vector3.new(0,1.0,0),color)
    makeBlock(world,Vector3.new(.34,.72,.34),Vector3.new(-.45,1.95,0),color)
    makeBlock(world,Vector3.new(.34,.72,.34),Vector3.new(.45,1.95,0),color)
    makeBall(world,Vector3.new(.18,.18,.18),Vector3.new(-.28,1.16,.72),Color3.fromRGB(35,45,60))
    makeBall(world,Vector3.new(.18,.18,.18),Vector3.new(.28,1.16,.72),Color3.fromRGB(35,45,60))
    if id=="Zappy" then makeBlock(world,Vector3.new(.16,.52,.16),Vector3.new(0,2.22,0),Color3.fromRGB(255,225,70)) end
    if id=="Mossy" then makeBall(world,Vector3.new(.42,.24,.42),Vector3.new(0,2.2,0),Color3.fromRGB(70,145,74)) end
end

local function buildPlant(world,id)
    if id=="Carrot" then
        makeBlock(world,Vector3.new(.7,1.35,.7),Vector3.new(0,.7,0),Color3.fromRGB(255,142,62))
        makeBlock(world,Vector3.new(.18,.75,.18),Vector3.new(-.2,1.7,0),Color3.fromRGB(72,178,91))
        makeBlock(world,Vector3.new(.18,.85,.18),Vector3.new(.1,1.75,0),Color3.fromRGB(72,178,91))
        makeBlock(world,Vector3.new(.18,.7,.18),Vector3.new(.32,1.62,0),Color3.fromRGB(72,178,91))
    elseif id=="Strawberry" then
        makeBall(world,Vector3.new(1.25,1.25,1.25),Vector3.new(0,.8,0),Color3.fromRGB(238,77,85))
        makeBlock(world,Vector3.new(.8,.18,.8),Vector3.new(0,1.5,0),Color3.fromRGB(72,178,91))
        makeBlock(world,Vector3.new(.16,.7,.16),Vector3.new(0,1.8,0),Color3.fromRGB(72,178,91))
    else
        makeBlock(world,Vector3.new(.18,1.7,.18),Vector3.new(0,.85,0),Color3.fromRGB(72,178,91))
        makeBall(world,Vector3.new(.58,.58,.58),Vector3.new(0,1.85,0),Color3.fromRGB(105,70,40))
        for i=0,7 do
            local a=math.rad(i*45)
            makeBall(world,Vector3.new(.42,.42,.26),Vector3.new(math.cos(a)*.52,1.85+math.sin(a)*.52,.02),Color3.fromRGB(255,211,66))
        end
    end
end

local function buildFurniture(world,id)
    if id=="StarLamp" then
        makeBlock(world,Vector3.new(.7,.18,.7),Vector3.new(0,.1,0),Color3.fromRGB(90,104,130))
        makeBlock(world,Vector3.new(.18,1.5,.18),Vector3.new(0,.9,0),Color3.fromRGB(110,120,145))
        local glow=makeBall(world,Vector3.new(.95,.95,.95),Vector3.new(0,1.85,0),Color3.fromRGB(255,224,92))
        glow.Material=Enum.Material.Neon
    elseif id=="BunnyChair" then
        makeBlock(world,Vector3.new(1.45,.28,1.25),Vector3.new(0,.7,0),Color3.fromRGB(245,211,228))
        makeBlock(world,Vector3.new(1.45,1.25,.25),Vector3.new(0,1.35,-.48),Color3.fromRGB(245,211,228))
        makeBlock(world,Vector3.new(.28,.8,.28),Vector3.new(-.42,2.25,-.48),Color3.fromRGB(245,211,228))
        makeBlock(world,Vector3.new(.28,.8,.28),Vector3.new(.42,2.25,-.48),Color3.fromRGB(245,211,228))
    elseif id=="ToyChest" then
        makeBlock(world,Vector3.new(1.9,1.0,1.15),Vector3.new(0,.55,0),Color3.fromRGB(186,120,70))
        makeBlock(world,Vector3.new(2.0,.28,1.22),Vector3.new(0,1.18,0),Color3.fromRGB(120,74,48))
        makeBlock(world,Vector3.new(.22,.28,.08),Vector3.new(0,.72,.61),Color3.fromRGB(255,213,82))
    elseif id=="CloudBed" then
        makeBlock(world,Vector3.new(2.2,.38,1.55),Vector3.new(0,.5,0),Color3.fromRGB(205,225,255))
        makeBlock(world,Vector3.new(2.0,.16,1.4),Vector3.new(0,.78,0),Color3.fromRGB(250,250,255))
        makeBall(world,Vector3.new(.9,.9,.55),Vector3.new(-.65,1.35,-.58),Color3.fromRGB(245,248,255))
        makeBall(world,Vector3.new(1.05,1.05,.55),Vector3.new(0,1.48,-.58),Color3.fromRGB(245,248,255))
        makeBall(world,Vector3.new(.9,.9,.55),Vector3.new(.68,1.34,-.58),Color3.fromRGB(245,248,255))
    elseif id=="RainbowSofa" then
        makeBlock(world,Vector3.new(2.25,.55,1.0),Vector3.new(0,.55,0),Color3.fromRGB(255,158,181))
        makeBlock(world,Vector3.new(2.25,1.0,.28),Vector3.new(0,1.2,-.38),Color3.fromRGB(152,185,255))
        makeBlock(world,Vector3.new(.65,.16,.88),Vector3.new(-.72,.92,0),Color3.fromRGB(255,222,104))
        makeBlock(world,Vector3.new(.65,.16,.88),Vector3.new(0,.92,0),Color3.fromRGB(122,220,174))
        makeBlock(world,Vector3.new(.65,.16,.88),Vector3.new(.72,.92,0),Color3.fromRGB(180,145,255))
    else
        local glass=makeBlock(world,Vector3.new(2.0,1.35,.9),Vector3.new(0,1.0,0),Color3.fromRGB(190,235,255))
        glass.Transparency=.35
        local water=makeBlock(world,Vector3.new(1.78,.9,.72),Vector3.new(0,.92,0),Color3.fromRGB(86,190,235))
        water.Transparency=.22
        makeBall(world,Vector3.new(.3,.22,.16),Vector3.new(.28,1.0,.42),Color3.fromRGB(255,154,69))
        makeBlock(world,Vector3.new(2.15,.18,1.0),Vector3.new(0,.24,0),Color3.fromRGB(72,85,105))
    end
end

local function buildBadge(world)
    local disc=makePart(world,Vector3.new(.45,1.75,1.75),Vector3.new(0,1.1,0),Color3.fromRGB(255,200,66),Enum.PartType.Cylinder)
    disc.CFrame=CFrame.new(0,1.1,0)*CFrame.Angles(0,math.rad(90),0)
    makeBall(world,Vector3.new(.62,.62,.3),Vector3.new(0,1.1,.82),Color3.fromRGB(255,241,150))
end

local function buildBiome(world,id)
    local baseColor=Color3.fromRGB(106,190,100)
    if id=="BeachIsland" then baseColor=Color3.fromRGB(238,211,142)
    elseif id=="SnowWorld" then baseColor=Color3.fromRGB(225,242,255)
    elseif id=="CandyWorld" then baseColor=Color3.fromRGB(255,174,215)
    elseif id=="SpaceWorld" then baseColor=Color3.fromRGB(65,58,110) end
    makeBlock(world,Vector3.new(2.7,.35,2.2),Vector3.new(0,.2,0),baseColor)
    if id=="MeadowPocket" then
        makeBlock(world,Vector3.new(.28,1.25,.28),Vector3.new(0,.9,0),Color3.fromRGB(126,84,55))
        makeBall(world,Vector3.new(1.1,1.1,1.1),Vector3.new(0,1.75,0),Color3.fromRGB(78,164,82))
    elseif id=="BeachIsland" then
        makeBlock(world,Vector3.new(.22,1.45,.22),Vector3.new(.2,.95,0),Color3.fromRGB(130,88,57))
        makeBall(world,Vector3.new(1.0,.5,1.0),Vector3.new(.2,1.75,0),Color3.fromRGB(72,175,99))
        makeBlock(world,Vector3.new(2.7,.12,.55),Vector3.new(0,.4,.82),Color3.fromRGB(80,191,232))
    elseif id=="SnowWorld" then
        makeBlock(world,Vector3.new(.25,1.05,.25),Vector3.new(0,.85,0),Color3.fromRGB(110,90,72))
        makeBall(world,Vector3.new(1.15,1.15,1.15),Vector3.new(0,1.65,0),Color3.fromRGB(245,250,255))
    elseif id=="CandyWorld" then
        makeBlock(world,Vector3.new(.32,1.55,.32),Vector3.new(0,1.0,0),Color3.fromRGB(255,245,245))
        makeBall(world,Vector3.new(1.0,1.0,.4),Vector3.new(0,1.9,0),Color3.fromRGB(255,92,156))
    else
        makeBall(world,Vector3.new(1.35,1.35,1.35),Vector3.new(0,1.25,0),Color3.fromRGB(143,100,225))
        makeBall(world,Vector3.new(.28,.28,.28),Vector3.new(.42,1.5,.58),Color3.fromRGB(215,185,255))
    end
end

local function buildPreview(viewport,category,id,found)
    local world=Instance.new("WorldModel")
    world.Parent=viewport
    if category=="Wondies" then buildWondi(world,id)
    elseif category=="Plants" then buildPlant(world,id)
    elseif category=="Furniture" then buildFurniture(world,id)
    elseif category=="Badges" then buildBadge(world)
    elseif category=="Biomes" then buildBiome(world,id) end

    if not found then
        for _,obj in ipairs(world:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Color=Color3.fromRGB(105,112,128)
                obj.Material=Enum.Material.SmoothPlastic
                obj.Transparency=math.max(obj.Transparency,.08)
            end
        end
    end

    local camera=Instance.new("Camera")
    camera.FieldOfView=36
    camera.CFrame=CFrame.lookAt(Vector3.new(4.1,3.1,5.2),Vector3.new(0,1.05,0))
    camera.Parent=viewport
    viewport.CurrentCamera=camera
end

local function clearCards()
    for _,child in ipairs(scroll:GetChildren()) do
        if child~=grid then child:Destroy() end
    end
end

local function render()
    clearCards()
    local meta=categories[activeCategory]
    local data=snapshot and snapshot[activeCategory]
    local foundCount=data and tonumber(data.found) or 0
    local total=data and tonumber(data.total) or #meta.items
    summary.Text=string.format("%s  •  %d / %d discovered",string.upper(meta.title),foundCount,total)

    for index,item in ipairs(meta.items) do
        local id,name=item[1],item[2]
        local found=data and type(data.ids)=="table" and data.ids[id]==true or false

        local card=Instance.new("Frame")
        card.Name=id
        card.LayoutOrder=index
        card.BackgroundColor3=found and Color3.fromRGB(237,245,255) or Color3.fromRGB(226,229,237)
        card.Parent=scroll
        corner(card,13)

        local viewport=Instance.new("ViewportFrame")
        viewport.Name="Preview"
        viewport.Position=UDim2.fromOffset(5,5)
        viewport.Size=UDim2.new(1,-10,1,-29)
        viewport.BackgroundColor3=found and Color3.fromRGB(221,238,255) or Color3.fromRGB(207,211,222)
        viewport.BorderSizePixel=0
        viewport.Ambient=Color3.fromRGB(175,180,195)
        viewport.LightColor=Color3.fromRGB(255,255,255)
        viewport.LightDirection=Vector3.new(-1,-1,-1)
        viewport.Parent=card
        corner(viewport,10)
        buildPreview(viewport,activeCategory,id,found)

        local nameLabel=Instance.new("TextLabel")
        nameLabel.AnchorPoint=Vector2.new(.5,1)
        nameLabel.Position=UDim2.new(.5,0,1,-3)
        nameLabel.Size=UDim2.new(1,-8,0,20)
        nameLabel.BackgroundTransparency=1
        nameLabel.Font=Enum.Font.GothamSemibold
        nameLabel.TextSize=10
        nameLabel.TextColor3=found and Color3.fromRGB(47,58,96) or Color3.fromRGB(104,108,124)
        nameLabel.TextTruncate=Enum.TextTruncate.AtEnd
        nameLabel.Text=found and name or "LOCKED"
        nameLabel.Parent=card
    end
end

local function syncTabs()
    for key,button in pairs(tabButtons) do
        local active=key==activeCategory
        button.BackgroundColor3=active and Color3.fromRGB(72,100,176) or Color3.fromRGB(232,236,247)
        button.TextColor3=active and Color3.new(1,1,1) or Color3.fromRGB(65,72,105)
    end
end

for _,key in ipairs(categoryOrder) do
    local meta=categories[key]
    local b=Instance.new("TextButton")
    b.Name=key
    b.Size=UDim2.new(.19,0,0,30)
    b.BackgroundColor3=Color3.fromRGB(232,236,247)
    b.TextColor3=Color3.fromRGB(65,72,105)
    b.Text=meta.label
    b.Font=Enum.Font.GothamBold
    b.TextSize=9
    b.Parent=tabs
    corner(b,10)
    tabButtons[key]=b
    b.Activated:Connect(function()
        activeCategory=key
        syncTabs()
        render()
    end)
end
syncTabs()
render()

local remotes=ReplicatedStorage:WaitForChild("WONDERPOCKET_Remotes",12)
local dexRemote=remotes and remotes:FindFirstChild("WonderDex")
if dexRemote then
    dexRemote.OnClientEvent:Connect(function(action,a,b,c)
        if action=="SNAPSHOT" and type(a)=="table" then
            snapshot=a
            render()
        elseif action=="DISCOVERED" and type(c)=="table" then
            snapshot=c
            render()
        end
    end)
    dexPanel:GetPropertyChangedSignal("Visible"):Connect(function()
        if dexPanel.Visible then dexRemote:FireServer("GET") end
    end)
    if dexPanel.Visible then dexRemote:FireServer("GET") end
end

local function resize()
    local width=dexContent.AbsoluteSize.X
    local height=dexContent.AbsoluteSize.Y
    if width>0 and width<340 then
        grid.CellSize=UDim2.new(.333,-4,0,78)
        summary.TextSize=11
        for _,button in pairs(tabButtons) do button.TextSize=8 end
    else
        grid.CellSize=UDim2.new(.333,-4,0,92)
        summary.TextSize=13
        for _,button in pairs(tabButtons) do button.TextSize=9 end
    end
    if height>0 and height<250 then
        scroll.Position=UDim2.fromOffset(0,62)
        scroll.Size=UDim2.new(1,0,1,-62)
        tabs.Position=UDim2.fromOffset(0,27)
    else
        scroll.Position=UDim2.fromOffset(0,70)
        scroll.Size=UDim2.new(1,0,1,-70)
        tabs.Position=UDim2.fromOffset(0,30)
    end
end

dexContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
task.defer(resize)

print("[WONDERPOCKET] Visual 3D WonderDex cards ready")
