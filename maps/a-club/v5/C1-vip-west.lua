-- [C1] VIP WEST MEZZANINE
local C1=registerZone("C1","VIP WEST MEZZANINE","VIP",Vector3.new(-72,18,5),Vector3.new(34,1,150))
part(C1,"VIP WEST MEZZANINE",Vector3.new(34,1,150),CFrame.new(-72,18,10),C.floor2,Enum.Material.Concrete,0,true)
part(C1,"VIP WEST INNER PARAPET",Vector3.new(2,3,132),CFrame.new(-55,19.5,3),C.wall2,Enum.Material.Concrete,0,true)
program(C1,"VIP WEST PROGRAM",Vector2.new(28,118),Vector3.new(-72,18.62,5),C.gold)
landing(C1,"VIP WEST LANDING",Vector3.new(-70,18.64,-17),C.gold)
zoneStamp(C1,CFrame.new(-54.2,23,18)*CFrame.Angles(0,math.rad(90),0),Vector3.new(20,3,.25),C.gold,Enum.NormalId.Front)
