-- ACC Mountain Social Adventure — POS 1 trailhead rebuild v4.1
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("ACC_MountainSocial")
local old=root:FindFirstChild("BasecampACC");if old then old:Destroy() end
local camp=Instance.new("Model");camp.Name="BasecampACC";camp.Parent=root
local base=Vector3.new(-55,44,-30)
local function mk(n,s,cf,m,c,p,tr,coll)
 local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Material=m or Enum.Material.Wood;if c then x.Color=c end;x.Transparency=tr or 0;x.CanCollide=coll~=false;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=p or camp;return x
end
mk("TrailheadClearing",Vector3.new(94,3,78),CFrame.new(base-Vector3.new(0,1.6,0)),Enum.Material.Ground,Color3.fromRGB(100,84,62),camp)
mk("SmallParking",Vector3.new(54,2,31),CFrame.new(base+Vector3.new(36,-1,17)),Enum.Material.Pebble,Color3.fromRGB(105,101,91),camp)
local h=base+Vector3.new(-32,2,18)
mk("HutFloor",Vector3.new(30,1,20),CFrame.new(h),Enum.Material.WoodPlanks,Color3.fromRGB(94,69,46),camp)
mk("HutBody",Vector3.new(28,11,18),CFrame.new(h+Vector3.new(0,6,0)),Enum.Material.WoodPlanks,Color3.fromRGB(115,83,54),camp)
mk("HutRoof",Vector3.new(34,2,24),CFrame.new(h+Vector3.new(0,13,0)),Enum.Material.Metal,Color3.fromRGB(67,72,68),camp)
mk("RegistrationDesk",Vector3.new(11,4,3),CFrame.new(h+Vector3.new(0,3,-10)),Enum.Material.WoodPlanks,Color3.fromRGB(85,62,42),camp)
local g=base+Vector3.new(-4,4,-33)
mk("GateL",Vector3.new(3,15,3),CFrame.new(g+Vector3.new(-11,3,0)),Enum.Material.Wood,Color3.fromRGB(70,50,34),camp)
mk("GateR",Vector3.new(3,15,3),CFrame.new(g+Vector3.new(11,3,0)),Enum.Material.Wood,Color3.fromRGB(70,50,34),camp)
local sign=mk("TrailheadSign",Vector3.new(28,6,1),CFrame.new(g+Vector3.new(0,10,0)),Enum.Material.WoodPlanks,Color3.fromRGB(69,51,35),camp)
local sg=Instance.new("SurfaceGui");sg.Face=Enum.NormalId.Front;sg.PixelsPerStud=30;sg.Parent=sign
local tx=Instance.new("TextLabel");tx.Size=UDim2.fromScale(1,1);tx.BackgroundTransparency=1;tx.Text="POS 1 — KAKI GUNUNG\nJALUR PENDAKIAN DIMULAI";tx.TextScaled=true;tx.TextWrapped=true;tx.Font=Enum.Font.GothamBold;tx.TextColor3=Color3.fromRGB(238,229,202);tx.Parent=sg
local board=mk("RouteBoard",Vector3.new(20,12,1),CFrame.new(base+Vector3.new(33,7,-22))*CFrame.Angles(0,math.rad(-18),0),Enum.Material.WoodPlanks,Color3.fromRGB(77,58,41),camp)
local bg=Instance.new("SurfaceGui");bg.Face=Enum.NormalId.Front;bg.PixelsPerStud=28;bg.Parent=board
local bt=Instance.new("TextLabel");bt.Size=UDim2.fromScale(1,1);bt.BackgroundTransparency=1;bt.Text="RUTE UTAMA\nHUTAN BAWAH → SUNGAI → CAMP TENGAH\nTEBING → KABUT → HIGHLAND\nRIDGE → FALSE SUMMIT → PUNCAK";bt.TextScaled=true;bt.TextWrapped=true;bt.Font=Enum.Font.GothamMedium;bt.TextColor3=Color3.fromRGB(229,221,199);bt.Parent=bg
local fireBase=mk("Pos1Campfire",Vector3.new(6,1,6),CFrame.new(base+Vector3.new(18,1.5,27)),Enum.Material.Slate,Color3.fromRGB(72,70,65),camp);local fire=Instance.new("Fire");fire.Size=4;fire.Heat=6;fire.Parent=fireBase
for i=1,3 do local a=i/3*math.pi*2;mk("SeatLog"..i,Vector3.new(8,1.3,1.5),CFrame.new(base+Vector3.new(18+math.cos(a)*9,1.2,27+math.sin(a)*9))*CFrame.Angles(0,-a,0),Enum.Material.Wood,Color3.fromRGB(82,59,40),camp) end
root:SetAttribute("BasecampVersion","4.1");root:SetAttribute("BasecampRole","POS1_TRAILHEAD")
print("[ACC] POS 1 trailhead v4.1 ready")