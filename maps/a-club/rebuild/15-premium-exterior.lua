-- BBYA SOCIAL HUB — V7 EXTERIOR DETAIL PASS
-- Detail-only layer. Structural massing lives in 10-architecture.lua.

-- Central social frontage: glass/mullions/neon only.
for _,x in ipairs({-2,22,46}) do
    part(A2,"ATRIUM FRONT MULLION "..x,Vector3.new(.7,17,.7),CFrame.new(x,9,-10.8),C.graphite,Enum.Material.Metal,0,true)
end
for _,x in ipairs({9.5,34}) do
    local g=glass(A2,"ATRIUM HERO GLASS "..x,Vector3.new(23,15,.4),CFrame.new(x,8.7,-11.15),.36)
    g.CanCollide=false
end
part(A2,"ATRIUM HERO CANOPY",Vector3.new(58,.7,8),CFrame.new(22,18.2,-7.5),C.charcoal,Enum.Material.Metal,0,true)
neon(A2,"ATRIUM CANOPY PINK",Vector3.new(52,.16,.16),CFrame.new(22,17.7,-11.5),C.pink)

-- Club facade rhythm; no duplicate balcony slabs.
for _,x in ipairs({-88,-80,-72,-64,-56}) do
    part(A4,"CLUB FACADE FIN "..x,Vector3.new(.45,43,2),CFrame.new(x,22,-8.7),C.graphite,Enum.Material.Metal,0,true)
end
neon(A4,"CLUB TOP CORNICE PINK",Vector3.new(44,.18,.18),CFrame.new(-70,44.8,-9.05),C.pink)
sign(A4,"CLUB WING BRAND","BBYA\nCLUB",CFrame.new(-70,36.5,-9.25),Vector3.new(29,7,.3),C.pink,Enum.NormalId.Front)

-- VIP glass/front detailing; structure remains in architecture file.
for _,x in ipairs({34,50,66,82,98,105}) do
    part(A5,"VIP FACADE FIN "..x,Vector3.new(.5,18,.7),CFrame.new(x,9,-8.2),C.graphite,Enum.Material.Metal,0,true)
end
for _,x in ipairs({42,58,74,90}) do
    local g=glass(A5,"VIP FACADE PANEL "..x,Vector3.new(14,13,.35),CFrame.new(x,7.1,-8.5),.38)
    g.CanCollide=false
end
neon(A5,"VIP FRONT EDGE",Vector3.new(62,.16,.16),CFrame.new(69,17.3,-10),C.pink)
sign(A5,"VIP PORTAL BRAND","VIP AREA",CFrame.new(77.5,9,-11.25),Vector3.new(17,3,.3),C.pink,Enum.NormalId.Front)

-- Rooftop resort silhouette: light pergola + sign only.
for _,x in ipairs({5,28,68,91}) do
    part(A6,"ROOF PERGOLA POST "..x,Vector3.new(.6,10,.6),CFrame.new(x,37,69),C.wood,Enum.Material.Wood,0,true)
end
for _,x in ipairs({16.5,79.5}) do
    part(A6,"ROOF PERGOLA BEAM "..x,Vector3.new(24,.6,10),CFrame.new(x,42,69),C.wood,Enum.Material.WoodPlanks,0,true)
end
sign(A6,"POOL PARTY BILLBOARD","ROOFTOP\nPOOL PARTY",CFrame.new(87,41,-6.4),Vector3.new(27,7,.35),C.cyan,Enum.NormalId.Front)
neon(A6,"POOL PARTY BILLBOARD EDGE",Vector3.new(26,.16,.16),CFrame.new(87,44.7,-6.7),C.pink)
neon(A6,"INFINITY HERO CYAN",Vector3.new(64,.18,.18),CFrame.new(48,33.8,-.95),C.cyan)
for _,x in ipairs({4,26,48,70,92}) do
    neon(A6,"ROOF WARM FASCIA "..x,Vector3.new(13,.1,.1),CFrame.new(x,32.1,-13.05),C.warm)
end

-- Landscape depth.
for _,cfg in ipairs({{-92,-63,13},{-76,-67,11},{84,-67,12},{100,-59,14}}) do
    palm(A1,"HERO PALM "..cfg[1],Vector3.new(cfg[1],0,cfg[2]),cfg[3])
end
for _,x in ipairs({-82,-58,58,82}) do
    part(A1,"HERO PLANTER "..x,Vector3.new(18,2.2,7),CFrame.new(x,1.2,-36),C.charcoal,Enum.Material.Slate,0,true)
    neon(A1,"HERO PLANTER GLOW "..x,Vector3.new(15,.12,.12),CFrame.new(x,2.35,-39.55),x<0 and C.pink or C.cyan)
end

workspace:SetAttribute("BBYAPremiumExterior","V7_DETAIL_ONLY")
workspace:SetAttribute("BBYAReferenceSilhouette","LEFT_CLUB_CENTER_SOCIAL_RIGHT_VIP_UPPER_POOL")