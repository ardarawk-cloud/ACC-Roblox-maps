-- ACC Mountain Social Adventure — Microdetail / Vegetation Realism v4.8
local Workspace=game:GetService("Workspace")
local Terrain=Workspace.Terrain
local root=Workspace:WaitForChild("ACC_MountainSocial",20);if not root then return end

task.wait(14)
local old=root:FindFirstChild("MicroDetailV48");if old then old:Destroy() end
local f=Instance.new("Folder");f.Name="MicroDetailV48";f.Parent=root

local rp=RaycastParams.new();rp.FilterType=Enum.RaycastFilterType.Include;rp.FilterDescendantsInstances={Terrain};rp.IgnoreWater=false
local function terrainY(x,z)local hit=Workspace:Raycast(Vector3.new(x,1500,z),Vector3.new(0,-3000,0),rp);return hit and hit.Position.Y or nil end
local function mk(n,s,cf,m,c,p,tr,coll)
 local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Material=m or Enum.Material.Wood
 if c then x.Color=c end;x.Transparency=tr or 0;x.CanCollide=coll~=false;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=p or f;return x
end
local function beam(n,a,b,w,mat,col,p,coll)
 local d=b-a;if d.Magnitude<.05 then return nil end
 return mk(n,Vector3.new(w,w,d.Magnitude),CFrame.lookAt((a+b)/2,b),mat,col,p,0,coll~=false)
end
local function leaf(pos,s,col,p)
 local x=mk("LeafCluster",Vector3.new(s,s*.62,s*.8),CFrame.new(pos)*CFrame.Angles(math.rad(math.random(-15,15)),math.rad(math.random(0,180)),math.rad(math.random(-12,12))),Enum.Material.LeafyGrass,col,p,0,false);x.Shape=Enum.PartType.Ball;x.CanCollide=false;return x
end
local function detailedTree(pos,scale,variant)
 local gy=terrainY(pos.X,pos.Z);if not gy then return nil end
 local base=Vector3.new(pos.X,gy,pos.Z);local m=Instance.new("Model");m.Name="DetailedBroadleaf";m.Parent=f
 local bark=variant==2 and Color3.fromRGB(84,62,43) or Color3.fromRGB(69,52,37)
 local leafCol=variant==3 and Color3.fromRGB(42,79,44) or (variant==2 and Color3.fromRGB(58,94,47) or Color3.fromRGB(48,87,43))
 local h=(10+variant*1.2)*scale
 mk("Trunk",Vector3.new(1.45*scale,h,1.45*scale),CFrame.new(base+Vector3.new(0,h*.5,0))*CFrame.Angles(0,0,math.rad(math.random(-3,3))),Enum.Material.Wood,bark,m,0,true)
 local fork=base+Vector3.new(0,h*.68,0)
 for b=1,4 do
  local a=(b-1)/4*math.pi*2+variant*.33;local len=(4.2+math.random()*2.6)*scale;local endp=fork+Vector3.new(math.cos(a)*len,math.random(18,34)/10*scale,math.sin(a)*len);beam("Branch",fork,endp,.55*scale,Enum.Material.Wood,bark,m,true)
  for k=1,3 do local q=endp+Vector3.new(math.random(-28,28)/10*scale,math.random(-8,22)/10*scale,math.random(-28,28)/10*scale);leaf(q,(3.2+math.random()*2.0)*scale,leafCol,m) end
 end
 for i=1,6 do leaf(base+Vector3.new(math.random(-42,42)/10*scale,h+math.random(-15,25)/10*scale,math.random(-42,42)/10*scale),(3.4+math.random()*1.9)*scale,leafCol,m) end
 m:SetAttribute("TerrainGrounded",true);return m
end

math.randomseed(480823)
-- Replace the most visibly spherical roadside trees with detailed multi-cluster trees.
local replaced=0
for _,folderName in ipairs({"VisualPolishV42","PrecisionV44"}) do
 local folder=root:FindFirstChild(folderName)
 if folder then
  local victims={}
  for _,obj in ipairs(folder:GetChildren()) do
   if obj:IsA("Model") and (obj.Name=="BroadleafTree" or obj.Name=="PrecisionTree") then table.insert(victims,obj) end
  end
  for i,obj in ipairs(victims) do
   local ok,cf=pcall(function() return select(1,obj:GetBoundingBox()) end)
   if ok and cf then detailedTree(cf.Position,.62+((i%4)*.09),1+(i%3));obj:Destroy();replaced+=1 end
  end
 end
end

-- Add smaller saplings to break repeated spacing without crowding the asphalt.
for i=1,46 do
 local z=1010-math.random()*1160;local x=(math.random()<.5 and -1 or 1)*math.random(42,175);detailedTree(Vector3.new(x,0,z),.42+math.random()*.28,1+(i%3))
end

-- Rebuild straight precision wires into sagging spans; add ceramic insulators.
local precision=root:FindFirstChild("PrecisionV44")
local spans=0
if precision then
 for _,obj in ipairs(precision:GetChildren()) do if obj.Name:match("^PrecisionWire") then obj:Destroy() end end
 local poles={}
 for _,obj in ipairs(precision:GetChildren()) do
  if obj:IsA("BasePart") and obj.Name:match("^PrecisionPole_") then table.insert(poles,obj) end
 end
 table.sort(poles,function(a,b) return tonumber(a.Name:match("(%d+)$"))<tonumber(b.Name:match("(%d+)$")) end)
 local wireCol=Color3.fromRGB(30,30,29)
 local function sagWire(a,b,offset,name)
  local pts={};local segments=7
  for s=0,segments do local t=s/segments;local p=a:Lerp(b,t)+offset;local sag=math.sin(math.pi*t)*(-2.0-math.min(2.5,(b-a).Magnitude/85));table.insert(pts,p+Vector3.new(0,sag,0)) end
  for i=1,#pts-1 do beam(name.."_"..i,pts[i],pts[i+1],.095,Enum.Material.SmoothPlastic,wireCol,f,false) end
 end
 for i,pole in ipairs(poles) do
  local top=pole.Position+Vector3.new(0,pole.Size.Y*.5-.5,0)
  for _,dx in ipairs({-2.05,2.05}) do
   local ins=mk("Insulator",Vector3.new(.32,.65,.32),CFrame.new(top+Vector3.new(dx,.45,0)),Enum.Material.SmoothPlastic,Color3.fromRGB(207,198,173),f,0,false);ins.Shape=Enum.PartType.Cylinder;ins.CFrame=ins.CFrame*CFrame.Angles(0,0,math.rad(90))
  end
  if i<#poles then
   local b=poles[i+1].Position+Vector3.new(0,poles[i+1].Size.Y*.5-.5,0)
   sagWire(top,b,Vector3.new(-2.05,.45,0),"SagWireA_"..i);sagWire(top,b,Vector3.new(2.05,.45,0),"SagWireB_"..i);spans+=1
  end
 end
end

-- House micro-detail: eaves, gutters, porch lights and foundation stones from each model bounding box.
local visual=root:FindFirstChild("VisualPolishV42")
local houseDetails=0
if visual then
 for _,house in ipairs(visual:GetChildren()) do
  if house:IsA("Model") and house.Name=="VillageHouse" then
   local ok,cf,size=pcall(function() local a,b=house:GetBoundingBox();return a,b end)
   if ok and cf and size then
    local front=cf.LookVector;local right=cf.RightVector;local bottom=cf.Position-Vector3.new(0,size.Y*.5,0);local frontPos=bottom-front*(size.Z*.46)+Vector3.new(0,size.Y*.54,0)
    beam("Gutter",frontPos-right*(size.X*.43),frontPos+right*(size.X*.43),.28,Enum.Material.Metal,Color3.fromRGB(77,76,71),f,false)
    local lamp=mk("PorchLamp",Vector3.new(.55,.8,.45),CFrame.new(frontPos+Vector3.new(0,-3.0,0)),Enum.Material.Glass,Color3.fromRGB(255,218,151),f,.12,false);local light=Instance.new("PointLight");light.Brightness=.6;light.Range=9;light.Color=Color3.fromRGB(255,209,143);light.Parent=lamp
    for s=-1,1 do local p=bottom+right*(s*size.X*.28)-front*(size.Z*.38)+Vector3.new(0,.18,0);local r=mk("FoundationStone",Vector3.new(2.2,.7,1.6),CFrame.new(p)*CFrame.Angles(0,math.rad(s*11),0),Enum.Material.Rock,Color3.fromRGB(104,100,90),f,0,true);r.Shape=Enum.PartType.Ball end
    houseDetails+=1
   end
  end
 end
end

-- Small trail edge markers only at critical upper bends, not an arcade/obby look.
local upperMarks={Vector3.new(-244,455,-1480),Vector3.new(-95,535,-1690),Vector3.new(150,615,-1900),Vector3.new(250,685,-2110),Vector3.new(105,750,-2305)}
for i,p in ipairs(upperMarks) do local gy=terrainY(p.X,p.Z);if gy then local post=mk("TrailMarker",Vector3.new(.7,4.2,.7),CFrame.new(p.X,gy+2.1,p.Z),Enum.Material.Wood,Color3.fromRGB(91,67,46),f,0,true);local cap=mk("MarkerCap",Vector3.new(1.2,.6,1.2),CFrame.new(p.X,gy+4.25,p.Z),Enum.Material.SmoothPlastic,Color3.fromRGB(177,74,50),f,0,false) end end

root:SetAttribute("MicroDetailReady",true)
root:SetAttribute("MicroDetailVersion","4.8")
root:SetAttribute("DetailedTreesReplaced",replaced)
root:SetAttribute("SagWireSpans",spans)
root:SetAttribute("HouseDetailCount",houseDetails)
print("[ACC] Mountain v4.8 microdetail ready",replaced,spans,houseDetails)
