-- AFTER SCHOOL CITY — Global Signage Readability v0.9.2.2
-- Normalizes world signage typography after V0.9.2 and fixes the oversized CITY PARK board.
-- No road, pool, gameplay, economy, persistence, monetization, music, or dedication authority.

local Workspace = game:GetService("Workspace")

local VERSION = "0.9.2.2-global-signage-readability-1"

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V0922 Signage] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_PrecisionEnvironmentPass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V0922 Signage] AfterSchoolCity root missing")
    return
end
if root:FindFirstChild("V0922_GlobalSignageReadability") then
    return
end

local layer = Instance.new("Model")
layer.Name = "V0922_GlobalSignageReadability"
layer:SetAttribute("ASC_Layer", "GLOBAL_SIGNAGE_READABILITY")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = root

local adjustedSurfaces = 0
local adjustedLabels = 0
local adjustedParts = 0

local function lowerName(obj)
    return string.lower(obj and obj.Name or "")
end

local function isSignLikePart(part)
    if not part or not part:IsA("BasePart") then
        return false
    end
    local current = part
    for _ = 1, 4 do
        if not current then break end
        local n = lowerName(current)
        if string.find(n, "sign", 1, true)
            or string.find(n, "wayfinding", 1, true)
            or string.find(n, "marquee", 1, true)
            or string.find(n, "plate", 1, true)
            or string.find(n, "board", 1, true)
            or string.find(n, "fascia", 1, true)
        then
            return true
        end
        current = current.Parent
    end
    return false
end

local function normalizeSurface(gui)
    local plate = gui.Parent
    if not isSignLikePart(plate) then
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

    gui.AlwaysOnTop = false
    gui.LightInfluence = math.min(gui.LightInfluence, 0.3)
    if gui.SizingMode == Enum.SurfaceGuiSizingMode.PixelsPerStud then
        gui.PixelsPerStud = math.max(gui.PixelsPerStud, 48)
    end

    for _, label in ipairs(labels) do
        label.TextScaled = true
        label.TextWrapped = false
        label.TextTruncate = Enum.TextTruncate.None
        label.Font = (#labels == 1) and Enum.Font.GothamBlack or Enum.Font.GothamBold
        label.TextStrokeColor3 = Color3.fromRGB(12, 16, 22)
        label.TextStrokeTransparency = math.min(label.TextStrokeTransparency, 0.76)
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center

        if #labels == 1 then
            label.AnchorPoint = Vector2.new(0, 0)
            label.Position = UDim2.new(0, 6, 0, 4)
            label.Size = UDim2.new(1, -12, 1, -8)
        end

        label:SetAttribute("ASC_V0922Readable", true)
        adjustedLabels += 1
    end

    plate:SetAttribute("ASC_V0922ReadableSign", true)
    adjustedSurfaces += 1
end

-- CITY PARK: this board is visibly oversized at avatar scale. Reduce the physical board,
-- but keep a large single-line headline that fills the new plate.
local premium060 = root:FindFirstChild("V060_PremiumExterior")
local parkExterior = premium060 and premium060:FindFirstChild("V060_ParkExterior")
if parkExterior then
    local sign = parkExterior:FindFirstChild("ParkEntrySign")
    local postL = parkExterior:FindFirstChild("ParkSignPostL")
    local postR = parkExterior:FindFirstChild("ParkSignPostR")
    if sign and sign:IsA("BasePart") and postL and postL:IsA("BasePart") and postR and postR:IsA("BasePart") then
        sign.Size = Vector3.new(12.8, 2.6, 0.5)
        sign.CFrame = CFrame.new(-70, 6.35, -145)
        sign.CanCollide = false
        sign.CanTouch = false
        sign.CanQuery = false

        postL.Size = Vector3.new(0.5, 4.7, 0.5)
        postR.Size = Vector3.new(0.5, 4.7, 0.5)
        postL.CFrame = CFrame.new(-75.4, 3.7, -145)
        postR.CFrame = CFrame.new(-64.6, 3.7, -145)
        postL.CanCollide = false
        postR.CanCollide = false
        postL.CanTouch = false
        postR.CanTouch = false
        postL.CanQuery = false
        postR.CanQuery = false
        adjustedParts += 3
    end
end

-- Global pass: normalize all sign-like SurfaceGui typography already present in the world.
for _, obj in ipairs(root:GetDescendants()) do
    if obj:IsA("SurfaceGui") then
        normalizeSurface(obj)
    end
end

layer:SetAttribute("ASC_V0922Pass", adjustedLabels > 0)
layer:SetAttribute("ASC_V0922AdjustedSurfaces", adjustedSurfaces)
layer:SetAttribute("ASC_V0922AdjustedLabels", adjustedLabels)
layer:SetAttribute("ASC_V0922AdjustedParts", adjustedParts)
root:SetAttribute("ASC_GlobalSignageReadable", true)
Workspace:SetAttribute("ASC_GlobalSignageReadabilityPass", VERSION)

print(string.format(
    "[AFTER SCHOOL CITY] V0.9.2.2 global signage readability ready; surfaces=%d labels=%d parts=%d",
    adjustedSurfaces,
    adjustedLabels,
    adjustedParts
))
