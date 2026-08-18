-- [D1] LUXURY ROOFTOP ARRIVAL / CIRCULATION
-- Separate resort mood: stone, wood and warm indirect light. Main axes remain clear.

finish(D1,"ROOFTOP STONE FINISH",Vector3.new(176,.16,196),CFrame.new(0,36.58,20),Color3.fromRGB(75,72,70),Enum.Material.Slate,0,false)
finish(D1,"CENTRAL SPINE FINISH",Vector3.new(14,.12,172),CFrame.new(0,36.72,18),Color3.fromRGB(112,78,52),Enum.Material.WoodPlanks,0,false)
finish(D1,"ARRIVAL PLAZA FINISH",Vector3.new(40,.14,20),CFrame.new(0,36.76,96),Color3.fromRGB(93,88,82),Enum.Material.Marble,0,false)

-- Warm orientation lights trace the circulation spine without becoming club neon.
for i,z in ipairs({-64,-44,-24,-4,16,36,56,76,102}) do
 bollard(D1,"SPINE WEST BOLLARD "..i,Vector3.new(-9,38.2,z),P.warm)
 bollard(D1,"SPINE EAST BOLLARD "..i,Vector3.new(9,38.2,z),P.warm)
end

-- Tropical framing stays at perimeter, away from D2/D3/D4/D5 program footprints.
palm(D1,"ROOF FRONT WEST PALM",Vector3.new(-80,37.6,92),11)
palm(D1,"ROOF FRONT EAST PALM",Vector3.new(80,37.6,92),11)
palm(D1,"ROOF MID WEST PALM",Vector3.new(-82,37.6,8),10)
palm(D1,"ROOF MID EAST PALM",Vector3.new(82,37.6,8),10)

-- View-safe glass parapet above the structural edge.
glassRail(D1,"ROOF FRONT GLASS",Vector3.new(0,40.2,119),Vector3.new(170,3.6,.35))
glassRail(D1,"ROOF WEST GLASS",Vector3.new(-88.5,40.2,20),Vector3.new(.35,3.6,190))
glassRail(D1,"ROOF EAST GLASS",Vector3.new(88.5,40.2,20),Vector3.new(.35,3.6,190))

zoneSign(D1,"ROOFTOP ARRIVAL SIGN","BBYA ROOFTOP  •  POOL ↓  •  SKY BAR ←  •  CHILL →",CFrame.new(0,43.2,105),Vector3.new(46,3,.25),P.warm,Enum.NormalId.Front)
