-- [SYS-LIFT] B3 THREE-LEVEL LIFT / SAFE TRANSFER
local liftCooldown={}
local floorCF={GROUND=CFrame.new(72,4,96),VIP=CFrame.new(72,22,96),ROOF=CFrame.new(72,40,96)}
local function canVIP(p)
 return p.UserId==QUEEN_ID or p:GetAttribute("BBYAAllAccess")==true or p:GetAttribute("IsVIP")==true or workspace:GetAttribute("BBYAMonetizationConfigured")~=true
end
local function travel(p,dest)
 dest=string.upper(tostring(dest or ""));local cf=floorCF[dest];if not cf or not p.Character then return end
 if dest=="VIP" and not canVIP(p) then NoticeRemote:FireClient(p,"VIP access required");return end
 local now=os.clock();if liftCooldown[p.UserId] and now-liftCooldown[p.UserId]<1.5 then return end;liftCooldown[p.UserId]=now
 NoticeRemote:FireClient(p,"BBYA SKY LIFT • "..dest)
 task.delay(.45,function() if p.Character then p.Character:PivotTo(cf) end end)
end
LiftRemote.OnServerEvent:Connect(travel)

local rootV5=workspace:FindFirstChild("BBYA V5.2 MODULAR GREYBOX")
local b3=rootV5 and rootV5:FindFirstChild("[B3] LIFT CORE")
if b3 then
 local function station(name,pos,dest,color)
  local p=Instance.new("Part");p.Name="B3 | LIFT BUTTON "..name;p.Size=Vector3.new(1.2,2.4,.45);p.CFrame=CFrame.new(pos);p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.Material=Enum.Material.Metal;p.Color=Color3.fromRGB(28,28,34);p:SetAttribute("BBYAZoneCode","B3");p:SetAttribute("BBYAZoneName","LIFT CORE");p.Parent=b3
  local prompt=Instance.new("ProximityPrompt");prompt.ActionText="GO "..dest;prompt.ObjectText="BBYA SKY LIFT";prompt.HoldDuration=.15;prompt.MaxActivationDistance=9;prompt.RequiresLineOfSight=false;prompt.Parent=p
  prompt.Triggered:Connect(function(plr) travel(plr,dest) end)
  local light=Instance.new("SurfaceLight");light.Face=Enum.NormalId.Front;light.Brightness=.4;light.Range=5;light.Color=color;light.Shadows=false;light.Parent=p
 end
 station("G TO VIP",Vector3.new(70.5,3,99.4),"VIP",Color3.fromRGB(255,194,72))
 station("G TO ROOF",Vector3.new(75.5,3,99.4),"ROOF",Color3.fromRGB(255,176,94))
 station("VIP TO G",Vector3.new(70.5,21,99.4),"GROUND",Color3.fromRGB(20,218,255))
 station("VIP TO ROOF",Vector3.new(75.5,21,99.4),"ROOF",Color3.fromRGB(255,176,94))
 station("ROOF TO G",Vector3.new(70.5,39,99.4),"GROUND",Color3.fromRGB(20,218,255))
 station("ROOF TO VIP",Vector3.new(75.5,39,99.4),"VIP",Color3.fromRGB(255,194,72))
end
workspace:SetAttribute("BBYASystemLift","5.0")
