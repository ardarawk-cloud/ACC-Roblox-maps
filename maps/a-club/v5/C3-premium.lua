-- [C3] PREMIUM QUEEN / PRIVATE BRIDGES
-- Private program remains inside the 42x16 rear bridge reservation.

finish(C3,"FRONT BRIDGE FINISH",Vector3.new(106,.14,14),CFrame.new(0,18.58,88),P.charcoal,Enum.Material.Marble,0,false)
finish(C3,"REAR BRIDGE FINISH",Vector3.new(106,.14,16),CFrame.new(0,18.58,-69),Color3.fromRGB(50,42,45),Enum.Material.Marble,0,false)
glassRail(C3,"FRONT BRIDGE RAIL",Vector3.new(0,21.2,80.5),Vector3.new(106,3,.3))
glassRail(C3,"REAR BRIDGE RAIL",Vector3.new(0,21.2,-60.5),Vector3.new(106,3,.3))

-- Queen skybox envelope centered on the reserved private rectangle.
finish(C3,"QUEEN BACKDROP",Vector3.new(42,9,.5),CFrame.new(0,23.3,-77.4),P.black,Enum.Material.Slate,0,false)
glow(C3,"QUEEN BACKDROP TOP",Vector3.new(40,.3,.25),CFrame.new(0,27.6,-77.1),P.pink,.48,10)
zoneSign(C3,"QUEEN BRAND","BBYA QUEEN",CFrame.new(0,24.3,-77.05),Vector3.new(28,4,.2),P.pink,Enum.NormalId.Back)

-- Crown mark.
glow(C3,"QUEEN CROWN BASE",Vector3.new(8,.25,.2),CFrame.new(0,27,-76.95),P.gold,.35,8)
for i,spec in ipairs({{-3,28.2,-25},{0,29.1,0},{3,28.2,25}}) do
 glow(C3,"QUEEN CROWN RAY "..i,Vector3.new(.25,3.3,.2),CFrame.new(spec[1],spec[2],-76.95)*CFrame.Angles(0,0,math.rad(spec[3])),P.gold,.28,7)
end

sofa(C3,"QUEEN SOFA",Vector3.new(0,19.4,-72),16,180,Color3.fromRGB(62,36,55))
lowTable(C3,"QUEEN TABLE",Vector3.new(0,19.3,-66),Vector3.new(7,.8,4),P.black)
sofa(C3,"QUEEN GUEST WEST",Vector3.new(-14,19.4,-69),9,90,P.graphite)
sofa(C3,"QUEEN GUEST EAST",Vector3.new(14,19.4,-69),9,-90,P.graphite)
glow(C3,"QUEEN FLOOR ACCENT",Vector3.new(34,.15,.2),CFrame.new(0,18.86,-61.5),P.gold,.18,6)
