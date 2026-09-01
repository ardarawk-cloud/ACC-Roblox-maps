-- AFTER SCHOOL CITY — Signage Typography Boost v0.9.2.3
-- Makes all world sign text visually dominant without changing physical sign geometry.
-- Runs after V0.9.2.2 global signage normalization.
-- No road, pool, gameplay, economy, persistence, monetization, music, or dedication authority.

local Workspace = game:GetService("Workspace")
local TextService = game:GetService("TextService")

local VERSION = "0.9.2.3-signage-typography-boost-1"

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V0923 Signage] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_GlobalSignageReadabilityPass", 45) then
    return
end

-- Let slower startup layers finish creating their signage before the first sweep.
task.wait(1.5)

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V0923 Signage] AfterSchoolCity root missing")
    return
end
if root:FindFirstChild("V0923_SignageTypographyBoost") then
    return
end

local layer = Instance.new("Model")
layer.Name = "V0923_SignageTypographyBoost"
layer:SetAttribute("ASC_Layer", "SIGNAGE_TYPOGRAPHY_BOOST")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = root

local adjustedSurfaces = 0
local adjustedLabels = 0
local maxAppliedTextSize = 0

local function getCanvasSize(gui, plate)
    if gui.SizingMode == Enum.SurfaceGuiSizingMode.FixedSize then
        return Vector2.new(math.max(gui.CanvasSize.X, 1), math.max(gui.CanvasSize.Y, 1))
    end

    local pps = math.max(gui.PixelsPerStud, 48)
    gui.PixelsPerStud = pps

    local face = gui.Face
    local studsX, studsY
    if face == Enum.NormalId.Front or face == Enum.NormalId.Back then
        studsX, studsY = plate.Size.X, plate.Size.Y
    elseif face == Enum.NormalId.Left or face == Enum.NormalId.Right then
        studsX, studsY = plate.Size.Z, plate.Size.Y
    else
        studsX, studsY = plate.Size.X, plate.Size.Z
    end

    return Vector2.new(math.max(studsX * pps, 1), math.max(studsY * pps, 1))
end

local function splitLines(text)
    local lines = {}
    text = tostring(text or "")
    if text == "" then
        return lines
    end
    for line in string.gmatch(text .. "\n", "(.-)\n") do
        table.insert(lines, line)
    end
    if #lines == 0 then
        table.insert(lines, text)
    end
    return lines
end

local function textFits(text, font, textSize, width, height)
    local lines = splitLines(text)
    if #lines == 0 then
        return true
    end

    local maxWidth = 0
    local totalHeight = 0
    for _, line in ipairs(lines) do
        local probe = (line == "") and " " or line
        local measured = TextService:GetTextSize(probe, textSize, font, Vector2.new(100000, 100000))
        maxWidth = math.max(maxWidth, measured.X)
        totalHeight += measured.Y
    end

    if #lines > 1 then
        totalHeight += math.max(0, #lines - 1) * math.floor(textSize * 0.08)
    end

    return maxWidth <= width and totalHeight <= height
end

local function bestTextSize(text, font, width, height)
    width = math.max(width, 16)
    height = math.max(height, 16)

    local low = 12
    local high = math.max(low, math.min(360, math.floor(height * 1.15)))
    local best = low

    while low <= high do
        local mid = math.floor((low + high) / 2)
        if textFits(text, font, mid, width, height) then
            best = mid
            low = mid + 1
        else
            high = mid - 1
        end
    end

    return math.max(12, best)
end

local function normalizeSurface(gui)
    local plate = gui.Adornee or gui.Parent
    if not plate or not plate:IsA("BasePart") then
        return
    end

    local labels = {}
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextLabel") and string.gsub(obj.Text or "", "%s", "") ~= "" then
            table.insert(labels, obj)
        end
    end
    if #labels == 0 then
        return
    end

    local canvas = getCanvasSize(gui, plate)
    gui.AlwaysOnTop = false
    gui.LightInfluence = math.min(gui.LightInfluence, 0.24)

    for _, label in ipairs(labels) do
        local singleTitle = (#labels == 1)
        local font = singleTitle and Enum.Font.GothamBlack or Enum.Font.GothamBold

        if singleTitle then
            -- Keep a narrow visual margin so the title visibly fills the physical board.
            label.AnchorPoint = Vector2.new(0, 0)
            label.Position = UDim2.fromScale(0.025, 0.075)
            label.Size = UDim2.fromScale(0.95, 0.85)
        end

        local regionWidth = canvas.X * math.max(label.Size.X.Scale, 0) + label.Size.X.Offset
        local regionHeight = canvas.Y * math.max(label.Size.Y.Scale, 0) + label.Size.Y.Offset
        if regionWidth <= 0 then regionWidth = canvas.X * 0.95 end
        if regionHeight <= 0 then regionHeight = canvas.Y * 0.85 end

        -- Fit to roughly 96% of the authored region. Fixed TextSize avoids the tiny-render
        -- behavior seen on some legacy sign SurfaceGuis even after TextScaled was enabled.
        local fitted = bestTextSize(label.Text, font, regionWidth * 0.96, regionHeight * 0.94)

        label.TextScaled = false
        label.TextSize = fitted
        label.TextWrapped = false
        label.TextTruncate = Enum.TextTruncate.None
        label.Font = font
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.TextStrokeColor3 = Color3.fromRGB(10, 13, 18)
        label.TextStrokeTransparency = math.min(label.TextStrokeTransparency, 0.58)

        for _, child in ipairs(label:GetChildren()) do
            if child:IsA("UITextSizeConstraint") then
                child.MinTextSize = math.min(child.MinTextSize, 8)
                child.MaxTextSize = math.max(child.MaxTextSize, 360)
            end
        end

        label:SetAttribute("ASC_V0923TypographyBoost", true)
        label:SetAttribute("ASC_V0923TextSize", fitted)
        adjustedLabels += 1
        maxAppliedTextSize = math.max(maxAppliedTextSize, fitted)
    end

    plate:SetAttribute("ASC_V0923ReadableSign", true)
    adjustedSurfaces += 1
end

local function sweep()
    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA("SurfaceGui") then
            normalizeSurface(obj)
        end
    end
end

-- Multiple short startup sweeps catch late-created world signs without keeping a permanent listener.
sweep()
task.wait(2)
sweep()
task.wait(3)
sweep()

layer:SetAttribute("ASC_V0923Pass", adjustedLabels > 0)
layer:SetAttribute("ASC_V0923AdjustedSurfaces", adjustedSurfaces)
layer:SetAttribute("ASC_V0923AdjustedLabels", adjustedLabels)
layer:SetAttribute("ASC_V0923MaxTextSize", maxAppliedTextSize)
root:SetAttribute("ASC_SignageTypographyBoost", true)
Workspace:SetAttribute("ASC_SignageTypographyBoostPass", VERSION)

print(string.format(
    "[AFTER SCHOOL CITY] V0.9.2.3 signage typography boost ready; surfaces=%d labels=%d maxTextSize=%d",
    adjustedSurfaces,
    adjustedLabels,
    maxAppliedTextSize
))
