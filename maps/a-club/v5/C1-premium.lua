-- [C1] PREMIUM VIP WEST
-- Lounge groups face inward toward A4; stair and bridge landings remain clear.

finish(C1,"VIP WEST FLOOR FINISH",Vector3.new(32,.14,146),CFrame.new(-72,18.58,10),Color3.fromRGB(46,41,42),Enum.Material.WoodPlanks,0,false)
glassRail(C1,"VIP WEST GLASS RAIL",Vector3.new(-54.3,21.8,3),Vector3.new(.35,3.6,126))
glow(C1,"VIP WEST RAIL LIGHT",Vector3.new(.2,.18,124),CFrame.new(-54.05,20.25,3),P.gold,.15,6)

for i,z in ipairs({-44,-8,28,62}) do
 sofa(C1,"VIP WEST BOOTH "..i,Vector3.new(-80,19.4,z),12,-90,P.graphite)
 lowTable(C1,"VIP WEST TABLE "..i,Vector3.new(-69,19.3,z),Vector3.new(5,.7,4),P.black)
 glow(C1,"VIP WEST TABLE LIGHT "..i,Vector3.new(3,.12,2),CFrame.new(-69,19.72,z),P.warm,.18,5)
end
zoneSign(C1,"VIP WEST BRAND","VIP WEST • DANCE FLOOR VIEW",CFrame.new(-88.15,25,10)*CFrame.Angles(0,math.rad(90),0),Vector3.new(26,3,.2),P.gold,Enum.NormalId.Front)
