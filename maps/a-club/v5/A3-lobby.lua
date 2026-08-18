-- [A3] SOCIAL COMMONS / LOBBY
local A3=registerZone("A3","SOCIAL COMMONS / LOBBY","G",Vector3.new(0,7,107),Vector3.new(120,14,42))
-- Building shell portions owned by the ground-floor social commons.
part(A3,"GROUND SLAB",Vector3.new(180,1,220),CFrame.new(0,0,20),C.floor,Enum.Material.Concrete,0,true)
part(A3,"GROUND WEST EXTERIOR WALL",Vector3.new(4,18,220),CFrame.new(-90,9,20),C.wall,Enum.Material.Concrete,0,true)
part(A3,"GROUND EAST EXTERIOR WALL",Vector3.new(4,18,220),CFrame.new(90,9,20),C.wall,Enum.Material.Concrete,0,true)
part(A3,"GROUND REAR EXTERIOR WALL",Vector3.new(180,18,4),CFrame.new(0,9,-90),C.wall,Enum.Material.Concrete,0,true)
part(A3,"LOBBY WEST DIVIDER",Vector3.new(4,14,42),CFrame.new(-60,7,107),C.wall2,Enum.Material.Concrete,0,true)
part(A3,"LOBBY EAST DIVIDER",Vector3.new(4,14,42),CFrame.new(60,7,107),C.wall2,Enum.Material.Concrete,0,true)
-- Social Commons -> Club Facility opening widened to 52 studs: x=-26..26.
wallX(A3,"LOBBY CLUB WALL WEST",84,-90,-26,7,14,3)
wallX(A3,"LOBBY CLUB WALL EAST",84,26,90,7,14,3)
landing(A3,"LOBBY LANDING",Vector3.new(0,.62,106),C.gold)
label(A3,"CLUB FACILITY DOOR LABEL","CLUB / DANCE",CFrame.new(0,10,82.3),Vector3.new(25,3,.25),C.pink,Enum.NormalId.Front)
zoneStamp(A3,CFrame.new(0,9,119),Vector3.new(30,4,.25),C.gold,Enum.NormalId.Front)
