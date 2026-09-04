-- AFTER SCHOOL CITY — V1.3-A Economy Core + First Shop
-- Server-authoritative ASC Coin spending and persistent collectible ownership.
-- Uses the existing Student Mini Mart interior; no marketplace/Robux authority is introduced.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local ASCConfig = require(ReplicatedStorage:WaitForChild("ASCConfig"))
local EconomyConfig = require(ReplicatedStorage:WaitForChild("ASCEconomyConfig"))
local GameplayService = require(ServerScriptService:WaitForChild("ASC_GameplayService"))

if not (ASCConfig.Flags and ASCConfig.Flags.EnableEconomy) then
    warn("[ASC V1.3] Economy disabled by ASCConfig")
    return
end

local function waitForAttribute(instance, name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if instance:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    return false
end

if not waitForAttribute(Workspace, "ASC_StudentRowShopInteriorsPass", 45) then
    warn("[ASC V1.3] Student Row shop interior readiness timeout")
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 30)
if not root then
    warn("[ASC V1.3] AfterSchoolCity root missing")
    return
end

local streetLife = root:FindFirstChild("V04_StreetLife")
local studentRow = streetLife and streetLife:FindFirstChild("StudentRowInfill")
local shopConfig = EconomyConfig.FirstShop
local miniMart = studentRow and studentRow:FindFirstChild(shopConfig.ModelName)
local interior = miniMart and miniMart:FindFirstChild("V080_Interior")
local counterTop = interior and interior:FindFirstChild("CounterTop")

if not (miniMart and interior and counterTop and counterTop:IsA("BasePart")) then
    warn("[ASC V1.3] Student Mini Mart purchase anchor missing")
    return
end

if miniMart:FindFirstChild("V130_EconomyFirstShop") then
    return
end

local layer = Instance.new("Model")
layer.Name = "V130_EconomyFirstShop"
layer:SetAttribute("ASC_Layer", "ECONOMY_FIRST_SHOP")
layer:SetAttribute("ASC_Version", EconomyConfig.Version)
layer:SetAttribute("ASC_ShopId", shopConfig.Id)
layer.Parent = miniMart

local function createProductLabel(part, item)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ProductLabel"
    billboard.Size = UDim2.fromOffset(156, 42)
    billboard.StudsOffset = Vector3.new(0, 1.25, 0)
    billboard.AlwaysOnTop = false
    billboard.LightInfluence = 0.2
    billboard.MaxDistance = 24
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = Color3.fromRGB(19, 25, 36)
    label.BackgroundTransparency = 0.16
    label.BorderSizePixel = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextWrapped = true
    label.TextColor3 = Color3.fromRGB(244, 247, 250)
    label.Text = string.format("%s\n%d ASC COINS", string.upper(item.DisplayName), item.Price)
    label.Parent = billboard

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = label

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Transparency = 0.2
    stroke.Color = Color3.fromRGB(225, 170, 73)
    stroke.Parent = label
end

local function failureDialogue(player, item, code)
    if code == "PROFILE_NOT_READY" then
        GameplayService.ShowDialogue(player, "MINI MART", "Your profile is still loading. Try again in a moment.")
        return
    end
    if code == "SAVE_UNAVAILABLE" then
        GameplayService.ShowDialogue(player, "MINI MART", "Purchases pause while cloud save is unavailable. Rejoin when SAVE AKTIF is back.")
        return
    end
    if code == "ALREADY_OWNED" then
        GameplayService.ShowDialogue(player, "MINI MART", "You already own " .. item.DisplayName .. ".")
        return
    end
    if code == "INSUFFICIENT_COINS" then
        local state = GameplayService.GetState(player)
        local shortfall = math.max(0, item.Price - (state.Coins or 0))
        GameplayService.ShowDialogue(player, "MINI MART", string.format("You need %d more ASC Coins for %s.", shortfall, item.DisplayName))
        return
    end
    GameplayService.ShowDialogue(player, "MINI MART", "Purchase unavailable right now.")
end

local items = shopConfig.Items
local count = #items
local spacing = math.min(4.1, math.max(2.8, (counterTop.Size.X - 3) / math.max(1, count)))
local centerOffset = (count - 1) * 0.5

for index, item in ipairs(items) do
    local xOffset = (index - 1 - centerOffset) * spacing
    local sample = Instance.new("Part")
    sample.Name = "Product_" .. item.Id
    sample.Size = Vector3.new(1.25, 1.05, 1.25)
    sample.CFrame = counterTop.CFrame * CFrame.new(xOffset, counterTop.Size.Y * 0.5 + 0.58, 0)
    sample.Anchored = true
    sample.CanCollide = false
    sample.CanTouch = false
    sample.CanQuery = true
    sample.CastShadow = true
    sample.Material = Enum.Material.SmoothPlastic
    sample.Color = item.Color
    sample.TopSurface = Enum.SurfaceType.Smooth
    sample.BottomSurface = Enum.SurfaceType.Smooth
    sample:SetAttribute("ASCEconomyItemId", item.Id)
    sample:SetAttribute("ASCEconomyPrice", item.Price)
    sample:SetAttribute("ASCEconomyKind", item.Kind)
    sample.Parent = layer

    createProductLabel(sample, item)

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "Buy_" .. item.Id
    prompt.ActionText = "BUY"
    prompt.ObjectText = string.format("%s | %d COINS", item.DisplayName, item.Price)
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
    prompt.HoldDuration = 0.2
    prompt.MaxActivationDistance = shopConfig.MaxActivationDistance
    prompt.RequiresLineOfSight = false
    prompt:SetAttribute("ASCEconomyPromptId", "BUY_" .. item.Id)
    prompt:SetAttribute("ASCEconomyItemId", item.Id)
    prompt.Parent = sample

    prompt.Triggered:Connect(function(player)
        local state = GameplayService.GetState(player)
        if not state.Ready then
            failureDialogue(player, item, "PROFILE_NOT_READY")
            return
        end
        if not state.Persistent then
            failureDialogue(player, item, "SAVE_UNAVAILABLE")
            return
        end

        local allowed = GameplayService.CanUseCooldown(player, "V130_PURCHASE", EconomyConfig.PurchaseCooldownSeconds)
        if not allowed then
            return
        end

        local ok, code = GameplayService.PurchaseItem(player, item.Id, item.Price, item.MaxOwned, item.DisplayName)
        if not ok then
            failureDialogue(player, item, code)
            return
        end

        GameplayService.ShowDialogue(player, "MINI MART", item.DisplayName .. " is now saved in your collection.")
    end)
end

miniMart:SetAttribute("ASC_V130PurchaseAuthority", true)
miniMart:SetAttribute("ASC_V130ShopId", shopConfig.Id)
miniMart:SetAttribute("ASC_V130ShopItemCount", count)
miniMart:SetAttribute("ASC_V130EconomyVersion", EconomyConfig.Version)
root:SetAttribute("ASC_EconomyReady", true)
root:SetAttribute("ASC_EconomyVersion", EconomyConfig.Version)
Workspace:SetAttribute("ASC_EconomyReady", true)
Workspace:SetAttribute("ASC_EconomyVersion", EconomyConfig.Version)

print(string.format("[AFTER SCHOOL CITY] V1.3 economy first shop ready; shop=%s items=%d", shopConfig.Id, count))
