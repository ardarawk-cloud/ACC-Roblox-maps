-- AFTER SCHOOL CITY — City Park Sign Proportion Hotfix v0.9.2.1
-- Exact narrow correction on top of V0.9.2 LIVE.
-- Goal: smaller physical board, much larger deterministic headline typography.
-- No road, pool, gameplay, economy, persistence, monetization, music, or dedication authority.

local Workspace = game:GetService("Workspace")

local VERSION = "0.9.2.1-city-park-sign-proportion-1"

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V0921] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_PrecisionEnvironmentPass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V0921] AfterSchoolCity root missing")
    return
end

local premium060 = root:FindFirstChild("V060_PremiumExterior")
local parkExterior = premium060 and premium060:FindFirstChild("V060_ParkExterior")
if not parkExterior then
    warn("[ASC V0921] Park exterior authority missing")
    return
end

local sign = parkExterior:FindFirstChild("ParkEntrySign")
local postL = parkExterior:FindFirstChild("ParkSignPostL")
local postR = parkExterior:FindFirstChild("ParkSignPostR")
if not sign or not sign:IsA("BasePart") or not postL or not postL:IsA("BasePart") or not postR or not postR:IsA("BasePart") then
    warn("[ASC V0921] City Park sign parts missing")
    return
end

-- Screenshot-confirmed issue: the 22 x 4.2 board is visually oversized at player distance.
-- Keep the same landmark position but reduce the physical mass substantially.
local BOARD_WIDTH = 13.6
local BOARD_HEIGHT = 2.8
local BOARD_THICKNESS = 0.48
local BOARD_Y = 6.55
local POST_HEIGHT = 4.7
local POST_SPAN = 5.8

sign.Size = Vector3.new(BOARD_WIDTH, BOARD_HEIGHT, BOARD_THICKNESS)
sign.CFrame = CFrame.new(-70, BOARD_Y, -145)
sign.CanCollide = false
sign.CanTouch = false
sign.CanQuery = false

postL.Size = Vector3.new(0.55, POST_HEIGHT, 0.55)
postR.Size = Vector3.new(0.55, POST_HEIGHT, 0.55)
postL.CFrame = CFrame.new(-70 - POST_SPAN, 3.45, -145)
postR.CFrame = CFrame.new(-70 + POST_SPAN, 3.45, -145)
postL.CanCollide = false
postR.CanCollide = false
postL.CanTouch = false
postR.CanTouch = false
postL.CanQuery = false
postR.CanQuery = false

-- Rebuild the typography deterministically. TextScaled on the previous sign did not
-- produce a strong enough headline in live mobile rendering, so use a fixed canvas
-- and explicit large type instead.
for _, child in ipairs(sign:GetChildren()) do
    if child:IsA("SurfaceGui") then
        child:Destroy()
    end
end

local function buildFace(face)
    local gui = Instance.new("SurfaceGui")
    gui.Name = "CityParkHeadline"
    gui.Face = face
    gui.AlwaysOnTop = false
    gui.LightInfluence = 0.22
    gui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
    gui.CanvasSize = Vector2.new(1024, 256)
    gui.Parent = sign

    local label = Instance.new("TextLabel")
    label.Name = "Headline"
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Position = UDim2.fromScale(0, 0)
    label.Text = "CITY PARK"
    label.TextColor3 = Color3.fromRGB(244, 238, 220)
    label.Font = Enum.Font.GothamBlack
    label.TextScaled = false
    label.TextSize = 154
    label.TextWrapped = false
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextStrokeColor3 = Color3.fromRGB(18, 24, 34)
    label.TextStrokeTransparency = 0.72
    label.Parent = gui
end

buildFace(Enum.NormalId.Front)
buildFace(Enum.NormalId.Back)

sign:SetAttribute("ASC_V0921BoardWidth", BOARD_WIDTH)
sign:SetAttribute("ASC_V0921BoardHeight", BOARD_HEIGHT)
sign:SetAttribute("ASC_V0921HeadlineTextSize", 154)
sign:SetAttribute("ASC_V0921Corrected", true)
root:SetAttribute("ASC_CityParkSignHotfix", VERSION)
Workspace:SetAttribute("ASC_CityParkSignHotfixPass", VERSION)

print(string.format("[AFTER SCHOOL CITY] City Park sign hotfix %s ready; board=%.1fx%.1f headline=%d", VERSION, BOARD_WIDTH, BOARD_HEIGHT, 154))
