-- BBYA V6 — VIP / PRIVATE SOCIAL FLOOR
-- Real balcony/lounge/private rooms around the club void.

-- Shared upper deck with central dance-hall void retained.
-- West VIP deck
floor(C1,"C1 WEST VIP FLOOR",Vector3.new(54,1,68),Vector3.new(-43,20,98),Color3.fromRGB(50,44,47),Enum.Material.WoodPlanks,"09W")
-- carve visual relation to club by using glass rail on east edge instead of wall.
glass(C1,"C1 CLUB VIEW RAIL",Vector3.new(.45,6,48),CFrame.new(-16.3,23,96),"11W")
wallZ(C1,"C1 WEST OUTER WALL",-70,64,132,29,18,2,P.charcoal,"09W")
wallX(C1,"C1 REAR WALL",132,-70,-16,29,18,2,P.charcoal,"09W")
-- front edge partly open to commons, protected with rail.
glass(C1,"C1 FRONT BALCONY RAIL",Vector3.new(40,5,.45),CFrame.new(-38,22.5,65),"11W")

-- East VIP deck
floor(C2,"C2 EAST VIP FLOOR",Vector3.new(54,1,68),Vector3.new(28,20,98),Color3.fromRGB(50,44,47),Enum.Material.WoodPlanks,"09E")
glass(C2,"C2 CLUB VIEW RAIL",Vector3.new(.45,6,48),CFrame.new(1.3,23,96),"11E")
wallZ(C2,"C2 EAST OUTER WALL",55,64,118,29,18,2,P.charcoal,"09E")
-- leave lift core area at x50..68/z119..149 intact.
glass(C2,"C2 FRONT BALCONY RAIL",Vector3.new(40,5,.45),CFrame.new(28,22.5,65),"11E")

-- VIP lounge furniture: distributed social pockets, not one giant room.
for _,z in ipairs({78,98,116}) do
    sofa(C1,"C1 VIP SOFA A "..z,Vector3.new(-58,21.3,z),11,90,P.cream,"09W")
    sofa(C1,"C1 VIP SOFA B "..z,Vector3.new(-42,21.3,z),11,-90,P.graphite,"09W")
    tableLow(C1,"C1 VIP TABLE "..z,Vector3.new(-50,21.1,z),Vector3.new(5,.6,4),P.black,"09W")
    light(C1,"C1 WARM LOUNGE LIGHT "..z,Vector3.new(-50,31,z),P.warm,1.05,15,"09W")
end
for _,z in ipairs({78,98,112}) do
    sofa(C2,"C2 VIP SOFA A "..z,Vector3.new(14,21.3,z),10,90,P.graphite,"09E")
    sofa(C2,"C2 VIP SOFA B "..z,Vector3.new(40,21.3,z),10,-90,P.cream,"09E")
    tableLow(C2,"C2 VIP TABLE "..z,Vector3.new(27,21.1,z),Vector3.new(5,.6,4),P.black,"09E")
    light(C2,"C2 WARM LOUNGE LIGHT "..z,Vector3.new(27,31,z),P.warm,1.05,15,"09E")
end

-- Small private bars inside VIP lounges.
bar(C1,"C1 PRIVATE BAR",Vector3.new(-60,22.3,121),Vector3.new(15,3.4,4),0,"09W")
bar(C2,"C2 PRIVATE BAR",Vector3.new(40,22.3,108),Vector3.new(13,3.4,4),0,"09E")

-- C3 rear bridge: actual corridor connecting west/east VIP and private rooms.
floor(C3,"C3 SOCIAL BRIDGE",Vector3.new(90,1,26),Vector3.new(0,20,138),P.stone2,Enum.Material.Marble,nil)
wallX(C3,"C3 REAR OUTER WALL",151,-45,45,29,18,2,P.charcoal,nil)
-- club-facing glass overlooking DJ/stage.
glass(C3,"C3 CLUB VIEW GLASS",Vector3.new(46,6,.45),CFrame.new(0,23,125.3),nil)

-- Queen Skybox: enclosed premium room with one glass face, not just a throne on a platform.
local qX1,qX2=-31,-5;local qZ1,qZ2=128,148
wallZ(C3,"C3 QUEEN WEST WALL",qX1,qZ1,qZ2,26,12,1.5,P.black,"10")
wallX(C3,"C3 QUEEN REAR WALL",qZ2,qX1,qX2,26,12,1.5,P.black,"10")
doorwayWallZ(C3,"C3 QUEEN EAST WALL",qX2,qZ1,qZ2,138,7,26,12,1.5,P.black,"10")
glass(C3,"C3 QUEEN CLUB GLASS",Vector3.new(26,8,.5),CFrame.new(-18,25,128.2),"10")
part(C3,"C3 QUEEN CEILING",Vector3.new(26,.5,20),CFrame.new(-18,32,138),P.black,Enum.Material.SmoothPlastic,0,true,"10")
sofa(C3,"C3 QUEEN SOFA",Vector3.new(-18,21.3,141),14,0,P.cream,"10")
tableLow(C3,"C3 QUEEN TABLE",Vector3.new(-18,21.1,136),Vector3.new(7,.7,5),P.black,"10")
neon(C3,"C3 QUEEN CROWN LINE",Vector3.new(12,.18,.18),CFrame.new(-18,29,147.5),P.pink,"10")
light(C3,"C3 QUEEN WARM KEY",Vector3.new(-18,29,137),P.warm,1.25,15,"10")
sign(C3,"C3 QUEEN PLAQUE","BBYA QUEEN",CFrame.new(-18,27.5,147.2),Vector3.new(12,1.7,.25),P.pink,Enum.NormalId.Front,"10")

-- Private Room West: real enclosed room.
local wX1,wX2=-45,-32;local prZ1,prZ2=128,148
wallZ(C3,"C3 PRW WEST",wX1,prZ1,prZ2,25,10,1.3,P.graphite,"12W")
wallX(C3,"C3 PRW REAR",prZ2,wX1,wX2,25,10,1.3,P.graphite,"12W")
doorwayWallZ(C3,"C3 PRW EAST",wX2,prZ1,prZ2,138,6,25,10,1.3,P.graphite,"12W")
glass(C3,"C3 PRW FRONT GLASS",Vector3.new(13,7,.4),CFrame.new(-38.5,24.5,128.2),"12W")
sofa(C3,"C3 PRW SOFA",Vector3.new(-38.5,21.3,142),9,0,P.graphite,"12W")
tableLow(C3,"C3 PRW TABLE",Vector3.new(-38.5,21.1,137),Vector3.new(5,.6,4),P.black,"12W")
light(C3,"C3 PRW LIGHT",Vector3.new(-38.5,28,138),P.warm,.95,11,"12W")
sign(C3,"C3 PRW PLAQUE","PRIVATE",CFrame.new(-32.7,26.8,132),Vector3.new(.25,1.2,5),P.gold,Enum.NormalId.Left,"12W")

-- Private Room East: real enclosed room.
local eX1,eX2=25,45
wallZ(C3,"C3 PRE EAST",eX2,prZ1,prZ2,25,10,1.3,P.graphite,"12E")
wallX(C3,"C3 PRE REAR",prZ2,eX1,eX2,25,10,1.3,P.graphite,"12E")
doorwayWallZ(C3,"C3 PRE WEST",eX1,prZ1,prZ2,138,6,25,10,1.3,P.graphite,"12E")
glass(C3,"C3 PRE FRONT GLASS",Vector3.new(20,7,.4),CFrame.new(35,24.5,128.2),"12E")
sofa(C3,"C3 PRE SOFA",Vector3.new(35,21.3,142),11,0,P.cream,"12E")
tableLow(C3,"C3 PRE TABLE",Vector3.new(35,21.1,137),Vector3.new(5,.6,4),P.black,"12E")
light(C3,"C3 PRE LIGHT",Vector3.new(35,28,138),P.warm,.95,11,"12E")
sign(C3,"C3 PRE PLAQUE","PRIVATE",CFrame.new(25.7,26.8,132),Vector3.new(.25,1.2,5),P.gold,Enum.NormalId.Right,"12E")

-- Real VIP connection to lift: broad landing outside shaft opening at VIP level.
part(C2,"C2 LIFT APPROACH",Vector3.new(18,1,13),CFrame.new(59,20,112),P.stone2,Enum.Material.Marble,0,true,nil)
clearPad(C2,"C2 LIFT CLEAR LANDING",Vector3.new(59,20.62,112),Vector3.new(12,.12,9),nil)
-- small direction plaque only.
twoFaceSign(C2,"C2 LIFT WAYFINDING","LIFT / ROOFTOP →","← VIP LOUNGE",CFrame.new(50,27,116),Vector3.new(12,1.5,.25),P.white,nil)

workspace:SetAttribute("BBYAV6VIPFloor","COMPLETE")
