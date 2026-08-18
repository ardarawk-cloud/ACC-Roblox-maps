local Players = game:GetService("Players")

local ROOT_NAME = "WONDERPOCKET_PlayerPlots"
local root = workspace:FindFirstChild(ROOT_NAME) or Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = workspace

local plotCenters = {
    Vector3.new(-78,5,-78), Vector3.new(-26,5,-78), Vector3.new(26,5,-78), Vector3.new(78,5,-78),
    Vector3.new(-78,5,-26), Vector3.new(78,5,-26), Vector3.new(-78,5,26), Vector3.new(78,5,26),
    Vector3.new(-78,5,78), Vector3.new(-26,5,78), Vector3.new(26,5,78), Vector3.new(78,5,78),
}
local PLOT_SIZE = Vector3.new(44,1,44)
local occupied = {}

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

for i,center in ipairs(plotCenters) do buildPad(i,center) end

local function assign(player)
    for i,center in ipairs(plotCenters) do
        if not occupied[i] then
            occupied[i] = player.UserId
            local pad = root:FindFirstChild("Plot"..i)
            if pad then pad:SetAttribute("WP_OwnerUserId", player.UserId) end
            player:SetAttribute("WP_PlotIndex", i)
            player:SetAttribute("WP_PlotCenterX", center.X)
            player:SetAttribute("WP_PlotCenterZ", center.Z)
            player:SetAttribute("WP_PlotHalfX", PLOT_SIZE.X/2 - 2)
            player:SetAttribute("WP_PlotHalfZ", PLOT_SIZE.Z/2 - 2)
            return
        end
    end
    player:SetAttribute("WP_PlotIndex", 0)
end

local function release(player)
    local index = tonumber(player:GetAttribute("WP_PlotIndex")) or 0
    if index > 0 and occupied[index] == player.UserId then
        occupied[index] = nil
        local pad = root:FindFirstChild("Plot"..index)
        if pad then pad:SetAttribute("WP_OwnerUserId", 0) end
    end
end

Players.PlayerAdded:Connect(assign)
Players.PlayerRemoving:Connect(release)
for _,player in ipairs(Players:GetPlayers()) do assign(player) end

print("[WONDERPOCKET] Player plot ownership loaded")