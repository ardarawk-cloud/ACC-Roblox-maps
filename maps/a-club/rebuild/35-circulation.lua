-- BBYA SOCIAL HUB — PHASE 3 CIRCULATION / LANDING SAFETY
-- V7 alignment pass: circulation follows the cleaned architecture and keeps hero sightlines open.

local function clearMarker(parent,name,cf,size)
    local p=part(parent,name,size,cf,C.white,Enum.Material.SmoothPlastic,1,false)
    p.CanQuery=false
    p:SetAttribute("BBYAClearLane",true)
    return p
end

-- =========================================================
-- ARRIVAL -> SOCIAL ATRIUM
-- =========================================================
-- Keep the center approach completely free from furniture, planters and decorative mass.
clearMarker(A1,"CLEAR ARRIVAL CENTER",CFrame.new(0,1,-43),Vector3.new(20,.2,50))
clearMarker(A2,"CLEAR ATRIUM CENTER",CFrame.new(22,1,29),Vector3.new(14,.2,66))

-- Floor guidance only; nothing tall is allowed on the arrival axis.
for _,z in ipairs({-66,-54,-42,-30,-18}) do
    neon(A1,"ARRIVAL GUIDE L "..z,Vector3.new(5,.08,.14),CFrame.new(-9,.76,z),C.pink)
    neon(A1,"ARRIVAL GUIDE R "..z,Vector3.new(5,.08,.14),CFrame.new(9,.76,z),C.cyan)
end
for _,z in ipairs({0,14,28,42,56}) do
    neon(A2,"ATRIUM GUIDE "..z,Vector3.new(7,.08,.14),CFrame.new(22,.72,z),z%28==0 and C.cyan or C.warm)
end

-- =========================================================
-- PARALLEL DESTINATIONS: CLUB / VIP
-- =========================================================
clearMarker(A3,"CLEAR CLUB THRESHOLD",CFrame.new(-28,1,2),Vector3.new(24,.2,16))
clearMarker(A5,"CLEAR VIP THRESHOLD",CFrame.new(78,1,-1),Vector3.new(18,.2,16))

-- Club threshold is framed but remains fully open between the piers.
part(A3,"CLUB ENTRY PIER L",Vector3.new(.8,10,.8),CFrame.new(-41,5,-7),C.graphite,Enum.Material.Metal,0,true)
part(A3,"CLUB ENTRY PIER R",Vector3.new(.8,10,.8),CFrame.new(-15,5,-7),C.graphite,Enum.Material.Metal,0,true)
neon(A3,"CLUB ENTRY HEADER",Vector3.new(26,.18,.18),CFrame.new(-28,10,-7.4),C.pink)
sign(A3,"CLUB ENTRY WAYFIND","CLUB / DANCE",CFrame.new(-28,8.2,-7.55),Vector3.new(18,2,.25),C.pink,Enum.NormalId.Front)

-- VIP threshold stays outside the atrium centerline.
neon(A5,"VIP ENTRY FLOOR L",Vector3.new(7,.1,.14),CFrame.new(72,.72,-2),C.gold)
neon(A5,"VIP ENTRY FLOOR R",Vector3.new(7,.1,.14),CFrame.new(84,.72,-2),C.pink)

-- =========================================================
-- SWITCHBACK STAIR SAFETY
-- =========================================================
-- Ground -> mid step-edge lights.
for i=0,27,4 do
    local cf=CFrame.new(Vector3.new(94,1.1,72))*CFrame.new(0,.55*i,-.75*i)
    neon(A5,"STAIR G EDGE "..i,Vector3.new(7.2,.08,.12),cf*CFrame.new(0,.35,-.38),i%8==0 and C.cyan or C.pink)
end

-- Mid -> roof step-edge lights, yaw locked to architecture.
local midBase=CFrame.new(Vector3.new(88,16.7,47))*CFrame.Angles(0,math.rad(180),0)
for i=0,27,4 do
    local cf=midBase*CFrame.new(0,.55*i,-.75*i)
    neon(A5,"STAIR ROOF EDGE "..i,Vector3.new(7.2,.08,.12),cf*CFrame.new(0,.35,-.38),i%8==0 and C.pink or C.cyan)
end

-- Landing rails stay on the sides only; both stair mouths remain open.
rail(A5,"MID LANDING RAIL WEST",Vector3.new(.45,4.8,9),CFrame.new(87.8,19,50))
rail(A5,"MID LANDING RAIL EAST",Vector3.new(.45,4.8,9),CFrame.new(100.2,19,50))
clearMarker(A5,"CLEAR MID LANDING",CFrame.new(94,16.85,50),Vector3.new(10,.2,8))

rail(A6,"ROOF LANDING RAIL WEST",Vector3.new(.45,4.8,11),CFrame.new(80.8,34,69))
rail(A6,"ROOF LANDING RAIL EAST",Vector3.new(.45,4.8,11),CFrame.new(95.2,34,69))
clearMarker(A6,"CLEAR ROOF LANDING",CFrame.new(88,32.05,69),Vector3.new(12,.2,10))

sign(A5,"MID LANDING SIGN","VIP  ←   ROOFTOP  ↑",CFrame.new(101,23,49),Vector3.new(.25,1.8,12),C.white,Enum.NormalId.Left)
sign(A6,"ROOF ARRIVAL SIGN","POOL  ←   SKY BAR  →",CFrame.new(80.4,39,69),Vector3.new(.25,1.8,14),C.white,Enum.NormalId.Right)

-- =========================================================
-- ROOFTOP WALKABILITY
-- =========================================================
-- Main spine from landing to pool/social split. Kept away from pool DJ island and daybeds.
clearMarker(A6,"CLEAR ROOF SOCIAL SPINE",CFrame.new(72,32.2,57),Vector3.new(12,.2,26))
clearMarker(A6,"CLEAR POOL WEST WALK",CFrame.new(8,32.2,23),Vector3.new(12,.2,40))
clearMarker(A6,"CLEAR POOL EAST WALK",CFrame.new(91,32.2,23),Vector3.new(10,.2,40))

-- Low bollards only at route edges; none inside clear lanes.
for _,cfg in ipairs({{65,54},{79,54},{65,67},{79,67},{15,4},{15,20},{15,36},{84,4},{84,20},{84,36}}) do
    local x,z=cfg[1],cfg[2]
    part(A6,"ROOF BOLLARD "..x.." "..z,Vector3.new(.7,2.2,.7),CFrame.new(x,33.1,z),C.charcoal,Enum.Material.Metal,0,true)
    local l=light(A6,"ROOF BOLLARD LIGHT "..x.." "..z,Vector3.new(x,34,z),C.warm,.55,7)
    l.Parent:SetAttribute("BBYACirculationLight",true)
end

workspace:SetAttribute("BBYACirculation","PHASE_3_LOCKED_CLEAR")
workspace:SetAttribute("BBYAClearLaneCount",7)
workspace:SetAttribute("BBYACirculationAlignment","V7_ARCHITECTURE_SYNC")
