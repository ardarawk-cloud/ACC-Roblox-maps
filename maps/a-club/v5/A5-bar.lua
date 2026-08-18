-- [A5] SOCIAL BAR
local A5=registerZone("A5","SOCIAL BAR","G",Vector3.new(-72,7,52),Vector3.new(32,14,50))
wallX(A5,"BAR REAR WALL",28,-88,-56,7,14,3)
wallX(A5,"BAR FRONT WALL WEST",78,-88,-79,7,14,3)
wallX(A5,"BAR FRONT WALL EAST",78,-65,-56,7,14,3) -- lobby doorway x -79..-65 = 14 clear
program(A5,"SOCIAL BAR PROGRAM",Vector2.new(28,44),Vector3.new(-72,.62,52),C.gold)
landing(A5,"BAR LANDING",Vector3.new(-72,.64,60),C.gold)
label(A5,"BAR LOBBY DOOR","SOCIAL BAR",CFrame.new(-72,8,77.9),Vector3.new(15,3,.25),C.gold,Enum.NormalId.Front)
zoneStamp(A5,CFrame.new(-87.5,8,52)*CFrame.Angles(0,math.rad(90),0),Vector3.new(18,3,.25),C.gold,Enum.NormalId.Front)
