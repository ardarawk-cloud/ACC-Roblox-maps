-- [A2] PREMIUM MAIN FACADE — SOCIAL STOREFRONT
-- Reference target: mounted BBYA neon identity above an open, visible social interior.

finish(A2,"WEST FACADE CLADDING",Vector3.new(42,22,.35),CFrame.new(-68,12,132.15),P.black,Enum.Material.Slate,0,false)
finish(A2,"EAST FACADE CLADDING",Vector3.new(42,22,.35),CFrame.new(68,12,132.15),P.black,Enum.Material.Slate,0,false)
finish(A2,"HEADER CLADDING",Vector3.new(178,4.6,.4),CFrame.new(0,21.55,132.2),P.charcoal,Enum.Material.Metal,0,false)

-- A real mounted brand wall: logo reads as part of the building, never as a floating event gate.
finish(A2,"BBYA BRAND WALL",Vector3.new(78,10,.75),CFrame.new(0,20.2,132.48),Color3.fromRGB(18,14,22),Enum.Material.Slate,0,false)
zoneSign(A2,"PREMIUM EXTERIOR BRAND","BBYA",CFrame.new(0,21.2,132.92),Vector3.new(55,5.2,.25),P.pink,Enum.NormalId.Back)
zoneSign(A2,"PREMIUM EXTERIOR SUBBRAND","SOCIAL HUB",CFrame.new(0,17.8,132.93),Vector3.new(34,2.4,.25),P.white,Enum.NormalId.Back)

-- Crown mounted directly above the BBYA lettering.
glow(A2,"CROWN BASE",Vector3.new(14,.3,.25),CFrame.new(0,25.3,132.9),P.pink,.50,10)
for i,spec in ipairs({{-5.3,27.0,-28},{-1.8,28.0,-10},{1.8,28.0,10},{5.3,27.0,28}}) do
 glow(A2,"CROWN RAY "..i,Vector3.new(.34,4.7,.25),CFrame.new(spec[1],spec[2],132.9)*CFrame.Angles(0,0,math.rad(spec[3])),P.pink,.42,8)
end

-- Storefront glazing on both wings; the social interior remains visible from the plaza.
finish(A2,"WEST SOCIAL WINDOW",Vector3.new(30,10,.24),CFrame.new(-68,7.5,132.5),P.glass,Enum.Material.Glass,.62,false)
finish(A2,"EAST SOCIAL WINDOW",Vector3.new(30,10,.24),CFrame.new(68,7.5,132.5),P.glass,Enum.Material.Glass,.62,false)
glow(A2,"WEST WINDOW PINK",Vector3.new(30,.18,.2),CFrame.new(-68,12.8,132.68),P.pink,.18,5)
glow(A2,"EAST WINDOW CYAN",Vector3.new(30,.18,.2),CFrame.new(68,12.8,132.68),P.cyan,.18,5)

-- Hospitality canopy under the hero sign, like a social lounge storefront rather than a club checkpoint.
finish(A2,"SOCIAL CANOPY",Vector3.new(94,.7,7),CFrame.new(0,14.9,128.8),P.charcoal,Enum.Material.Metal,0,false)
glow(A2,"CANOPY FRONT EDGE",Vector3.new(90,.2,.2),CFrame.new(0,14.55,132.2),P.pink,.20,6)
for _,x in ipairs({-36,-24,-12,0,12,24,36}) do
 local lamp=glow(A2,"CANOPY WARM LIGHT "..x,Vector3.new(1.8,.18,1.8),CFrame.new(x,14.35,128.6),P.warm,.34,9)
 lamp:SetAttribute("BBYACriticalFill",true)
end

-- Thin vertical accents frame the 92-stud open threshold. No door or checkpoint blocks the center.
glow(A2,"PORTAL WEST",Vector3.new(.24,11,.28),CFrame.new(-45.5,7.6,132.66),P.pink,.20,6)
glow(A2,"PORTAL EAST",Vector3.new(.24,11,.28),CFrame.new(45.5,7.6,132.66),P.cyan,.20,6)
zoneSign(A2,"OPEN HOUSE COPY","COME IN • MEET • HANG OUT • STAY LATE",CFrame.new(0,12.6,132.74),Vector3.new(38,1.7,.25),P.warm,Enum.NormalId.Back)
