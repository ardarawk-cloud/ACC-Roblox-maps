local W=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local root=W:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder",W);root.Name="BBYA_ZERO_BUILD"
local old=root:FindFirstChild("ClubAmbience");if old then old:Destroy() end
local m=Instance.new("Model",root);m.Name="ClubAmbience"
local C={pink=Color3.fromRGB(255,42,157),blue=Color3.fromRGB(0,174,255),violet=Color3.fromRGB(152,80,255),warm=Color3.fromRGB(255,188,122)}
local function rigPart(n,pos,col)
 local p=Instance.new("Part");p.Name=n;p.Anchored=true;p.CanCollide=false;p.Transparency=1;p.Size=Vector3.new(.5,.5,.5);p.CFrame=CFrame.new(pos);p.Parent=m
 local s=Instance.new("SpotLight");s.Name="Beam";s.Color=col;s.Brightness=4;s.Range=58;s.Angle=38;s.Face=Enum.NormalId.Bottom;s.Shadows=false;s.Parent=p
 return p,s
end
local rigs={}
for i,x in ipairs({-24,-12,0,12,24}) do local p,s=rigPart("StageBeam"..i,Vector3.new(x,19,27),i%2==0 and C.blue or C.pink);table.insert(rigs,{p=p,s=s,phase=i*.8}) end
for i,x in ipairs({-22,-7,7,22}) do local p,s=rigPart("DanceBeam"..i,Vector3.new(x,18,-4),i%2==0 and C.violet or C.blue);s.Angle=46;s.Range=48;table.insert(rigs,{p=p,s=s,phase=i*1.1}) end
-- ambient accents around bar/VIP/roof
local function point(n,pos,col,b,r)
 local p=Instance.new("Part");p.Name=n;p.Anchored=true;p.CanCollide=false;p.Transparency=1;p.Size=Vector3.new(.2,.2,.2);p.CFrame=CFrame.new(pos);p.Parent=m
 local l=Instance.new("PointLight");l.Color=col;l.Brightness=b;l.Range=r;l.Shadows=false;l.Parent=p
end
for _,v in ipairs({{-46,8,-10,C.warm},{46,8,2,C.warm},{-45,30,20,C.pink},{45,30,20,C.blue},{0,49,12,C.blue},{0,49,-12,C.pink}}) do point("Ambient",Vector3.new(v[1],v[2],v[3]),v[4],1.7,24) end
Lighting.ClockTime=21.2;Lighting.Brightness=2.4;Lighting.Ambient=Color3.fromRGB(48,37,55);Lighting.OutdoorAmbient=Color3.fromRGB(30,24,40)
local at=Lighting:FindFirstChild("BBYAAtmosphere") or Instance.new("Atmosphere");at.Name="BBYAAtmosphere";at.Density=.28;at.Offset=.05;at.Color=Color3.fromRGB(178,156,210);at.Decay=Color3.fromRGB(68,45,86);at.Glare=.12;at.Haze=1.25;at.Parent=Lighting
-- slow moving light show, intentionally lightweight
 task.spawn(function()
  local t=0
  while m.Parent do
   t+=.08
   for _,r in ipairs(rigs) do
    local yaw=math.sin(t+r.phase)*22
    local roll=math.cos(t*.7+r.phase)*9
    r.p.CFrame=CFrame.new(r.p.Position)*CFrame.Angles(math.rad(roll),math.rad(yaw),0)
    r.s.Brightness=3.2+math.abs(math.sin(t*1.7+r.phase))*2.4
   end
   task.wait(.08)
  end
 end)
print("[BBYA] dynamic lighting + ambience online")