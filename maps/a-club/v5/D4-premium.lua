-- [D4] PREMIUM ROOFTOP CHILL / SUNSET SOCIAL
-- Lower-energy resort lounge, warm light with restrained BBYA accents.

finish(D4,"EAST CHILL DECK",Vector3.new(38,.14,32),CFrame.new(58,36.74,43),Color3.fromRGB(100,76,58),Enum.Material.WoodPlanks,0,false)
finish(D4,"SUNSET SOCIAL DECK FINISH",Vector3.new(46,.14,26),CFrame.new(0,36.76,42),Color3.fromRGB(82,77,73),Enum.Material.Slate,0,false)

-- East lounge perimeter.
sofa(D4,"EAST ROOF SOFA NORTH",Vector3.new(58,37.45,32),13,180,P.cream)
lowTable(D4,"EAST ROOF TABLE NORTH",Vector3.new(58,37.35,38),Vector3.new(6,.7,4),P.wood)
sofa(D4,"EAST ROOF SOFA SIDE",Vector3.new(72,37.45,47),11,-90,P.cream)
lowTable(D4,"EAST ROOF TABLE SIDE",Vector3.new(66,37.35,47),Vector3.new(5,.7,4),P.wood)
sofa(D4,"EAST ROOF SOFA SOUTH",Vector3.new(58,37.45,57),11,0,P.cream)

-- Central sunset deck stays open in its middle; seating hugs outer edges.
sofa(D4,"SUNSET WEST BENCH",Vector3.new(-17,37.45,42),10,-90,P.graphite)
sofa(D4,"SUNSET EAST BENCH",Vector3.new(17,37.45,42),10,90,P.graphite)
lowTable(D4,"SUNSET TABLE",Vector3.new(0,37.35,42),Vector3.new(7,.7,5),P.wood)

-- Warm floor lamps and very restrained identity accent.
for i,z in ipairs({31,43,55}) do
 bollard(D4,"EAST CHILL LAMP "..i,Vector3.new(78,38.2,z),P.warm)
end
glow(D4,"SUNSET IDENTITY ACCENT",Vector3.new(18,.14,.18),CFrame.new(0,36.95,57),P.pink,.12,5)
zoneSign(D4,"ROOF CHILL SIGN","ROOFTOP CHILL",CFrame.new(58,42.8,59.5),Vector3.new(18,2.5,.2),P.warm,Enum.NormalId.Front)
zoneSign(D4,"SUNSET DECK SIGN","SUNSET / SOCIAL DECK",CFrame.new(0,42.5,56),Vector3.new(21,2.5,.2),P.white,Enum.NormalId.Front)
