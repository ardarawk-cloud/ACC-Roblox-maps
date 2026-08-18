-- [D5] CABANA PROGRAM ZONES
local D5=registerZone("D5","CABANA PROGRAM ZONES","ROOF",Vector3.new(0,36.72,-40),Vector3.new(154,.14,24))
program(D5,"WEST CABANA PROGRAM ZONE",Vector2.new(30,24),Vector3.new(-62,36.72,-40),C.warm)
program(D5,"EAST CABANA PROGRAM ZONE",Vector2.new(30,24),Vector3.new(62,36.72,-40),C.warm)
zoneStamp(D5,CFrame.new(-62,42,-52),Vector3.new(20,3,.25),C.warm,Enum.NormalId.Front)
zoneStamp(D5,CFrame.new(62,42,-52),Vector3.new(20,3,.25),C.warm,Enum.NormalId.Front)
