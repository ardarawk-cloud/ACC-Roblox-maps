-- BBYA SOCIAL HUB — VIP WHITE TRIANGLE CEILING NETWORK v1
-- Replaces the single colored VIP ceiling triangle with a dense irregular
-- network of WHITE triangle fixtures inspired by club truss/neon geometry.
-- No unrelated ceiling strip lines and no small square white downlights.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then return end

local upper = root:WaitForChild("UpperLevels", 30)
if not upper then return end

local vip = upper:WaitForChild("L2_VIP_Level", 30)
if not vip then return end

local activeVIP = vip:WaitForChild("VIPMinimalStanding", 30)
if not activeVIP then return end

-- Wait for the v5 pass to finish creating its original single triangle,
-- then replace only that ceiling-light model.
local oldSingle = activeVIP:WaitForChild("TriangleCeilingLight", 20)
if oldSingle then
    oldSingle:Destroy()
end

local oldNetwork = activeVIP:FindFirstChild("TriangleCeilingNetwork")
if oldNetwork then
    oldNetwork:Destroy()
end

local out = Instance.new("Model")
out.Name = "TriangleCeilingNetwork"
out:SetAttribute("Pass", "VIP_WHITE_TRIANGLE_NETWORK_V1")
out:SetAttribute("WhiteOnly", true)
out:SetAttribute("NoStandaloneCeilingStrips", true)
out:SetAttribute("NoSmallSquareDownlights", true)
out.Parent = activeVIP

local WHITE = Color3.fromRGB(248, 250, 255)
local DARK = Color3.fromRGB(16, 16, 19)
local TRI_Y = 43.48

local function part(name, size, cf, color, material, transparency, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = material
    p.Transparency = transparency or 0
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = true
    p.CastShadow = material ~= Enum.Material.Neon
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function neonBeam(name, a, b)
    local delta = b - a
    local length = delta.Magnitude
    local mid = (a + b) / 2
    local cf = CFrame.lookAt(mid, b) * CFrame.Angles(0, math.rad(90), 0)

    local beam = part(
        name,
        Vector3.new(length, 0.18, 0.28),
        cf,
        WHITE,
        Enum.Material.Neon,
        0,
        out
    )
    beam.CastShadow = false

    -- Soft wash comes from the triangle tubes themselves; there are no separate
    -- visible ceiling downlight fixtures.
    local glow = Instance.new("SurfaceLight")
    glow.Name = "WhiteTubeWash"
    glow.Face = Enum.NormalId.Bottom
    glow.Color = WHITE
    glow.Brightness = 0.34
    glow.Range = 8
    glow.Angle = 120
    glow.Shadows = false
    glow.Parent = beam

    return beam
end

-- Irregular ceiling vertices spanning the VIP footprint. The layout deliberately
-- avoids a uniform grid so it reads like the reference club's connected triangles.
local V = {
    A = Vector3.new(-54, TRI_Y, -34),
    B = Vector3.new(-34, TRI_Y, -36),
    C = Vector3.new(-45, TRI_Y, -15),
    D = Vector3.new(-15, TRI_Y, -30),
    E = Vector3.new(-22, TRI_Y, -10),
    F = Vector3.new(8, TRI_Y, -34),
    G = Vector3.new(3, TRI_Y, -8),
    H = Vector3.new(30, TRI_Y, -31),
    I = Vector3.new(22, TRI_Y, -9),
    J = Vector3.new(53, TRI_Y, -30),
    K = Vector3.new(45, TRI_Y, -7),
    L = Vector3.new(-52, TRI_Y, 12),
    M = Vector3.new(-31, TRI_Y, 10),
    N = Vector3.new(-42, TRI_Y, 34),
    O = Vector3.new(-10, TRI_Y, 16),
    P = Vector3.new(-18, TRI_Y, 36),
    Q = Vector3.new(13, TRI_Y, 13),
    R = Vector3.new(8, TRI_Y, 36),
    S = Vector3.new(35, TRI_Y, 11),
    T = Vector3.new(29, TRI_Y, 35),
    U = Vector3.new(53, TRI_Y, 17),
}

-- Many connected triangles; shared edges are instantiated only once.
local triangles = {
    {"A", "B", "C"},
    {"B", "D", "C"},
    {"C", "D", "E"},
    {"D", "F", "E"},
    {"E", "F", "G"},
    {"F", "H", "G"},
    {"G", "H", "I"},
    {"H", "J", "I"},
    {"I", "J", "K"},
    {"C", "E", "L"},
    {"L", "E", "M"},
    {"L", "M", "N"},
    {"M", "O", "N"},
    {"N", "O", "P"},
    {"E", "G", "M"},
    {"M", "G", "O"},
    {"G", "Q", "O"},
    {"G", "I", "Q"},
    {"Q", "I", "S"},
    {"I", "K", "S"},
    {"O", "Q", "R"},
    {"O", "R", "P"},
    {"Q", "S", "R"},
    {"R", "S", "T"},
    {"S", "K", "U"},
    {"S", "U", "T"},
}

local createdEdges = {}
local edgeCount = 0

local function edgeKey(aName, bName)
    if aName < bName then
        return aName .. "_" .. bName
    end
    return bName .. "_" .. aName
end

local function addEdge(aName, bName)
    local key = edgeKey(aName, bName)
    if createdEdges[key] then return end
    createdEdges[key] = true
    edgeCount += 1
    neonBeam("TriangleTube_" .. key, V[aName], V[bName])
end

for _, tri in ipairs(triangles) do
    addEdge(tri[1], tri[2])
    addEdge(tri[2], tri[3])
    addEdge(tri[3], tri[1])
end

-- Small dark ceiling anchors at network vertices. These are mounts, not lights.
for name, pos in pairs(V) do
    part(
        "Mount_" .. name,
        Vector3.new(0.48, 0.26, 0.48),
        CFrame.new(pos),
        DARK,
        Enum.Material.Metal,
        0,
        out
    )
end

activeVIP:SetAttribute("TriangleFixtureCount", #triangles)
activeVIP:SetAttribute("TriangleBeamCount", edgeCount)
activeVIP:SetAttribute("TriangleCeilingColor", "White")
activeVIP:SetAttribute("LightingLayout", "Dense irregular white triangle ceiling network + floor boundary neon")

out:SetAttribute("TriangleCount", #triangles)
out:SetAttribute("BeamCount", edgeCount)

print(string.format(
    "[BBYA] VIP white triangle network online: %d triangles / %d unique white tubes",
    #triangles,
    edgeCount
))
