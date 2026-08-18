-- [A2] PREMIUM MAIN FACADE — SOCIAL LIFESTYLE ENTRANCE
-- Wide, visible, welcoming frontage inspired by current social-club venues.

finish(A2,"WEST FACADE CLADDING",Vector3.new(50,22,.35),CFrame.new(-64,12,132.15),P.black,Enum.Material.Slate,0,false)
finish(A2,"EAST FACADE CLADDING",Vector3.new(50,22,.35),CFrame.new(64,12,132.15),P.black,Enum.Material.Slate,0,false)
finish(A2,"HEADER CLADDING",Vector3.new(178,4.6,.4),CFrame.new(0,21.55,132.2),P.charcoal,Enum.Material.Metal,0,false)

-- Large BBYA identity floats above the open social frontage.
glow(A2,"CROWN BASE",Vector3.new(13,.32,.25),CFrame.new(0,24.0,132.55),P.pink,.55,11)
for i,spec in ipairs({{-5,25.9,-28},{-1.8,27.4,-10},{1.8,27.4,10},{5,25.9,28}}) do
 glow(A2,"CROWN RAY "..i,Vector3.new(.35,5.1,.25),CFrame.new(spec[1],spec[2],132.55)*CFrame.Angles(0,0,math.rad(spec[3])),P.pink,.45,9)
end
zoneSign(A2,"PREMIUM EXTERIOR BRAND","BBYA\nSOCIAL HUB",CFrame.new(0,20.4,132.7),Vector3.new(34,8,.25),P.pink,Enum.NormalId.Back)
zoneSign(A2,"ENTRANCE SUBLINE","SOCIAL • MUSIC • STYLE • ROOFTOP",CFrame.new(0,14.2,132.7),Vector3.new(38,2.2,.25),P.white,Enum.NormalId.Back)

-- Storefront side glazing makes the interior visible instead of hiding it behind a solid nightclub wall.
finish(A2,"WEST SOCIAL WINDOW",Vector3.new(23,10,.24),CFrame.new(-49.5,8.2,132.48),P.glass,Enum.Material.Glass,.55,false)
finish(A2,"EAST SOCIAL WINDOW",Vector3.new(23,10,.24),CFrame.new(49.5,8.2,132.48),P.glass,Enum.Material.Glass,.55,false)
glow(A2,"WEST WINDOW PINK",Vector3.new(23,.2,.2),CFrame.new(-49.5,13.35,132.65),P.pink,.22,6)
glow(A2,"EAST WINDOW CYAN",Vector3.new(23,.2,.2),CFrame.new(49.5,13.35,132.65),P.cyan,.22,6)

-- Open portal frame. No doors/checkpoint across x=-38..38.
glow(A2,"PORTAL TOP",Vector3.new(74,.28,.3),CFrame.new(0,15.7,132.65),P.pink,.32,9)
glow(A2,"PORTAL WEST",Vector3.new(.28,12,.3),CFrame.new(-37,8.4,132.65),P.pink,.24,7)
glow(A2,"PORTAL EAST",Vector3.new(.28,12,.3),CFrame.new(37,8.4,132.65),P.cyan,.24,7)

-- Warm downlight rhythm softens the entrance and reads more lounge/hospitality than pure nightclub.
for _,x in ipairs({-30,-18,-6,6,18,30}) do
 local lamp=glow(A2,"WELCOME DOWNLIGHT "..x,Vector3.new(2.2,.22,2.2),CFrame.new(x,14.5,129.3),P.warm,.38,10)
 lamp:SetAttribute("BBYACriticalFill",true)
end

zoneSign(A2,"OPEN HOUSE COPY","COME IN • HANG OUT • STAY LATE",CFrame.new(0,11.8,132.72),Vector3.new(31,1.8,.25),P.warm,Enum.NormalId.Back)
