-- ACC Mountain Social Adventure — Terrain Grounding v4.6
local Workspace=game:GetService("Workspace")
local Terrain=Workspace.Terrain
local root=Workspace:WaitForChild("ACC_MountainSocial",20);if not root then return end

task.wait(8) -- wait until visual + precision generators finish

local params=RaycastParams.new()
params.FilterType=Enum.RaycastFilterType.Include
params.FilterDescendantsInstances={Terrain}
params.IgnoreWater=false

local function terrainY(x,z)
 local hit=Workspace:Raycast(Vector3.new(x,1400,z),Vector3.new(0,-2800,0),params)
 return hit and hit.Position.Y or nil
end

local grounded=0
local function groundModel(model,pad)
 if not model:IsA("Model") then return end
 local ok,cf,size=pcall(function() local a,b=model:GetBoundingBox();return a,b end)
 if not ok or not cf or not size then return end
 local y=terrainY(cf.Position.X,cf.Position.Z);if not y then return end
 local bottom=cf.Position.Y-size.Y*.5
 local dy=y-bottom+(pad or .05)
 if math.abs(dy)>0.03 then model:PivotTo(model:GetPivot()+Vector3.new(0,dy,0)) end
 model:SetAttribute("TerrainGrounded",true)
 grounded+=1
end

-- Ground all tree models from the village and precision passes.
for _,folderName in ipairs({"VisualPolishV42","PrecisionV44"}) do
 local folder=root:FindFirstChild(folderName)
 if folder then
  for _,obj in ipairs(folder:GetChildren()) do
   if obj:IsA("Model") and (obj.Name=="BroadleafTree" or obj.Name=="Palm" or obj.Name=="PrecisionTree") then
    groundModel(obj,.08)
   end
  end
 end
end

-- Rebuild precision utility poles/wires from actual terrain height.
local precision=root:FindFirstChild("PrecisionV44")
if precision then
 for _,obj in ipairs(precision:GetChildren()) do
  if obj.Name:match("^PrecisionPole_") or obj.Name:match("^PrecisionArm_") or obj.Name:match("^PrecisionWire") then obj:Destroy() end
 end

 local function mk(n,s,cf,m,c,p,tr,coll)
  local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Material=m or Enum.Material.Wood
  if c then x.Color=c end;x.Transparency=tr or 0;x.CanCollide=coll~=false;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=p;return x
 end
 local function beam(n,a,b,w,mat,col,p)
  local d=b-a;if d.Magnitude<.05 then return end
  return mk(n,Vector3.new(w,w,d.Magnitude),CFrame.lookAt((a+b)/2,b),mat,col,p,0,false)
 end
 local function catmull(p0,p1,p2,p3,t)
  local t2=t*t;local t3=t2*t
  return 0.5*((2*p1)+(-p0+p2)*t+(2*p0-5*p1+4*p2-p3)*t2+(-p0+3*p1-3*p2+p3)*t3)
 end
 local ctrl={
  Vector3.new(0,10.8,1060),Vector3.new(18,11.4,880),Vector3.new(-7,12.8,700),Vector3.new(31,14.5,565),
  Vector3.new(70,17.0,430),Vector3.new(60,22.0,295),Vector3.new(28,27.5,205),Vector3.new(-8,34.0,115),
  Vector3.new(-43,41.5,20),Vector3.new(-55,44,-30)
 }
 local pts={}
 for i=1,#ctrl-1 do
  local p0=ctrl[math.max(1,i-1)];local p1=ctrl[i];local p2=ctrl[i+1];local p3=ctrl[math.min(#ctrl,i+2)]
  for s=0,7 do table.insert(pts,catmull(p0,p1,p2,p3,s/8)) end
 end
 table.insert(pts,ctrl[#ctrl])
 local function halfWidth(i)
  local progress=(i-1)/math.max(1,#pts-2)
  if progress<.48 then return 11 elseif progress<.70 then return 10 elseif progress<.86 then return 8.5 else return 7 end
 end
 local tops={}
 for i=7,math.min(#pts-8,53),8 do
  local p=pts[i];local d=pts[i+1]-pts[i-1];local flat=Vector3.new(d.X,0,d.Z)
  if flat.Magnitude>0 then
   local side=Vector3.new(-flat.Z,0,flat.X).Unit;local q=p+side*(halfWidth(i)+10)
   local gy=terrainY(q.X,q.Z)
   if gy then
    q=Vector3.new(q.X,gy,q.Z)
    mk("PrecisionPole_"..i,Vector3.new(.9,15,.9),CFrame.new(q+Vector3.new(0,7.5,0)),Enum.Material.Wood,Color3.fromRGB(68,51,39),precision)
    mk("PrecisionArm_"..i,Vector3.new(6.5,.45,.45),CFrame.new(q+Vector3.new(0,14.2,0)),Enum.Material.Wood,Color3.fromRGB(68,51,39),precision)
    tops[#tops+1]=q+Vector3.new(0,14.5,0)
   end
  end
 end
 for i=1,#tops-1 do
  beam("PrecisionWireA_"..i,tops[i]+Vector3.new(-2.1,0,0),tops[i+1]+Vector3.new(-2.1,0,0),.12,Enum.Material.SmoothPlastic,Color3.fromRGB(35,35,34),precision)
  beam("PrecisionWireB_"..i,tops[i]+Vector3.new(2.1,0,0),tops[i+1]+Vector3.new(2.1,0,0),.12,Enum.Material.SmoothPlastic,Color3.fromRGB(35,35,34),precision)
 end
end

root:SetAttribute("TerrainGroundingReady",true)
root:SetAttribute("TerrainGroundingVersion","4.6")
root:SetAttribute("GroundedSceneryCount",grounded)
print("[ACC] Mountain v4.6 terrain grounding ready; models grounded",grounded)
