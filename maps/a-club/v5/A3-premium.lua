-- [A3] PREMIUM SOCIAL COMMONS / LIVING ROOM
-- BBYA is a social hub first. The front third must visibly feel occupied from outside the building.
-- Club/dance is one optional facility. Center x=-13..13 stays clear through the 52-stud club opening.

finish(A3,"LOBBY FLOOR FINISH",Vector3.new(116,.16,38),CFrame.new(0,.6,107),Color3.fromRGB(57,50,54),Enum.Material.Marble,0,false)
finish(A3,"CENTER SOCIAL WALK",Vector3.new(22,.12,38),CFrame.new(0,.72,107),Color3.fromRGB(71,58,64),Enum.Material.SmoothPlastic,0,false)
glow(A3,"CENTER WALK LEFT",Vector3.new(.16,.12,36),CFrame.new(-11.2,.82,107),P.pink,.12,5)
glow(A3,"CENTER WALK RIGHT",Vector3.new(.16,.12,36),CFrame.new(11.2,.82,107),P.cyan,.12,5)

-- Front-of-house hospitality island is pulled toward the storefront so it is visible from A1/A2.
barCounter(A3,"WELCOME SOCIAL BAR",Vector3.new(31,2.15,117),Vector3.new(25,3.4,5),0)
zoneSign(A3,"WELCOME BAR SIGN","WELCOME • SOCIAL BAR",CFrame.new(31,5.5,119.65),Vector3.new(22,2.2,.25),P.warm,Enum.NormalId.Front)
for _,x in ipairs({23,29,35,41}) do stool(A3,"WELCOME STOOL "..x,Vector3.new(x,2.1,112.8),P.graphite) end

-- Social lounge sits close to the glazing: people here should be visible from the plaza.
sofa(A3,"FRONT SOCIAL SOFA A",Vector3.new(-34,1.4,117),14,90,P.graphite)
sofa(A3,"FRONT SOCIAL SOFA B",Vector3.new(-48,1.4,117),14,90,P.charcoal)
lowTable(A3,"FRONT SOCIAL TABLE",Vector3.new(-41,1.3,109.5),Vector3.new(7,.7,5),P.black)
palm(A3,"FRONT SOCIAL PALM",Vector3.new(-54,1.6,122),8)
zoneSign(A3,"SOCIAL LOUNGE SIGN","SOCIAL COMMONS",CFrame.new(-40,7.1,123.1),Vector3.new(22,2.4,.25),P.pink,Enum.NormalId.Front)

-- A second conversational pocket makes the social core feel populated without blocking circulation.
sofa(A3,"MID SOCIAL SOFA",Vector3.new(-39,1.4,96),15,90,P.charcoal)
lowTable(A3,"MID SOCIAL TABLE",Vector3.new(-31,1.3,96),Vector3.new(6,.7,4),P.black)

-- Outfit / selfie corner remains a primary Social Hub activity and is visible through the east storefront glazing.
finish(A3,"LOOK WALL",Vector3.new(24,9,.45),CFrame.new(48,6.2,123.2),P.black,Enum.Material.Slate,0,false)
glow(A3,"LOOK FRAME TOP",Vector3.new(22,.25,.25),CFrame.new(48,10.3,122.9),P.cyan,.22,6)
glow(A3,"LOOK FRAME L",Vector3.new(.25,7.8,.25),CFrame.new(37.3,6.3,122.9),P.pink,.16,5)
glow(A3,"LOOK FRAME R",Vector3.new(.25,7.8,.25),CFrame.new(58.7,6.3,122.9),P.cyan,.16,5)
zoneSign(A3,"LOOK COPY","OUTFIT • SELFIE",CFrame.new(48,7.2,122.65),Vector3.new(19,3,.25),P.white,Enum.NormalId.Front)

-- Warm social lighting is intentionally brighter than the old entrance so avatars/outfits read from outside.
for _,spec in ipairs({{-48,117},{-24,117},{0,117},{24,117},{48,117},{-36,100},{0,100},{36,100}}) do
 local lamp=glow(A3,"SOCIAL CEILING LIGHT "..spec[1].." "..spec[2],Vector3.new(3,.18,3),CFrame.new(spec[1],12.5,spec[2]),P.warm,.38,10)
 lamp:SetAttribute("BBYACriticalFill",true)
end
for _,x in ipairs({-32,32}) do
 local fill=glow(A3,"OUTFIT FILL "..x,Vector3.new(2.6,.18,2.6),CFrame.new(x,11.8,119),P.white,.30,8)
 fill:SetAttribute("BBYACriticalFill",true)
end

-- Club is one branch of the Social Hub, not the identity of the building.
zoneSignPair(
 A3,
 "SOCIAL COMMONS FACILITY WAYFINDING",
 "SOCIAL COMMONS ↑     CHILL / TALK ←     SOCIAL BAR →     VIP / ROOF",
 "CLUB / DANCE ↑     SOCIAL BAR ←     CHILL / TALK →     EXIT / COMMONS",
 CFrame.new(0,12.1,83.9),
 Vector3.new(54,3,.25),
 P.white
)
