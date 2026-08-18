-- BBYA SOCIAL HUB — PHASE 3 CIRCULATION / LANDING SAFETY
-- Locks readable walking flow without teleporting players or turning the venue into an obby.

local function clearMarker(parent,name,cf,size)
    local p=part(parent,name,size,cf,C.white,Enum.Material.SmoothPlastic,1,false)
    p.CanQuery=false
    p:SetAttribute("BBYAClearLane",true)
    return p
end

-- =========================================================
-- ARRIVAL -> SOCIAL ATRIUM
-- =========================================================
clearMarker(A1,"CLEAR ARRIVAL CENTER",CFrame.new(0,1,-43),Vector3.new(18,.2,50))
clearMarker(A2,"CLEAR ATRIUM CENTER",CFrame.new(30,1,29),Vector3.new(12,.2,62))

-- Architectural floor guidance only; center remains fully walkable.
for _,z in ipairs({-66,-54,-42,-30,-18}) do
    neon(A1,"ARRIVAL GUIDE L "..z,Vector3.new(5,.08,.14),CFrame.new(-8,.76,z),C.pink)
    neon(A1,"ARRIVAL GUIDE R "..z,Vector3.new(5,.08,.14),CFrame.new(8,.76,z),C.cyan)
end
for _,z in ipairs({0,14,28,42,56}) do
    neon(A2,"ATRIUM GUIDE "..z,Vector3.new(7,.08,.14),CFrame.new(30,.72,z),z%28==0 and C.cyan or C.warm)
end

-- =========================================================
-- PARALLEL DESTINATIONS: CLUB / VIP
-- =========================================================
clearMarker(A3,"CLEAR CLUB THRESHOLD",CFrame.new(-28,1,2),Vector3.new(22,.2,14))
clearMarker(A5,"CLEAR VIP THRESHOLD",CFrame.new(78,1,-1),Vector3.new(16,.2,14))

part(A3,"CLUB ENTRY PIER L",Vector3.new(.8,10,.8),CFrame.new(-40,5,-7),C.graphite,Enum.Material.Metal,0,true)
part(A3,"CLUB ENTRY PIER R",Vector3.new(.8,10,.8),CFrame.new(-16,5,-7),C.graphite,Enum.Material.Metal,0,true)
neon(A3,"CLUB ENTRY HEADER",Vector3.new(24,.18,.18),CFrame.new(-28,10,-7.4),C.pink)
sign(A3,"CLUB ENTRY WAYFIND","CLUB / DANCE",CFrame.new(-28,8.2,-7.55),Vector3.new(18,2,.25),C.pink,Enum.NormalId.Front)

-- VIP portal already exists; add a restrained floor threshold so the route reads from the atrium.
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
-- Mid -> roof step-edge lights (yaw 180, matching the corrected architecture stair).
local midBase=CFrame.new(Vector3.new(88,16.7,47))*CFrame.Angles(0,math.rad(180),0)
for i=0,27,4 do
    local cf=midBase*CFrame.new(0,.55*i,-.75*i)
    neon(A5,"STAIR ROOF EDGE "..i,Vector3.new(7.2,.08,.12),cf*CFrame.new(0,.35,-.38),i%8==0 and C.pink or C.cyan)
end

-- Landing rails are positioned on the sides only; stair mouths stay open.
rail(A5,"MID LANDING RAIL WEST",Vector3.new(.45,4.8,9),CFrame.new(87.8,19,50))
rail(A5,"MID LANDING RAIL EAST",Vector3.new(.45,4.8,9),CFrame.new(100.2,19,50))
clearMarker(A5,"CLEAR MID LANDING",CFrame.new(94,16.85,50),Vector3.new(10,.2,8))

rail(A6,"ROOF LANDING RAIL WEST",Vector3.new(.45,4.8,11),CFrame.new(80.8,34,69))
rail(A6,"ROOF LANDING RAIL EAST",Vector3.new(.45,4.8,11),CFrame.new(95.2,34,69))
clearMarker(A6,"CLEAR ROOF LANDING",CFrame.new(88,32.05,69),Vector3.new(12,.2,10))

-- Small direction blades at landings, never giant floating labels.
sign(A5,"MID LANDING SIGN","VIP  ←   ROOFTOP  ↑",CFrame.new(101,23,49),Vector3.new(.25,1.8,12),C.white,Enum.NormalId.Left)
sign(A6,"ROOF ARRIVAL SIGN","POOL  ←   SKY BAR  →",CFrame.new(80.4,39,69),Vector3.new(.25,1.8,14),C.white,Enum.NormalId.Right)

-- =========================================================
-- ROOFTOP WALKABILITY
-- =========================================================
-- Keep one clean spine from roof landing to pool / bar split.
clearMarker(A6,"CLEAR ROOF SOCIAL SPINE",CFrame.new(72,32.2,58),Vector3.new(12,.2,24))
clearMarker(A6,"CLEAR POOL WEST WALK",CFrame.new(7,32.2,23),Vector3.new(10,.2,40))

-- Warm low bollards frame the walk instead of blocking it.
for _,cfg in ipairs({{66,56},{78,56},{66,66},{78,66},{8,4},{8,20},{8,36}}) do
    local x,z=cfg[1],cfg[2]
    part(A6,"ROOF BOLLARD "..x.." "..z,Vector3.new(.7,2.2,.7),CFrame.new(x,33.1,z),C.charcoal,Enum.Material.Metal,0,true)
    local l=light(A6,"ROOF BOLLARD LIGHT "..x.." "..z,Vector3.new(x,34,z),C.warm,.55,7)
    l.Parent:SetAttribute("BBYACirculationLight",true)
end

workspace:SetAttribute("BBYACirculation","PHASE_3_LOCKED_CLEAR")
workspace:SetAttribute("BBYAClearLaneCount",6)
