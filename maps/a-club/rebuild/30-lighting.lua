-- BBYA SOCIAL HUB — CLEAN REBUILD LIGHTING
-- V7 alignment pass: remove obsolete foreground court lighting and focus visual hierarchy on club / atrium / VIP / rooftop.

-- Critical avatar fill lights: keep people readable for hangout/screenshots.
for _,p in ipairs({
    Vector3.new(-58,14,15),Vector3.new(-28,14,15),Vector3.new(2,14,15),
    Vector3.new(-58,14,43),Vector3.new(-28,14,43),Vector3.new(2,14,43),
    Vector3.new(15,12,20),Vector3.new(15,12,52),
    Vector3.new(50,11,12),Vector3.new(78,11,12),Vector3.new(50,11,48),Vector3.new(78,11,48),
}) do
    local l=light(ROOT,"AVATAR FILL",p,C.white,1.35,24)
    l.Parent:SetAttribute("BBYACriticalFill",true)
end

-- Main club truss and show heads.
for _,z in ipairs({12,34,56}) do
    part(A3,"CLUB TRUSS "..z,Vector3.new(76,.7,.7),CFrame.new(-28,19,z),C.black,Enum.Material.Metal,0,false)
    for _,x in ipairs({-58,-43,-28,-13,2}) do
        local head=part(A3,"SHOW HEAD "..x.." "..z,Vector3.new(2,1.5,2),CFrame.new(x,18.3,z),C.black,Enum.Material.Metal,0,false)
        local s=Instance.new("SpotLight")
        s.Name="SHOW BEAM"
        s.Face=Enum.NormalId.Bottom
        s.Angle=36
        s.Brightness=3.0
        s.Range=55
        s.Shadows=false
        s.Color=((x+z)%2==0) and C.pink or C.cyan
        s.Parent=head
        head:SetAttribute("BBYAShowLight",true)
    end
end

-- LED wall pattern and booth glow.
for row=0,4 do
    for col=0,9 do
        local x=-56+col*6.2
        local y=5.3+row*2.1
        neon(A3,"LED PIXEL "..row.." "..col,Vector3.new(5.1,1.25,.18),CFrame.new(x,y,85.25),(row+col)%3==0 and C.cyan or C.pink)
    end
end
neon(A3,"DJ BOOTH FRONT LIGHT",Vector3.new(21,.25,.2),CFrame.new(-28,5,69.4),C.pink)

-- Club tower glow: layered, not uniformly bright.
for _,y in ipairs({8,16,30,42}) do
    for _,x in ipairs({-84,-70,-56}) do
        light(A4,"TOWER GLOW "..x.." "..y,Vector3.new(x,y,-6),y>=30 and C.pink or C.cyan,.72,12)
    end
end

-- Social atrium: brighter and warmer than club so circulation reads immediately.
for _,p in ipairs({
    Vector3.new(-2,14,5),Vector3.new(20,14,5),Vector3.new(42,14,5),
    Vector3.new(-2,14,35),Vector3.new(20,14,35),Vector3.new(42,14,35),
    Vector3.new(-2,14,65),Vector3.new(20,14,65),Vector3.new(42,14,65),
}) do light(A2,"ATRIUM WARM",p,C.warm,1.05,18) end

-- VIP premium lighting.
for _,z in ipairs({5,24,43,62}) do
    light(A5,"VIP WARM "..z,Vector3.new(54,13,z),C.warm,.95,17)
    light(A5,"VIP PINK "..z,Vector3.new(88,13,z),C.pink,.48,14)
end
neon(A5,"VIP CEILING LINE L",Vector3.new(.18,.18,68),CFrame.new(44,17.4,34),C.pink)
neon(A5,"VIP CEILING LINE R",Vector3.new(.18,.18,68),CFrame.new(92,17.4,34),C.cyan)

-- Rooftop resort: warm hospitality + cyan pool only. No full-club neon wash.
for _,p in ipairs({
    Vector3.new(4,39,0),Vector3.new(25,39,0),Vector3.new(70,39,0),Vector3.new(92,39,0),
    Vector3.new(4,39,48),Vector3.new(92,39,48),Vector3.new(18,39,72),Vector3.new(78,39,72),
}) do light(A6,"ROOF WARM",p,C.warm,.82,15) end
for _,x in ipairs({20,36,52,68,84}) do
    local l=light(A6,"POOL GLOW "..x,Vector3.new(x,31.4,22),C.cyan,.68,12)
    l.Parent:SetAttribute("BBYAPoolLight",true)
end
neon(A6,"POOL DJ FRONT",Vector3.new(14,.2,.18),CFrame.new(48,34.6,63.45),C.pink)
for _,x in ipairs({39,57}) do light(A6,"POOL DJ WARM "..x,Vector3.new(x,38,64),C.warm,.72,11) end

-- Hero facade wash: readable from spawn, but avoids flattening the building.
for _,cfg in ipairs({
    {Vector3.new(-76,24,-15),C.pink,1.05,25},
    {Vector3.new(-28,23,-15),C.cyan,.85,23},
    {Vector3.new(24,19,-15),C.warm,.95,24},
    {Vector3.new(76,19,-15),C.pink,.78,22},
}) do
    local l=light(ROOT,"HERO FACADE WASH",cfg[1],cfg[2],cfg[3],cfg[4])
    l.Parent:SetAttribute("BBYAFacadeWash",true)
end

-- Welcome/selfie keys.
for _,p in ipairs({Vector3.new(8,11,64),Vector3.new(24,11,64),Vector3.new(-1,11,61)}) do
    local l=light(A2,"SOCIAL PHOTO KEY",p,C.white,1.2,15)
    l.Parent:SetAttribute("BBYACriticalFill",true)
end

-- Mezzanine lounge pools separated from club show palette.
for _,y in ipairs({22,36}) do
    for _,z in ipairs({18,42,66}) do
        light(A4,"MEZZ LOUNGE WARM "..y.." "..z,Vector3.new(-78,y,z),C.warm,.72,11)
    end
end

-- VIP portal + integrated Queen niche only; obsolete foreground Queen/support court lighting removed.
light(A5,"VIP PORTAL KEY",Vector3.new(77,14,-3),C.pink,.9,14)
light(A5,"VIP QUEEN NICHE KEY",Vector3.new(47,10,61),C.warm,.9,13)

-- Sky bar and rooftop photo deck.
for _,p in ipairs({Vector3.new(86,41,51),Vector3.new(18,42,6),Vector3.new(78,42,6)}) do
    light(A6,"ROOF LIFESTYLE KEY",p,C.warm,.75,12)
end

workspace:SetAttribute("BBYALighting","V7_REFERENCE_NIGHT_PASS")
workspace:SetAttribute("BBYAFacadeLighting","HERO_READABLE_DEPTH")
workspace:SetAttribute("BBYAObsoleteCourtLighting",false)
