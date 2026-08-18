-- BBYA V6 — GROUND FLOOR PHYSICAL SHELL
-- Architecture first: real rooms, real openings, clear circulation. No oversized placeholder labels.

-- A1 ARRIVAL PLAZA
floor(A1,"A1 PLAZA FLOOR",Vector3.new(144,1,40),Vector3.new(0,0,-22),P.stone2,Enum.Material.Slate,"01")
-- low side walls only; front remains open.
wallZ(A1,"A1 WEST EDGE",-72,-42,-2,2.5,5,2,P.charcoal,"01")
wallZ(A1,"A1 EAST EDGE",72,-42,-2,2.5,5,2,P.charcoal,"01")
-- Broad social path, no red carpet/bouncer lane.
part(A1,"A1 CENTER WALK",Vector3.new(28,.18,36),CFrame.new(0,.58,-22),P.concrete,Enum.Material.Concrete,0,true,"01")
for _,x in ipairs({-46,46}) do
    planter(A1,"A1 PLANTER "..x,Vector3.new(x,1.5,-24),Vector3.new(12,2.4,8),"01")
    palm(A1,"A1 PALM "..x,Vector3.new(x,2.7,-24),9,"01")
end
for _,p in ipairs({Vector3.new(-24,1.3,-28),Vector3.new(24,1.3,-28)}) do
    sofa(A1,"A1 SOCIAL BENCH "..tostring(p.X),p,12,0,P.graphite,"01")
end

-- A2 STOREFRONT: building facade with real open ground floor, not a portal gate.
floor(A2,"A2 STOREFRONT FLOOR",Vector3.new(144,1,22),Vector3.new(0,0,5),P.stone,Enum.Material.Slate,nil)
-- facade piers and brand wall high above, leaving 92-stud transparent/open frontage.
wallZ(A2,"A2 WEST PIER",-69,-3,15,8,16,6,P.charcoal,nil)
wallZ(A2,"A2 EAST PIER",69,-3,15,8,16,6,P.charcoal,nil)
part(A2,"A2 BRAND WALL",Vector3.new(108,7,2),CFrame.new(0,13,-1),P.black,Enum.Material.Slate,0,true,nil)
part(A2,"A2 CANOPY",Vector3.new(96,.7,8),CFrame.new(0,9.2,3),P.charcoal,Enum.Material.Metal,0,true,nil)
-- transparent storefront wings, center fully open.
glass(A2,"A2 WEST STOREFRONT",Vector3.new(22,8,.5),CFrame.new(-57,5.2,13.2),nil)
glass(A2,"A2 EAST STOREFRONT",Vector3.new(22,8,.5),CFrame.new(57,5.2,13.2),nil)
-- Real logo board attached to facade. Large brand is allowed here only.
sign(A2,"A2 BBYA BRAND","♕  BBYA\nSOCIAL HUB",CFrame.new(0,13,-2.1),Vector3.new(74,6.2,.4),P.pink,Enum.NormalId.Front,nil)
neon(A2,"A2 CANOPY PINK LINE",Vector3.new(94,.18,.18),CFrame.new(0,8.85,-.9),P.pink,nil)
for _,x in ipairs({-36,-18,0,18,36}) do light(A2,"A2 WARM DOWNLIGHT "..x,Vector3.new(x,8.6,4),P.warm,1.25,16,nil) end

-- A3 SOCIAL COMMONS shell: 144x48, ceiling, side walls, clear center sightline.
floor(A3,"A3 COMMONS FLOOR",Vector3.new(144,1,50),Vector3.new(0,0,39),Color3.fromRGB(59,53,56),Enum.Material.Marble,nil)
part(A3,"A3 CEILING",Vector3.new(144,1,50),CFrame.new(0,17.5,39),P.charcoal,Enum.Material.Concrete,0,true,nil)
wallZ(A3,"A3 WEST WALL",-72,15,64,9,18,2,P.charcoal,nil)
wallZ(A3,"A3 EAST WALL",72,15,64,9,18,2,P.charcoal,nil)
-- A3 front wall has huge 92-stud open storefront, only side returns.
wallX(A3,"A3 FRONT RETURN W",15,-72,-46,9,18,2,P.charcoal,nil)
wallX(A3,"A3 FRONT RETURN E",15,46,72,9,18,2,P.charcoal,nil)
-- Rear boundary has parallel destinations, not one club-only door.
doorwayWallX(A3,"A3 REAR WEST",64,-72,-30,-51,16,9,18,2,P.charcoal,nil) -- chill
doorwayWallX(A3,"A3 REAR CENTER",64,-30,30,0,38,9,18,2,P.charcoal,nil) -- club
doorwayWallX(A3,"A3 REAR EAST",64,30,72,55,18,9,18,2,P.charcoal,nil) -- bar

-- Real LOOK / OUTFIT STUDIO room (A3/04): 34x18, enclosed on 3 sides, open doorway, not just text.
local studioX1,studioX2=-64,-30
local studioZ1,studioZ2=43,62
wallZ(A3,"A3 LOOK STUDIO WEST",studioX1,studioZ1,studioZ2,6.5,13,1.5,P.graphite,"04")
wallX(A3,"A3 LOOK STUDIO BACK",studioZ2,studioX1,studioX2,6.5,13,1.5,P.graphite,"04")
doorwayWallZ(A3,"A3 LOOK STUDIO EAST",studioX2,studioZ1,studioZ2,52,8,6.5,13,1.5,P.graphite,"04")
part(A3,"A3 LOOK STUDIO CEILING",Vector3.new(34,.5,19),CFrame.new(-47,13,52.5),P.black,Enum.Material.SmoothPlastic,0,true,"04")
-- curved-photo-wall approximation: wide cyclorama back wall + floor strip.
part(A3,"A3 LOOK CYC WALL",Vector3.new(28,9,.7),CFrame.new(-47,5.2,60.6),Color3.fromRGB(224,215,224),Enum.Material.SmoothPlastic,0,true,"04")
part(A3,"A3 LOOK CYC FLOOR",Vector3.new(28,.25,8),CFrame.new(-47,.65,57),Color3.fromRGB(224,215,224),Enum.Material.SmoothPlastic,0,true,"04")
-- mirror/display wall and fitting pedestal.
glass(A3,"A3 LOOK MIRROR",Vector3.new(.5,8,12),CFrame.new(-63.1,5.1,52),"04")
part(A3,"A3 LOOK PEDESTAL",Vector3.new(8,.5,8),CFrame.new(-47,.8,48),P.graphite,Enum.Material.Marble,0,true,"04")
for _,x in ipairs({-57,-47,-37}) do light(A3,"A3 LOOK KEY "..x,Vector3.new(x,11.5,52),P.white,1.6,16,"04") end
-- Small physical room plaque, not floating giant copy.
sign(A3,"A3 LOOK ROOM PLAQUE","LOOK STUDIO",CFrame.new(-30.85,9.5,48),Vector3.new(.35,2.2,8),P.cyan,Enum.NormalId.Left,"04")

-- A3/02 Welcome Host room/island on east-front side.
local hostX1,hostX2=32,66
local hostZ1,hostZ2=23,43
wallZ(A3,"A3 HOST EAST WALL",hostX2,hostZ1,hostZ2,5.5,11,1.2,P.graphite,"02")
wallX(A3,"A3 HOST BACK WALL",hostZ2,hostX1,hostX2,5.5,11,1.2,P.graphite,"02")
bar(A3,"A3 WELCOME BAR",Vector3.new(48,2.3,31),Vector3.new(27,3.4,5),0,"02")
for _,x in ipairs({39,45,51,57}) do
    part(A3,"A3 HOST STOOL "..x,Vector3.new(2.2,.6,2.2),CFrame.new(x,1.6,27),P.cream,Enum.Material.Fabric,0,true,"02")
end
sign(A3,"A3 HOST PLAQUE","WELCOME / INFO",CFrame.new(49,8.2,42.25),Vector3.new(22,2,.3),P.warm,Enum.NormalId.Front,"02")

-- A3/03 Photo/selfie alcove, a real usable space.
wallX(A3,"A3 SELFIE BACK",36,-64,-34,5.5,11,1.2,P.black,"03")
wallZ(A3,"A3 SELFIE WEST",-64,22,36,5.5,11,1.2,P.graphite,"03")
part(A3,"A3 SELFIE PLATFORM",Vector3.new(20,.5,10),CFrame.new(-49,.8,30),P.graphite,Enum.Material.Marble,0,true,"03")
neon(A3,"A3 SELFIE FRAME TOP",Vector3.new(18,.18,.18),CFrame.new(-49,9.5,35.5),P.pink,"03")
neon(A3,"A3 SELFIE FRAME L",Vector3.new(.18,8,.18),CFrame.new(-58,5.5,35.5),P.cyan,"03")
neon(A3,"A3 SELFIE FRAME R",Vector3.new(.18,8,.18),CFrame.new(-40,5.5,35.5),P.pink,"03")
for _,x in ipairs({-55,-43}) do light(A3,"A3 SELFIE FILL "..x,Vector3.new(x,10,29),P.white,1.4,13,"03") end

-- A3 social commons must contain real hangout pockets, while keeping x=-10..10 as a clear circulation spine.
for _,cfg in ipairs({
    {x=-21,z=46,yaw=90,color=P.cream,name="WEST"},
    {x=21,z=49,yaw=-90,color=P.graphite,name="EAST"},
}) do
    sofa(A3,"A3 SOCIAL ISLAND "..cfg.name,Vector3.new(cfg.x,1.3,cfg.z),11,cfg.yaw,cfg.color,nil)
    local tx=cfg.x<0 and -15 or 15
    tableLow(A3,"A3 SOCIAL TABLE "..cfg.name,Vector3.new(tx,1.1,cfg.z),Vector3.new(5,.6,4),P.black,nil)
end
for _,p in ipairs({Vector3.new(-22,1.3,22),Vector3.new(22,1.3,22)}) do
    planter(A3,"A3 COMMONS PLANTER "..tostring(p.X),p,Vector3.new(5,2,5),nil)
end
for _,p in ipairs({Vector3.new(-20,12,42),Vector3.new(20,12,42),Vector3.new(-20,12,56),Vector3.new(20,12,56)}) do
    light(A3,"A3 AVATAR SOCIAL FILL",p,P.warm,1.05,15,nil)
end

-- A4 CLUB shell: central facility only.
floor(A4,"A4 CLUB FLOOR",Vector3.new(92,1,68),Vector3.new(0,0,98),Color3.fromRGB(29,27,34),Enum.Material.Slate,"05")
part(A4,"A4 CLUB CEILING",Vector3.new(92,1,68),CFrame.new(0,18,98),P.black,Enum.Material.Concrete,0,true,nil)
wallZ(A4,"A4 CLUB WEST WALL",-46,64,132,9,18,2,P.black,nil)
wallZ(A4,"A4 CLUB EAST WALL",46,64,132,9,18,2,P.black,nil)
-- front opening to A3 is 38 studs.
doorwayWallX(A4,"A4 CLUB FRONT",64,-46,46,0,38,9,18,2,P.black,nil)
wallX(A4,"A4 CLUB BACK",132,-46,46,9,18,2,P.black,nil)
-- dance floor physical inset
part(A4,"A4 DANCE FLOOR",Vector3.new(58,.3,42),CFrame.new(0,.68,94),P.graphite,Enum.Material.SmoothPlastic,0,true,"05")
for _,x in ipairs({-29,29}) do neon(A4,"A4 DANCE EDGE X "..x,Vector3.new(.18,.12,42),CFrame.new(x,.9,94),x<0 and P.cyan or P.pink,"05") end
for _,z in ipairs({73,115}) do neon(A4,"A4 DANCE EDGE Z "..z,Vector3.new(58,.12,.18),CFrame.new(0,.9,z),z<90 and P.cyan or P.pink,"05") end
-- stage/DJ are actual raised physical structures.
part(A4,"A4 STAGE",Vector3.new(50,2,14),CFrame.new(0,1.5,121),P.graphite,Enum.Material.Slate,0,true,"07")
part(A4,"A4 DJ BOOTH",Vector3.new(24,3.2,5),CFrame.new(0,4.1,121),P.black,Enum.Material.Metal,0,true,"06")
part(A4,"A4 LED WALL",Vector3.new(44,10,.7),CFrame.new(0,8.5,130.8),P.black,Enum.Material.SmoothPlastic,0,true,"07")
-- side social pockets let users watch/show outfits without standing on the dance floor.
for _,cfg in ipairs({
    {x=-38,z=84,yaw=90,name="WL1"},{x=-38,z=105,yaw=90,name="WL2"},
    {x=38,z=84,yaw=-90,name="ER1"},{x=38,z=105,yaw=-90,name="ER2"},
}) do
    sofa(A4,"A4 SOCIAL SIDE "..cfg.name,Vector3.new(cfg.x,1.3,cfg.z),10,cfg.yaw,P.graphite,"05")
end
-- bright critical outfit fill, not a dark void.
for _,pos in ipairs({Vector3.new(-28,14,78),Vector3.new(0,14,78),Vector3.new(28,14,78),Vector3.new(-28,14,100),Vector3.new(0,14,100),Vector3.new(28,14,100),Vector3.new(-20,14,118),Vector3.new(20,14,118)}) do
    local l=light(A4,"A4 OUTFIT FILL",pos,P.white,1.5,22,"05");l.Parent:SetAttribute("BBYACriticalFill",true)
end

-- A5 SOCIAL BAR: actual room with open frontage to commons/club corridor.
floor(A5,"A5 BAR FLOOR",Vector3.new(26,1,64),Vector3.new(59,0,96),Color3.fromRGB(52,45,45),Enum.Material.WoodPlanks,"08")
part(A5,"A5 BAR CEILING",Vector3.new(26,1,64),CFrame.new(59,18,96),P.charcoal,Enum.Material.Concrete,0,true,"08")
wallZ(A5,"A5 BAR EAST WALL",72,64,128,9,18,2,P.charcoal,"08")
wallX(A5,"A5 BAR BACK",128,46,72,9,18,2,P.charcoal,"08")
-- open west side to club corridor with columns, not sealed.
for _,z in ipairs({72,96,120}) do part(A5,"A5 BAR COLUMN "..z,Vector3.new(2,18,2),CFrame.new(47,9,z),P.graphite,Enum.Material.Concrete,0,true,"08") end
bar(A5,"A5 MAIN BAR",Vector3.new(62,2.3,91),Vector3.new(18,3.6,6),90,"08")
for _,z in ipairs({78,86,94,102,110}) do sofa(A5,"A5 BAR BOOTH "..z,Vector3.new(64,1.3,z),10,90,P.graphite,"08") end
for _,z in ipairs({76,88,100,112}) do light(A5,"A5 WARM BAR LIGHT "..z,Vector3.new(58,12,z),P.warm,1.1,15,"08") end

-- A6 CHILL: conversation room, warm and quiet, actual pockets.
floor(A6,"A6 CHILL FLOOR",Vector3.new(26,1,64),Vector3.new(-59,0,96),Color3.fromRGB(61,56,54),Enum.Material.WoodPlanks,nil)
part(A6,"A6 CHILL CEILING",Vector3.new(26,1,64),CFrame.new(-59,18,96),P.charcoal,Enum.Material.Concrete,0,true,nil)
wallZ(A6,"A6 CHILL WEST WALL",-72,64,128,9,18,2,P.charcoal,nil)
wallX(A6,"A6 CHILL BACK",128,-72,-46,9,18,2,P.charcoal,nil)
for _,z in ipairs({72,96,120}) do part(A6,"A6 CHILL COLUMN "..z,Vector3.new(2,18,2),CFrame.new(-47,9,z),P.graphite,Enum.Material.Concrete,0,true,nil) end
for _,z in ipairs({78,94,110}) do
    sofa(A6,"A6 CONVERSATION SOFA A "..z,Vector3.new(-64,1.3,z),10,90,P.cream,nil)
    sofa(A6,"A6 CONVERSATION SOFA B "..z,Vector3.new(-53,1.3,z),10,-90,P.graphite,nil)
    tableLow(A6,"A6 CONVERSATION TABLE "..z,Vector3.new(-58.5,1.1,z),Vector3.new(5,.6,4),P.black,nil)
end
for _,z in ipairs({76,92,108,124}) do light(A6,"A6 WARM CHILL LIGHT "..z,Vector3.new(-59,12,z),P.warm,.95,14,nil) end

-- B1/B2 real stair cores, enclosed with open ground/VIP doors.
floor(B1,"B1 GROUND LANDING",Vector3.new(28,1,24),Vector3.new(-56,0,140),P.stone2,Enum.Material.Concrete,nil)
wallZ(B1,"B1 WEST CORE",-70,124,150,9,18,2,P.charcoal,nil)
wallZ(B1,"B1 EAST CORE",-42,124,150,9,18,2,P.charcoal,nil)
doorwayWallX(B1,"B1 FRONT CORE",124,-70,-42,-56,12,9,18,2,P.charcoal,nil)
wallX(B1,"B1 BACK CORE",150,-70,-42,9,18,2,P.charcoal,nil)
stairFlight(B1,"B1 FLIGHT",CFrame.new(-56,1,146),24,12,.78,1.15,nil)
part(B1,"B1 VIP LANDING",Vector3.new(18,1,10),CFrame.new(-56,19.7,118),P.stone2,Enum.Material.Concrete,0,true,nil)

floor(B2,"B2 GROUND LANDING",Vector3.new(28,1,24),Vector3.new(33,0,140),P.stone2,Enum.Material.Concrete,nil)
wallZ(B2,"B2 WEST CORE",19,124,150,9,18,2,P.charcoal,nil)
wallZ(B2,"B2 EAST CORE",47,124,150,9,18,2,P.charcoal,nil)
doorwayWallX(B2,"B2 FRONT CORE",124,19,47,33,12,9,18,2,P.charcoal,nil)
wallX(B2,"B2 BACK CORE",150,19,47,9,18,2,P.charcoal,nil)
stairFlight(B2,"B2 FLIGHT",CFrame.new(33,1,146),24,12,.78,1.15,nil)
part(B2,"B2 VIP LANDING",Vector3.new(18,1,10),CFrame.new(33,19.7,118),P.stone2,Enum.Material.Concrete,0,true,nil)

-- B3 LIFT CORE: sealed shaft + three real landing doors + cab aligned directly behind doors.
-- Landing/approach is outside the shaft; the shaft itself begins at z=119.
part(B3,"B3 GROUND LIFT LANDING",Vector3.new(22,.35,14),CFrame.new(59,.68,112),P.stone2,Enum.Material.Marble,0,true,nil)
-- Continuous side/back shaft walls from ground through rooftop door height.
wallZ(B3,"B3 SHAFT WEST",50,119,132,26,52,2,P.charcoal,nil)
wallZ(B3,"B3 SHAFT EAST",68,119,132,26,52,2,P.charcoal,nil)
wallX(B3,"B3 SHAFT BACK",132,50,68,26,52,2,P.charcoal,nil)
-- Front wall around each landing opening.
wallX(B3,"B3 G FRONT LEFT",119,50,54,5,10,2,P.charcoal,nil)
wallX(B3,"B3 G FRONT RIGHT",119,64,68,5,10,2,P.charcoal,nil)
part(B3,"B3 G FRONT LINTEL",Vector3.new(10,3,2),CFrame.new(59,8.5,119),P.charcoal,Enum.Material.Concrete,0,true,nil)
wallX(B3,"B3 V FRONT LEFT",119,50,54,25,10,2,P.charcoal,nil)
wallX(B3,"B3 V FRONT RIGHT",119,64,68,25,10,2,P.charcoal,nil)
part(B3,"B3 V FRONT LINTEL",Vector3.new(10,3,2),CFrame.new(59,28.5,119),P.charcoal,Enum.Material.Concrete,0,true,nil)
wallX(B3,"B3 R FRONT LEFT",119,50,54,45,10,2,P.charcoal,nil)
wallX(B3,"B3 R FRONT RIGHT",119,64,68,45,10,2,P.charcoal,nil)
part(B3,"B3 R FRONT LINTEL",Vector3.new(10,3,2),CFrame.new(59,48.5,119),P.charcoal,Enum.Material.Concrete,0,true,nil)
-- Seal the shaft front between floor openings: no open vertical void visible to players.
part(B3,"B3 G-V FRONT INFILL",Vector3.new(18,10,2),CFrame.new(59,15,119),P.charcoal,Enum.Material.Concrete,0,true,nil)
part(B3,"B3 V-R FRONT INFILL",Vector3.new(18,10,2),CFrame.new(59,35,119),P.charcoal,Enum.Material.Concrete,0,true,nil)
-- Landing doors are physical architecture; systems only animate these existing parts.
for _,lv in ipairs({{code="G",y=5.2},{code="VIP",y=25.2},{code="ROOF",y=45.2}}) do
    part(B3,"B3 "..lv.code.." LANDING DOOR L",Vector3.new(5,9,.5),CFrame.new(56.5,lv.y,119.15),P.black,Enum.Material.Metal,0,true,nil)
    part(B3,"B3 "..lv.code.." LANDING DOOR R",Vector3.new(5,9,.5),CFrame.new(61.5,lv.y,119.15),P.black,Enum.Material.Metal,0,true,nil)
end
-- Cab is directly behind the landing opening (front face ~119.2), not floating deep inside the shaft.
part(B3,"B3 LIFT CAB FLOOR",Vector3.new(12,.6,11),CFrame.new(59,.8,124.8),P.graphite,Enum.Material.Metal,0,true,nil)
part(B3,"B3 LIFT CAB BACK",Vector3.new(12,9,.5),CFrame.new(59,5.2,130.05),P.graphite,Enum.Material.Metal,0,true,nil)
part(B3,"B3 LIFT CAB WEST",Vector3.new(.5,9,11),CFrame.new(53.2,5.2,124.8),P.graphite,Enum.Material.Metal,0,true,nil)
part(B3,"B3 LIFT CAB EAST",Vector3.new(.5,9,11),CFrame.new(64.8,5.2,124.8),P.graphite,Enum.Material.Metal,0,true,nil)
part(B3,"B3 LIFT CAB DOOR L",Vector3.new(5,9,.45),CFrame.new(56.5,5.2,119.28),P.black,Enum.Material.Metal,0,true,nil)
part(B3,"B3 LIFT CAB DOOR R",Vector3.new(5,9,.45),CFrame.new(61.5,5.2,119.28),P.black,Enum.Material.Metal,0,true,nil)
-- small signage only
sign(B3,"B3 LIFT PLAQUE","LIFT",CFrame.new(59,10.5,118.85),Vector3.new(8,1.5,.25),P.white,Enum.NormalId.Front,nil)
clearPad(B3,"B3 G CLEAR LANDING",Vector3.new(59,.82,112),Vector3.new(12,.12,10),nil)

workspace:SetAttribute("BBYAV6GroundShell","COMPLETE")
workspace:SetAttribute("BBYAV6LiftShell","SEALED_3_LEVEL")