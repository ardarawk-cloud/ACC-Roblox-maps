-- BBYA SOCIAL HUB — DJ BACKGROUND CORRECTION v1
-- Move only the DJ/stage background architecture deeper toward the rear wall.
-- The DJ booth, decks, monitors, speakers and dance floor remain untouched.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then
    warn("[BBYA DJ Background] BBYA_ZERO_BUILD unavailable")
    return
end

local club = root:WaitForChild("MainClubRealism", 30)
if not club then
    warn("[BBYA DJ Background] MainClubRealism unavailable")
    return
end

local architecture = club:WaitForChild("Architecture", 20)
local stage = architecture and architecture:WaitForChild("PremiumStage", 20)
if not stage then
    warn("[BBYA DJ Background] PremiumStage unavailable")
    return
end

-- Rear wall structural face begins around Z=51.0.
-- Shift backdrop objects +2.5 studs so the LED/background reads as a true rear wall,
-- while preserving clearance from the structural rear shell.
local SHIFT = Vector3.new(0, 0, 2.5)

local function moveModelOrPart(obj)
    if obj:IsA("BasePart") then
        obj.CFrame = obj.CFrame + SHIFT
    elseif obj:IsA("Model") then
        obj:PivotTo(obj:GetPivot() + SHIFT)
    end
end

-- Background-only objects. Stage deck/lip are deliberately excluded.
for _, name in ipairs({
    "PortalBack",
    "PortalTop",
    "PortalLeft",
    "PortalRight",
    "LEDWall",
    "LogoDisplay",
}) do
    local obj = stage:FindFirstChild(name)
    if obj then
        moveModelOrPart(obj)
    end
end

-- Safety: any stage background tile/trim that is still forward of Z=48.5 gets moved back,
-- but never touch the stage deck/lip.
for _, obj in ipairs(stage:GetDescendants()) do
    if obj:IsA("BasePart") and obj.Name ~= "StageDeck" and obj.Name ~= "StageLip" and obj.Name ~= "StageLipAccent" then
        if obj.Position.Z > 46 and obj.Position.Z < 48.5 then
            obj.CFrame = obj.CFrame + SHIFT
        end
    end
end

print("[BBYA] DJ background corrected: backdrop/LED portal moved deeper; DJ booth untouched")
