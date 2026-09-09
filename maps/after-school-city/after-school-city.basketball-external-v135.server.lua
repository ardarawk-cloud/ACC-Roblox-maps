-- AFTER SCHOOL CITY â€” V1.3.5 Basketball External Asset
-- Visual replacement layer only. Native SportsField geometry remains as the gameplay/collision authority.

local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")

local VERSION = "1.3.5-basketball-external-1"
local BASKETBALL_COURT_ASSET_ID = 113057298365947 -- ASC_WORKFLOW_BASKETBALL_ASSET_ID

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 60)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V135 Basketball] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_SportsAssetsV134", 60) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V135 Basketball] AfterSchoolCity root missing")
    return
end

if root:FindFirstChild("V135_BasketballExternalAsset") then
    return
end

local districts = root:FindFirstChild("Districts")
local sports = districts and districts:FindFirstChild("SportsField")
local court = sports and sports:FindFirstChild("BasketballCourt")
if not sports or not court or not court:IsA("BasePart") then
    warn("[ASC V135 Basketball] SportsField/BasketballCourt authority missing")
    return
end

local protected = {
    Parent = court.Parent,
    CFrame = court.CFrame,
    Size = court.Size,
    CanCollide = court.CanCollide,
}

local function loadAsset(assetId)
    if not assetId or assetId <= 0 then
        return nil, "ASSET_ID_DISABLED"
    end
    local ok, result = pcall(function()
        return InsertService:LoadAsset(assetId)
    end)
    if not ok or not result then
        return nil, tostring(result)
    end
    return result, nil
end

local function scrubImported(container)
    for _, descendant in ipairs(container:GetDescendants()) do
        if descendant:IsA("LuaSourceContainer") then
            descendant:Destroy()
        elseif descendant:IsA("BasePart") then
            descendant.Anchored = true
            descendant.CanCollide = false
            descendant.CanTouch = false
            descendant.CanQuery = false
            descendant.CastShadow = true
            descendant:SetAttribute("ASC_ExternalAsset", true)
            descendant:SetAttribute("ASC_AssetSource", "BASKETBALL_COURT_GAME_READY")
        end
    end
end

local function findLargestHorizontalPart(container)
    local best = nil
    local bestArea = -1
    for _, descendant in ipairs(container:GetDescendants()) do
        if descendant:IsA("BasePart") then
            local sx, sy, sz = descendant.Size.X, descendant.Size.Y, descendant.Size.Z
            local longest = math.max(sx, sz)
            local area = sx * sz
            if longest > 0.01 and sy <= longest * 0.22 and area > bestArea then
                best = descendant
                bestArea = area
            end
        end
    end
    return best
end

local function hideNativeVisual(instance)
    if instance:IsA("BasePart") then
        instance:SetAttribute("ASC_V135_PreviousTransparency", instance.Transparency)
        instance.Transparency = 1
        instance.CastShadow = false
    end
    for _, descendant in ipairs(instance:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant:SetAttribute("ASC_V135_PreviousTransparency", descendant.Transparency)
            descendant.Transparency = 1
            descendant.CastShadow = false
        end
    end
end

local layer = Instance.new("Model")
layer.Name = "V135_BasketballExternalAsset"
layer:SetAttribute("ASC_Layer", "BASKETBALL_EXTERNAL_VISUAL")
layer:SetAttribute("ASC_Version", VERSION)
layer:SetAttribute("ASC_SourceRightsStatus", "USER_AUTHORIZED_SOURCE_UNVERIFIED")
layer.Parent = root

local imported, loadError = loadAsset(BASKETBALL_COURT_ASSET_ID)
if not imported then
    layer:Destroy()
    warn("[ASC V135 Basketball] asset unavailable: " .. tostring(loadError))
    return
end

imported.Name = "ImportedBasketballCourt"
scrubImported(imported)
imported.Parent = layer

local _, initialSize = imported:GetBoundingBox()
if initialSize.X <= 0.01 or initialSize.Z <= 0.01 then
    layer:Destroy()
    warn("[ASC V135 Basketball] imported asset has invalid bounds")
    return
end

-- Source court is longer on local Z. Rotate 90Â° so it follows the existing ASC court's long X axis.
local fitScale = math.min(
    (court.Size.X * 0.94) / initialSize.Z,
    (court.Size.Z * 0.94) / initialSize.X
)
fitScale = math.clamp(fitScale, 0.1, 20)
imported:ScaleTo(fitScale)
imported:PivotTo(imported:GetPivot() * CFrame.Angles(0, math.rad(90), 0))

local floorPart = findLargestHorizontalPart(imported)
if not floorPart then
    layer:Destroy()
    warn("[ASC V135 Basketball] unable to resolve imported court floor")
    return
end

local bboxCFrame = imported:GetBoundingBox()
local shiftX = court.Position.X - bboxCFrame.Position.X
local shiftZ = court.Position.Z - bboxCFrame.Position.Z
local nativeTop = court.Position.Y + court.Size.Y * 0.5
local importedFloorTop = floorPart.Position.Y + floorPart.Size.Y * 0.5
local shiftY = (nativeTop + 0.10) - importedFloorTop
imported:PivotTo(imported:GetPivot() + Vector3.new(shiftX, shiftY, shiftZ))

-- Once the imported layer is safely placed, hide only the old visual pieces that would double-render.
-- The native BasketballCourt part stays in place and keeps its collision authority.
hideNativeVisual(court)
for _, child in ipairs(sports:GetChildren()) do
    if child.Name == "BasketballHoop"
        or child.Name == "CenterLine"
        or child.Name == "SideLineN"
        or child.Name == "SideLineS"
        or child.Name == "Bleachers" then
        hideNativeVisual(child)
    end
end

local protectedUnchanged = court.Parent == protected.Parent
    and court.CFrame == protected.CFrame
    and court.Size == protected.Size
    and court.CanCollide == protected.CanCollide
if not protectedUnchanged then
    layer:Destroy()
    warn("[ASC V135 Basketball] HARD LOCK FAILED: native court geometry/collision changed")
    return
end

local finalBoxCFrame, finalBoxSize = imported:GetBoundingBox()
layer:SetAttribute("ASC_BasketballAssetId", BASKETBALL_COURT_ASSET_ID)
layer:SetAttribute("ASC_FitScale", fitScale)
layer:SetAttribute("ASC_FinalWidth", finalBoxSize.X)
layer:SetAttribute("ASC_FinalDepth", finalBoxSize.Z)
layer:SetAttribute("ASC_NativeCourtCollisionPreserved", true)
root:SetAttribute("ASC_BasketballExternalV135", VERSION)
Workspace:SetAttribute("ASC_BasketballExternalV135", VERSION)

print(string.format(
    "[AFTER SCHOOL CITY] V1.3.5 basketball external visual ready asset=%d scale=%.3f center=(%.1f,%.1f,%.1f) nativeCollisionPreserved=true",
    BASKETBALL_COURT_ASSET_ID,
    fitScale,
    finalBoxCFrame.Position.X,
    finalBoxCFrame.Position.Y,
    finalBoxCFrame.Position.Z
))

