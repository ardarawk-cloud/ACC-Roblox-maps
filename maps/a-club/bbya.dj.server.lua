-- BBYA resident DJ NPC / booth performer v1.2
local TweenService=game:GetService("TweenService")

local old=workspace:FindFirstChild("BBYA Resident DJ")
if old then old:Destroy() end

local booth=workspace:WaitForChild("DJ Booth",15)
if not booth then warn("[BBYA DJ] DJ Booth not found");return end

-- Explicitly clear the legacy center screen/column that blocks the performer sightline.
for _,name in ipairs({"DJ Screen Center","DJ Screen Left","DJ Screen Right"}) do
 local o=workspace:FindFirstChild(name)
 if o and o:IsA("BasePart") then
  if name=="DJ Screen Center" then
   o.Transparency=1;o.CanCollide=false;o.CanTouch=false;o.CanQuery=false
  else
   o.Transparency=.28;o.CanCollide=false
  end
 end
end
for _,o in ipairs(workspace:GetDescendants()) do
 if o:IsA("BasePart") and o~=booth then
  local lp=booth.CFrame:PointToObjectSpace(o.Position)
  local tall=o.Size.Y>=7
  local nearBooth=math.abs(lp.X)<6 and math.abs(lp.Z)<6 and math.abs(lp.Y)<9
  local ln=string.lower(o.Name)
  local obstruction=string.find(ln,"pillar") or string.find(ln,"column") or string.find(ln,"support") or string.find(ln,"post") or string.find(ln,"wall") or string.find(ln,"screen center")
  if tall and nearBooth and obstruction then o.Transparency=1;o.CanCollide=false;o.CanTouch=false;o.CanQuery=false end
 end
end

local model=Instance.new("Model");model.Name="BBYA Resident DJ";model.Parent=workspace
local function p(name,size,cf,color,material)
 local x=Instance.new("Part");x.Name=name;x.Size=size;x.CFrame=cf;x.Anchored=true;x.CanCollide=false;x.Color=color;x.Material=material or Enum.Material.SmoothPlastic;x.Parent=model;return x
end
local facing=booth.CFrame*CFrame.Angles(0,math.pi,0)
local base=facing*CFrame.new(0,4.8,1.15)
local torso=p("Torso",Vector3.new(3.4,4.4,1.8),base,Color3.fromRGB(24,24,30),Enum.Material.Fabric)
local head=p("Head",Vector3.new(2.2,2.2,2.2),base*CFrame.new(0,3.1,0),Color3.fromRGB(218,170,132))
p("Hair",Vector3.new(2.45,.7,2.45),head.CFrame*CFrame.new(0,1.05,0),Color3.fromRGB(18,18,24))
local leftArm=p("Left Arm",Vector3.new(1.2,4,1.2),base*CFrame.new(-2.2,.1,-.35)*CFrame.Angles(math.rad(-25),0,math.rad(-10)),Color3.fromRGB(218,170,132))
local rightArm=p("Right Arm",Vector3.new(1.2,4,1.2),base*CFrame.new(2.2,.1,-.35)*CFrame.Angles(math.rad(-25),0,math.rad(10)),Color3.fromRGB(218,170,132))
p("Left Leg",Vector3.new(1.35,3.6,1.45),base*CFrame.new(-.9,-3.7,0),Color3.fromRGB(20,20,26),Enum.Material.Fabric)
p("Right Leg",Vector3.new(1.35,3.6,1.45),base*CFrame.new(.9,-3.7,0),Color3.fromRGB(20,20,26),Enum.Material.Fabric)
p("Headphone Band",Vector3.new(2.8,.28,2.8),head.CFrame*CFrame.new(0,.6,0),Color3.fromRGB(255,70,190),Enum.Material.Neon)
p("Headphone L",Vector3.new(.45,1.2,.8),head.CFrame*CFrame.new(-1.25,.15,0),Color3.fromRGB(30,30,38),Enum.Material.Metal)
p("Headphone R",Vector3.new(.45,1.2,.8),head.CFrame*CFrame.new(1.25,.15,0),Color3.fromRGB(30,30,38),Enum.Material.Metal)
local logo=Instance.new("SurfaceGui");logo.Face=Enum.NormalId.Front;logo.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;logo.PixelsPerStud=30;logo.Parent=torso
local txt=Instance.new("TextLabel");txt.BackgroundTransparency=1;txt.Size=UDim2.fromScale(1,1);txt.Font=Enum.Font.GothamBlack;txt.Text="BBYA DJ";txt.TextColor3=Color3.fromRGB(255,80,210);txt.TextScaled=true;txt.Parent=logo
local deck=p("DJ Deck",Vector3.new(10,1,3.8),facing*CFrame.new(0,2.7,-2.15),Color3.fromRGB(20,20,28),Enum.Material.Metal)
for _,x in ipairs({-3,-1,1,3}) do p("Deck Light",Vector3.new(.35,.18,.35),deck.CFrame*CFrame.new(x,.58,-.3),x<0 and Color3.fromRGB(255,60,190) or Color3.fromRGB(60,190,255),Enum.Material.Neon) end
local tag=Instance.new("BillboardGui");tag.Size=UDim2.fromOffset(132,28);tag.StudsOffset=Vector3.new(0,4.2,0);tag.MaxDistance=45;tag.AlwaysOnTop=false;tag.Parent=head
local tl=Instance.new("TextLabel");tl.BackgroundTransparency=1;tl.Size=UDim2.fromScale(1,1);tl.Font=Enum.Font.GothamBold;tl.Text="RESIDENT DJ";tl.TextColor3=Color3.fromRGB(255,100,220);tl.TextStrokeTransparency=.4;tl.TextScaled=true;tl.Parent=tag
local l0,r0=leftArm.CFrame,rightArm.CFrame
task.spawn(function()
 while model.Parent do
  TweenService:Create(leftArm,TweenInfo.new(.45,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{CFrame=l0*CFrame.Angles(math.rad(-18),0,math.rad(-12))}):Play()
  TweenService:Create(rightArm,TweenInfo.new(.45,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{CFrame=r0*CFrame.Angles(math.rad(12),0,math.rad(16))}):Play();task.wait(.5)
  TweenService:Create(leftArm,TweenInfo.new(.45,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{CFrame=l0*CFrame.Angles(math.rad(8),0,math.rad(8))}):Play()
  TweenService:Create(rightArm,TweenInfo.new(.45,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{CFrame=r0*CFrame.Angles(math.rad(-15),0,math.rad(-10))}):Play();task.wait(.5)
 end
end)
print("[BBYA DJ] v1.2 center obstruction cleared")