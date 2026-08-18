-- [A3] PREMIUM SOCIAL COMMONS / LIVING ROOM
-- BBYA is a social hub first: hospitality, conversation, outfit visibility and hangout are primary.
-- Club/dance is one optional facility. Center x=-13..13 stays clear through the 52-stud club opening.

finish(A3,"LOBBY FLOOR FINISH",Vector3.new(116,.16,38),CFrame.new(0,.6,107),Color3.fromRGB(57,50,54),Enum.Material.Marble,0,false)
finish(A3,"CENTER SOCIAL WALK",Vector3.new(18,.12,36),CFrame.new(0,.72,107),Color3.fromRGB(71,58,64),Enum.Material.SmoothPlastic,0,false)
glow(A3,"CENTER WALK LEFT",Vector3.new(.16,.12,34),CFrame.new(-9.2,.82,107),P.pink,.14,5)
glow(A3,"CENTER WALK RIGHT",Vector3.new(.16,.12,34),CFrame.new(9.2,.82,107),P.cyan,.14,5)

-- Hospitality island: welcome, meet-up and casual social anchor.
barCounter(A3,"WELCOME BAR HOST",Vector3.new(35,2.15,111),Vector3.new(23,3.4,5),0)
zoneSign(A3,"WELCOME BAR SIGN","WELCOME BAR • HOST",CFrame.new(35,5.5,113.65),Vector3.new(20,2.2,.25),P.warm,Enum.NormalId.Front)
for _,x in ipairs({27,33,39,45}) do stool(A3,"WELCOME STOOL "..x,Vector3.new(x,2.1,107.8),P.graphite) end

-- Social living room visible directly from the entrance.
sofa(A3,"WEST SOCIAL SOFA A",Vector3.new(-42,1.4,109),15,90,P.graphite)
sofa(A3,"WEST SOCIAL SOFA B",Vector3.new(-42,1.4,96),15,90,P.charcoal)
lowTable(A3,"WEST SOCIAL TABLE",Vector3.new(-33,1.3,102.5),Vector3.new(7,.7,5),P.black)
palm(A3,"WEST SOCIAL PALM",Vector3.new(-53,1.6,116),8)
zoneSign(A3,"SOCIAL LOUNGE SIGN","SOCIAL COMMONS",CFrame.new(-45,7.1,123.1),Vector3.new(20,2.4,.25),P.pink,Enum.NormalId.Front)

-- Outfit / photo corner is a primary Social Hub activity, not club decoration.
finish(A3,"LOOK WALL",Vector3.new(24,9,.45),CFrame.new(45,6.2,123.2),P.black,Enum.Material.Slate,0,false)
glow(A3,"LOOK FRAME TOP",Vector3.new(22,.25,.25),CFrame.new(45,10.3,122.9),P.cyan,.25,6)
glow(A3,"LOOK FRAME L",Vector3.new(.25,7.8,.25),CFrame.new(34.3,6.3,122.9),P.pink,.18,5)
glow(A3,"LOOK FRAME R",Vector3.new(.25,7.8,.25),CFrame.new(55.7,6.3,122.9),P.cyan,.18,5)
zoneSign(A3,"LOOK COPY","OUTFIT • SELFIE",CFrame.new(45,7.2,122.65),Vector3.new(19,3,.25),P.white,Enum.NormalId.Front)

-- Warm ceiling pools keep avatars readable in the social core.
for _,x in ipairs({-44,-22,0,22,44}) do
 local lamp=glow(A3,"SOCIAL CEILING LIGHT "..x,Vector3.new(3,.18,3),CFrame.new(x,12.5,107),P.warm,.42,11)
 lamp:SetAttribute("BBYACriticalFill",true)
end
for _,x in ipairs({-33,33}) do
 local fill=glow(A3,"OUTFIT FILL "..x,Vector3.new(2.6,.18,2.6),CFrame.new(x,11.8,117),P.white,.34,9)
 fill:SetAttribute("BBYACriticalFill",true)
end

-- One physical boundary board, readable correctly from both directions.
-- Neither face treats the club as the identity of the whole venue.
zoneSignPair(
 A3,
 "SOCIAL COMMONS FACILITY WAYFINDING",
 "SOCIAL COMMONS ↑     CHILL / TALK ←     SOCIAL BAR →     VIP / ROOF",
 "CLUB / DANCE ↑     SOCIAL BAR ←     CHILL / TALK →     EXIT / COMMONS",
 CFrame.new(0,12.1,83.9),
 Vector3.new(54,3,.25),
 P.white
)
