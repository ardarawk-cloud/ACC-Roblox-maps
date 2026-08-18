-- [A1] PREMIUM EXTERIOR / SOCIAL ARRIVAL COURTYARD
-- Broad approach to a visible Social Commons. The entrance should feel like a lifestyle venue, not a club queue.

finish(A1,"PREMIUM PLAZA STONE",Vector3.new(160,.18,54),CFrame.new(0,.58,159),P.stone,Enum.Material.Slate,0,false)
finish(A1,"SOCIAL APPROACH WALK",Vector3.new(42,.12,50),CFrame.new(0,.72,158),Color3.fromRGB(49,42,49),Enum.Material.SmoothPlastic,0,false)
glow(A1,"APPROACH LEFT EDGE",Vector3.new(.16,.12,48),CFrame.new(-21.2,.82,158),P.pink,.14,5)
glow(A1,"APPROACH RIGHT EDGE",Vector3.new(.16,.12,48),CFrame.new(21.2,.82,158),P.cyan,.14,5)

-- Soft landscape framing. Keep the center and storefront sightline completely clear.
palm(A1,"WEST ARRIVAL PALM",Vector3.new(-58,1.6,160),11)
palm(A1,"EAST ARRIVAL PALM",Vector3.new(58,1.6,160),11)
palm(A1,"WEST FRONT PALM",Vector3.new(-72,1.6,178),9)
palm(A1,"EAST FRONT PALM",Vector3.new(72,1.6,178),9)

-- Casual pre-entry hangout pockets, placed off-axis so people can meet without blocking circulation.
sofa(A1,"WEST COURTYARD SOFA",Vector3.new(-50,1.4,148),14,0,P.charcoal)
lowTable(A1,"WEST COURTYARD TABLE",Vector3.new(-50,1.3,142),Vector3.new(6,.7,4),P.black)
sofa(A1,"EAST COURTYARD SOFA",Vector3.new(50,1.4,148),14,0,P.charcoal)
lowTable(A1,"EAST COURTYARD TABLE",Vector3.new(50,1.3,142),Vector3.new(6,.7,4),P.black)

-- Warm low-level lighting: hospitality first, neon only as identity accents.
for _,spec in ipairs({{-28,146},{28,146},{-28,173},{28,173}}) do
 bollard(A1,"SOCIAL GUIDE "..spec[1].." "..spec[2],Vector3.new(spec[1],2,spec[2]),P.warm)
end
for _,spec in ipairs({{-18,152},{18,152},{-18,167},{18,167}}) do
 local lamp=glow(A1,"COURTYARD LANTERN "..spec[1].." "..spec[2],Vector3.new(.5,1.2,.5),CFrame.new(spec[1],1.45,spec[2]),P.warm,.30,8)
 lamp:SetAttribute("BBYACriticalFill",true)
end

-- Minimal arrival copy. The actual brand hero belongs to the building facade ahead.
zoneSign(A1,"ARRIVAL WAYFINDING","BBYA SOCIAL HUB  •  SOCIAL COMMONS ↑",CFrame.new(0,4.2,187.5)*CFrame.Angles(0,math.rad(180),0),Vector3.new(42,3,.25),P.white,Enum.NormalId.Front)
