-- [C3] QUEEN / VIP BRIDGES
local C3=registerZone("C3","QUEEN / VIP BRIDGES","VIP",Vector3.new(0,18,-69),Vector3.new(108,1,175))
part(C3,"VIP FRONT BRIDGE",Vector3.new(108,1,16),CFrame.new(0,18,88),C.floor2,Enum.Material.Concrete,0,true)
part(C3,"VIP REAR BRIDGE",Vector3.new(108,1,18),CFrame.new(0,18,-69),C.floor2,Enum.Material.Concrete,0,true)
program(C3,"QUEEN PRIVATE PROGRAM",Vector2.new(42,16),Vector3.new(0,18.64,-69),C.gold)
landing(C3,"QUEEN LANDING",Vector3.new(0,18.66,-62),C.gold)
label(C3,"QUEEN PRIVATE LABEL","QUEEN / PRIVATE",CFrame.new(0,23,-78),Vector3.new(28,3,.25),C.gold,Enum.NormalId.Front)
zoneStamp(C3,CFrame.new(0,24,87.5),Vector3.new(28,3,.25),C.gold,Enum.NormalId.Front)
