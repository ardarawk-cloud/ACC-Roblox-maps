-- BBYA SOCIAL HUB — FISHING PREMIUM UPGRADE v3
-- Additive visual pass over the stable v2 fishing district.
-- No global Lighting, audio, monetization, role, club, mall, or travel changes.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 35)
if not root then return end
local district = root:WaitForChild("PremiumFishingDistrictV2", 35)
if not district then return end

task.wait(1.2)
local old = district:FindFirstChild("PremiumFishingUpgradeV3")
if old then old:Destroy() end

local out = Instance.new("Model")
out.Name = "PremiumFishingUpgradeV3"
out.Parent = district
out:SetAttribute("Pass", "PREMIUM_FISHING_UPGRADE_V3")
out:SetAttribute("AdditiveOnly", true)
out:SetAttribute("GlobalLightingUntouched", true)
out:SetAttribute("AudioInjected", false)
out:SetAttribute("HeroAssets3D", true)
out:SetAttribute("AmbientFishSchools", 4)
out:SetAttribute("WaterfallGrotto", true)
out:SetAttribute("MoonCoveSignature", true)
out:SetAttribute("PhotoPierSignature", true)

local C = {
 dark = Color3.fromRGB(15, 18, 23),
 charcoal = Color3.fromRGB(28, 32, 38),
 graphite = Color3.fromRGB(48, 52, 58),
 metal = Color3.fromRGB(90, 95, 101),
 stone = Color3.fromRGB(92, 92, 87),
 stoneDark = Color3.fromRGB(55, 58, 58),
 wood = Color3.fromRGB(103, 70, 46),
 woodDark = Color3.fromRGB(66, 44, 32),
 brass = Color3.fromRGB(218, 174, 89),
 warm = Color3.fromRGB(255, 218, 160),
 white = Color3.fromRGB(241, 243, 242),
 leaf = Color3.fromRGB(48, 92, 63),
 leaf2 = Color3.fromRGB(68, 116, 78),
 moss = Color3.fromRGB(62, 90, 64),
 aqua = Color3.fromRGB(74, 211, 220),
 blue = Color3.fromRGB(53, 132, 174),
 moon = Color3.fromRGB(174, 198, 247),
 violet = Color3.fromRGB(142, 99, 220),
 pink = Color3.fromRGB(232, 102, 168),
 gold = Color3.fromRGB(242, 191, 81),
}

local function model(name, parent)
 local m = Instance.new("Model")
 m.Name = name
 m.Parent = parent or out
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
 p.CanTouch = false
 p.CanQuery = true
 p.Transparency = transparency or 0
 p.TopSurface = Enum.SurfaceType.Smooth
 p.BottomSurface = Enum.SurfaceType.Smooth
 p.CastShadow = p.Transparency < .9
 p.Parent = parent or out
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
 p.Parent = parent or out
 return p
end

local function pointLight(parent, brightness, range, color)
 local l = Instance.new("PointLight")
 l.Color = color or C.warm
 l.Brightness = brightness or .55
 l.Range = range or 13
 l.Shadows = false
 l.Parent = parent
 return l
end

local function signFace(board, title, sub)
 local gui = Instance.new("SurfaceGui")
 gui.Face = Enum.NormalId.Front
 gui.PixelsPerStud = 60
 gui.LightInfluence = .1
 gui.Parent = board
 local bg = Instance.new("Frame")
 bg.Size = UDim2.fromScale(1, 1)
 bg.BackgroundColor3 = C.dark
 bg.BorderSizePixel = 0
 bg.Parent = gui
 local line = Instance.new("Frame")
 line.Size = UDim2.new(0, 6, 1, 0)
 line.BackgroundColor3 = C.brass
 line.BorderSizePixel = 0
 line.Parent = bg
 local h = Instance.new("TextLabel")
 h.BackgroundTransparency = 1
 h.Position = UDim2.fromScale(.08, .13)
 h.Size = UDim2.fromScale(.84, .43)
 h.Text = title
 h.TextColor3 = C.white
 h.Font = Enum.Font.GothamBlack
 h.TextScaled = true
 h.TextXAlignment = Enum.TextXAlignment.Left
 h.Parent = bg
 local s = Instance.new("TextLabel")
 s.BackgroundTransparency = 1
 s.Position = UDim2.fromScale(.08, .64)
 s.Size = UDim2.fromScale(.84, .18)
 s.Text = sub
 s.TextColor3 = Color3.fromRGB(190, 187, 179)
 s.Font = Enum.Font.GothamBold
 s.TextScaled = true
 s.TextXAlignment = Enum.TextXAlignment.Left
 s.Parent = bg
end

local function lantern(name, pos, glowColor, parent, scale)
 scale = scale or 1
 local m = model(name, parent)
 m:SetAttribute("BBYAFloatingLantern", true)
 m:SetAttribute("BaseY", pos.Y)
 m:SetAttribute("Phase", (pos.X * .17 + pos.Z * .11) % 6.28)
 local capTop = cylinder("CapTop", Vector3.new(.18, 1.15, 1.15) * scale, CFrame.new(pos + Vector3.new(0, .62 * scale, 0)) * CFrame.Angles(0, 0, math.rad(90)), C.graphite, Enum.Material.Metal, false, m)
 local body = cylinder("GlowBody", Vector3.new(1.05, .9, .9) * scale, CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90)), glowColor, Enum.Material.Glass, false, m, .15)
 cylinder("CapBottom", Vector3.new(.18, 1.05, 1.05) * scale, CFrame.new(pos - Vector3.new(0, .62 * scale, 0)) * CFrame.Angles(0, 0, math.rad(90)), C.graphite, Enum.Material.Metal, false, m)
 pointLight(body, .38, 8 * scale, glowColor)
 m.PrimaryPart = body
 return m
end

local function rockCluster(name, center, scale, parent)
 local m = model(name, parent)
 local offsets = {
  {Vector3.new(0,0,0), Vector3.new(8,5,6), 0},
  {Vector3.new(5,1,2), Vector3.new(6,4,5), 18},
  {Vector3.new(-5,.4,2), Vector3.new(7,4.5,5), -22},
  {Vector3.new(1,2,-3), Vector3.new(5,5,4), 31},
 }
 for i, spec in ipairs(offsets) do
  ball("Rock"..i, spec[2] * scale, CFrame.new(center + spec[1] * scale) * CFrame.Angles(math.rad(spec[3]), math.rad(spec[3]*.6), 0), i%2==0 and C.stone or C.stoneDark, Enum.Material.Slate, true, m)
 end
 return m
end

local function reedPatch(name, pos, count, parent)
 local m = model(name, parent)
 for i = 1, count do
  local a = i * 2.399
  local r = 1.1 + (i % 4) * .42
  local x = pos.X + math.cos(a) * r
  local z = pos.Z + math.sin(a) * r
  local h = 2.0 + (i % 3) * .45
  cylinder("Reed"..i, Vector3.new(h, .08, .08), CFrame.new(x, pos.Y + h/2, z) * CFrame.Angles(0,0,math.rad(90)), i%2==0 and C.leaf2 or C.leaf, Enum.Material.SmoothPlastic, false, m)
 end
 return m
end

local function lily(name, pos, size, flower, parent)
 local m = model(name, parent)
 m:SetAttribute("BBYALily", true)
 m:SetAttribute("BaseY", pos.Y)
 m:SetAttribute("Phase", (pos.X * .13 + pos.Z * .19) % 6.28)
 cylinder("Pad", Vector3.new(.18, size, size), CFrame.new(pos) * CFrame.Angles(0,0,math.rad(90)), C.leaf2, Enum.Material.SmoothPlastic, false, m)
 if flower then
  for i=1,6 do
   local a=(i-1)*math.pi/3
   ball("Petal"..i, Vector3.new(.42,.18,.28), CFrame.new(pos + Vector3.new(math.cos(a)*.26,.16,math.sin(a)*.26)), C.white, Enum.Material.SmoothPlastic, false, m)
  end
  ball("FlowerCore", Vector3.new(.24,.24,.24), CFrame.new(pos+Vector3.new(0,.2,0)), C.gold, Enum.Material.SmoothPlastic, false, m)
 end
 m.PrimaryPart = m:FindFirstChild("Pad")
 return m
end

local function fishModel(name, bodyColor, accentColor, scale, parent)
 local m = model(name, parent)
 local body = ball("Body", Vector3.new(2.8, 1.05, .82) * scale, CFrame.new(0,0,0), bodyColor, Enum.Material.SmoothPlastic, false, m)
 wedge("TailTop", Vector3.new(1.0, 1.05, .18) * scale, CFrame.new(-1.75*scale,.24*scale,0)*CFrame.Angles(0,math.rad(90),0), accentColor, Enum.Material.SmoothPlastic, false, m)
 wedge("TailBottom", Vector3.new(1.0,1.05,.18)*scale, CFrame.new(-1.75*scale,-.24*scale,0)*CFrame.Angles(math.rad(180),math.rad(90),0), accentColor, Enum.Material.SmoothPlastic, false, m)
 wedge("Dorsal", Vector3.new(.72,.58,.12)*scale, CFrame.new(-.1*scale,.54*scale,0)*CFrame.Angles(0,math.rad(90),0), accentColor, Enum.Material.SmoothPlastic, false, m)
 ball("EyeL", Vector3.new(.14,.14,.14)*scale, CFrame.new(1.0*scale,.18*scale,-.38*scale), Color3.fromRGB(6,7,8), Enum.Material.SmoothPlastic, false, m)
 ball("EyeR", Vector3.new(.14,.14,.14)*scale, CFrame.new(1.0*scale,.18*scale,.38*scale), Color3.fromRGB(6,7,8), Enum.Material.SmoothPlastic, false, m)
 m.PrimaryPart = body
 return m
end

-- ==========================================================================
-- SIGNATURE WATERFALL / GROTTO
-- ==========================================================================
local grotto = model("MoonfallGrotto")
rockCluster("CliffCenter", Vector3.new(0, 4.2, 858), 1.85, grotto)
rockCluster("CliffLeft", Vector3.new(-14, 3.3, 857), 1.45, grotto)
rockCluster("CliffRight", Vector3.new(14, 3.5, 857), 1.5, grotto)

local fallBack = part("WaterfallBack", Vector3.new(15, 13, 1.1), CFrame.new(0, 7.0, 851.4), Color3.fromRGB(49, 151, 178), Enum.Material.Glass, false, grotto, .34)
local fallGlow = part("WaterfallGlow", Vector3.new(11.5, 11.5, .35), CFrame.new(0, 6.7, 850.75), C.aqua, Enum.Material.Neon, false, grotto, .70)
fallGlow:SetAttribute("BBYAWaterfallShimmer", true)
fallGlow:SetAttribute("Phase", 0)
pointLight(fallGlow, .38, 15, C.aqua)

local pool = cylinder("MoonfallPool", Vector3.new(.22, 24, 15), CFrame.new(0, .63, 844.5) * CFrame.Angles(0,0,math.rad(90)), Color3.fromRGB(42, 128, 151), Enum.Material.Glass, false, grotto, .32)
pool.Reflectance = .1
for _,p in ipairs({Vector3.new(-11,.6,844),Vector3.new(11,.6,844),Vector3.new(-8,.5,837),Vector3.new(8,.5,837)}) do rockCluster("PoolRock"..math.floor(p.X+p.Z), p, .43, grotto) end

local grottoSign = part("GrottoSign", Vector3.new(12, 2.8, .3), CFrame.new(0, 5.0, 835.4), C.dark, Enum.Material.Metal, false, grotto)
signFace(grottoSign, "MOONFALL", "SIGNATURE GROTTO")

for _,x in ipairs({-9,-4.5,4.5,9}) do lantern("GrottoLantern"..x, Vector3.new(x,4.2,838.5), x<0 and C.moon or C.aqua, grotto, .78) end

-- ==========================================================================
-- WATER GARDEN / LILY LANDSCAPING
-- ==========================================================================
local garden = model("WaterGarden")
local lilySpecs = {
 {-48, 808, 4.4, true}, {-40, 813, 3.6, false}, {-34, 805, 3.0, true}, {-55, 817, 3.2, false},
 {42, 800, 3.8, true}, {50, 806, 3.1, false}, {57, 798, 4.0, true}, {34, 811, 2.8, false},
 {-24, 829, 3.0, true}, {27, 828, 3.4, true},
}
for i,s in ipairs(lilySpecs) do lily("Lily"..i, Vector3.new(s[1], .62, s[2]), s[3], s[4], garden) end
reedPatch("ReedsWestA", Vector3.new(-102,.45,786), 14, garden)
reedPatch("ReedsWestB", Vector3.new(-101,.45,803), 12, garden)
reedPatch("ReedsEastA", Vector3.new(101,.45,774), 14, garden)
reedPatch("ReedsEastB", Vector3.new(105,.45,790), 11, garden)

for _,p in ipairs({Vector3.new(-92,.35,758),Vector3.new(94,.35,750),Vector3.new(-104,.35,824),Vector3.new(107,.35,827)}) do rockCluster("ShoreAccent"..math.floor(p.X+p.Z), p, .38, garden) end

-- ==========================================================================
-- MOON COVE PREMIUM IDENTITY
-- ==========================================================================
local cove = model("MoonCoveSignature")
local coveHalo = cylinder("CoveHalo", Vector3.new(.20, 15, 15), CFrame.new(90,.76,820)*CFrame.Angles(0,0,math.rad(90)), C.violet, Enum.Material.Neon, false, cove, .84)
coveHalo:SetAttribute("BBYACovePulse", true)
pointLight(coveHalo, .30, 16, C.violet)
for _,spec in ipairs({{80,4.4,805},{90,5.2,816},{99,4.8,828},{107,4.2,813}}) do lantern("MoonCoveLantern"..spec[1],Vector3.new(spec[1],spec[2],spec[3]),C.violet,cove,.82) end

local coveMarker = model("RareCatchSculpture", cove)
local coveFish = fishModel("CelestialKoiSculpture", C.white, C.gold, 1.45, coveMarker)
coveFish:PivotTo(CFrame.new(103,5.6,787)*CFrame.Angles(0,math.rad(145),math.rad(-6)))
local pedestal = cylinder("SculpturePedestal", Vector3.new(2.0, 5.5, 5.5), CFrame.new(103,2.0,787)*CFrame.Angles(0,0,math.rad(90)), C.stoneDark, Enum.Material.Slate, true, coveMarker)
local ring = cylinder("SculptureRing", Vector3.new(.26, 6.0, 6.0), CFrame.new(103,3.03,787)*CFrame.Angles(0,0,math.rad(90)), C.brass, Enum.Material.Metal, false, coveMarker)

-- ==========================================================================
-- SCENIC PIER / PHOTO SIGNATURE
-- ==========================================================================
local scenic = model("ScenicPhotoSignature")
for _,x in ipairs({-106,-94}) do
 part("PhotoPost"..x, Vector3.new(.72,8.6,.72), CFrame.new(x,5.15,844), C.graphite, Enum.Material.Metal, true, scenic)
end
part("PhotoHeader", Vector3.new(12.7,.68,.72), CFrame.new(-100,9.15,844), C.graphite, Enum.Material.Metal, true, scenic)
local logoBoard = part("PhotoBoard", Vector3.new(10.3,2.5,.32), CFrame.new(-100,7.7,843.58), C.dark, Enum.Material.Metal, false, scenic)
signFace(logoBoard, "BBYA LAKESIDE", "MOONLIGHT PIER")
for _,x in ipairs({-104.8,-95.2}) do lantern("PhotoLantern"..x,Vector3.new(x,7.1,842.9),C.warm,scenic,.72) end

-- Crown-like gold arc built from dimensional segments, no image asset.
local crown = model("PhotoCrown", scenic)
for i=0,8 do
 local a=math.rad(-70+i*17.5)
 local x=-100+math.sin(a)*6.0
 local y=9.0+math.cos(a)*3.3
 local seg=part("Arc"..i,Vector3.new(1.5,.22,.22),CFrame.new(x,y,844)*CFrame.Angles(0,0,-a),C.brass,Enum.Material.Metal,false,crown)
 if i%2==0 then local gem=ball("Gem"..i,Vector3.new(.34,.34,.34),CFrame.new(x,y+.32,844),i%4==0 and C.aqua or C.pink,Enum.Material.Neon,false,crown);pointLight(gem,.22,5,gem.Color) end
end

-- ==========================================================================
-- STATIC ROWBOAT / DOCK DETAIL
-- ==========================================================================
local boat = model("SignatureRowboat")
local hull = part("Hull", Vector3.new(9.5,1.1,3.8), CFrame.new(75,.72,758)*CFrame.Angles(0,math.rad(-18),0), C.woodDark, Enum.Material.WoodPlanks, false, boat)
for _,z in ipairs({-1.3,1.3}) do wedge("Bow"..z,Vector3.new(3.0,1.1,1.6),hull.CFrame*CFrame.new(4.8,0,z*.15)*CFrame.Angles(0,math.rad(90),0),C.wood,Enum.Material.WoodPlanks,false,boat) end
part("BoatSeatA",Vector3.new(.38,.45,3.0),hull.CFrame*CFrame.new(-1.6,.75,0),C.wood,Enum.Material.WoodPlanks,false,boat)
part("BoatSeatB",Vector3.new(.38,.45,3.0),hull.CFrame*CFrame.new(1.4,.75,0),C.wood,Enum.Material.WoodPlanks,false,boat)
for _,side in ipairs({-1,1}) do cylinder("Oar"..side,Vector3.new(6.8,.13,.13),hull.CFrame*CFrame.new(0,1.0,side*2.4)*CFrame.Angles(0,math.rad(side*22),math.rad(8)),C.wood,Enum.Material.Wood,false,boat) end

-- ==========================================================================
-- UNDERWATER 3D FISH SCHOOLS — client animates whole schools locally.
-- ==========================================================================
local schools = model("AmbientFishSchools")
local schoolSpecs = {
 {name="AzureSchool", center=Vector3.new(-42,-.05,780), radiusX=23, radiusZ=14, speed=.28, body=Color3.fromRGB(67,144,177), accent=C.aqua, count=6, scale=.72, phase=.2},
 {name="JadeSchool", center=Vector3.new(34,-.08,803), radiusX=20, radiusZ=11, speed=.34, body=Color3.fromRGB(69,128,79), accent=Color3.fromRGB(185,201,68), count=5, scale=.68, phase=1.7},
 {name="MoonSchool", center=Vector3.new(-12,-.10,820), radiusX=27, radiusZ=12, speed=.22, body=Color3.fromRGB(170,181,185), accent=C.white, count=7, scale=.64, phase=3.1},
 {name="RareSchool", center=Vector3.new(72,-.06,821), radiusX=16, radiusZ=9, speed=.38, body=Color3.fromRGB(80,95,143), accent=C.violet, count=4, scale=.78, phase=4.3},
}
for _,spec in ipairs(schoolSpecs) do
 local school = model(spec.name, schools)
 school:SetAttribute("BBYAFishSchool", true)
 school:SetAttribute("CenterX", spec.center.X)
 school:SetAttribute("CenterY", spec.center.Y)
 school:SetAttribute("CenterZ", spec.center.Z)
 school:SetAttribute("RadiusX", spec.radiusX)
 school:SetAttribute("RadiusZ", spec.radiusZ)
 school:SetAttribute("Speed", spec.speed)
 school:SetAttribute("Phase", spec.phase)
 local pivot = part("SchoolPivot",Vector3.new(.1,.1,.1),CFrame.new(spec.center),C.dark,Enum.Material.SmoothPlastic,false,school,1)
 school.PrimaryPart = pivot
 for i=1,spec.count do
  local fish=fishModel("Fish"..i,spec.body,spec.accent,spec.scale*(.85+(i%3)*.08),school)
  local localAngle=(i/spec.count)*math.pi*2
  fish:PivotTo(CFrame.new(spec.center + Vector3.new(math.cos(localAngle)*3.2,(i%2)*.25,math.sin(localAngle)*2.1)))
 end
end

-- Warm floating lantern rhythm around the lake; client gives subtle vertical drift.
local lakeLanterns = model("LakeLanterns")
local lanternPositions = {
 Vector3.new(-66,3.2,743),Vector3.new(-46,3.0,735),Vector3.new(46,3.0,735),Vector3.new(66,3.2,743),
 Vector3.new(-94,3.6,777),Vector3.new(96,3.5,768),Vector3.new(-75,3.4,831),Vector3.new(72,3.5,838),
}
for i,pos in ipairs(lanternPositions) do lantern("LakeLantern"..i,pos,i%3==0 and C.aqua or C.warm,lakeLanterns,.72) end

out:SetAttribute("InstalledDescendants", #out:GetDescendants())
print("[BBYA] Fishing Premium v3 online: Moonfall grotto + water garden + Moon Cove signature + photo pier + animated 3D fish schools")
