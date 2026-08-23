local RS=game:GetService("ReplicatedStorage");local W=game:GetService("Workspace");local L=game:GetService("Lighting")
local old=W:FindFirstChild("BBYAVATAR_SHOWROOM");if old then old:Destroy() end;local rr=RS:FindFirstChild("BBYAVATAR");if rr then rr:Destroy() end
for _,n in ipairs({"BBYAVATAR_Color","BBYAVATAR_Atmosphere","BBYAVATAR_Bloom"})do local x=L:FindFirstChild(n);if x then x:Destroy() end end
L.ClockTime=13.8;L.Brightness=3.2;L.Ambient=Color3.fromRGB(145,145,155);L.OutdoorAmbient=Color3.fromRGB(170,170,178);L.EnvironmentDiffuseScale=.55;L.EnvironmentSpecularScale=.8
local cc=Instance.new("ColorCorrectionEffect");cc.Name="BBYAVATAR_Color";cc.Contrast=.06;cc.Saturation=-.02;cc.Brightness=.03;cc.Parent=L
local bloom=Instance.new("BloomEffect");bloom.Name="BBYAVATAR_Bloom";bloom.Intensity=.12;bloom.Size=18;bloom.Threshold=1.4;bloom.Parent=L
local root=Instance.new("Folder");root.Name="BBYAVATAR_SHOWROOM";root.Parent=W;root:SetAttribute("BuildVersion","4.0");root:SetAttribute("Design","PREMIUM_FASHION_GALLERY")
local rem=Instance.new("Folder");rem.Name="BBYAVATAR";rem.Parent=RS;local open=Instance.new("RemoteEvent");open.Name="OpenCatalog";open.Parent=rem
local function p(pa,n,s,cf,col,mat)local x=Instance.new("Part");x.Name=n;x.Size=s;x.CFrame=cf;x.Anchored=true;x.Color=col;x.Material=mat or Enum.Material.SmoothPlastic;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=pa;return x end
local function label(part,text,dark)local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=24;g.Parent=part;local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.Font=Enum.Font.GothamMedium;t.TextScaled=true;t.TextWrapped=true;t.TextColor3=dark and Color3.fromRGB(25,25,29) or Color3.fromRGB(245,245,245);t.Parent=g end
local function prompt(x,title,cat)local q=Instance.new("ProximityPrompt");q.ActionText="EXPLORE";q.ObjectText=title;q.MaxActivationDistance=9;q.RequiresLineOfSight=true;q.Parent=x;q.Triggered:Connect(function(plr)open:FireClient(plr,cat)end)end
local ivory=Color3.fromRGB(224,221,213);local charcoal=Color3.fromRGB(30,31,35);local stone=Color3.fromRGB(94,94,99);local gold=Color3.fromRGB(171,145,91)
-- gallery shell
p(root,"Floor",Vector3.new(180,1,180),CFrame.new(0,0,0),Color3.fromRGB(202,199,192),Enum.Material.Marble)
p(root,"Ceiling",Vector3.new(180,1,180),CFrame.new(0,24,0),Color3.fromRGB(42,43,47),Enum.Material.SmoothPlastic)
p(root,"Back",Vector3.new(180,24,1),CFrame.new(0,12,-90),ivory);p(root,"Left",Vector3.new(1,24,180),CFrame.new(-90,12,0),ivory);p(root,"Right",Vector3.new(1,24,180),CFrame.new(90,12,0),ivory)
-- ceiling light rails
for _,x in ipairs({-48,-16,16,48})do p(root,"LightRail",Vector3.new(1,1,150),CFrame.new(x,23.2,0),charcoal,Enum.Material.Metal);for z=-60,60,20 do local lamp=p(root,"Spot",Vector3.new(2.2,.4,2.2),CFrame.new(x,22.5,z),Color3.fromRGB(255,244,218),Enum.Material.Neon);lamp.CanCollide=false;local li=Instance.new("PointLight");li.Brightness=.8;li.Range=18;li.Color=Color3.fromRGB(255,240,215);li.Parent=lamp end end
-- spawn foyer: intentionally almost empty
local spawn=Instance.new("SpawnLocation");spawn.Name="BBYAVATAR_Spawn";spawn.Size=Vector3.new(8,1,8);spawn.CFrame=CFrame.new(0,1,76)*CFrame.Angles(0,math.rad(180),0);spawn.Anchored=true;spawn.Transparency=1;spawn.Neutral=true;spawn.Parent=root
local brand=p(root,"Brand",Vector3.new(42,5,1),CFrame.new(0,12,-88.8),charcoal);label(brand,"BBYAVATAR",false)
local sub=p(root,"Subtitle",Vector3.new(26,2,1),CFrame.new(0,8,-88.7),ivory);label(sub,"CURATED AVATAR GALLERY",true)
-- central sculptural runway, no text clutter
p(root,"Runway",Vector3.new(24,.35,132),CFrame.new(0,.7,-1),Color3.fromRGB(45,46,52),Enum.Material.Slate)
for _,x in ipairs({-12.3,12.3})do local line=p(root,"EdgeLight",Vector3.new(.12,.08,132),CFrame.new(x,.9,-1),gold,Enum.Material.Neon);line.CanCollide=false end
-- simple premium mannequins
local function mannequin(pa,x,z,cat,accent)
 local m=Instance.new("Model");m.Name="Look_"..cat;m.Parent=pa
 local skin=Color3.fromRGB(190,188,184);local torso=p(m,"Torso",Vector3.new(2.8,3.5,1.5),CFrame.new(x,4,z),accent);local h=p(m,"Head",Vector3.new(2,2,2),CFrame.new(x,6.8,z),skin);h.Shape=Enum.PartType.Ball
 p(m,"ArmL",Vector3.new(.8,3.4,.8),CFrame.new(x-1.8,4,z),accent);p(m,"ArmR",Vector3.new(.8,3.4,.8),CFrame.new(x+1.8,4,z),accent);p(m,"LegL",Vector3.new(1,3.4,1),CFrame.new(x-.7,1.3,z),charcoal);p(m,"LegR",Vector3.new(1,3.4,1),CFrame.new(x+.7,1.3,z),charcoal);prompt(torso,cat,cat)
end
local zones={{"TRENDING",-55,48,Color3.fromRGB(93,78,116)},{"NEW DROPS",55,48,Color3.fromRGB(73,99,119)},{"STREETWEAR",-55,14,Color3.fromRGB(105,82,72)},{"CYBER",55,14,Color3.fromRGB(65,104,108)},{"LUXURY",-55,-20,Color3.fromRGB(125,105,68)},{"CUTE",55,-20,Color3.fromRGB(125,88,111)},{"BALI",-55,-54,Color3.fromRGB(112,91,70)},{"CREATORS",55,-54,Color3.fromRGB(72,105,83)}}
for _,z in ipairs(zones)do
 local alc=Instance.new("Model");alc.Name=z[1];alc.Parent=root
 p(alc,"Platform",Vector3.new(42,.8,24),CFrame.new(z[2],.5,z[3]),Color3.fromRGB(232,229,222),Enum.Material.Marble)
 p(alc,"Backdrop",Vector3.new(42,11,1),CFrame.new(z[2],6,z[3]-11.5),z[4])
 local plaque=p(alc,"Plaque",Vector3.new(18,2.2,.4),CFrame.new(z[2],10,z[3]-10.9),charcoal);label(plaque,z[1],false)
 mannequin(alc,z[2]-10,z[3]+2,z[1],Color3.fromRGB(69,70,78));mannequin(alc,z[2],z[3]+2,z[1],z[4]);mannequin(alc,z[2]+10,z[3]+2,z[1],Color3.fromRGB(219,216,209))
end
-- one focal featured stage at the far end
local stage=p(root,"FeaturedStage",Vector3.new(30,1,20),CFrame.new(0,.7,-67),Color3.fromRGB(236,233,226),Enum.Material.Marble);prompt(stage,"FEATURED LOOKS","FEATURED")
local feature=p(root,"FeaturedLabel",Vector3.new(24,2.5,.5),CFrame.new(0,8,-78),gold);label(feature,"FEATURED / 01",true)
mannequin(root,-8,-67,"FEATURED",Color3.fromRGB(30,31,35));mannequin(root,0,-67,"FEATURED",gold);mannequin(root,8,-67,"FEATURED",Color3.fromRGB(232,229,222))
-- utility lounges are discrete, small and at entrance corners
for _,d in ipairs({{"AVATAR STUDIO",-73,70,"STUDIO"},{"PHOTO STUDIO",73,70,"PHOTO"}})do local pad=p(root,d[1],Vector3.new(24,.8,14),CFrame.new(d[2],.5,d[3]),charcoal);prompt(pad,d[1],d[4]);local s=p(root,d[1].."Label",Vector3.new(18,2,.5),CFrame.new(d[2],4,d[3]-6),charcoal);label(s,d[1],false) end
root:SetAttribute("MobileSightline","CLEAR");root:SetAttribute("TextClutter","MINIMAL");root:SetAttribute("LookPreviewCount",27);print("[BBYAVATAR] premium fashion gallery v4 ready")