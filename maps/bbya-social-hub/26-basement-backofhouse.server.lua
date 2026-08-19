local W=game:GetService("Workspace")
local root=W:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder",W);root.Name="BBYA_ZERO_BUILD"
local old=root:FindFirstChild("BasementBOH");if old then old:Destroy() end
local m=Instance.new("Model",root);m.Name="BasementBOH"
local C={dark=Color3.fromRGB(18,18,22),wall=Color3.fromRGB(38,38,44),floor=Color3.fromRGB(50,50,56),yellow=Color3.fromRGB(255,190,45),blue=Color3.fromRGB(0,174,255)}
local function p(n,s,cf,c,mat,t)local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Color=c;x.Material=mat or Enum.Material.Concrete;x.Transparency=t or 0;x.Parent=m;return x end
-- full-footprint basement, matching main building envelope
p("BasementFloor",Vector3.new(120,1,90),CFrame.new(0,-15.5,0),C.floor)
p("BasementCeiling",Vector3.new(120,1,90),CFrame.new(0,-.5,0),C.dark)
p("NorthRetaining",Vector3.new(120,16,2),CFrame.new(0,-8,44),C.wall)
p("SouthRetaining",Vector3.new(120,16,2),CFrame.new(0,-8,-44),C.wall)
p("WestRetaining",Vector3.new(2,16,90),CFrame.new(-59,-8,0),C.wall)
p("EastRetaining",Vector3.new(2,16,90),CFrame.new(59,-8,0),C.wall)
-- BOH zoning: staff, storage, technical, utilities; central service lane retained
p("StaffRoom",Vector3.new(34,10,24),CFrame.new(-39,-9,-26),C.wall)
p("Storage",Vector3.new(34,10,24),CFrame.new(-39,-9,25),C.wall)
p("Technical",Vector3.new(34,10,24),CFrame.new(39,-9,25),C.wall)
p("Utilities",Vector3.new(34,10,18),CFrame.new(39,-9,-2),C.wall)
-- rear-right service ramp reservation / entry opening
p("ServiceRamp",Vector3.new(16,1,34),CFrame.new(49,-10,36)*CFrame.Angles(math.rad(-14),0,0),C.floor,Enum.Material.Concrete)
-- service path marker
local lane=p("ServiceLane",Vector3.new(10,.12,70),CFrame.new(18,-14.9,0),C.yellow,Enum.Material.Neon);lane.CanCollide=false
print("[BBYA] Full basement back-of-house built")