-- [A2] PREMIUM MAIN FACADE
-- Exterior identity belongs outside; 40-stud entrance remains unobstructed.

finish(A2,"WEST FACADE CLADDING",Vector3.new(68,22,.35),CFrame.new(-55,12,132.15),P.black,Enum.Material.Slate,0,false)
finish(A2,"EAST FACADE CLADDING",Vector3.new(68,22,.35),CFrame.new(55,12,132.15),P.black,Enum.Material.Slate,0,false)
finish(A2,"HEADER CLADDING",Vector3.new(178,5.2,.4),CFrame.new(0,21,132.2),P.charcoal,Enum.Material.Metal,0,false)

-- Crown silhouette over the BBYA exterior logo.
glow(A2,"CROWN BASE",Vector3.new(13,.32,.25),CFrame.new(0,23.2,132.55),P.pink,.7,12)
for i,spec in ipairs({{-5,25.1,-28},{-1.8,26.8,-10},{1.8,26.8,10},{5,25.1,28}}) do
 glow(A2,"CROWN RAY "..i,Vector3.new(.35,5.5,.25),CFrame.new(spec[1],spec[2],132.55)*CFrame.Angles(0,0,math.rad(spec[3])),P.pink,.55,10)
end

-- Vertical facade rhythm; entrance itself stays clear x=-20..20.
for _,x in ipairs({-82,-72,-62,-52,-42,-32,32,42,52,62,72,82}) do
 local col=(x%20==0) and P.cyan or P.pink
 glow(A2,"FACADE PIN "..x,Vector3.new(.28,9,.28),CFrame.new(x,11,132.55),col,.24,7)
end

glow(A2,"ENTRANCE HEADER PINK",Vector3.new(40,.32,.32),CFrame.new(0,16.1,132.55),P.pink,.6,12)
glow(A2,"ENTRANCE HEADER CYAN",Vector3.new(34,.18,.18),CFrame.new(0,15.35,132.6),P.cyan,.35,9)
zoneSign(A2,"PREMIUM EXTERIOR BRAND","BBYA\nSOCIAL HUB",CFrame.new(0,20.1,132.7),Vector3.new(31,8,.25),P.pink,Enum.NormalId.Back)
zoneSign(A2,"ENTRANCE SUBLINE","LUXURY NIGHTLIFE • SOCIAL • ROOFTOP",CFrame.new(0,14.1,132.7),Vector3.new(36,2.2,.25),P.white,Enum.NormalId.Back)
