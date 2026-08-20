-- BBYA SOCIAL HUB — TRUE 3D FRONT FACADE SIGNAGE v1.0
-- Replaces the flat SurfaceGui hero signage on the v4.9 facade with real extruded Parts.
-- User lock: BBYA larger, SOCIAL HUB larger/closer, and "24 / 7" with spaces around slash.

local ROOT_NAME = "BBYA Front Facade 3D Signage v1"

-- Let the late front-lobby rebuild finish first.
task.wait(9)

local oldRoot = workspace:FindFirstChild(ROOT_NAME)
if oldRoot then oldRoot:Destroy() end

local frontLobby
for _ = 1, 20 do
    frontLobby = workspace:FindFirstChild("BBYA Front Lobby v4.9")
    if frontLobby then break end
    task.wait(1)
end

if not frontLobby then
    warn("[BBYA 3D Signage] BBYA Front Lobby v4.9 not found; signage skipped")
    return
end

local facade = frontLobby:FindFirstChild("02 BBYA Neon Facade")
if not facade then
    warn("[BBYA 3D Signage] 02 BBYA Neon Facade not found; signage skipped")
    return
end

-- Remove the old flat sign plates only. Crown/facade geometry stays untouched.
for _, name in ipairs({"BBYA Hero", "BBYA Social Hub", "BBYA 24 7", ROOT_NAME}) do
    local old = facade:FindFirstChild(name)
    if old then old:Destroy() end
end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = facade

local PINK_FACE = Color3.fromRGB(255, 105, 220)
local PINK_EDGE = Color3.fromRGB(108, 23, 86)
local SOFT_FACE = Color3.fromRGB(255, 151, 225)
local SOFT_EDGE = Color3.fromRGB(92, 30, 76)

-- Normalized single-stroke glyphs. Every visible stroke becomes a real 3D bar.
-- Coordinates: x 0..1, y 0..1, bottom-left origin.
local G = {
    B = {
        {0,0,0,1},{0,1,0.72,1},{0,0.5,0.72,0.5},{0,0,0.72,0},
        {0.72,1,0.92,0.78},{0.92,0.78,0.92,0.58},{0.92,0.58,0.72,0.5},
        {0.72,0.5,0.94,0.34},{0.94,0.34,0.94,0.16},{0.94,0.16,0.72,0},
    },
    Y = {{0,1,0.5,0.54},{1,1,0.5,0.54},{0.5,0.54,0.5,0}},
    A = {{0,0,0.5,1},{0.5,1,1,0},{0.22,0.43,0.78,0.43}},
    S = {{0.08,1,0.95,1},{0.08,1,0.02,0.58},{0.02,0.58,0.9,0.5},{0.9,0.5,0.98,0},{0.98,0,0.08,0}},
    O = {{0.08,1,0.92,1},{0.92,1,0.92,0},{0.92,0,0.08,0},{0.08,0,0.08,1}},
    C = {{0.92,1,0.08,1},{0.08,1,0.08,0},{0.08,0,0.92,0}},
    I = {{0.08,1,0.92,1},{0.5,1,0.5,0},{0.08,0,0.92,0}},
    L = {{0.08,1,0.08,0},{0.08,0,0.92,0}},
    H = {{0.08,1,0.08,0},{0.92,1,0.92,0},{0.08,0.5,0.92,0.5}},
    U = {{0.08,1,0.08,0.15},{0.92,1,0.92,0.15},{0.08,0.15,0.25,0},{0.25,0,0.75,0},{0.75,0,0.92,0.15}},
    ["2"] = {{0.06,1,0.88,1},{0.88,1,0.94,0.55},{0.94,0.55,0.06,0},{0.06,0,0.94,0}},
    ["4"] = {{0.78,1,0.78,0},{0.78,1,0.08,0.43},{0.08,0.43,0.98,0.43}},
    ["7"] = {{0.05,1,0.95,1},{0.95,1,0.28,0}},
    ["/"] = {{0.08,0,0.92,1}},
}

local function bar(parent, name, x1, y1, x2, y2, centerX, centerY, z, glyphW, glyphH, stroke, depth, color, material)
    local ax = centerX + (x1 - 0.5) * glyphW
    local ay = centerY + (y1 - 0.5) * glyphH
    local bx = centerX + (x2 - 0.5) * glyphW
    local by = centerY + (y2 - 0.5) * glyphH
    local dx, dy = bx - ax, by - ay
    local length = math.sqrt(dx*dx + dy*dy)
    local angle = math.atan2(dy, dx)

    local p = Instance.new("Part")
    p.Name = name
    p.Size = Vector3.new(length + stroke * 0.12, stroke, depth)
    p.CFrame = CFrame.new((ax+bx)/2, (ay+by)/2, z) * CFrame.Angles(0,0,angle)
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = false
    p.Material = material
    p.Color = color
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function renderWord(name, text, centerX, centerY, glyphW, glyphH, spacing, faceColor, edgeColor)
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = root

    local widths = {}
    local total = 0
    for i = 1, #text do
        local ch = text:sub(i,i)
        local w = (ch == " ") and glyphW * 0.48 or glyphW
        widths[i] = w
        total += w
        if i < #text then total += spacing end
    end

    local cursor = centerX - total/2
    for i = 1, #text do
        local ch = text:sub(i,i)
        local w = widths[i]
        if ch ~= " " then
            local glyph = G[ch]
            if glyph then
                local cx = cursor + w/2
                local charModel = Instance.new("Model")
                charModel.Name = ch .. "_" .. i
                charModel.Parent = model

                local stroke = math.max(0.34, glyphH * 0.115)
                for s, seg in ipairs(glyph) do
                    -- Deep dark-magenta extrusion/backing starts at facade face.
                    bar(charModel, "Extrusion_"..s, seg[1],seg[2],seg[3],seg[4], cx,centerY, 76.10, w,glyphH, stroke*1.18, 1.05, edgeColor, Enum.Material.Metal)
                    -- Thin neon cap sits physically forward, giving a genuine raised face.
                    bar(charModel, "NeonFace_"..s, seg[1],seg[2],seg[3],seg[4], cx,centerY, 75.48, w,glyphH, stroke, 0.30, faceColor, Enum.Material.Neon)
                end
            end
        end
        cursor += w + spacing
    end

    return model
end

-- Compact vertical stack: larger than previous flat labels, but lines sit closer together.
renderWord("BBYA 3D", "BBYA", 0, 28.7, 11.8, 9.8, 2.0, PINK_FACE, PINK_EDGE)
renderWord("SOCIAL HUB 3D", "SOCIAL HUB", 0, 20.9, 4.55, 4.2, 0.85, SOFT_FACE, SOFT_EDGE)
renderWord("24 / 7 3D", "24 / 7", 0, 16.9, 3.55, 3.1, 0.72, PINK_FACE, PINK_EDGE)

-- A restrained halo behind the 3D stack; one light only, not one per letter.
local haloAnchor = Instance.new("Part")
haloAnchor.Name = "3D Sign Halo"
haloAnchor.Size = Vector3.new(0.2,0.2,0.2)
haloAnchor.CFrame = CFrame.new(0,23.5,76.35)
haloAnchor.Anchored = true
haloAnchor.CanCollide = false
haloAnchor.CanTouch = false
haloAnchor.CanQuery = false
haloAnchor.Transparency = 1
haloAnchor.Parent = root

local halo = Instance.new("PointLight")
halo.Color = PINK_FACE
halo.Brightness = 0.55
halo.Range = 17
halo.Shadows = false
halo.Parent = haloAnchor

print("[BBYA] True 3D front facade signage loaded: BBYA / SOCIAL HUB / 24 / 7")
