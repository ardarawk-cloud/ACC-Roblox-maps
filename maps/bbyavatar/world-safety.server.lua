-- BBYAVATAR world safety sentinel.
-- This script is intentionally isolated from the main runtime and feature stack.
-- Its only job is to prevent a totally blank/unplayable place if the world bootstrap regresses.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local ROOT_NAME = "BBYAVATAR_SHOWROOM"
local SENTINEL_NAME = "BBYAVATAR_SAFETY_FALLBACK"
local CHECK_DELAY = 6
local MIN_WORLD_PARTS = 12

local function countBaseParts(container)
    local count = 0
    for _, descendant in ipairs(container:GetDescendants()) do
        if descendant:IsA("BasePart") then
            count += 1
        end
    end
    return count
end

local function hasHealthyWorld()
    local root = Workspace:FindFirstChild(ROOT_NAME)
    if not root then
        return false, "missing_root"
    end
    local parts = countBaseParts(root)
    if parts < MIN_WORLD_PARTS then
        return false, "too_few_parts_" .. tostring(parts)
    end
    return true, "healthy"
end

local function makePart(parent, name, size, cframe, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Anchored = true
    part.Color = color
    part.Material = material or Enum.Material.SmoothPlastic
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

local function makeLabel(part, text)
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Front
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 28
    gui.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextScaled = true
    label.TextWrapped = true
    label.TextColor3 = Color3.fromRGB(245, 245, 245)
    label.Parent = gui
end

local function buildFallback(reason)
    if Workspace:FindFirstChild(SENTINEL_NAME) then
        return
    end

    local fallback = Instance.new("Folder")
    fallback.Name = SENTINEL_NAME
    fallback:SetAttribute("FallbackActive", true)
    fallback:SetAttribute("Reason", reason)
    fallback.Parent = Workspace

    Lighting.ClockTime = 13.5
    Lighting.Brightness = math.max(Lighting.Brightness, 2.5)
    Lighting.Ambient = Color3.fromRGB(135, 135, 145)
    Lighting.OutdoorAmbient = Color3.fromRGB(160, 160, 170)

    makePart(fallback, "EmergencyFloor", Vector3.new(120, 1, 120), CFrame.new(0, 0, 0), Color3.fromRGB(205, 202, 195), Enum.Material.Marble)
    makePart(fallback, "EmergencyBack", Vector3.new(120, 20, 1), CFrame.new(0, 10, -59.5), Color3.fromRGB(32, 33, 38))
    makePart(fallback, "EmergencyLeft", Vector3.new(1, 20, 120), CFrame.new(-59.5, 10, 0), Color3.fromRGB(232, 229, 222))
    makePart(fallback, "EmergencyRight", Vector3.new(1, 20, 120), CFrame.new(59.5, 10, 0), Color3.fromRGB(232, 229, 222))

    local runway = makePart(fallback, "EmergencyRunway", Vector3.new(20, 0.3, 90), CFrame.new(0, 0.7, -2), Color3.fromRGB(48, 49, 56), Enum.Material.Slate)
    runway.CanCollide = true

    local brand = makePart(fallback, "EmergencyBrand", Vector3.new(34, 5, 1), CFrame.new(0, 10, -58.8), Color3.fromRGB(35, 36, 42))
    makeLabel(brand, "BBYAVATAR")

    for _, x in ipairs({-28, 28}) do
        for _, z in ipairs({28, 0, -28}) do
            makePart(fallback, "EmergencyDisplay", Vector3.new(18, 1, 14), CFrame.new(x, 0.7, z), Color3.fromRGB(226, 223, 216), Enum.Material.Marble)
        end
    end

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "BBYAVATAR_FallbackSpawn"
    spawn.Size = Vector3.new(8, 1, 8)
    spawn.CFrame = CFrame.new(0, 1.5, 48) * CFrame.Angles(0, math.rad(180), 0)
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Transparency = 0.85
    spawn.Parent = fallback

    warn("[BBYAVATAR] World safety fallback activated: " .. tostring(reason))
end

task.delay(CHECK_DELAY, function()
    local healthy, reason = hasHealthyWorld()
    if healthy then
        local fallback = Workspace:FindFirstChild(SENTINEL_NAME)
        if fallback then
            fallback:Destroy()
        end
        return
    end
    buildFallback(reason)
end)
