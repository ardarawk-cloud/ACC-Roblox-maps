-- ACC Mountain Social Adventure — Immersive Biome Realism v5.0
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local Terrain=Workspace.Terrain
local root=Workspace:WaitForChild("ACC_MountainSocial",20);if not root then return end

task.wait(22)
local old=root:FindFirstChild("ImmersiveV50");if old then old:Destroy() end
local f=Instance.new("Folder");f.Name="ImmersiveV50";f.Parent=root

local rp=RaycastParams.new();rp.FilterType=Enum.RaycastFilterType.Include;rp.FilterDescendantsInstances={Terrain};rp.IgnoreWater=false
local function terrainY(x,z)
 local hit=Workspace:Raycast(Vector3.new(x,1600,z),Vector3.new(0,-3200,0),rp)
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
 local x=mk(n,Vector3.new(size,size*.72,size*.9),CFrame.new(pos)*CFrame.Angles(math.rad(math.random(-12,12)),math.rad(math.random(0,180)),math.rad(math.random(-10,10))),mat,col,p,0,coll~=false);x.Shape=Enum.PartType.Ball;return x
end

math.randomseed(500823)

-- Water surface response: subtle, reflective mountain water instead of flat plastic-looking water.
pcall(function()
 Terrain.WaterWaveSize=.12
 Terrain.WaterWaveSpeed=7
 Terrain.WaterReflectance=.33
 Terrain.WaterTransparency=.28
 Terrain.WaterColor=Color3.fromRGB(54,91,88)
end)

-- Lighting depth that stays compatible with the existing four-phase day cycle.
pcall(function()
 Lighting.GlobalShadows=true
 Lighting.ShadowSoftness=.22
 Lighting.EnvironmentDiffuseScale=.38
 Lighting.EnvironmentSpecularScale=.58
end)

-- Natural roadside crack clusters on the actual precision road pieces.
local road= root:FindFirstChild("PrecisionV44")
local crackCount=0
if road then
 local roads={}
 for _,p in ipairs(road:GetChildren()) do if p:IsA("BasePart") and p.Name:match("^PrecisionRoad_") and p.Material==Enum.Material.Asphalt then table.insert(roads,p) end end
 table.sort(roads,function(a,b)return a.Name<b.Name end)
 for i=5,#roads,7 do
  local p=roads[i]
  local top=p.CFrame*CFrame.new(((i%3)-1)*p.Size.X*.18,p.Size.Y*.51,0)
  local start=top.Position
  local right=p.CFrame.RightVector;local forward=p.CFrame.LookVector
  local q1=start+right*(1.1+(i%2)*.7)+forward*.9
  local q2=q1-right*.55+forward*1.25
  beam("RoadCrack",start,q1,.10,Enum.Material.SmoothPlastic,Color3.fromRGB(30,30,29),f,false)
  beam("RoadCrack",q1,q2,.085,Enum.Material.SmoothPlastic,Color3.fromRGB(30,30,29),f,false)
  crackCount+=2
 end
end

-- Ditch stones, grass clumps and small erosion debris at the lowland shoulders.
local shoulderDetail=0
for i=1,70 do
 local z=1030-math.random()*1120
 local x=(math.random()<.5 and -1 or 1)*math.random(28,82)
 local y=terrainY(x,z)
 if y then
  if i%3==0 then
   ball("DitchStone",Vector3.new(x,y+.24,z),1.1+math.random()*1.6,Enum.Material.Rock,Color3.fromRGB(98+math.random(0,16),94+math.random(0,14),82+math.random(0,12)),f,false)
  else
   local h=.8+math.random()*1.6
   for b=1,4 do
    local ang=(b/4)*math.pi*2+math.random()*.35
    local tip=Vector3.new(x+math.cos(ang)*(.35+math.random()*.5),y+h,z+math.sin(ang)*(.35+math.random()*.5))
    beam("ShoulderGrass",Vector3.new(x,y+.04,z),tip,.11,Enum.Material.Grass,Color3.fromRGB(66+math.random(0,18),102+math.random(0,24),56+math.random(0,12)),f,false)
   end
  end
  shoulderDetail+=1
 end
end

-- Forest trail roots and leaf-litter clusters: low profile so it remains hiking terrain, not an obby.
local rootCount=0
local rootAnchors={
 Vector3.new(-62,0,-135),Vector3.new(-96,0,-280),Vector3.new(-122,0,-410),Vector3.new(-154,0,-545),
 Vector3.new(-181,0,-680),Vector3.new(-205,0,-820),Vector3.new(-226,0,-960),Vector3.new(-248,0,-1090)
}
for idx,a in ipairs(rootAnchors) do
 local y=terrainY(a.X,a.Z)
 if y then
  local base=Vector3.new(a.X,y+.12,a.Z)
  for k=1,3 do
   local ang=math.rad(-55+k*30+idx*7)
   local len=4.2+k*.9
   local b=base+Vector3.new(math.cos(ang)*len,.08,math.sin(ang)*len)
   beam("ExposedRoot",base,b,.34-(k*.04),Enum.Material.Wood,Color3.fromRGB(82,61,43),f,false)
   rootCount+=1
  end
  for j=1,5 do
   ball("ForestFloorRock",base+Vector3.new(math.random(-35,35)/10,.10,math.random(-32,32)/10),.55+math.random()*.65,Enum.Material.Rock,Color3.fromRGB(91,91,80),f,false)
  end
 end
end

-- River detail: shoreline stones and stepped rapids around the known crossing zone.
local riverDetail=0
for i=1,32 do
 local z=-730+math.random(-75,75)
 local x=-80+math.random(-95,95)
 local y=terrainY(x,z)
 if y then
  ball("RiverStone",Vector3.new(x,y+.15,z),1.0+math.random()*2.4,Enum.Material.Rock,Color3.fromRGB(94+math.random(0,18),96+math.random(0,15),91+math.random(0,12)),f,false)
  riverDetail+=1
 end
end
for i=1,9 do
 local x=-150+i*17
 local z=-724+math.sin(i*.8)*12
 local y=terrainY(x,z)
 if y then
  local foam=mk("RapidHighlight",Vector3.new(7,.09,1.2),CFrame.new(x,y+.30,z)*CFrame.Angles(0,math.rad(10+i*8),0),Enum.Material.Glass,Color3.fromRGB(220,231,224),f,.45,false)
  riverDetail+=1
 end
end

-- High-altitude biome: smaller wind-shaped shrubs, dry grasses and exposed stone.
local alpineCount=0
for i=1,75 do
 local z=-1450-math.random()*1050
 local x=-320+math.random()*650
 local y=terrainY(x,z)
 if y and y>390 then
  if i%4==0 then
   ball("HighlandRock",Vector3.new(x,y+.2,z),1.4+math.random()*3.0,Enum.Material.Slate,Color3.fromRGB(105+math.random(0,18),105+math.random(0,14),100+math.random(0,10)),f,false)
  else
   local h=.55+math.random()*1.35
   for b=1,3 do
    local lean=Vector3.new(.7+math.random()*.6,h,math.random(-8,8)/10)
    if i%2==0 then lean=Vector3.new(-lean.X,lean.Y,lean.Z) end
    beam("WindGrass",Vector3.new(x,y+.02,z),Vector3.new(x,y,z)+lean,.09,Enum.Material.Grass,Color3.fromRGB(114+math.random(0,20),121+math.random(0,18),72+math.random(0,12)),f,false)
   end
  end
  alpineCount+=1
 end
end

-- Village/camp practical lights. Lights only wake up at night, preserving the day cycle.
local lamps={}
local function lantern(pos,range,brightness)
 local y=terrainY(pos.X,pos.Z);if not y then return end
 local pole=mk("LanternPost",Vector3.new(.45,5.2,.45),CFrame.new(pos.X,y+2.6,pos.Z),Enum.Material.Wood,Color3.fromRGB(72,53,39),f,0,true)
 local housing=mk("LanternHousing",Vector3.new(.75,.85,.75),CFrame.new(pos.X,y+5.3,pos.Z),Enum.Material.Metal,Color3.fromRGB(74,72,65),f,0,false)
 local glass=mk("LanternGlass",Vector3.new(.55,.55,.55),CFrame.new(pos.X,y+5.25,pos.Z),Enum.Material.Glass,Color3.fromRGB(255,215,151),f,.18,false)
 local light=Instance.new("PointLight");light.Name="NightLight";light.Color=Color3.fromRGB(255,203,137);light.Range=range or 18;light.Brightness=brightness or 1.0;light.Shadows=true;light.Enabled=false;light.Parent=glass
 table.insert(lamps,light)
end
for _,p in ipairs({Vector3.new(-28,0,940),Vector3.new(44,0,820),Vector3.new(-55,0,690),Vector3.new(66,0,550),Vector3.new(-18,0,390),Vector3.new(-48,0,-60),Vector3.new(-198,0,-980)}) do lantern(p,17,1.05) end

local function updateLights()
 local phase=tostring(Workspace:GetAttribute("ACC_DayPhase") or "")
 local night=phase=="NIGHT" or Lighting.ClockTime>=18.4 or Lighting.ClockTime<5.3
 for _,l in ipairs(lamps) do if l and l.Parent then l.Enabled=night end end
end
updateLights();Workspace:GetAttributeChangedSignal("ACC_DayPhase"):Connect(updateLights)
task.spawn(function() while f.Parent do updateLights();task.wait(8) end end)

root:SetAttribute("ImmersiveBiomeReady",true)
root:SetAttribute("ImmersiveBiomeVersion","5.0")
root:SetAttribute("RoadCrackDetailCount",crackCount)
root:SetAttribute("ShoulderNaturalDetailCount",shoulderDetail)
root:SetAttribute("TrailRootCount",rootCount)
root:SetAttribute("RiverMicroDetailCount",riverDetail)
root:SetAttribute("HighlandBiomeDetailCount",alpineCount)
root:SetAttribute("NightLanternCount",#lamps)
print("[ACC] Mountain v5.0 immersive biome realism ready",crackCount,shoulderDetail,rootCount,riverDetail,alpineCount,#lamps)
