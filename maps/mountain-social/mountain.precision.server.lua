-- ACC Mountain Social Adventure — Precision Alignment v4.4
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("ACC_MountainSocial",20);if not root then return end
local low=root:WaitForChild("Lowlands",20);if not low then return end
local decor=root:FindFirstChild("Decor") or root

task.wait(3.5) -- allow visual pass to finish before cleanup/rebuild

local old=root:FindFirstChild("PrecisionV44");if old then old:Destroy() end
local precision=Instance.new("Folder");precision.Name="PrecisionV44";precision.Parent=root

local function mk(n,s,cf,m,c,p,tr,coll)
 local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Material=m or Enum.Material.Ground
 if c then x.Color=c end;x.Transparency=tr or 0;x.CanCollide=coll~=false;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=p or precision;return x
end
local function segment(n,a,b,w,h,mat,col,p,tr,coll)
 local d=b-a;if d.Magnitude<.05 then return nil end
 return mk(n,Vector3.new(w,h,d.Magnitude+.35),CFrame.lookAt((a+b)/2,b),mat,col,p,tr,coll)
end
local function beam(n,a,b,w,mat,col,p)
 return segment(n,a,b,w,w,mat,col,p,0,false)
end
local function catmull(p0,p1,p2,p3,t)
 local t2=t*t;local t3=t2*t
 return 0.5*((2*p1)+(-p0+p2)*t+(2*p0-5*p1+4*p2-p3)*t2+(-p0+3*p1-3*p2+p3)*t3)
end

-- Same design control points as lowland master, but resampled into a smooth spline.
local ctrl={
 Vector3.new(0,10.8,1060),Vector3.new(18,11.4,880),Vector3.new(-7,12.8,700),Vector3.new(31,14.5,565),
 Vector3.new(70,17.0,430),Vector3.new(60,22.0,295),Vector3.new(28,27.5,205),Vector3.new(-8,34.0,115),
 Vector3.new(-43,41.5,20),Vector3.new(-55,44,-30)
}
local pts={}
for i=1,#ctrl-1 do
 local p0=ctrl[math.max(1,i-1)];local p1=ctrl[i];local p2=ctrl[i+1];local p3=ctrl[math.min(#ctrl,i+2)]
 local steps=8
 for s=0,steps-1 do table.insert(pts,catmull(p0,p1,p2,p3,s/steps)) end
end
table.insert(pts,ctrl[#ctrl])

-- Remove legacy road geometry so only one road exists.
for _,obj in ipairs(low:GetChildren()) do
 if obj.Name:match("^ApproachRoad_") or obj.Name:match("^RoadEdge") or obj.Name:match("^CenterDash") or obj.Name:match("^RoadWear") then obj:Destroy() end
end

local roadHalfWidths={}
for i=1,#pts-1 do
 local a,b=pts[i],pts[i+1];local progress=(i-1)/math.max(1,#pts-2)
 local w,mat,col
 if progress<.48 then w=22;mat=Enum.Material.Asphalt;col=Color3.fromRGB(48,50,51)
 elseif progress<.70 then w=20;mat=Enum.Material.Asphalt;col=Color3.fromRGB(58,59,57)
 elseif progress<.86 then w=17;mat=Enum.Material.Pebble;col=Color3.fromRGB(105,100,88)
 else w=14;mat=Enum.Material.Ground;col=Color3.fromRGB(113,90,65) end
 segment(string.format("PrecisionRoad_%03d",i),a,b,w,1.2,mat,col,precision)
 local d=b-a;local flat=Vector3.new(d.X,0,d.Z);local side=flat.Magnitude>0 and Vector3.new(-flat.Z,0,flat.X).Unit or Vector3.xAxis
 segment("PrecisionShoulderL_"..i,a+side*(w*.61)-Vector3.new(0,.5,0),b+side*(w*.61)-Vector3.new(0,.5,0),2.4,.55,Enum.Material.Ground,Color3.fromRGB(93,85,66),precision)
 segment("PrecisionShoulderR_"..i,a-side*(w*.61)-Vector3.new(0,.5,0),b-side*(w*.61)-Vector3.new(0,.5,0),2.4,.55,Enum.Material.Ground,Color3.fromRGB(93,85,66),precision)
 if progress<.48 and i%4==1 then
  local mid=a:Lerp(b,.5)+Vector3.new(0,.66,0);local dir=(b-a).Unit
  segment("PrecisionDash_"..i,mid-dir*4,mid+dir*4,.28,.07,Enum.Material.SmoothPlastic,Color3.fromRGB(218,211,186),precision,0,false)
 end
 roadHalfWidths[i]=w*.5
end

local function pointSegmentDistance2D(p,a,b)
 local ap=Vector2.new(p.X-a.X,p.Z-a.Z);local ab=Vector2.new(b.X-a.X,b.Z-a.Z);local denom=ab:Dot(ab)
 local t=denom>0 and math.clamp(ap:Dot(ab)/denom,0,1) or 0
 local q=Vector2.new(a.X,a.Z)+ab*t
 return (Vector2.new(p.X,p.Z)-q).Magnitude
end
local function tooClose(pos,extra)
 for i=1,#pts-1 do if pointSegmentDistance2D(pos,pts[i],pts[i+1]) < (roadHalfWidths[i]+extra) then return true end end
 return false
end

-- Delete only roadside visual models/parts that violate road clearance.
local visual=root:FindFirstChild("VisualPolishV42")
if visual then
 for _,obj in ipairs(visual:GetChildren()) do
  local pos
  if obj:IsA("Model") then local ok,cf=pcall(function() return obj:GetBoundingBox() end);if ok then pos=cf.Position end
  elseif obj:IsA("BasePart") then pos=obj.Position end
  if pos and tooClose(pos,7.5) then obj:Destroy() end
 end
end

local function broadTree(pos,scale)
 local m=Instance.new("Model");m.Name="PrecisionTree";m.Parent=precision
 local bark=Color3.fromRGB(73,53,36);local leaf=Color3.fromRGB(46,86,44)
 mk("Trunk",Vector3.new(1.7*scale,9.5*scale,1.7*scale),CFrame.new(pos+Vector3.new(0,4.75*scale,0)),Enum.Material.Wood,bark,m)
 local function crown(off,s)
  local p=mk("Crown",Vector3.new(s*scale,s*.82*scale,s*scale),CFrame.new(pos+off*scale),Enum.Material.LeafyGrass,leaf,m,0,false);p.Shape=Enum.PartType.Ball
 end
 crown(Vector3.new(0,12,0),7.5);crown(Vector3.new(3.2,12.2,1),5.0);crown(Vector3.new(-3,11.8,-1.5),4.8);crown(Vector3.new(.7,14,-2),4.5)
end

-- Replant trees from the exact spline tangent: fixed offset, controlled alternating cadence.
for i=5,#pts-5,5 do
 local p=pts[i];local prev=pts[i-1];local nxt=pts[i+1];local d=nxt-prev;local flat=Vector3.new(d.X,0,d.Z);if flat.Magnitude>0 then
  local side=Vector3.new(-flat.Z,0,flat.X).Unit;local baseOffset=roadHalfWidths[i] or 10
  local left=p+side*(baseOffset+14+((i*7)%9));local right=p-side*(baseOffset+17+((i*5)%11))
  broadTree(left,0.72+((i%4)*.07));if i%2==0 then broadTree(right,0.68+((i%3)*.08)) end
 end
end

-- Utility poles and cables follow the same spline, always on one side and outside tree/road clearance.
local tops={}
for i=7,math.min(#pts-8,53),8 do
 local p=pts[i];local d=pts[i+1]-pts[i-1];local flat=Vector3.new(d.X,0,d.Z);if flat.Magnitude>0 then
  local side=Vector3.new(-flat.Z,0,flat.X).Unit;local baseOffset=roadHalfWidths[i] or 10;local q=p+side*(baseOffset+10)
  local pole=mk("PrecisionPole_"..i,Vector3.new(.9,15,.9),CFrame.new(q+Vector3.new(0,7.5,0)),Enum.Material.Wood,Color3.fromRGB(68,51,39),precision)
  local arm=mk("PrecisionArm_"..i,Vector3.new(6.5,.45,.45),CFrame.new(q+Vector3.new(0,14.2,0)),Enum.Material.Wood,Color3.fromRGB(68,51,39),precision)
  tops[#tops+1]=q+Vector3.new(0,14.5,0)
 end
end
for i=1,#tops-1 do beam("PrecisionWireA_"..i,tops[i]+Vector3.new(-2.1,0,0),tops[i+1]+Vector3.new(-2.1,0,0),.12,Enum.Material.SmoothPlastic,Color3.fromRGB(35,35,34),precision);beam("PrecisionWireB_"..i,tops[i]+Vector3.new(2.1,0,0),tops[i+1]+Vector3.new(2.1,0,0),.12,Enum.Material.SmoothPlastic,Color3.fromRGB(35,35,34),precision) end

root:SetAttribute("PrecisionRoadReady",true)
root:SetAttribute("RoadClearanceStuds",7.5)
root:SetAttribute("PrecisionVersion","4.4")
print("[ACC] Mountain v4.4 precision spline/alignment ready")