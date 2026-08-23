-- ACC Mountain Social Adventure — Lowland Polish v5.3
-- Scope lock: Spawn village -> rice fields -> village road -> foothill -> POS 1 only.
-- This module never rebuilds the master road, houses, trees, or utility poles.
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local Terrain=Workspace.Terrain
local root=Workspace:WaitForChild("ACC_MountainSocial",20);if not root then return end

local master=root:WaitForChild("LowlandMasterV52",20);if not master then return end
task.wait(1.2)
local old=root:FindFirstChild("LowlandPolishV53");if old then old:Destroy() end
local f=Instance.new("Folder");f.Name="LowlandPolishV53";f.Parent=root

local rp=RaycastParams.new();rp.FilterType=Enum.RaycastFilterType.Include;rp.FilterDescendantsInstances={Terrain};rp.IgnoreWater=false
local function terrainY(x,z)
 local hit=Workspace:Raycast(Vector3.new(x,1700,z),Vector3.new(0,-3400,0),rp)
 return hit and hit.Position.Y or nil
end
local function mk(n,s,cf,mat,col,parent,tr,coll)
 local p=Instance.new("Part");p.Name=n;p.Anchored=true;p.Size=s;p.CFrame=cf;p.Material=mat or Enum.Material.Ground
 if col then p.Color=col end;p.Transparency=tr or 0;p.CanCollide=coll==true;p.CastShadow=true
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or f;return p
end
local function beam(n,a,b,w,mat,col,parent,coll)
 local d=b-a;if d.Magnitude<.05 then return nil end
 return mk(n,Vector3.new(w,w,d.Magnitude),CFrame.lookAt((a+b)/2,b),mat,col,parent,0,coll)
end
local function ball(n,pos,size,mat,col,parent,coll)
 local p=mk(n,Vector3.new(size,size*.68,size*.84),CFrame.new(pos)*CFrame.Angles(math.rad(math.random(-10,10)),math.rad(math.random(0,180)),math.rad(math.random(-8,8))),mat,col,parent,0,coll)
 p.Shape=Enum.PartType.Ball;return p
end
local function grassClump(x,z,scale,parent)
 local y=terrainY(x,z);if not y then return 0 end
 local base=Vector3.new(x,y+.03,z)
 for i=1,5 do
  local ang=(i/5)*math.pi*2+math.random()*.35
  local h=(1.0+math.random()*.9)*scale
  local tip=base+Vector3.new(math.cos(ang)*(.35+.35*math.random())*scale,h,math.sin(ang)*(.35+.35*math.random())*scale)
  beam("RoadsideGrass",base,tip,.075*scale,Enum.Material.Grass,Color3.fromRGB(67+math.random(0,18),105+math.random(0,22),57+math.random(0,13)),parent or f,false)
 end
 return 1
end
math.randomseed(530824)

-- 1) Rice terrace contour polish: low retaining stones + extra rice blades, no boxy walls.
local terraceDetail=0
local terraceEdges={
 {-176,1007,-118,1007},{122,986,178,986},
 {-188,931,-124,931},{128,905,194,905},
 {-198,843,-132,843},{138,815,205,815},
 {-205,749,-138,749},{146,710,214,710},
 {-210,649,-146,649},{154,602,220,602}
}
for ei,e in ipairs(terraceEdges) do
 local a=Vector3.new(e[1],0,e[2]);local b=Vector3.new(e[3],0,e[4])
 for s=0,7 do
  local p=a:Lerp(b,s/7);local y=terrainY(p.X,p.Z)
  if y then
   ball("TerraceEdgeStone",Vector3.new(p.X,y+.12,p.Z),.75+math.random()*.55,Enum.Material.Rock,Color3.fromRGB(105+math.random(0,11),101+math.random(0,10),88+math.random(0,9)),f,false)
   terraceDetail+=1
  end
 end
end
local riceBands={
 {-150,1000},{151,982},{-159,925},{162,902},{-169,838},{174,810},{-178,744},{183,706},{-184,645},{190,598}
}
for _,p in ipairs(riceBands) do
 local y=terrainY(p[1],p[2])
 if y then
  for gx=-2,2 do for gz=-1,1 do
   local base=Vector3.new(p[1]+gx*5.1,y+.52,p[2]+gz*5.0)
   for blade=-1,1 do
    beam("RiceFineBlade",base,base+Vector3.new(blade*.12,1.1+math.random()*.35,.08*blade),.055,Enum.Material.Grass,Color3.fromRGB(91+math.random(0,10),138+math.random(0,15),62),f,false)
   end
  end end
 end
end

-- 2) Irrigation canal network and tiny practical crossings.
local irrigationCount=0
local canals={
 {Vector3.new(-118,0,1018),Vector3.new(-116,0,630)},
 {Vector3.new(116,0,995),Vector3.new(118,0,625)},
 {Vector3.new(-126,0,590),Vector3.new(-119,0,430)},
 {Vector3.new(128,0,582),Vector3.new(122,0,430)}
}
for ci,line in ipairs(canals) do
 local prev=nil
 for s=0,14 do
  local p=line[1]:Lerp(line[2],s/14);local y=terrainY(p.X,p.Z)
  if y then
   local q=Vector3.new(p.X,y+.07,p.Z)
   if prev then
    local water=beam("IrrigationChannel",prev,q,.64,Enum.Material.Glass,Color3.fromRGB(74,108,103),f,false)
    if water then water.Transparency=.31 end
    irrigationCount+=1
   end
   prev=q
  end
 end
 local mid=line[1]:Lerp(line[2],.52);local my=terrainY(mid.X,mid.Z)
 if my then
  local rot=(ci%2==0) and 0 or 90
  mk("IrrigationFootbridge",Vector3.new(4.6,.28,1.7),CFrame.new(mid.X,my+.42,mid.Z)*CFrame.Angles(0,math.rad(rot),0),Enum.Material.WoodPlanks,Color3.fromRGB(113,80,51),f,0,true)
  irrigationCount+=1
 end
end

-- 3) Lived-in house yards: stones, water jars, small gardens and clotheslines.
local yardCount=0
local yards={
 {-72,1020,18},{76,978,-14},{-80,902,8},{84,837,-19},
 {-88,768,14},{92,686,-16},{-96,596,10},{98,510,-13}
}
for i,v in ipairs(yards) do
 local x,z,rot=v[1],v[2],v[3];local y=terrainY(x,z)
 if y then
  local cf=CFrame.new(x,y,z)*CFrame.Angles(0,math.rad(rot),0)
  -- stepping stones from porch toward lane
  for s=1,4 do
   local p=(cf*CFrame.new((s%2==0 and .35 or -.25),.10,-10-s*2.1)).Position
   ball("YardStepStone",p,1.25+math.random()*.35,Enum.Material.Rock,Color3.fromRGB(112,108,96),f,true);yardCount+=1
  end
  -- water jar
  local jar=mk("WaterJar",Vector3.new(1.25,1.9,1.25),cf*CFrame.new(6.0,.95,-4.5),Enum.Material.Slate,Color3.fromRGB(104,88,69),f,0,true);jar.Shape=Enum.PartType.Cylinder;yardCount+=1
  -- compact garden bed and plants
  mk("KitchenGarden",Vector3.new(5.6,.32,3.8),cf*CFrame.new(-6.2,.18,2.2),Enum.Material.Ground,Color3.fromRGB(77,64,48),f,0,true);yardCount+=1
  for k=1,4 do
   local gp=(cf*CFrame.new(-7.7+(k-1)*1.0,.42,2.2+((k%2)-.5)*.8)).Position
   ball("GardenPlant",gp,1.0,Enum.Material.LeafyGrass,Color3.fromRGB(58,101,50),f,false);yardCount+=1
  end
  -- clothesline only on alternating houses
  if i%2==1 then
   local a=(cf*CFrame.new(7.5,0,4.0)).Position;local b=(cf*CFrame.new(7.5,0,-3.5)).Position
   mk("ClothesPost",Vector3.new(.3,4.1,.3),CFrame.new(a+Vector3.new(0,2.05,0)),Enum.Material.Wood,Color3.fromRGB(79,59,42),f,0,true)
   mk("ClothesPost",Vector3.new(.3,4.1,.3),CFrame.new(b+Vector3.new(0,2.05,0)),Enum.Material.Wood,Color3.fromRGB(79,59,42),f,0,true)
   beam("ClothesLine",a+Vector3.new(0,3.7,0),b+Vector3.new(0,3.7,0),.045,Enum.Material.SmoothPlastic,Color3.fromRGB(112,109,98),f,false)
   yardCount+=3
  end
 end
end

-- 4) Roadside natural scale: grass, tiny rocks and culverts, kept away from asphalt center.
local roadsideCount=0
local roadsideSpots={
 {-23,1035},{28,1002},{-27,960},{31,930},{-30,875},{34,840},{-32,785},{35,750},
 {-34,695},{37,655},{-39,600},{42,555},{-45,500},{50,455},{-52,395},{57,350},
 {-58,292},{62,250},{-62,205},{58,165},{-59,120},{52,78},{-60,34}
}
for i,p in ipairs(roadsideSpots) do
 roadsideCount+=grassClump(p[1],p[2],.75+(i%3)*.12,f)
 if i%3==0 then
  local y=terrainY(p[1]+3,p[2]+2)
  if y then ball("RoadsidePebble",Vector3.new(p[1]+3,y+.08,p[2]+2),.65+math.random()*.65,Enum.Material.Rock,Color3.fromRGB(101,99,90),f,false);roadsideCount+=1 end
 end
end
local culverts={{-17,770,17},{-18,560,18},{-20,350,20}}
for ci,c in ipairs(culverts) do
 local z=c[2]
 for _,x in ipairs({c[1],c[3]}) do
  local y=terrainY(x,z)
  if y then
   mk("CulvertHeadwall",Vector3.new(3.3,1.0,.7),CFrame.new(x,y+.45,z),Enum.Material.Rock,Color3.fromRGB(103,100,91),f,0,true)
   local opening=mk("CulvertOpening",Vector3.new(1.2,.55,.12),CFrame.new(x,y+.42,z-.38),Enum.Material.SmoothPlastic,Color3.fromRGB(41,44,42),f,0,false);opening.Shape=Enum.PartType.Cylinder
   roadsideCount+=2
  end
 end
end

-- 5) Foothill transition: vegetation gradually shrinks and road clutter increases near CP1.
local foothillCount=0
for i=1,34 do
 local z=330-i*10.5
 local x=(i%2==0 and 1 or -1)*(52+(i%5)*8)
 local y=terrainY(x,z)
 if y then
  if i%4==0 then
   ball("FoothillRock",Vector3.new(x,y+.14,z),1.2+math.random()*2.0,Enum.Material.Rock,Color3.fromRGB(101,99,91),f,false)
  else
   grassClump(x,z,.9+(i%3)*.14,f)
  end
  foothillCount+=1
 end
end

-- 6) POS 1 practical realism: boot wash, equipment rack, first-aid board and trail marker.
local cp1Count=0
local cp1x,cp1z=-55,-30;local cp1y=terrainY(cp1x,cp1z)
if cp1y then
 local cf=CFrame.new(cp1x,cp1y,cp1z)
 -- equipment rack
 mk("GearRackPost",Vector3.new(.45,5,.45),cf*CFrame.new(-21,2.5,-5),Enum.Material.Wood,Color3.fromRGB(77,57,40),f,0,true)
 mk("GearRackPost",Vector3.new(.45,5,.45),cf*CFrame.new(-14,2.5,-5),Enum.Material.Wood,Color3.fromRGB(77,57,40),f,0,true)
 beam("GearRackBar",(cf*CFrame.new(-21,4.5,-5)).Position,(cf*CFrame.new(-14,4.5,-5)).Position,.3,Enum.Material.Wood,Color3.fromRGB(77,57,40),f,true)
 cp1Count+=3
 -- boot wash / small drain
 mk("BootWashPad",Vector3.new(7,.35,4.2),cf*CFrame.new(-4,.2,14),Enum.Material.Rock,Color3.fromRGB(104,101,93),f,0,true)
 local wash=mk("BootWashWater",Vector3.new(6.3,.08,3.5),cf*CFrame.new(-4,.42,14),Enum.Material.Glass,Color3.fromRGB(79,112,108),f,.34,false);cp1Count+=2
 -- first aid board
 local board=mk("FirstAidBoard",Vector3.new(4.5,3.6,.35),cf*CFrame.new(-24,4.1,3),Enum.Material.WoodPlanks,Color3.fromRGB(103,76,50),f,0,true)
 local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.PixelsPerStud=38;gui.Parent=board
 local tx=Instance.new("TextLabel");tx.Size=UDim2.fromScale(1,1);tx.BackgroundTransparency=1;tx.Text="+\nP3K";tx.TextWrapped=true;tx.TextScaled=true;tx.Font=Enum.Font.GothamBold;tx.TextColor3=Color3.fromRGB(226,226,211);tx.Parent=gui;cp1Count+=1
 -- first trail marker immediately after gate
 local post=mk("TrailMarkerPost",Vector3.new(.55,5,.55),cf*CFrame.new(-8,2.5,-31),Enum.Material.Wood,Color3.fromRGB(75,55,39),f,0,true)
 local marker=mk("TrailMarker",Vector3.new(3.5,1.9,.3),cf*CFrame.new(-8,5.1,-31),Enum.Material.WoodPlanks,Color3.fromRGB(83,62,43),f,0,false)
 local mg=Instance.new("SurfaceGui");mg.Face=Enum.NormalId.Front;mg.PixelsPerStud=42;mg.Parent=marker
 local mt=Instance.new("TextLabel");mt.Size=UDim2.fromScale(1,1);mt.BackgroundTransparency=1;mt.Text="HUTAN BAWAH ↑";mt.TextScaled=true;mt.Font=Enum.Font.GothamBold;mt.TextColor3=Color3.fromRGB(236,227,203);mt.Parent=mg;cp1Count+=2
end

-- Slight lowland lighting refinement only; time-cycle controller remains authoritative.
pcall(function()
 Lighting.ShadowSoftness=.20
 Lighting.EnvironmentDiffuseScale=.42
 Lighting.EnvironmentSpecularScale=.48
end)

root:SetAttribute("LowlandPolishReady",true)
root:SetAttribute("LowlandPolishVersion","5.3")
root:SetAttribute("LowlandTerraceDetailCount",terraceDetail)
root:SetAttribute("LowlandIrrigationCount",irrigationCount)
root:SetAttribute("LowlandYardDetailCount",yardCount)
root:SetAttribute("LowlandRoadsideDetailCount",roadsideCount)
root:SetAttribute("LowlandFoothillDetailCount",foothillCount)
root:SetAttribute("LowlandCP1PolishCount",cp1Count)
print("[ACC] Mountain v5.3 LOWLAND POLISH ready",terraceDetail,irrigationCount,yardCount,roadsideCount,foothillCount,cp1Count)
