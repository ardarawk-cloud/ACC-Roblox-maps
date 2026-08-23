-- ACC Mountain Social Adventure — Environmental Realism v4.9
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local Terrain=Workspace.Terrain
local root=Workspace:WaitForChild("ACC_MountainSocial",20);if not root then return end

task.wait(18)
local old=root:FindFirstChild("EnvironmentV49");if old then old:Destroy() end
local f=Instance.new("Folder");f.Name="EnvironmentV49";f.Parent=root

local rp=RaycastParams.new();rp.FilterType=Enum.RaycastFilterType.Include;rp.FilterDescendantsInstances={Terrain};rp.IgnoreWater=false
local function terrainY(x,z)
 local hit=Workspace:Raycast(Vector3.new(x,1700,z),Vector3.new(0,-3400,0),rp)
 return hit and hit.Position.Y or nil
end
local function mk(n,s,cf,m,c,p,tr,coll)
 local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Material=m or Enum.Material.Ground
 if c then x.Color=c end;x.Transparency=tr or 0;x.CanCollide=coll~=false;x.CastShadow=true;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=p or f;return x
end
local function beam(n,a,b,w,mat,col,p,coll)
 local d=b-a;if d.Magnitude<.05 then return nil end
 return mk(n,Vector3.new(w,w,d.Magnitude),CFrame.lookAt((a+b)/2,b),mat,col,p,0,coll~=false)
end
local function ball(n,pos,size,mat,col,p,coll)
 local x=mk(n,Vector3.new(size,size*.72,size*.86),CFrame.new(pos)*CFrame.Angles(math.rad(math.random(-12,12)),math.rad(math.random(0,180)),math.rad(math.random(-12,12))),mat,col,p,0,coll~=false);x.Shape=Enum.PartType.Ball;return x
end

math.randomseed(490823)

-- Natural global material tuning. This gives terrain more depth without external assets.
pcall(function()
 Terrain:SetMaterialColor(Enum.Material.Grass,Color3.fromRGB(78,103,58))
 Terrain:SetMaterialColor(Enum.Material.Ground,Color3.fromRGB(100,81,58))
 Terrain:SetMaterialColor(Enum.Material.Mud,Color3.fromRGB(83,69,52))
 Terrain:SetMaterialColor(Enum.Material.Rock,Color3.fromRGB(92,91,84))
 Terrain:SetMaterialColor(Enum.Material.Slate,Color3.fromRGB(72,76,74))
 Terrain.WaterColor=Color3.fromRGB(64,105,109)
 Terrain.WaterTransparency=.38
 Terrain.WaterReflectance=.18
 Terrain.WaterWaveSize=.12
 Terrain.WaterWaveSpeed=7
 Workspace.GlobalWind=Vector3.new(3.5,0,1.3)
end)

-- Subtle cinematic depth. Keep values restrained for mobile readability.
local cc=Lighting:FindFirstChild("ACC_RealismColor") or Instance.new("ColorCorrectionEffect");cc.Name="ACC_RealismColor";cc.Brightness=-.015;cc.Contrast=.07;cc.Saturation=-.04;cc.TintColor=Color3.fromRGB(255,248,235);cc.Parent=Lighting
local bloom=Lighting:FindFirstChild("ACC_RealismBloom") or Instance.new("BloomEffect");bloom.Name="ACC_RealismBloom";bloom.Intensity=.16;bloom.Size=28;bloom.Threshold=1.35;bloom.Parent=Lighting
local rays=Lighting:FindFirstChild("ACC_RealismSunRays") or Instance.new("SunRaysEffect");rays.Name="ACC_RealismSunRays";rays.Intensity=.045;rays.Spread=.78;rays.Parent=Lighting
local dof=Lighting:FindFirstChild("ACC_RealismDOF") or Instance.new("DepthOfFieldEffect");dof.Name="ACC_RealismDOF";dof.FarIntensity=.045;dof.FocusDistance=120;dof.InFocusRadius=85;dof.NearIntensity=.025;dof.Parent=Lighting

-- Soil/erosion patches break the single-material hillside look.
local erosionCenters={
 Vector3.new(-135,0,900),Vector3.new(142,0,820),Vector3.new(-116,0,640),Vector3.new(132,0,535),
 Vector3.new(-78,0,315),Vector3.new(92,0,245),Vector3.new(-115,0,90),Vector3.new(-92,0,-150),
 Vector3.new(-205,0,-410),Vector3.new(85,0,-610),Vector3.new(170,0,-845),Vector3.new(-80,0,-1110),
 Vector3.new(-205,0,-1320),Vector3.new(-235,0,-1530),Vector3.new(-70,0,-1770),Vector3.new(155,0,-1985)
}
local erosionCount=0
for i,p in ipairs(erosionCenters) do
 local y=terrainY(p.X,p.Z)
 if y then
  local mat=(i%4==0) and Enum.Material.Rock or ((i%3==0) and Enum.Material.Mud or Enum.Material.Ground)
  local r=18+(i%5)*5
  Terrain:FillBall(Vector3.new(p.X,y-r*.55,p.Z),r,mat)
  erosionCount+=1
 end
end

-- Road shoulder breakup, shallow ditch stones and weathering. All pieces raycast to terrain.
local roadControl={Vector3.new(0,0,1040),Vector3.new(15,0,920),Vector3.new(5,0,790),Vector3.new(5,0,660),Vector3.new(45,0,520),Vector3.new(70,0,390),Vector3.new(55,0,285),Vector3.new(20,0,185),Vector3.new(-15,0,95),Vector3.new(-48,0,-5)}
local roadDetail=0
for i=1,#roadControl-1 do
 local a,b=roadControl[i],roadControl[i+1]
 local dir=Vector3.new(b.X-a.X,0,b.Z-a.Z);if dir.Magnitude>0 then
  local side=Vector3.new(-dir.Z,0,dir.X).Unit
  for s=1,3 do
   local t=s/4;local mid=a:Lerp(b,t);local lr=((i+s)%2==0) and 1 or -1;local q=mid+side*(lr*(15+((i+s)%6)))
   local y=terrainY(q.X,q.Z)
   if y then
    local stone=ball("ShoulderStone",Vector3.new(q.X,y+.35,q.Z),1.4+((i+s)%4)*.45,Enum.Material.Rock,Color3.fromRGB(101+((i+s)%8),98+((i+s)%7),89),f,true);stone.CanCollide=true
    if (i+s)%3==0 then
     local puddle=mk("RoadsidePuddle",Vector3.new(4.2,.12,2.4),CFrame.new(q.X,y+.12,q.Z)*CFrame.Angles(0,math.rad((i*19+s*31)%180),0),Enum.Material.Glass,Color3.fromRGB(74,103,101),f,.38,false);puddle.CastShadow=false
    end
    roadDetail+=1
   end
  end
 end
end

-- Mixed undergrowth: fern fans + tall grass + broad leaves, with less density above highland.
local plantCount=0
local function fern(base,scale)
 local m=Instance.new("Model");m.Name="GroundFern";m.Parent=f
 for k=1,7 do
  local a=(k-1)/7*math.pi*2;local len=(2.7+math.random()*1.8)*scale
  local start=base+Vector3.new(0,.28,0);local endpoint=base+Vector3.new(math.cos(a)*len,1.1*scale,math.sin(a)*len)
  local fr=beam("FernFrond",start,endpoint,.28*scale,Enum.Material.LeafyGrass,Color3.fromRGB(55+math.random(0,10),91+math.random(0,15),48),m,false);if fr then fr.CanCollide=false end
 end
end
local vegetationZones={
 {Vector3.new(0,0,850),210,34},{Vector3.new(20,0,520),190,38},{Vector3.new(-70,0,80),180,42},
 {Vector3.new(-170,0,-280),175,45},{Vector3.new(0,0,-560),180,46},{Vector3.new(145,0,-820),170,45},
 {Vector3.new(30,0,-1070),160,38},{Vector3.new(-180,0,-1300),150,30},{Vector3.new(-245,0,-1510),135,22}
}
for zi,z in ipairs(vegetationZones) do
 for j=1,z[3] do
  local ang=math.random()*math.pi*2;local rad=22+math.sqrt(math.random())*(z[2]-22);local x=z[1].X+math.cos(ang)*rad;local zz=z[1].Z+math.sin(ang)*rad;local y=terrainY(x,zz)
  if y then
   if j%4==0 then fern(Vector3.new(x,y+.05,zz),.55+math.random()*.45)
   else
    local h=.8+math.random()*2.0;local grass=mk("WildGrass",Vector3.new(.32,h,.32),CFrame.new(x,y+h*.5,zz)*CFrame.Angles(math.rad(math.random(-13,13)),math.rad(math.random(0,180)),math.rad(math.random(-13,13))),Enum.Material.LeafyGrass,Color3.fromRGB(68+math.random(0,18),104+math.random(0,25),54),f,0,false);grass.CanCollide=false
   end
   plantCount+=1
  end
 end
end

-- Irregular rock families: multiple overlapping stones avoid single primitive boulders.
local outcropCount=0
local outcropCenters={Vector3.new(-155,0,-210),Vector3.new(-5,0,-505),Vector3.new(155,0,-760),Vector3.new(38,0,-1010),Vector3.new(-185,0,-1240),Vector3.new(-245,0,-1495),Vector3.new(-72,0,-1725),Vector3.new(158,0,-1935),Vector3.new(245,0,-2115),Vector3.new(95,0,-2320)}
for i,c in ipairs(outcropCenters) do
 local y=terrainY(c.X,c.Z)
 if y then
  local m=Instance.new("Model");m.Name="IrregularOutcrop";m.Parent=f
  for k=1,4+(i%3) do
   local off=Vector3.new(math.random(-45,45)/10,math.random(0,20)/10,math.random(-45,45)/10);local s=3.2+math.random()*4.8
   local rock=ball("Rock",Vector3.new(c.X,y+.3,c.Z)+off,s,(i>6) and Enum.Material.Slate or Enum.Material.Rock,Color3.fromRGB(83+math.random(0,18),84+math.random(0,16),80+math.random(0,13)),m,true);rock.CanCollide=true
  end
  outcropCount+=1
 end
end

-- Fallen branches and leaf-litter accents on forest trail margins.
local forestDetail=0
for i=1,30 do
 local z=-180-math.random()*1280;local x=-190+math.random()*380;local y=terrainY(x,z)
 if y then
  if i%3==0 then
   local len=5+math.random()*7;local a=Vector3.new(x,y+.35,z);local b=a+Vector3.new(math.cos(i*1.7)*len,.25,math.sin(i*1.7)*len);beam("FallenBranch",a,b,.45+math.random()*.35,Enum.Material.Wood,Color3.fromRGB(78,59,42),f,true)
  else
   local litter=mk("LeafLitter",Vector3.new(2.0+math.random()*2.5,.09,1.4+math.random()*2.0),CFrame.new(x,y+.08,z)*CFrame.Angles(0,math.rad(math.random(0,180)),0),Enum.Material.LeafyGrass,Color3.fromRGB(78+math.random(0,20),75+math.random(0,16),42),f,.12,false);litter.CastShadow=false
  end
  forestDetail+=1
 end
end

root:SetAttribute("EnvironmentRealismReady",true)
root:SetAttribute("EnvironmentRealismVersion","4.9")
root:SetAttribute("ErosionPatchCount",erosionCount)
root:SetAttribute("RoadWeatherDetailCount",roadDetail)
root:SetAttribute("MixedVegetationCount",plantCount)
root:SetAttribute("IrregularOutcropCount",outcropCount)
root:SetAttribute("ForestMicroDetailCount",forestDetail)
print("[ACC] Mountain v4.9 environmental realism ready",erosionCount,roadDetail,plantCount,outcropCount,forestDetail)
