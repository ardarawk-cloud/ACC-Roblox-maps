-- BBYA SOCIAL HUB — PHOTO STUDIO LIGHTING UPGRADE v1
-- Turns the Floor 1 photo area into an actual bright photo studio.
-- Adds recognizable key/fill softboxes, rim lights and a soft overhead source.

local Workspace = game:GetService("Workspace")
local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then return end
local front = root:WaitForChild("Floor1FrontPremium", 30)
if not front then return end
local photo = front:WaitForChild("PhotoAreaPremium", 30)
if not photo then return end

task.wait(0.3)
local old = photo:FindFirstChild("PhotoStudioLightingUpgrade")
if old then old:Destroy() end

local out = Instance.new("Model")
out.Name = "PhotoStudioLightingUpgrade"
out:SetAttribute("Pass", "PHOTO_STUDIO_LIGHTING_V1")
out:SetAttribute("SoftboxCount", 4)
out:SetAttribute("NoDarkPhotoZone", true)
out.Parent = photo

local WHITE = Color3.fromRGB(255, 247, 235)
local BLACK = Color3.fromRGB(18, 18, 21)
local METAL = Color3.fromRGB(67, 67, 72)

local function part(name, size, cf, color, material, transparency, collide, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color or BLACK
    p.Material = material or Enum.Material.SmoothPlastic
    p.Transparency = transparency or 0
    p.Anchored = true
    p.CanCollide = collide == true
    p.CanTouch = false
    p.CanQuery = true
    p.CastShadow = material ~= Enum.Material.Neon
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent or out
    return p
end

local function cylinder(name, size, cf, color, parent)
    local p = part(name, size, cf, color, Enum.Material.Metal, 0, false, parent)
    p.Shape = Enum.PartType.Cylinder
    return p
end

local function lightPanel(parent, name, cf, size, brightness, range)
    local panel = part(name, size, cf, WHITE, Enum.Material.Neon, 0, false, parent)
    panel.CastShadow = false
    local s = Instance.new("SurfaceLight")
    s.Name = "StudioSoftLight"
    s.Face = Enum.NormalId.Front
    s.Color = WHITE
    s.Brightness = brightness
    s.Range = range
    s.Angle = 120
    s.Shadows = false
    s.Parent = panel
    return panel
end

local function softbox(name, pos, target, panelSize)
    local m = Instance.new("Model")
    m.Name = name
    m.Parent = out

    local look = CFrame.lookAt(pos, target)
    local right = look.RightVector
    local baseY = 1.05
    local standTopY = pos.Y - panelSize.Y * 0.5
    local standH = math.max(2.4, standTopY - baseY)

    -- Tripod base.
    cylinder("StandPole", Vector3.new(standH, .18, .18), CFrame.new(pos.X, baseY + standH/2, pos.Z) * CFrame.Angles(0,0,math.rad(90)), METAL, m)
    for i, angle in ipairs({-45, 45, 180}) do
        local a = math.rad(angle)
        local foot = Vector3.new(pos.X + math.sin(a)*1.15, .22, pos.Z + math.cos(a)*1.15)
        local mid = Vector3.new((pos.X+foot.X)/2, .38, (pos.Z+foot.Z)/2)
        local len = (Vector3.new(pos.X,.38,pos.Z)-Vector3.new(foot.X,.38,foot.Z)).Magnitude
        part("TripodLeg"..i, Vector3.new(.12,.12,len), CFrame.lookAt(mid, Vector3.new(foot.X,.38,foot.Z)), METAL, Enum.Material.Metal, 0, false, m)
    end

    -- Softbox housing and diffusion panel.
    part("SoftboxHousing", panelSize + Vector3.new(.55,.55,.45), look, BLACK, Enum.Material.Metal, 0, false, m)
    local face = lightPanel(m, "DiffusionPanel", look * CFrame.new(0,0,-(panelSize.Z/2+.28)), panelSize, 2.7, 30)
    face:SetAttribute("PhotoStudioFixture", true)

    -- Back yoke so fixture reads as proper studio equipment.
    part("Yoke", Vector3.new(panelSize.X*.68,.16,.16), CFrame.new(pos + right*(panelSize.X*.02)), METAL, Enum.Material.Metal, 0, false, m)
end

-- Main shooting position is in front of the photo wall around X=-42, Z=-25.
local subject = Vector3.new(-42.0, 4.0, -25.0)
softbox("KeySoftbox",  Vector3.new(-35.0, 7.6, -18.0), subject, Vector3.new(5.2,3.8,.18))
softbox("FillSoftbox", Vector3.new(-35.0, 6.7, -32.0), subject, Vector3.new(4.6,3.4,.18))
softbox("RimSoftboxL", Vector3.new(-47.0, 7.8, -17.8), subject, Vector3.new(3.2,2.4,.16))
softbox("RimSoftboxR", Vector3.new(-47.0, 7.8, -32.2), subject, Vector3.new(3.2,2.4,.16))

-- Large overhead source to make the entire shooting zone readable on mobile.
local overhead = lightPanel(
    out,
    "OverheadStudioPanel",
    CFrame.new(-41.5, 12.45, -25) * CFrame.Angles(math.rad(90),0,0),
    Vector3.new(12, 6, .18),
    1.8,
    28
)
local overheadGlow = Instance.new("PointLight")
overheadGlow.Name = "StudioAmbientFill"
overheadGlow.Color = WHITE
overheadGlow.Brightness = 1.35
overheadGlow.Range = 28
overheadGlow.Shadows = false
overheadGlow.Parent = overhead

-- Small floor bounce cards add recognizable studio detail without clutter.
for i,z in ipairs({-20.5,-29.5}) do
    local card = part("BounceCard"..i, Vector3.new(.18,3.3,2.8), CFrame.new(-32.5,2.35,z)*CFrame.Angles(0,math.rad(90),math.rad(-7)), Color3.fromRGB(232,232,232), Enum.Material.SmoothPlastic, 0, false, out)
    card.Reflectance = .05
end

print("[BBYA] Photo Studio lighting v1 online: 4 softboxes + overhead fill")
