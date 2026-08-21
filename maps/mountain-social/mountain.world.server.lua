-- ACC Mountain Social Adventure — Scenic Long Journey v4.2
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local Terrain=Workspace.Terrain
local ROOT_NAME="ACC_MountainSocial"
local old=Workspace:FindFirstChild(ROOT_NAME);if old then old:Destroy() end
local root=Instance.new("Folder");root.Name=ROOT_NAME;root.Parent=Workspace
local folders={};for _,n in ipairs({"Checkpoints","Camps","PhotoSpots","Secrets","Decor","RouteAnchors","Lowlands"}) do local f=Instance.new("Folder");f.Name=n;f.Parent=root;folders[n]=f end

local function part(n,s,cf,m,c,p,tr,coll)
 local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Material=m or Enum.Material.Ground
 if c then x.Color=c end;x.Transparency=tr or 0;x.CanCollide=coll~=false;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=p or root;return x
end
local function segment(n,a,b,w,h,mat,col,parent,tr,coll)
 local d=b-a;if d.Magnitude<.1 then return end
 return part(n,Vector3.new(w,h,d.Magnitude),CFrame.lookAt((a+b)/2,b),mat,col,parent or root,tr or 0,coll~=false)
end
local function checkpoint(i,name,pos)
 part(string.format("CheckpointPad_%02d",i),Vector3.new(i==12 and 42 or 30,2,i==12 and 42 or 30),CFrame.new(pos-Vector3.new(0,1.4,0)),i>=9 and Enum.Material.Rock or Enum.Material.Ground,i>=9 and Color3.fromRGB(94,94,91) or Color3.fromRGB(99,84,62),root,0,true)
 local cp=part(string.format("CP%02d_%s",i,name:gsub(" ","_")),Vector3.new(12,1,12),CFrame.new(pos+Vector3.new(0,.2,0)),Enum.Material.SmoothPlastic,Color3.fromRGB(226,173,70),folders.Checkpoints,.96,false)
 cp:SetAttribute("CheckpointIndex",i);cp:SetAttribute("CheckpointName",name);cp:SetAttribute("SaveReady",true)
end
local function hill(pos,radius,mat) Terrain:FillBall(pos-Vector3.new(0,radius-10,0),radius,mat) end
local function shallowMound(x,z,r,top,mat) Terrain:FillBall(Vector3.new(x,top-r,z),r,mat or Enum.Material.Grass) end

Lighting.ClockTime=6.25;Lighting.Brightness=2.15;Lighting.GlobalShadows=true;Lighting.EnvironmentDiffuseScale=.5;Lighting.EnvironmentSpecularScale=.4
Terrain:Clear()
Terrain:FillBlock(CFrame.new(0,-22,560),Vector3.new(3300,60,2250),Enum.Material.Grass)
-- Break the flat horizon with broad low hills. Their centers sit far below ground, leaving only natural crowns visible.
for _,m in ipairs({{-420,1030,240,18},{410,970,280,20},{-500,720,310,25},{500,610,320,28},{-430,350,290,35},{430,260,300,42},{-520,40,340,55},{520,-80,360,70}}) do shallowMound(m[1],m[2],m[3],m[4],Enum.Material.Grass) end

-- Curving village-to-trailhead road. Short segments remove the giant black trapezoid look.
local approach={
 Vector3.new(0,10.8,1060),Vector3.new(5,10.9,1015),Vector3.new(13,11.0,970),Vector3.new(19,11.2,925),
 Vector3.new(18,11.4,880),Vector3.new(12,11.7,835),Vector3.new(3,12.0,790),Vector3.new(-5,12.4,745),
 Vector3.new(-7,12.8,700),Vector3.new(0,13.2,655),Vector3.new(15,13.8,610),Vector3.new(31,14.5,565),
 Vector3.new(46,15.2,520),Vector3.new(60,16.0,475),Vector3.new(70,17.0,430),Vector3.new(74,18.4,385),
 Vector3.new(70,20.0,340),Vector3.new(60,22.0,295),Vector3.new(45,24.5,250),Vector3.new(28,27.5,205),
 Vector3.new(10,30.5,160),Vector3.new(-8,34.0,115),Vector3.new(-27,38.0,70),Vector3.new(-43,41.5,20),Vector3.new(-55,44,-30)
}
for i=1,#approach-1 do
 local a,b=approach[i],approach[i+1]
 local progress=(i-1)/(#approach-2);local mat,col,w
 if progress<.45 then mat=Enum.Material.Asphalt;col=Color3.fromRGB(48,51,52);w=23
 elseif progress<.68 then mat=Enum.Material.Asphalt;col=Color3.fromRGB(60,61,59);w=21
 elseif progress<.84 then mat=Enum.Material.Pebble;col=Color3.fromRGB(107,101,88);w=18
 else mat=Enum.Material.Ground;col=Color3.fromRGB(116,91,64);w=15 end
 segment(string.format("ApproachRoad_%02d",i),a,b,w,1.45,mat,col,folders.Lowlands)
 local d=b-a;local side=Vector3.new(-d.Z,0,d.X).Unit
 segment(string.format("RoadEdgeL_%02d",i),a+side*(w*.59)-Vector3.new(0,.55,0),b+side*(w*.59)-Vector3.new(0,.55,0),2.2,.65,Enum.Material.Ground,Color3.fromRGB(95,86,66),folders.Lowlands)
 segment(string.format("RoadEdgeR_%02d",i),a-side*(w*.59)-Vector3.new(0,.55,0),b-side*(w*.59)-Vector3.new(0,.55,0),2.2,.65,Enum.Material.Ground,Color3.fromRGB(95,86,66),folders.Lowlands)
 if progress<.5 and i%2==1 then segment("CenterDash_"..i,a+Vector3.new(0,.77,0),b+Vector3.new(0,.77,0),.34,.08,Enum.Material.SmoothPlastic,Color3.fromRGB(218,210,183),folders.Lowlands,0,false) end
end
-- Cracked/dirty public road transition.
for i,p in ipairs({Vector3.new(72,18.9,365),Vector3.new(66,21.0,320),Vector3.new(51,24.0,260),Vector3.new(31,27.4,210),Vector3.new(8,32.5,135)}) do
 local q=part("RoadWear_"..i,Vector3.new(3+i*.8,.18,7+i),CFrame.new(p)*CFrame.Angles(0,math.rad(11*i),0),i<3 and Enum.Material.Pebble or Enum.Material.Ground,Color3.fromRGB(111,96,76),folders.Lowlands,0,false);q.CanCollide=false
end

-- Long mountain progression.
local route={
 {"POS 1 - TRAILHEAD",Vector3.new(-55,44,-30)},
 {"POS 2 - HUTAN BAWAH",Vector3.new(-180,100,-270)},
 {"POS 3 - SUNGAI BATU",Vector3.new(20,160,-520)},
 {"POS 4 - HUTAN RAPAT",Vector3.new(185,225,-770)},
 {"CAMP TENGAH",Vector3.new(42,295,-1020)},
 {"POS 5 - TEBING",Vector3.new(-185,375,-1250)},
 {"POS 6 - KABUT",Vector3.new(-265,455,-1480)},
 {"HIGHLAND",Vector3.new(-78,535,-1705)},
 {"RIDGE",Vector3.new(165,615,-1910)},
 {"FALSE SUMMIT",Vector3.new(265,685,-2120)},
 {"POS 7 - FINAL APPROACH",Vector3.new(112,750,-2315)},
 {"SUMMIT ACC",Vector3.new(0,815,-2525)}
}
for i,info in ipairs(route) do
 local pos=info[2];local radius=math.max(128,238-i*7);local mat=i<=3 and Enum.Material.Grass or (i<=7 and Enum.Material.Ground or Enum.Material.Rock);hill(pos,radius,mat)
 if i>=2 then local prev=route[i-1][2];local d=pos-prev;local side=Vector3.new(-d.Z,0,d.X).Unit;hill(pos+side*(radius*.62)-Vector3.new(0,18,0),radius*.76,mat);hill(pos-side*(radius*.58)-Vector3.new(0,26,0),radius*.7,mat) end
end
for i,p in ipairs({Vector3.new(-560,170,-520),Vector3.new(590,205,-760),Vector3.new(-620,325,-1120),Vector3.new(620,385,-1390),Vector3.new(-540,515,-1760),Vector3.new(560,570,-1980)}) do hill(p,260-i*12,i<3 and Enum.Material.Grass or Enum.Material.Rock) end
-- Additional foothill masses create a visible mountain silhouette from the village.
for _,p in ipairs({Vector3.new(-280,95,-250),Vector3.new(260,120,-360),Vector3.new(-330,150,-520),Vector3.new(330,185,-650)}) do hill(p,210,Enum.Material.Grass) end

for i=1,#route-1 do
 local a,b=route[i][2],route[i+1][2];local d=b-a;local side=Vector3.new(-d.Z,0,d.X).Unit;local pts={a}
 for s=1,5 do local t=s/6;local base=a:Lerp(b,t);table.insert(pts,base+side*(math.sin((i*1.9+s)*1.1)*(i<5 and 22 or 14))) end;table.insert(pts,b)
 for j=1,#pts-1 do local mat=i<=3 and Enum.Material.Ground or (i<=7 and Enum.Material.Pebble or Enum.Material.Rock);local col=i<=3 and Color3.fromRGB(111,88,62) or (i<=7 and Color3.fromRGB(102,94,78) or Color3.fromRGB(92,93,90));segment(string.format("MountainTrail_%02d_%02d",i,j),pts[j],pts[j+1],i<4 and 14 or (i<9 and 12 or 10),1.7,mat,col,root) end
end
for i,info in ipairs(route) do checkpoint(i,info[1],info[2]) end

local spawn=Instance.new("SpawnLocation");spawn.Name="MountainSpawn";spawn.Anchored=true;spawn.Size=Vector3.new(14,1,14);spawn.CFrame=CFrame.lookAt(Vector3.new(0,12.3,1060),Vector3.new(5,12.3,1015));spawn.Transparency=1;spawn.CanCollide=true;spawn.Neutral=true;spawn.Duration=0;spawn.Parent=root
part("VillageSpawnGround",Vector3.new(55,1.5,48),CFrame.new(0,9.8,1060),Enum.Material.Grass,Color3.fromRGB(82,112,65),folders.Lowlands,0,true)
Terrain:FillBlock(CFrame.new(route[3][2]-Vector3.new(0,6,0))*CFrame.Angles(0,math.rad(24),0),Vector3.new(190,7,32),Enum.Material.Water)
for _,idx in ipairs({5,8}) do local pos=route[idx][2];local camp=Instance.new("Model");camp.Name="Camp_"..idx;camp.Parent=folders.Camps;local fb=part("Campfire",Vector3.new(5,1,5),CFrame.new(pos+Vector3.new(13,1.5,9)),Enum.Material.Slate,Color3.fromRGB(71,69,65),camp,0,true);local fire=Instance.new("Fire");fire.Size=4;fire.Heat=6;fire.Parent=fb end
local summit=route[12][2];local monument=part("ACC_SummitMonument",Vector3.new(8,22,8),CFrame.new(summit+Vector3.new(0,11,-13)),Enum.Material.Granite,Color3.fromRGB(83,84,82),root,0,true);monument:SetAttribute("SummitTriggerReady",true)
root:SetAttribute("Project","Mountain Social Adventure");root:SetAttribute("MasterPlanLocked",true);root:SetAttribute("JourneyFlow","Village>RiceFields>Foothill>Forest>River>Camp>Cliff>Fog>Highland>Ridge>FalseSummit>Summit");root:SetAttribute("CheckpointSaveReady",true);root:SetAttribute("MobileFriendly",true);root:SetAttribute("WorldRebuild","4.2");root:SetAttribute("CurvedRoadReady",true);root:SetAttribute("BuildVersion","4.2.0-scenic-lowlands")
print("[ACC] Mountain v4.2 scenic lowlands generated")