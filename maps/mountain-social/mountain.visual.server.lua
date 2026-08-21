-- ACC Mountain Social Adventure — scenic lowland art pass v4.2
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local root=Workspace:WaitForChild("ACC_MountainSocial",20);if not root then return end
local old=root:FindFirstChild("VisualPolishV42");if old then old:Destroy() end
local f=Instance.new("Folder");f.Name="VisualPolishV42";f.Parent=root

local function mk(n,s,cf,m,col,p,tr,co)
 local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Material=m or Enum.Material.Wood
 if col then x.Color=col end;x.Transparency=tr or 0;x.CanCollide=co~=false;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=p or f;return x
end
local function beam(n,a,b,w,mat,col,p,tr,co)
 local d=b-a;if d.Magnitude<.05 then return end
 return mk(n,Vector3.new(w,w,d.Magnitude),CFrame.lookAt((a+b)/2,b),mat,col,p,tr,co)
end
local function ball(n,pos,size,col,p,mat)
 local x=mk(n,Vector3.new(size,size*.86,size),CFrame.new(pos),mat or Enum.Material.LeafyGrass,col,p,0,false);x.Shape=Enum.PartType.Ball;return x
end
local function broadTree(pos,scale,dark)
 local m=Instance.new("Model");m.Name="BroadleafTree";m.Parent=f
 local bark=Color3.fromRGB(74,54,37);local leaf=dark and Color3.fromRGB(37,70,39) or Color3.fromRGB(49,91,45)
 mk("Trunk",Vector3.new(2.0*scale,10*scale,2.0*scale),CFrame.new(pos+Vector3.new(0,5*scale,0)),Enum.Material.Wood,bark,m)
 beam("BranchA",pos+Vector3.new(0,7*scale,0),pos+Vector3.new(4*scale,10*scale,1*scale),1.1*scale,Enum.Material.Wood,bark,m)
 beam("BranchB",pos+Vector3.new(0,8*scale,0),pos+Vector3.new(-3.5*scale,10.5*scale,-2*scale),1.0*scale,Enum.Material.Wood,bark,m)
 ball("Crown1",pos+Vector3.new(0,13*scale,0),8.4*scale,leaf,m)
 ball("Crown2",pos+Vector3.new(4.1*scale,12.6*scale,1.0*scale),5.8*scale,leaf,m)
 ball("Crown3",pos+Vector3.new(-3.7*scale,12.8*scale,-1.6*scale),5.5*scale,leaf,m)
 ball("Crown4",pos+Vector3.new(1.2*scale,15.0*scale,-2.5*scale),5.1*scale,leaf,m)
end
local function palm(pos,scale)
 local m=Instance.new("Model");m.Name="Palm";m.Parent=f
 local top=pos+Vector3.new(0,14*scale,0)
 mk("PalmTrunk",Vector3.new(1.6*scale,14*scale,1.6*scale),CFrame.new(pos+Vector3.new(0,7*scale,0))*CFrame.Angles(0,0,math.rad(-3)),Enum.Material.Wood,Color3.fromRGB(91,67,43),m)
 for i=1,8 do local a=(i-1)/8*math.pi*2;local leaf=mk("PalmLeaf",Vector3.new(2.2*scale,.5*scale,11*scale),CFrame.new(top)*CFrame.Angles(math.rad(-18),a,math.rad(math.sin(a)*8)),Enum.Material.LeafyGrass,Color3.fromRGB(49,101,52),m,0,false);leaf.CanCollide=false end
end
local function house(pos,rot,wall,roof,scale)
 scale=scale or 1;local m=Instance.new("Model");m.Name="VillageHouse";m.Parent=f
 local cf=CFrame.new(pos)*CFrame.Angles(0,math.rad(rot),0)
 local w,d,h=24*scale,18*scale,10*scale
 mk("Foundation",Vector3.new(w+2,.9,d+2),cf,Enum.Material.Concrete,Color3.fromRGB(118,112,102),m)
 mk("Body",Vector3.new(w,h,d),cf*CFrame.new(0,h/2,0),Enum.Material.Brick,wall,m)
 -- pitched roof made from two overlapping slabs, not a flat box
 mk("RoofL",Vector3.new(w*.58,1.1,d+5),cf*CFrame.new(-w*.23,h+3.0,0)*CFrame.Angles(0,0,math.rad(25)),Enum.Material.Metal,roof,m)
 mk("RoofR",Vector3.new(w*.58,1.1,d+5),cf*CFrame.new(w*.23,h+3.0,0)*CFrame.Angles(0,0,math.rad(-25)),Enum.Material.Metal,roof,m)
 mk("Door",Vector3.new(3.8*scale,7*scale,.45),cf*CFrame.new(0,3.5*scale,-d/2-.25),Enum.Material.Wood,Color3.fromRGB(76,54,38),m,0,false)
 for _,x in ipairs({-w*.27,w*.27}) do
  mk("WindowGlass",Vector3.new(4.2*scale,3.1*scale,.35),cf*CFrame.new(x,6*scale,-d/2-.3),Enum.Material.Glass,Color3.fromRGB(148,183,193),m,.23,false)
  mk("WindowTop",Vector3.new(4.8*scale,.28,.5),cf*CFrame.new(x,7.75*scale,-d/2-.5),Enum.Material.Wood,Color3.fromRGB(86,66,50),m,0,false)
 end
 mk("Porch",Vector3.new(w*.65,.65,4.5*scale),cf*CFrame.new(0,.3,-d/2-2.1*scale),Enum.Material.WoodPlanks,Color3.fromRGB(106,81,58),m)
 for _,x in ipairs({-w*.26,w*.26}) do mk("PorchPost",Vector3.new(.65,6,.65),cf*CFrame.new(x,3.2,-d/2-4),Enum.Material.Wood,Color3.fromRGB(81,61,44),m) end
 mk("PorchRoof",Vector3.new(w*.7,.65,6),cf*CFrame.new(0,6.3,-d/2-2.4)*CFrame.Angles(math.rad(-9),0,0),Enum.Material.Metal,roof,m)
end
local function paddy(name,pos,w,d,rot)
 local m=Instance.new("Model");m.Name=name;m.Parent=f
 local cf=CFrame.new(pos)*CFrame.Angles(0,math.rad(rot or 0),0)
 local mud=Color3.fromRGB(96,81,57)
 mk("Water",Vector3.new(w,.28,d),cf,Enum.Material.Glass,Color3.fromRGB(94,132,123),m,.38,false)
 mk("BundN",Vector3.new(w+3,.9,2.2),cf*CFrame.new(0,.15,-d/2-1),Enum.Material.Ground,mud,m)
 mk("BundS",Vector3.new(w+3,.9,2.2),cf*CFrame.new(0,.15,d/2+1),Enum.Material.Ground,mud,m)
 mk("BundW",Vector3.new(2.2,.9,d),cf*CFrame.new(-w/2-1,.15,0),Enum.Material.Ground,mud,m)
 mk("BundE",Vector3.new(2.2,.9,d),cf*CFrame.new(w/2+1,.15,0),Enum.Material.Ground,mud,m)
 for r=-4,4 do
  for c=-4,4 do
   if (r+c)%2==0 then local localPos=Vector3.new(c*w/11,.55,r*d/11);local tuft=mk("RiceTuft",Vector3.new(1.2,1.15,1.2),cf*CFrame.new(localPos),Enum.Material.LeafyGrass,Color3.fromRGB(91+math.random(0,14),139+math.random(0,15),61),m,0,false);tuft.Shape=Enum.PartType.Ball end
  end
 end
end
local function fence(a,b,count)
 for i=0,count do local t=i/count;local p=a:Lerp(b,t);mk("FencePost",Vector3.new(.55,4,.55),CFrame.new(p+Vector3.new(0,2,0)),Enum.Material.Wood,Color3.fromRGB(91,68,48),f) end
 beam("FenceRail1",a+Vector3.new(0,1.5,0),b+Vector3.new(0,1.5,0),.32,Enum.Material.Wood,Color3.fromRGB(91,68,48),f)
 beam("FenceRail2",a+Vector3.new(0,3,0),b+Vector3.new(0,3,0),.32,Enum.Material.Wood,Color3.fromRGB(91,68,48),f)
end
math.randomseed(4220826)

-- Terraced rice fields set back from the road, with water, bunds and individual rice tufts.
paddy("Paddy_A",Vector3.new(-125,9.1,1005),100,58,-4)
paddy("Paddy_B",Vector3.new(126,9.0,990),105,62,4)
paddy("Paddy_C",Vector3.new(-145,9.4,900),112,66,2)
paddy("Paddy_D",Vector3.new(151,9.4,875),118,64,-3)
paddy("Paddy_E",Vector3.new(-155,9.8,790),120,68,-2)
paddy("Paddy_F",Vector3.new(165,10.0,755),125,70,3)
paddy("Paddy_G",Vector3.new(-165,10.5,665),118,64,4)
paddy("Paddy_H",Vector3.new(175,10.7,620),122,66,-4)

-- Rural houses have pitched roofs, windows, porches and varied setback/orientation.
house(Vector3.new(-54,9.2,1032),18,Color3.fromRGB(202,188,160),Color3.fromRGB(91,72,58),.94)
house(Vector3.new(58,9.2,1018),-13,Color3.fromRGB(189,177,151),Color3.fromRGB(67,73,70),.88)
house(Vector3.new(-66,9.5,948),7,Color3.fromRGB(213,198,169),Color3.fromRGB(100,69,51),.92)
house(Vector3.new(70,9.6,914),-21,Color3.fromRGB(195,184,163),Color3.fromRGB(71,72,69),.9)
house(Vector3.new(-78,9.8,842),15,Color3.fromRGB(182,173,151),Color3.fromRGB(88,65,48),.86)
house(Vector3.new(82,10.0,792),-18,Color3.fromRGB(202,190,166),Color3.fromRGB(68,71,67),.9)
house(Vector3.new(-88,10.4,710),9,Color3.fromRGB(197,187,164),Color3.fromRGB(96,69,50),.84)

-- Warung with open frontage and sloped awning.
local warung=Instance.new("Model");warung.Name="WarungKakiGunung";warung.Parent=f
local wc=CFrame.new(50,9.6,868)*CFrame.Angles(0,math.rad(-5),0)
mk("Floor",Vector3.new(24,.8,16),wc,Enum.Material.WoodPlanks,Color3.fromRGB(108,80,53),warung)
mk("Back",Vector3.new(24,9,1),wc*CFrame.new(0,4.5,7.5),Enum.Material.WoodPlanks,Color3.fromRGB(101,74,50),warung)
mk("SideL",Vector3.new(1,9,16),wc*CFrame.new(-11.5,4.5,0),Enum.Material.WoodPlanks,Color3.fromRGB(101,74,50),warung)
mk("Counter",Vector3.new(15,3,2),wc*CFrame.new(2,1.6,-5.8),Enum.Material.WoodPlanks,Color3.fromRGB(85,63,44),warung)
mk("Roof",Vector3.new(28,1,20),wc*CFrame.new(0,10.2,0)*CFrame.Angles(math.rad(-7),0,0),Enum.Material.Metal,Color3.fromRGB(75,80,76),warung)
local sign=mk("WarungSign",Vector3.new(15,3,.5),wc*CFrame.new(0,8.2,-8.2),Enum.Material.WoodPlanks,Color3.fromRGB(74,55,39),warung)
local sg=Instance.new("SurfaceGui");sg.Face=Enum.NormalId.Front;sg.Parent=sign;local tx=Instance.new("TextLabel");tx.Size=UDim2.fromScale(1,1);tx.BackgroundTransparency=1;tx.Text="WARUNG KAKI GUNUNG";tx.TextScaled=true;tx.Font=Enum.Font.GothamBold;tx.TextColor3=Color3.fromRGB(238,227,195);tx.Parent=sg

-- Organic vegetation: multi-lobed broadleaf trees + palms near the village, denser toward foothills.
for _,v in ipairs({{-33,9.3,1035,1.0},{35,9.3,975,.9},{-40,9.5,915,.95},{42,9.7,850,.86},{-46,10.1,780,.9},{48,10.5,700,.92},{-50,11.0,610,.96},{52,12.0,525,1.0}}) do broadTree(Vector3.new(v[1],v[2],v[3]),v[4],false) end
for _,v in ipairs({{-92,9.1,1008,.8},{96,9.2,940,.75},{-105,9.8,815,.82},{112,10.5,690,.78}}) do palm(Vector3.new(v[1],v[2],v[3]),v[4]) end
for i=1,42 do local z=520-math.random()*610;local x=(math.random()<.5 and -1 or 1)*math.random(36,125);local y=12+(520-z)*.055;broadTree(Vector3.new(x,y,z),.58+math.random()*.42,z<140) end

-- Fences and drainage give the village lived-in scale.
fence(Vector3.new(-28,9.4,1002),Vector3.new(-28,9.8,925),6)
fence(Vector3.new(29,9.4,965),Vector3.new(29,10.0,890),6)
fence(Vector3.new(-32,10.1,825),Vector3.new(-34,11.0,750),6)
for _,z in ipairs({995,925,855,785,715,645}) do mk("DrainL",Vector3.new(2.2,.35,44),CFrame.new(-17,9.35,z),Enum.Material.Glass,Color3.fromRGB(78,116,125),f,.4,false);mk("DrainR",Vector3.new(2.2,.35,44),CFrame.new(17,9.35,z),Enum.Material.Glass,Color3.fromRGB(78,116,125),f,.4,false) end

-- Utility poles follow the road; thin overhead wires connect them.
local poles={Vector3.new(-18,10.8,1018),Vector3.new(-18,11.5,925),Vector3.new(-15,12.2,832),Vector3.new(-16,13.2,738),Vector3.new(-12,14.6,642),Vector3.new(3,16.2,545),Vector3.new(23,18.6,448),Vector3.new(34,22.0,350)}
local tops={}
for i,p in ipairs(poles) do mk("UtilityPole_"..i,Vector3.new(1.0,16,1.0),CFrame.new(p+Vector3.new(0,8,0)),Enum.Material.Wood,Color3.fromRGB(69,52,40),f);mk("CrossArm_"..i,Vector3.new(7,.55,.55),CFrame.new(p+Vector3.new(0,15.2,0)),Enum.Material.Wood,Color3.fromRGB(69,52,40),f);tops[i]=p+Vector3.new(0,15.6,0) end
for i=1,#tops-1 do beam("PowerWireA_"..i,tops[i]+Vector3.new(-2.4,0,0),tops[i+1]+Vector3.new(-2.4,0,0),.12,Enum.Material.SmoothPlastic,Color3.fromRGB(34,34,32),f,0,false);beam("PowerWireB_"..i,tops[i]+Vector3.new(2.4,0,0),tops[i+1]+Vector3.new(2.4,0,0),.12,Enum.Material.SmoothPlastic,Color3.fromRGB(34,34,32),f,0,false) end

-- Foothill rocks/bushes become dominant after the public road ends.
for i=1,62 do local z=360-math.random()*430;local x=(math.random()<.5 and -1 or 1)*math.random(24,105);local y=18+(360-z)*.06;ball("FoothillBush",Vector3.new(x,y,z),math.random(3,6),Color3.fromRGB(math.random(40,57),math.random(74,101),math.random(40,57)),f);if i%4==0 then local r=ball("FoothillRock",Vector3.new(x+math.random(-8,8),y-1,z+math.random(-7,7)),math.random(3,7),Color3.fromRGB(88,89,84),f,Enum.Material.Rock);r.CanCollide=true end end

-- River landmark with rough stepping stones and narrow timber crossing.
local river=Vector3.new(20,160,-520)
for i=-4,4 do local r=ball("RiverStone",river+Vector3.new(i*11,2,math.sin(i)*5),math.random(6,9),Color3.fromRGB(87,91,88),f,Enum.Material.Rock);r.CanCollide=true end
for i=-6,6 do mk("BridgePlank",Vector3.new(8.5,.7,2.7),CFrame.new(river+Vector3.new(i*2.8,5,-18))*CFrame.Angles(0,0,math.rad(math.sin(i)*1.5)),Enum.Material.WoodPlanks,Color3.fromRGB(88,64,43),f) end

-- False summit remains a deliberate story beat.
local fs=Vector3.new(265,685,-2120);local fsSign=mk("FalseSummitSign",Vector3.new(17,5,1),CFrame.new(fs+Vector3.new(0,8,-10)),Enum.Material.WoodPlanks,Color3.fromRGB(72,55,41),f);local fsg=Instance.new("SurfaceGui");fsg.Face=Enum.NormalId.Front;fsg.Parent=fsSign;local fst=Instance.new("TextLabel");fst.Size=UDim2.fromScale(1,1);fst.BackgroundTransparency=1;fst.Text="BELUM PUNCAK\nJALUR MASIH LANJUT";fst.TextScaled=true;fst.TextWrapped=true;fst.Font=Enum.Font.GothamBold;fst.TextColor3=Color3.fromRGB(236,229,210);fst.Parent=fsg

Lighting.FogColor=Color3.fromRGB(190,202,200);Lighting.FogStart=950;Lighting.FogEnd=4200
root:SetAttribute("VisualPolish","4.2");root:SetAttribute("LowlandVillageReady",true);root:SetAttribute("RiceFieldZoneReady",true);root:SetAttribute("RealisticSceneryLock",true);root:SetAttribute("OrganicVillageReady",true)
print("[ACC] Mountain v4.2 organic scenic village applied")