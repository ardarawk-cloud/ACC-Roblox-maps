-- BBYA SOCIAL HUB — CLEAN REBUILD ARCHITECTURE
-- Reference read: left multi-level club wing, center social court, right VIP wing, upper rooftop pool.

-- SITE / ARRIVAL
part(A1,"SITE BASE",Vector3.new(220,2,190),CFrame.new(0,-1,25),C.black,Enum.Material.Slate,0,true)
part(A1,"ARRIVAL PLAZA",Vector3.new(190,1,46),CFrame.new(0,.1,-61),Color3.fromRGB(37,35,47),Enum.Material.Marble,0,true)
part(A1,"CENTER APPROACH",Vector3.new(28,.25,58),CFrame.new(0,.72,-40),Color3.fromRGB(69,66,77),Enum.Material.Marble,0,true)
for _,x in ipairs({-64,-42,42,64}) do
    neon(A1,"ARRIVAL EDGE "..x,Vector3.new(16,.16,.16),CFrame.new(x,.75,-46),x<0 and C.pink or C.cyan)
end

-- MAIN BUILDING MASSING
-- Left club tower: 3 visible tiers, open glass front, actual playable ground + mezzanine decks.
part(A3,"CLUB GROUND SLAB",Vector3.new(104,2,105),CFrame.new(-34,0,35),Color3.fromRGB(28,27,36),Enum.Material.Slate,0,true)
part(A4,"MEZZ LEVEL 1",Vector3.new(34,1.4,84),CFrame.new(-78,16,42),C.charcoal,Enum.Material.Slate,0,true)
part(A4,"MEZZ LEVEL 2",Vector3.new(34,1.4,62),CFrame.new(-78,30,53),C.charcoal,Enum.Material.Slate,0,true)

-- Outer left tower frame.
for _,x in ipairs({-86,-70,-54}) do
    part(A4,"LEFT TOWER COLUMN "..x,Vector3.new(2,44,2),CFrame.new(x,22,30),C.graphite,Enum.Material.Metal,0,true)
end
for _,y in ipairs({8,16,30,43}) do
    part(A4,"LEFT TOWER BAND "..y,Vector3.new(48,1.2,2),CFrame.new(-70,y,-8),C.graphite,Enum.Material.Metal,0,true)
    neon(A4,"LEFT TOWER BAND NEON "..y,Vector3.new(42,.18,.18),CFrame.new(-70,y+.68,-9.05),y==30 and C.cyan or C.pink)
end
for _,cfg in ipairs({{y=8,h=13},{y=23,h=12},{y=36,h=10}}) do
    local g=glass(A4,"LEFT GLASS FACADE "..cfg.y,Vector3.new(46,cfg.h,.5),CFrame.new(-70,cfg.y,-8.8),.48)
    g.CanCollide=false
end

-- Deep rear club enclosure and stage frame.
part(A3,"CLUB BACK WALL",Vector3.new(104,22,2),CFrame.new(-34,11,87),C.black,Enum.Material.Concrete,0,true)
part(A3,"CLUB WEST WALL",Vector3.new(2,22,95),CFrame.new(-86,11,39),C.black,Enum.Material.Concrete,0,true)
part(A3,"CLUB EAST RETURN",Vector3.new(2,22,54),CFrame.new(18,11,60),C.black,Enum.Material.Concrete,0,true)
part(A3,"CLUB CEILING REAR",Vector3.new(104,1.2,38),CFrame.new(-34,22,68),C.black,Enum.Material.Concrete,0,true)

-- Central dance floor / stage.
part(A3,"DANCE FLOOR",Vector3.new(66,.55,46),CFrame.new(-28,.65,35),C.graphite,Enum.Material.Glass,.08,true)
for _,x in ipairs({-61,5}) do neon(A3,"DANCE X EDGE "..x,Vector3.new(.22,.16,46),CFrame.new(x,1,35),x<0 and C.pink or C.cyan) end
for _,z in ipairs({12,58}) do neon(A3,"DANCE Z EDGE "..z,Vector3.new(66,.16,.22),CFrame.new(-28,1,z),z<30 and C.cyan or C.pink) end
part(A3,"MAIN STAGE",Vector3.new(58,3,18),CFrame.new(-28,2.2,76),C.black,Enum.Material.Metal,0,true)
part(A3,"DJ BOOTH",Vector3.new(25,4.2,7),CFrame.new(-28,5.1,73),C.graphite,Enum.Material.Metal,0,true)
part(A3,"LED WALL",Vector3.new(64,13,.7),CFrame.new(-28,10,85.7),C.black,Enum.Material.SmoothPlastic,0,true)

-- Central social atrium joins club and VIP wing.
part(A2,"ATRIUM FLOOR",Vector3.new(56,1,86),CFrame.new(22,.15,28),Color3.fromRGB(51,48,60),Enum.Material.Marble,0,true)
part(A2,"ATRIUM REAR DECK",Vector3.new(56,1,24),CFrame.new(22,.15,82),Color3.fromRGB(46,43,54),Enum.Material.Marble,0,true)
for _,x in ipairs({-3,47}) do
    part(A2,"ATRIUM COLUMN "..x,Vector3.new(1.2,18,1.2),CFrame.new(x,9,-8),C.graphite,Enum.Material.Metal,0,true)
end
part(A2,"ATRIUM CANOPY",Vector3.new(54,1,13),CFrame.new(22,18,-8),C.black,Enum.Material.Metal,0,true)

-- Right VIP wing on ground floor, with real roof deck above.
part(A5,"VIP FLOOR",Vector3.new(72,1.4,84),CFrame.new(68,.2,35),Color3.fromRGB(47,38,48),Enum.Material.Marble,0,true)
part(A5,"VIP EAST WALL",Vector3.new(2,18,84),CFrame.new(104,9,35),C.charcoal,Enum.Material.Concrete,0,true)
part(A5,"VIP BACK WALL",Vector3.new(72,18,2),CFrame.new(68,9,77),C.charcoal,Enum.Material.Concrete,0,true)
part(A5,"VIP CEILING",Vector3.new(72,1,84),CFrame.new(68,18,35),C.charcoal,Enum.Material.Concrete,0,true)
for _,x in ipairs({38,68,98}) do
    part(A5,"VIP FRONT COLUMN "..x,Vector3.new(1.3,18,1.3),CFrame.new(x,9,-7),C.graphite,Enum.Material.Metal,0,true)
end
for _,x in ipairs({52,84}) do
    local g=glass(A5,"VIP FRONT GLASS "..x,Vector3.new(27,13,.45),CFrame.new(x,7,-7.6),.44)
    g.CanCollide=false
end

-- Upper rooftop / infinity-pool terrace. This is a playable real level, not decorative fake floor.
part(A6,"ROOFTOP DECK",Vector3.new(110,2,92),CFrame.new(48,31,34),Color3.fromRGB(72,61,59),Enum.Material.WoodPlanks,0,true)
rail(A6,"ROOFTOP FRONT GLASS",Vector3.new(106,5,.5),CFrame.new(48,34,-12))
rail(A6,"ROOFTOP EAST GLASS",Vector3.new(.5,5,88),CFrame.new(103,34,34))
rail(A6,"ROOFTOP REAR GLASS",Vector3.new(106,5,.5),CFrame.new(48,34,80))

-- Real infinity pool basin.
part(A6,"POOL BASIN",Vector3.new(68,4,42),CFrame.new(48,31.2,22),Color3.fromRGB(23,67,88),Enum.Material.Slate,0,true)
local water=part(A6,"POOL WATER",Vector3.new(66,.55,40),CFrame.new(48,33.25,22),C.water,Enum.Material.Glass,.28,false)
water.CanQuery=false
rail(A6,"POOL INFINITY GLASS",Vector3.new(66,3,.35),CFrame.new(48,34,-.2))
neon(A6,"POOL INFINITY GLOW",Vector3.new(64,.18,.18),CFrame.new(48,33.55,-.45),C.cyan)
for i=0,3 do
    part(A6,"POOL STEP "..i,Vector3.new(11,.45,3),CFrame.new(20,33-i*.42,35-i*2.1),Color3.fromRGB(176,168,160),Enum.Material.Slate,0,true)
end

-- Rooftop pool DJ platform.
part(A6,"POOL DJ ISLAND",Vector3.new(24,1.2,14),CFrame.new(48,32.3,66),C.graphite,Enum.Material.Slate,0,true)
part(A6,"POOL DJ DESK",Vector3.new(16,3.2,5),CFrame.new(48,34.4,66),C.black,Enum.Material.Metal,0,true)

-- Physical stairs: ground -> VIP/mezz and VIP -> rooftop.
-- Right side switchback is intentionally broad and normal, never obby-like.
stair(A5,"STAIR G TO MID",Vector3.new(94,1.1,72),28,8,.55,.75,180,C.stone)
part(A5,"MID STAIR LANDING",Vector3.new(12,1,10),CFrame.new(94,16.2,50),C.stone,Enum.Material.Slate,0,true)
stair(A5,"STAIR MID TO ROOF",Vector3.new(88,16.7,47),28,8,.55,.75,0,C.stone)
part(A6,"ROOF STAIR LANDING",Vector3.new(14,1,12),CFrame.new(88,31.4,68),C.stone,Enum.Material.Slate,0,true)

-- Safety rails around mezzanine edges.
rail(A4,"MEZZ1 FRONT RAIL",Vector3.new(32,5,.45),CFrame.new(-78,19,-.5))
rail(A4,"MEZZ2 FRONT RAIL",Vector3.new(32,5,.45),CFrame.new(-78,33,22))

-- Exterior brand wall / facade.
part(A2,"BRAND FACADE WALL",Vector3.new(96,15,2),CFrame.new(-10,28,-10),C.black,Enum.Material.Slate,0,true)
sign(A2,"MAIN BBYA WORDMARK","BBYA\nSOCIAL HUB",CFrame.new(-10,28,-11.1),Vector3.new(72,10,.35),C.pink,Enum.NormalId.Front)
neon(A2,"CROWN BASE",Vector3.new(24,.4,.4),CFrame.new(-10,35.3,-11.4),C.pink)
neon(A2,"CROWN L1",Vector3.new(9,.4,.4),CFrame.new(-19,38,-11.4)*CFrame.Angles(0,0,math.rad(58)),C.pink)
neon(A2,"CROWN L2",Vector3.new(9,.4,.4),CFrame.new(-13,39,-11.4)*CFrame.Angles(0,0,math.rad(-62)),C.pink)
neon(A2,"CROWN R2",Vector3.new(9,.4,.4),CFrame.new(-7,39,-11.4)*CFrame.Angles(0,0,math.rad(62)),C.pink)
neon(A2,"CROWN R1",Vector3.new(9,.4,.4),CFrame.new(-1,38,-11.4)*CFrame.Angles(0,0,math.rad(-58)),C.pink)

workspace:SetAttribute("BBYAArchitecture","REFERENCE_MASSING_PHASE_1")
workspace:SetAttribute("BBYAPlayableLevels",3)
