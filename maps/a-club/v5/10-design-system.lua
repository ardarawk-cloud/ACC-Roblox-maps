-- BBYA V5 PREMIUM DESIGN SYSTEM
-- Shared finish helpers. All geometry must be passed an existing coded zone folder.

local P={
 black=Color3.fromRGB(12,12,18), charcoal=Color3.fromRGB(24,24,31), graphite=Color3.fromRGB(38,38,46),
 pink=Color3.fromRGB(255,32,178), cyan=Color3.fromRGB(20,218,255), violet=Color3.fromRGB(145,62,255),
 gold=Color3.fromRGB(255,194,72), warm=Color3.fromRGB(255,176,94), cream=Color3.fromRGB(226,215,198),
 wood=Color3.fromRGB(104,70,48), stone=Color3.fromRGB(72,70,73), water=Color3.fromRGB(30,165,205),
 leaf=Color3.fromRGB(37,93,63), white=Color3.fromRGB(245,242,247), glass=Color3.fromRGB(125,190,210)
}

local function finish(zone,name,size,cf,color,material,transparency,collide)
 return part(zone,name,size,cf,color or P.charcoal,material or Enum.Material.SmoothPlastic,transparency or 0,collide~=false)
end

local function glow(zone,name,size,cf,color,brightness,range)
 local p=finish(zone,name,size,cf,color or P.pink,Enum.Material.Neon,0,false)
 p.CanQuery=false
 if brightness and brightness>0 then
  local l=Instance.new("PointLight")
  l.Name="BBYA Decorative Light";l.Color=p.Color;l.Brightness=brightness;l.Range=range or 14;l.Shadows=false;l.Parent=p
  l:SetAttribute("BBYADecorativeLight",true)
 end
 return p
end

local function zoneSign(zone,name,value,cf,size,color,face)
 return label(zone,name,value,cf,size,color or P.white,face or Enum.NormalId.Front)
end

local function glassRail(zone,name,center,size)
 return finish(zone,name,size,CFrame.new(center),P.glass,Enum.Material.Glass,.48,true)
end

local function sofa(zone,name,center,width,yaw,color)
 local rot=CFrame.Angles(0,math.rad(yaw or 0),0)
 local base=finish(zone,name.." BASE",Vector3.new(width,1.2,4),CFrame.new(center)*rot,color or P.graphite,Enum.Material.Fabric,0,true)
 finish(zone,name.." BACK",Vector3.new(width,3.2,1),CFrame.new(center+Vector3.new(0,1.7,1.5))*rot,color or P.graphite,Enum.Material.Fabric,0,true)
 finish(zone,name.." ARM L",Vector3.new(1,2,4),CFrame.new(center)*rot*CFrame.new(-width/2+.5,.7,0),color or P.graphite,Enum.Material.Fabric,0,true)
 finish(zone,name.." ARM R",Vector3.new(1,2,4),CFrame.new(center)*rot*CFrame.new(width/2-.5,.7,0),color or P.graphite,Enum.Material.Fabric,0,true)
 return base
end

local function lowTable(zone,name,center,size,color)
 local s=size or Vector3.new(6,.7,4)
 local top=finish(zone,name.." TOP",s,CFrame.new(center),color or P.black,Enum.Material.SmoothPlastic,0,true)
 for _,dx in ipairs({-s.X*.35,s.X*.35}) do
  finish(zone,name.." LEG "..tostring(dx),Vector3.new(.45,1.4,.45),CFrame.new(center+Vector3.new(dx,-1,0)),P.gold,Enum.Material.Metal,0,true)
 end
 return top
end

local function stool(zone,name,center,color)
 finish(zone,name.." SEAT",Vector3.new(2.2,.55,2.2),CFrame.new(center),color or P.graphite,Enum.Material.Fabric,0,true)
 finish(zone,name.." POST",Vector3.new(.4,2.4,.4),CFrame.new(center+Vector3.new(0,-1.45,0)),P.gold,Enum.Material.Metal,0,true)
 finish(zone,name.." FOOT",Vector3.new(1.6,.25,1.6),CFrame.new(center+Vector3.new(0,-2.6,0)),P.black,Enum.Material.Metal,0,true)
end

local function planter(zone,name,center,size)
 local s=size or Vector3.new(5,2.2,5)
 finish(zone,name.." BOX",s,CFrame.new(center),P.charcoal,Enum.Material.Slate,0,true)
 finish(zone,name.." SOIL",Vector3.new(s.X-.5,.25,s.Z-.5),CFrame.new(center+Vector3.new(0,s.Y/2+.08,0)),Color3.fromRGB(42,31,25),Enum.Material.Ground,0,false)
end

local function palm(zone,name,center,height)
 height=height or 13
 planter(zone,name.." PLANTER",center,Vector3.new(5,2,5))
 -- Roblox Cylinder length is its local X axis. Use X=height then rotate X onto world Y.
 local trunk=finish(zone,name.." TRUNK",Vector3.new(height,1.2,1.2),CFrame.new(center+Vector3.new(0,height/2+1,0))*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(105,70,45),Enum.Material.Wood,0,true)
 trunk.Shape=Enum.PartType.Cylinder
 local crown=center+Vector3.new(0,height+1,0)
 for i=0,5 do
  local a=math.rad(i*60)
  local leaf=finish(zone,name.." LEAF "..i,Vector3.new(7,.4,1.3),CFrame.new(crown)*CFrame.Angles(0,a,math.rad(-10))*CFrame.new(3,0,0),P.leaf,Enum.Material.SmoothPlastic,0,false)
  leaf.CanQuery=false
 end
end

local function barCounter(zone,name,center,size,yaw)
 local rot=CFrame.Angles(0,math.rad(yaw or 0),0)
 finish(zone,name.." BODY",Vector3.new(size.X,3.4,size.Z),CFrame.new(center)*rot,P.charcoal,Enum.Material.Slate,0,true)
 finish(zone,name.." TOP",Vector3.new(size.X+.5,.35,size.Z+.5),CFrame.new(center+Vector3.new(0,1.85,0))*rot,P.wood,Enum.Material.WoodPlanks,0,true)
 glow(zone,name.." UNDERGLOW",Vector3.new(size.X-.8,.18,.18),CFrame.new(center+Vector3.new(0,-.7,-size.Z/2-.11))*rot,P.warm,.35,8)
end

local function cabana(zone,name,center,yaw)
 local rot=CFrame.Angles(0,math.rad(yaw or 0),0)
 local w,d,h=13,10,7
 for _,x in ipairs({-w/2,w/2}) do for _,z in ipairs({-d/2,d/2}) do
  finish(zone,name.." POST",Vector3.new(.55,h,.55),CFrame.new(center)*rot*CFrame.new(x,h/2,z),P.wood,Enum.Material.Wood,0,true)
 end end
 finish(zone,name.." ROOF",Vector3.new(w+1,.45,d+1),CFrame.new(center)*rot*CFrame.new(0,h,0),P.charcoal,Enum.Material.WoodPlanks,0,true)
 sofa(zone,name.." DAYBED",center+Vector3.new(0,1.1,0),8,yaw,P.cream)
end

local function bollard(zone,name,center,color)
 finish(zone,name.." POST",Vector3.new(.65,2.6,.65),CFrame.new(center),P.black,Enum.Material.Metal,0,true)
 glow(zone,name.." CAP",Vector3.new(.8,.28,.8),CFrame.new(center+Vector3.new(0,1.45,0)),color or P.warm,.4,7)
end

workspace:SetAttribute("BBYAV5DesignSystem","1.0")
