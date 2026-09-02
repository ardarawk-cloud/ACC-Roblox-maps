local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local FurnitureAssets=require(ReplicatedStorage:WaitForChild("FurnitureAssets"))

local displayToId={}
for _,id in ipairs(FurnitureAssets.Order) do
    displayToId[FurnitureAssets.GetDisplayName(id)]=id
end

local function cameraFor(viewport,model)
    local camera=Instance.new("Camera")
    camera.Name="WP_FurnitureCamera"
    camera.Parent=viewport
    viewport.CurrentCamera=camera
    local _,size=model:GetBoundingBox()
    local m=math.max(size.X,size.Y,size.Z)
    local focus=Vector3.new(0,size.Y*.05,0)
    camera.CFrame=CFrame.lookAt(Vector3.new(m*1.25,m*.8,m*1.45),focus)
end

local function fillViewport(viewport,itemId)
    for _,child in ipairs(viewport:GetChildren()) do
        if child:IsA("WorldModel") or child:IsA("Camera") then child:Destroy() end
    end
    local world=Instance.new("WorldModel")
    world.Name="WP_FurnitureWorld"
    world.Parent=viewport
    local model=FurnitureAssets.Create(itemId)
    if not model then return end
    FurnitureAssets.RestoreAppearance(model)
    model.Parent=world
    model:PivotTo(CFrame.new())
    cameraFor(viewport,model)
end

local function itemIdFromText(text)
    text=tostring(text or "")
    for display,id in pairs(displayToId) do
        if text:sub(1,#display)==display then return id end
    end
    return nil
end

local function decorateButton(button,isShop)
    if not button:IsA("TextButton") or button:GetAttribute("WP_FurnitureDecorated") then return end
    local id=itemIdFromText(button.Text)
    if not id then return end
    button:SetAttribute("WP_FurnitureDecorated",true)

    local viewport=Instance.new("ViewportFrame")
    viewport.Name="FurniturePreview"
    viewport.BackgroundTransparency=1
    viewport.Size=UDim2.new(1,-8,0,isShop and 62 or 34)
    viewport.Position=UDim2.fromOffset(4,2)
    viewport.Parent=button
    fillViewport(viewport,id)

    button.TextYAlignment=Enum.TextYAlignment.Bottom
    if isShop then
        button.TextSize=13
    else
        button.TextSize=10
    end
end

local function decoratePremiumUi()
    local premium=playerGui:FindFirstChild("WonderPocketPremiumUI")
    if not premium then return end

    local shop=premium:FindFirstChild("ShopPanel")
    local shopContent=shop and shop:FindFirstChild("Content")
    if shopContent then
        local grid=shopContent:FindFirstChildOfClass("UIGridLayout")
        if grid then grid.CellSize=UDim2.new(.5,-4,0,108) end
        for _,child in ipairs(shopContent:GetChildren()) do decorateButton(child,true) end
        shopContent.ChildAdded:Connect(function(child) task.defer(decorateButton,child,true) end)
    end

    local build=premium:FindFirstChild("BuildPanel")
    local content=build and build:FindFirstChild("Content")
    local frame=content and content:FindFirstChildOfClass("Frame")
    if frame then
        local grid=frame:FindFirstChildOfClass("UIGridLayout")
        if grid then grid.CellSize=UDim2.new(.333,-5,0,68) end
        for _,child in ipairs(frame:GetChildren()) do decorateButton(child,false) end
        frame.ChildAdded:Connect(function(child) task.defer(decorateButton,child,false) end)
    end
end

task.spawn(function()
    local premium=playerGui:WaitForChild("WonderPocketPremiumUI",20)
    if premium then task.defer(decoratePremiumUi) end
end)

local function patchDexViewport(viewport)
    if not viewport:IsA("ViewportFrame") then return end
    local premium=playerGui:FindFirstChild("WonderPocketPremiumUI")
    local dex=premium and premium:FindFirstChild("DexPanel")
    if not dex or not viewport:IsDescendantOf(dex) then return end
    local card=viewport.Parent
    if not card then return end
    local id
    for _,obj in ipairs(card:GetDescendants()) do
        if obj:IsA("TextLabel") then
            id=itemIdFromText(obj.Text)
            if id then break end
        end
    end
    if not id then return end
    if viewport:GetAttribute("WP_CanonicalFurnitureId")==id then return end
    viewport:SetAttribute("WP_CanonicalFurnitureId",id)
    fillViewport(viewport,id)
end

playerGui.DescendantAdded:Connect(function(obj)
    if obj:IsA("ViewportFrame") then task.defer(patchDexViewport,obj) end
end)

task.spawn(function()
    while task.wait(1) do
        local premium=playerGui:FindFirstChild("WonderPocketPremiumUI")
        local dex=premium and premium:FindFirstChild("DexPanel")
        if dex then
            for _,obj in ipairs(dex:GetDescendants()) do
                if obj:IsA("ViewportFrame") then patchDexViewport(obj) end
            end
        end
    end
end)

local ghostCarrier
local ghostVisual
local ghostItem
local ghostValid

local function clearGhostVisual()
    if ghostVisual then ghostVisual:Destroy() end
    ghostCarrier=nil
    ghostVisual=nil
    ghostItem=nil
    ghostValid=nil
end

RunService.RenderStepped:Connect(function()
    local carrier
    for _,obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and obj.Name:sub(1,9)=="WP_Ghost_" then carrier=obj break end
    end
    if not carrier then clearGhostVisual() return end

    local itemId=carrier.Name:sub(10)
    if carrier~=ghostCarrier or itemId~=ghostItem then
        clearGhostVisual()
        ghostCarrier=carrier
        ghostItem=itemId
        ghostVisual=FurnitureAssets.Create(itemId)
        if ghostVisual then
            ghostVisual.Name="WP_GhostFurnitureVisual"
            ghostVisual.Parent=workspace
        end
    end
    if not ghostVisual then return end

    carrier.Transparency=1
    ghostVisual:PivotTo(carrier.CFrame)
    local valid=carrier:GetAttribute("WP_Valid")==true
    if valid~=ghostValid then
        ghostValid=valid
        FurnitureAssets.SetGhostState(ghostVisual,valid)
    end
end)

print("[WONDERPOCKET] Canonical furniture SHOP/BUILD/DEX visual bridge ready")
