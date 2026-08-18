-- [A2] MAIN ENTRANCE / FACADE
-- V5.4 social-storefront frontage: broad visual connection into Social Commons.
local A2=registerZone("A2","MAIN ENTRANCE / FACADE","G",Vector3.new(0,12,130),Vector3.new(180,30,10))

-- 92-stud clear opening: x=-46..46. Side masses act as storefront wings, not a nightclub checkpoint.
part(A2,"FRONT WALL WEST",Vector3.new(44,24,4),CFrame.new(-68,12,130),C.wall,Enum.Material.Concrete,0,true)
part(A2,"FRONT WALL EAST",Vector3.new(44,24,4),CFrame.new(68,12,130),C.wall,Enum.Material.Concrete,0,true)
part(A2,"FRONT HEADER",Vector3.new(180,5,4),CFrame.new(0,21.5,130),C.wall,Enum.Material.Concrete,0,true)

-- Shallow returns define the threshold while keeping almost the entire ground floor visually open.
part(A2,"WEST STOREFRONT RETURN",Vector3.new(2.5,15,6),CFrame.new(-46.75,7.5,127),C.wall2,Enum.Material.Concrete,0,true)
part(A2,"EAST STOREFRONT RETURN",Vector3.new(2.5,15,6),CFrame.new(46.75,7.5,127),C.wall2,Enum.Material.Concrete,0,true)

landing(A2,"ENTRANCE LANDING",Vector3.new(0,.62,139),C.green)
zoneStamp(A2,CFrame.new(-37,8.5,132.3),Vector3.new(18,3,.25),C.green,Enum.NormalId.Back)
