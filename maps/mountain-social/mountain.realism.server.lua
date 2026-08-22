-- ACC Mountain Social Adventure — Realism Pass v4.7
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local Terrain=Workspace.Terrain
local root=Workspace:WaitForChild("ACC_MountainSocial",20);if not root then return end

task.wait(11.5) -- run after visual / precision / grounding
local old=root:FindFirstChild("RealismV47");if old then old:Destroy() end
local f=Instance.new("Folder");f.Name="RealismV47";f.Parent=root

local rayParams=RaycastParams.new();rayParams.FilterType=Enum.RaycastFilterType.Include;rayParams.FilterDescendantsInstances={Terrain};rayParams.IgnoreWater=false
local function terrainY(x,z)
 local hit=Workspace:Raycast(Vector3.new(x,1500,z),Vector3.new(0,-3000,0),rayParams)
 return hit and hit.Position.Y or nil
end
local function mk(n,s,cf,m,c,p,tr,coll)
 local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Material=m or Enum.Material.Ground
 if c then x.Color=c end;x.Transparency=tr or 0;x.CanCollide=coll~=false;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=p or f;return x
end
local function ball(n,pos,size,mat,col,p,coll)
 local x=mk(n,Vector3.new(size,size*.72,size*.88),CFrame.new(pos)*CFrame.Angles(math.rad(math.random(-12,12)),math.rad(math.random(0,180)),math.rad(math.random(-10,10))),mat,col,p,0,coll~=false);x.Shape=Enum.PartType.Ball;return x
end
local function beam(n,a,b,w,mat,col,p,coll)
 local d=b-a;if d.Magnitude<.05 then return nil end
 return mk(n,Vector3.new(w,w,d.Magnitude),CFrame.lookAt((a+b)/2,b),mat,col,p,0,coll~=false)
end
local function groundXZ(x,z,pad)
 local y=terrainY(x,z);if not y then return nil end;return Vector3.new(x,y+(pad or 0),z)
end

-- Smooth design spline used by the current lowland road.
local function catmull(p0,p1,p2,p3,t)
 local t2=t*t;local t3=t2*t
 return .5*((2*p1)+(-p0+p2)*t+(2*p0-5*p1+4*p2-p3)*t2+(-p0+3*p1-3*p2+p3)*t3)
end
local ctrl={Vector3.new(0,10.8,1060),Vector3.new(18,11.4,880),Vector3.new(-7,12.8,700),Vector3.new(31,14.5,565),Vector3.new(70,17,430),Vector3.new(60,22,295),Vector3.new(28,27.5,205),Vector3.new(-8,34,115),Vector3.new(-43,41.5,20),Vector3.new(-55,44,-30)}
local roadPts={}
for i=1,#ctrl-1 do local p0=ctrl[math.max(1,i-1)];local p1=ctrl[i];local p2=ctrl[i+1];local p3=ctrl[math.min(#ctrl,i+2)];for s=0,9 do table.insert(roadPts,catmull(p0,p1,p2,p3,s/10)) end end
table.insert(roadPts,ctrl[#ctrl])
local function dist2DSegment(p,a,b)
 local pv=Vector2.new(p.X,p.Z);local av=Vector2.new(a.X,a.Z);local bv=Vector2.new(b.X,b.Z);local ab=bv-av;local d=ab:Dot(ab);local t=d>0 and math.clamp((pv-av):Dot(ab)/d,0,1) or 0;return (pv-(av+ab*t)).Magnitude
end
local function nearRoad(p,margin)
 for i=1,#roadPts-1 do if dist2DSegment(p,roadPts[i],roadPts[i+1])<(margin or 18) then return true end end
 return false
end

math.randomseed(470823)

-- Break large smooth grassy surfaces with subtle terrain crowns away from the road.
local terrainBreakups=0
for i=1,46 do
 local z=1080-math.random()*1180;local x=(math.random()<.5 and -1 or 1)*math.random(55,310);local p=Vector3.new(x,0,z)
 if not nearRoad(p,34) then
  local gy=terrainY(x,z)
  if gy then
   local r=math.random(20,54);Terrain:FillBall(Vector3.new(x,gy-r*.82,z),r,math.random()<.8 and Enum.Material.Grass or Enum.Material.Ground);terrainBreakups+=1
  end
 end
end

-- Diverse shrubs / saplings instead of repeating the same round tree silhouette.
local function shrubAt(x,z,scale)
 local gy=terrainY(x,z);if not gy then return end
 local p=Vector3.new(x,gy,z);local m=Instance.new("Model");m.Name="MixedShrub";m.Parent=f
 local palette={Color3.fromRGB(47,83,43),Color3.fromRGB(58,95,49),Color3.fromRGB(70,103,52),Color3.fromRGB(42,76,47)}
 local col=palette[math.random(1,#palette)]
 for k=1,math.random(3,6) do
  local off=Vector3.new(math.random(-22,22)/10,math.random(4,13)/10,math.random(-22,22)/10)*scale
  local b=ball("ShrubLobe",p+off,math.random(18,34)/10*scale,Enum.Material.LeafyGrass,col,m,false);b.CanCollide=false
 end
end
for i=1,125 do
 local z=1050-math.random()*1480;local x=(math.random()<.5 and -1 or 1)*math.random(24,220);local p=Vector3.new(x,0,z)
 if not nearRoad(p,15) then shrubAt(x,z,.55+math.random()*.7) end
end

-- Banana / broad-leaf plants around village and humid lower forest.
local function broadPlant(x,z,scale)
 local gy=terrainY(x,z);if not gy then return end
 local m=Instance.new("Model");m.Name="BroadLeafPlant";m.Parent=f;local base=Vector3.new(x,gy,z)
 mk("Stem",Vector3.new(.45*scale,3.5*scale,.45*scale),CFrame.new(base+Vector3.new(0,1.75*scale,0)),Enum.Material.Wood,Color3.fromRGB(83,94,55),m,0,false)
 for i=1,6 do
  local a=(i-1)/6*math.pi*2;local leaf=mk("Leaf",Vector3.new(1.1*scale,.18*scale,5.8*scale),CFrame.new(base+Vector3.new(0,3.6*scale,0))*CFrame.Angles(math.rad(-23),a,math.rad(math.sin(a)*10)),Enum.Material.LeafyGrass,Color3.fromRGB(55+math.random(0,10),103+math.random(0,15),49),m,0,false);leaf.CanCollide=false
 end
end
for i=1,30 do
 local z=1020-math.random()*980;local x=(math.random()<.5 and -1 or 1)*math.random(38,150);local p=Vector3.new(x,0,z);if not nearRoad(p,20) then broadPlant(x,z,.65+math.random()*.55) end
end

-- Irregular rocks and small outcrops through foothills and upper sections.
local rockAnchors={Vector3.new(-80,0,120),Vector3.new(-145,0,-170),Vector3.new(5,0,-490),Vector3.new(170,0,-760),Vector3.new(45,0,-1010),Vector3.new(-180,0,-1240),Vector3.new(-255,0,-1470),Vector3.new(-70,0,-1690),Vector3.new(160,0,-1900),Vector3.new(255,0,-2110),Vector3.new(105,0,-2310),Vector3.new(0,0,-2500)}
local rockCount=0
for idx,a in ipairs(rockAnchors) do
 local count=idx<5 and 10 or 16
 for i=1,count do
  local ang=math.random()*math.pi*2;local r=math.random(25,115);local x=a.X+math.cos(ang)*r;local z=a.Z+math.sin(ang)*r;local gy=terrainY(x,z)
  if gy then
   local s=(idx<6 and math.random(25,70)/10 or math.random(35,105)/10);local mat=idx>7 and Enum.Material.Slate or Enum.Material.Rock;local col=idx>7 and Color3.fromRGB(83+math.random(0,12),84+math.random(0,10),82+math.random(0,10)) or Color3.fromRGB(88+math.random(0,14),88+math.random(0,12),82+math.random(0,10));ball("NaturalRock",Vector3.new(x,gy+s*.18,z),s,mat,col,f,true);rockCount+=1
  end
 end
end

-- Fallen logs / deadwood in forest zones, grounded on actual terrain.
for i=1,26 do
 local z=-120-math.random()*1050;local x=(math.random()<.5 and -1 or 1)*math.random(34,155);local gy=terrainY(x,z)
 if gy then
  local len=math.random(7,16);local a=math.random()*math.pi*2;local start=Vector3.new(x,gy+1.0,z);local finish=start+Vector3.new(math.cos(a)*len,math.random(-8,8)/20,math.sin(a)*len);beam("FallenLog",start,finish,.9+math.random()*.7,Enum.Material.Wood,Color3.fromRGB(74+math.random(0,13),54+math.random(0,10),38),f,true)
 end
end

-- Irrigation / roadside drainage details: short grounded channels instead of long floating strips.
local drainSamples={13,22,31,40,49,58,67}
for _,idx in ipairs(drainSamples) do
 if roadPts[idx] and roadPts[idx+2] then
  local p=roadPts[idx];local q=roadPts[idx+2];local d=q-p;local flat=Vector3.new(d.X,0,d.Z)
  if flat.Magnitude>0 then
   local side=Vector3.new(-flat.Z,0,flat.X).Unit
   for _,sgn in ipairs({-1,1}) do
    local xz=p+side*(sgn*15);local gy=terrainY(xz.X,xz.Z)
    if gy then
     local a=Vector3.new(xz.X,gy+.12,xz.Z);local bxz=q+side*(sgn*15);local gy2=terrainY(bxz.X,bxz.Z) or gy;local b=Vector3.new(bxz.X,gy2+.12,bxz.Z)
     beam("DrainWater",a,b,1.35,Enum.Material.Glass,Color3.fromRGB(73,108,112),f,false).Transparency=.38
     beam("DrainBankA",a+side*(sgn*.95)+Vector3.new(0,.25,0),b+side*(sgn*.95)+Vector3.new(0,.25,0),.55,Enum.Material.Ground,Color3.fromRGB(89,78,59),f,true)
    end
   end
  end
 end
end

-- Culvert crossings and small roadside stones make asphalt-to-dirt transition believable.
for _,idx in ipairs({34,46,57,68}) do
 local p=roadPts[idx];if p then local gy=terrainY(p.X,p.Z);if gy then
  for k=-3,3 do local x=p.X+k*2.4;local z=p.Z+((k%2==0) and 1.3 or -1.0);local y=terrainY(x,z) or gy;ball("RoadEdgeStone",Vector3.new(x,y+.25,z),1.2+math.random()*.9,Enum.Material.Rock,Color3.fromRGB(94,91,82),f,true) end
 end end
end

-- Subtle roadside puddles only in lower village, collisionless and terrain-grounded.
for _,idx in ipairs({18,27,36}) do local p=roadPts[idx];if p then local gy=terrainY(p.X+13,p.Z);if gy then local puddle=mk("RoadsidePuddle",Vector3.new(8,.08,4.5),CFrame.new(p.X+13,gy+.08,p.Z)*CFrame.Angles(0,math.rad(idx*11),0),Enum.Material.Glass,Color3.fromRGB(92,119,119),f,.5,false);puddle.CanCollide=false end end end

-- Human-scale field details: stepping slabs and small stone boundaries near paddies.
for _,v in ipairs({{-74,960,1},{82,915,-1},{-92,805,1},{97,720,-1},{-105,625,1}}) do
 local x,z,dir=v[1],v[2],v[3];for k=0,6 do local px=x+dir*k*3.6;local pz=z+k*.65;local gy=terrainY(px,pz);if gy then mk("FieldStep",Vector3.new(2.4,.35,1.7),CFrame.new(px,gy+.22,pz)*CFrame.Angles(0,math.rad(k*4),0),Enum.Material.Slate,Color3.fromRGB(102,99,89),f,0,true) end end
end

-- Mild lighting depth; day/night cycle remains controlled by ambience script.
Lighting.ShadowSoftness=.42
Lighting.EnvironmentDiffuseScale=.62
Lighting.EnvironmentSpecularScale=.48
local cc=Lighting:FindFirstChild("ACC_RealismColor") or Instance.new("ColorCorrectionEffect");cc.Name="ACC_RealismColor";cc.Brightness=-.01;cc.Contrast=.08;cc.Saturation=-.025;cc.TintColor=Color3.fromRGB(248,246,238);cc.Parent=Lighting
local bloom=Lighting:FindFirstChild("ACC_RealismBloom") or Instance.new("BloomEffect");bloom.Name="ACC_RealismBloom";bloom.Intensity=.16;bloom.Size=26;bloom.Threshold=1.45;bloom.Parent=Lighting
local rays=Lighting:FindFirstChild("ACC_RealismSunRays") or Instance.new("SunRaysEffect");rays.Name="ACC_RealismSunRays";rays.Intensity=.035;rays.Spread=.68;rays.Parent=Lighting

root:SetAttribute("RealismPassReady",true)
root:SetAttribute("RealismVersion","4.7")
root:SetAttribute("TerrainBreakupCount",terrainBreakups)
root:SetAttribute("NaturalRockCount",rockCount)
root:SetAttribute("GroundedRealism",true)
print("[ACC] Mountain v4.7 realism pass ready",terrainBreakups,rockCount)
