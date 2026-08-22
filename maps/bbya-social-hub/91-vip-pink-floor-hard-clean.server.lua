-- BBYA SOCIAL HUB — VIP FLOOR FINAL GUARD v3
-- Final owner lock for L2 VIP:
-- 1) remove ONLY pink/magenta floor neon,
-- 2) never remove blue/cyan trim,
-- 3) restore the four intended blue floor-boundary strips if another pass removed them.
-- Ceiling/DJ-wall/rooftop lighting is outside this guard.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then return end
local upper = root:WaitForChild("UpperLevels", 30)
if not upper then return end
local vip = upper:WaitForChild("L2_VIP_Level", 30)
if not vip then return end
local active = vip:WaitForChild("VIPMinimalStanding", 30)
if not active then return end

local BLUE = Color3.fromRGB(0, 174, 255)
local FLOOR_Y = 25.04

local BLUE_SPECS = {
    {name="OuterSouth", size=Vector3.new(116, 0.10, 0.16), cf=CFrame.new(0, FLOOR_Y, -44.92)},
    {name="OuterWest",  size=Vector3.new(0.16, 0.10, 90), cf=CFrame.new(-57.92, FLOOR_Y, 0)},
    {name="InnerNorth", size=Vector3.new(70, 0.10, 0.16), cf=CFrame.new(0, FLOOR_Y, 22.86)},
    {name="InnerEast",  size=Vector3.new(0.16, 0.10, 50), cf=CFrame.new(34.86, FLOOR_Y, -2)},
}

local function isPinkFloorNeon(obj)
    if not obj:IsA("BasePart") then return false end
    if obj.Material ~= Enum.Material.Neon then return false end
    local y = obj.Position.Y
    if y < 24.4 or y > 25.6 then return false end
    local c = obj.Color
    return c.R > 0.72 and c.G < 0.48 and c.B > 0.35
end

local function removePinkOnly()
    local removed = 0
    for _, obj in ipairs(vip:GetDescendants()) do
        if isPinkFloorNeon(obj) then
            obj:Destroy()
            removed += 1
        end
    end
    return removed
end

local function getBoundary()
    local boundary = active:FindFirstChild("FloorBoundaryNeon")
    if not boundary then
        boundary = Instance.new("Model")
        boundary.Name = "FloorBoundaryNeon"
        boundary.Parent = active
    end
    return boundary
end

local function ensureBlueTrim()
    local boundary = getBoundary()
    local repaired = 0

    for _, spec in ipairs(BLUE_SPECS) do
        local keeper = nil
        for _, child in ipairs(boundary:GetChildren()) do
            if child.Name == spec.name and child:IsA("BasePart") then
                if keeper then
                    child:Destroy()
                else
                    keeper = child
                end
            end
        end

        if not keeper then
            keeper = Instance.new("Part")
            keeper.Name = spec.name
            keeper.Parent = boundary
            repaired += 1
        end

        keeper.Size = spec.size
        keeper.CFrame = spec.cf
        keeper.Color = BLUE
        keeper.Material = Enum.Material.Neon
        keeper.Transparency = 0
        keeper.Anchored = true
        keeper.CanCollide = false
        keeper.CanTouch = false
        keeper.CanQuery = true
        keeper.CastShadow = false
        keeper.TopSurface = Enum.SurfaceType.Smooth
        keeper.BottomSurface = Enum.SurfaceType.Smooth

        local glow = keeper:FindFirstChild("NeonWash")
        if not glow or not glow:IsA("SurfaceLight") then
            if glow then glow:Destroy() end
            glow = Instance.new("SurfaceLight")
            glow.Name = "NeonWash"
            glow.Parent = keeper
        end
        glow.Face = Enum.NormalId.Bottom
        glow.Color = BLUE
        glow.Brightness = 0.34
        glow.Range = 6
        glow.Angle = 120
        glow.Shadows = false
    end

    return repaired
end

-- Scripts start in parallel. Guard the finished runtime for several seconds so
-- a late builder cannot recreate the pink floor strips after cleanup.
local totalRemoved = 0
local totalRepaired = 0
for _ = 1, 24 do
    totalRemoved += removePinkOnly()
    totalRepaired += ensureBlueTrim()
    task.wait(0.25)
end

-- One final deterministic pass.
totalRemoved += removePinkOnly()
totalRepaired += ensureBlueTrim()

active:SetAttribute("PinkFloorHardClean", true)
active:SetAttribute("PinkFloorHardCleanRemoved", totalRemoved)
active:SetAttribute("BlueFloorTrimPreserved", true)
active:SetAttribute("BlueFloorTrimRepaired", totalRepaired)
active:SetAttribute("PinkFloorHardCleanScope", "VIP_FLOOR_ONLY_V3")

print(string.format(
    "[BBYA] VIP final neon guard v3: pink removed=%d / blue repaired=%d",
    totalRemoved,
    totalRepaired
))
