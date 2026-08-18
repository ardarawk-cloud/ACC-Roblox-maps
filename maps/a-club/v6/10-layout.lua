-- BBYA SOCIAL HUB V6 — CLEAN COORDINATE PLAN
-- Fixed architectural grid. Decoration must respect these boundaries and clear lanes.

local L={
 G=0.5, VIP=20.5, ROOF=40.5, BASE=-11.5,
 minX=-72,maxX=72,frontZ=-42,backZ=154,
 centerLaneHalf=10,
}

-- Ground zones
local A1=zone("A1","SOCIAL ARRIVAL PLAZA","G",Vector3.new(0,L.G,-24),Vector3.new(144,18,36))
local A2=zone("A2","BBYA STOREFRONT ENTRANCE","G",Vector3.new(0,L.G,4),Vector3.new(144,18,20))
local A3=zone("A3","SOCIAL COMMONS","G",Vector3.new(0,L.G,38),Vector3.new(144,18,48))
local A4=zone("A4","CLUB FACILITY / DANCE HALL","G",Vector3.new(0,L.G,96),Vector3.new(92,18,68))
local A5=zone("A5","SOCIAL BAR","G",Vector3.new(59,L.G,94),Vector3.new(26,18,64))
local A6=zone("A6","CHILL / CONVERSATION LOUNGE","G",Vector3.new(-59,L.G,94),Vector3.new(26,18,64))
local B1=zone("B1","WEST STAIR CORE","G-VIP",Vector3.new(-56,10.5,132),Vector3.new(28,38,34))
local B2=zone("B2","EAST STAIR CORE","G-VIP",Vector3.new(33,10.5,132),Vector3.new(28,38,34))
local B3=zone("B3","LIFT CORE","G-ROOF",Vector3.new(59,20.5,132),Vector3.new(22,58,30))

-- VIP floor
local C1=zone("C1","VIP WEST LOUNGE","VIP",Vector3.new(-43,L.VIP,96),Vector3.new(54,18,68))
local C2=zone("C2","VIP EAST LOUNGE","VIP",Vector3.new(28,L.VIP,96),Vector3.new(54,18,68))
local C3=zone("C3","QUEEN / PRIVATE SOCIAL BRIDGE","VIP",Vector3.new(0,L.VIP,137),Vector3.new(90,18,26))

-- Rooftop
local D1=zone("D1","ROOFTOP ARRIVAL","R",Vector3.new(46,L.ROOF,132),Vector3.new(48,10,32))
local D2=zone("D2","INFINITY POOL + POOL DJ","R",Vector3.new(0,L.ROOF,92),Vector3.new(86,10,56))
local D3=zone("D3","SKY BAR","R",Vector3.new(57,L.ROOF,88),Vector3.new(28,10,56))
local D4=zone("D4","ROOFTOP CHILL","R",Vector3.new(-57,L.ROOF,88),Vector3.new(28,10,56))
local D5=zone("D5","CABANAS","R",Vector3.new(0,L.ROOF,132),Vector3.new(88,10,28))
local D6=zone("D6","PHOTO / VIEW DECK","R",Vector3.new(0,L.ROOF,54),Vector3.new(86,10,18))

-- Service basement
local S1=zone("S1","SERVICE / STAFF / TECHNICAL","B",Vector3.new(0,L.BASE,100),Vector3.new(110,14,80))

-- Blueprint component registry, with actual room extents rather than text-only labels.
component(A1,"01","ARRIVAL PLAZA",Vector3.new(0,L.G,-24),Vector3.new(120,12,28))
component(A3,"02","WELCOME / HOST",Vector3.new(42,L.G,31),Vector3.new(34,12,20))
component(A3,"03","PHOTO / SELFIE",Vector3.new(-43,L.G,31),Vector3.new(34,12,20))
component(A3,"04","LOOK / OUTFIT STUDIO",Vector3.new(-43,L.G,51),Vector3.new(34,12,18))
component(A4,"05","DANCE FLOOR",Vector3.new(0,L.G,96),Vector3.new(58,12,42))
component(A4,"06","DJ BOOTH",Vector3.new(0,L.G,124),Vector3.new(28,12,12))
component(A4,"07","STAGE / LIGHTING",Vector3.new(0,L.G,116),Vector3.new(50,12,16))
component(A5,"08","SOCIAL BAR",Vector3.new(59,L.G,94),Vector3.new(24,12,46))
component(C1,"09W","VIP LOUNGE WEST",Vector3.new(-43,L.VIP,96),Vector3.new(48,12,54))
component(C2,"09E","VIP LOUNGE EAST",Vector3.new(28,L.VIP,96),Vector3.new(48,12,54))
component(C3,"10","QUEEN SKYBOX",Vector3.new(-18,L.VIP,137),Vector3.new(32,12,20))
component(C1,"11W","VIP BALCONY WEST",Vector3.new(-30,L.VIP,66),Vector3.new(28,10,10))
component(C2,"11E","VIP BALCONY EAST",Vector3.new(21,L.VIP,66),Vector3.new(28,10,10))
component(C3,"12W","PRIVATE ROOM WEST",Vector3.new(-35,L.VIP,137),Vector3.new(20,10,18))
component(C3,"12E","PRIVATE ROOM EAST",Vector3.new(35,L.VIP,137),Vector3.new(20,10,18))
component(D2,"13","INFINITY POOL",Vector3.new(0,L.ROOF,92),Vector3.new(66,4,36))
component(D2,"14","POOL DJ",Vector3.new(0,L.ROOF,119),Vector3.new(20,8,10))
component(D3,"15","SKY BAR",Vector3.new(57,L.ROOF,88),Vector3.new(24,8,42))
component(D5,"16","CABANAS",Vector3.new(0,L.ROOF,132),Vector3.new(82,8,22))
component(D6,"17","VIEW DECK / CITY VIEW",Vector3.new(0,L.ROOF,54),Vector3.new(80,8,14))

workspace:SetAttribute("BBYAV6Grid","A1-A6/B1-B3/C1-C3/D1-D6/S1")
workspace:SetAttribute("BBYAV6Levels","BASE=-11.5;G=0.5;VIP=20.5;ROOF=40.5")
