-- [A6] CHILL / CONVERSATION LOUNGE
local A6=registerZone("A6","CHILL / CONVERSATION LOUNGE","G",Vector3.new(72,7,52),Vector3.new(32,14,50))
wallX(A6,"CHILL REAR WALL",28,56,88,7,14,3)
wallX(A6,"CHILL FRONT WALL WEST",78,56,65,7,14,3)
wallX(A6,"CHILL FRONT WALL EAST",78,79,88,7,14,3) -- lobby doorway x 65..79 = 14 clear
program(A6,"SOCIAL CHILL PROGRAM",Vector2.new(28,44),Vector3.new(72,.62,52),C.cyan)
landing(A6,"CHILL LANDING",Vector3.new(72,.64,60),C.cyan)
label(A6,"CHILL LOBBY DOOR","CHILL / TALK",CFrame.new(72,8,77.9),Vector3.new(17,3,.25),C.cyan,Enum.NormalId.Front)
zoneStamp(A6,CFrame.new(87.5,8,52)*CFrame.Angles(0,math.rad(-90),0),Vector3.new(20,3,.25),C.cyan,Enum.NormalId.Front)
