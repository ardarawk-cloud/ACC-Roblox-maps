-- BBYA SOCIAL HUB — PREMIUM FISHING LAKE + CORE SYSTEM v1
-- Rear-of-Night-Market fishing district: premium environment, procedural 3D rods/fish,
-- server-authoritative cast/bite/tension gameplay, persistent Lake Tokens, and rod skins.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 35)
if not root then return end
local market = root:WaitForChild("BBYANightMarket", 35)
if not market then return end

task.wait(1.5)
local previous = root:FindFirstChild("PremiumFishingDistrictV1")
if previous then previous:Destroy() end

local district = Instance.new("Model")
district.Name = "PremiumFishingDistrictV1"
district.Parent = root
district:SetAttribute("Pass", "PREMIUM_FISHING_DISTRICT_V1")
district:SetAttribute("MarketRearBoundaryZ", 685)
district:SetAttribute("LakeCenterZ", 790)
district:SetAttribute("SimpleUI", true)
district:SetAttribute("ThreeDFish", true)
district:SetAttribute("ThreeDRods", true)
district:SetAttribute("OriginalCosmetics", true)

local LAKE_CENTER = Vector3.new(0, 0.18, 790)
local LAKE_RX = 112
local LAKE_RZ = 70
local DISTRICT_RADIUS = 225
local WATER_Y = 0.22

local C = {
 dark = Color3.fromRGB(15, 18, 23),
 graphite = Color3.fromRGB(38, 43, 50),
 metal = Color3.fromRGB(82, 88, 94),
 stone = Color3.fromRGB(112, 108, 101),
 stoneDark = Color3.fromRGB(67, 68, 67),
 wood = Color3.fromRGB(112, 76, 49),
 woodDark = Color3.fromRGB(70, 47, 35),
 brass = Color3.fromRGB(205, 164, 91),
 warm = Color3.fromRGB(255, 220, 170),
 white = Color3.fromRGB(242, 242, 240),
 leaf = Color3.fromRGB(52, 91, 61),
 leaf2 = Color3.fromRGB(75, 112, 74),
 water = Color3.fromRGB(27, 83, 101),
 waterDeep = Color3.fromRGB(11, 39, 58),
 cyan = Color3.fromRGB(66, 207, 223),
 pink = Color3.fromRGB(241, 104, 171),
 red = Color3.fromRGB(210, 63, 73),
 gold = Color3.fromRGB(244, 192, 78),
}

local function model(name, parent)
 local m = Instance.new("Model")
 m.Name = name
 m.Parent = parent or district
 return m
end

local function part(name, size, cf, color, material, collide, parent, transparency)
 local p = Instance.new("Part")
 p.Name = name
 p.Size = size
 p.CFrame = cf
 p.Color = color or C.graphite
 p.Material = material or Enum.Material.SmoothPlastic
 p.Anchored = true
 p.CanCollide = collide == true
 p.CanTouch = collide == true
 p.CanQuery = true
 p.Transparency = transparency or 0
 p.TopSurface = Enum.SurfaceType.Smooth
 p.BottomSurface = Enum.SurfaceType.Smooth
 p.CastShadow = p.Transparency < 0.92
 p.Parent = parent or district
 return p
end

local function ball(name, size, cf, color, material, collide, parent, transparency)
 local p = part(name, size, cf, color, material, collide, parent, transparency)
 p.Shape = Enum.PartType.Ball
 return p
end

local function cylinder(name, size, cf, color, material, collide, parent, transparency)
 local p = part(name, size, cf, color, material, collide, parent, transparency)
 p.Shape = Enum.PartType.Cylinder
 return p
end

local function wedge(name, size, cf, color, material, collide, parent, transparency)
 local p = Instance.new("WedgePart")
 p.Name = name
 p.Size = size
 p.CFrame = cf
 p.Color = color or C.graphite
 p.Material = material or Enum.Material.SmoothPlastic
 p.Anchored = true
 p.CanCollide = collide == true
 p.CanTouch = false
 p.CanQuery = true
 p.Transparency = transparency or 0
 p.TopSurface = Enum.SurfaceType.Smooth
 p.BottomSurface = Enum.SurfaceType.Smooth
 p.Parent = parent or district
 return p
end

local function pointLight(parent, brightness, range, color)
 local l = Instance.new("PointLight")
 l.Color = color or C.warm
 l.Brightness = brightness or 0.7
 l.Range = range or 14
 l.Shadows = true
 l.Parent = parent
 return l
end

local function surfaceText(board, title, sub)
 for _, face in ipairs({Enum.NormalId.Front, Enum.NormalId.Back}) do
  local gui = Instance.new("SurfaceGui")
  gui.Face = face
  gui.PixelsPerStud = 55
  gui.LightInfluence = 0.12
  gui.Parent = board
  local bg = Instance.new("Frame")
  bg.Size = UDim2.fromScale(1, 1)
  bg.BackgroundColor3 = C.dark
  bg.BorderSizePixel = 0
  bg.Parent = gui
  local accent = Instance.new("Frame")
  accent.Size = UDim2.new(0, 6, 1, 0)
  accent.BackgroundColor3 = C.brass
  accent.BorderSizePixel = 0
  accent.Parent = bg
  local h = Instance.new("TextLabel")
  h.BackgroundTransparency = 1
  h.Position = UDim2.fromScale(.08, .12)
  h.Size = UDim2.fromScale(.84, .44)
  h.Text = title
  h.TextColor3 = C.white
  h.Font = Enum.Font.GothamBlack
  h.TextScaled = true
  h.TextXAlignment = Enum.TextXAlignment.Left
  h.Parent = bg
  local s = Instance.new("TextLabel")
  s.BackgroundTransparency = 1
  s.Position = UDim2.fromScale(.08, .62)
  s.Size = UDim2.fromScale(.84, .18)
  s.Text = sub
  s.TextColor3 = Color3.fromRGB(184, 181, 174)
  s.Font = Enum.Font.GothamBold
  s.TextScaled = true
  s.TextXAlignment = Enum.TextXAlignment.Left
  s.Parent = bg
 end
end

local function lamp(name, x, z, parent, height)
 height = height or 7.5
 local m = model(name, parent)
 cylinder("Post", Vector3.new(height, .30, .30), CFrame.new(x, 1.1 + height/2, z) * CFrame.Angles(0, 0, math.rad(90)), C.graphite, Enum.Material.Metal, true, m)
 local glow = ball("Glow", Vector3.new(.78, .78, .78), CFrame.new(x, 1.2 + height, z), C.warm, Enum.Material.Glass, false, m, .12)
 pointLight(glow, .72, 15, C.warm)
 return m
end

local function bench(name, cf, parent)
 local m = model(name, parent)
 part("Seat", Vector3.new(6.4, .42, 1.55), cf * CFrame.new(0, 1.45, 0), C.wood, Enum.Material.WoodPlanks, true, m)
 part("Back", Vector3.new(6.4, 2.25, .35), cf * CFrame.new(0, 2.42, .65) * CFrame.Angles(math.rad(-7), 0, 0), C.woodDark, Enum.Material.WoodPlanks, true, m)
 for _, x in ipairs({-2.5, 2.5}) do
  part("Leg" .. tostring(x), Vector3.new(.32, 1.3, 1.15), cf * CFrame.new(x, .72, 0), C.graphite, Enum.Material.Metal, true, m)
 end
 return m
end

local function planter(name, pos, parent)
 local m = model(name, parent)
 cylinder("Pot", Vector3.new(1.9, 3.0, 3.0), CFrame.new(pos.X, 1.25, pos.Z) * CFrame.Angles(0, 0, math.rad(90)), C.stoneDark, Enum.Material.Concrete, true, m)
 cylinder("Trunk", Vector3.new(3.2, .38, .38), CFrame.new(pos.X, 3.2, pos.Z) * CFrame.Angles(0, 0, math.rad(90)), C.woodDark, Enum.Material.Wood, false, m)
 for i = 1, 6 do
  local a = math.rad((i-1) * 60)
  ball("Leaf" .. i, Vector3.new(1.8, 2.3, 1.5), CFrame.new(pos.X + math.cos(a)*1.0, 5.1 + (i%2)*.25, pos.Z + math.sin(a)*1.0), i%2==0 and C.leaf2 or C.leaf, Enum.Material.SmoothPlastic, false, m)
 end
 return m
end

-- Open a deliberate center passage through the late Night Market rear guard if it exists.
local guard = root:FindFirstChild("NightMarketBoundaryLayoutGuardV1")
if guard then
 for _, d in ipairs(guard:GetDescendants()) do
  if d:IsA("BasePart") and d.Position.Z > 679 and d.Position.Z < 685 and math.abs(d.Position.X) < 15 then
   local n = string.lower(d.Name)
   if string.find(n, "rail") or string.find(n, "barrier") or string.find(n, "fence") then
    d:Destroy()
   end
  end
 end
end

-- =============================================================================
-- ENVIRONMENT: landscaped lake, promenade, main pier, rare cove, scenic pier, shop
-- =============================================================================
local env = model("Environment")
part("LakesideGround", Vector3.new(286, 1.2, 205), CFrame.new(0, -1.02, 786), Color3.fromRGB(55, 68, 54), Enum.Material.Ground, true, env)

local deep = ball("DeepWater", Vector3.new(LAKE_RX*2.04, 1.2, LAKE_RZ*2.04), CFrame.new(LAKE_CENTER.X, WATER_Y-.33, LAKE_CENTER.Z), C.waterDeep, Enum.Material.Glass, false, env, .18)
deep.Reflectance = .05
local water = ball("LakeWater", Vector3.new(LAKE_RX*2, .52, LAKE_RZ*2), CFrame.new(LAKE_CENTER.X, WATER_Y, LAKE_CENTER.Z), C.water, Enum.Material.Glass, false, env, .28)
water.Reflectance = .12
water:SetAttribute("BBYAFishingWater", true)

-- Shoreline blocks follow the ellipse tangent, giving the lake a deliberate non-square silhouette.
local shore = model("NaturalStoneShore", env)
local shoreCount = 40
for i = 0, shoreCount-1 do
 local a = (i/shoreCount) * math.pi * 2
 local x = LAKE_CENTER.X + math.cos(a) * (LAKE_RX + 3.5)
 local z = LAKE_CENTER.Z + math.sin(a) * (LAKE_RZ + 3.5)
 local tangent = Vector3.new(-LAKE_RX*math.sin(a), 0, LAKE_RZ*math.cos(a)).Unit
 local yaw = math.atan2(tangent.X, tangent.Z)
 local s = part("ShoreStone" .. i, Vector3.new(13.5 + (i%3)*1.2, 1.6, 6.2), CFrame.new(x, .18, z) * CFrame.Angles(0, yaw, 0), i%2==0 and C.stone or C.stoneDark, Enum.Material.Slate, true, shore)
 s.CornerRadius = nil
end

-- Market-to-lake reveal: centered opening, warm gate and boardwalk.
local approach = model("MarketLakeApproach", env)
part("ApproachDeck", Vector3.new(25, 1.05, 54), CFrame.new(0, .88, 707), C.wood, Enum.Material.WoodPlanks, true, approach)
for _, x in ipairs({-12.8, 12.8}) do
 part("GatePost" .. x, Vector3.new(1.2, 10.5, 1.2), CFrame.new(x, 5.6, 686.5), C.graphite, Enum.Material.Metal, true, approach)
 part("GateBrass" .. x, Vector3.new(1.45, .35, 1.45), CFrame.new(x, 10.7, 686.5), C.brass, Enum.Material.Metal, false, approach)
end
part("GateHeader", Vector3.new(27, 1.0, 1.3), CFrame.new(0, 10.2, 686.5), C.graphite, Enum.Material.Metal, true, approach)
local entrySign = part("EntrySign", Vector3.new(18, 3.3, .36), CFrame.new(0, 8.35, 685.78), C.dark, Enum.Material.Metal, false, approach)
surfaceText(entrySign, "BBYA LAKESIDE", "FISH • RELAX • COLLECT")
for _, z in ipairs({692, 708, 724}) do
 lamp("ApproachLampL"..z, -10.4, z, approach, 6.3)
 lamp("ApproachLampR"..z, 10.4, z, approach, 6.3)
end

-- Main public pier.
local pier = model("MainFishingPier", env)
part("PierDeck", Vector3.new(18, 1.12, 64), CFrame.new(0, 1.0, 751), C.wood, Enum.Material.WoodPlanks, true, pier)
for _, x in ipairs({-9.4, 9.4}) do
 for z = 726, 777, 10 do
  cylinder("PierPost"..x.."_"..z, Vector3.new(4.4, .5, .5), CFrame.new(x, -.05, z) * CFrame.Angles(0,0,math.rad(90)), C.woodDark, Enum.Material.Wood, true, pier)
 end
end
for _, z in ipairs({732, 746, 760, 774}) do
 lamp("PierLampL"..z, -8.0, z, pier, 5.4)
 lamp("PierLampR"..z, 8.0, z, pier, 5.4)
end

-- Front promenade decks for social seating and viewing even when not fishing.
local promenade = model("LakesidePromenade", env)
part("WestDeck", Vector3.new(70, .95, 12), CFrame.new(-53, .9, 724), C.woodDark, Enum.Material.WoodPlanks, true, promenade)
part("EastDeck", Vector3.new(70, .95, 12), CFrame.new(53, .9, 724), C.woodDark, Enum.Material.WoodPlanks, true, promenade)
bench("WestBenchA", CFrame.new(-67, .2, 720) * CFrame.Angles(0, math.rad(180), 0), promenade)
bench("WestBenchB", CFrame.new(-38, .2, 720) * CFrame.Angles(0, math.rad(180), 0), promenade)
bench("EastBenchA", CFrame.new(38, .2, 720) * CFrame.Angles(0, math.rad(180), 0), promenade)
bench("EastBenchB", CFrame.new(67, .2, 720) * CFrame.Angles(0, math.rad(180), 0), promenade)
for _, x in ipairs({-78,-50,-24,24,50,78}) do lamp("PromenadeLamp"..x, x, 730, promenade, 6.0) end

-- Fishing shop: open-front boutique, not a flat booth.
local shop = model("FishingAtelier", env)
part("ShopFloor", Vector3.new(35, .9, 25), CFrame.new(-92, .7, 700), C.stoneDark, Enum.Material.Slate, true, shop)
part("ShopRearWall", Vector3.new(35, 10, 1), CFrame.new(-92, 5.6, 711.7), C.dark, Enum.Material.Concrete, true, shop)
part("ShopLeftWall", Vector3.new(1, 10, 25), CFrame.new(-109, 5.6, 700), C.dark, Enum.Material.Concrete, true, shop)
part("ShopRightPier", Vector3.new(1.2, 10, 4), CFrame.new(-75, 5.6, 709), C.graphite, Enum.Material.Metal, true, shop)
part("ShopCanopy", Vector3.new(36, .75, 26), CFrame.new(-92, 10.65, 700), C.graphite, Enum.Material.Metal, true, shop)
local shopSign = part("ShopSign", Vector3.new(22, 3.0, .38), CFrame.new(-92, 8.6, 687.3), C.dark, Enum.Material.Metal, false, shop)
surfaceText(shopSign, "BBYA ANGLER", "RODS • SKINS • LAKE TOKENS")
for _, x in ipairs({-104,-96,-88,-80}) do
 local d = part("CanopyLight"..x, Vector3.new(.6,.22,.6), CFrame.new(x,10.15,697), C.warm, Enum.Material.Neon, false, shop)
 pointLight(d,.5,10,C.warm)
end

-- Rod display rack uses actual cylindrical multi-segment silhouettes.
local rack = model("RodDisplayRack", shop)
part("RackBack", Vector3.new(22, 6.3, .45), CFrame.new(-92, 4.2, 710.9), C.graphite, Enum.Material.Metal, false, rack)
for i = 1, 5 do
 local x = -102 + (i-1)*5
 local accent = ({C.white, C.pink, C.cyan, C.red, C.gold})[i]
 cylinder("DisplayRodA"..i, Vector3.new(5.8,.18,.18), CFrame.new(x,5.1,710.3)*CFrame.Angles(0,0,math.rad(78)), accent, Enum.Material.Metal, false, rack)
 cylinder("DisplayRodB"..i, Vector3.new(3.7,.11,.11), CFrame.new(x+.8,7.3,710.3)*CFrame.Angles(0,0,math.rad(78)), accent, Enum.Material.Metal, false, rack)
 cylinder("DisplayReel"..i, Vector3.new(.55,.75,.75), CFrame.new(x-.5,3.2,710.0)*CFrame.Angles(0,0,math.rad(90)), C.brass, Enum.Material.Metal, false, rack)
end
local promptAnchor = part("RodCounter", Vector3.new(12, 2.3, 2.6), CFrame.new(-92, 1.9, 689.8), C.woodDark, Enum.Material.WoodPlanks, true, shop)
local getRodPrompt = Instance.new("ProximityPrompt")
getRodPrompt.Name = "GetFishingRod"
getRodPrompt.ActionText = "Ambil Pancing"
getRodPrompt.ObjectText = "BBYA ANGLER"
getRodPrompt.KeyboardKeyCode = Enum.KeyCode.E
getRodPrompt.HoldDuration = .15
getRodPrompt.MaxActivationDistance = 12
getRodPrompt.RequiresLineOfSight = false
getRodPrompt.Parent = promptAnchor

-- Rare cove and scenic pier create exploration and different casting positions.
local rare = model("RareFishingCove", env)
local rareDeck = part("RareCoveDeck", Vector3.new(14, 1.0, 42), CFrame.new(86, 1.0, 812) * CFrame.Angles(0, math.rad(-32), 0), C.woodDark, Enum.Material.WoodPlanks, true, rare)
rareDeck:SetAttribute("FishingSpot", "RARE_COVE")
for _, p in ipairs({Vector3.new(103,0,834),Vector3.new(111,0,815),Vector3.new(105,0,792),Vector3.new(92,0,847)}) do planter("CovePlanter"..math.floor(p.X+p.Z), p, rare) end
local rareSign = part("RareSign", Vector3.new(9, 2.6, .3), CFrame.new(93, 5.0, 786) * CFrame.Angles(0, math.rad(28), 0), C.dark, Enum.Material.Metal, false, rare)
surfaceText(rareSign, "MOON COVE", "RARE WATER")

local scenic = model("ScenicPier", env)
local scenicDeck = part("ScenicDeck", Vector3.new(15, 1.0, 44), CFrame.new(-88, 1.0, 816) * CFrame.Angles(0, math.rad(30), 0), C.wood, Enum.Material.WoodPlanks, true, scenic)
scenicDeck:SetAttribute("FishingSpot", "SCENIC_PIER")
bench("ScenicBench", CFrame.new(-100, .2, 837) * CFrame.Angles(0, math.rad(145), 0), scenic)
lamp("ScenicLampA", -94, 829, scenic, 5.8)
lamp("ScenicLampB", -81, 803, scenic, 5.8)

-- Showcase a few high-tier fish in 3D at the shop entrance.
local showcase = model("FishShowcase", shop)
for i, spec in ipairs({
 {"CRIMSON AROWANA", CFrame.new(-103,3.0,687.2), Color3.fromRGB(205,54,67), Color3.fromRGB(255,161,88)},
 {"AURORA ARAPAIMA", CFrame.new(-92,3.0,687.2), Color3.fromRGB(74,105,147), Color3.fromRGB(89,235,218)},
 {"CELESTIAL KOI", CFrame.new(-81,3.0,687.2), Color3.fromRGB(238,236,222), Color3.fromRGB(242,192,68)},
}) do
 local body = ball("ShowcaseBody"..i, Vector3.new(6.3,2.4,2.1), spec[2], spec[3], Enum.Material.SmoothPlastic, false, showcase)
 wedge("ShowcaseTailA"..i, Vector3.new(2.3,2.7,.35), spec[2]*CFrame.new(-3.5,.45,0)*CFrame.Angles(0,math.rad(90),0), spec[4], Enum.Material.SmoothPlastic, false, showcase)
 wedge("ShowcaseTailB"..i, Vector3.new(2.3,2.7,.35), spec[2]*CFrame.new(-3.5,-.45,0)*CFrame.Angles(math.rad(180),math.rad(90),0), spec[4], Enum.Material.SmoothPlastic, false, showcase)
 ball("ShowcaseEye"..i, Vector3.new(.38,.38,.38), spec[2]*CFrame.new(2.4,.45,-.9), Color3.new(0,0,0), Enum.Material.SmoothPlastic, false, showcase)
 body:SetAttribute("FishName", spec[1])
end

-- =============================================================================
-- GAME DATA
-- =============================================================================
local remotes = ReplicatedStorage:FindFirstChild("BBYAFishingRemotes") or Instance.new("Folder")
remotes.Name = "BBYAFishingRemotes"
remotes.Parent = ReplicatedStorage
local actionRemote = remotes:FindFirstChild("Action") or Instance.new("RemoteEvent")
actionRemote.Name = "Action"
actionRemote.Parent = remotes
local stateRemote = remotes:FindFirstChild("State") or Instance.new("RemoteEvent")
stateRemote.Name = "State"
stateRemote.Parent = remotes

local SKINS = {
 {name="Graphite Core", rarity="COMMON", price=0, required=0, body=Color3.fromRGB(35,39,46), accent=Color3.fromRGB(185,190,197), reel=Color3.fromRGB(84,88,96), material=Enum.Material.Metal},
 {name="Pearl Tide", rarity="UNCOMMON", price=300, required=3, body=Color3.fromRGB(232,234,230), accent=Color3.fromRGB(94,205,219), reel=Color3.fromRGB(176,183,188), material=Enum.Material.SmoothPlastic},
 {name="Sakura Koi", rarity="RARE", price=750, required=8, body=Color3.fromRGB(246,208,222), accent=Color3.fromRGB(239,91,160), reel=Color3.fromRGB(238,188,96), material=Enum.Material.SmoothPlastic},
 {name="Neon Circuit", rarity="RARE", price=1400, required=15, body=Color3.fromRGB(22,28,34), accent=Color3.fromRGB(55,229,226), reel=Color3.fromRGB(87,98,107), material=Enum.Material.Metal},
 {name="Crimson Dragon", rarity="EPIC", price=2600, required=28, body=Color3.fromRGB(86,22,26), accent=Color3.fromRGB(238,66,67), reel=Color3.fromRGB(204,145,72), material=Enum.Material.Metal},
 {name="Celestial Moon", rarity="EPIC", price=4200, required=45, body=Color3.fromRGB(41,47,76), accent=Color3.fromRGB(178,199,255), reel=Color3.fromRGB(220,222,230), material=Enum.Material.Metal},
 {name="Poseidon Crown", rarity="LEGENDARY", price=6500, required=70, body=Color3.fromRGB(18,65,86), accent=Color3.fromRGB(52,218,207), reel=Color3.fromRGB(224,180,84), material=Enum.Material.Metal},
 {name="Phantom Leviathan", rarity="LEGENDARY", price=10000, required=110, body=Color3.fromRGB(24,18,39), accent=Color3.fromRGB(153,94,231), reel=Color3.fromRGB(91,77,126), material=Enum.Material.Metal},
 {name="BBYA Royal", rarity="MYTHIC", price=16000, required=175, body=Color3.fromRGB(19,19,23), accent=Color3.fromRGB(244,182,82), reel=Color3.fromRGB(235,193,101), material=Enum.Material.Metal},
}
local skinByName = {}
for _, s in ipairs(SKINS) do skinByName[s.name] = s end

local FISH = {
 {name="Moon Carp", rarity="COMMON", weight=32, min=0.7, max=2.4, value=18, body=Color3.fromRGB(165,183,188), accent=Color3.fromRGB(224,232,231), shape="STANDARD"},
 {name="Azure Gourami", rarity="COMMON", weight=29, min=0.5, max=1.9, value=20, body=Color3.fromRGB(65,145,181), accent=Color3.fromRGB(96,215,218), shape="STANDARD"},
 {name="Jade Peacock Bass", rarity="UNCOMMON", weight=14, min=1.2, max=4.8, value=42, body=Color3.fromRGB(70,132,79), accent=Color3.fromRGB(193,207,64), shape="STANDARD"},
 {name="Redtail Giant", rarity="UNCOMMON", weight=12, min=2.2, max=8.5, value=55, body=Color3.fromRGB(68,74,82), accent=Color3.fromRGB(214,62,58), shape="CATFISH"},
 {name="Royal Koi", rarity="RARE", weight=5.4, min=1.0, max=5.0, value=105, body=Color3.fromRGB(239,236,219), accent=Color3.fromRGB(228,111,58), shape="KOI"},
 {name="Sapphire Barramundi", rarity="RARE", weight=4.4, min=3.0, max=11.0, value=125, body=Color3.fromRGB(83,119,151), accent=Color3.fromRGB(158,208,224), shape="STANDARD"},
 {name="Crimson Arowana", rarity="EPIC", weight=1.8, min=2.4, max=7.2, value=260, body=Color3.fromRGB(185,42,54), accent=Color3.fromRGB(247,143,78), shape="LONG"},
 {name="Obsidian Ray", rarity="EPIC", weight=1.45, min=4.0, max=15.0, value=300, body=Color3.fromRGB(34,31,42), accent=Color3.fromRGB(111,84,145), shape="RAY"},
 {name="Golden Mahseer", rarity="LEGENDARY", weight=.48, min=5.0, max=18.0, value=700, body=Color3.fromRGB(169,120,40), accent=Color3.fromRGB(246,205,91), shape="STANDARD"},
 {name="Aurora Arapaima", rarity="LEGENDARY", weight=.34, min=9.0, max=31.0, value=900, body=Color3.fromRGB(55,83,126), accent=Color3.fromRGB(72,224,206), shape="LONG"},
 {name="Celestial Koi", rarity="MYTHIC", weight=.075, min=3.0, max=10.0, value=2400, body=Color3.fromRGB(235,236,229), accent=Color3.fromRGB(240,190,68), shape="KOI"},
 {name="Phantom Leviathan", rarity="MYTHIC", weight=.035, min=18.0, max=55.0, value=4200, body=Color3.fromRGB(42,31,67), accent=Color3.fromRGB(132,82,216), shape="LEVIATHAN"},
}
local RARITY_DIFFICULTY = {COMMON=.64, UNCOMMON=.76, RARE=.91, EPIC=1.08, LEGENDARY=1.25, MYTHIC=1.42}
local RARITY_MULT = {COMMON=1, UNCOMMON=1.1, RARE=1.25, EPIC=1.45, LEGENDARY=1.7, MYTHIC=2.1}

local fishStore = DataStoreService:GetDataStore("BBYA_FISHING_V1")
local dataByUser = {}
local sessions = {}

local function defaultData()
 return {tokens=0,total=0,best=0,equipped="Graphite Core",unlocked={['Graphite Core']=true}}
end

local function normalizeData(raw)
 local d = defaultData()
 if type(raw) == "table" then
  d.tokens = math.max(0, math.floor(tonumber(raw.tokens) or 0))
  d.total = math.max(0, math.floor(tonumber(raw.total) or 0))
  d.best = math.max(0, tonumber(raw.best) or 0)
  if type(raw.unlocked) == "table" then
   for name, value in pairs(raw.unlocked) do
    if value == true and skinByName[name] then d.unlocked[name] = true end
   end
  end
  if type(raw.equipped) == "string" and d.unlocked[raw.equipped] and skinByName[raw.equipped] then d.equipped = raw.equipped end
 end
 return d
end

local function publishAttributes(player, d)
 player:SetAttribute("BBYAFishingTokens", d.tokens)
 player:SetAttribute("BBYAFishingTotal", d.total)
 player:SetAttribute("BBYAFishingBestWeight", math.floor(d.best*100)/100)
 player:SetAttribute("BBYAFishingSkin", d.equipped)
end

local function loadData(player)
 local raw
 local ok = pcall(function() raw = fishStore:GetAsync("u_"..player.UserId) end)
 local d = normalizeData(ok and raw or nil)
 dataByUser[player.UserId] = d
 publishAttributes(player, d)
end

local function saveData(player)
 local d = dataByUser[player.UserId]
 if not d then return end
 pcall(function() fishStore:SetAsync("u_"..player.UserId, d) end)
end

local function skinSnapshot(d)
 local list = {}
 for _, s in ipairs(SKINS) do
  table.insert(list, {name=s.name,rarity=s.rarity,price=s.price,required=s.required,unlocked=d.unlocked[s.name]==true,equipped=d.equipped==s.name})
 end
 return list
end

local function sendSnapshot(player)
 local d = dataByUser[player.UserId]
 if not d then return end
 stateRemote:FireClient(player, "Snapshot", {tokens=d.tokens,total=d.total,best=math.floor(d.best*100)/100,equipped=d.equipped,skins=skinSnapshot(d)})
end

local function weld(base, child)
 child.Anchored = false
 child.CanCollide = false
 child.CanTouch = false
 child.CanQuery = false
 child.Massless = true
 local w = Instance.new("WeldConstraint")
 w.Part0 = base
 w.Part1 = child
 w.Parent = child
end

local function toolCylinder(name, size, cf, parent, role)
 local p = Instance.new("Part")
 p.Name = name
 p.Shape = Enum.PartType.Cylinder
 p.Size = size
 p.CFrame = cf
 p.Material = Enum.Material.Metal
 p.Color = C.graphite
 p.Anchored = false
 p.CanCollide = false
 p.CanTouch = false
 p.CanQuery = false
 p.Massless = true
 p.TopSurface = Enum.SurfaceType.Smooth
 p.BottomSurface = Enum.SurfaceType.Smooth
 p:SetAttribute("RodRole", role)
 p.Parent = parent
 return p
end

local function applySkin(tool, skinName)
 local s = skinByName[skinName] or SKINS[1]
 for _, d in ipairs(tool:GetDescendants()) do
  if d:IsA("BasePart") then
   local role = d:GetAttribute("RodRole")
   if role == "BODY" then d.Color=s.body;d.Material=s.material
   elseif role == "ACCENT" then d.Color=s.accent;d.Material=(s.rarity=="LEGENDARY" or s.rarity=="MYTHIC") and Enum.Material.Neon or s.material
   elseif role == "REEL" then d.Color=s.reel;d.Material=Enum.Material.Metal
   elseif role == "GRIP" then d.Color=Color3.fromRGB(37,31,30);d.Material=Enum.Material.Fabric end
  end
 end
 local old = tool:FindFirstChild("SkinLight", true)
 if old and old:IsA("PointLight") then old:Destroy() end
 if s.rarity == "LEGENDARY" or s.rarity == "MYTHIC" then
  local tipPart = tool:FindFirstChild("TipSegment")
  if tipPart then
   local light = Instance.new("PointLight")
   light.Name="SkinLight";light.Color=s.accent;light.Brightness=.45;light.Range=5;light.Shadows=false;light.Parent=tipPart
  end
 end
 tool:SetAttribute("RodSkin", s.name)
 tool:SetAttribute("RodSkinRarity", s.rarity)
end

local function createRod(player)
 local tool = Instance.new("Tool")
 tool.Name = "BBYA Fishing Rod"
 tool.RequiresHandle = true
 tool.CanBeDropped = false
 tool:SetAttribute("BBYAFishingRod", true)
 tool.ToolTip = "BBYA Lakeside Fishing"

 local baseCF = CFrame.new(0, 1000, 0)
 local handle = toolCylinder("Handle", Vector3.new(2.4,.34,.34), baseCF, tool, "GRIP")
 local body1 = toolCylinder("RodSegment1", Vector3.new(2.8,.24,.24), baseCF*CFrame.new(2.55,0,0), tool, "BODY")
 local accent1 = toolCylinder("AccentRing1", Vector3.new(.20,.32,.32), baseCF*CFrame.new(1.25,0,0), tool, "ACCENT")
 local body2 = toolCylinder("RodSegment2", Vector3.new(2.35,.17,.17), baseCF*CFrame.new(5.1,0,0), tool, "BODY")
 local accent2 = toolCylinder("AccentRing2", Vector3.new(.14,.24,.24), baseCF*CFrame.new(4.05,0,0), tool, "ACCENT")
 local tip = toolCylinder("TipSegment", Vector3.new(1.8,.10,.10), baseCF*CFrame.new(7.15,0,0), tool, "ACCENT")
 local reel = toolCylinder("ReelSpool", Vector3.new(.62,.92,.92), baseCF*CFrame.new(.35,-.48,0)*CFrame.Angles(0,0,math.rad(90)), tool, "REEL")
 local reelArm = toolCylinder("ReelArm", Vector3.new(.85,.13,.13), baseCF*CFrame.new(.15,-.92,0)*CFrame.Angles(0,0,math.rad(35)), tool, "REEL")
 local knob = Instance.new("Part")
 knob.Name="ReelKnob";knob.Shape=Enum.PartType.Ball;knob.Size=Vector3.new(.28,.28,.28);knob.CFrame=baseCF*CFrame.new(-.15,-1.2,0);knob:SetAttribute("RodRole","GRIP");knob.Parent=tool
 knob.Anchored=false;knob.CanCollide=false;knob.CanTouch=false;knob.CanQuery=false;knob.Massless=true

 for _, p in ipairs({body1,accent1,body2,accent2,tip,reel,reelArm,knob}) do weld(handle,p) end
 local att = Instance.new("Attachment")
 att.Name="LineTip";att.Position=Vector3.new(tip.Size.X/2,0,0);att.Parent=tip
 tool.Grip = CFrame.new(0,-.45,0) * CFrame.Angles(0,0,math.rad(68))
 local d = dataByUser[player.UserId] or defaultData()
 applySkin(tool, d.equipped)
 tool.Parent = player:WaitForChild("Backpack")
 return tool
end

local function findRod(player)
 local char = player.Character
 if char then
  for _, item in ipairs(char:GetChildren()) do if item:IsA("Tool") and item:GetAttribute("BBYAFishingRod") then return item end end
 end
 local backpack = player:FindFirstChildOfClass("Backpack")
 if backpack then
  for _, item in ipairs(backpack:GetChildren()) do if item:IsA("Tool") and item:GetAttribute("BBYAFishingRod") then return item end end
 end
 return nil
end

local function grantRod(player, equip)
 local rod = findRod(player) or createRod(player)
 if equip and player.Character then
  local hum = player.Character:FindFirstChildOfClass("Humanoid")
  if hum then hum:EquipTool(rod) end
 end
 return rod
end

getRodPrompt.Triggered:Connect(function(player)
 grantRod(player, true)
 stateRemote:FireClient(player, "Toast", {text="Pancing siap. Pilih skin dari ROD."})
 sendSnapshot(player)
end)

local function inDistrict(player)
 local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not hrp then return false end
 local dx = hrp.Position.X - LAKE_CENTER.X
 local dz = hrp.Position.Z - LAKE_CENTER.Z
 return (dx*dx + dz*dz) <= DISTRICT_RADIUS*DISTRICT_RADIUS
end

local function insideLake(pos, margin)
 margin = margin or .92
 local dx = (pos.X-LAKE_CENTER.X)/(LAKE_RX*margin)
 local dz = (pos.Z-LAKE_CENTER.Z)/(LAKE_RZ*margin)
 return dx*dx + dz*dz <= 1
end

local function castTarget(player)
 local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not hrp then return nil end
 local target = hrp.Position + hrp.CFrame.LookVector * 52
 target = Vector3.new(target.X, WATER_Y+.8, target.Z)
 if not insideLake(target, .90) then
  local toward = Vector3.new(LAKE_CENTER.X-hrp.Position.X,0,LAKE_CENTER.Z-hrp.Position.Z)
  if toward.Magnitude > 1 then
   target = hrp.Position + toward.Unit * math.min(64, toward.Magnitude*.72)
   target = Vector3.new(target.X, WATER_Y+.8, target.Z)
  end
 end
 if not insideLake(target, .90) then
  local v = Vector3.new(target.X-LAKE_CENTER.X,0,target.Z-LAKE_CENTER.Z)
  local scale = math.max(math.abs(v.X)/(LAKE_RX*.82), math.abs(v.Z)/(LAKE_RZ*.82), 1)
  target = Vector3.new(LAKE_CENTER.X+v.X/scale, WATER_Y+.8, LAKE_CENTER.Z+v.Z/scale)
 end
 return target
end

local function createBobber(tool, target)
 local m = model("ActiveBobber", district)
 local body = ball("Float", Vector3.new(.7,.7,.7), CFrame.new(target), Color3.fromRGB(238,239,234), Enum.Material.SmoothPlastic, false, m)
 ball("FloatTop", Vector3.new(.42,.42,.42), CFrame.new(target+Vector3.new(0,.35,0)), C.red, Enum.Material.SmoothPlastic, false, m)
 cylinder("Stem", Vector3.new(1.1,.10,.10), CFrame.new(target+Vector3.new(0,.55,0))*CFrame.Angles(0,0,math.rad(90)), C.graphite, Enum.Material.Metal, false, m)
 local bobAtt = Instance.new("Attachment");bobAtt.Name="LineEnd";bobAtt.Parent=body
 local tipAtt = tool:FindFirstChild("LineTip", true)
 local beam
 if tipAtt and tipAtt:IsA("Attachment") then
  beam = Instance.new("Beam")
  beam.Name="FishingLine";beam.Attachment0=tipAtt;beam.Attachment1=bobAtt;beam.Width0=.035;beam.Width1=.025;beam.FaceCamera=true
  beam.Color=ColorSequence.new(Color3.fromRGB(224,228,229));beam.Transparency=NumberSequence.new(.1);beam.Parent=tipAtt
 end
 return m, beam
end

local function cleanupSession(player)
 local s = sessions[player]
 if not s then return end
 if s.beam then pcall(function() s.beam:Destroy() end) end
 if s.bobber then pcall(function() s.bobber:Destroy() end) end
 sessions[player] = nil
end

local function rareBoostFor(player)
 local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not hrp then return 1 end
 if hrp.Position.X > 58 and hrp.Position.Z > 775 then return 2.2 end
 return 1
end

local function pickFish(player)
 local boost = rareBoostFor(player)
 local total = 0
 for _, f in ipairs(FISH) do
  local w = f.weight
  if f.rarity=="RARE" or f.rarity=="EPIC" then w=w*boost
  elseif f.rarity=="LEGENDARY" or f.rarity=="MYTHIC" then w=w*(1+(boost-1)*.6) end
  total += w
 end
 local roll = math.random()*total
 local acc = 0
 for _, f in ipairs(FISH) do
  local w = f.weight
  if f.rarity=="RARE" or f.rarity=="EPIC" then w=w*boost
  elseif f.rarity=="LEGENDARY" or f.rarity=="MYTHIC" then w=w*(1+(boost-1)*.6) end
  acc += w
  if roll <= acc then return f end
 end
 return FISH[1]
end

local function createFishVisual(fish, weight, cf)
 local m = model("Catch_"..string.gsub(fish.name," ",""), district)
 m:SetAttribute("FishName",fish.name);m:SetAttribute("Rarity",fish.rarity);m:SetAttribute("Weight",weight)
 local scale = math.clamp(.72 + weight/(fish.max*1.8), .8, 1.45)
 local bodySize
 if fish.shape=="LONG" or fish.shape=="LEVIATHAN" then bodySize=Vector3.new(7.4,2.1,2.0)*scale
 elseif fish.shape=="RAY" then bodySize=Vector3.new(5.7,1.0,5.0)*scale
 else bodySize=Vector3.new(5.4,2.45,2.05)*scale end
 local body = ball("Body", bodySize, cf, fish.body, fish.rarity=="MYTHIC" and Enum.Material.Neon or Enum.Material.SmoothPlastic, false, m)
 m.PrimaryPart = body
 local backX = -bodySize.X*.52
 if fish.shape=="RAY" then
  wedge("WingL",Vector3.new(4.8,.7,3.2)*scale,cf*CFrame.new(-.2,0,2.8*scale)*CFrame.Angles(0,math.rad(180),0),fish.body,Enum.Material.SmoothPlastic,false,m)
  wedge("WingR",Vector3.new(4.8,.7,3.2)*scale,cf*CFrame.new(-.2,0,-2.8*scale),fish.body,Enum.Material.SmoothPlastic,false,m)
  cylinder("RayTail",Vector3.new(5.2*scale,.12,.12),cf*CFrame.new(backX-2.2*scale,0,0),fish.accent,Enum.Material.SmoothPlastic,false,m)
 else
  wedge("TailTop",Vector3.new(2.3,2.7,.42)*scale,cf*CFrame.new(backX-1.0*scale,.55*scale,0)*CFrame.Angles(0,math.rad(90),0),fish.accent,Enum.Material.SmoothPlastic,false,m)
  wedge("TailBottom",Vector3.new(2.3,2.7,.42)*scale,cf*CFrame.new(backX-1.0*scale,-.55*scale,0)*CFrame.Angles(math.rad(180),math.rad(90),0),fish.accent,Enum.Material.SmoothPlastic,false,m)
  wedge("Dorsal",Vector3.new(1.9,1.25,.32)*scale,cf*CFrame.new(-.4*scale,bodySize.Y*.48,0)*CFrame.Angles(0,math.rad(90),0),fish.accent,Enum.Material.SmoothPlastic,false,m)
  wedge("FinL",Vector3.new(1.5,.32,1.2)*scale,cf*CFrame.new(.2*scale,-.15*scale,bodySize.Z*.48)*CFrame.Angles(math.rad(-18),0,0),fish.accent,Enum.Material.SmoothPlastic,false,m)
  wedge("FinR",Vector3.new(1.5,.32,1.2)*scale,cf*CFrame.new(.2*scale,-.15*scale,-bodySize.Z*.48)*CFrame.Angles(math.rad(198),0,0),fish.accent,Enum.Material.SmoothPlastic,false,m)
 end
 local eyeX = bodySize.X*.35
 local eyeZ = bodySize.Z*.47
 for _, z in ipairs({-eyeZ,eyeZ}) do
  ball("Eye",Vector3.new(.34,.34,.34)*scale,cf*CFrame.new(eyeX,bodySize.Y*.18,z),Color3.fromRGB(8,9,10),Enum.Material.SmoothPlastic,false,m)
  ball("EyeGlint",Vector3.new(.11,.11,.11)*scale,cf*CFrame.new(eyeX+.06*scale,bodySize.Y*.23,z+(z>0 and .10 or -.10)*scale),C.white,Enum.Material.Neon,false,m)
 end
 if fish.shape=="CATFISH" then
  for _, sy in ipairs({-.35,.35}) do
   cylinder("Whisker",Vector3.new(2.3,.05,.05)*scale,cf*CFrame.new(bodySize.X*.47,-.15*scale,sy*bodySize.Z)*CFrame.Angles(0,math.rad(sy>0 and 25 or -25),math.rad(8)),fish.accent,Enum.Material.SmoothPlastic,false,m)
  end
 end
 if fish.shape=="LEVIATHAN" then
  for i=1,4 do
   wedge("Spine"..i,Vector3.new(1.1,1.0,.3)*scale,cf*CFrame.new(-2.2*scale+i*1.1*scale,bodySize.Y*.50,0)*CFrame.Angles(0,math.rad(90),0),fish.accent,Enum.Material.Neon,false,m)
  end
 end
 if fish.rarity=="LEGENDARY" or fish.rarity=="MYTHIC" then
  local h=Instance.new("Highlight");h.FillColor=fish.accent;h.FillTransparency=.83;h.OutlineColor=fish.accent;h.OutlineTransparency=.20;h.DepthMode=Enum.HighlightDepthMode.Occluded;h.Parent=m
 end
 return m
end

local function showCatch(player, fish, weight)
 local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not hrp then return end
 local base = CFrame.new(hrp.Position + hrp.CFrame.RightVector*4 + Vector3.new(0,4.1,0)) * CFrame.Angles(0, math.rad(18), 0)
 local visual = createFishVisual(fish, weight, base)
 task.spawn(function()
  local start = os.clock()
  while visual.Parent and os.clock()-start < 4.2 do
   local t=os.clock()-start
   visual:PivotTo(base*CFrame.new(0,math.sin(t*3)*.18,0)*CFrame.Angles(0,math.sin(t*2)*.08,0))
   task.wait(.05)
  end
  if visual.Parent then visual:Destroy() end
 end)
end

local function failFight(player, reason)
 cleanupSession(player)
 stateRemote:FireClient(player,"Escaped",{text=reason or "Ikan lepas."})
 task.delay(.65,function() if player.Parent then stateRemote:FireClient(player,"Idle",{}) end end)
end

local function finishCatch(player, fish)
 local d = dataByUser[player.UserId]
 if not d then failFight(player,"Data belum siap.");return end
 local weight = fish.min + math.random()*(fish.max-fish.min)
 weight = math.floor(weight*100)/100
 local reward = math.max(1, math.floor(fish.value * (0.72 + weight/fish.max*.55) * (RARITY_MULT[fish.rarity] or 1)))
 d.total += 1
 d.tokens += reward
 d.best = math.max(d.best, weight)
 publishAttributes(player,d)
 cleanupSession(player)
 showCatch(player,fish,weight)
 stateRemote:FireClient(player,"Catch",{name=fish.name,rarity=fish.rarity,weight=weight,reward=reward,tokens=d.tokens,total=d.total,best=d.best})
 task.delay(.9,function() if player.Parent then stateRemote:FireClient(player,"Idle",{}) end end)
 if d.total%5==0 then task.spawn(saveData,player) end
end

local function startCast(player)
 if not inDistrict(player) then stateRemote:FireClient(player,"Toast",{text="Dekati danau untuk mancing."});return end
 if sessions[player] then return end
 local rod=grantRod(player,true)
 if not rod then return end
 local target=castTarget(player)
 if not target then return end
 local bobber,beam=createBobber(rod,target)
 local s={state="WAITING",rod=rod,bobber=bobber,beam=beam,target=target}
 sessions[player]=s
 stateRemote:FireClient(player,"Waiting",{})
 local waitTime=2.2+math.random()*3.1
 task.delay(waitTime,function()
  if sessions[player]~=s or s.state~="WAITING" then return end
  s.fish=pickFish(player);s.state="BITE";s.biteDeadline=os.clock()+2.35
  stateRemote:FireClient(player,"Bite",{})
  task.delay(2.4,function()
   if sessions[player]==s and s.state=="BITE" then failFight(player,"Strike terlambat — ikan lepas.") end
  end)
 end)
end

local function hookFish(player)
 local s=sessions[player]
 if not s or s.state~="BITE" or not s.fish then return end
 if os.clock()>(s.biteDeadline or 0) then failFight(player,"Strike terlambat — ikan lepas.");return end
 s.state="FIGHT";s.progress=0;s.tension=.20;s.reeling=false;s.lastPush=0
 s.difficulty=RARITY_DIFFICULTY[s.fish.rarity] or .8
 stateRemote:FireClient(player,"Fight",{rarity=s.fish.rarity,progress=0,tension=s.tension})
end

RunService.Heartbeat:Connect(function(dt)
 dt=math.min(dt,.12)
 local now=os.clock()
 for player,s in pairs(sessions) do
  if s.state=="FIGHT" then
   if not player.Parent or not inDistrict(player) then failFight(player,"Keluar dari area mancing.")
   else
    local pressure=.78+.20*math.sin(now*2.3+player.UserId%17)+.12*math.sin(now*5.1+player.UserId%11)
    pressure=math.max(.42,pressure)
    if s.reeling then
     s.progress=math.clamp(s.progress+dt*(.31/s.difficulty),0,1)
     s.tension=math.clamp(s.tension+dt*(.36*s.difficulty*pressure),0,1.2)
    else
     s.progress=math.clamp(s.progress-dt*(.028*s.difficulty),0,1)
     s.tension=math.clamp(s.tension-dt*.49+dt*.035*s.difficulty*pressure,0,1.2)
    end
    if s.tension>=1 then failFight(player,"Tali terlalu tegang — ikan lepas.")
    elseif s.progress>=1 then finishCatch(player,s.fish)
    elseif now-(s.lastPush or 0)>.10 then
     s.lastPush=now
     stateRemote:FireClient(player,"FightTick",{progress=s.progress,tension=s.tension})
    end
   end
  end
 end
end)

actionRemote.OnServerEvent:Connect(function(player, action, payload)
 if type(action)~="string" then return end
 local d=dataByUser[player.UserId]
 if action=="Snapshot" then sendSnapshot(player);return end
 if not d then return end
 if action=="GetRod" then grantRod(player,true);sendSnapshot(player);return end
 if action=="Cast" then startCast(player);return end
 if action=="Hook" then hookFish(player);return end
 if action=="Reel" then
  local s=sessions[player]
  if s and s.state=="FIGHT" then s.reeling=payload==true end
  return
 end
 if action=="EquipSkin" and type(payload)=="string" then
  if d.unlocked[payload] and skinByName[payload] then
   d.equipped=payload;publishAttributes(player,d)
   local rod=findRod(player);if rod then applySkin(rod,payload) end
   sendSnapshot(player);stateRemote:FireClient(player,"Toast",{text=payload.." dipakai."})
  end
  return
 end
 if action=="BuySkin" and type(payload)=="string" then
  local skin=skinByName[payload]
  if not skin then return end
  if d.unlocked[payload] then d.equipped=payload;local rod=findRod(player);if rod then applySkin(rod,payload) end;sendSnapshot(player);return end
  if d.total < skin.required then stateRemote:FireClient(player,"Toast",{text="Butuh "..skin.required.." tangkapan."});return end
  if d.tokens < skin.price then stateRemote:FireClient(player,"Toast",{text="Lake Token belum cukup."});return end
  d.tokens-=skin.price;d.unlocked[payload]=true;d.equipped=payload;publishAttributes(player,d)
  local rod=findRod(player);if rod then applySkin(rod,payload) end
  task.spawn(saveData,player);sendSnapshot(player);stateRemote:FireClient(player,"Toast",{text="Skin "..payload.." terbuka."})
 end
end)

local function setupPlayer(player)
 task.spawn(function()
  loadData(player)
  task.wait(.2)
  sendSnapshot(player)
 end)
 player.CharacterAdded:Connect(function()
  task.wait(1.0)
  local d=dataByUser[player.UserId]
  if d then publishAttributes(player,d) end
 end)
end

for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
 cleanupSession(player);saveData(player);dataByUser[player.UserId]=nil
end)

task.spawn(function()
 while task.wait(90) do
  for _, player in ipairs(Players:GetPlayers()) do task.spawn(saveData,player) end
 end
end)

game:BindToClose(function()
 for _, player in ipairs(Players:GetPlayers()) do saveData(player) end
end)

district:SetAttribute("InstalledDescendants", #district:GetDescendants())
print("[BBYA] Premium Fishing District v1 online: lakeside + 3D rods/fish + tension fishing + persistent skins")
