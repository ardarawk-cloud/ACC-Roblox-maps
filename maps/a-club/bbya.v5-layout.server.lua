-- BBYA SOCIAL HUB — V5 ARCHITECTURAL GREYBOX
-- Architecture/circulation only. NO furniture, trees, decorative lighting, UI props, or visual clutter.
-- Coordinate convention: front/spawn = +Z, rear/stage = -Z.
-- Levels: Ground = Y 0, VIP = Y 18, Rooftop = Y 36.

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local ROOT_NAME = "BBYA V5 ARCHITECTURAL GREYBOX"

-- HARD RESET: remove all prior venue geometry/runtime folders before rebuilding.
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
	floor = Color3.fromRGB(110,110,116),
	floor2 = Color3.fromRGB(132,132,138),
	wall = Color3.fromRGB(65,65,72),
	wall2 = Color3.fromRGB(82,82,90),
	stair = Color3.fromRGB(92,92,100),
	pink = Color3.fromRGB(255,90,205),
	cyan = Color3.fromRGB(75,220,255),
	gold = Color3.fromRGB(255,205,100),
	green = Color3.fromRGB(110,225,150),
	blue = Color3.fromRGB(100,145,255),
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
	local p = part(name, size, cf, Color3.fromRGB(36,36,42), Enum.Material.SmoothPlastic, 0, false, parent)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 30
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

local function marker(name, position, color, parent)
	local p = part(name, Vector3.new(8,.18,8), CFrame.new(position), color or C.green, Enum.Material.Neon, .45, false, parent)
	p.CanQuery = false
	return p
end

local function straightFlight(parent, name, startCF, steps, width, rise, run)
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	for i = 0, steps-1 do
		part(name.." Step "..i, Vector3.new(width, rise+.12, run+.06), startCF*CFrame.new(0, rise*i, -run*i), C.stair, Enum.Material.Concrete, 0, true, f)
	end
	return f
end

-- U-shaped stair: 12 steps + landing + 12 steps = exactly 18 studs rise.
local function uStair(parent, name, centerX, centerZ, fromY)
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	local width = 9
	local rise = .75
	local run = 1.4
	local steps = 12
	local flightRun = run*(steps-1)
	-- Flight A travels north (-Z) and rises 9 studs.
	straightFlight(f, name.." A", CFrame.new(centerX-5.2, fromY+.45, centerZ+8), steps, width, rise, run)
	-- Mid landing, 11 x 11.
	part(name.." Mid Landing", Vector3.new(11,.8,11), CFrame.new(centerX-5.2, fromY+9, centerZ+8-flightRun-4.5), C.floor2, Enum.Material.Concrete, 0, true, f)
	-- Flight B returns south (+Z), offset to the other side; rotate 180 degrees.
	local bStart = CFrame.new(centerX+5.2, fromY+9.45, centerZ+8-flightRun-9) * CFrame.Angles(0, math.rad(180), 0)
	straightFlight(f, name.." B", bStart, steps, width, rise, run)
	-- Top landing.
	part(name.." Top Landing", Vector3.new(22,.8,12), CFrame.new(centerX, fromY+18, centerZ+7), C.floor2, Enum.Material.Concrete, 0, true, f)
	-- Side guard walls, not obby rails.
	part(name.." Core West", Vector3.new(2,18,38), CFrame.new(centerX-11.5, fromY+9, centerZ-1), C.wall2, Enum.Material.Concrete, 0, true, f)
	part(name.." Core East", Vector3.new(2,18,38), CFrame.new(centerX+11.5, fromY+9, centerZ-1), C.wall2, Enum.Material.Concrete, 0, true, f)
	return f
end

-- Neutral daytime/early-evening review light so circulation is obvious.
Lighting.ClockTime = 18.2
Lighting.Brightness = 2.6
Lighting.ExposureCompensation = .12
Lighting.Ambient = Color3.fromRGB(105,105,115)
Lighting.OutdoorAmbient = Color3.fromRGB(85,88,98)
Lighting.FogStart = 1500
Lighting.FogEnd = 3500
for _, e in ipairs(Lighting:GetChildren()) do
	if e:IsA("BloomEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("Atmosphere") then e:Destroy() end
end

-- =====================================================================
-- MASTER DIMENSIONS
-- Building shell: 180 wide (X -90..90), 220 deep (Z -90..130)
-- Ground clear height: 18 studs. VIP to roof: 18 studs.
-- Main public corridors: 14+ studs. Doors: 16–36 studs.
-- =====================================================================

-- 01 EXTERIOR / APPROACH ------------------------------------------------
local ext = Instance.new("Folder"); ext.Name = "01 Exterior"; ext.Parent = root
part("Exterior Plaza", Vector3.new(160,1,50), CFrame.new(0,0,157), C.floor2, Enum.Material.Concrete, 0, true, ext)
part("Approach Walk", Vector3.new(24,.15,52), CFrame.new(0,.58,157), Color3.fromRGB(145,145,150), Enum.Material.Concrete, 0, false, ext)
-- Front facade: 36-stud central opening.
part("Front Wall L", Vector3.new(72,24,4), CFrame.new(-54,12,130), C.wall, Enum.Material.Concrete, 0, true, ext)
part("Front Wall R", Vector3.new(72,24,4), CFrame.new(54,12,130), C.wall, Enum.Material.Concrete, 0, true, ext)
part("Front Header", Vector3.new(180,6,4), CFrame.new(0,21,130), C.wall, Enum.Material.Concrete, 0, true, ext)
label("Entrance Label", "MAIN ENTRANCE", CFrame.new(0,17,127.8), Vector3.new(34,4,.25), C.pink, Enum.NormalId.Front, ext)
marker("ENTRANCE LANDING", Vector3.new(0,.62,139), C.green, ext)

local spawn = Instance.new("SpawnLocation")
spawn.Name = "BBYA V5 SPAWN"
spawn.Size = Vector3.new(10,1,10)
spawn.CFrame = CFrame.new(0,1,173)*CFrame.Angles(0,math.rad(180),0)
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0
spawn.Material = Enum.Material.Neon
spawn.Color = C.green
spawn.Transparency = .25
spawn.Parent = ext

-- 02 GROUND FLOOR --------------------------------------------------------
local g = Instance.new("Folder"); g.Name = "02 Ground Floor"; g.Parent = root
part("Ground Slab", Vector3.new(180,1,220), CFrame.new(0,0,20), C.floor, Enum.Material.Concrete, 0, true, g)
part("Ground West Wall", Vector3.new(4,18,220), CFrame.new(-90,9,20), C.wall, Enum.Material.Concrete, 0, true, g)
part("Ground East Wall", Vector3.new(4,18,220), CFrame.new(90,9,20), C.wall, Enum.Material.Concrete, 0, true, g)
part("Ground Rear Wall", Vector3.new(180,18,4), CFrame.new(0,9,-90), C.wall, Enum.Material.Concrete, 0, true, g)

-- Lobby: 120 wide x 42 deep, Z 86..128.
part("Lobby West Divider", Vector3.new(4,14,42), CFrame.new(-60,7,107), C.wall2, Enum.Material.Concrete, 0, true, g)
part("Lobby East Divider", Vector3.new(4,14,42), CFrame.new(60,7,107), C.wall2, Enum.Material.Concrete, 0, true, g)
label("Lobby Label", "LOBBY", CFrame.new(0,9,85.5), Vector3.new(28,4,.25), C.gold, Enum.NormalId.Front, g)
marker("LOBBY LANDING", Vector3.new(0,.62,106), C.gold, g)

-- Lobby -> main club divider leaves a clear 36-stud central doorway.
part("Lobby Club Divider L", Vector3.new(72,14,3), CFrame.new(-54,7,84), C.wall2, Enum.Material.Concrete, 0, true, g)
part("Lobby Club Divider R", Vector3.new(72,14,3), CFrame.new(54,7,84), C.wall2, Enum.Material.Concrete, 0, true, g)
label("Club Door Label", "MAIN CLUB", CFrame.new(0,10,82.3), Vector3.new(24,3,.25), C.pink, Enum.NormalId.Front, g)

-- Main club clear hall: X -52..52, Z -62..82.
part("Main Club West Wall", Vector3.new(3,18,144), CFrame.new(-53.5,9,10), C.wall2, Enum.Material.Concrete, 0, true, g)
part("Main Club East Wall", Vector3.new(3,18,144), CFrame.new(53.5,9,10), C.wall2, Enum.Material.Concrete, 0, true, g)
label("Dance Label", "MAIN CLUB / DANCE", CFrame.new(0,8,-60.3), Vector3.new(38,4,.25), C.pink, Enum.NormalId.Front, g)
marker("DANCE LANDING", Vector3.new(0,.62,15), C.pink, g)

-- Stage is built into rear wall zone, not floating in the room.
part("Stage Platform", Vector3.new(72,3,18), CFrame.new(0,1.5,-77), C.wall2, Enum.Material.Concrete, 0, true, g)
label("Stage Label", "DJ / STAGE", CFrame.new(0,7,-86.8), Vector3.new(28,3,.25), C.pink, Enum.NormalId.Front, g)
marker("DJ LANDING", Vector3.new(0,3.7,-63), C.pink, g)

-- WEST BAR: dedicated room X -88..-56, Z 24..78.
part("Bar South Wall", Vector3.new(34,14,3), CFrame.new(-72,7,22), C.wall2, Enum.Material.Concrete, 0, true, g)
part("Bar North Wall", Vector3.new(34,14,3), CFrame.new(-72,7,80), C.wall2, Enum.Material.Concrete, 0, true, g)
-- Door opening in club west wall around Z=61: remove wall by covering only segments around opening.
part("Bar Door Wall A", Vector3.new(3,14,82), CFrame.new(-53.5,7,-20), C.wall2, Enum.Material.Concrete, 0, true, g)
part("Bar Door Wall B", Vector3.new(3,14,28), CFrame.new(-53.5,7,70), C.wall2, Enum.Material.Concrete, 0, true, g)
label("Bar Label", "BAR", CFrame.new(-55,8,51), Vector3.new(.25,4,16), C.gold, Enum.NormalId.Left, g)
marker("BAR LANDING", Vector3.new(-72,.62,52), C.gold, g)

-- EAST CHILL: separated acoustically from dance hall, X 56..88, Z 24..78.
part("Chill South Wall", Vector3.new(34,14,3), CFrame.new(72,7,22), C.wall2, Enum.Material.Concrete, 0, true, g)
part("Chill North Wall", Vector3.new(34,14,3), CFrame.new(72,7,80), C.wall2, Enum.Material.Concrete, 0, true, g)
-- 16-stud doorway in east club wall around Z=60.
part("Chill Door Wall A", Vector3.new(3,14,82), CFrame.new(53.5,7,-20), C.wall2, Enum.Material.Concrete, 0, true, g)
part("Chill Door Wall B", Vector3.new(3,14,28), CFrame.new(53.5,7,70), C.wall2, Enum.Material.Concrete, 0, true, g)
label("Chill Label", "CHILL LOUNGE", CFrame.new(55,8,51), Vector3.new(.25,4,19), C.cyan, Enum.NormalId.Right, g)
marker("CHILL LANDING", Vector3.new(72,.62,52), C.cyan, g)

-- LIFT CORE in lobby east service band. 14x14 shaft, 12-stud lobby in front.
local lift = Instance.new("Folder"); lift.Name = "Lift Core"; lift.Parent = root
part("Lift Back", Vector3.new(14,54,2), CFrame.new(73,27,109), C.wall2, Enum.Material.Concrete, 0, true, lift)
part("Lift West", Vector3.new(2,54,14), CFrame.new(66,27,102), C.wall2, Enum.Material.Concrete, 0, true, lift)
part("Lift East", Vector3.new(2,54,14), CFrame.new(80,27,102), C.wall2, Enum.Material.Concrete, 0, true, lift)
label("Lift Ground Label", "LIFT\nG / VIP / ROOF", CFrame.new(73,7,94.8), Vector3.new(12,7,.25), C.blue, Enum.NormalId.Front, lift)
marker("LIFT GROUND LANDING", Vector3.new(73,.62,92), C.blue, lift)
marker("LIFT VIP LANDING", Vector3.new(73,18.62,92), C.blue, lift)
marker("LIFT ROOF LANDING", Vector3.new(73,36.62,92), C.blue, lift)

-- TWO ARCHITECTURAL U-STAIR CORES, visible from main club sides.
local stairs = Instance.new("Folder"); stairs.Name = "Stair Cores"; stairs.Parent = root
uStair(stairs, "WEST STAIR G-VIP", -70, -28, 0)
uStair(stairs, "EAST STAIR G-VIP", 70, -28, 0)
uStair(stairs, "WEST STAIR VIP-ROOF", -70, -28, 18)
uStair(stairs, "EAST STAIR VIP-ROOF", 70, -28, 18)
label("West Stair Ground Label", "STAIR → VIP / ROOF", CFrame.new(-58,7,-21), Vector3.new(.25,4,20), C.cyan, Enum.NormalId.Left, stairs)
label("East Stair Ground Label", "STAIR → VIP / ROOF", CFrame.new(58,7,-21), Vector3.new(.25,4,20), C.cyan, Enum.NormalId.Right, stairs)

-- 03 VIP LEVEL -----------------------------------------------------------
local vip = Instance.new("Folder"); vip.Name = "03 VIP Level"; vip.Parent = root
-- Side mezzanines only; center remains open to dance floor below.
part("VIP West Slab", Vector3.new(36,1,126), CFrame.new(-71,18,-5), C.floor2, Enum.Material.Concrete, 0, true, vip)
part("VIP East Slab", Vector3.new(36,1,126), CFrame.new(71,18,-5), C.floor2, Enum.Material.Concrete, 0, true, vip)
part("VIP Rear Bridge", Vector3.new(106,1,20), CFrame.new(0,18,-71), C.floor2, Enum.Material.Concrete, 0, true, vip)
-- 12-stud circulation along each mezzanine edge.
label("VIP West Label", "VIP WEST", CFrame.new(-53,23,18), Vector3.new(.25,4,16), C.gold, Enum.NormalId.Left, vip)
label("VIP East Label", "VIP EAST", CFrame.new(53,23,18), Vector3.new(.25,4,16), C.gold, Enum.NormalId.Right, vip)
marker("VIP WEST LANDING", Vector3.new(-70,18.62,10), C.gold, vip)
marker("VIP EAST LANDING", Vector3.new(70,18.62,10), C.gold, vip)

-- Queen/private zone is only allocated, not decorated.
part("Queen Zone Slab", Vector3.new(40,1,22), CFrame.new(0,18,-73), C.floor2, Enum.Material.Concrete, 0, true, vip)
label("Queen Zone Label", "QUEEN / PRIVATE ZONE", CFrame.new(0,23,-83.5), Vector3.new(32,3,.25), C.gold, Enum.NormalId.Front, vip)
marker("QUEEN LANDING", Vector3.new(0,18.62,-68), C.gold, vip)

-- 04 ROOFTOP ------------------------------------------------------------
local roof = Instance.new("Folder"); roof.Name = "04 Rooftop"; roof.Parent = root
part("Rooftop Slab", Vector3.new(180,1,180), CFrame.new(0,36,20), C.floor2, Enum.Material.Concrete, 0, true, roof)
-- Parapet only; no pool/bar/cabana yet.
part("Roof West Parapet", Vector3.new(2,4,180), CFrame.new(-89,38,20), C.wall2, Enum.Material.Concrete, 0, true, roof)
part("Roof East Parapet", Vector3.new(2,4,180), CFrame.new(89,38,20), C.wall2, Enum.Material.Concrete, 0, true, roof)
part("Roof North Parapet", Vector3.new(180,4,2), CFrame.new(0,38,-70), C.wall2, Enum.Material.Concrete, 0, true, roof)
part("Roof South Parapet", Vector3.new(180,4,2), CFrame.new(0,38,110), C.wall2, Enum.Material.Concrete, 0, true, roof)
label("Rooftop Label", "ROOFTOP — EMPTY PROGRAMMING FLOOR", CFrame.new(0,43,-60), Vector3.new(50,4,.25), C.green, Enum.NormalId.Front, roof)
marker("ROOFTOP LANDING", Vector3.new(0,36.62,20), C.green, roof)

-- Future program rectangles only; no physical decor.
local future = Instance.new("Folder"); future.Name = "Future Program Markers"; future.Parent = roof
part("FUTURE POOL ZONE", Vector3.new(70,.12,38), CFrame.new(0,36.62,-25), Color3.fromRGB(70,160,210), Enum.Material.Neon, .6, false, future)
part("FUTURE SKY BAR ZONE", Vector3.new(36,.12,32), CFrame.new(-63,36.62,48), C.gold, Enum.Material.Neon, .65, false, future)
part("FUTURE ROOFTOP CHILL ZONE", Vector3.new(36,.12,32), CFrame.new(63,36.62,48), C.cyan, Enum.Material.Neon, .65, false, future)

workspace:SetAttribute("BBYAV5Layout", "5.0-greybox")
workspace:SetAttribute("BBYAV5Decor", false)
workspace:SetAttribute("BBYAV5Levels", "0/18/36")
workspace:SetAttribute("BBYAV5MainCorridorWidth", 14)
print("[BBYA] V5 ARCHITECTURAL GREYBOX loaded — circulation first, decor OFF")
