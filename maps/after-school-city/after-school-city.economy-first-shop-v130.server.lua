-- AFTER SCHOOL CITY — V1.3-A Economy Core + First Shop
-- V1.3-B visual polish: shaped physical product displays while preserving purchase/data authority.
-- Server-authoritative ASC Coin spending and persistent collectible ownership remain unchanged.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local ASCConfig = require(ReplicatedStorage:WaitForChild("ASCConfig"))
local EconomyConfig = require(ReplicatedStorage:WaitForChild("ASCEconomyConfig"))
local GameplayService = require(ServerScriptService:WaitForChild("ASC_GameplayService"))

local VISUAL_VERSION = "1.3.3-mini-mart-product-display-1"
local DISPLAY_DARK = Color3.fromRGB(28, 34, 45)
local DISPLAY_METAL = Color3.fromRGB(82, 88, 99)
local DISPLAY_PAPER = Color3.fromRGB(231, 225, 209)
local DISPLAY_SILVER = Color3.fromRGB(174, 181, 190)
local DISPLAY_GOLD = Color3.fromRGB(225, 170, 73)

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
layer:SetAttribute("ASC_VisualVersion", VISUAL_VERSION)
layer:SetAttribute("ASC_ShopId", shopConfig.Id)
layer.Parent = miniMart

local function visualPart(parent, name, size, cf, color, material, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = true
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color or Color3.fromRGB(240, 240, 240)
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    if shape then
        p.Shape = shape
    end
    p.Parent = parent
    return p
end

local function productModel(parent, item)
    local model = Instance.new("Model")
    model.Name = "Display_" .. item.Id
    model:SetAttribute("ASC_ProductDisplay", true)
    model:SetAttribute("ASCEconomyItemId", item.Id)
    model.Parent = parent
    return model
end

local function addSurfaceLabel(plate, face, text)
    local gui = Instance.new("SurfaceGui")
    gui.Name = "PriceFace_" .. face.Name
    gui.Face = face
    gui.AlwaysOnTop = false
    gui.LightInfluence = 0.2
    gui.PixelsPerStud = 42
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.Parent = plate

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextWrapped = true
    label.RichText = true
    label.TextColor3 = Color3.fromRGB(244, 247, 250)
    label.Text = text
    label.Parent = gui

    local constraint = Instance.new("UITextSizeConstraint")
    constraint.MinTextSize = 8
    constraint.MaxTextSize = 15
    constraint.Parent = label
end

local function createProductLabel(parent, item, xOffset, spacing, counterSurfaceY)
    local width = math.min(2.75, math.max(2.15, spacing - 0.32))
    local cf = counterTop.CFrame * CFrame.new(
        xOffset,
        counterSurfaceY + 0.48,
        counterTop.Size.Z * 0.5 - 0.08
    )

    local plate = visualPart(parent, "PricePlate_" .. item.Id, Vector3.new(width, 0.78, 0.10), cf, DISPLAY_DARK, Enum.Material.Metal)
    plate.CanQuery = false

    local text = string.format(
        "%s\n<font color=\"#E1AA49\">%d ASC COINS</font>",
        string.upper(item.DisplayName),
        item.Price
    )
    addSurfaceLabel(plate, Enum.NormalId.Front, text)
    addSurfaceLabel(plate, Enum.NormalId.Back, text)

    visualPart(
        parent,
        "PriceAccent_" .. item.Id,
        Vector3.new(width - 0.18, 0.08, 0.13),
        cf * CFrame.new(0, -0.33, 0),
        item.Color,
        Enum.Material.SmoothPlastic
    )
end

local function buildNotebook(parent, item, baseCF)
    local model = productModel(parent, item)
    local cf = baseCF * CFrame.Angles(0, math.rad(-8), 0)

    visualPart(model, "Pages", Vector3.new(1.36, 0.22, 1.62), cf * CFrame.new(0, 0.15, 0), DISPLAY_PAPER, Enum.Material.SmoothPlastic)
    local cover = visualPart(model, "Cover", Vector3.new(1.46, 0.09, 1.72), cf * CFrame.new(0, 0.31, 0), item.Color, Enum.Material.SmoothPlastic)
    visualPart(model, "Spine", Vector3.new(0.10, 0.34, 1.72), cf * CFrame.new(-0.68, 0.17, 0), Color3.fromRGB(39, 57, 79), Enum.Material.SmoothPlastic)
    visualPart(model, "Band", Vector3.new(0.13, 0.10, 1.54), cf * CFrame.new(0.44, 0.37, 0), DISPLAY_GOLD, Enum.Material.SmoothPlastic)
    return cover
end

local function buildStickerPack(parent, item, baseCF)
    local model = productModel(parent, item)
    local cf = baseCF * CFrame.Angles(0, math.rad(6), 0)

    local packet = visualPart(model, "Packet", Vector3.new(1.30, 1.58, 0.18), cf * CFrame.new(0, 0.79, 0), item.Color, Enum.Material.SmoothPlastic)
    visualPart(model, "HeaderTab", Vector3.new(1.02, 0.24, 0.20), cf * CFrame.new(0, 1.67, 0), DISPLAY_GOLD, Enum.Material.SmoothPlastic)

    local stickerSpecs = {
        {x = -0.36, y = 1.08, color = Color3.fromRGB(239, 222, 105)},
        {x = 0.30, y = 0.92, color = Color3.fromRGB(235, 132, 123)},
        {x = -0.02, y = 0.48, color = Color3.fromRGB(99, 176, 169)},
    }
    for i, spec in ipairs(stickerSpecs) do
        visualPart(
            model,
            "Sticker" .. i,
            Vector3.new(0.09, 0.38, 0.38),
            cf * CFrame.new(spec.x, spec.y, 0.15) * CFrame.Angles(0, math.rad(90), 0),
            spec.color,
            Enum.Material.SmoothPlastic,
            Enum.PartType.Cylinder
        )
    end
    return packet
end

local function buildKeychain(parent, item, baseCF)
    local model = productModel(parent, item)
    local cf = baseCF * CFrame.Angles(0, math.rad(-5), 0)

    local ring = visualPart(
        model,
        "RingOuter",
        Vector3.new(0.13, 0.88, 0.88),
        cf * CFrame.new(0, 1.18, 0) * CFrame.Angles(0, math.rad(90), 0),
        DISPLAY_SILVER,
        Enum.Material.Metal,
        Enum.PartType.Cylinder
    )
    visualPart(
        model,
        "RingHole",
        Vector3.new(0.15, 0.46, 0.46),
        cf * CFrame.new(0, 1.18, 0.02) * CFrame.Angles(0, math.rad(90), 0),
        DISPLAY_DARK,
        Enum.Material.SmoothPlastic,
        Enum.PartType.Cylinder
    )
    visualPart(model, "Connector", Vector3.new(0.13, 0.43, 0.13), cf * CFrame.new(0, 0.72, 0), DISPLAY_SILVER, Enum.Material.Metal)
    local tag = visualPart(model, "ASCTag", Vector3.new(0.78, 0.70, 0.20), cf * CFrame.new(0, 0.30, 0), item.Color, Enum.Material.SmoothPlastic)
    visualPart(model, "TagStripe", Vector3.new(0.58, 0.10, 0.22), cf * CFrame.new(0, 0.34, 0.02), DISPLAY_GOLD, Enum.Material.SmoothPlastic)
    ring.CanQuery = false
    return tag
end

local function buildTote(parent, item, baseCF)
    local model = productModel(parent, item)
    local cf = baseCF * CFrame.Angles(0, math.rad(5), 0)

    local body = visualPart(model, "BagBody", Vector3.new(1.62, 1.24, 0.48), cf * CFrame.new(0, 0.62, 0), item.Color, Enum.Material.Fabric)
    visualPart(model, "BagBottom", Vector3.new(1.66, 0.13, 0.52), cf * CFrame.new(0, 0.08, 0), Color3.fromRGB(74, 58, 92), Enum.Material.Fabric)

    for _, x in ipairs({-0.47, 0.47}) do
        local angle = x < 0 and -18 or 18
        visualPart(
            model,
            x < 0 and "HandleL" or "HandleR",
            Vector3.new(0.12, 0.90, 0.12),
            cf * CFrame.new(x, 1.52, 0.24) * CFrame.Angles(0, 0, math.rad(angle)),
            Color3.fromRGB(93, 72, 116),
            Enum.Material.Fabric
        )
    end
    visualPart(model, "HandleTop", Vector3.new(0.76, 0.12, 0.12), cf * CFrame.new(0, 1.91, 0.24), Color3.fromRGB(93, 72, 116), Enum.Material.Fabric)
    visualPart(model, "ASCMark", Vector3.new(0.54, 0.13, 0.51), cf * CFrame.new(0, 0.68, 0.27), DISPLAY_GOLD, Enum.Material.SmoothPlastic)
    return body
end

local function buildFallback(parent, item, baseCF)
    local model = productModel(parent, item)
    return visualPart(model, "Product", Vector3.new(1.25, 1.05, 1.25), baseCF * CFrame.new(0, 0.53, 0), item.Color, Enum.Material.SmoothPlastic)
end

local productBuilders = {
    CAMPUS_NOTEBOOK = buildNotebook,
    CITY_STICKER_PACK = buildStickerPack,
    ASC_KEYCHAIN = buildKeychain,
    STUDENT_TOTE = buildTote,
}

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
local counterSurfaceY = counterTop.Size.Y * 0.5
local padHeight = 0.16
local padDepth = math.min(2.20, math.max(1.75, counterTop.Size.Z - 1.0))
local padWidth = math.min(2.60, math.max(2.10, spacing - 0.34))

-- A restrained physical rail makes the merchandise read as one coherent retail display.
visualPart(
    layer,
    "DisplayRail",
    Vector3.new(math.max(4, counterTop.Size.X - 1.0), 0.10, 0.12),
    counterTop.CFrame * CFrame.new(0, counterSurfaceY + 0.06, -counterTop.Size.Z * 0.5 + 0.16),
    DISPLAY_GOLD,
    Enum.Material.Metal
)

for index, item in ipairs(items) do
    local xOffset = (index - 1 - centerOffset) * spacing
    local padCF = counterTop.CFrame * CFrame.new(xOffset, counterSurfaceY + padHeight * 0.5, -0.18)
    local baseCF = counterTop.CFrame * CFrame.new(xOffset, counterSurfaceY + padHeight, -0.18)

    visualPart(layer, "DisplayPad_" .. item.Id, Vector3.new(padWidth, padHeight, padDepth), padCF, DISPLAY_DARK, Enum.Material.Slate)
    visualPart(
        layer,
        "DisplayPadAccent_" .. item.Id,
        Vector3.new(padWidth - 0.16, 0.06, 0.10),
        padCF * CFrame.new(0, padHeight * 0.5 + 0.03, padDepth * 0.5 - 0.08),
        item.Color,
        Enum.Material.SmoothPlastic
    )

    local builder = productBuilders[item.Id] or buildFallback
    local promptHost = builder(layer, item, baseCF)
    promptHost.CanQuery = true
    promptHost:SetAttribute("ASCEconomyItemId", item.Id)
    promptHost:SetAttribute("ASCEconomyPrice", item.Price)
    promptHost:SetAttribute("ASCEconomyKind", item.Kind)
    promptHost:SetAttribute("ASC_ShapedProductDisplay", true)

    createProductLabel(layer, item, xOffset, spacing, counterSurfaceY)

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
    prompt.Parent = promptHost

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
miniMart:SetAttribute("ASC_V133MiniMartVisualVersion", VISUAL_VERSION)
root:SetAttribute("ASC_EconomyReady", true)
root:SetAttribute("ASC_EconomyVersion", EconomyConfig.Version)
Workspace:SetAttribute("ASC_EconomyReady", true)
Workspace:SetAttribute("ASC_EconomyVersion", EconomyConfig.Version)

print(string.format("[AFTER SCHOOL CITY] V1.3 economy first shop ready; shop=%s items=%d visual=%s", shopConfig.Id, count, VISUAL_VERSION))
