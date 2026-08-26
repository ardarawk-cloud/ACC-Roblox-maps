-- BBYA SOCIAL HUB — MALL PREMIUM ATMOSPHERE v9
-- Narrow visual/hospitality pass layered on top of Mall Gallery v6 + Visual Cleanup v8.
-- Scope: Mall only. No global Lighting, audio, fishing, economy, VIP, Night Market, or commerce logic changes.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 60)
if not root then return end

local mall = root:WaitForChild("BBYAMall", 90)
if not mall then return end

local live = mall:WaitForChild("MallLiveUpgradeV2", 120)
local galleryAuthority = mall:WaitForChild("MallPremiumGalleryV6", 120)
if not live or not galleryAuthority then
	warn("[BBYA] Mall Premium Atmosphere v9 aborted: v6/v8 authority unavailable")
	return
end

task.wait(0.6)

local old = mall:FindFirstChild("MallPremiumAtmosphereV9")
if old then old:Destroy() end

local out = Instance.new("Model")
out.Name = "MallPremiumAtmosphereV9"
out:SetAttribute("Pass", "MALL_PREMIUM_ATMOSPHERE_V9")
out:SetAttribute("LegacyAtriumSeatsRemoved", true)
out:SetAttribute("LegacyFrontPlantersRemoved", true)
out:SetAttribute("RetailThresholdWarmth", true)
out:SetAttribute("AtriumHospitalityLounge", true)
out:SetAttribute("ArrivalLightingRefined", true)
out:SetAttribute("GlobalLightingUntouched", true)
out:SetAttribute("AudioUntouched", true)
out:SetAttribute("FishingUntouched", true)
out.Parent = mall

local C = {
	ink = Color3.fromRGB(35, 36, 39),
	graphite = Color3.fromRGB(57, 57, 59),
	metal = Color3.fromRGB(86, 88, 92),
	stone = Color3.fromRGB(116, 112, 106),
	brass = Color3.fromRGB(194, 153, 91),
	champagne = Color3.fromRGB(222, 187, 127),
	warm = Color3.fromRGB(255, 226, 198),
	fabric = Color3.fromRGB(53, 50, 52),
	leaf = Color3.fromRGB(61, 91, 66),
	soil = Color3.fromRGB(59, 47, 39),
	glass = Color3.fromRGB(117, 143, 154),
}

local function part(name, size, cf, color, material, collide, parent, transparency)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color or C.graphite
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = collide == true
	p.CanTouch = false
	p.CanQuery = false
	p.Transparency = transparency or 0
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CastShadow = p.Material ~= Enum.Material.Neon and p.Transparency < 0.9
	p.Parent = parent or out
	return p
end

local function neon(name, size, cf, color, parent, transparency)
	local p = part(name, size, cf, color or C.champagne, Enum.Material.Neon, false, parent, transparency or 0)
	p.CastShadow = false
	return p
end

local function cylinder(name, height, diameter, cf, color, material, collide, parent, transparency)
	local p = part(name, Vector3.new(height, diameter, diameter), cf * CFrame.Angles(0, 0, math.rad(90)), color, material, collide, parent, transparency)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function ball(name, size, cf, color, parent)
	local p = part(name, size, cf, color, Enum.Material.SmoothPlastic, false, parent, 0)
	p.Shape = Enum.PartType.Ball
	return p
end

local function surfaceDownLight(parent, brightness, range)
	local light = Instance.new("SurfaceLight")
	light.Name = "MallV9LocalLight"
	light.Face = Enum.NormalId.Bottom
	light.Color = C.warm
	light.Brightness = brightness
	light.Range = range
	light.Angle = 105
	light.Shadows = false
	light.Parent = parent
	return light
end

-- 1) Retire primitive first-generation Mall dressing that survived later authorities.
local atriumExperience = mall:FindFirstChild("AtriumExperience")
if atriumExperience then
	for _, child in ipairs(atriumExperience:GetChildren()) do
		if child.Name == "AtriumSeat" then
			child:Destroy()
		end
	end
end
for _, child in ipairs(mall:GetChildren()) do
	if child.Name:match("^FrontPlanter") then
		child:Destroy()
	end
end

-- 2) Refine the arrival identity without replacing working text GUIs or doors.
for _, name in ipairs({"MallHeroSign", "MallSubSign"}) do
	local p = mall:FindFirstChild(name)
	if p and p:IsA("BasePart") then
		p.Color = name == "MallHeroSign" and C.ink or C.graphite
		p.Material = Enum.Material.Metal
		p.Reflectance = 0.02
		p.CastShadow = false
	end
end

local connector = mall:FindFirstChild("FunkotMallConnector")
if connector then
	local sign = connector:FindFirstChild("ConnectorSign")
	if sign and sign:IsA("BasePart") then
		sign.Color = C.graphite
		sign.Material = Enum.Material.Metal
		sign.Reflectance = 0.01
	end
end

local doors = mall:FindFirstChild("AutomaticEntrance")
if doors then
	for _, name in ipairs({"EntryDoorL", "EntryDoorR"}) do
		local door = doors:FindFirstChild(name)
		if door and door:IsA("BasePart") then
			door.Color = C.glass
			door.Material = Enum.Material.Glass
			door.Transparency = 0.34
			door.Reflectance = 0.10
			door.CastShadow = false
		end
	end
end

local arrival = Instance.new("Model")
arrival.Name = "PremiumArrivalAtmosphereV9"
arrival.Parent = out
neon("ArrivalFloorReveal", Vector3.new(34, 0.045, 0.16), CFrame.new(0, 1.11, 300.5), C.champagne, arrival, 0.28)
for _, x in ipairs({-10, 10}) do
	for _, z in ipairs({307, 321}) do
		local fixture = neon("ArrivalCeiling_" .. x .. "_" .. z, Vector3.new(6.2, 0.055, 0.72), CFrame.new(x, 14.42, z), C.warm, arrival, 0.78)
		surfaceDownLight(fixture, 0.26, 9)
	end
end

-- 3) Add restrained warm threshold lines to the rebuilt retail galleries.
-- They give each open store an intentional entry plane without adding more signage or prompts.
local retail = Instance.new("Model")
retail.Name = "RetailThresholdWarmthV9"
retail.Parent = out
local thresholdCount = 0
for _, unit in ipairs(mall:GetChildren()) do
	if unit:IsA("Model") and unit.Name:match("^Tenant_") then
		local gallery = unit:FindFirstChild("PremiumRetailGalleryV6")
		local floor = unit:FindFirstChild("Floor")
		if gallery and floor and floor:IsA("BasePart") then
			local cx = floor.Position.X
			local z = floor.Position.Z
			local width = floor.Size.X
			local depth = floor.Size.Z
			local inward = cx < 0 and 1 or -1
			local frontX = cx + inward * (width / 2 - 0.55)
			local accent = C.champagne
			local underline = gallery:FindFirstChild("IdentityUnderline")
			if underline and underline:IsA("BasePart") then
				accent = underline.Color
			end
			neon(
				"Threshold_" .. unit.Name,
				Vector3.new(0.07, 0.045, math.max(8, depth - 4.0)),
				CFrame.new(frontX - inward * 0.16, floor.Position.Y + 0.54, z),
				accent,
				retail,
				0.30
			)
			thresholdCount = thresholdCount + 1
		end
	end
end

-- 4) Replace cheap standalone atrium seats with two compact hospitality lounge islands.
-- Positioning stays outside the central stone inlay and clear of the south-west stair run.
local lounge = Instance.new("Model")
lounge.Name = "AtriumHospitalityLoungeV9"
lounge.Parent = out

local function loungeSeat(name, x, z, yaw)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = lounge
	local cf = CFrame.new(x, 1.65, z) * CFrame.Angles(0, math.rad(yaw), 0)
	local seat = Instance.new("Seat")
	seat.Name = "SocialSeat"
	seat.Size = Vector3.new(7.0, 0.64, 2.15)
	seat.CFrame = cf
	seat.Color = C.fabric
	seat.Material = Enum.Material.Fabric
	seat.Anchored = true
	seat.CanCollide = true
	seat.CanTouch = true
	seat.TopSurface = Enum.SurfaceType.Smooth
	seat.BottomSurface = Enum.SurfaceType.Smooth
	seat.Parent = m
	part("Back", Vector3.new(7.0, 1.9, 0.38), cf * CFrame.new(0, 1.12, 0.98) * CFrame.Angles(math.rad(-7), 0, 0), C.fabric, Enum.Material.Fabric, true, m, 0)
	for _, xo in ipairs({-3.0, 3.0}) do
		part("Leg", Vector3.new(0.28, 0.72, 0.28), cf * CFrame.new(xo, -0.55, 0), C.brass, Enum.Material.Metal, true, m, 0)
	end
	return m
end

local function loungePlanter(name, x, z)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = lounge
	cylinder("Planter", 1.25, 3.1, CFrame.new(x, 1.75, z), C.graphite, Enum.Material.Concrete, true, m, 0)
	cylinder("Soil", 0.16, 2.55, CFrame.new(x, 2.42, z), C.soil, Enum.Material.Ground, false, m, 0)
	for i = 1, 4 do
		local a = math.rad((i - 1) * 90 + 45)
		local px = x + math.cos(a) * 0.54
		local pz = z + math.sin(a) * 0.54
		part("Stem" .. i, Vector3.new(0.12, 1.5, 0.12), CFrame.new(px, 3.25, pz), C.stone, Enum.Material.Wood, false, m, 0)
		ball("Leaf" .. i, Vector3.new(1.05, 1.45, 0.88), CFrame.new(px, 4.15 + (i % 2) * 0.18, pz), C.leaf, m)
	end
	return m
end

loungeSeat("WestLounge", -23.3, 365, -90)
loungePlanter("WestPlanter", -28.0, 365)
loungeSeat("EastLounge", 23.3, 365, 90)
loungePlanter("EastPlanter", 28.0, 365)

-- Small brass side tables keep the lounge from reading as two isolated benches.
for _, x in ipairs({-20.6, 20.6}) do
	for _, z in ipairs({359.0, 371.0}) do
		cylinder("SideTable", 0.16, 1.55, CFrame.new(x, 2.0, z), C.brass, Enum.Material.Metal, true, lounge, 0)
		cylinder("SideTableBase", 1.05, 0.34, CFrame.new(x, 1.42, z), C.metal, Enum.Material.Metal, true, lounge, 0)
	end
end

-- 5) Give upper atrium rails a restrained metallic cap for clearer floor hierarchy.
local rails = Instance.new("Model")
rails.Name = "AtriumRailCapsV9"
rails.Parent = out
for level = 2, 4 do
	local y = ({[2] = 19.55, [3] = 33.55, [4] = 47.55})[level]
	for _, x in ipairs({-30.15, 30.15}) do
		part("RailCapX_L" .. level, Vector3.new(0.12, 0.12, 53.4), CFrame.new(x, y, 365), C.brass, Enum.Material.Metal, false, rails, 0.08)
	end
	for _, z in ipairs({338.0, 392.0}) do
		part("RailCapZ_L" .. level, Vector3.new(59.7, 0.12, 0.12), CFrame.new(0, y, z), C.brass, Enum.Material.Metal, false, rails, 0.08)
	end
end

mall:SetAttribute("MallPremiumAtmosphere", "V9")
mall:SetAttribute("MallFirstImpression", "PREMIUM_HOSPITALITY_V9")
mall:SetAttribute("MallRetailThresholds", thresholdCount)
out:SetAttribute("RetailThresholdCount", thresholdCount)

print(string.format("[BBYA] Mall Premium Atmosphere v9 online: %d tenant thresholds, refined arrival, social atrium lounge; global Lighting/audio/fishing untouched", thresholdCount))
