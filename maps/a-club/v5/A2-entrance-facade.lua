-- [A2] MAIN ENTRANCE / FACADE
-- V5.4 lifestyle-social frontage: wide open portal, not a formal nightclub checkpoint.
local A2=registerZone("A2","MAIN ENTRANCE / FACADE","G",Vector3.new(0,12,130),Vector3.new(180,24,10))

-- 76-stud clear opening: x=-38..38. Side masses frame the venue without blocking sightlines.
part(A2,"FRONT WALL WEST",Vector3.new(52,24,4),CFrame.new(-64,12,130),C.wall,Enum.Material.Concrete,0,true)
part(A2,"FRONT WALL EAST",Vector3.new(52,24,4),CFrame.new(64,12,130),C.wall,Enum.Material.Concrete,0,true)
part(A2,"FRONT HEADER",Vector3.new(180,5,4),CFrame.new(0,21.5,130),C.wall,Enum.Material.Concrete,0,true)

-- Shallow side returns create a storefront portal while keeping the center completely open.
part(A2,"WEST PORTAL RETURN",Vector3.new(3,17,7),CFrame.new(-38.5,8.5,127),C.wall2,Enum.Material.Concrete,0,true)
part(A2,"EAST PORTAL RETURN",Vector3.new(3,17,7),CFrame.new(38.5,8.5,127),C.wall2,Enum.Material.Concrete,0,true)

landing(A2,"ENTRANCE LANDING",Vector3.new(0,.62,139),C.green)
zoneStamp(A2,CFrame.new(-31,9,132.3),Vector3.new(18,3,.25),C.green,Enum.NormalId.Back)
