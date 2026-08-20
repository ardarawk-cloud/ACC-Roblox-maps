local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local ROOT = "BBYAVATAR_SHOWROOM"
local old = Workspace:FindFirstChild(ROOT); if old then old:Destroy() end
local oldRemote = ReplicatedStorage:FindFirstChild("BBYAVATAR"); if oldRemote then oldRemote:Destroy() end
for _,n in ipairs({"BBYAVATAR_Color","BBYAVATAR_Atmosphere"}) do local x=Lighting:FindFirstChild(n); if x then x:Destroy() end end
Lighting.ClockTime=18.1; Lighting.Brightness=2.4; Lighting.Ambient=Color3.fromRGB(78,82,96); Lighting.OutdoorAmbient=Color3.fromRGB(108,110,128)
local cc=Instance.new("ColorCorrectionEffect"); cc.Name="BBYAVATAR_Color"; cc.Contrast=.1; cc.Saturation=-.04; cc.Parent=Lighting
local atm=Instance.new("Atmosphere"); atm.Name="BBYAVATAR_Atmosphere"; atm.Density=.14; atm.Haze=.8; atm.Parent=Lighting

local function part(parent,name,size,cf,mat,col)
 local p=Instance.new("Part"); p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.Material=mat or Enum.Material.SmoothPlastic;p.Color=col or Color3.fromRGB(32,34,42);p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function sign(p,text,face)
 local g=Instance.new("SurfaceGui");g.Face=face or Enum.NormalId.Front;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=34;g.Parent=p
 local l=Instance.new("TextLabel");l.Size=UDim2.fromScale(1,1);l.BackgroundTransparency=1;l.Font=Enum.Font.GothamBlack;l.Text=text;l.TextColor3=Color3.fromRGB(245,245,248);l.TextScaled=true;l.TextWrapped=true;l.Parent=g
end
local function prompt(p,action,obj,category,remote)
 local q=Instance.new("ProximityPrompt");q.ActionText=action;q.ObjectText=obj;q.HoldDuration=0;q.MaxActivationDistance=12;q.RequiresLineOfSight=false;q.Parent=p;q.Triggered:Connect(function(plr) remote:FireClient(plr,category) end)
end
local root=Instance.new("Folder");root.Name=ROOT;root.Parent=Workspace;root:SetAttribute("BuildVersion","3.0");root:SetAttribute("Experience","BBYAVATAR");root:SetAttribute("UXRevision","MANNEQUIN_SOCIAL_HUB")
local rem=Instance.new("Folder");rem.Name="BBYAVATAR";rem.Parent=ReplicatedStorage
local open=Instance.new("RemoteEvent");open.Name="OpenCatalog";open.Parent=rem

-- architectural shell
part(root,"Floor",Vector3.new(196,1,156),CFrame.new(0,0,0),Enum.Material.Concrete,Color3.fromRGB(23,24,29))
part(root,"BackWall",Vector3.new(196,34,1),CFrame.new(0,17,-77.5),nil,Color3.fromRGB(16,17,22))
part(root,"LeftWall",Vector3.new(1,34,156),CFrame.new(-97.5,17,0),nil,Color3.fromRGB(16,17,22))
part(root,"RightWall",Vector3.new(1,34,156),CFrame.new(97.5,17,0),nil,Color3.fromRGB(16,17,22))
local header=part(root,"BrandHeader",Vector3.new(54,7,2),CFrame.new(0,16,69),Enum.Material.Metal,Color3.fromRGB(36,39,50));sign(header,"BBYAVATAR  •  FIND YOUR NEXT LOOK")
local spawn=Instance.new("SpawnLocation");spawn.Name="Spawn";spawn.Size=Vector3.new(10,1,10);spawn.CFrame=CFrame.new(0,1.5,63)*CFrame.Angles(0,math.rad(180),0);spawn.Anchored=true;spawn.Neutral=true;spawn.Transparency=.75;spawn.Parent=root
local runway=part(root,"Runway",Vector3.new(30,1,112),CFrame.new(0,.7,4),Enum.Material.SmoothPlastic,Color3.fromRGB(43,46,57))
for _,x in ipairs({-15,15}) do part(root,"RunwayGlow",Vector3.new(.3,.08,112),CFrame.new(x,.57,4),Enum.Material.Neon,Color3.fromRGB(105,116,165)) end

-- central hero / featured area
local hero=part(root,"HeroStage",Vector3.new(34,1.4,18),CFrame.new(0,1,-52),Enum.Material.Marble,Color3.fromRGB(225,225,230));prompt(hero,"DISCOVER","FEATURED LOOKS","FEATURED",open)
local hs=part(root,"HeroSign",Vector3.new(42,8,1),CFrame.new(0,6,-61),nil,Color3.fromRGB(75,66,110));sign(hs,"FEATURED LOOKS\nCURATED DAILY")

-- category boutiques with mannequin-like R15 preview silhouettes
local categories={{"TRENDING",-66,38,Color3.fromRGB(101,72,170)},{"NEW DROPS",66,38,Color3.fromRGB(45,112,170)},{"STREETWEAR",-66,8,Color3.fromRGB(135,77,55)},{"CYBER",66,8,Color3.fromRGB(39,128,136)},{"LUXURY",-66,-22,Color3.fromRGB(142,112,49)},{"CUTE",66,-22,Color3.fromRGB(154,79,130)},{"BALI",-66,-52,Color3.fromRGB(116,84,52)},{"CREATORS",66,-52,Color3.fromRGB(61,105,75)}}
local function mannequin(parent,x,z,idx)
 local m=Instance.new("Model");m.Name="LookPreview_"..idx;m.Parent=parent
 local col=Color3.fromRGB(205,207,216)
 local torso=part(m,"Torso",Vector3.new(2.6,3.4,1.4),CFrame.new(x,4,z),Enum.Material.SmoothPlastic,col)
 part(m,"Head",Vector3.new(2,2,2),CFrame.new(x,6.7,z),Enum.Material.SmoothPlastic,col).Shape=Enum.PartType.Ball
 part(m,"LeftArm",Vector3.new(.9,3.2,.9),CFrame.new(x-1.75,4,z),nil,col);part(m,"RightArm",Vector3.new(.9,3.2,.9),CFrame.new(x+1.75,4,z),nil,col)
 part(m,"LeftLeg",Vector3.new(1,3.4,1),CFrame.new(x-.7,1.2,z),nil,col);part(m,"RightLeg",Vector3.new(1,3.4,1),CFrame.new(x+.7,1.2,z),nil,col)
 local halo=Instance.new("PointLight");halo.Color=Color3.fromRGB(180,190,255);halo.Brightness=.5;halo.Range=7;halo.Parent=torso
end
for i,c in ipairs(categories) do
 local model=Instance.new("Model");model.Name="Boutique_"..c[1];model.Parent=root
 local base=part(model,"Base",Vector3.new(34,1,22),CFrame.new(c[2],.7,c[3]),nil,Color3.fromRGB(30,32,39));prompt(base,"BROWSE",c[1],c[1],open)
 local wall=part(model,"Header",Vector3.new(34,7,1),CFrame.new(c[2],5,c[3]-10.5),nil,c[4]);sign(wall,string.format("%02d  %s",i,c[1]))
 for s=-1,1 do local px=c[2]+s*9;part(model,"Pod",Vector3.new(6,1,6),CFrame.new(px,1,c[3]+3),Enum.Material.Marble,Color3.fromRGB(218,218,223));mannequin(model,px,c[3]+3,tostring(s+2)) end
end

-- social utility area: avatar studio, photo studio, community board
local studio=part(root,"AvatarStudio",Vector3.new(24,1,16),CFrame.new(-34,.7,58),nil,Color3.fromRGB(50,58,82));prompt(studio,"CREATE LOOK","AVATAR STUDIO","STUDIO",open)
local ss=part(root,"AvatarStudioSign",Vector3.new(24,6,1),CFrame.new(-34,4.5,50.5),nil,Color3.fromRGB(55,67,105));sign(ss,"AVATAR STUDIO")
local photo=part(root,"PhotoStudio",Vector3.new(24,1,16),CFrame.new(34,.7,58),nil,Color3.fromRGB(73,51,70));prompt(photo,"OPEN","PHOTO STUDIO","PHOTO",open)
local ps=part(root,"PhotoStudioSign",Vector3.new(24,6,1),CFrame.new(34,4.5,50.5),nil,Color3.fromRGB(95,64,91));sign(ps,"PHOTO STUDIO")
local community=part(root,"CommunityBoard",Vector3.new(28,9,1),CFrame.new(0,6,42),nil,Color3.fromRGB(42,48,58));sign(community,"COMMUNITY LOOKS\nCOMING NEXT • CREATOR SPOTLIGHT • SAVED OUTFITS")

-- seating/social dwell points
for _,x in ipairs({-24,24}) do for _,z in ipairs({28,-36}) do local bench=part(root,"SocialBench",Vector3.new(10,1.2,3),CFrame.new(x,1.2,z),Enum.Material.Wood,Color3.fromRGB(82,67,61));part(root,"BenchBack",Vector3.new(10,3,.6),CFrame.new(x,2.6,z+1.2),Enum.Material.Wood,Color3.fromRGB(82,67,61)) end end

-- simple runtime health markers for future automated QC
root:SetAttribute("ZoneCount",#categories+3);root:SetAttribute("MobileSafe","true");root:SetAttribute("CatalogRemoteReady",true)
print("[BBYAVATAR] Showroom v3.0 mannequin + social hub ready")