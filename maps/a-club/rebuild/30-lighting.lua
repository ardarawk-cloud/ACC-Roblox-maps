-- BBYA SOCIAL HUB — CLEAN REBUILD LIGHTING

-- Critical avatar fill lights: keep people readable for hangout/screenshots.
for _,p in ipairs({
    Vector3.new(-58,14,15),Vector3.new(-28,14,15),Vector3.new(2,14,15),
    Vector3.new(-58,14,43),Vector3.new(-28,14,43),Vector3.new(2,14,43),
    Vector3.new(15,12,20),Vector3.new(15,12,52),
    Vector3.new(50,11,12),Vector3.new(78,11,12),Vector3.new(50,11,48),Vector3.new(78,11,48),
}) do
    local l=light(ROOT,"AVATAR FILL",p,C.white,1.45,24)
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
        s.Brightness=3.2
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
neon(A3,"DJ BOOTH FRONT",Vector3.new(21,.25,.2),CFrame.new(-28,5,69.4),C.pink)

-- Left tower exterior glow from the hero view.
for _,y in ipairs({6,15,29,42}) do
    for _,x in ipairs({-84,-70,-56}) do
        light(A4,"TOWER GLOW "..x.." "..y,Vector3.new(x,y,-6),y>20 and C.pink or C.cyan,.85,13)
    end
end

-- Atrium hospitality: warm/pink, not nightclub-dark.
for _,p in ipairs({
    Vector3.new(-2,14,5),Vector3.new(20,14,5),Vector3.new(42,14,5),
    Vector3.new(-2,14,35),Vector3.new(20,14,35),Vector3.new(42,14,35),
    Vector3.new(-2,14,65),Vector3.new(20,14,65),Vector3.new(42,14,65),
}) do light(A2,"ATRIUM WARM",p,C.warm,1.15,19) end

-- VIP premium lighting.
for _,z in ipairs({5,24,43,62}) do
    light(A5,"VIP WARM "..z,Vector3.new(54,13,z),C.warm,1.05,18)
    light(A5,"VIP PINK "..z,Vector3.new(88,13,z),C.pink,.55,15)
end
neon(A5,"VIP CEILING LINE L",Vector3.new(.18,.18,68),CFrame.new(44,17.4,34),C.pink)
neon(A5,"VIP CEILING LINE R",Vector3.new(.18,.18,68),CFrame.new(92,17.4,34),C.cyan)

-- Rooftop resort lighting: restrained, warm, cyan only around water.
for _,p in ipairs({
    Vector3.new(4,39,0),Vector3.new(25,39,0),Vector3.new(70,39,0),Vector3.new(92,39,0),
    Vector3.new(4,39,48),Vector3.new(92,39,48),Vector3.new(18,39,72),Vector3.new(78,39,72),
}) do light(A6,"ROOF WARM",p,C.warm,.9,16) end
for _,x in ipairs({20,36,52,68,84}) do
    local l=light(A6,"POOL GLOW "..x,Vector3.new(x,31.4,22),C.cyan,.72,13)
    l.Parent:SetAttribute("BBYAPoolLight",true)
end

-- Pool DJ soft accent.
neon(A6,"POOL DJ FRONT",Vector3.new(14,.2,.18),CFrame.new(48,34.6,63.45),C.pink)
for _,x in ipairs({39,57}) do light(A6,"POOL DJ WARM "..x,Vector3.new(x,38,64),C.warm,.8,12) end

-- Queen/support front court illumination.
light(A7,"QUEEN KEY",Vector3.new(-38,14,-29),C.pink,1.3,20)
light(A7,"SUPPORT KEY",Vector3.new(45,15,-30),C.cyan,1.2,20)

workspace:SetAttribute("BBYALighting","PREMIUM_NIGHT_PASS_1")
