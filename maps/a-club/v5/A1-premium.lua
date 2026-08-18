-- [A1] PREMIUM EXTERIOR / ARRIVAL PLAZA
-- Central x=-12..12 approach axis stays completely clear.

finish(A1,"PREMIUM PLAZA STONE",Vector3.new(160,.18,54),CFrame.new(0,.58,159),P.stone,Enum.Material.Slate,0,false)
finish(A1,"APPROACH CARPET",Vector3.new(18,.12,50),CFrame.new(0,.72,158),Color3.fromRGB(37,29,39),Enum.Material.SmoothPlastic,0,false)
glow(A1,"APPROACH LEFT EDGE",Vector3.new(.18,.15,48),CFrame.new(-9.5,.82,158),P.pink,.28,8)
glow(A1,"APPROACH RIGHT EDGE",Vector3.new(.18,.15,48),CFrame.new(9.5,.82,158),P.cyan,.28,8)

for i,z in ipairs({140,150,160,170,180}) do
 bollard(A1,"WEST BOLLARD "..i,Vector3.new(-18,2,z),P.warm)
 bollard(A1,"EAST BOLLARD "..i,Vector3.new(18,2,z),P.warm)
end

palm(A1,"WEST ARRIVAL PALM",Vector3.new(-48,1.6,160),13)
palm(A1,"EAST ARRIVAL PALM",Vector3.new(48,1.6,160),13)
palm(A1,"WEST FRONT PALM",Vector3.new(-68,1.6,177),11)
palm(A1,"EAST FRONT PALM",Vector3.new(68,1.6,177),11)

sofa(A1,"WEST WAIT SOFA",Vector3.new(-55,1.4,145),14,0,P.charcoal)
lowTable(A1,"WEST WAIT TABLE",Vector3.new(-55,1.3,139),Vector3.new(6,.7,4),P.black)
sofa(A1,"EAST WAIT SOFA",Vector3.new(55,1.4,145),14,0,P.charcoal)
lowTable(A1,"EAST WAIT TABLE",Vector3.new(55,1.3,139),Vector3.new(6,.7,4),P.black)

zoneSign(A1,"ARRIVAL WAYFINDING","BBYA SOCIAL HUB  •  MAIN ENTRANCE ↑",CFrame.new(0,4.2,187.5)*CFrame.Angles(0,math.rad(180),0),Vector3.new(38,3,.25),P.white,Enum.NormalId.Front)
