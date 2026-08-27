-- ACC Mountain Social Adventure — Natural Lowland Route v5.4
-- Scope: Spawn -> paved road -> damaged road/gravel -> footpath -> POS 1.
local Workspace=game:GetService("Workspace")
local Terrain=Workspace.Terrain
local root=Workspace:WaitForChild("ACC_MountainSocial",20);if not root then return end
local master=root:WaitForChild("LowlandMasterV52",20);if not master then return end

task.wait(.75)
local old=root:FindFirstChild("LowlandRouteV54");if old then old:Destroy() end
local f=Instance.new("Folder");f.Name="LowlandRouteV54";f.Parent=root

local rp=RaycastParams.new();rp.FilterType=Enum.RaycastFilterType.Include;rp.FilterDescendantsInstances={Terrain};rp.IgnoreWater=false
local function ground(x,z)
 local hit=Workspace:Raycast(Vector3.new(x,1500,z),Vector3.new(0,-3000,0),rp)
 return hit and hit.Position.Y or nil
end
local function mk(n,s,cf,mat,col,parent,tr,coll)
 local p=Instance.new("Part");p.Name=n;p.Anchored=true;p.Size=s;p.CFrame=cf;p.Material=mat or Enum.Material.Ground
 if col then p.Color=col end;p.Transparency=tr or 0;p.CanCollide=coll==true;p.CastShadow=true
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or f;return p
end
local function seg(n,a,b,w,h,mat,col,parent,tr,coll)
 local d=b-a;if d.Magnitude<.05 then return nil end
 return mk(n,Vector3.new(w,h,d.Magnitude+.12),CFrame.lookAt((a+b)/2,b),mat,col,parent,tr,coll)
end
local function catmull(p0,p1,p2,p3,t)
 local t2=t*t;local t3=t2*t
 return .5*((2*p1)+(-p0+p2)*t+(2*p0-5*p1+4*p2-p3)*t2+(-p0+3*p1-3*p2+p3)*t3)
end
local function sample(ctrl,steps)
 local raw={}
 for i=1,#ctrl-1 do
  local p0=ctrl[math.max(1,i-1)];local p1=ctrl[i];local p2=ctrl[i+1];local p3=ctrl[math.min(#ctrl,i+2)]
  for s=0,steps-1 do table.insert(raw,catmull(p0,p1,p2,p3,s/steps)) end
 end
 table.insert(raw,ctrl[#ctrl])
 local out={}
 for _,p in ipairs(raw) do local y=ground(p.X,p.Z);if y then table.insert(out,Vector3.new(p.X,y,p.Z)) end end
 return out
end

-- Remove the v5.2 slab road and its surface-dependent details. Houses/paddies/trees stay.
local removed=0
for _,obj in ipairs(master:GetChildren()) do
 if obj:IsA("BasePart") and (
  obj.Name:match("^MasterRoad_") or obj.Name=="RoadShoulder" or obj.Name=="RoadCenterDash" or
  obj.Name=="StoneDrain" or obj.Name=="DrainWater" or obj.Name=="AsphaltCrack") then
  obj:Destroy();removed+=1
 end
end

-- VEHICLE ACCESS: long gentle approach. It intentionally stops before the actual hiking footpath.
local roadCtrl={
 Vector3.new(0,0,1060),Vector3.new(9,0,970),Vector3.new(17,0,875),Vector3.new(7,0,780),
 Vector3.new(-3,0,690),Vector3.new(15,0,600),Vector3.new(43,0,510),Vector3.new(65,0,430),
 Vector3.new(68,0,365),Vector3.new(58,0,325)
}
local road=sample(roadCtrl,26)
local roadParts=0
for i=1,#road-1 do
 local a0,b0=road[i],road[i+1];local t=(i-1)/math.max(1,#road-2)
 local w=t<.58 and 22 or (t<.82 and 19 or 16)
 local mat=t<.60 and Enum.Material.Asphalt or (t<.84 and Enum.Material.Asphalt or Enum.Material.Pebble)
 local col=t<.60 and Color3.fromRGB(47,49,49) or (t<.84 and Color3.fromRGB(57,57,54) or Color3.fromRGB(98,93,82))
 local a=Vector3.new(a0.X,a0.Y-.03,a0.Z);local b=Vector3.new(b0.X,b0.Y-.03,b0.Z)
 -- Fill a shallow subgrade beneath every short tile so the road can never bridge over empty air.
 local d=b-a;local mid=(a+b)/2;local yaw=CFrame.lookAt(mid,b)
 Terrain:FillBlock(yaw*CFrame.new(0,-.72,0),Vector3.new(w+3,1.55,d.Magnitude+1.0),Enum.Material.Ground)
 seg("GroundedRoad",a,b,w,.34,mat,col,f,0,true);roadParts+=1
 local flat=Vector3.new(d.X,0,d.Z);local side=flat.Magnitude>0 and Vector3.new(-flat.Z,0,flat.X).Unit or Vector3.xAxis
 for _,sgn in ipairs({-1,1}) do
  local qa=a+side*sgn*(w*.5+1.0);local qb=b+side*sgn*(w*.5+1.0)
  local ya=ground(qa.X,qa.Z);local yb=ground(qb.X,qb.Z)
  if ya and yb then seg("GroundedShoulder",Vector3.new(qa.X,ya-.04,qa.Z),Vector3.new(qb.X,yb-.04,qb.Z),2.0,.28,Enum.Material.Ground,Color3.fromRGB(91,82,63),f,0,true) end
 end
 if t<.48 and i%9==1 then
  local q=a:Lerp(b,.5)+Vector3.new(0,.20,0);local dir=(b-a).Unit
  seg("CenterMark",q-dir*1.8,q+dir*1.8,.22,.045,Enum.Material.SmoothPlastic,Color3.fromRGB(207,200,178),f,0,false)
 end
 -- broken asphalt becomes progressively patchier before vehicle access ends.
 if t>.60 and t<.88 and i%7==0 then
  local q=a:Lerp(b,.55)+Vector3.new(0,.20,0)
  local patch=mk("RoadDamage",Vector3.new(2.2+(i%3),.055,3.0+(i%4)),CFrame.new(q)*CFrame.Angles(0,math.rad((i*29)%180),0),Enum.Material.Pebble,Color3.fromRGB(89,84,74),f,0,false);patch.CanCollide=false
 end
end

-- End-of-road layby/turnaround. Hiking begins beside it, not straight into a mountain wall.
local endp=road[#road];local ey=ground(endp.X,endp.Z) or endp.Y
Terrain:FillBlock(CFrame.new(endp.X,ey-.8,endp.Z),Vector3.new(38,1.8,28),Enum.Material.Ground)
mk("RoadEndLayby",Vector3.new(31,.32,20),CFrame.new(endp.X,ey+.02,endp.Z)*CFrame.Angles(0,math.rad(-8),0),Enum.Material.Pebble,Color3.fromRGB(96,92,82),f,0,true)

-- Clear only the hiking corridor through the oversized foothill mass, then rebuild a gentle forest floor.
-- This removes the current 'road hits a giant hill' silhouette without flattening the whole mountain.
local trailCtrl={
 Vector3.new(50,0,322),Vector3.new(35,0,285),Vector3.new(8,0,245),Vector3.new(-16,0,205),
 Vector3.new(-35,0,162),Vector3.new(-48,0,115),Vector3.new(-62,0,70),Vector3.new(-63,0,25),Vector3.new(-55,0,-30)
}
-- First-pass approximate heights are used for carving; the corridor is wide and shallow, not a tunnel.
for i=1,#trailCtrl do
 local p=trailCtrl[i];local y=ground(p.X,p.Z)
 if y then
  local width=44-math.min(18,(i-1)*2.2)
  Terrain:FillBlock(CFrame.new(p.X,y+22,p.Z),Vector3.new(width,44,42),Enum.Material.Air)
  Terrain:FillBlock(CFrame.new(p.X,y-1.8,p.Z),Vector3.new(width,4.0,42),Enum.Material.Ground)
 end
end

local trail=sample(trailCtrl,22)
local trailParts=0
for i=1,#trail-1 do
 local a0,b0=trail[i],trail[i+1];local t=(i-1)/math.max(1,#trail-2)
 local w=11.5-(t*4.2)
 local a=Vector3.new(a0.X,a0.Y+.02,a0.Z);local b=Vector3.new(b0.X,b0.Y+.02,b0.Z)
 local d=b-a;local mid=(a+b)/2;local yaw=CFrame.lookAt(mid,b)
 Terrain:FillBlock(yaw*CFrame.new(0,-.55,0),Vector3.new(w+2.0,1.2,d.Magnitude+.8),Enum.Material.Ground)
 seg("NaturalFootpath",a,b,w,.22,t<.42 and Enum.Material.Ground or Enum.Material.Pebble,t<.42 and Color3.fromRGB(105,87,65) or Color3.fromRGB(96,90,76),f,0,true)
 trailParts+=1
 -- roots/stones appear gradually, never as an obby wall.
 if t>.28 and i%9==0 then
  local flat=Vector3.new(d.X,0,d.Z);local side=flat.Magnitude>0 and Vector3.new(-flat.Z,0,flat.X).Unit or Vector3.xAxis
  local q=a:Lerp(b,.55)+Vector3.new(0,.16,0)+side*((i%3)-1)*1.2
  seg("ExposedRoot",q-side*2.0,q+side*2.0,.18,Enum.Material.Wood,Color3.fromRGB(77,58,42),f,0,false)
 end
end

-- Vegetation density ramp: open roadside -> woodland entrance -> dense forest near CP1.
math.randomseed(540828)
local forestDetail=0
local function bush(pos,scale)
 for k=1,3 do
  local a=k/3*math.pi*2
  local p=mk("TrailBush",Vector3.new(2.8*scale,1.8*scale,2.8*scale),CFrame.new(pos+Vector3.new(math.cos(a)*1.1*scale,.7*scale,math.sin(a)*1.1*scale)),Enum.Material.LeafyGrass,Color3.fromRGB(45+math.random(0,12),82+math.random(0,15),43),f,0,false)
  p.Shape=Enum.PartType.Ball
 end
end
for i=8,#trail-7,10 do
 local p=trail[i];local d=trail[i+1]-trail[i-1];local flat=Vector3.new(d.X,0,d.Z);if flat.Magnitude>0 then
  local side=Vector3.new(-flat.Z,0,flat.X).Unit;local t=i/#trail;local off=9.5+(1-t)*5
  for _,sgn in ipairs({-1,1}) do
   local q=p+side*sgn*(off+math.random()*5);local y=ground(q.X,q.Z)
   if y then bush(Vector3.new(q.X,y,q.Z),.75+t*.45);forestDetail+=1 end
  end
 end
end

-- Clear visual cue: road ends here, footpath begins to the side.
local sy=ground(52,315) or ey
local sign=mk("TrailEntranceSign",Vector3.new(8.5,3.0,.38),CFrame.new(47,sy+4.6,309)*CFrame.Angles(0,math.rad(18),0),Enum.Material.WoodPlanks,Color3.fromRGB(74,55,39),f,0,true)
local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.PixelsPerStud=34;gui.Parent=sign
local txt=Instance.new("TextLabel");txt.Size=UDim2.fromScale(1,1);txt.BackgroundTransparency=1;txt.Text="JALUR PENDAKIAN →";txt.TextScaled=true;txt.Font=Enum.Font.GothamBold;txt.TextColor3=Color3.fromRGB(232,224,198);txt.Parent=gui
for _,x in ipairs({43,51}) do local y=ground(x,309) or sy;mk("TrailSignPost",Vector3.new(.45,4.5,.45),CFrame.new(x,y+2.25,309),Enum.Material.Wood,Color3.fromRGB(72,53,38),f,0,true) end

root:SetAttribute("LowlandRouteReady",true)
root:SetAttribute("LowlandRouteVersion","5.4")
root:SetAttribute("RoadGroundedSubgrade",true)
root:SetAttribute("VehicleRoadEndsBeforeTrail",true)
root:SetAttribute("NaturalFootpathReady",true)
root:SetAttribute("LowlandGroundedRoadParts",roadParts)
root:SetAttribute("LowlandFootpathParts",trailParts)
root:SetAttribute("LowlandForestRampDetail",forestDetail)
print("[ACC] Mountain v5.4 grounded natural road-to-trail transition ready",roadParts,trailParts,forestDetail,removed)
