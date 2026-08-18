-- BBYA V6 — OWNER REFERENCE MASSING PASS
-- Purpose: make the existing playable floors read as one layered/terraced premium complex.
-- This module adds facade framing and destination landmarks only. It does NOT create fake playable floors,
-- does NOT change clear circulation, and does NOT move the V6 coordinate plan.

-- =========================================================
-- LEFT MULTI-LEVEL CLUB / SOCIAL WING
-- Tie the real A6 ground lounge + C1 VIP level into one visible vertical glass facade.
-- =========================================================
local westFacadeX=-72.35
for _,z in ipairs({70,88,106,124}) do
    part(A6,"REF WEST FACADE COLUMN "..z,Vector3.new(.7,39,.7),CFrame.new(westFacadeX,20,z),P.charcoal,Enum.Material.Metal,0,false,nil)
    neon(A6,"REF WEST FACADE PINK LINE "..z,Vector3.new(.14,35,.14),CFrame.new(westFacadeX-.42,20,z),z%36==16 and P.cyan or P.pink,nil)
end

for _,cfg in ipairs({
    {y=8.8,z=79,h=15.5,code="GROUND A"},
    {y=8.8,z=106,h=15.5,code="GROUND B"},
    {y=28.5,z=79,h=15.5,code="VIP A"},
    {y=28.5,z=106,h=15.5,code="VIP B"},
}) do
    local panel=glass(A6,"REF WEST GLASS "..cfg.code,Vector3.new(.3,cfg.h,17),CFrame.new(westFacadeX-.18,cfg.y,cfg.z),nil)
    panel.CanCollide=false
    panel.CanTouch=false
end

-- Physical floor-band language connects the real ground/VIP/roof levels without adding new floors.
neon(A6,"REF WEST LEVEL BAND G",Vector3.new(.18,.18,57),CFrame.new(westFacadeX-.48,17.9,97),P.cyan,nil)
neon(C1,"REF WEST LEVEL BAND VIP",Vector3.new(.18,.18,57),CFrame.new(westFacadeX-.48,38.7,97),P.pink,"11W")

-- Club identity is attached to the real A4 front/stage zone, visible through the open commons axis.
sign(A4,"REF CLUB FACADE MARK","BBYA  CLUB",CFrame.new(-29,15.1,63.1),Vector3.new(25,2.4,.28),P.pink,Enum.NormalId.Front,"07")
neon(A4,"REF CLUB FACADE CYAN",Vector3.new(24,.14,.14),CFrame.new(-29,13.65,63),P.cyan,"07")

-- =========================================================
-- RIGHT-SIDE VIP / ROOFTOP READABILITY
-- The reference composition shows a lower premium destination with an upper pool terrace.
-- We keep the actual V6 paths authoritative and use honest wayfinding/architecture.
-- =========================================================
part(A3,"REF VIP ROUTE PIER L",Vector3.new(.7,8,.7),CFrame.new(45,4.5,60.5),P.charcoal,Enum.Material.Metal,0,true,nil)
part(A3,"REF VIP ROUTE PIER R",Vector3.new(.7,8,.7),CFrame.new(66,4.5,60.5),P.charcoal,Enum.Material.Metal,0,true,nil)
neon(A3,"REF VIP ROUTE TOP",Vector3.new(22,.18,.18),CFrame.new(55.5,8.6,60.5),P.gold,nil)
sign(A3,"REF VIP ROUTE SIGN","VIP  •  ROOFTOP  →",CFrame.new(55.5,7.3,60.25),Vector3.new(19,1.7,.25),P.gold,Enum.NormalId.Front,nil)

-- Real rooftop landmark, attached to the actual D2/D3 terrace edge.
part(D2,"REF ROOFTOP POOL SIGN POST L",Vector3.new(.55,6,.55),CFrame.new(27,44,64.5),P.wood,Enum.Material.Wood,0,true,"13")
part(D2,"REF ROOFTOP POOL SIGN POST R",Vector3.new(.55,6,.55),CFrame.new(55,44,64.5),P.wood,Enum.Material.Wood,0,true,"13")
sign(D2,"REF ROOFTOP POOL LANDMARK","ROOFTOP  POOL",CFrame.new(41,46.6,64.25),Vector3.new(27,2.6,.3),P.cyan,Enum.NormalId.Front,"13")
neon(D2,"REF ROOFTOP POOL UNDERSCORE",Vector3.new(24,.14,.14),CFrame.new(41,45.0,64.05),P.pink,"13")

-- Make the true infinity edge legible in the distant hero composition.
neon(D2,"REF INFINITY EDGE READ",Vector3.new(64,.16,.16),CFrame.new(0,40.75,73.75),P.cyan,"13")

-- =========================================================
-- FOREGROUND SOCIAL LANDMARKS
-- Keep the arrival plaza social rather than empty, while preserving the center approach lane.
-- =========================================================
local function socialPylon(name,x,text,color)
    part(A1,name.." POST",Vector3.new(.55,5,.55),CFrame.new(x,3.1,-9),P.charcoal,Enum.Material.Metal,0,true,"01")
    sign(A1,name.." BOARD",text,CFrame.new(x,5.8,-9),Vector3.new(15,3,.3),color,Enum.NormalId.Front,"01")
end
socialPylon("REF QUEEN SOCIAL",-48,"BBYA\nQUEEN",P.pink)
socialPylon("REF SUPPORT SOCIAL",48,"TOP\nSUPPORTERS",P.cyan)

-- Premium restrained foreground accents; center x=-14..14 stays fully clear.
for _,x in ipairs({-62,-48,48,62}) do
    neon(A1,"REF PLAZA EDGE "..x,Vector3.new(10,.12,.12),CFrame.new(x,.72,-6),x<0 and P.pink or P.cyan,"01")
end

-- =========================================================
-- HERO COMPOSITION STATE
-- =========================================================
workspace:SetAttribute("BBYAV6ReferenceMassing","OWNER_IMAGE_1_LOCKED")
workspace:SetAttribute("BBYAV6HeroComposition","LEFT_CLUB_CENTER_SOCIAL_RIGHT_VIP_UPPER_POOL")
workspace:SetAttribute("BBYAV6NoFakePlayableFloors",true)
