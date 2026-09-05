-- MOUNT BBYA — Phase 1 visual depth pass v6.6
-- Donor baseline: v6.4 / commit 08dc1c083289a6505808607546fbfb788ea21d36
-- Scope: visual-only after terrain freeze. No Terrain Fill* calls in this file.
-- v6.6 owner runtime scale pass: realistic house / utility-pole / tree proportions.

local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local Terrain=Workspace.Terrain

local root=Workspace:WaitForChild("ACC_MountainSocial",60)
if not root then error("Mount BBYA v6.6: runtime root missing") end
local deadline=os.clock()+60
while not (root:GetAttribute("TerrainFrozen")==true and root:GetAttribute("Phase1VisualReady")==true) do
 if os.clock()>deadline then error("Mount BBYA v6.6: baseline readiness timeout") end
 task.wait(.25)
end

local old=root:FindFirstChild("MountBBYA_Phase1Premium")
if old then old:Destroy() end
local pass=Instance.new("Folder");pass.Name="MountBBYA_Phase1Premium";pass.Parent=root

local rp=RaycastParams.new();rp.FilterType=Enum.RaycastFilterType.Include;rp.FilterDescendantsInstances={Terrain};rp.IgnoreWater=true
local function groundY(x,z)
 local hit=Workspace:Raycast(Vector3.new(x,700,z),Vector3.new(0,-1400,0),rp)
 return hit and hit.Position.Y or 10
end
local function part(name,size,cf,mat,col,parent,coll,tr)
 local p=Instance.new("Part");p.Name=name;p.Anchored=true;p.CanCollide=coll==true;p.CastShadow=true
 p.Size=size;p.CFrame=cf;p.Material=mat or Enum.Material.SmoothPlastic;p.Color=col or Color3.new(1,1,1);p.Transparency=tr or 0
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or pass
 return p
end
local function beam(name,a,b,width,mat,col,parent)
 local d=b-a;if d.Magnitude<.05 then return nil end
 return part(name,Vector3.new(width,width,d.Magnitude),CFrame.lookAt((a+b)/2,b),mat,col,parent,false,0)
end
local function label(facePart,text)
 local sg=Instance.new("SurfaceGui");sg.Face=Enum.NormalId.Front;sg.PixelsPerStud=46;sg.Parent=facePart
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.TextScaled=true;t.Font=Enum.Font.GothamBold
 t.TextColor3=Color3.fromRGB(242,235,213);t.TextStrokeTransparency=.72;t.Parent=sg
end

-- OWNER RUNTIME SCALE PASS ---------------------------------------------------
-- Houses were visibly avatar-sized. Increase vertical architecture only,
-- preserving every foundation footprint and the frozen terrain.
local houseScaleY=1.38
local scaledHouseCount=0
local village=root:FindFirstChild("Village")
if village then
 for _,model in ipairs(village:GetChildren()) do
  if model:IsA("Model") and string.match(model.Name,"^VillageHouse_") then
   local anchor=model:FindFirstChild("Foundation") or model:FindFirstChildWhichIsA("BasePart")
   if anchor then
    local gy=groundY(anchor.Position.X,anchor.Position.Z)
    for _,obj in ipairs(model:GetDescendants()) do
     if obj:IsA("BasePart") then
      local pos=obj.Position
      local rot=obj.CFrame-pos
      local relY=pos.Y-gy
      obj.Size=Vector3.new(obj.Size.X,obj.Size.Y*houseScaleY,obj.Size.Z)
      obj.CFrame=CFrame.new(pos.X,gy+relY*houseScaleY,pos.Z)*rot
     end
    end
    scaledHouseCount+=1
   end
  end
 end
end

-- Existing roadside/forest trees were miniature against a Roblox avatar.
-- Scale from each trunk ground point so no tree floats after enlargement.
local treeScaleXZ=1.55
local treeScaleY=1.80
local scaledTreeCount=0
local function scaleTreeFolder(folder)
 if not folder then return end
 for _,model in ipairs(folder:GetChildren()) do
  if model:IsA("Model") and model.Name=="GroundedTree" then
   local trunk=model:FindFirstChild("Trunk")
   if trunk and trunk:IsA("BasePart") then
    local cx,cz=trunk.Position.X,trunk.Position.Z
    local baseY=trunk.Position.Y-trunk.Size.Y*.5
    for _,obj in ipairs(model:GetDescendants()) do
     if obj:IsA("BasePart") then
      local pos=obj.Position
      local rot=obj.CFrame-pos
      local rel=pos-Vector3.new(cx,baseY,cz)
      local newPos=Vector3.new(cx+rel.X*treeScaleXZ,baseY+rel.Y*treeScaleY,cz+rel.Z*treeScaleXZ)
      obj.Size=Vector3.new(obj.Size.X*treeScaleXZ,obj.Size.Y*treeScaleY,obj.Size.Z*treeScaleXZ)
      obj.CFrame=CFrame.new(newPos)*rot
     end
    end
    scaledTreeCount+=1
   end
  end
 end
end
scaleTreeFolder(root:FindFirstChild("Roadside"))
scaleTreeFolder(root:FindFirstChild("ForestEdge"))

-- Retire the miniature donor power line. v6.6 creates one authoritative,
-- realistic-height utility line below; terrain and road stay untouched.
local roadside=root:FindFirstChild("Roadside")
if roadside then
 for _,obj in ipairs(roadside:GetDescendants()) do
  if obj:IsA("BasePart") and (obj.Name=="UtilityPole" or obj.Name=="CrossArm" or obj.Name=="PowerWire") then
   obj:Destroy()
  end
 end
end

-- Authoritative road center from v6 terrain master.
local roadNodes={{1060,0},{930,8},{800,-4},{670,16},{545,42},{430,59},{335,61},{255,53},{185,42},{150,38}}
local function roadX(z)
 for i=1,#roadNodes-1 do
  local z1,x1=roadNodes[i][1],roadNodes[i][2];local z2,x2=roadNodes[i+1][1],roadNodes[i+1][2]
  if z<=z1 and z>=z2 then local t=(z1-z)/(z1-z2);return x1+(x2-x1)*t end
 end
 return z>1060 and 0 or 38
end

-- 1) Stone-lined shoulders / drains: makes the village road read as a real foothill road.
local drainCount=0
for z=1030,260,-28 do
 local cx=roadX(z)
 for _,side in ipairs({-1,1}) do
  local x=cx+side*13.8;local y=groundY(x,z)
  local stone=part("DrainStone",Vector3.new(1.1,.55,2.6),CFrame.new(x,y+.18,z)*CFrame.Angles(math.rad(5),math.rad(z*1.9),math.rad(side*4)),Enum.Material.Rock,Color3.fromRGB(91,89,81),pass,false)
  stone.Shape=Enum.PartType.Ball
  if z%56==22 or z%56==-34 then
   part("CulvertCap",Vector3.new(3.2,.28,3.4),CFrame.new(x,y+.12,z),Enum.Material.Concrete,Color3.fromRGB(115,113,104),pass,false)
  end
  drainCount+=1
 end
end

-- 2) Single realistic utility line: ~24 studs tall, clearly above avatar/house scale.
local utilityCount=0
local previous=nil
local utilityHeight=24
for _,z in ipairs({1015,910,805,700,595,490,385,280}) do
 local x=roadX(z)+24;local y=groundY(x,z)
 local poleTop=Vector3.new(x,y+utilityHeight,z)
 part("UtilityPole",Vector3.new(.9,utilityHeight,.9),CFrame.new(x,y+utilityHeight*.5,z),Enum.Material.Wood,Color3.fromRGB(75,57,42),pass,true)
 part("CrossArm",Vector3.new(6.4,.48,.48),CFrame.new(x,y+utilityHeight-1.25,z),Enum.Material.Wood,Color3.fromRGB(72,55,41),pass,false)
 if previous then beam("UtilityCable",previous,poleTop,.10,Enum.Material.SmoothPlastic,Color3.fromRGB(38,38,36),pass) end
 previous=poleTop;utilityCount+=1
end

-- 3) Indonesian foothill cues: red-white flag and village welcome marker.
local fz=1000;local fx=roadX(fz)-18;local fy=groundY(fx,fz)
part("FlagPole",Vector3.new(.35,13,.35),CFrame.new(fx,fy+6.5,fz),Enum.Material.Metal,Color3.fromRGB(175,175,170),pass,true)
part("FlagRed",Vector3.new(.12,2.3,5.4),CFrame.new(fx-.25,fy+11.5,fz+2.7),Enum.Material.Fabric,Color3.fromRGB(205,35,45),pass,false)
part("FlagWhite",Vector3.new(.12,2.3,5.4),CFrame.new(fx-.25,fy+9.2,fz+2.7),Enum.Material.Fabric,Color3.fromRGB(238,238,232),pass,false)

local sz=940;local sx=roadX(sz)-25;local sy=groundY(sx,sz)
for _,o in ipairs({-1,1}) do part("WelcomePost",Vector3.new(.8,5.4,.8),CFrame.new(sx+o*6,sy+2.7,sz),Enum.Material.Wood,Color3.fromRGB(72,54,39),pass,true) end
local sign=part("MountBBYASign",Vector3.new(14,3.1,.45),CFrame.new(sx,sy+5.6,sz),Enum.Material.WoodPlanks,Color3.fromRGB(77,57,40),pass,false);label(sign,"MOUNT BBYA  •  DESA KAKI GUNUNG")

-- 4) Non-spherical tropical vegetation clusters: bamboo + banana-like broad leaves.
local vegetationCount=0
local function bambooCluster(x,z,scale)
 local y=groundY(x,z)
 local naturalScale=1.45
 scale=scale*naturalScale
 for i=1,5 do
  local ox=(i-3)*.65;local oz=((i%2)*.8-.4);local h=(9+i*.65)*scale
  part("Bamboo",Vector3.new(.22*scale,h,.22*scale),CFrame.new(x+ox,y+h*.5,z+oz)*CFrame.Angles(0,0,math.rad((i-3)*1.8)),Enum.Material.Grass,Color3.fromRGB(78,112,54),pass,false)
  for j=1,3 do
   local yy=y+h*(.58+j*.10);local dir=(i+j)%2==0 and 1 or -1
   part("BambooLeaf",Vector3.new(2.6*scale,.10,.52*scale),CFrame.new(x+ox+dir*1.1*scale,yy,z+oz)*CFrame.Angles(math.rad(dir*7),math.rad(22*i+31*j),math.rad(dir*8)),Enum.Material.Grass,Color3.fromRGB(55,101,49),pass,false)
  end
 end
 vegetationCount+=1
end
local function broadPlant(x,z,scale)
 local y=groundY(x,z);part("PlantStem",Vector3.new(.38*scale,4.2*scale,.38*scale),CFrame.new(x,y+2.1*scale,z),Enum.Material.Grass,Color3.fromRGB(76,112,57),pass,false)
 for i=1,6 do
  local a=(i-1)*math.pi/3;local len=4.8*scale;local cx=x+math.cos(a)*len*.42;local cz=z+math.sin(a)*len*.42
  part("BroadLeaf",Vector3.new(len,.13,1.0*scale),CFrame.new(cx,y+4.1*scale,cz)*CFrame.Angles(math.rad(-10),-a,math.rad((i%2==0 and 1 or -1)*8)),Enum.Material.Grass,Color3.fromRGB(49,102,49),pass,false)
 end
 vegetationCount+=1
end
for _,v in ipairs({{-48,980,1},{48,900,.9},{-52,820,.95},{66,745,1},{-62,650,.9},{70,575,1},{-35,455,.95},{88,410,.9},{-20,330,1},{83,300,.9},{-18,225,.9},{67,220,.95}}) do bambooCluster(v[1],v[2],v[3]) end
for _,v in ipairs({{-38,930,.8},{55,860,.75},{-48,730,.8},{61,665,.78},{-45,545,.78},{73,510,.76},{-30,380,.76},{77,350,.75}}) do broadPlant(v[1],v[2],v[3]) end

-- 5) Trail transition: rough edge stones + understated wayfinding.
local trail={{28,190},{10,155},{-10,118},{-26,77},{-35,34},{-51,-4},{-67,-39},{-82,-72}}
local trailEdgeCount=0
for i=2,#trail do
 local a=trail[i-1];local b=trail[i];local dx=b[1]-a[1];local dz=b[2]-a[2];local mag=math.sqrt(dx*dx+dz*dz);local nx=-dz/mag;local nz=dx/mag
 for s=1,3 do
  local t=s/4;local x=a[1]+dx*t;local z=a[2]+dz*t;local side=((i+s)%2==0) and -1 or 1;local rx=x+nx*side*3.4;local rz=z+nz*side*3.4;local y=groundY(rx,rz)
  local r=part("TrailEdgeRock",Vector3.new(1.5,.75,1.9),CFrame.new(rx,y+.26,rz)*CFrame.Angles(math.rad(8),math.rad(i*37+s*23),math.rad(5)),Enum.Material.Rock,Color3.fromRGB(88,87,79),pass,false);r.Shape=Enum.PartType.Ball
  trailEdgeCount+=1
 end
end

-- 6) CP1 arrival readability without expanding beyond CP1.
local cp=Vector3.new(-82,groundY(-82,-72),-72)
local board=part("CP1MountBBYA",Vector3.new(12.5,2.8,.45),CFrame.new(cp.X+16,cp.Y+5.0,cp.Z+4)*CFrame.Angles(0,math.rad(-8),0),Enum.Material.WoodPlanks,Color3.fromRGB(70,51,36),pass,false);label(board,"POS 1  •  MOUNT BBYA")
for _,side in ipairs({-1,1}) do part("CP1Bench",Vector3.new(6,.45,1.8),CFrame.new(cp.X+side*10,cp.Y+.7,cp.Z+10),Enum.Material.WoodPlanks,Color3.fromRGB(94,68,46),pass,true) end

-- Lighting refinement stays compatible with donor four-phase ambience.
Lighting.EnvironmentDiffuseScale=.72
Lighting.EnvironmentSpecularScale=.58
Lighting.ShadowSoftness=.32

root:SetAttribute("MountBBYAPhase1PremiumVersion","6.6")
root:SetAttribute("MountBBYAPremiumScope","SPAWN_TO_CP1_ONLY")
root:SetAttribute("MountBBYADrainDetailCount",drainCount)
root:SetAttribute("MountBBYAUtilityPoleCount",utilityCount)
root:SetAttribute("MountBBYAVegetationClusterCount",vegetationCount)
root:SetAttribute("MountBBYATrailEdgeDetailCount",trailEdgeCount)
root:SetAttribute("MountBBYAScaledHouseCount",scaledHouseCount)
root:SetAttribute("MountBBYAScaledTreeCount",scaledTreeCount)
root:SetAttribute("MountBBYAHouseScaleY",houseScaleY)
root:SetAttribute("MountBBYATreeScaleY",treeScaleY)
root:SetAttribute("MountBBYAUtilityHeight",utilityHeight)
root:SetAttribute("MountBBYAPhase1PremiumReady",true)
Workspace:SetAttribute("ACC_MountainBuild","mount-bbya-v6.6-realistic-scale-pass")
print("[MOUNT BBYA] v6.6 realistic scale pass ready",scaledHouseCount,scaledTreeCount,utilityCount)
