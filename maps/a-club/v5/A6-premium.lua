-- [A6] PREMIUM CHILL LOUNGE
-- Lower-energy room separated from A4. Furniture stays off lobby/club door lanes.

finish(A6,"CHILL FLOOR FINISH",Vector3.new(30,.16,46),CFrame.new(72,.72,52),Color3.fromRGB(48,45,51),Enum.Material.WoodPlanks,0,false)
finish(A6,"CHILL FEATURE WALL",Vector3.new(.45,9,26),CFrame.new(87.3,6,50),P.charcoal,Enum.Material.Slate,0,false)
zoneSign(A6,"CHILL FEATURE SIGN","BBYA CHILL",CFrame.new(87.02,7.5,50)*CFrame.Angles(0,math.rad(-90),0),Vector3.new(18,3,.2),P.cyan,Enum.NormalId.Front)

-- Perimeter lounge groups. Central x around 72 and z 52-68 remains readable for movement.
sofa(A6,"NORTH SOFA",Vector3.new(72,1.4,35),14,180,P.graphite)
lowTable(A6,"NORTH TABLE",Vector3.new(72,1.3,41),Vector3.new(6,.7,4),P.black)
sofa(A6,"EAST SOFA",Vector3.new(82,1.4,50),12,-90,P.graphite)
lowTable(A6,"EAST TABLE",Vector3.new(76,1.3,50),Vector3.new(5,.7,4),P.black)
sofa(A6,"SOUTH SIDE SOFA",Vector3.new(82,1.4,68),10,-90,P.graphite)
lowTable(A6,"SOUTH SIDE TABLE",Vector3.new(76,1.3,68),Vector3.new(5,.7,4),P.black)

-- Restrained lounge lighting: cyan/warm accents, not club grid.
glow(A6,"FEATURE CYAN LINE",Vector3.new(.18,6,.18),CFrame.new(86.8,6,41),P.cyan,.28,7)
glow(A6,"FEATURE PINK LINE",Vector3.new(.18,6,.18),CFrame.new(86.8,6,59),P.pink,.22,7)
for _,z in ipairs({38,52,66}) do
 glow(A6,"WARM CEILING "..z,Vector3.new(8,.25,.8),CFrame.new(72,12.5,z),P.warm,.34,10)
end
zoneSign(A6,"CHILL WAYFINDING","MAIN CLUB ←  •  LOBBY ↑",CFrame.new(72,11,29.7),Vector3.new(20,2.4,.2),P.white,Enum.NormalId.Back)
