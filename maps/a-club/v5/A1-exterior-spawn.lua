-- [A1] EXTERIOR / SPAWN
local A1 = registerZone("A1","EXTERIOR / SPAWN","G",Vector3.new(0,0,159),Vector3.new(180,24,58))
part(A1,"EXTERIOR PLAZA",Vector3.new(160,1,54),CFrame.new(0,0,159),C.floor2,Enum.Material.Concrete,0,true)
part(A1,"APPROACH AXIS",Vector3.new(24,.14,54),CFrame.new(0,.58,159),Color3.fromRGB(150,150,155),Enum.Material.Concrete,0,false)
local spawn=Instance.new("SpawnLocation")
spawn.Name="A1 | BBYA V5 SPAWN";spawn.Size=Vector3.new(10,1,10);spawn.CFrame=CFrame.new(0,1,176)*CFrame.Angles(0,math.rad(180),0)
spawn.Anchored=true;spawn.Neutral=true;spawn.Duration=0;spawn.Material=Enum.Material.SmoothPlastic;spawn.Color=C.green;spawn.Transparency=.2
spawn:SetAttribute("BBYAZoneCode","A1");spawn:SetAttribute("BBYAZoneName","EXTERIOR / SPAWN");spawn.Parent=A1
zoneStamp(A1,CFrame.new(0,5,184)*CFrame.Angles(0,math.rad(180),0),Vector3.new(34,4,.25),C.green,Enum.NormalId.Front)
