local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("WP_DataSafety")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "WP_DataSafety"
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
gui.Parent = playerGui

local banner = Instance.new("TextLabel")
banner.Name = "ReadOnlyBanner"
banner.AnchorPoint = Vector2.new(.5,0)
banner.Position = UDim2.new(.5,0,0,8)
banner.Size = UDim2.new(1,-24,0,52)
banner.BackgroundColor3 = Color3.fromRGB(126,48,60)
banner.BackgroundTransparency = .04
banner.TextColor3 = Color3.fromRGB(255,245,245)
banner.Font = Enum.Font.GothamBold
banner.TextSize = 13
banner.TextWrapped = true
banner.Text = "SAVE DATA UNAVAILABLE • Your Pocket is READ-ONLY / protected. Rejoin before buying, building, planting, or collecting more progress."
banner.Visible = false
banner.Parent = gui
local constraint = Instance.new("UISizeConstraint")
constraint.MaxSize = Vector2.new(520,52)
constraint.Parent = banner
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,14)
corner.Parent = banner

local failureLabels = {
    WP_DataSaveHealthy = "Main Data",
    WP_InventorySaveHealthy = "Furniture Inventory",
    WP_FurnitureSaveHealthy = "Placed Furniture",
    WP_GardenSaveHealthy = "Garden",
    WP_DexSaveHealthy = "WonderDex",
    WP_DataLoadFailed = "Main Data",
    WP_InventoryLoadFailed = "Furniture Inventory",
    WP_FurnitureLoadFailed = "Placed Furniture",
    WP_GardenLoadFailed = "Garden",
    WP_DexLoadFailed = "WonderDex",
}

local function unsafe()
    return player:GetAttribute("WP_DataReadOnly")==true
        or player:GetAttribute("WP_DataLoadFailed")==true
        or player:GetAttribute("WP_InventoryLoadFailed")==true
        or player:GetAttribute("WP_FurnitureLoadFailed")==true
        or player:GetAttribute("WP_GardenLoadFailed")==true
        or player:GetAttribute("WP_DexLoadFailed")==true
        or player:GetAttribute("WP_DataSaveHealthy")==false
        or player:GetAttribute("WP_InventorySaveHealthy")==false
        or player:GetAttribute("WP_FurnitureSaveHealthy")==false
        or player:GetAttribute("WP_GardenSaveHealthy")==false
        or player:GetAttribute("WP_DexSaveHealthy")==false
end

local function failureSource()
    local reported = tostring(player:GetAttribute("WP_SaveHealthFailure") or "")
    if failureLabels[reported] then return failureLabels[reported] end

    for _, attribute in ipairs({
        "WP_DataLoadFailed","WP_InventoryLoadFailed","WP_FurnitureLoadFailed","WP_GardenLoadFailed","WP_DexLoadFailed",
    }) do
        if player:GetAttribute(attribute)==true then return failureLabels[attribute] end
    end
    for _, attribute in ipairs({
        "WP_DataSaveHealthy","WP_InventorySaveHealthy","WP_FurnitureSaveHealthy","WP_GardenSaveHealthy","WP_DexSaveHealthy",
    }) do
        if player:GetAttribute(attribute)==false then return failureLabels[attribute] end
    end
    return nil
end

local function refresh()
    local blocked = unsafe()
    banner.Visible = blocked
    if not blocked then return end

    local source = failureSource()
    if source then
        banner.Text = string.format("%s SAVE UNAVAILABLE • Your Pocket is READ-ONLY / protected. Rejoin before buying, building, planting, or collecting more progress.", string.upper(source))
    else
        banner.Text = "SAVE DATA UNAVAILABLE • Your Pocket is READ-ONLY / protected. Rejoin before buying, building, planting, or collecting more progress."
    end
end

for _,attribute in ipairs({
    "WP_DataReadOnly","WP_DataLoadFailed","WP_InventoryLoadFailed",
    "WP_FurnitureLoadFailed","WP_GardenLoadFailed","WP_DexLoadFailed",
    "WP_DataSaveHealthy","WP_InventorySaveHealthy","WP_FurnitureSaveHealthy",
    "WP_GardenSaveHealthy","WP_DexSaveHealthy","WP_SaveHealthReadOnly","WP_SaveHealthFailure",
}) do
    player:GetAttributeChangedSignal(attribute):Connect(refresh)
end

local remotes = ReplicatedStorage:WaitForChild("WONDERPOCKET_Remotes",15)
local stateRemote = remotes and remotes:FindFirstChild("State")
if stateRemote then
    stateRemote.OnClientEvent:Connect(function(kind)
        if kind=="LOAD_FAILED" then refresh() end
    end)
end

refresh()
print("[WONDERPOCKET] Load/save health READ-ONLY protection warning UI ready")
