-- [C1] PREMIUM VIP WEST
-- Lounge groups face inward toward A4; stair and bridge landings remain clear.

finish(C1,"VIP WEST FLOOR FINISH",Vector3.new(32,.14,146),CFrame.new(-72,18.58,10),Color3.fromRGB(46,41,42),Enum.Material.WoodPlanks,0,false)
glassRail(C1,"VIP WEST GLASS RAIL",Vector3.new(-54.3,21.8,3),Vector3.new(.35,3.6,126))
glow(C1,"VIP WEST RAIL LIGHT",Vector3.new(.2,.18,124),CFrame.new(-54.05,20.25,3),P.gold,.15,6)

-- [09W] VIP lounge groups. Front-most bay is reserved for [12W] private room.
for i,z in ipairs({-44,-8,28}) do
 sofa(C1,"VIP WEST BOOTH "..i,Vector3.new(-80,19.4,z),12,-90,P.graphite)
 lowTable(C1,"VIP WEST TABLE "..i,Vector3.new(-69,19.3,z),Vector3.new(5,.7,4),P.black)
 glow(C1,"VIP WEST TABLE LIGHT "..i,Vector3.new(3,.12,2),CFrame.new(-69,19.72,z),P.warm,.18,5)
end

-- [12W] Private room: enclosed against outer wall while keeping ~17 studs of inner public circulation.
finish(C1,"PRIVATE 12W FRONT WALL",Vector3.new(15,7,.45),CFrame.new(-80.5,22.1,57),P.charcoal,Enum.Material.Slate,0,true)
finish(C1,"PRIVATE 12W REAR WALL",Vector3.new(15,7,.45),CFrame.new(-80.5,22.1,75),P.charcoal,Enum.Material.Slate,0,true)
finish(C1,"PRIVATE 12W INNER WALL A",Vector3.new(.45,7,6),CFrame.new(-72.8,22.1,60),P.charcoal,Enum.Material.Slate,0,true)
finish(C1,"PRIVATE 12W INNER WALL B",Vector3.new(.45,7,6),CFrame.new(-72.8,22.1,72),P.charcoal,Enum.Material.Slate,0,true)
glow(C1,"PRIVATE 12W HEADER",Vector3.new(.25,.25,5.5),CFrame.new(-72.55,25.2,66),P.gold,.18,5)
sofa(C1,"PRIVATE 12W SOFA",Vector3.new(-83,19.5,66),8,-90,P.graphite)
lowTable(C1,"PRIVATE 12W TABLE",Vector3.new(-78,19.35,66),Vector3.new(4,.65,3),P.black)
zoneSign(C1,"PRIVATE 12W SIGN","12W • PRIVATE",CFrame.new(-72.5,23.4,66)*CFrame.Angles(0,math.rad(90),0),Vector3.new(9,2,.2),P.gold,Enum.NormalId.Front)

zoneSign(C1,"VIP WEST BRAND","VIP WEST • DANCE FLOOR VIEW",CFrame.new(-88.15,25,10)*CFrame.Angles(0,math.rad(90),0),Vector3.new(26,3,.2),P.gold,Enum.NormalId.Front)
