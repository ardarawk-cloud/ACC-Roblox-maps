-- ACC Mountain Social Adventure — Lowland & progression visual pass v4.0
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local Terrain=Workspace.Terrain
local root=Workspace:WaitForChild("ACC_MountainSocial")
local decor=root:WaitForChild("Decor")
local old=root:FindFirstChild("VisualPolishV40");if old then old:Destroy() end
local f=Instance.new("Folder");f.Name="VisualPolishV40";f.Parent=root
local function mk(n,s,cf,m,col,p,tr,co)
 local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Material=m or Enum.Material.Wood
 if col then x.Color=col end;x.Transparency=tr or 0;x.CanCollide=co~=false;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=p or f;return x
end
local function tree(pos,scale)
 local trunk=mk("RoadsideTreeTrunk",Vector3.new(2.2*scale,9*scale,2.2*scale),CFrame.new(pos+Vector3.new(0,4.5*scale,0)),Enum.Material.Wood,Color3.fromRGB(82,58,38),f,0,true)
 local crown=mk("RoadsideTreeCrown",Vector3.new(9*scale,8*scale,9*scale),CFrame.new(pos+Vector3.new(0,11*scale,0)),Enum.Material.Grass,Color3.fromRGB(53,91,49),f,0,false);crown.Shape=Enum.PartType.Ball
end
local function house(pos,rot,wall,roof)
 local m=Instance.new("Model");m.Name="VillageHouse";m.Parent=f
 local cf=CFrame.new(pos)*CFrame.Angles(0,math.rad(rot),0)
 mk("Floor",Vector3.new(24,1,18),cf,Enum.Material.Concrete,Color3.fromRGB(126,119,103),m)
 mk("Body",Vector3.new(22,10,16),cf+Vector3.new(0,5.5,0),Enum.Material.Plaster,wall,m)
 mk("Roof",Vector3.new(27,2,21),cf+Vector3.new(0,12,0),Enum.Material.Slate,roof,m)
 local door=mk("Door",Vector3.new(4,7,.5),cf*CFrame.new(0,3.5,-8.25),Enum.Material.Wood,Color3.fromRGB(83,59,39),m,0,false);door.CanCollide=false
end
math.randomseed(220826)

-- Rice paddies dominate the first stretch on both sides of the asphalt road.
local paddies={
 {-135,945,105,82},{135,940,105,82},{-155,825,125,88},{160,815,128,86},
 {-165,690,135,92},{175,675,138,90},{-155,545,120,88},{190,525,125,82}
}
for i,v in ipairs(paddies) do
 local x,z,w,d=v[1],v[2],v[3],v[4]
 mk("PaddyBund_"..i,Vector3.new(w+6,1,d+6),CFrame.new(x,10,z),Enum.Material.Ground,Color3.fromRGB(103,88,58),f,0,true)
 local field=mk("RiceField_"..i,Vector3.new(w,1.1,d),CFrame.new(x,10.8,z),Enum.Material.Grass,Color3.fromRGB(91+math.random(-7,7),132+math.random(-8,8),63),f,0,true)
 -- thin irrigation strip on field edge
 mk("Irrigation_"..i,Vector3.new(3,.45,d-5),CFrame.new(x-w/2+5,11.25,z),Enum.Material.Glass,Color3.fromRGB(92,139,151),f,.28,false)
end
-- Simple rice rows so fields read as cultivated rather than generic green rectangles.
for _,v in ipairs(paddies) do
 local x,z,w,d=v[1],v[2],v[3],v[4]
 for r=-3,3 do mk("RiceRow",Vector3.new(w-12,.35,1.4),CFrame.new(x,11.55,z+r*(d/8)),Enum.Material.Grass,Color3.fromRGB(104,151,69),f,0,false) end
end

-- Inhabited village around spawn: houses, warung and roadside details.
house(Vector3.new(-58,12,1045),18,Color3.fromRGB(210,197,169),Color3.fromRGB(94,72,57))
house(Vector3.new(62,12,1018),-12,Color3.fromRGB(195,184,158),Color3.fromRGB(77,77,72))
house(Vector3.new(-76,12,960),6,Color3.fromRGB(219,204,178),Color3.fromRGB(101,70,52))
house(Vector3.new(82,12,922),-20,Color3.fromRGB(201,191,170),Color3.fromRGB(74,73,70))
house(Vector3.new(-88,13,860),15,Color3.fromRGB(186,180,159),Color3.fromRGB(92,66,48))
house(Vector3.new(92,13,780),-18,Color3.fromRGB(207,195,173),Color3.fromRGB(70,71,68))
local warung=Instance.new("Model");warung.Name="WarungKakiGunung";warung.Parent=f
mk("WarungFloor",Vector3.new(25,1,16),CFrame.new(55,12,875),Enum.Material.WoodPlanks,Color3.fromRGB(113,82,52),warung)
mk("WarungBack",Vector3.new(25,10,1),CFrame.new(55,17,882.5),Enum.Material.WoodPlanks,Color3.fromRGB(105,77,52),warung)
mk("WarungRoof",Vector3.new(29,1.5,20),CFrame.new(55,23,875),Enum.Material.CorrugatedMetal,Color3.fromRGB(79,84,78),warung)
local board=mk("WarungSign",Vector3.new(16,4,.6),CFrame.new(55,21,866.8),Enum.Material.WoodPlanks,Color3.fromRGB(80,58,39),warung)
local sg=Instance.new("SurfaceGui");sg.Face=Enum.NormalId.Front;sg.Parent=board;local tx=Instance.new("TextLabel");tx.Size=UDim2.fromScale(1,1);tx.BackgroundTransparency=1;tx.Text="WARUNG KAKI GUNUNG";tx.TextScaled=true;tx.Font=Enum.Font.GothamBold;tx.TextColor3=Color3.fromRGB(239,229,196);tx.Parent=sg

-- Roadside trees are ordered near village then become denser/less manicured toward foothills.
for i=0,17 do
 local z=1030-i*48;local x=(i%2==0 and -1 or 1)*(32+math.random(6,18));tree(Vector3.new(x,12+(1030-z)*.009,z),.8+math.random()*0.35)
end
for i=1,42 do
 local z=470-math.random()*520;local x=(math.random()<.5 and -1 or 1)*math.random(34,105);local y=18+(470-z)*.06
 tree(Vector3.new(x,y,z),.7+math.random()*.55)
end
-- Utility poles along public road; they stop before the dirt transition.
for i,z in ipairs({1010,900,790,680,570,455,350}) do
 local pole=mk("UtilityPole_"..i,Vector3.new(1.3,16,1.3),CFrame.new(-22,20+(1010-z)*.012,z),Enum.Material.Wood,Color3.fromRGB(72,55,42),f)
 mk("PoleArm_"..i,Vector3.new(9,.7,.7),pole.CFrame*CFrame.new(0,7,0),Enum.Material.Wood,Color3.fromRGB(72,55,42),f)
end

-- Transition zone: fewer cultivated elements, more brush and stones.
for i=1,65 do
 local z=380-math.random()*430;local x=(math.random()<.5 and -1 or 1)*math.random(24,95);local y=22+(380-z)*.065
 local bush=mk("FoothillBush_"..i,Vector3.new(math.random(3,7),math.random(2,5),math.random(3,7)),CFrame.new(x,y,z),Enum.Material.Grass,Color3.fromRGB(math.random(43,58),math.random(76,103),math.random(42,59)),f,0,false);bush.Shape=Enum.PartType.Ball
 if i%5==0 then local rock=mk("FoothillRock_"..i,Vector3.new(math.random(3,7),math.random(2,5),math.random(3,8)),CFrame.new(x+(i%2==0 and 5 or -5),y-1,z+4),Enum.Material.Rock,Color3.fromRGB(91,91,85),f);rock.Shape=Enum.PartType.Ball end
end

-- River landmark at POS 3 with stepping stones and a wooden bridge nearby.
local river=Vector3.new(20,165,-520)
for i=-4,4 do local stone=mk("RiverStone",Vector3.new(8,3,7),CFrame.new(river+Vector3.new(i*11,1,math.sin(i)*5)),Enum.Material.Rock,Color3.fromRGB(91,94,90),f);stone.Shape=Enum.PartType.Ball end
for i=-6,6 do mk("BridgePlank",Vector3.new(9,.8,3),CFrame.new(river+Vector3.new(i*3,5,-18)),Enum.Material.WoodPlanks,Color3.fromRGB(91,66,43),f) end

-- Vegetation thins with altitude.
local upper={Vector3.new(-180,105,-270),Vector3.new(20,165,-520),Vector3.new(185,230,-770),Vector3.new(42,300,-1020),Vector3.new(-185,380,-1250),Vector3.new(-265,460,-1480)}
for idx,p in ipairs(upper) do
 local count=math.max(8,28-idx*3)
 for i=1,count do local a=math.random()*math.pi*2;local r=math.random(35,115);local q=p+Vector3.new(math.cos(a)*r,-2,math.sin(a)*r);tree(q,math.max(.55,1.05-idx*.07)) end
end

-- False summit marker warns the player that the main summit is still ahead.
local fs=Vector3.new(265,690,-2120)
local fsSign=mk("FalseSummitSign",Vector3.new(16,5,1),CFrame.new(fs+Vector3.new(0,7,-10)),Enum.Material.WoodPlanks,Color3.fromRGB(72,55,41),f)
local fsg=Instance.new("SurfaceGui");fsg.Face=Enum.NormalId.Front;fsg.Parent=fsSign;local fst=Instance.new("TextLabel");fst.Size=UDim2.fromScale(1,1);fst.BackgroundTransparency=1;fst.Text="BELUM PUNCAK\nJALUR UTAMA MASIH LANJUT";fst.TextScaled=true;fst.TextWrapped=true;fst.Font=Enum.Font.GothamBold;fst.TextColor3=Color3.fromRGB(236,229,210);fst.Parent=fsg

Lighting.FogColor=Color3.fromRGB(194,205,202);Lighting.FogStart=900;Lighting.FogEnd=3400
root:SetAttribute("VisualPolish","4.0")
root:SetAttribute("LowlandVillageReady",true)
root:SetAttribute("RiceFieldZoneReady",true)
print("[ACC] Mountain v4 lowland/visual progression applied")
