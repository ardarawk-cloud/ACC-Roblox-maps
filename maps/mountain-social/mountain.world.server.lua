-- ACC Mountain Social Adventure — Long Journey Rebuild v4.0
-- Canon flow: Desa -> Sawah -> Jalan Kaki Gunung -> Hutan -> Sungai -> Camp -> Tebing -> Kabut -> Highland -> Ridge -> False Summit -> Puncak.
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local Terrain=Workspace.Terrain

local ROOT_NAME="ACC_MountainSocial"
local old=Workspace:FindFirstChild(ROOT_NAME);if old then old:Destroy() end
local root=Instance.new("Folder");root.Name=ROOT_NAME;root.Parent=Workspace
local folders={}
for _,n in ipairs({"Checkpoints","Camps","PhotoSpots","Secrets","Decor","RouteAnchors","Lowlands"}) do local f=Instance.new("Folder");f.Name=n;f.Parent=root;folders[n]=f end

local function part(n,s,cf,m,c,p,tr,coll)
 local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Material=m or Enum.Material.Ground
 if c then x.Color=c end;x.Transparency=tr or 0;x.CanCollide=coll~=false;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=p or root;return x
end
local function segment(n,a,b,w,h,mat,col,parent)
 local d=b-a;local dist=d.Magnitude;local mid=(a+b)/2
 return part(n,Vector3.new(w,h,dist),CFrame.lookAt(mid,b),mat,col,parent or root,0,true)
end
local function checkpoint(i,name,pos)
 local pad=part(string.format("CheckpointPad_%02d",i),Vector3.new(i==12 and 40 or 28,2,i==12 and 40 or 28),CFrame.new(pos-Vector3.new(0,2,0)),i>=9 and Enum.Material.Rock or Enum.Material.Ground,i>=9 and Color3.fromRGB(94,94,91) or Color3.fromRGB(99,84,62),root,0,true)
 local cp=part(string.format("CP%02d_%s",i,name:gsub(" ","_")),Vector3.new(12,1,12),CFrame.new(pos),Enum.Material.SmoothPlastic,Color3.fromRGB(226,173,70),folders.Checkpoints,.94,false)
 cp:SetAttribute("CheckpointIndex",i);cp:SetAttribute("CheckpointName",name);cp:SetAttribute("SaveReady",true);return pad,cp
end
local function terrainHill(pos,radius,material)
 Terrain:FillBall(pos-Vector3.new(0,radius-8,0),radius,material)
end

Lighting.ClockTime=6.35;Lighting.Brightness=2.2;Lighting.GlobalShadows=true;Lighting.EnvironmentDiffuseScale=.45;Lighting.EnvironmentSpecularScale=.35
Terrain:Clear()
-- Wide lowland foundation. The player starts in inhabited countryside, not on raw mountain terrain.
Terrain:FillBlock(CFrame.new(0,-18,610),Vector3.new(3000,60,1900),Enum.Material.Grass)

-- Village/road backbone. Long approach before the actual trail begins.
local approach={
 Vector3.new(0,12,1050),
 Vector3.new(18,12,900),
 Vector3.new(-8,13,740),
 Vector3.new(34,15,580),
 Vector3.new(78,18,420),
 Vector3.new(45,24,260),
 Vector3.new(-18,34,105),
 Vector3.new(-55,48,-30)
}
for i=1,#approach-1 do
 local a,b=approach[i],approach[i+1]
 local mat,col,w
 if i<=3 then mat=Enum.Material.Concrete;col=Color3.fromRGB(58,61,62);w=30
 elseif i<=5 then mat=Enum.Material.Concrete;col=Color3.fromRGB(67,68,65);w=25
 elseif i==6 then mat=Enum.Material.Gravel;col=Color3.fromRGB(106,101,88);w=22
 else mat=Enum.Material.Ground;col=Color3.fromRGB(116,91,64);w=18 end
 segment(string.format("ApproachRoad_%02d",i),a-Vector3.new(0,1,0),b-Vector3.new(0,1,0),w,2,mat,col,folders.Lowlands)
 -- shoulders keep the road readable while transitioning from public road to trailhead.
 local d=b-a;local side=Vector3.new(-d.Z,0,d.X);if side.Magnitude>0 then side=side.Unit end
 segment(string.format("ShoulderL_%02d",i),a+side*(w*.62)-Vector3.new(0,1.6,0),b+side*(w*.62)-Vector3.new(0,1.6,0),5,1.2,i<6 and Enum.Material.Grass or Enum.Material.Ground,i<6 and Color3.fromRGB(83,112,64) or Color3.fromRGB(107,91,68),folders.Lowlands)
 segment(string.format("ShoulderR_%02d",i),a-side*(w*.62)-Vector3.new(0,1.6,0),b-side*(w*.62)-Vector3.new(0,1.6,0),5,1.2,i<6 and Enum.Material.Grass or Enum.Material.Ground,i<6 and Color3.fromRGB(83,112,64) or Color3.fromRGB(107,91,68),folders.Lowlands)
end
-- Broken asphalt/gravel patches visually announce the transition near the mountain.
for i,p in ipairs({Vector3.new(54,20,355),Vector3.new(38,24,285),Vector3.new(16,29,205),Vector3.new(-5,34,125)}) do
 local q=part("RoadDamage_"..i,Vector3.new(7+i,0.35,11+i*2),CFrame.new(p)*CFrame.Angles(0,math.rad(13*i),0),i<3 and Enum.Material.Gravel or Enum.Material.Ground,Color3.fromRGB(112,96,76),folders.Lowlands,0,false);q.CanCollide=false
end

-- Long mountain progression. Twelve save checkpoints; summit is deliberately far from spawn.
local route={
 {"POS 1 - TRAILHEAD",Vector3.new(-55,48,-30)},
 {"POS 2 - HUTAN BAWAH",Vector3.new(-180,105,-270)},
 {"POS 3 - SUNGAI BATU",Vector3.new(20,165,-520)},
 {"POS 4 - HUTAN RAPAT",Vector3.new(185,230,-770)},
 {"CAMP TENGAH",Vector3.new(42,300,-1020)},
 {"POS 5 - TEBING",Vector3.new(-185,380,-1250)},
 {"POS 6 - KABUT",Vector3.new(-265,460,-1480)},
 {"HIGHLAND",Vector3.new(-78,540,-1705)},
 {"RIDGE",Vector3.new(165,620,-1910)},
 {"FALSE SUMMIT",Vector3.new(265,690,-2120)},
 {"POS 7 - FINAL APPROACH",Vector3.new(112,755,-2315)},
 {"SUMMIT ACC",Vector3.new(0,820,-2525)}
}

-- Build a continuous mountain mass from many overlapping terrain forms, not one giant boulder.
for i,info in ipairs(route) do
 local pos=info[2];local radius=math.max(125,235-i*7);local mat=i<=4 and Enum.Material.Grass or (i<=8 and Enum.Material.Ground or Enum.Material.Rock)
 terrainHill(pos,radius,mat)
 if i>=2 then
  local prev=route[i-1][2];local d=pos-prev;local side=Vector3.new(-d.Z,0,d.X);if side.Magnitude>0 then side=side.Unit end
  terrainHill(pos+side*(radius*.62)-Vector3.new(0,18,0),radius*.78,mat)
  terrainHill(pos-side*(radius*.58)-Vector3.new(0,28,0),radius*.72,mat)
 end
end
-- Distant side ridges make the mountain read as a landscape rather than a narrow obby tower.
for i,p in ipairs({Vector3.new(-560,175,-520),Vector3.new(590,210,-760),Vector3.new(-620,330,-1120),Vector3.new(620,390,-1390),Vector3.new(-540,520,-1760),Vector3.new(560,575,-1980)}) do
 terrainHill(p,260-i*12,i<3 and Enum.Material.Grass or Enum.Material.Rock)
end

-- Primary hiking path. Wider and gentler low down, narrower/rockier at altitude.
for i=1,#route-1 do
 local a,b=route[i][2],route[i+1][2];local d=b-a;local side=Vector3.new(-d.Z,0,d.X);if side.Magnitude>0 then side=side.Unit end
 local pts={a}
 for s=1,4 do local t=s/5;local base=a:Lerp(b,t);local sway=math.sin((i*1.9+s)*1.1)*(i<5 and 22 or 14);table.insert(pts,base+side*sway) end
 table.insert(pts,b)
 for j=1,#pts-1 do
  local mat=i<=3 and Enum.Material.Ground or (i<=7 and Enum.Material.Gravel or Enum.Material.Rock)
  local col=i<=3 and Color3.fromRGB(111,88,62) or (i<=7 and Color3.fromRGB(102,94,78) or Color3.fromRGB(92,93,90))
  segment(string.format("MountainTrail_%02d_%02d",i,j),pts[j]-Vector3.new(0,1.7,0),pts[j+1]-Vector3.new(0,1.7,0),i<4 and 17 or (i<9 and 14 or 12),2.3,mat,col,root)
 end
end
for i,info in ipairs(route) do checkpoint(i,info[1],info[2]) end

-- Spawn stays in the village, far before checkpoint 1.
local spawn=Instance.new("SpawnLocation");spawn.Name="MountainSpawn";spawn.Anchored=true;spawn.Size=Vector3.new(18,1,18);spawn.CFrame=CFrame.new(approach[1]+Vector3.new(0,1,0));spawn.Transparency=1;spawn.CanCollide=true;spawn.Neutral=true;spawn.Duration=0;spawn.Parent=root
local startPad=part("VillageSpawnGround",Vector3.new(70,2,60),CFrame.new(approach[1]-Vector3.new(0,2,0)),Enum.Material.Grass,Color3.fromRGB(87,119,67),folders.Lowlands,0,true)

-- Core landmarks: river, camps and summit marker. Detailed decoration is added by visual/basecamp modules.
Terrain:FillBlock(CFrame.new(route[3][2]-Vector3.new(0,7,0))*CFrame.Angles(0,math.rad(24),0),Vector3.new(190,7,32),Enum.Material.Water)
for _,idx in ipairs({5,8}) do local pos=route[idx][2];local camp=Instance.new("Model");camp.Name="Camp_"..idx;camp.Parent=folders.Camps;local fireBase=part("Campfire",Vector3.new(5,1,5),CFrame.new(pos+Vector3.new(13,1,9)),Enum.Material.Slate,Color3.fromRGB(71,69,65),camp,0,true);local fire=Instance.new("Fire");fire.Size=4;fire.Heat=6;fire.Parent=fireBase end
local summit=route[12][2];local monument=part("ACC_SummitMonument",Vector3.new(8,22,8),CFrame.new(summit+Vector3.new(0,10,-13)),Enum.Material.Granite,Color3.fromRGB(83,84,82),root,0,true);monument:SetAttribute("SummitTriggerReady",true)
local secret=part("SecretSummit",Vector3.new(8,1,8),CFrame.new(-360,735,-2370),Enum.Material.SmoothPlastic,Color3.fromRGB(160,132,78),folders.Secrets,.96,false);secret:SetAttribute("SecretSummit",true);secret:SetAttribute("DiscoveryId","SECRET_TRAIL_01")

root:SetAttribute("Project","Mountain Social Adventure")
root:SetAttribute("MasterPlanLocked",true)
root:SetAttribute("JourneyFlow","Village>RiceFields>Foothill>Forest>River>Camp>Cliff>Fog>Highland>Ridge>FalseSummit>Summit")
root:SetAttribute("CheckpointSaveReady",true)
root:SetAttribute("MobileFriendly",true)
root:SetAttribute("WorldRebuild","4.0")
root:SetAttribute("BuildVersion","4.0.0-long-journey")
print("[ACC] Mountain v4 long-journey world generated")
