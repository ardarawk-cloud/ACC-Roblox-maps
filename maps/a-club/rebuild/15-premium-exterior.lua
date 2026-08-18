-- BBYA SOCIAL HUB — PHASE 2 PREMIUM EXTERIOR
-- Strengthens the owner-reference silhouette without adding fake floors.
-- All elements attach to the real ground/mezzanine/VIP/rooftop geometry from 10-architecture.lua.

-- =========================================================
-- ARRIVAL / CENTRAL HERO FACADE
-- =========================================================
-- Dark hospitality plinth ties the three masses together.
part(A2,"HERO FACADE PLINTH",Vector3.new(196,3,5),CFrame.new(4,2,-10.5),C.black,Enum.Material.Slate,0,true)

-- Double-height transparent social entrance in the middle.
for _,x in ipairs({-2,22,46}) do
    part(A2,"ATRIUM FRONT MULLION "..x,Vector3.new(.8,17,.8),CFrame.new(x,9,-10.8),C.graphite,Enum.Material.Metal,0,true)
end
for _,x in ipairs({9.5,34}) do
    local g=glass(A2,"ATRIUM HERO GLASS "..x,Vector3.new(23,15,.45),CFrame.new(x,8.7,-11.15),.36)
    g.CanCollide=false
end
part(A2,"ATRIUM HERO CANOPY",Vector3.new(58,1.2,11),CFrame.new(22,18,-7),C.charcoal,Enum.Material.Metal,0,true)
neon(A2,"ATRIUM CANOPY PINK",Vector3.new(54,.18,.18),CFrame.new(22,17.35,-12.4),C.pink)
neon(A2,"ATRIUM CANOPY CYAN",Vector3.new(32,.14,.14),CFrame.new(22,16.85,-12.55),C.cyan)

-- Central BBYA vertical brand tower behind the foreground wordmark.
part(A2,"BRAND TOWER",Vector3.new(44,26,3),CFrame.new(-12,28,-7.5),C.black,Enum.Material.Slate,0,true)
for _,x in ipairs({-31,-24,-17,-10,-3,4}) do
    neon(A2,"BRAND TOWER FIN "..x,Vector3.new(.15,22,.15),CFrame.new(x,28,-9.1),x%2==0 and C.cyan or C.pink)
end

-- =========================================================
-- LEFT MULTI-LEVEL CLUB WING
-- =========================================================
-- Projecting balcony boxes create the layered look in the reference.
for _,cfg in ipairs({
    {y=16.7,z=10,w=32,d=14,label="L1 SOUTH"},
    {y=16.7,z=48,w=32,d=14,label="L1 NORTH"},
    {y=30.7,z=30,w=32,d=14,label="L2 MID"},
    {y=30.7,z=62,w=32,d=14,label="L2 NORTH"},
}) do
    part(A4,"CLUB BALCONY SLAB "..cfg.label,Vector3.new(cfg.w,1.1,cfg.d),CFrame.new(-78,cfg.y,cfg.z),C.charcoal,Enum.Material.Slate,0,true)
    rail(A4,"CLUB BALCONY GLASS "..cfg.label,Vector3.new(cfg.w-2,4.2,.4),CFrame.new(-78,cfg.y+2.6,cfg.z-cfg.d/2+.2))
    neon(A4,"CLUB BALCONY EDGE "..cfg.label,Vector3.new(cfg.w-3,.15,.15),CFrame.new(-78,cfg.y+1,cfg.z-cfg.d/2),cfg.y<20 and C.cyan or C.pink)
end

-- Vertical glass curtain-wall rhythm along club facade.
for _,x in ipairs({-88,-80,-72,-64,-56}) do
    part(A4,"CLUB FACADE FIN "..x,Vector3.new(.5,43,3),CFrame.new(x,22,-8.7),C.graphite,Enum.Material.Metal,0,true)
end

-- Upper crown/cornice on left wing.
part(A4,"CLUB TOP CORNICE",Vector3.new(54,2.2,8),CFrame.new(-70,44,-5),C.black,Enum.Material.Metal,0,true)
neon(A4,"CLUB TOP CORNICE PINK",Vector3.new(48,.2,.2),CFrame.new(-70,45,-9.05),C.pink)

-- Giant attached CLUB identity, smaller than main BBYA wordmark.
sign(A4,"CLUB WING BRAND","BBYA\nCLUB",CFrame.new(-70,36.5,-9.25),Vector3.new(31,8,.35),C.pink,Enum.NormalId.Front)

-- =========================================================
-- RIGHT VIP WING / TERRACED READ
-- =========================================================
-- Framed glass VIP frontage.
for _,x in ipairs({34,50,66,82,98,105}) do
    part(A5,"VIP FACADE FIN "..x,Vector3.new(.6,18,.8),CFrame.new(x,9,-8.2),C.graphite,Enum.Material.Metal,0,true)
end
for _,x in ipairs({42,58,74,90}) do
    local g=glass(A5,"VIP FACADE PANEL "..x,Vector3.new(14,13,.4),CFrame.new(x,7.1,-8.5),.38)
    g.CanCollide=false
end
part(A5,"VIP FRONT CANOPY",Vector3.new(70,1.1,10),CFrame.new(69,18,-5),C.black,Enum.Material.Metal,0,true)
neon(A5,"VIP FRONT EDGE",Vector3.new(64,.18,.18),CFrame.new(69,17.35,-10),C.pink)

-- Architectural VIP portal at the center-right entrance.
part(A5,"VIP PORTAL L",Vector3.new(1.2,12,2),CFrame.new(67,6,-10),C.graphite,Enum.Material.Metal,0,true)
part(A5,"VIP PORTAL R",Vector3.new(1.2,12,2),CFrame.new(88,6,-10),C.graphite,Enum.Material.Metal,0,true)
part(A5,"VIP PORTAL TOP",Vector3.new(22,1.2,2),CFrame.new(77.5,12,-10),C.graphite,Enum.Material.Metal,0,true)
neon(A5,"VIP PORTAL LIGHT",Vector3.new(19,.18,.18),CFrame.new(77.5,11.25,-11.1),C.pink)
sign(A5,"VIP PORTAL BRAND","VIP AREA",CFrame.new(77.5,9,-11.25),Vector3.new(17,3,.3),C.pink,Enum.NormalId.Front)

-- =========================================================
-- ROOFTOP RESORT SILHOUETTE
-- =========================================================
-- Warm roof frame above cabana/bar side, leaving pool sky open.
for _,x in ipairs({5,28,68,91}) do
    part(A6,"ROOF PERGOLA POST "..x,Vector3.new(.7,11,.7),CFrame.new(x,37.5,69),C.wood,Enum.Material.Wood,0,true)
end
for _,x in ipairs({16.5,79.5}) do
    part(A6,"ROOF PERGOLA BEAM "..x,Vector3.new(24,.7,12),CFrame.new(x,43,69),C.wood,Enum.Material.WoodPlanks,0,true)
end

-- Rooftop pool-party billboard from the reference, attached to a real terrace edge.
part(A6,"POOL PARTY SIGN POST L",Vector3.new(.6,7,.6),CFrame.new(73,37,-6),C.graphite,Enum.Material.Metal,0,true)
part(A6,"POOL PARTY SIGN POST R",Vector3.new(.6,7,.6),CFrame.new(101,37,-6),C.graphite,Enum.Material.Metal,0,true)
sign(A6,"POOL PARTY BILLBOARD","ROOFTOP\nPOOL PARTY",CFrame.new(87,41,-6.4),Vector3.new(27,7,.35),C.cyan,Enum.NormalId.Front)
neon(A6,"POOL PARTY BILLBOARD EDGE",Vector3.new(26,.18,.18),CFrame.new(87,44.7,-6.7),C.pink)

-- Infinity edge frame makes the water visible from the arrival hero angle.
part(A6,"INFINITY EDGE LOWER",Vector3.new(70,.8,1),CFrame.new(48,31.4,-.7),C.graphite,Enum.Material.Metal,0,true)
neon(A6,"INFINITY HERO CYAN",Vector3.new(66,.2,.2),CFrame.new(48,33.8,-.95),C.cyan)

-- Rooftop side fascia with restrained warm light, not a second nightclub.
part(A6,"ROOF FRONT FASCIA",Vector3.new(110,3,2),CFrame.new(48,31.8,-12),C.charcoal,Enum.Material.Slate,0,true)
for _,x in ipairs({4,26,48,70,92}) do
    neon(A6,"ROOF WARM FASCIA "..x,Vector3.new(13,.12,.12),CFrame.new(x,32.1,-13.05),C.warm)
end

-- =========================================================
-- LANDSCAPE / HERO DEPTH
-- =========================================================
for _,cfg in ipairs({
    {-92,-63,13},{-76,-67,11},{84,-67,12},{100,-59,14},
}) do
    palm(A1,"HERO PALM "..cfg[1],Vector3.new(cfg[1],0,cfg[2]),cfg[3])
end

-- Low illuminated planter walls frame the social approach without closing it.
for _,x in ipairs({-82,-58,58,82}) do
    part(A1,"HERO PLANTER "..x,Vector3.new(18,2.2,7),CFrame.new(x,1.2,-36),C.charcoal,Enum.Material.Slate,0,true)
    neon(A1,"HERO PLANTER GLOW "..x,Vector3.new(15,.12,.12),CFrame.new(x,2.35,-39.55),x<0 and C.pink or C.cyan)
end

workspace:SetAttribute("BBYAPremiumExterior","PHASE_2_COMPLETE")
workspace:SetAttribute("BBYAReferenceSilhouette","LEFT_CLUB_CENTER_SOCIAL_RIGHT_VIP_UPPER_POOL")
