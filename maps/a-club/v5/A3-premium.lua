-- [A3] PREMIUM LOBBY / ORIENTATION
-- Main axis x=-12..12 stays furniture-free from entrance to Main Club.

finish(A3,"LOBBY FLOOR FINISH",Vector3.new(116,.16,38),CFrame.new(0,.6,107),Color3.fromRGB(50,47,53),Enum.Material.Marble,0,false)
finish(A3,"CENTER WAYFINDING STRIP",Vector3.new(16,.12,36),CFrame.new(0,.72,107),P.charcoal,Enum.Material.SmoothPlastic,0,false)
glow(A3,"CENTER STRIP LEFT",Vector3.new(.18,.14,34),CFrame.new(-8.2,.82,107),P.pink,.2,6)
glow(A3,"CENTER STRIP RIGHT",Vector3.new(.18,.14,34),CFrame.new(8.2,.82,107),P.cyan,.2,6)

-- Reception islands sit outside the centerline.
barCounter(A3,"WEST RECEPTION",Vector3.new(-35,2.15,111),Vector3.new(18,3.4,4),0)
zoneSign(A3,"WEST RECEPTION SIGN","RECEPTION",CFrame.new(-35,5.5,113.15),Vector3.new(15,2.2,.25),P.gold,Enum.NormalId.Front)
barCounter(A3,"EAST HOST DESK",Vector3.new(35,2.15,111),Vector3.new(18,3.4,4),0)
zoneSign(A3,"EAST HOST SIGN","HOST / INFO",CFrame.new(35,5.5,113.15),Vector3.new(15,2.2,.25),P.cyan,Enum.NormalId.Front)

-- Photo/look alcoves at the sides; no object protrudes into the 40-stud club doorway.
finish(A3,"WEST PHOTO BACKDROP",Vector3.new(24,9,.45),CFrame.new(-45,6.2,123.2),P.black,Enum.Material.Slate,0,false)
glow(A3,"WEST PHOTO FRAME TOP",Vector3.new(22,.25,.25),CFrame.new(-45,10.3,122.9),P.pink,.32,7)
glow(A3,"WEST PHOTO FRAME L",Vector3.new(.25,7.8,.25),CFrame.new(-55.7,6.3,122.9),P.pink,.22,6)
glow(A3,"WEST PHOTO FRAME R",Vector3.new(.25,7.8,.25),CFrame.new(-34.3,6.3,122.9),P.cyan,.22,6)
zoneSign(A3,"WEST PHOTO COPY","BBYA PHOTO / SELFIE",CFrame.new(-45,7.2,122.65),Vector3.new(19,3,.25),P.pink,Enum.NormalId.Front)

finish(A3,"EAST LOOK BACKDROP",Vector3.new(24,9,.45),CFrame.new(45,6.2,123.2),P.black,Enum.Material.Slate,0,false)
glow(A3,"EAST LOOK FRAME TOP",Vector3.new(22,.25,.25),CFrame.new(45,10.3,122.9),P.cyan,.32,7)
zoneSign(A3,"EAST LOOK COPY","LOOK STUDIO",CFrame.new(45,7.2,122.65),Vector3.new(18,3,.25),P.cyan,Enum.NormalId.Front)

-- Lobby waiting pockets.
sofa(A3,"WEST LOBBY SOFA",Vector3.new(-43,1.4,94),13,180,P.graphite)
lowTable(A3,"WEST LOBBY TABLE",Vector3.new(-43,1.3,100),Vector3.new(6,.7,4),P.black)
sofa(A3,"EAST LOBBY SOFA",Vector3.new(43,1.4,94),13,180,P.graphite)
lowTable(A3,"EAST LOBBY TABLE",Vector3.new(43,1.3,100),Vector3.new(6,.7,4),P.black)

zoneSign(A3,"LOBBY MAIN WAYFINDING","MAIN CLUB ↑     BAR ←     CHILL →",CFrame.new(0,12.1,83.9),Vector3.new(44,3,.25),P.white,Enum.NormalId.Front)
