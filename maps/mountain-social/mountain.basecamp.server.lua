-- Mountain Social Adventure v2.1 Basecamp ACC rebuild
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("ACC_MountainSocial")
local decor=root:FindFirstChild("Decor") or Instance.new("Folder",root);decor.Name="Decor"
local old=root:FindFirstChild("BasecampACC");if old then old:Destroy() end
local camp=Instance.new("Model");camp.Name="BasecampACC";camp.Parent=root
local base=Vector3.new(0,22,690)
local function mk(n,s,cf,m,c,p,tr,coll)
 local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Material=m or Enum.Material.Wood
 if c then x.Color=c end;x.Transparency=tr or 0;x.CanCollide=coll~=false;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=p or camp;return x
end
-- Grounded arrival clearing and first-path apron.
mk("ArrivalGround",Vector3.new(76,3,72),CFrame.new(base-Vector3.new(0,2.2,0)),Enum.Material.Ground,Color3.fromRGB(91,80,62),camp,0,true)
mk("TrailApron",Vector3.new(22,2,58),CFrame.new(base+Vector3.new(-8,-1,-42))*CFrame.Angles(0,math.rad(-42),0),Enum.Material.Ground,Color3.fromRGB(102,86,65),camp,0,true)
-- Ranger hut.
local h=base+Vector3.new(-30,3,18)
mk("HutFloor",Vector3.new(28,1.2,20),CFrame.new(h),Enum.Material.WoodPlanks,Color3.fromRGB(92,68,45))
mk("HutBack",Vector3.new(28,12,1),CFrame.new(h+Vector3.new(0,6,9.5)),Enum.Material.WoodPlanks,Color3.fromRGB(78,58,40))
mk("HutLeft",Vector3.new(1,12,20),CFrame.new(h+Vector3.new(-13.5,6,0)),Enum.Material.WoodPlanks,Color3.fromRGB(78,58,40))
mk("HutRight",Vector3.new(1,12,20),CFrame.new(h+Vector3.new(13.5,6,0)),Enum.Material.WoodPlanks,Color3.fromRGB(78,58,40))
mk("RoofL",Vector3.new(17,1,23),CFrame.new(h+Vector3.new(-7,13,0))*CFrame.Angles(0,0,math.rad(24)),Enum.Material.Slate,Color3.fromRGB(50,52,51))
mk("RoofR",Vector3.new(17,1,23),CFrame.new(h+Vector3.new(7,13,0))*CFrame.Angles(0,0,math.rad(-24)),Enum.Material.Slate,Color3.fromRGB(50,52,51))
-- Trailhead gate and sign.
local g=base+Vector3.new(-13,4,-33)
mk("GateL",Vector3.new(3,14,3),CFrame.new(g+Vector3.new(-10,3,0)),Enum.Material.Wood,Color3.fromRGB(68,49,34))
mk("GateR",Vector3.new(3,14,3),CFrame.new(g+Vector3.new(10,3,0)),Enum.Material.Wood,Color3.fromRGB(68,49,34))
local sign=mk("TrailheadSign",Vector3.new(25,6,1),CFrame.new(g+Vector3.new(0,9,0)),Enum.Material.WoodPlanks,Color3.fromRGB(68,51,36))
local sg=Instance.new("SurfaceGui");sg.Face=Enum.NormalId.Front;sg.PixelsPerStud=32;sg.Parent=sign
local tx=Instance.new("TextLabel");tx.Size=UDim2.fromScale(1,1);tx.BackgroundTransparency=1;tx.Text="BASECAMP ACC\nTRAIL TO SUMMIT";tx.TextScaled=true;tx.Font=Enum.Font.GothamBold;tx.TextColor3=Color3.fromRGB(236,228,203);tx.Parent=sg
-- Tents and social fire circle.
for i,off in ipairs({Vector3.new(25,2,20),Vector3.new(34,2,5),Vector3.new(26,2,-13)}) do
 local t=mk("Tent"..i,Vector3.new(10,6,7),CFrame.new(base+off)*CFrame.Angles(0,math.rad(22*i),math.rad(34)),Enum.Material.Fabric,Color3.fromRGB(66,83,62),camp,0,false);t.CanCollide=false
end
local fireBase=mk("SocialCampfire",Vector3.new(7,1,7),CFrame.new(base+Vector3.new(10,1,17)),Enum.Material.Slate,Color3.fromRGB(70,69,64));fireBase.Shape=Enum.PartType.Cylinder
local fire=Instance.new("Fire");fire.Size=5;fire.Heat=7;fire.Color=Color3.fromRGB(255,170,80);fire.Parent=fireBase
local light=Instance.new("PointLight");light.Range=22;light.Brightness=2;light.Color=Color3.fromRGB(255,176,92);light.Parent=fireBase
for i=1,4 do local a=i/4*math.pi*2;mk("SeatLog"..i,Vector3.new(9,1.4,1.6),CFrame.new(base+Vector3.new(10+math.cos(a)*10,1.2,17+math.sin(a)*10))*CFrame.Angles(0,-a,0),Enum.Material.Wood,Color3.fromRGB(81,58,39)) end
-- Route board.
local board=mk("RouteBoard",Vector3.new(16,10,1),CFrame.new(base+Vector3.new(33,6,-27))*CFrame.Angles(0,math.rad(-22),0),Enum.Material.WoodPlanks,Color3.fromRGB(72,55,39))
local bg=Instance.new("SurfaceGui");bg.Face=Enum.NormalId.Front;bg.PixelsPerStud=30;bg.Parent=board
local bt=Instance.new("TextLabel");bt.Size=UDim2.fromScale(1,1);bt.BackgroundTransparency=1;bt.Text="12 CHECKPOINTS\nFOREST • WATERFALL • RIDGE\nCLOUD SEA • SUMMIT";bt.TextScaled=true;bt.TextWrapped=true;bt.Font=Enum.Font.GothamMedium;bt.TextColor3=Color3.fromRGB(229,222,202);bt.Parent=bg
-- Natural edge blockers so spawn reads as a clearing, not empty world.
math.randomseed(210826)
for i=1,34 do local a=i/34*math.pi*2;local r=math.random(42,62);local pos=base+Vector3.new(math.cos(a)*r,0,math.sin(a)*r);if pos.Z>base.Z-50 then
 local rock=mk("BoundaryRock"..i,Vector3.new(math.random(4,10),math.random(3,7),math.random(4,10)),CFrame.new(pos)*CFrame.Angles(math.random(),math.random(),math.random()),Enum.Material.Rock,Color3.fromRGB(82,85,82),camp);rock.Shape=Enum.PartType.Ball
 end end
-- Make technical spawn invisible but solid and centered on safe ground.
local spawn=root:FindFirstChild("MountainSpawn");if spawn and spawn:IsA("SpawnLocation") then spawn.CFrame=CFrame.new(base+Vector3.new(0,1,10));spawn.Transparency=1;spawn.CanCollide=true;spawn.Duration=0 end
root:SetAttribute("BasecampVersion","2.1");root:SetAttribute("BuildVersion","2.1.0-basecamp-rebuild")
print("[ACC] Basecamp ACC v2.1 rebuilt")