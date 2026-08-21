-- ACC Mountain Social Adventure — realistic lowland visual pass v4.1
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local root=Workspace:WaitForChild("ACC_MountainSocial",20);if not root then return end
local old=root:FindFirstChild("VisualPolishV41");if old then old:Destroy() end
local f=Instance.new("Folder");f.Name="VisualPolishV41";f.Parent=root
local function mk(n,s,cf,m,col,p,tr,co)
 local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Material=m or Enum.Material.Wood;if col then x.Color=col end;x.Transparency=tr or 0;x.CanCollide=co~=false;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=p or f;return x
end
local function tree(pos,scale,dark)
 local trunk=mk("TreeTrunk",Vector3.new(2.1*scale,10*scale,2.1*scale),CFrame.new(pos+Vector3.new(0,5*scale,0)),Enum.Material.Wood,Color3.fromRGB(78,56,37),f,0,true)
 local crown=mk("TreeCrown",Vector3.new(10*scale,9*scale,10*scale),CFrame.new(pos+Vector3.new(0,12*scale,0)),Enum.Material.LeafyGrass,dark and Color3.fromRGB(39,73,42) or Color3.fromRGB(53,96,50),f,0,false);crown.Shape=Enum.PartType.Ball
end
local function house(pos,rot,wall,roof)
 local m=Instance.new("Model");m.Name="VillageHouse";m.Parent=f
 local cf=CFrame.new(pos)*CFrame.Angles(0,math.rad(rot),0)
 mk("Floor",Vector3.new(25,1,19),cf,Enum.Material.Concrete,Color3.fromRGB(123,116,103),m)
 mk("Body",Vector3.new(23,10,17),cf+Vector3.new(0,5.5,0),Enum.Material.Brick,wall,m)
 mk("Roof",Vector3.new(29,1.5,22),cf+Vector3.new(0,12,0),Enum.Material.Metal,roof,m)
 mk("Door",Vector3.new(4,7,.6),cf*CFrame.new(0,3.5,-8.7),Enum.Material.Wood,Color3.fromRGB(82,58,39),m,0,false)
 mk("WindowL",Vector3.new(4,3,.5),cf*CFrame.new(-6,6,-8.8),Enum.Material.Glass,Color3.fromRGB(150,186,197),m,.25,false)
 mk("WindowR",Vector3.new(4,3,.5),cf*CFrame.new(6,6,-8.8),Enum.Material.Glass,Color3.fromRGB(150,186,197),m,.25,false)
end
math.randomseed(220826)
-- Rice fields: lifted above terrain and layered with bunds/water/rice rows.
local paddies={{-135,955,105,82},{135,945,108,82},{-155,835,126,88},{160,820,128,86},{-165,700,136,92},{175,680,138,90},{-155,555,120,88},{190,530,125,82}}
for i,v in ipairs(paddies) do
 local x,z,w,d=v[1],v[2],v[3],v[4]
 mk("PaddyBund_"..i,Vector3.new(w+8,1.2,d+8),CFrame.new(x,8.65,z),Enum.Material.Ground,Color3.fromRGB(101,86,58),f)
 mk("PaddyWater_"..i,Vector3.new(w,0.45,d),CFrame.new(x,9.2,z),Enum.Material.Glass,Color3.fromRGB(102,139,130),f,.42,false)
 for r=-4,4 do mk("RiceRow",Vector3.new(w-12,.55,1.5),CFrame.new(x,9.65,z+r*(d/10)),Enum.Material.LeafyGrass,Color3.fromRGB(95+math.random(0,12),142+math.random(0,10),65),f,0,false) end
end
-- Village cluster around spawn. Buildings are deliberately close enough to be visible immediately.
house(Vector3.new(-58,9.1,1042),18,Color3.fromRGB(207,193,165),Color3.fromRGB(92,72,58))
house(Vector3.new(62,9.1,1018),-12,Color3.fromRGB(193,182,155),Color3.fromRGB(72,74,72))
house(Vector3.new(-78,9.1,972),6,Color3.fromRGB(215,199,171),Color3.fromRGB(99,70,53))
house(Vector3.new(82,9.1,925),-20,Color3.fromRGB(197,185,163),Color3.fromRGB(71,72,70))
house(Vector3.new(-88,9.2,865),15,Color3.fromRGB(184,175,151),Color3.fromRGB(89,66,49))
house(Vector3.new(92,9.3,790),-18,Color3.fromRGB(203,190,166),Color3.fromRGB(69,71,68))
-- Warung roadside.
local warung=Instance.new("Model");warung.Name="WarungKakiGunung";warung.Parent=f
mk("WarungFloor",Vector3.new(26,1,17),CFrame.new(54,9.2,882),Enum.Material.WoodPlanks,Color3.fromRGB(111,81,52),warung)
mk("WarungBack",Vector3.new(26,10,1),CFrame.new(54,14.4,890),Enum.Material.WoodPlanks,Color3.fromRGB(103,76,52),warung)
mk("WarungSide",Vector3.new(1,10,17),CFrame.new(41.5,14.4,882),Enum.Material.WoodPlanks,Color3.fromRGB(103,76,52),warung)
mk("WarungRoof",Vector3.new(30,1.4,21),CFrame.new(54,20.2,882),Enum.Material.Metal,Color3.fromRGB(76,82,78),warung)
local sign=mk("WarungSign",Vector3.new(17,4,.6),CFrame.new(54,18.3,873.3),Enum.Material.WoodPlanks,Color3.fromRGB(78,57,39),warung)
local sg=Instance.new("SurfaceGui");sg.Face=Enum.NormalId.Front;sg.Parent=sign;local tx=Instance.new("TextLabel");tx.Size=UDim2.fromScale(1,1);tx.BackgroundTransparency=1;tx.Text="WARUNG KAKI GUNUNG";tx.TextScaled=true;tx.Font=Enum.Font.GothamBold;tx.TextColor3=Color3.fromRGB(239,229,196);tx.Parent=sg
-- Drainage channels and rice-field edges make the road feel inhabited.
for _,z in ipairs({1000,930,860,790,720,650,580}) do mk("DrainL",Vector3.new(3,.5,62),CFrame.new(-25,9.15,z),Enum.Material.Glass,Color3.fromRGB(86,126,135),f,.35,false);mk("DrainR",Vector3.new(3,.5,62),CFrame.new(25,9.15,z),Enum.Material.Glass,Color3.fromRGB(86,126,135),f,.35,false) end
-- Road markings only in the lower public-road section.
for _,z in ipairs({1000,940,880,820,760,700,640}) do mk("CenterMark",Vector3.new(.45,.12,18),CFrame.new(0,11.75,z),Enum.Material.SmoothPlastic,Color3.fromRGB(214,205,169),f,0,false) end
-- Trees: ordered village vegetation, then increasingly wild foothill vegetation.
for i=0,18 do local z=1035-i*47;local x=(i%2==0 and -1 or 1)*(36+math.random(5,18));tree(Vector3.new(x,9.2+(1035-z)*.007,z),.8+math.random()*.3,false) end
for i=1,54 do local z=500-math.random()*600;local x=(math.random()<.5 and -1 or 1)*math.random(38,115);local y=10+(500-z)*.055;tree(Vector3.new(x,y,z),.72+math.random()*.5,z<120) end
-- Utility poles end before the trailhead.
for i,z in ipairs({1010,900,790,680,570,455,350}) do local y=11+(1010-z)*.018;local pole=mk("UtilityPole_"..i,Vector3.new(1.3,17,1.3),CFrame.new(-24,y+8.5,z),Enum.Material.Wood,Color3.fromRGB(72,55,42),f);mk("PoleArm_"..i,Vector3.new(9,.7,.7),pole.CFrame*CFrame.new(0,7.5,0),Enum.Material.Wood,Color3.fromRGB(72,55,42),f) end
-- Foothill brush and rocks.
for i=1,75 do local z=390-math.random()*470;local x=(math.random()<.5 and -1 or 1)*math.random(26,105);local y=15+(390-z)*.06;local bush=mk("FoothillBush_"..i,Vector3.new(math.random(3,8),math.random(2,5),math.random(3,8)),CFrame.new(x,y,z),Enum.Material.LeafyGrass,Color3.fromRGB(math.random(43,58),math.random(76,103),math.random(42,59)),f,0,false);bush.Shape=Enum.PartType.Ball;if i%5==0 then local rock=mk("FoothillRock_"..i,Vector3.new(math.random(3,8),math.random(2,5),math.random(3,9)),CFrame.new(x+(i%2==0 and 6 or -6),y-1,z+4),Enum.Material.Rock,Color3.fromRGB(91,91,85),f);rock.Shape=Enum.PartType.Ball end end
-- River and bridge at POS 3.
local river=Vector3.new(20,160,-520);for i=-4,4 do local stone=mk("RiverStone",Vector3.new(8,3,7),CFrame.new(river+Vector3.new(i*11,2,math.sin(i)*5)),Enum.Material.Rock,Color3.fromRGB(91,94,90),f);stone.Shape=Enum.PartType.Ball end;for i=-6,6 do mk("BridgePlank",Vector3.new(9,.8,3),CFrame.new(river+Vector3.new(i*3,5,-18)),Enum.Material.WoodPlanks,Color3.fromRGB(91,66,43),f) end
-- High-altitude vegetation thins naturally.
local upper={Vector3.new(-180,100,-270),Vector3.new(20,160,-520),Vector3.new(185,225,-770),Vector3.new(42,295,-1020),Vector3.new(-185,375,-1250),Vector3.new(-265,455,-1480)}
for idx,p in ipairs(upper) do local count=math.max(7,27-idx*3);for i=1,count do local a=math.random()*math.pi*2;local r=math.random(38,118);tree(p+Vector3.new(math.cos(a)*r,-3,math.sin(a)*r),math.max(.55,1.03-idx*.07),idx>3) end end
-- False summit sign.
local fs=Vector3.new(265,685,-2120);local fsSign=mk("FalseSummitSign",Vector3.new(17,5,1),CFrame.new(fs+Vector3.new(0,8,-10)),Enum.Material.WoodPlanks,Color3.fromRGB(72,55,41),f);local fsg=Instance.new("SurfaceGui");fsg.Face=Enum.NormalId.Front;fsg.Parent=fsSign;local fst=Instance.new("TextLabel");fst.Size=UDim2.fromScale(1,1);fst.BackgroundTransparency=1;fst.Text="BELUM PUNCAK\nJALUR MASIH LANJUT";fst.TextScaled=true;fst.TextWrapped=true;fst.Font=Enum.Font.GothamBold;fst.TextColor3=Color3.fromRGB(236,229,210);fst.Parent=fsg
Lighting.FogColor=Color3.fromRGB(194,205,202);Lighting.FogStart=700;Lighting.FogEnd=3600
root:SetAttribute("VisualPolish","4.1");root:SetAttribute("LowlandVillageReady",true);root:SetAttribute("RiceFieldZoneReady",true);root:SetAttribute("RealisticSceneryLock",true)
print("[ACC] Mountain v4.1 realistic village/fields applied")