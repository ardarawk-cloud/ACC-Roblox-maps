-- [A3] LOBBY / ORIENTATION
local A3=registerZone("A3","LOBBY / ORIENTATION","G",Vector3.new(0,7,107),Vector3.new(120,14,42))
-- Building shell portions owned by lobby zone.
part(A3,"GROUND SLAB",Vector3.new(180,1,220),CFrame.new(0,0,20),C.floor,Enum.Material.Concrete,0,true)
part(A3,"GROUND WEST EXTERIOR WALL",Vector3.new(4,18,220),CFrame.new(-90,9,20),C.wall,Enum.Material.Concrete,0,true)
part(A3,"GROUND EAST EXTERIOR WALL",Vector3.new(4,18,220),CFrame.new(90,9,20),C.wall,Enum.Material.Concrete,0,true)
part(A3,"GROUND REAR EXTERIOR WALL",Vector3.new(180,18,4),CFrame.new(0,9,-90),C.wall,Enum.Material.Concrete,0,true)
part(A3,"LOBBY WEST DIVIDER",Vector3.new(4,14,42),CFrame.new(-60,7,107),C.wall2,Enum.Material.Concrete,0,true)
part(A3,"LOBBY EAST DIVIDER",Vector3.new(4,14,42),CFrame.new(60,7,107),C.wall2,Enum.Material.Concrete,0,true)
-- Lobby -> Main Club opening is exactly 40 studs clear, x=-20..20.
wallX(A3,"LOBBY CLUB WALL WEST",84,-90,-20,7,14,3)
wallX(A3,"LOBBY CLUB WALL EAST",84,20,90,7,14,3)
landing(A3,"LOBBY LANDING",Vector3.new(0,.62,106),C.gold)
label(A3,"MAIN CLUB DOOR LABEL","MAIN CLUB",CFrame.new(0,10,82.3),Vector3.new(25,3,.25),C.pink,Enum.NormalId.Front)
zoneStamp(A3,CFrame.new(0,9,119),Vector3.new(30,4,.25),C.gold,Enum.NormalId.Front)
