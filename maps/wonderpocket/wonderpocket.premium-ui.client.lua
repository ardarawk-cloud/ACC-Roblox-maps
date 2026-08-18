local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("WonderPocketPremiumUI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "WonderPocketPremiumUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local function corner(parent,radius)
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,radius or 16)
    c.Parent=parent
    return c
end

local function stroke(parent,thickness,transparency)
    local s=Instance.new("UIStroke")
    s.Thickness=thickness or 1
    s.Transparency=transparency or .7
    s.Parent=parent
    return s
end

local function maxSize(parent,x,y)
    local c=Instance.new("UISizeConstraint")
    c.MaxSize=Vector2.new(x,y)
    c.Parent=parent
    return c
end

local toast=Instance.new("TextLabel")
toast.AnchorPoint=Vector2.new(.5,0)
toast.Position=UDim2.new(.5,0,0,66)
toast.Size=UDim2.new(1,-28,0,44)
toast.BackgroundColor3=Color3.fromRGB(35,45,85)
toast.BackgroundTransparency=.05
toast.TextColor3=Color3.new(1,1,1)
toast.Font=Enum.Font.GothamSemibold
toast.TextSize=14
toast.TextWrapped=true
toast.Visible=false
toast.Parent=gui
maxSize(toast,360,44)
corner(toast,14)

local toastToken=0
local function showToast(text)
    toastToken+=1
    local token=toastToken
    toast.Text=tostring(text)
    toast.Visible=true
    toast.TextTransparency=1
    toast.BackgroundTransparency=1
    TweenService:Create(toast,TweenInfo.new(.15),{TextTransparency=0,BackgroundTransparency=.05}):Play()
    task.delay(2.4,function()
        if token~=toastToken or not toast.Parent then return end
        local tween=TweenService:Create(toast,TweenInfo.new(.2),{TextTransparency=1,BackgroundTransparency=1})
        tween:Play()
        tween.Completed:Wait()
        if token==toastToken and toast.Parent then toast.Visible=false end
    end)
end

local dock=Instance.new("Frame")
dock.Name="BottomDock"
dock.AnchorPoint=Vector2.new(.5,1)
dock.Position=UDim2.new(.5,0,1,-12)
dock.Size=UDim2.new(1,-20,0,60)
dock.BackgroundColor3=Color3.fromRGB(25,31,65)
dock.BackgroundTransparency=.08
dock.Parent=gui
maxSize(dock,390,60)
corner(dock,20)
stroke(dock,1.5,.55)

local dockLayout=Instance.new("UIListLayout")
dockLayout.FillDirection=Enum.FillDirection.Horizontal
dockLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
dockLayout.VerticalAlignment=Enum.VerticalAlignment.Center
dockLayout.Padding=UDim.new(0,6)
dockLayout.Parent=dock

local panels={}
local panelContents={}
local activePanel

local function makePanel(name,title)
    local panel=Instance.new("Frame")
    panel.Name=name
    panel.AnchorPoint=Vector2.new(.5,.5)
    panel.Position=UDim2.fromScale(.5,.49)
    panel.Size=UDim2.new(1,-24,1,-150)
    panel.BackgroundColor3=Color3.fromRGB(248,250,255)
    panel.Visible=false
    panel.Parent=gui
    local limit=maxSize(panel,420,430)
    limit.MinSize=Vector2.new(300,320)
    corner(panel,22)
    stroke(panel,2,.8)

    local header=Instance.new("TextLabel")
    header.Name="Header"
    header.Size=UDim2.new(1,-76,0,56)
    header.Position=UDim2.fromOffset(20,8)
    header.BackgroundTransparency=1
    header.Font=Enum.Font.GothamBold
    header.Text=title
    header.TextColor3=Color3.fromRGB(35,44,85)
    header.TextSize=23
    header.TextXAlignment=Enum.TextXAlignment.Left
    header.Parent=panel

    local close=Instance.new("TextButton")
    close.Name="Close"
    close.Size=UDim2.fromOffset(40,40)
    close.Position=UDim2.new(1,-50,0,12)
    close.BackgroundColor3=Color3.fromRGB(235,238,248)
    close.Text="×"
    close.TextSize=26
    close.Font=Enum.Font.GothamBold
    close.TextColor3=Color3.fromRGB(65,70,100)
    close.Parent=panel
    corner(close,13)

    local content=Instance.new("Frame")
    content.Name="Content"
    content.Position=UDim2.fromOffset(16,68)
    content.Size=UDim2.new(1,-32,1,-84)
    content.BackgroundTransparency=1
    content.Parent=panel

    close.Activated:Connect(function()
        panel.Visible=false
        activePanel=nil
    end)

    panels[name]=panel
    panelContents[name]=content
    return panel,content
end

local shopPanel,shopContent=makePanel("ShopPanel","Wonder Shop")
local dexPanel,dexContent=makePanel("DexPanel","WonderDex")
local buildPanel,buildContent=makePanel("BuildPanel","Decorate My Pocket")
local socialPanel,socialContent=makePanel("SocialPanel","Friends & Gifts")

local catalog={
    {"Star Lamp",125,"StarLamp"},{"Bunny Chair",180,"BunnyChair"},{"Toy Chest",220,"ToyChest"},
    {"Cloud Bed",325,"CloudBed"},{"Rainbow Sofa",450,"RainbowSofa"},{"Mini Aquarium",550,"MiniAquarium"},
}

local remotes=ReplicatedStorage:WaitForChild("WONDERPOCKET_Remotes",12)
local shopRemote=remotes and remotes:FindFirstChild("Shop")
local socialRemote=remotes and remotes:FindFirstChild("Social")
local dexRemote=remotes and remotes:FindFirstChild("WonderDex")
local buildBus=playerGui:WaitForChild("WP_BuildCommand",10)

local shopGrid=Instance.new("UIGridLayout")
shopGrid.CellPadding=UDim2.fromOffset(8,8)
shopGrid.CellSize=UDim2.new(.5,-4,0,82)
shopGrid.HorizontalAlignment=Enum.HorizontalAlignment.Center
shopGrid.VerticalAlignment=Enum.VerticalAlignment.Top
shopGrid.Parent=shopContent

for _,item in ipairs(catalog) do
    local b=Instance.new("TextButton")
    b.BackgroundColor3=Color3.fromRGB(235,244,255)
    b.Text=item[1].."\n"..item[2].." Coins"
    b.TextColor3=Color3.fromRGB(40,55,100)
    b.TextSize=15
    b.TextWrapped=true
    b.Font=Enum.Font.GothamSemibold
    b.Parent=shopContent
    corner(b,14)
    b.Activated:Connect(function()
        if not shopRemote then showToast("Shop is still loading") return end
        shopRemote:FireServer("BUY",item[3])
    end)
end

local dexText=Instance.new("TextLabel")
dexText.Size=UDim2.fromScale(1,1)
dexText.BackgroundTransparency=1
dexText.TextXAlignment=Enum.TextXAlignment.Left
dexText.TextYAlignment=Enum.TextYAlignment.Top
dexText.Font=Enum.Font.GothamMedium
dexText.TextSize=16
dexText.TextColor3=Color3.fromRGB(50,60,95)
dexText.TextWrapped=true
dexText.Text="Loading WonderDex..."
dexText.Parent=dexContent

local function updateDex(snapshot)
    if type(snapshot)~="table" then return end
    local order={"Wondies","Plants","Furniture","Badges","Biomes"}
    local lines={"COLLECTION PROGRESS"}
    for _,category in ipairs(order) do
        local data=snapshot[category]
        if type(data)=="table" then
            table.insert(lines,string.format("%s   %s / %s",string.upper(category),tostring(data.found or 0),tostring(data.total or 0)))
        end
    end
    table.insert(lines,"")
    table.insert(lines,"Discover items by playing. Unlocks are verified by the server.")
    dexText.Text=table.concat(lines,"\n")
end

if dexRemote then
    dexRemote.OnClientEvent:Connect(function(action,a,b,c)
        if action=="SNAPSHOT" then updateDex(a)
        elseif action=="DISCOVERED" then
            showToast("WonderDex discovered: "..tostring(b or "item"))
            updateDex(c)
        elseif action=="NOTICE" then showToast(tostring(a or "WonderDex notice")) end
    end)
end

local buildHint=Instance.new("TextLabel")
buildHint.Size=UDim2.new(1,0,0,48)
buildHint.BackgroundTransparency=1
buildHint.TextWrapped=true
buildHint.Font=Enum.Font.GothamMedium
buildHint.TextSize=14
buildHint.TextColor3=Color3.fromRGB(55,62,95)
buildHint.Text="Choose owned furniture. Cyan preview = valid. Red = outside your Pocket plot."
buildHint.Parent=buildContent

local buildItemsFrame=Instance.new("Frame")
buildItemsFrame.Position=UDim2.fromOffset(0,58)
buildItemsFrame.Size=UDim2.new(1,0,1,-58)
buildItemsFrame.BackgroundTransparency=1
buildItemsFrame.Parent=buildContent

local buildGrid=Instance.new("UIGridLayout")
buildGrid.CellPadding=UDim2.fromOffset(7,7)
buildGrid.CellSize=UDim2.new(.333,-5,0,48)
buildGrid.HorizontalAlignment=Enum.HorizontalAlignment.Center
buildGrid.VerticalAlignment=Enum.VerticalAlignment.Top
buildGrid.Parent=buildItemsFrame

local buildButtons={}
local function ownedCount(id)
    return math.max(0,math.floor(tonumber(player:GetAttribute("WP_INV_"..id)) or 0))
end
local function refreshBuildButton(id)
    local data=buildButtons[id]
    if not data then return end
    local count=ownedCount(id)
    data.button.Text=data.name.."\nx"..count
    data.button.BackgroundColor3=count>0 and Color3.fromRGB(232,242,255) or Color3.fromRGB(225,226,232)
    data.button.TextColor3=count>0 and Color3.fromRGB(45,60,100) or Color3.fromRGB(125,128,145)
end

for _,item in ipairs(catalog) do
    local name,id=item[1],item[3]
    local b=Instance.new("TextButton")
    b.TextSize=12
    b.TextWrapped=true
    b.Font=Enum.Font.GothamSemibold
    b.Parent=buildItemsFrame
    corner(b,12)
    buildButtons[id]={button=b,name=name}
    b.Activated:Connect(function()
        if ownedCount(id)<=0 then showToast("You don't own "..name.." yet. Buy it in SHOP.") return end
        if buildBus then
            buildBus:Fire("BEGIN",id)
            buildPanel.Visible=false
            activePanel=nil
        else
            showToast("Build controls are still loading")
        end
    end)
    player:GetAttributeChangedSignal("WP_INV_"..id):Connect(function() refreshBuildButton(id) end)
    refreshBuildButton(id)
end

local controls=Instance.new("Frame")
controls.AnchorPoint=Vector2.new(.5,1)
controls.Position=UDim2.new(.5,0,1,-80)
controls.Size=UDim2.new(1,-24,0,54)
controls.BackgroundTransparency=1
controls.Parent=gui
controls.Visible=false
maxSize(controls,360,54)

local ctlLayout=Instance.new("UIListLayout")
ctlLayout.FillDirection=Enum.FillDirection.Horizontal
ctlLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
ctlLayout.Padding=UDim.new(0,7)
ctlLayout.Parent=controls

local function controlButton(text,color,action)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(.31,0,0,50)
    b.BackgroundColor3=color
    b.Text=text
    b.TextColor3=Color3.new(1,1,1)
    b.Font=Enum.Font.GothamBold
    b.TextSize=14
    b.Parent=controls
    corner(b,15)
    b.Activated:Connect(function() if buildBus then buildBus:Fire(action) end end)
end
controlButton("ROTATE",Color3.fromRGB(86,104,180),"ROTATE")
controlButton("PLACE",Color3.fromRGB(54,164,112),"PLACE")
controlButton("CANCEL",Color3.fromRGB(190,78,92),"CANCEL")

local function syncBuildControls()
    controls.Visible=player:GetAttribute("WP_BuildActive")==true
end
player:GetAttributeChangedSignal("WP_BuildActive"):Connect(syncBuildControls)
syncBuildControls()

local socialText=Instance.new("TextLabel")
socialText.Size=UDim2.new(1,0,0,86)
socialText.BackgroundTransparency=1
socialText.TextWrapped=true
socialText.Font=Enum.Font.GothamMedium
socialText.TextSize=15
socialText.TextColor3=Color3.fromRGB(55,62,95)
socialText.Text="Visit friends in this server or send a Surprise. Gifts are cosmetic social moments only."
socialText.Parent=socialContent

local giftFrame=Instance.new("Frame")
giftFrame.Position=UDim2.fromOffset(0,96)
giftFrame.Size=UDim2.new(1,0,1,-96)
giftFrame.BackgroundTransparency=1
giftFrame.Parent=socialContent
local giftGrid=Instance.new("UIGridLayout")
giftGrid.CellPadding=UDim2.fromOffset(8,8)
giftGrid.CellSize=UDim2.new(.5,-4,0,50)
giftGrid.Parent=giftFrame

for _,name in ipairs({"Balloon","IceCream","Flower","Fireworks"}) do
    local b=Instance.new("TextButton")
    b.BackgroundColor3=Color3.fromRGB(240,232,255)
    b.Text=name
    b.Font=Enum.Font.GothamSemibold
    b.TextColor3=Color3.fromRGB(65,52,100)
    b.TextSize=15
    b.Parent=giftFrame
    corner(b,14)
    b.Activated:Connect(function()
        if socialRemote then socialRemote:FireServer("GIFT_NEAREST",name) else showToast("Social is still loading") end
    end)
end

local dockEntries={{"SHOP","ShopPanel"},{"DEX","DexPanel"},{"BUILD","BuildPanel"},{"SOCIAL","SocialPanel"}}
for _,entry in ipairs(dockEntries) do
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(.23,0,0,44)
    b.BackgroundColor3=Color3.fromRGB(54,78,150)
    b.TextColor3=Color3.new(1,1,1)
    b.Text=entry[1]
    b.Font=Enum.Font.GothamBold
    b.TextSize=13
    b.Parent=dock
    corner(b,14)
    b.Activated:Connect(function()
        local panel=panels[entry[2]]
        if activePanel and activePanel~=panel then activePanel.Visible=false end
        panel.Visible=not panel.Visible
        activePanel=panel.Visible and panel or nil
        if panel.Visible then
            panel.BackgroundTransparency=.16
            TweenService:Create(panel,TweenInfo.new(.16),{BackgroundTransparency=0}):Play()
            if entry[2]=="DexPanel" and dexRemote then dexRemote:FireServer("GET") end
        end
    end)
end

if shopRemote then
    shopRemote.OnClientEvent:Connect(function(action,ok,reason,itemId)
        if action~="RESULT" then return end
        if ok then
            local label=tostring(itemId or "item"):gsub("(%l)(%u)","%1 %2")
            showToast(label.." added to your inventory")
        elseif reason=="NOT_ENOUGH_COINS" then showToast("Not enough Coins")
        elseif reason=="DATA_NOT_READY" then showToast("Your Pocket data is still loading")
        elseif reason=="BUSY" or reason=="RATE_LIMITED" then showToast("One moment — processing your last tap")
        else showToast("Purchase failed: "..tostring(reason or "UNKNOWN")) end
    end)
end

player:GetAttributeChangedSignal("WP_LastBuildError"):Connect(function()
    local err=player:GetAttribute("WP_LastBuildError")
    if err and err~="" then
        if err=="BUSY" or err=="RATE_LIMITED" then showToast("One moment — processing placement")
        else showToast("Build: "..tostring(err)) end
    end
end)

print("[WONDERPOCKET] v1.2 responsive premium mobile UI loaded")
