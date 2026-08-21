-- ACC Mountain Social Adventure — Long Journey Rebuild v4.1
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local Terrain=Workspace.Terrain
local ROOT_NAME="ACC_MountainSocial"
local old=Workspace:FindFirstChild(ROOT_NAME);if old then old:Destroy() end
local root=Instance.new("Folder");root.Name=ROOT_NAME;root.Parent=Workspace
local folders={};for _,n in ipairs({"Checkpoints","Camps","PhotoSpots","Secrets","Decor","RouteAnchors","Lowlands"}) do local f=Instance.new("Folder");f.Name=n;f.Parent=root;folders[n]=f end
local function part(n,s,cf,m,c,p,tr,coll)
 local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Material=m or Enum.Material.Ground;if c then x.Color=c end;x.Transparency=tr or 0;x.CanCollide=coll~=false;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=p or root;return x
end
local function segment(n,a,b,w,h,mat,col,parent)
 local d=b-a;local dist=d.Magnitude;local mid=(a+b)/2;return part(n,Vector3.new(w,h,dist),CFrame.lookAt(mid,b),mat,col,parent or root,0,true)
end
local function checkpoint(i,name,pos)
 part(string.format("CheckpointPad_%02d",i),Vector3.new(i==12 and 42 or 30,2,i==12 and 42 or 30),CFrame.new(pos-Vector3.new(0,1.4,0)),i>=9 and Enum.Material.Rock or Enum.Material.Ground,i>=9 and Color3.fromRGB(94,94,91) or Color3.fromRGB(99,84,62),root,0,true)
 local cp=part(string.format("CP%02d_%s",i,name:gsub(" ","_")),Vector3.new(12,1,12),CFrame.new(pos+Vector3.new(0,.2,0)),Enum.Material.SmoothPlastic,Color3.fromRGB(226,173,70),folders.Checkpoints,.94,false)
 cp:SetAttribute("CheckpointIndex",i);cp:SetAttribute("CheckpointName",name);cp:SetAttribute("SaveReady",true)
end
local function hill(pos,radius,mat) Terrain:FillBall(pos-Vector3.new(0,radius-10,0),radius,mat) end
Lighting.ClockTime=6.3;Lighting.Brightness=2.2;Lighting.GlobalShadows=true;Lighting.EnvironmentDiffuseScale=.5;Lighting.EnvironmentSpecularScale=.4
Terrain:Clear()
-- Ground top is intentionally below all roads/fields so geometry remains visible.
Terrain:FillBlock(CFrame.new(0,-22,610),Vector3.new(3200,60,2100),Enum.Material.Grass)
local approach={Vector3.new(0,10.8,1050),Vector3.new(18,11.2,900),Vector3.new(-8,12,740),Vector3.new(34,13.5,580),Vector3.new(78,16,420),Vector3.new(45,22,260),Vector3.new(-18,31,105),Vector3.new(-55,44,-30)}
for i=1,#approach-1 do
 local a,b=approach[i],approach[i+1];local mat,col,w
 if i<=3 then mat=Enum.Material.Asphalt;col=Color3.fromRGB(47,50,52);w=32 elseif i<=5 then mat=Enum.Material.Asphalt;col=Color3.fromRGB(60,61,59);w=27 elseif i==6 then mat=Enum.Material.Pebble;col=Color3.fromRGB(111,104,90);w=23 else mat=Enum.Material.Ground;col=Color3.fromRGB(118,91,63);w=19 end
 segment(string.format("ApproachRoad_%02d",i),a,b,w,1.8,mat,col,folders.Lowlands)
 local d=b-a;local side=Vector3.new(-d.Z,0,d.X);if side.Magnitude>0 then side=side.Unit end
 segment(string.format("ShoulderL_%02d",i),a+side*(w*.65)-Vector3.new(0,.55,0),b+side*(w*.65)-Vector3.new(0,.55,0),5,1,Enum.Material.Ground,Color3.fromRGB(102,92,68),folders.Lowlands)
 segment(string.format("ShoulderR_%02d",i),a-side*(w*.65)-Vector3.new(0,.55,0),b-side*(w*.65)-Vector3.new(0,.55,0),5,1,Enum.Material.Ground,Color3.fromRGB(102,92,68),folders.Lowlands)
end
for i,p in ipairs({Vector3.new(62,16.8,365),Vector3.new(44,21.4,285),Vector3.new(19,27.8,200),Vector3.new(-7,33.6,120)}) do local q=part("RoadDamage_"..i,Vector3.new(8+i,0.3,13+i*2),CFrame.new(p)*CFrame.Angles(0,math.rad(12*i),0),i<3 and Enum.Material.Pebble or Enum.Material.Ground,Color3.fromRGB(112,96,76),folders.Lowlands,0,false);q.CanCollide=false end
local route={{"POS 1 - TRAILHEAD",Vector3.new(-55,44,-30)},{"POS 2 - HUTAN BAWAH",Vector3.new(-180,100,-270)},{"POS 3 - SUNGAI BATU",Vector3.new(20,160,-520)},{"POS 4 - HUTAN RAPAT",Vector3.new(185,225,-770)},{"CAMP TENGAH",Vector3.new(42,295,-1020)},{"POS 5 - TEBING",Vector3.new(-185,375,-1250)},{"POS 6 - KABUT",Vector3.new(-265,455,-1480)},{"HIGHLAND",Vector3.new(-78,535,-1705)},{"RIDGE",Vector3.new(165,615,-1910)},{"FALSE SUMMIT",Vector3.new(265,685,-2120)},{"POS 7 - FINAL APPROACH",Vector3.new(112,750,-2315)},{"SUMMIT ACC",Vector3.new(0,815,-2525)}}
for i,info in ipairs(route) do
 local pos=info[2];local radius=math.max(128,238-i*7);local mat=i<=3 and Enum.Material.Grass or (i<=7 and Enum.Material.Ground or Enum.Material.Rock);hill(pos,radius,mat)
 if i>=2 then local prev=route[i-1][2];local d=pos-prev;local side=Vector3.new(-d.Z,0,d.X);if side.Magnitude>0 then side=side.Unit end;hill(pos+side*(radius*.62)-Vector3.new(0,18,0),radius*.76,mat);hill(pos-side*(radius*.58)-Vector3.new(0,26,0),radius*.7,mat) end
end
for i,p in ipairs({Vector3.new(-560,170,-520),Vector3.new(590,205,-760),Vector3.new(-620,325,-1120),Vector3.new(620,385,-1390),Vector3.new(-540,515,-1760),Vector3.new(560,570,-1980)}) do hill(p,260-i*12,i<3 and Enum.Material.Grass or Enum.Material.Rock) end
for i=1,#route-1 do
 local a,b=route[i][2],route[i+1][2];local d=b-a;local side=Vector3.new(-d.Z,0,d.X);if side.Magnitude>0 then side=side.Unit end;local pts={a}
 for s=1,4 do local t=s/5;local base=a:Lerp(b,t);table.insert(pts,base+side*(math.sin((i*1.9+s)*1.1)*(i<5 and 22 or 14))) end;table.insert(pts,b)
 for j=1,#pts-1 do local mat=i<=3 and Enum.Material.Ground or (i<=7 and Enum.Material.Pebble or Enum.Material.Rock);local col=i<=3 and Color3.fromRGB(111,88,62) or (i<=7 and Color3.fromRGB(102,94,78) or Color3.fromRGB(92,93,90));segment(string.format("MountainTrail_%02d_%02d",i,j),pts[j],pts[j+1],i<4 and 17 or (i<9 and 14 or 12),2.2,mat,col,root) end
end
for i,info in ipairs(route) do checkpoint(i,info[1],info[2]) end
local spawn=Instance.new("SpawnLocation");spawn.Name="MountainSpawn";spawn.Anchored=true;spawn.Size=Vector3.new(18,1,18);spawn.CFrame=CFrame.new(0,12.8,1050);spawn.Transparency=1;spawn.CanCollide=true;spawn.Neutral=true;spawn.Duration=0;spawn.Parent=root
part("VillageSpawnGround",Vector3.new(90,2,74),CFrame.new(0,10.1,1050),Enum.Material.Grass,Color3.fromRGB(87,119,67),folders.Lowlands,0,true)
Terrain:FillBlock(CFrame.new(route[3][2]-Vector3.new(0,6,0))*CFrame.Angles(0,math.rad(24),0),Vector3.new(190,7,32),Enum.Material.Water)
for _,idx in ipairs({5,8}) do local pos=route[idx][2];local camp=Instance.new("Model");camp.Name="Camp_"..idx;camp.Parent=folders.Camps;local fb=part("Campfire",Vector3.new(5,1,5),CFrame.new(pos+Vector3.new(13,1.5,9)),Enum.Material.Slate,Color3.fromRGB(71,69,65),camp,0,true);local fire=Instance.new("Fire");fire.Size=4;fire.Heat=6;fire.Parent=fb end
local summit=route[12][2];local monument=part("ACC_SummitMonument",Vector3.new(8,22,8),CFrame.new(summit+Vector3.new(0,11,-13)),Enum.Material.Granite,Color3.fromRGB(83,84,82),root,0,true);monument:SetAttribute("SummitTriggerReady",true)
root:SetAttribute("Project","Mountain Social Adventure");root:SetAttribute("MasterPlanLocked",true);root:SetAttribute("JourneyFlow","Village>RiceFields>Foothill>Forest>River>Camp>Cliff>Fog>Highland>Ridge>FalseSummit>Summit");root:SetAttribute("CheckpointSaveReady",true);root:SetAttribute("MobileFriendly",true);root:SetAttribute("WorldRebuild","4.1");root:SetAttribute("BuildVersion","4.1.0-visible-lowlands")
print("[ACC] Mountain v4.1 visible lowlands generated")