local Players = game:GetService("Players")

local ROOT_NAME = "WONDERPOCKET_PlayerPlots"
local root = workspace:FindFirstChild(ROOT_NAME) or Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = workspace

local homes = workspace:FindFirstChild("WONDERPOCKET_PlotHomes") or Instance.new("Folder")
homes.Name = "WONDERPOCKET_PlotHomes"
homes.Parent = workspace

local plotCenters = {
    Vector3.new(-78,5,-78), Vector3.new(-26,5,-78), Vector3.new(26,5,-78), Vector3.new(78,5,-78),
    Vector3.new(-78,5,-26), Vector3.new(78,5,-26), Vector3.new(-78,5,26), Vector3.new(78,5,26),
    Vector3.new(-78,5,78), Vector3.new(-26,5,78), Vector3.new(26,5,78), Vector3.new(78,5,78),
}
local PLOT_SIZE = Vector3.new(44,1,44)
local occupied = {}

local function makePart(parent,name,size,position,color,material,collide)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.Position=position
    p.Anchored=true
    p.CanCollide=collide~=false
    p.Material=material or Enum.Material.SmoothPlastic
    p.Color=color
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent
    return p
end

local function buildPad(index, center)
    local pad = root:FindFirstChild("Plot"..index) or Instance.new("Part")
    pad.Name = "Plot"..index
    pad.Size = PLOT_SIZE
    pad.Position = center
    pad.Anchored = true
    pad.Material = Enum.Material.Grass
    pad.Color = Color3.fromRGB(126,205,106)
    pad.Transparency = 0.08
    pad.TopSurface = Enum.SurfaceType.Smooth
    pad.BottomSurface = Enum.SurfaceType.Smooth
    pad:SetAttribute("WP_PlotIndex", index)
    pad:SetAttribute("WP_OwnerUserId", 0)
    pad.Parent = root
    return pad
end

local function destroyHome(userId)
    local old=homes:FindFirstChild(tostring(userId))
    if old then old:Destroy() end
end

local function addWindow(model,homeCenter,x,z,frontFacing)
    local glass=makePart(model,"WindowGlass",Vector3.new(3.2,2.6,.16),homeCenter+Vector3.new(x,4.4,z),Color3.fromRGB(176,226,255),Enum.Material.Glass,false)
    glass.Transparency=.28
    local trimColor=Color3.fromRGB(245,214,160)
    local depth=frontFacing and .24 or .22
    makePart(model,"WindowTrim",Vector3.new(3.7,.22,depth),glass.Position+Vector3.new(0,1.45,0),trimColor,Enum.Material.WoodPlanks,false)
    makePart(model,"WindowTrim",Vector3.new(3.7,.22,depth),glass.Position+Vector3.new(0,-1.45,0),trimColor,Enum.Material.WoodPlanks,false)
    makePart(model,"WindowTrim",Vector3.new(.22,3.1,depth),glass.Position+Vector3.new(-1.85,0,0),trimColor,Enum.Material.WoodPlanks,false)
    makePart(model,"WindowTrim",Vector3.new(.22,3.1,depth),glass.Position+Vector3.new(1.85,0,0),trimColor,Enum.Material.WoodPlanks,false)
end

local function buildHome(player, center)
    destroyHome(player.UserId)
    local model=Instance.new("Model")
    model.Name=tostring(player.UserId)
    model:SetAttribute("WP_OwnerUserId",player.UserId)
    model:SetAttribute("WP_HomeType","Starter Cottage")
    model.Parent=homes

    local homeCenter=Vector3.new(center.X,center.Y+1,center.Z-8)
    local wallColor=Color3.fromRGB(255,244,218)
    local woodColor=Color3.fromRGB(237,216,180)
    local roofColor=Color3.fromRGB(232,92,132)
    local trimColor=Color3.fromRGB(255,224,105)

    makePart(model,"Floor",Vector3.new(18,1,14),homeCenter,woodColor,Enum.Material.WoodPlanks,true)
    makePart(model,"BackWall",Vector3.new(18,8,1),homeCenter+Vector3.new(0,4,-6.5),wallColor,Enum.Material.SmoothPlastic,true)
    makePart(model,"LeftWall",Vector3.new(1,8,14),homeCenter+Vector3.new(-8.5,4,0),wallColor,Enum.Material.SmoothPlastic,true)
    makePart(model,"RightWall",Vector3.new(1,8,14),homeCenter+Vector3.new(8.5,4,0),wallColor,Enum.Material.SmoothPlastic,true)

    -- Front facade keeps a wide central doorway so entering the cottage remains effortless on mobile.
    makePart(model,"FrontWallLeft",Vector3.new(6.5,8,1),homeCenter+Vector3.new(-5.75,4,6.5),wallColor,Enum.Material.SmoothPlastic,true)
    makePart(model,"FrontWallRight",Vector3.new(6.5,8,1),homeCenter+Vector3.new(5.75,4,6.5),wallColor,Enum.Material.SmoothPlastic,true)
    makePart(model,"DoorLintel",Vector3.new(5,1.5,1),homeCenter+Vector3.new(0,7.25,6.5),wallColor,Enum.Material.SmoothPlastic,true)

    makePart(model,"Roof",Vector3.new(20,1,16),homeCenter+Vector3.new(0,8.5,0),roofColor,Enum.Material.SmoothPlastic,true)
    makePart(model,"RoofTrimFront",Vector3.new(20.5,.35,.5),homeCenter+Vector3.new(0,8.05,7.7),trimColor,Enum.Material.SmoothPlastic,false)
    makePart(model,"RoofTrimBack",Vector3.new(20.5,.35,.5),homeCenter+Vector3.new(0,8.05,-7.7),trimColor,Enum.Material.SmoothPlastic,false)

    -- Small porch anchors the home visually without occupying the garden area.
    makePart(model,"Porch",Vector3.new(8,.55,3.5),homeCenter+Vector3.new(0,.55,7.4),Color3.fromRGB(221,187,145),Enum.Material.WoodPlanks,true)
    makePart(model,"PorchPostLeft",Vector3.new(.45,4.2,.45),homeCenter+Vector3.new(-3.4,2.5,7.2),trimColor,Enum.Material.WoodPlanks,true)
    makePart(model,"PorchPostRight",Vector3.new(.45,4.2,.45),homeCenter+Vector3.new(3.4,2.5,7.2),trimColor,Enum.Material.WoodPlanks,true)
    makePart(model,"PorchAwning",Vector3.new(8.3,.35,3.7),homeCenter+Vector3.new(0,4.55,7.2),roofColor,Enum.Material.SmoothPlastic,false)

    addWindow(model,homeCenter,-5.55,6.02,true)
    addWindow(model,homeCenter,5.55,6.02,true)

    local lamp=makePart(model,"PocketLamp",Vector3.new(.42,.42,.42),homeCenter+Vector3.new(0,5.2,6.05),Color3.fromRGB(255,235,145),Enum.Material.Neon,false)
    lamp.Shape=Enum.PartType.Ball

    local welcome=makePart(model,"PocketSign",Vector3.new(7.6,1.55,.35),homeCenter+Vector3.new(0,6.75,6.02),trimColor,Enum.Material.SmoothPlastic,false)
    local gui=Instance.new("SurfaceGui")
    gui.Face=Enum.NormalId.Front
    gui.AlwaysOnTop=true
    gui.Parent=welcome
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundTransparency=1
    label.Text=player.DisplayName.."'s Pocket"
    label.TextScaled=true
    label.Font=Enum.Font.GothamBold
    label.TextColor3=Color3.fromRGB(45,60,100)
    label.Parent=gui

    player:SetAttribute("WP_HomeReady",true)
end

for i,center in ipairs(plotCenters) do buildPad(i,center) end

local function clearPlotAttributes(player)
    player:SetAttribute("WP_PlotIndex",0)
    player:SetAttribute("WP_PlotCenterX",nil)
    player:SetAttribute("WP_PlotCenterY",nil)
    player:SetAttribute("WP_PlotCenterZ",nil)
    player:SetAttribute("WP_PlotHalfX",nil)
    player:SetAttribute("WP_PlotHalfZ",nil)
end

local function assign(player)
    for i,center in ipairs(plotCenters) do
        if not occupied[i] then
            occupied[i] = player.UserId
            local pad = root:FindFirstChild("Plot"..i)
            if pad then pad:SetAttribute("WP_OwnerUserId", player.UserId) end
            player:SetAttribute("WP_PlotIndex", i)
            player:SetAttribute("WP_PlotCenterX", center.X)
            player:SetAttribute("WP_PlotCenterY", center.Y)
            player:SetAttribute("WP_PlotCenterZ", center.Z)
            player:SetAttribute("WP_PlotHalfX", PLOT_SIZE.X/2 - 2)
            player:SetAttribute("WP_PlotHalfZ", PLOT_SIZE.Z/2 - 2)
            buildHome(player,center)
            return
        end
    end
    clearPlotAttributes(player)
    player:SetAttribute("WP_HomeReady",false)
end

local function release(player)
    local index = tonumber(player:GetAttribute("WP_PlotIndex")) or 0
    if index > 0 and occupied[index] == player.UserId then
        occupied[index] = nil
        local pad = root:FindFirstChild("Plot"..index)
        if pad then pad:SetAttribute("WP_OwnerUserId", 0) end
    end
    destroyHome(player.UserId)
    clearPlotAttributes(player)
end

Players.PlayerAdded:Connect(assign)
Players.PlayerRemoving:Connect(release)
for _,player in ipairs(Players:GetPlayers()) do assign(player) end

print("[WONDERPOCKET] upgraded starter cottages + stable personal Pocket coordinates loaded")
