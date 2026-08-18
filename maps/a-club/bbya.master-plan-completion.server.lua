-- BBYA SOCIAL HUB — MASTER PLAN COMPLETION PASS v3.0
-- Completes the premium venue layer without replacing working music, social, Queen, or supporter systems.
-- Idempotent: safe to re-run; only this layer is rebuilt.

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local ROOT_NAME = "BBYA Master Plan Completion v3"
local QUEEN_USER_ID = 4271188557

local old = workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = workspace

local C = {
	black = Color3.fromRGB(10, 10, 16),
	midnight = Color3.fromRGB(15, 20, 37),
	stone = Color3.fromRGB(34, 32, 39),
	stone2 = Color3.fromRGB(54, 48, 55),
	wood = Color3.fromRGB(74, 53, 43),
	blue = Color3.fromRGB(30, 145, 255),
	cyan = Color3.fromRGB(45, 225, 255),
	pink = Color3.fromRGB(255, 55, 170),
	magenta = Color3.fromRGB(210, 48, 255),
	purple = Color3.fromRGB(103, 61, 196),
	gold = Color3.fromRGB(255, 191, 76),
	glass = Color3.fromRGB(66, 92, 120),
	water = Color3.fromRGB(32, 160, 220),
	green = Color3.fromRGB(31, 95, 67),
	warm = Color3.fromRGB(255, 147, 71),
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

local function neon(name, size, cf, color, parent, brightness, range)
	local p = part(name, size, cf, color, Enum.Material.Neon, 0, false, parent)
	local light = Instance.new("PointLight")
	light.Name = "AccentLight"
	light.Color = color
	light.Brightness = brightness or 1.1
	light.Range = range or 16
	light.Shadows = false
	light.Parent = p
	return p
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
	t.TextStrokeTransparency = 0.25
	t.Font = Enum.Font.GothamBlack
	t.TextScaled = true
	t.TextWrapped = true
	t.Parent = gui
	return t
end

local function sign(name, text, cf, size, color, parent)
	local p = part(name, size or Vector3.new(22, 4, 0.45), cf, C.black, Enum.Material.SmoothPlastic, 0, false, parent)
	label(p, text, color or C.pink)
	return p
end

local function glass(name, size, cf, parent)
	return part(name, size, cf, C.glass, Enum.Material.Glass, 0.5, true, parent)
end

local function seat(name, cf, size, color, parent)
	local s = Instance.new("Seat")
	s.Name = name
	s.Size = size or Vector3.new(5.5, 1.4, 4.5)
	s.CFrame = cf
	s.Anchored = true
	s.Material = Enum.Material.Fabric
	s.Color = color or C.purple
	s.Parent = parent or root
	return s
end

local function palm(name, pos, scale, parent)
	scale = scale or 1
	part(name .. " Trunk", Vector3.new(1.25, 9, 1.25) * scale, CFrame.new(pos + Vector3.new(0, 4.5 * scale, 0)) * CFrame.Angles(0, 0, math.rad(-4)), Color3.fromRGB(77, 53, 38), Enum.Material.Wood, 0, true, parent)
	for i = 0, 5 do
		local a = i * math.pi / 3
		part(name .. " Leaf " .. i, Vector3.new(1, 0.3, 7) * scale, CFrame.new(pos + Vector3.new(0, 9.1 * scale, 0)) * CFrame.Angles(0, a, math.rad(-18)), C.green, Enum.Material.SmoothPlastic, 0, false, parent)
	end
end

local function planter(name, cf, size, parent)
	local base = part(name .. " Planter", size, cf, C.stone2, Enum.Material.Slate, 0, true, parent)
	local soil = part(name .. " Soil", Vector3.new(size.X - 0.7, 0.35, size.Z - 0.7), cf * CFrame.new(0, size.Y / 2 + 0.12, 0), Color3.fromRGB(46, 32, 26), Enum.Material.Ground, 0, false, parent)
	for x = -1, 1 do
		local leaf = part(name .. " Plant " .. x, Vector3.new(1.2, 4.5, 1.2), soil.CFrame * CFrame.new(x * 2.3, 2.1, 0) * CFrame.Angles(0, 0, math.rad(x * 9)), C.green, Enum.Material.Grass, 0, false, parent)
		leaf.Shape = Enum.PartType.Cylinder
	end
	return base
end

local function loungeCluster(name, center, yaw, parent, accent)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent or root
	local cf = CFrame.new(center) * CFrame.Angles(0, math.rad(yaw or 0), 0)
	seat(name .. " Sofa L", cf * CFrame.new(-6.3, 0, 0), Vector3.new(5.5, 1.4, 4.8), Color3.fromRGB(75, 44, 84), folder)
	seat(name .. " Sofa R", cf * CFrame.new(6.3, 0, 0), Vector3.new(5.5, 1.4, 4.8), Color3.fromRGB(75, 44, 84), folder)
	part(name .. " Table", Vector3.new(6.5, 1, 4.5), cf * CFrame.new(0, 0.4, -4.7), C.black, Enum.Material.Glass, 0.12, true, folder)
	neon(name .. " Accent", Vector3.new(15, 0.18, 0.18), cf * CFrame.new(0, 1.35, 2.6), accent or C.pink, folder, 0.8, 12)
	return folder
end

local function stairRun(name, startPos, direction, steps, stepWidth, rise, run, parent)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent or root
	local dir = direction.Unit
	for i = 0, steps - 1 do
		local pos = startPos + dir * (run * i) + Vector3.new(0, rise * i, 0)
		local yaw = math.atan2(dir.X, dir.Z)
		part(name .. " Step " .. string.format("%02d", i + 1), Vector3.new(stepWidth, rise + 0.35, run + 0.12), CFrame.new(pos) * CFrame.Angles(0, yaw, 0), C.stone2, Enum.Material.Slate, 0, true, folder)
	end
	local totalRun = run * math.max(steps - 1, 1)
	local totalRise = rise * math.max(steps - 1, 1)
	local mid = startPos + dir * (totalRun / 2) + Vector3.new(0, totalRise / 2 + 2.1, 0)
	local yaw = math.atan2(dir.X, dir.Z)
	local length = math.sqrt(totalRun * totalRun + totalRise * totalRise)
	local pitch = -math.atan2(totalRise, totalRun)
	for _, side in ipairs({-1, 1}) do
		local rail = part(name .. " Rail " .. side, Vector3.new(0.3, 0.3, length), CFrame.new(mid) * CFrame.Angles(pitch, yaw, 0) * CFrame.new(side * (stepWidth / 2 + 0.35), 0, 0), C.glass, Enum.Material.Glass, 0.35, false, folder)
		rail.CanQuery = false
	end
	return folder
end

-- ============================================================
-- PREMIUM ARRIVAL / FACADE DEPTH
-- ============================================================
local arrival = Instance.new("Folder")
arrival.Name = "Premium Arrival Layer"
arrival.Parent = root

-- Secondary framing creates depth around the existing monumental gateway.
part("Arrival Outer Canopy", Vector3.new(104, 2.2, 16), CFrame.new(0, 23.5, 89), C.black, Enum.Material.Metal, 0, true, arrival)
part("Arrival Blade L", Vector3.new(5, 26, 18), CFrame.new(-48, 13, 91) * CFrame.Angles(0, math.rad(-8), 0), C.stone, Enum.Material.Slate, 0, true, arrival)
part("Arrival Blade R", Vector3.new(5, 26, 18), CFrame.new(48, 13, 91) * CFrame.Angles(0, math.rad(8), 0), C.stone, Enum.Material.Slate, 0, true, arrival)
neon("Arrival Cyan Line", Vector3.new(90, 0.3, 0.3), CFrame.new(0, 22.1, 80.8), C.cyan, arrival, 1.15, 22)
neon("Arrival Pink Line", Vector3.new(66, 0.35, 0.35), CFrame.new(0, 25.0, 81.0), C.pink, arrival, 1.15, 22)
planter("Arrival L", CFrame.new(-68, 2, 87), Vector3.new(17, 3, 7), arrival)
planter("Arrival R", CFrame.new(68, 2, 87), Vector3.new(17, 3, 7), arrival)
palm("Arrival Statement Palm L", Vector3.new(-69, 3.5, 86), 1.05, arrival)
palm("Arrival Statement Palm R", Vector3.new(69, 3.5, 86), 1.05, arrival)

-- Covered transition tunnel from arrival into the main club.
for _, x in ipairs({-42, 42}) do
	part("Lobby Rib " .. x, Vector3.new(4, 18, 30), CFrame.new(x, 10, 60), C.stone, Enum.Material.Slate, 0, true, arrival)
	neon("Lobby Rib Neon " .. x, Vector3.new(0.35, 15, 0.35), CFrame.new(x + (x < 0 and 2.1 or -2.1), 10, 46), x < 0 and C.blue or C.pink, arrival, 0.8, 12)
end
part("Lobby Floating Ceiling", Vector3.new(88, 1.2, 29), CFrame.new(0, 18.5, 60), C.black, Enum.Material.Metal, 0, true, arrival)

-- ============================================================
-- MAIN CLUB — SOCIAL DEPTH + SIDE TERRACES
-- ============================================================
local club = Instance.new("Folder")
club.Name = "Main Club Premium Layer"
club.Parent = root

-- Side social terraces visually connect dance floor, VIP, and bar zones.
part("West Social Terrace", Vector3.new(22, 1.2, 42), CFrame.new(-76, 4.2, 8), C.stone, Enum.Material.Slate, 0, true, club)
part("East Social Terrace", Vector3.new(22, 1.2, 42), CFrame.new(76, 4.2, 8), C.stone, Enum.Material.Slate, 0, true, club)
for _, z in ipairs({-5, 15}) do
	loungeCluster("West Social " .. z, Vector3.new(-76, 6, z), 90, club, C.blue)
	loungeCluster("East Social " .. z, Vector3.new(76, 6, z), -90, club, C.pink)
end
sign("West Social Sign", "SOCIAL TERRACE", CFrame.new(-65, 12, 27) * CFrame.Angles(0, math.rad(90), 0), Vector3.new(22, 3, 0.35), C.blue, club)
sign("East Social Sign", "SOCIAL TERRACE", CFrame.new(65, 12, 27) * CFrame.Angles(0, math.rad(-90), 0), Vector3.new(22, 3, 0.35), C.pink, club)

-- Warm-gold micro accents keep the cyber palette from feeling flat.
for _, x in ipairs({-50, -25, 0, 25, 50}) do
	neon("Warm Floor Guide " .. x, Vector3.new(12, 0.14, 0.5), CFrame.new(x, 1.15, 39), C.gold, club, 0.5, 8)
end

-- ============================================================
-- NATURAL VERTICAL CIRCULATION
-- ============================================================
local circulation = Instance.new("Folder")
circulation.Name = "Natural Circulation"
circulation.Parent = root

-- Ground -> mezzanine. Positioned on both outer sides to keep the central club sightline open.
stairRun("West Grand Stair", Vector3.new(-82, 2.2, 31), Vector3.new(0, 0, -1), 18, 9, 0.82, 1.55, circulation)
stairRun("East Grand Stair", Vector3.new(82, 2.2, 31), Vector3.new(0, 0, -1), 18, 9, 0.82, 1.55, circulation)

-- Mezzanine -> rooftop resort.
stairRun("West Rooftop Stair", Vector3.new(-75, 18.2, 36), Vector3.new(0, 0, 1), 23, 8, 0.88, 1.45, circulation)
stairRun("East Rooftop Stair", Vector3.new(75, 18.2, 36), Vector3.new(0, 0, 1), 23, 8, 0.88, 1.45, circulation)

sign("West Rooftop Wayfinding", "ROOFTOP ↑", CFrame.new(-75, 23, 34), Vector3.new(15, 3, 0.35), C.cyan, circulation)
sign("East Rooftop Wayfinding", "ROOFTOP ↑", CFrame.new(75, 23, 34), Vector3.new(15, 3, 0.35), C.cyan, circulation)

-- Two compact lift platforms provide an accessible/fast route while stairs remain the default exploration route.
local function buildLift(name, x)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = circulation
	local shaft = part(name .. " Shaft", Vector3.new(11, 38, 11), CFrame.new(x, 20, 46), C.black, Enum.Material.Metal, 0.18, true, folder)
	glass(name .. " Glass Front", Vector3.new(9, 34, 0.45), CFrame.new(x, 20, 40.45), folder)
	local platform = part(name .. " Platform", Vector3.new(8, 0.8, 8), CFrame.new(x, 3, 46), C.stone2, Enum.Material.Metal, 0, true, folder)
	neon(name .. " Floor Light", Vector3.new(7.5, 0.12, 0.35), platform.CFrame * CFrame.new(0, 0.48, -3.5), C.cyan, folder, 0.8, 10)
	local call = part(name .. " Call", Vector3.new(2.2, 3, 0.6), CFrame.new(x + (x < 0 and 6.1 or -6.1), 4, 46), C.black, Enum.Material.Metal, 0, false, folder)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "CALL / RIDE"
	prompt.ObjectText = "Rooftop Lift"
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = call
	local busy = false
	local floorTop = false
	prompt.Triggered:Connect(function()
		if busy then return end
		busy = true
		prompt.Enabled = false
		local targetY = floorTop and 3 or 38.5
		local tween = TweenService:Create(platform, TweenInfo.new(5.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CFrame = CFrame.new(x, targetY, 46)})
		tween:Play()
		tween.Completed:Wait()
		floorTop = not floorTop
		prompt.Enabled = true
		busy = false
	end)
	shaft.CanQuery = false
end

buildLift("West BBYA Lift", -56)
buildLift("East BBYA Lift", 56)

-- ============================================================
-- ROOFTOP RESORT COMPLETION
-- ============================================================
local roof = Instance.new("Folder")
roof.Name = "Rooftop Resort Completion"
roof.Parent = root

-- Dedicated rooftop bar.
part("Rooftop Bar Back", Vector3.new(38, 12, 3), CFrame.new(62, 44, 27), C.black, Enum.Material.Slate, 0, true, roof)
part("Rooftop Bar Counter", Vector3.new(34, 4, 6), CFrame.new(62, 40.5, 20), C.stone2, Enum.Material.Marble, 0, true, roof)
neon("Rooftop Bar Underlight", Vector3.new(32, 0.25, 0.25), CFrame.new(62, 39.1, 16.9), C.pink, roof, 1.1, 18)
sign("Rooftop Bar Sign", "BBYA SKY BAR", CFrame.new(62, 47.5, 25.4), Vector3.new(28, 4.5, 0.4), C.gold, roof)
for i = -3, 3 do
	seat("Sky Bar Stool " .. i, CFrame.new(62 + i * 4, 40, 15.7) * CFrame.Angles(0, math.pi, 0), Vector3.new(2.4, 1.2, 2.4), Color3.fromRGB(82, 52, 72), roof)
end

-- Sunset/viewing deck opposite the bar.
part("Viewing Deck", Vector3.new(50, 1.1, 30), CFrame.new(-59, 39.5, 22), C.wood, Enum.Material.WoodPlanks, 0, true, roof)
glass("Viewing Deck Glass", Vector3.new(50, 6, 0.6), CFrame.new(-59, 42.5, 7.1), roof)
sign("Viewing Deck Sign", "BALI NIGHT VIEW", CFrame.new(-59, 46, 8), Vector3.new(26, 3.5, 0.35), C.gold, roof)
loungeCluster("View Lounge A", Vector3.new(-70, 41, 22), 0, roof, C.gold)
loungeCluster("View Lounge B", Vector3.new(-48, 41, 22), 0, roof, C.cyan)

-- Pool-side daybeds and service tables.
for _, x in ipairs({-51, -34, 34, 51}) do
	seat("Pool Daybed " .. x, CFrame.new(x, 40.4, -10) * CFrame.Angles(0, math.pi, 0), Vector3.new(10, 1.1, 5), Color3.fromRGB(67, 43, 72), roof)
	part("Pool Side Table " .. x, Vector3.new(3, 1, 3), CFrame.new(x, 40.3, -16), C.black, Enum.Material.Glass, 0.1, true, roof)
end

-- Pool photo bridge / screenshot landmark.
part("Pool Photo Bridge", Vector3.new(4, 0.7, 28), CFrame.new(0, 40.1, -27), C.glass, Enum.Material.Glass, 0.32, true, roof)
neon("Pool Photo Bridge Edge L", Vector3.new(0.18, 0.18, 28), CFrame.new(-1.9, 40.5, -27), C.cyan, roof, 0.75, 10)
neon("Pool Photo Bridge Edge R", Vector3.new(0.18, 0.18, 28), CFrame.new(1.9, 40.5, -27), C.pink, roof, 0.75, 10)
sign("Pool Photo Sign", "BBYA NIGHTS", CFrame.new(0, 47, -44), Vector3.new(24, 4, 0.4), C.pink, roof)

-- Tropical perimeter composition.
for _, p in ipairs({Vector3.new(-80, 38, -40), Vector3.new(80, 38, -40), Vector3.new(-80, 38, 35), Vector3.new(80, 38, 35)}) do
	planter("Roof Green " .. tostring(p.X) .. " " .. tostring(p.Z), CFrame.new(p + Vector3.new(0, 1.3, 0)), Vector3.new(12, 2.6, 7), roof)
end

-- Warm fire bowls in lounge corners (visual only; no damage).
for _, pos in ipairs({Vector3.new(-82, 41, 2), Vector3.new(82, 41, 2)}) do
	local bowl = part("Fire Bowl", Vector3.new(5, 1.2, 5), CFrame.new(pos), C.black, Enum.Material.Metal, 0, true, roof)
	bowl.Shape = Enum.PartType.Cylinder
	local flame = Instance.new("ParticleEmitter")
	flame.Name = "Warm Flame"
	flame.Texture = "rbxasset://textures/particles/fire_main.dds"
	flame.Color = ColorSequence.new(C.warm, C.gold)
	flame.LightEmission = 0.9
	flame.Rate = 14
	flame.Lifetime = NumberRange.new(0.45, 0.8)
	flame.Speed = NumberRange.new(1.4, 2.8)
	flame.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.4), NumberSequenceKeypoint.new(1, 0)})
	flame.Parent = bowl
	local light = Instance.new("PointLight")
	light.Color = C.warm
	light.Brightness = 1.5
	light.Range = 14
	light.Shadows = false
	light.Parent = bowl
end

-- ============================================================
-- VIP PRESENCE / WAYFINDING (access itself remains owned by existing server role systems)
-- ============================================================
local vip = Instance.new("Folder")
vip.Name = "VIP Premium Layer"
vip.Parent = root

sign("VIP West Header", "VIP • SKY LOUNGE", CFrame.new(-53, 13, 42) * CFrame.Angles(0, math.rad(90), 0), Vector3.new(22, 4, 0.35), C.gold, vip)
neon("VIP West Portal L", Vector3.new(0.45, 11, 0.45), CFrame.new(-53, 7, 36), C.gold, vip, 1.1, 15)
neon("VIP West Portal R", Vector3.new(0.45, 11, 0.45), CFrame.new(-53, 7, 48), C.gold, vip, 1.1, 15)
neon("VIP West Portal Top", Vector3.new(0.45, 0.45, 12), CFrame.new(-53, 12.5, 42), C.gold, vip, 1.1, 15)

-- ============================================================
-- AMBIENT POLISH / PERFORMANCE-SAFE PULSE
-- ============================================================
Lighting.GlobalShadows = true
workspace:SetAttribute("BBYAMasterPlanVersion", "3.0")
workspace:SetAttribute("BBYAMasterPlanCompletion", true)

local pulse = {}
for _, obj in ipairs(root:GetDescendants()) do
	if obj:IsA("BasePart") and obj.Material == Enum.Material.Neon and #pulse < 28 then
		table.insert(pulse, obj)
	end
end

for i, obj in ipairs(pulse) do
	task.spawn(function()
		task.wait((i % 8) * 0.08)
		while obj.Parent do
			local a = TweenService:Create(obj, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.32})
			a:Play(); a.Completed:Wait()
			if not obj.Parent then break end
			local b = TweenService:Create(obj, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.02})
			b:Play(); b.Completed:Wait()
		end
	end)
end

-- Queen receives a subtle arrival announcement attribute for client UI systems if present.
local function tagPlayer(player)
	if player.UserId == QUEEN_USER_ID then
		player:SetAttribute("BBYAMasterPlanAllAccess", true)
		player:SetAttribute("IsVIP", true)
	end
end
Players.PlayerAdded:Connect(tagPlayer)
for _, player in ipairs(Players:GetPlayers()) do tagPlayer(player) end

print("[BBYA MASTER PLAN] v3.0 loaded: premium arrival, social terraces, natural stairs/lifts, rooftop sky bar/view deck/daybeds/photo bridge, VIP visual layer")
