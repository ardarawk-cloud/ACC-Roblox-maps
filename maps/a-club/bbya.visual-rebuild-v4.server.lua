-- BBYA SOCIAL HUB — PREMIUM VISUAL REBUILD v4.0
-- Replaces the old basic-looking club shell while preserving runtime systems.
-- Goal: premium Bali nightlife / rooftop resort feel, mobile-conscious part budget.

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local ROOT_NAME = "BBYA Premium Visual Rebuild v4"

for _, name in ipairs({
	"BBYA Mega Architecture v2",
	"BBYA Master Plan Completion v3",
	"BBYA Visual v1.2",
	ROOT_NAME,
}) do
	local old = workspace:FindFirstChild(name)
	if old then old:Destroy() end
end

-- Retire legacy base anchors. New anchors below keep the same names for working systems.
for _, name in ipairs({
	"Main Floor", "Rooftop Floor", "Back Wall", "Left Wall", "Right Wall",
	"DJ Stage", "DJ Booth", "Dance Floor", "Left VIP Platform", "Right VIP Platform",
	"Rooftop Pool", "BBYA Bar", "Photo Wall", "Chill Table"
}) do
	local obj = workspace:FindFirstChild(name)
	if obj then obj:Destroy() end
end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = workspace

local C = {
	black = Color3.fromRGB(8, 8, 14),
	midnight = Color3.fromRGB(14, 17, 30),
	stone = Color3.fromRGB(31, 29, 36),
	stone2 = Color3.fromRGB(48, 43, 50),
	wood = Color3.fromRGB(82, 57, 42),
	pink = Color3.fromRGB(255, 45, 170),
	magenta = Color3.fromRGB(211, 48, 255),
	purple = Color3.fromRGB(101, 55, 191),
	blue = Color3.fromRGB(35, 145, 255),
	cyan = Color3.fromRGB(48, 228, 255),
	gold = Color3.fromRGB(255, 191, 75),
	glass = Color3.fromRGB(71, 98, 127),
	water = Color3.fromRGB(34, 160, 221),
	green = Color3.fromRGB(29, 93, 60),
	warm = Color3.fromRGB(255, 140, 72),
}

local function part(name, size, cf, color, material, transparency, collide, parent)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Anchored = true
	p.CanCollide = collide ~= false
	p.Material = material or Enum.Material.SmoothPlastic
	p.Color = color or C.stone
	p.Transparency = transparency or 0
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent or root
	return p
end

local function wedge(name, size, cf, color, material, transparency, collide, parent)
	local p = Instance.new("WedgePart")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Anchored = true
	p.CanCollide = collide ~= false
	p.Material = material or Enum.Material.SmoothPlastic
	p.Color = color or C.stone
	p.Transparency = transparency or 0
	p.Parent = parent or root
	return p
end

local function neon(name, size, cf, color, parent, brightness, range)
	local p = part(name, size, cf, color, Enum.Material.Neon, 0, false, parent)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Brightness = brightness or 1
	l.Range = range or 14
	l.Shadows = false
	l.Parent = p
	return p
end

local function glass(name, size, cf, parent, collide)
	return part(name, size, cf, C.glass, Enum.Material.Glass, 0.48, collide ~= false, parent)
end

local function label(base, text, color, face)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 28
	gui.LightInfluence = 0
	gui.Parent = base
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.fromScale(1, 1)
	t.Text = text
	t.TextColor3 = color or C.pink
	t.TextStrokeTransparency = 0.28
	t.Font = Enum.Font.GothamBlack
	t.TextScaled = true
	t.TextWrapped = true
	t.Parent = gui
	return t
end

local function sign(name, text, cf, size, color, parent, face)
	local p = part(name, size or Vector3.new(24, 4, 0.45), cf, C.black, Enum.Material.SmoothPlastic, 0, false, parent)
	label(p, text, color or C.pink, face)
	return p
end

local function seat(name, cf, size, color, parent)
	local s = Instance.new("Seat")
	s.Name = name
	s.Size = size or Vector3.new(5, 1.4, 4.5)
	s.CFrame = cf
	s.Anchored = true
	s.Material = Enum.Material.Fabric
	s.Color = color or C.purple
	s.Parent = parent or root
	return s
end

local function planter(name, pos, size, parent)
	local base = part(name .. " Planter", size, CFrame.new(pos), C.stone2, Enum.Material.Slate, 0, true, parent)
	part(name .. " Soil", Vector3.new(size.X - .7, .35, size.Z - .7), CFrame.new(pos + Vector3.new(0, size.Y/2 + .12, 0)), Color3.fromRGB(48, 33, 25), Enum.Material.Ground, 0, false, parent)
	return base
end

local function palm(name, pos, scale, parent)
	scale = scale or 1
	part(name .. " Trunk", Vector3.new(1.1, 9, 1.1) * scale, CFrame.new(pos + Vector3.new(0, 4.5*scale, 0)) * CFrame.Angles(0,0,math.rad(-5)), Color3.fromRGB(82, 57, 39), Enum.Material.Wood, 0, true, parent)
	for i = 0, 5 do
		local a = i * math.pi / 3
		part(name .. " Leaf " .. i, Vector3.new(.85, .28, 7) * scale, CFrame.new(pos + Vector3.new(0, 9.1*scale, 0)) * CFrame.Angles(0, a, math.rad(-17)), C.green, Enum.Material.Grass, 0, false, parent)
	end
end

local function lounge(name, center, yaw, accent, parent)
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent or root
	local cf = CFrame.new(center) * CFrame.Angles(0, math.rad(yaw or 0), 0)
	seat(name .. " Sofa A", cf * CFrame.new(-5.5, 0, 0), Vector3.new(5,1.4,4.5), Color3.fromRGB(68,39,78), f)
	seat(name .. " Sofa B", cf * CFrame.new(5.5, 0, 0), Vector3.new(5,1.4,4.5), Color3.fromRGB(68,39,78), f)
	part(name .. " Table", Vector3.new(5.5,1,4), cf * CFrame.new(0,.35,-4.4), C.black, Enum.Material.Glass, .12, true, f)
	neon(name .. " Accent", Vector3.new(13,.16,.18), cf * CFrame.new(0,1.4,2.5), accent or C.pink, f, .7, 10)
end

local function stairs(name, startPos, dir, steps, width, rise, run, parent)
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent or root
	local d = dir.Unit
	local yaw = math.atan2(d.X, d.Z)
	for i=0,steps-1 do
		local pos = startPos + d*(run*i) + Vector3.new(0,rise*i,0)
		part(name .. " Step " .. i, Vector3.new(width,rise+.25,run+.08), CFrame.new(pos)*CFrame.Angles(0,yaw,0), C.stone2, Enum.Material.Slate, 0, true, f)
	end
	return f
end

local function daybed(name, cf, parent)
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	part(name .. " Base", Vector3.new(7,1,5), cf, Color3.fromRGB(73,55,67), Enum.Material.Fabric, 0, true, f)
	wedge(name .. " Back", Vector3.new(7,3.2,2.2), cf*CFrame.new(0,1.9,2.2)*CFrame.Angles(math.rad(10),0,0), Color3.fromRGB(84,61,78), Enum.Material.Fabric, 0, true, f)
	neon(name .. " Underlight", Vector3.new(6.2,.12,.18), cf*CFrame.new(0,-.55,-2.3), C.cyan, f, .45, 7)
end

-- ============================================================
-- LIGHTING / ATMOSPHERE
-- ============================================================
Lighting.ClockTime = 23.2
Lighting.Brightness = 1.75
Lighting.Ambient = Color3.fromRGB(25, 24, 42)
Lighting.OutdoorAmbient = Color3.fromRGB(10, 13, 29)
Lighting.FogColor = Color3.fromRGB(18, 22, 42)
Lighting.FogStart = 300
Lighting.FogEnd = 1150

for _, effectName in ipairs({"BBYA_Bloom_v4","BBYA_Color_v4","BBYA_Atmosphere_v4"}) do
	local e = Lighting:FindFirstChild(effectName)
	if e then e:Destroy() end
end
local bloom = Instance.new("BloomEffect")
bloom.Name = "BBYA_Bloom_v4"
bloom.Intensity = .55
bloom.Size = 28
bloom.Threshold = 1.3
bloom.Parent = Lighting
local color = Instance.new("ColorCorrectionEffect")
color.Name = "BBYA_Color_v4"
color.Brightness = .03
color.Contrast = .08
color.Saturation = .08
color.TintColor = Color3.fromRGB(235, 232, 255)
color.Parent = Lighting
local atmosphere = Instance.new("Atmosphere")
atmosphere.Name = "BBYA_Atmosphere_v4"
atmosphere.Density = .19
atmosphere.Haze = 1
atmosphere.Glare = .08
atmosphere.Color = Color3.fromRGB(83, 91, 138)
atmosphere.Decay = Color3.fromRGB(25, 16, 48)
atmosphere.Parent = Lighting

-- ============================================================
-- CORE ANCHORS (direct Workspace names retained for existing systems)
-- ============================================================
local mainFloor = part("Main Floor", Vector3.new(184,2,142), CFrame.new(0,0,0), C.stone, Enum.Material.Slate, 0, true, workspace)
local danceFloor = part("Dance Floor", Vector3.new(72,1,54), CFrame.new(0,1.15,-6), Color3.fromRGB(22,15,32), Enum.Material.Glass, .08, true, workspace)
local djStage = part("DJ Stage", Vector3.new(64,3.5,18), CFrame.new(0,2.2,-53), C.black, Enum.Material.Metal, 0, true, workspace)
local djBooth = part("DJ Booth", Vector3.new(28,3.5,6), CFrame.new(0,6.3,-48), Color3.fromRGB(31,24,42), Enum.Material.Metal, 0, true, workspace)
local vipL = part("Left VIP Platform", Vector3.new(30,2,34), CFrame.new(-70,10,-2), C.stone2, Enum.Material.Marble, 0, true, workspace)
local vipR = part("Right VIP Platform", Vector3.new(30,2,34), CFrame.new(70,10,-2), C.stone2, Enum.Material.Marble, 0, true, workspace)
local rooftopFloor = part("Rooftop Floor", Vector3.new(184,2,114), CFrame.new(0,36,6), C.stone, Enum.Material.Slate, 0, true, workspace)
local pool = part("Rooftop Pool", Vector3.new(72,1.6,36), CFrame.new(0,38,-25), C.water, Enum.Material.Glass, .26, false, workspace)
local barAnchor = part("BBYA Bar", Vector3.new(26,4,7), CFrame.new(-57,3.1,27), C.black, Enum.Material.Marble, 0, true, workspace)
local photoAnchor = part("Photo Wall", Vector3.new(22,11,1), CFrame.new(58,7,27), C.black, Enum.Material.SmoothPlastic, 0, true, workspace)
local chillAnchor = part("Chill Table", Vector3.new(7,1,7), CFrame.new(58,2,-25), C.black, Enum.Material.Glass, .1, true, workspace)

-- ============================================================
-- ARRIVAL COURTYARD / FACADE
-- ============================================================
local arrival = Instance.new("Folder"); arrival.Name="01 Arrival Courtyard"; arrival.Parent=root
part("Arrival Court", Vector3.new(160,1.4,58), CFrame.new(0,1,102), C.stone, Enum.Material.Slate, 0, true, arrival)
for _, x in ipairs({-58,58}) do
	part("Reflecting Pool "..x, Vector3.new(38,.45,22), CFrame.new(x,2,108), C.water, Enum.Material.Glass, .25, false, arrival)
	planter("Arrival Planter "..x, Vector3.new(x,3,86), Vector3.new(20,3,8), arrival)
	palm("Arrival Palm "..x, Vector3.new(x,4.5,86), 1.15, arrival)
end
-- Layered façade gives depth instead of a flat Roblox wall.
part("Facade Crown", Vector3.new(112,3,15), CFrame.new(0,25,82), C.black, Enum.Material.Metal, 0, true, arrival)
wedge("Facade Wing L", Vector3.new(28,28,18), CFrame.new(-46,14,84)*CFrame.Angles(0,math.rad(180),0), C.stone2, Enum.Material.Slate, 0, true, arrival)
wedge("Facade Wing R", Vector3.new(28,28,18), CFrame.new(46,14,84), C.stone2, Enum.Material.Slate, 0, true, arrival)
neon("Facade Crown Pink", Vector3.new(76,.45,.4), CFrame.new(0,23.3,74.3), C.pink, arrival, 1.5, 24)
neon("Facade Crown Cyan", Vector3.new(48,.3,.3), CFrame.new(0,20.5,74.2), C.cyan, arrival, 1, 20)
sign("BBYA Arrival Sign", "BBYA SOCIAL HUB", CFrame.new(0,30,75), Vector3.new(72,8,.6), C.pink, arrival)
sign("Arrival Subtitle", "MUSIC  •  DANCE  •  SOCIAL  •  ROOFTOP", CFrame.new(0,21.5,75), Vector3.new(52,3,.5), C.cyan, arrival)

-- Grand lobby tunnel.
part("Lobby Floor Premium", Vector3.new(112,1.4,32), CFrame.new(0,1.8,60), C.black, Enum.Material.Marble, 0, true, arrival)
for _, x in ipairs({-48,-32,32,48}) do
	part("Lobby Blade "..x, Vector3.new(3,19,26), CFrame.new(x,10,60), C.stone2, Enum.Material.Slate, 0, true, arrival)
	neon("Lobby Blade Light "..x, Vector3.new(.25,16,.25), CFrame.new(x + (x<0 and 1.6 or -1.6),10,48), x<0 and C.blue or C.pink, arrival, .8, 11)
end
part("Lobby Ceiling", Vector3.new(100,1,30), CFrame.new(0,19.5,60), C.black, Enum.Material.Metal, 0, true, arrival)
sign("Lobby Direction", "CLUB ↑      VIP ↗      ROOFTOP ↖", CFrame.new(0,13,44.5), Vector3.new(54,4,.4), C.gold, arrival)

-- ============================================================
-- MAIN CLUB / FESTIVAL HALL
-- ============================================================
local club = Instance.new("Folder"); club.Name="02 Main Club"; club.Parent=root
-- Architectural side walls only; center remains visually open.
for _, x in ipairs({-88,88}) do
	part("Club Side Spine "..x, Vector3.new(4,25,104), CFrame.new(x,12.5,-10), C.midnight, Enum.Material.Slate, 0, true, club)
	for _, z in ipairs({-44,-20,4,28}) do
		neon("Spine Light "..x.." "..z, Vector3.new(.35,12,.35), CFrame.new(x + (x<0 and 2.1 or -2.1),10,z), x<0 and C.blue or C.pink, club, .8, 10)
	end
end

-- Ceiling ribs and floating canopy.
for _, z in ipairs({-44,-26,-8,10,28}) do
	part("Ceiling Rib "..z, Vector3.new(116,.7,1), CFrame.new(0,25,z), C.black, Enum.Material.Metal, 0, false, club)
	for _, x in ipairs({-44,-22,0,22,44}) do
		local lamp = neon("Moving Head "..x.." "..z, Vector3.new(2,1.2,2), CFrame.new(x,24.2,z), ((x+z)%3==0) and C.cyan or C.pink, club, 1, 15)
		local s = Instance.new("SpotLight")
		s.Face = Enum.NormalId.Bottom
		s.Angle = 46
		s.Brightness = 3.2
		s.Range = 62
		s.Color = lamp.Color
		s.Shadows = false
		s.Parent = lamp
	end
end

-- Dance floor inset tiles, cleaner than old giant checkerboard.
for ix=-3,3 do
	for iz=-2,2 do
		local col = ((ix+iz)%2==0) and C.pink or C.cyan
		local tile = part("Dance Glass Tile", Vector3.new(8.5,.14,8.5), CFrame.new(ix*9,1.72,-6+iz*9), Color3.fromRGB(32,22,43), Enum.Material.Glass, .18, false, club)
		neon("Dance Edge", Vector3.new(7.6,.08,.12), tile.CFrame*CFrame.new(0,.12,4.1), col, club, .35, 5)
	end
end

-- Premium stage geometry and LED wall.
part("Stage Fascia", Vector3.new(70,7,3), CFrame.new(0,7,-61), C.black, Enum.Material.Metal, 0, true, club)
for _, x in ipairs({-28,-14,0,14,28}) do
	part("LED Tower "..x, Vector3.new(10,15,.8), CFrame.new(x,15,-59.2), Color3.fromRGB(25,15,35), Enum.Material.Glass, .08, false, club)
	for y=10,20,5 do neon("LED Pixel "..x.." "..y, Vector3.new(8,.35,.2), CFrame.new(x,y,-58.7), ((x+y)%2==0) and C.pink or C.cyan, club, .65, 8) end
end
sign("Stage Brand", "BBYA • NIGHT SYSTEM", CFrame.new(0,25,-59), Vector3.new(58,6,.5), C.pink, club)
-- DJ console decoration, anchor remains direct Workspace.
neon("DJ Booth Rim", Vector3.new(27,.2,.2), djBooth.CFrame*CFrame.new(0,1.9,-3), C.pink, club, 1, 12)
neon("DJ Booth Cyan", Vector3.new(18,.15,.18), djBooth.CFrame*CFrame.new(0,1.2,-3.1), C.cyan, club, .75, 10)

-- Main floor social/bar/photo corners.
sign("Bar Wall Sign", "BBYA BAR • MOCKTAILS", CFrame.new(-57,8,23.3), Vector3.new(25,3.5,.4), C.gold, club)
neon("Bar Underglow", Vector3.new(24,.2,.2), barAnchor.CFrame*CFrame.new(0,-2.1,-3.6), C.pink, club, .7, 9)
for _, x in ipairs({-8,0,8}) do seat("Bar Stool "..x, CFrame.new(-57+x,1.7,21), Vector3.new(3,1.2,3), Color3.fromRGB(82,45,83), club) end
sign("Photo Neon", "BBYA ♥ NIGHT", CFrame.new(58,8,26.4), Vector3.new(19,5,.3), C.pink, club)
for i=0,5 do
	local a=i*math.pi/3
	local pos=Vector3.new(58+math.cos(a)*8,2,-25+math.sin(a)*8)
	seat("Chill Seat "..i, CFrame.new(pos,Vector3.new(58,2,-25)), Vector3.new(4,1.2,4), Color3.fromRGB(69,41,79), club)
end
sign("Chill Label", "CHILL & TALK", CFrame.new(58,6,-33), Vector3.new(16,3,.4), C.cyan, club)

-- ============================================================
-- VIP MEZZANINE + QUEEN SKYBOX
-- ============================================================
local upper = Instance.new("Folder"); upper.Name="03 VIP + Queen"; upper.Parent=root
for _, side in ipairs({{-70,C.blue},{70,C.pink}}) do
	local x, accent = side[1], side[2]
	glass("VIP Front Glass "..x, Vector3.new(29,6,1), CFrame.new(x,14,-18), upper, true)
	lounge("VIP Lounge A "..x, Vector3.new(x,12,-6), 0, accent, upper)
	lounge("VIP Lounge B "..x, Vector3.new(x,12,8), 180, accent, upper)
	neon("VIP Rail "..x, Vector3.new(28,.18,.18), CFrame.new(x,15,-18.4), accent, upper, .8, 12)
end
sign("VIP Left Sign", "VIP LOUNGE", CFrame.new(-70,17,14.4), Vector3.new(22,3,.4), C.gold, upper)
sign("VIP Right Sign", "VIP LOUNGE", CFrame.new(70,17,14.4), Vector3.new(22,3,.4), C.gold, upper)

-- Queen skybox centered over dance floor.
part("Queen Skybox Floor", Vector3.new(42,1.5,25), CFrame.new(0,21,15), C.black, Enum.Material.Marble, 0, true, upper)
glass("Queen Skybox Glass", Vector3.new(42,7,1), CFrame.new(0,25.5,2.6), upper, true)
part("Queen Skybox Back", Vector3.new(42,13,1.5), CFrame.new(0,27,27), C.midnight, Enum.Material.Slate, 0, true, upper)
sign("Queen Skybox Sign", "♛  BBYA QUEEN  ♛", CFrame.new(0,31,26.1), Vector3.new(30,5,.4), C.pink, upper)
local throne = seat("BBYA QUEEN THRONE", CFrame.new(0,23,19), Vector3.new(8,2.5,7), Color3.fromRGB(84,43,94), upper)
part("Queen Throne Back", Vector3.new(9,9,1.5), CFrame.new(0,27,22), C.black, Enum.Material.Metal, 0, true, upper)
for i=-2,2 do neon("Queen Crown "..i, Vector3.new(.8,5,.8), CFrame.new(i*2.3,33+(math.abs(i)%2),24), C.pink, upper, .8, 9) end

-- Natural stairs, no teleport dependency.
stairs("West VIP Stair", Vector3.new(-47,1.8,27), Vector3.new(-1,0,-.75), 16, 8, .66, 1.35, upper)
stairs("East VIP Stair", Vector3.new(47,1.8,27), Vector3.new(1,0,-.75), 16, 8, .66, 1.35, upper)
stairs("West Rooftop Stair", Vector3.new(-78,12,21), Vector3.new(0,0,1), 28, 8, .9, 1.35, upper)
stairs("East Rooftop Stair", Vector3.new(78,12,21), Vector3.new(0,0,1), 28, 8, .9, 1.35, upper)
sign("Roof Wayfinding L", "ROOFTOP ↑", CFrame.new(-78,20,20), Vector3.new(14,3,.35), C.cyan, upper)
sign("Roof Wayfinding R", "ROOFTOP ↑", CFrame.new(78,20,20), Vector3.new(14,3,.35), C.cyan, upper)

-- ============================================================
-- ROOFTOP RESORT / POOL PARTY
-- ============================================================
local roof = Instance.new("Folder"); roof.Name="04 Rooftop Resort"; roof.Parent=root
-- Deck zoning.
part("Pool Timber Deck", Vector3.new(96,.6,52), CFrame.new(0,37.2,-18), Color3.fromRGB(71,54,52), Enum.Material.WoodPlanks, 0, true, roof)
part("Rooftop Social Deck L", Vector3.new(38,.6,84), CFrame.new(-70,37.2,2), C.stone2, Enum.Material.Slate, 0, true, roof)
part("Rooftop Social Deck R", Vector3.new(38,.6,84), CFrame.new(70,37.2,2), C.stone2, Enum.Material.Slate, 0, true, roof)
-- Pool edge treatment.
neon("Pool Front Edge", Vector3.new(74,.25,.25), CFrame.new(0,39,-43.3), C.cyan, roof, 1, 18)
for _, x in ipairs({-34,34}) do neon("Pool Side Edge "..x, Vector3.new(.25,.25,34), CFrame.new(x,39,-25), C.cyan, roof, .7, 12) end
sign("Pool Party Sign", "BBYA POOL PARTY", CFrame.new(0,45,31), Vector3.new(34,5,.45), C.pink, roof)
-- Rooftop DJ deck.
part("Pool DJ Deck", Vector3.new(38,2.5,15), CFrame.new(0,39,37), C.black, Enum.Material.Metal, 0, true, roof)
neon("Pool DJ Rim", Vector3.new(36,.2,.2), CFrame.new(0,40.5,29.6), C.pink, roof, 1, 13)
-- Sky bar.
part("BBYA Sky Bar", Vector3.new(36,4,8), CFrame.new(-62,40,30), C.black, Enum.Material.Marble, 0, true, roof)
sign("Sky Bar Sign", "BBYA SKY BAR", CFrame.new(-62,46,25.8), Vector3.new(28,4,.4), C.gold, roof)
neon("Sky Bar Underglow", Vector3.new(34,.2,.2), CFrame.new(-62,37.8,26), C.pink, roof, .65, 9)
for _, x in ipairs({-12,-4,4,12}) do seat("Sky Bar Stool "..x, CFrame.new(-62+x,38.8,24), Vector3.new(3,1.2,3), Color3.fromRGB(83,48,76), roof) end
-- Cabanas and daybeds.
for i, x in ipairs({-62,-37,37,62}) do
	local z = 2
	part("Cabana Roof "..i, Vector3.new(18,.8,14), CFrame.new(x,47,z), C.black, Enum.Material.WoodPlanks, 0, true, roof)
	for _, ox in ipairs({-8,8}) do for _, oz in ipairs({-6,6}) do part("Cabana Post "..i.." "..ox.." "..oz, Vector3.new(.7,9,.7), CFrame.new(x+ox,42.5,z+oz), C.wood, Enum.Material.Wood, 0, true, roof) end end
	lounge("Cabana Lounge "..i, Vector3.new(x,39,z), 0, i%2==0 and C.cyan or C.pink, roof)
end
for _, cfg in ipairs({{-23,-4,0},{23,-4,180},{-23,-43,0},{23,-43,180}}) do daybed("Pool Daybed "..cfg[1].." "..cfg[2], CFrame.new(cfg[1],38.2,cfg[2])*CFrame.Angles(0,math.rad(cfg[3]),0), roof) end
-- Tropical structure.
for _, x in ipairs({-86,-74,74,86}) do for _, z in ipairs({-36,8,42}) do palm("Roof Palm "..x.." "..z, Vector3.new(x,38,z), 1.05, roof) end end
-- Perimeter glass keeps the rooftop safe without killing the skyline view.
glass("Roof Front Glass", Vector3.new(182,7,1), CFrame.new(0,41.5,-50), roof, true)
glass("Roof Left Glass", Vector3.new(1,7,108), CFrame.new(-91,41.5,4), roof, true)
glass("Roof Right Glass", Vector3.new(1,7,108), CFrame.new(91,41.5,4), roof, true)
-- City-view lounge.
part("City View Deck", Vector3.new(54,.6,18), CFrame.new(61,37.3,46), Color3.fromRGB(58,48,55), Enum.Material.WoodPlanks, 0, true, roof)
sign("City View Sign", "CITY VIEW • SUNSET / NIGHT", CFrame.new(61,44,54.2), Vector3.new(30,4,.4), C.cyan, roof)
lounge("City View Lounge", Vector3.new(61,39,46), 180, C.cyan, roof)

-- ============================================================
-- FICTIONAL SKYLINE DEPTH
-- ============================================================
local skyline = Instance.new("Folder"); skyline.Name="05 Skyline"; skyline.Parent=root
for i=-8,8 do
	local x=i*34
	local h=math.random(42,95)
	local z=-155-math.random(0,35)
	local b=part("Skyline Tower "..i, Vector3.new(22,h,22), CFrame.new(x,h/2,z), Color3.fromRGB(19,21,32), Enum.Material.SmoothPlastic, 0, true, skyline)
	for y=8,h-6,12 do
		neon("Skyline Window "..i.." "..y, Vector3.new(14,.18,.18), CFrame.new(x,y,z+11.2), i%2==0 and C.cyan or C.pink, skyline, .18, 4)
	end
end

-- ============================================================
-- LIGHT ANIMATION (small selected set only)
-- ============================================================
local pulse = {}
for _, o in ipairs(root:GetDescendants()) do
	if o:IsA("BasePart") and o.Material==Enum.Material.Neon and (#pulse < 70) then
		table.insert(pulse,o)
	end
end

task.spawn(function()
	local on=false
	while root.Parent do
		on=not on
		for _, p in ipairs(pulse) do
			if p.Parent then TweenService:Create(p,TweenInfo.new(.75,Enum.EasingStyle.Sine),{Transparency=on and .08 or .28}):Play() end
		end
		task.wait(.8)
	end
end)

workspace:SetAttribute("BBYAVisualBuild", "4.0")
workspace:SetAttribute("BBYAVisualDirection", "Premium Bali Nightlife / Rooftop Resort")
print("[BBYA VISUAL] Premium Rebuild v4.0 loaded — legacy basic shell retired, new arrival/club/VIP/Queen/rooftop resort active")
