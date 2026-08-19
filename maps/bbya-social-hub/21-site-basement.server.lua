local W=game:GetService("Workspace")
local root=W:FindFirstChild("BBYA_ZERO_BUILD")
if not root then root=Instance.new("Folder");root.Name="BBYA_ZERO_BUILD";root.Parent=W end
local old=root:FindFirstChild("SiteBasement")
if old then old:Destroy() end
local m=Instance.new("Model");m.Name="SiteBasement";m.Parent=root
local function p(n,s,pos,col,mat)
 local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.CanCollide=true;x.Size=s;x.CFrame=CFrame.new(pos);x.Color=col;x.Material=mat or Enum.Material.Concrete;x.Parent=m;return x
end
p("Site",Vector3.new(160,1,120),Vector3.new(0,-0.5,0),Color3.fromRGB(18,18,22),Enum.Material.Slate)
p("BasementFloor",Vector3.new(120,1,90),Vector3.new(0,-15.5,0),Color3.fromRGB(24,24,28))
p("BasementNorth",Vector3.new(120,16,2),Vector3.new(0,-8,44),Color3.fromRGB(20,20,24))
p("BasementSouth",Vector3.new(120,16,2),Vector3.new(0,-8,-44),Color3.fromRGB(20,20,24))
p("BasementWest",Vector3.new(2,16,88),Vector3.new(-59,-8,0),Color3.fromRGB(20,20,24))
p("BasementEast",Vector3.new(2,16,88),Vector3.new(59,-8,0),Color3.fromRGB(20,20,24))
print("[BBYA] site + basement preview built")
