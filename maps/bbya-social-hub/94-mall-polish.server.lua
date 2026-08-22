-- BBYA SOCIAL HUB — MALL POLISH v1
-- Replaces solid cylinder sculpture primitives with an open neon frame sculpture.
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local mall=root:WaitForChild("BBYAMall",30)
if not mall then return end
local atr=mall:WaitForChild("AtriumExperience",30)
if not atr then return end
for i=1,3 do local old=atr:FindFirstChild("SculptureRing"..i);if old then old:Destroy() end end
local colors={Color3.fromRGB(211,166,86),Color3.fromRGB(235,56,147),Color3.fromRGB(38,192,214)}
local function bar(name,size,cf,color)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=Enum.Material.Neon;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CastShadow=false;p.Parent=atr;return p
end
for i=1,3 do
 local half=5+i*2
 local y=7+i*5
 local rot=CFrame.Angles(0,math.rad(18*i),math.rad(45))
 local center=CFrame.new(0,y,365)*rot
 bar("OpenFrameTop"..i,Vector3.new(half*2,.35,.35),center*CFrame.new(0,half,0),colors[i])
 bar("OpenFrameBottom"..i,Vector3.new(half*2,.35,.35),center*CFrame.new(0,-half,0),colors[i])
 bar("OpenFrameLeft"..i,Vector3.new(.35,half*2,.35),center*CFrame.new(-half,0,0),colors[i])
 bar("OpenFrameRight"..i,Vector3.new(.35,half*2,.35),center*CFrame.new(half,0,0),colors[i])
end
print("[BBYA] Mall polish v1 online: atrium sculpture remains visually open")
