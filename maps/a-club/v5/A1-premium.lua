-- [A1] PREMIUM EXTERIOR / SOCIAL ARRIVAL COURTYARD
-- Central x=-12..12 approach axis stays completely clear.

finish(A1,"PREMIUM PLAZA STONE",Vector3.new(160,.18,54),CFrame.new(0,.58,159),P.stone,Enum.Material.Slate,0,false)
finish(A1,"SOCIAL APPROACH WALK",Vector3.new(20,.12,50),CFrame.new(0,.72,158),Color3.fromRGB(49,42,49),Enum.Material.SmoothPlastic,0,false)
glow(A1,"APPROACH LEFT EDGE",Vector3.new(.16,.12,48),CFrame.new(-10.2,.82,158),P.pink,.18,6)
glow(A1,"APPROACH RIGHT EDGE",Vector3.new(.16,.12,48),CFrame.new(10.2,.82,158),P.cyan,.18,6)

-- Casual courtyard pockets instead of a bouncer/red-carpet procession.
palm(A1,"WEST ARRIVAL PALM",Vector3.new(-48,1.6,160),12)
palm(A1,"EAST ARRIVAL PALM",Vector3.new(48,1.6,160),12)
palm(A1,"WEST FRONT PALM",Vector3.new(-68,1.6,177),10)
palm(A1,"EAST FRONT PALM",Vector3.new(68,1.6,177),10)

sofa(A1,"WEST COURTYARD SOFA",Vector3.new(-52,1.4,149),14,0,P.charcoal)
lowTable(A1,"WEST COURTYARD TABLE",Vector3.new(-52,1.3,143),Vector3.new(6,.7,4),P.black)
sofa(A1,"EAST COURTYARD SOFA",Vector3.new(52,1.4,149),14,0,P.charcoal)
lowTable(A1,"EAST COURTYARD TABLE",Vector3.new(52,1.3,143),Vector3.new(6,.7,4),P.black)

-- Grounded warm guide lanterns; no formal queue lane and no floating exterior fixtures.
for _,spec in ipairs({{-20,148},{20,148},{-20,174},{20,174}}) do
 bollard(A1,"SOCIAL GUIDE "..spec[1].." "..spec[2],Vector3.new(spec[1],2,spec[2]),P.warm)
end
for _,spec in ipairs({{-14,154},{14,154},{-14,166},{14,166}}) do
 local lamp=glow(A1,"COURTYARD LANTERN "..spec[1].." "..spec[2],Vector3.new(.5,1.2,.5),CFrame.new(spec[1],1.45,spec[2]),P.warm,.34,9)
 lamp:SetAttribute("BBYACriticalFill",true)
end

zoneSign(A1,"ARRIVAL WAYFINDING","BBYA SOCIAL HUB  •  COME IN ↑",CFrame.new(0,4.2,187.5)*CFrame.Angles(0,math.rad(180),0),Vector3.new(38,3,.25),P.white,Enum.NormalId.Front)
