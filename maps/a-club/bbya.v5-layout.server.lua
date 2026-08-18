-- BBYA SOCIAL HUB — V5.1 ARCHITECTURAL GREYBOX MASTERPLAN
-- Architecture and circulation ONLY. No furniture, trees, cabana objects, decorative neon rigs, or gameplay UI.
-- Coordinate convention: front/spawn = +Z, rear/stage = -Z.
-- Structural levels: Ground = Y 0, VIP = Y 18, Rooftop = Y 36.
-- Primary design rule: circulation and room hierarchy must work before any decorative layer is allowed.

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local ROOT_NAME = "BBYA V5.1 ARCHITECTURAL GREYBOX"

-- HARD RESET: one architectural source of truth. No stacked venue generations.
for _, obj in ipairs(workspace:GetChildren()) do
	local preserve = obj:IsA("Terrain") or obj.Name == "Camera"
	if obj:IsA("Model") and Players:GetPlayerFromCharacter(obj) then preserve = true end
	if not preserve and (obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("Sound")) then
		obj:Destroy()
	end
end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = workspace

local C = {
	floor = Color3.fromRGB(108,108,114),
	floor2 = Color3.fromRGB(132,132,138),
	wall = Color3.fromRGB(66,66,73),
	wall2 = Color3.fromRGB(82,82,90),
	stair = Color3.fromRGB(96,96,104),
	pink = Color3.fromRGB(255,90,205),
	cyan = Color3.fromRGB(75,220,255),
	gold = Color3.fromRGB(255,205,100),
	green = Color3.fromRGB(110,225,150),
	blue = Color3.fromRGB(100,145,255),
	service = Color3.fromRGB(190,150,85),
	pool = Color3.fromRGB(70,160,210),
}

local function part(name, size, cf, color, material, transparency, collide, parent)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Anchored = true
	p.CanCollide = collide ~= false
	p.CanTouch = false
	p.Material = material or Enum.Material.Concrete
	p.Color = color or C.wall
	p.Transparency = transparency or 0
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent or root
	return p
end

local function label(name, text, cf, size, color, face, parent)
	local p = part(name, size, cf, Color3.fromRGB(38,38,44), Enum.Material.SmoothPlastic, 0, false, parent)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 28
	gui.LightInfluence = 0
	gui.Parent = p
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1,1)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextColor3 = color or C.pink
	t.Font = Enum.Font.GothamBlack
	t.TextScaled = true
	t.TextWrapped = true
	t.Parent = gui
	return p
end

local function zone(name, size, position, color, parent)
	local p = part(name, Vector3.new(size.X,.14,size.Y), CFrame.new(position), color, Enum.Material.SmoothPlastic, .48, false, parent)
	p.CanQuery = false
	return p
end

local function landing(name, position, color, parent)
	return zone(name, Vector2.new(9,9), position, color or C.green, parent)
end

local function wallZ(name, x, z1, z2, y, h, thickness, parent)
	local len = math.abs(z2-z1)
	return part(name, Vector3.new(thickness or 3,h,len), CFrame.new(x,y,(z1+z2)/2), C.wall2, Enum.Material.Concrete, 0, true, parent)
end

local function wallX(name, z, x1, x2, y, h, thickness, parent)
	local len = math.abs(x2-x1)
	return part(name, Vector3.new(len,h,thickness or 3), CFrame.new((x1+x2)/2,y,z), C.wall2, Enum.Material.Concrete, 0, true, parent)
end

local function straightFlight(parent, name, startCF, steps, width, rise, run)
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	for i = 0, steps-1 do
		part(name.." Step "..i, Vector3.new(width,rise+.12,run+.06), startCF*CFrame.new(0,rise*i,-run*i), C.stair, Enum.Material.Concrete, 0, true, f)
	end
	return f
end

-- U-stair: 2 flights, 12 risers per flight, 0.75 stud/riser = 18 studs total floor-to-floor.
-- Clear stair width = 9 studs. Mid landing = 11x11. Entire stair core approx 25x38.
local function uStair(parent, name, centerX, centerZ, fromY)
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	local width, rise, run, steps = 9, .75, 1.4, 12
	local flightRun = run*(steps-1)
	straightFlight(f, name.." FLIGHT A", CFrame.new(centerX-5.2,fromY+.45,centerZ+8), steps, width, rise, run)
	part(name.." MID LANDING", Vector3.new(11,.8,11), CFrame.new(centerX-5.2,fromY+9,centerZ+8-flightRun-4.5), C.floor2, Enum.Material.Concrete, 0, true, f)
	local bStart = CFrame.new(centerX+5.2,fromY+9.45,centerZ+8-flightRun-9)*CFrame.Angles(0,math.rad(180),0)
	straightFlight(f, name.." FLIGHT B", bStart, steps, width, rise, run)
	part(name.." TOP LANDING", Vector3.new(23,.8,12), CFrame.new(centerX,fromY+18,centerZ+7), C.floor2, Enum.Material.Concrete, 0, true, f)
	-- Full-height core side walls define a real stairwell and prevent obby-like edge falls.
	part(name.." CORE WEST", Vector3.new(2,18,39), CFrame.new(centerX-12,fromY+9,centerZ-1), C.wall, Enum.Material.Concrete, 0, true, f)
	part(name.." CORE EAST", Vector3.new(2,18,39), CFrame.new(centerX+12,fromY+9,centerZ-1), C.wall, Enum.Material.Concrete, 0, true, f)
	return f
end

-- Review lighting: neutral enough to inspect proportions and circulation.
Lighting.ClockTime = 18.2
Lighting.Brightness = 2.7
Lighting.ExposureCompensation = .12
Lighting.Ambient = Color3.fromRGB(108,108,118)
Lighting.OutdoorAmbient = Color3.fromRGB(88,90,100)
Lighting.FogStart = 1800
Lighting.FogEnd = 4000
for _, e in ipairs(Lighting:GetChildren()) do
	if e:IsA("BloomEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("Atmosphere") then e:Destroy() end
end

-- =====================================================================
-- MASTER ARCHITECTURAL DIMENSIONS
-- Envelope: 180 studs wide (X -90..90) x 220 studs deep (Z -90..130).
-- Levels: G=0, VIP=18, Roof=36. Ground clear height approx 18.
-- Public corridors: 14 studs minimum. Main entrance: 40 studs clear.
-- Main Club: 108 studs wide x 146 studs deep.
-- Side-room public doorways: 20 studs. Stair-foyer doorways: 18 studs.
-- =====================================================================

-- 01 EXTERIOR / APPROACH ------------------------------------------------
local ext = Instance.new("Folder"); ext.Name = "01 EXTERIOR"; ext.Parent = root
part("EXTERIOR PLAZA", Vector3.new(160,1,54), CFrame.new(0,0,159), C.floor2, Enum.Material.Concrete, 0, true, ext)
part("APPROACH AXIS", Vector3.new(24,.14,54), CFrame.new(0,.58,159), Color3.fromRGB(150,150,155), Enum.Material.Concrete, 0, false, ext)
-- 40-stud exterior entrance opening centered on the building axis.
part("FRONT WALL WEST", Vector3.new(70,24,4), CFrame.new(-55,12,130), C.wall, Enum.Material.Concrete, 0, true, ext)
part("FRONT WALL EAST", Vector3.new(70,24,4), CFrame.new(55,12,130), C.wall, Enum.Material.Concrete, 0, true, ext)
part("FRONT HEADER", Vector3.new(180,6,4), CFrame.new(0,21,130), C.wall, Enum.Material.Concrete, 0, true, ext)
-- Exterior-facing placeholder identity. Back face points toward +Z / spawn.
label("EXTERIOR BBYA IDENTITY", "BBYA SOCIAL HUB\nMAIN ENTRANCE", CFrame.new(0,17,132.25), Vector3.new(38,7,.25), C.pink, Enum.NormalId.Back, ext)
landing("ENTRANCE LANDING", Vector3.new(0,.62,139), C.green, ext)

local spawn = Instance.new("SpawnLocation")
spawn.Name = "BBYA V5 SPAWN"
spawn.Size = Vector3.new(10,1,10)
spawn.CFrame = CFrame.new(0,1,176)*CFrame.Angles(0,math.rad(180),0)
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0
spawn.Material = Enum.Material.SmoothPlastic
spawn.Color = C.green
spawn.Transparency = .2
spawn.Parent = ext

-- 02 GROUND FLOOR --------------------------------------------------------
local g = Instance.new("Folder"); g.Name = "02 GROUND FLOOR"; g.Parent = root
part("GROUND SLAB", Vector3.new(180,1,220), CFrame.new(0,0,20), C.floor, Enum.Material.Concrete, 0, true, g)
part("GROUND WEST EXTERIOR WALL", Vector3.new(4,18,220), CFrame.new(-90,9,20), C.wall, Enum.Material.Concrete, 0, true, g)
part("GROUND EAST EXTERIOR WALL", Vector3.new(4,18,220), CFrame.new(90,9,20), C.wall, Enum.Material.Concrete, 0, true, g)
part("GROUND REAR EXTERIOR WALL", Vector3.new(180,18,4), CFrame.new(0,9,-90), C.wall, Enum.Material.Concrete, 0, true, g)

-- LOBBY: central 120x42. Central axis remains completely empty for orientation.
part("LOBBY WEST DIVIDER", Vector3.new(4,14,42), CFrame.new(-60,7,107), C.wall2, Enum.Material.Concrete, 0, true, g)
part("LOBBY EAST DIVIDER", Vector3.new(4,14,42), CFrame.new(60,7,107), C.wall2, Enum.Material.Concrete, 0, true, g)
label("LOBBY LABEL", "LOBBY", CFrame.new(0,9,86.2), Vector3.new(28,4,.25), C.gold, Enum.NormalId.Front, g)
landing("LOBBY LANDING", Vector3.new(0,.62,106), C.gold, g)

-- Lobby -> Main Club: 40-stud clear central doorway.
wallX("LOBBY CLUB WALL WEST",84,-90,-20,7,14,3,g)
wallX("LOBBY CLUB WALL EAST",84,20,90,7,14,3,g)
label("MAIN CLUB DOOR LABEL", "MAIN CLUB", CFrame.new(0,10,82.3), Vector3.new(25,3,.25), C.pink, Enum.NormalId.Front, g)

-- WEST LOBBY SERVICE / RESTROOM allocation: architecture only.
wallX("WEST SERVICE REAR WALL",94,-88,-62,7,14,3,g)
wallZ("WEST SERVICE EAST WALL",-62,94,124,7,14,3,g)
label("WEST SERVICE LABEL", "RESTROOM / SERVICE", CFrame.new(-75,8,94.1), Vector3.new(22,3,.25), C.service, Enum.NormalId.Front, g)
zone("WEST SERVICE PROGRAM", Vector2.new(24,26), Vector3.new(-75,.62,109), C.service, g)

-- EAST LOBBY = dedicated lift core + waiting foyer.
local lift = Instance.new("Folder"); lift.Name = "LIFT CORE"; lift.Parent = root
part("LIFT SHAFT BACK", Vector3.new(16,54,2), CFrame.new(73,27,116), C.wall2, Enum.Material.Concrete, 0, true, lift)
part("LIFT SHAFT WEST", Vector3.new(2,54,16), CFrame.new(65,27,108), C.wall2, Enum.Material.Concrete, 0, true, lift)
part("LIFT SHAFT EAST", Vector3.new(2,54,16), CFrame.new(81,27,108), C.wall2, Enum.Material.Concrete, 0, true, lift)
label("LIFT GROUND LABEL", "LIFT\nG / VIP / ROOF", CFrame.new(73,7,99.8), Vector3.new(13,7,.25), C.blue, Enum.NormalId.Front, lift)
zone("LIFT GROUND FOYER", Vector2.new(24,18), Vector3.new(72,.62,91), C.blue, g)
landing("LIFT GROUND LANDING", Vector3.new(72,.64,96), C.blue, lift)
landing("LIFT VIP LANDING", Vector3.new(72,18.64,96), C.blue, lift)
landing("LIFT ROOF LANDING", Vector3.new(72,36.64,96), C.blue, lift)

-- MAIN CLUB HALL ---------------------------------------------------------
-- Hall boundary X -54..54, Z -62..84. Side walls are split so doors are REAL openings.
-- Stair doors: Z -34..-16 (18 clear). Bar/Chill doors: Z 48..68 (20 clear).
wallZ("CLUB WEST WALL REAR",-54,-62,-34,9,18,3,g)
wallZ("CLUB WEST WALL MID",-54,-16,48,9,18,3,g)
wallZ("CLUB WEST WALL FRONT",-54,68,84,9,18,3,g)
wallZ("CLUB EAST WALL REAR",54,-62,-34,9,18,3,g)
wallZ("CLUB EAST WALL MID",54,-16,48,9,18,3,g)
wallZ("CLUB EAST WALL FRONT",54,68,84,9,18,3,g)
zone("MAIN CLUB CLEAR FLOOR", Vector2.new(100,118), Vector3.new(0,.62,9), C.pink, g)
landing("DANCE LANDING", Vector3.new(0,.64,14), C.pink, g)
label("MAIN CLUB LABEL", "MAIN CLUB / DANCE", CFrame.new(0,8,-59.8), Vector3.new(38,4,.25), C.pink, Enum.NormalId.Front, g)

-- Stage integrated into rear architecture, leaving a 14-stud circulation strip on each side.
part("STAGE PLATFORM", Vector3.new(76,3,18), CFrame.new(0,1.5,-77), C.wall2, Enum.Material.Concrete, 0, true, g)
label("STAGE LABEL", "DJ / STAGE", CFrame.new(0,7,-86.8), Vector3.new(28,3,.25), C.pink, Enum.NormalId.Front, g)
landing("DJ LANDING", Vector3.new(0,3.7,-63), C.pink, g)

-- WEST BAR ROOM ---------------------------------------------------------
-- Dedicated room: approx 32x50. Two access points: Lobby/front + Main Club.
wallX("BAR REAR WALL",28,-88,-56,7,14,3,g)
wallX("BAR FRONT WALL WEST",78,-88,-79,7,14,3,g)
wallX("BAR FRONT WALL EAST",78,-65,-56,7,14,3,g) -- 14-stud lobby doorway between x -79..-65
label("BAR LOBBY DOOR", "BAR", CFrame.new(-72,8,77.9), Vector3.new(12,3,.25), C.gold, Enum.NormalId.Front, g)
zone("BAR PROGRAM", Vector2.new(28,44), Vector3.new(-72,.62,52), C.gold, g)
landing("BAR LANDING", Vector3.new(-72,.64,60), C.gold, g)

-- EAST CHILL LOUNGE -----------------------------------------------------
-- Same footprint as bar, but acoustically separated from the dance hall.
wallX("CHILL REAR WALL",28,56,88,7,14,3,g)
wallX("CHILL FRONT WALL WEST",78,56,65,7,14,3,g)
wallX("CHILL FRONT WALL EAST",78,79,88,7,14,3,g) -- 14-stud lobby doorway between x 65..79
label("CHILL LOBBY DOOR", "CHILL LOUNGE", CFrame.new(72,8,77.9), Vector3.new(17,3,.25), C.cyan, Enum.NormalId.Front, g)
zone("CHILL PROGRAM", Vector2.new(28,44), Vector3.new(72,.62,52), C.cyan, g)
landing("CHILL LANDING", Vector3.new(72,.64,60), C.cyan, g)

-- REAR STAIR FOYERS -----------------------------------------------------
-- Doors in club side walls at Z -34..-16 lead to proper side stair halls.
local stairs = Instance.new("Folder"); stairs.Name = "STAIR CORES"; stairs.Parent = root
zone("WEST STAIR FOYER", Vector2.new(28,24), Vector3.new(-70,.62,-24), C.blue, stairs)
zone("EAST STAIR FOYER", Vector2.new(28,24), Vector3.new(70,.62,-24), C.blue, stairs)
label("WEST STAIR LABEL", "STAIR\nVIP / ROOF", CFrame.new(-55.3,7,-25), Vector3.new(.25,7,16), C.blue, Enum.NormalId.Left, stairs)
label("EAST STAIR LABEL", "STAIR\nVIP / ROOF", CFrame.new(55.3,7,-25), Vector3.new(.25,7,16), C.blue, Enum.NormalId.Right, stairs)
uStair(stairs,"WEST STAIR G-VIP",-70,-24,0)
uStair(stairs,"EAST STAIR G-VIP",70,-24,0)
uStair(stairs,"WEST STAIR VIP-ROOF",-70,-24,18)
uStair(stairs,"EAST STAIR VIP-ROOF",70,-24,18)

-- BACK-OF-HOUSE reservation beside stage; not public decor.
zone("BACKSTAGE WEST PROGRAM", Vector2.new(26,18), Vector3.new(-68,.62,-75), C.service, g)
zone("BACKSTAGE EAST PROGRAM", Vector2.new(26,18), Vector3.new(68,.62,-75), C.service, g)

-- 03 VIP LEVEL -----------------------------------------------------------
local vip = Instance.new("Folder"); vip.Name = "03 VIP LEVEL"; vip.Parent = root
-- Side mezzanines align with service bands. Center remains open to the dance floor.
part("VIP WEST MEZZANINE", Vector3.new(34,1,150), CFrame.new(-72,18,10), C.floor2, Enum.Material.Concrete, 0, true, vip)
part("VIP EAST MEZZANINE", Vector3.new(34,1,150), CFrame.new(72,18,10), C.floor2, Enum.Material.Concrete, 0, true, vip)
-- Front bridge connects lift and both mezzanines without covering the dance-floor void.
part("VIP FRONT BRIDGE", Vector3.new(108,1,16), CFrame.new(0,18,88), C.floor2, Enum.Material.Concrete, 0, true, vip)
-- Rear bridge creates a coherent loop and supports the private/Queen zone.
part("VIP REAR BRIDGE", Vector3.new(108,1,18), CFrame.new(0,18,-69), C.floor2, Enum.Material.Concrete, 0, true, vip)
-- Architectural safety parapets along the central void.
part("VIP WEST INNER PARAPET", Vector3.new(2,3,132), CFrame.new(-55,19.5,3), C.wall2, Enum.Material.Concrete, 0, true, vip)
part("VIP EAST INNER PARAPET", Vector3.new(2,3,132), CFrame.new(55,19.5,3), C.wall2, Enum.Material.Concrete, 0, true, vip)
zone("VIP WEST PROGRAM", Vector2.new(28,118), Vector3.new(-72,18.62,5), C.gold, vip)
zone("VIP EAST PROGRAM", Vector2.new(28,118), Vector3.new(72,18.62,5), C.gold, vip)
landing("VIP WEST LANDING", Vector3.new(-70,18.64,-17), C.gold, vip)
landing("VIP EAST LANDING", Vector3.new(70,18.64,-17), C.gold, vip)
label("VIP WEST LABEL", "VIP WEST", CFrame.new(-54.2,23,18), Vector3.new(.25,4,15), C.gold, Enum.NormalId.Left, vip)
label("VIP EAST LABEL", "VIP EAST", CFrame.new(54.2,23,18), Vector3.new(.25,4,15), C.gold, Enum.NormalId.Right, vip)

-- Queen/private room reservation on rear bridge; decor comes later.
zone("QUEEN PRIVATE PROGRAM", Vector2.new(42,16), Vector3.new(0,18.64,-69), C.gold, vip)
label("QUEEN PRIVATE LABEL", "QUEEN / PRIVATE", CFrame.new(0,23,-78), Vector3.new(28,3,.25), C.gold, Enum.NormalId.Front, vip)
landing("QUEEN LANDING", Vector3.new(0,18.66,-62), C.gold, vip)
-- VIP service/restroom reservation opposite lift foyer.
zone("VIP SERVICE PROGRAM", Vector2.new(24,18), Vector3.new(-72,18.64,96), C.service, vip)
zone("VIP LIFT FOYER", Vector2.new(24,18), Vector3.new(72,18.64,96), C.blue, vip)

-- 04 ROOFTOP ------------------------------------------------------------
local roof = Instance.new("Folder"); roof.Name = "04 ROOFTOP"; roof.Parent = root
part("ROOFTOP SLAB", Vector3.new(180,1,200), CFrame.new(0,36,20), C.floor2, Enum.Material.Concrete, 0, true, roof)
part("ROOF WEST PARAPET", Vector3.new(2,4,200), CFrame.new(-89,38,20), C.wall2, Enum.Material.Concrete, 0, true, roof)
part("ROOF EAST PARAPET", Vector3.new(2,4,200), CFrame.new(89,38,20), C.wall2, Enum.Material.Concrete, 0, true, roof)
part("ROOF REAR PARAPET", Vector3.new(180,4,2), CFrame.new(0,38,-80), C.wall2, Enum.Material.Concrete, 0, true, roof)
part("ROOF FRONT PARAPET", Vector3.new(180,4,2), CFrame.new(0,38,120), C.wall2, Enum.Material.Concrete, 0, true, roof)

-- Rooftop circulation first: central 16-stud spine + two 14-stud cross connectors.
zone("ROOF CENTRAL SPINE", Vector2.new(16,174), Vector3.new(0,36.64,18), Color3.fromRGB(165,165,170), roof)
zone("ROOF STAIR CROSS AXIS", Vector2.new(164,14), Vector3.new(0,36.66,-17), Color3.fromRGB(165,165,170), roof)
zone("ROOF LIFT CROSS AXIS", Vector2.new(164,14), Vector3.new(0,36.66,96), Color3.fromRGB(165,165,170), roof)
zone("ROOFTOP ARRIVAL PLAZA", Vector2.new(42,22), Vector3.new(0,36.68,96), C.green, roof)
landing("ROOFTOP MAIN LANDING", Vector3.new(0,36.7,96), C.green, roof)
label("ROOFTOP ORIENTATION", "ROOFTOP ARRIVAL", CFrame.new(0,42,84), Vector3.new(30,3,.25), C.green, Enum.NormalId.Front, roof)

-- PROGRAM ZONING ONLY — no furniture/assets yet.
-- Pool stays central/rear to preserve skyline sightline and keep wet zone away from lift arrivals.
zone("POOL PROGRAM ZONE", Vector2.new(76,42), Vector3.new(0,36.72,-43), C.pool, roof)
-- 12+ stud circulation remains around pool footprint before future deck/furniture placement.
zone("SKY BAR PROGRAM ZONE", Vector2.new(40,34), Vector3.new(-58,36.72,43), C.gold, roof)
zone("ROOFTOP CHILL PROGRAM ZONE", Vector2.new(40,34), Vector3.new(58,36.72,43), C.cyan, roof)
zone("WEST CABANA PROGRAM ZONE", Vector2.new(30,24), Vector3.new(-62,36.72,-40), Color3.fromRGB(205,170,120), roof)
zone("EAST CABANA PROGRAM ZONE", Vector2.new(30,24), Vector3.new(62,36.72,-40), Color3.fromRGB(205,170,120), roof)
zone("SUNSET SOCIAL DECK", Vector2.new(48,28), Vector3.new(0,36.72,42), C.green, roof)
zone("PHOTO / VIEW DECK", Vector2.new(48,18), Vector3.new(0,36.72,108), C.pink, roof)

-- Explicit architectural status for future validators and playtest screenshots.
workspace:SetAttribute("BBYAV5Layout","5.1-architectural-masterplan")
workspace:SetAttribute("BBYAV5Decor",false)
workspace:SetAttribute("BBYAV5Levels","0/18/36")
workspace:SetAttribute("BBYAV5MainCorridorWidth",14)
workspace:SetAttribute("BBYAV5EntranceWidth",40)
workspace:SetAttribute("BBYAV5ClubDoorWidth",40)
workspace:SetAttribute("BBYAV5StairWidth",9)
workspace:SetAttribute("BBYAV5LiftCore","16x16 / G-VIP-ROOF")
workspace:SetAttribute("BBYAV5ArchitecturePhase","PHASE_A")
print("[BBYA] V5.1 ARCHITECTURAL MASTERPLAN loaded — circulation/room hierarchy locked, decor OFF")
