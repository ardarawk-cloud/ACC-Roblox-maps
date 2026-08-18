-- [C2] PREMIUM VIP EAST
-- Mirrors C1 while keeping B3 lift arrival and bridges clear.

finish(C2,"VIP EAST FLOOR FINISH",Vector3.new(32,.14,146),CFrame.new(72,18.58,10),Color3.fromRGB(46,41,42),Enum.Material.WoodPlanks,0,false)
glassRail(C2,"VIP EAST GLASS RAIL",Vector3.new(54.3,21.8,3),Vector3.new(.35,3.6,126))
glow(C2,"VIP EAST RAIL LIGHT",Vector3.new(.2,.18,124),CFrame.new(54.05,20.25,3),P.gold,.15,6)

-- [09E] VIP lounge groups. Front-most bay is reserved for [12E] private room.
for i,z in ipairs({-44,-8,28}) do
 sofa(C2,"VIP EAST BOOTH "..i,Vector3.new(80,19.4,z),12,90,P.graphite)
 lowTable(C2,"VIP EAST TABLE "..i,Vector3.new(69,19.3,z),Vector3.new(5,.7,4),P.black)
 glow(C2,"VIP EAST TABLE LIGHT "..i,Vector3.new(3,.12,2),CFrame.new(69,19.72,z),P.warm,.18,5)
end

-- [12E] Private room: mirror of 12W, outer-side enclosure with inner corridor kept open.
finish(C2,"PRIVATE 12E FRONT WALL",Vector3.new(15,7,.45),CFrame.new(80.5,22.1,57),P.charcoal,Enum.Material.Slate,0,true)
finish(C2,"PRIVATE 12E REAR WALL",Vector3.new(15,7,.45),CFrame.new(80.5,22.1,75),P.charcoal,Enum.Material.Slate,0,true)
finish(C2,"PRIVATE 12E INNER WALL A",Vector3.new(.45,7,6),CFrame.new(72.8,22.1,60),P.charcoal,Enum.Material.Slate,0,true)
finish(C2,"PRIVATE 12E INNER WALL B",Vector3.new(.45,7,6),CFrame.new(72.8,22.1,72),P.charcoal,Enum.Material.Slate,0,true)
glow(C2,"PRIVATE 12E HEADER",Vector3.new(.25,.25,5.5),CFrame.new(72.55,25.2,66),P.gold,.18,5)
sofa(C2,"PRIVATE 12E SOFA",Vector3.new(83,19.5,66),8,90,P.graphite)
lowTable(C2,"PRIVATE 12E TABLE",Vector3.new(78,19.35,66),Vector3.new(4,.65,3),P.black)
zoneSign(C2,"PRIVATE 12E SIGN","12E • PRIVATE",CFrame.new(72.5,23.4,66)*CFrame.Angles(0,math.rad(-90),0),Vector3.new(9,2,.2),P.gold,Enum.NormalId.Front)

zoneSign(C2,"VIP EAST BRAND","VIP EAST • DANCE FLOOR VIEW",CFrame.new(88.15,25,10)*CFrame.Angles(0,math.rad(-90),0),Vector3.new(26,3,.2),P.gold,Enum.NormalId.Front)
