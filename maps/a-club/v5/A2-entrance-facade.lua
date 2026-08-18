-- [A2] MAIN ENTRANCE / FACADE
local A2=registerZone("A2","MAIN ENTRANCE / FACADE","G",Vector3.new(0,12,130),Vector3.new(180,24,10))
part(A2,"FRONT WALL WEST",Vector3.new(70,24,4),CFrame.new(-55,12,130),C.wall,Enum.Material.Concrete,0,true)
part(A2,"FRONT WALL EAST",Vector3.new(70,24,4),CFrame.new(55,12,130),C.wall,Enum.Material.Concrete,0,true)
part(A2,"FRONT HEADER",Vector3.new(180,6,4),CFrame.new(0,21,130),C.wall,Enum.Material.Concrete,0,true)
label(A2,"EXTERIOR BBYA IDENTITY","BBYA SOCIAL HUB\nMAIN ENTRANCE",CFrame.new(0,17,132.25),Vector3.new(38,7,.25),C.pink,Enum.NormalId.Back)
landing(A2,"ENTRANCE LANDING",Vector3.new(0,.62,139),C.green)
zoneStamp(A2,CFrame.new(-31,9,132.3),Vector3.new(18,3,.25),C.green,Enum.NormalId.Back)
