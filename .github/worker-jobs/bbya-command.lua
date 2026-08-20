print("[BBYA_JOB_BEGIN:vip-linear-ceiling-qc-006]")
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")
print("STATE|running="..tostring(RunService:IsRunning()).."|studio="..tostring(RunService:IsStudio()))

local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
local upper=root and root:FindFirstChild("UpperLevels")
local vip=upper and upper:FindFirstChild("L2_VIP_Level")
local premium=vip and vip:FindFirstChild("PremiumVIPPass")
local ceiling=premium and premium:FindFirstChild("VIPCeiling")
local pass=ceiling and ceiling:FindFirstChild("LinearCeilingPass")
print("VIP|root="..tostring(root~=nil).."|upper="..tostring(upper~=nil).."|level="..tostring(vip~=nil).."|premium="..tostring(premium~=nil).."|ceiling="..tostring(ceiling~=nil).."|linear="..tostring(pass~=nil))

local fixtures=0
local surfaceLights=0
local pointLights=0
local emitters=0
local minX,maxX,minZ,maxZ=999,-999,999,-999
if pass then
 for _,d in ipairs(pass:GetDescendants()) do
  if d:IsA("Model") and d.Name:match("^LinearStrip") then fixtures+=1 end
  if d:IsA("SurfaceLight") then surfaceLights+=1 end
  if d:IsA("PointLight") then pointLights+=1 end
  if d:IsA("BasePart") and d.Name=="Emitter" then
   emitters+=1
   local p=d.Position
   minX=math.min(minX,p.X);maxX=math.max(maxX,p.X);minZ=math.min(minZ,p.Z);maxZ=math.max(maxZ,p.Z)
  end
 end
 print("COUNTS|fixtures="..fixtures.."|emitters="..emitters.."|surfaceLights="..surfaceLights.."|pointLights="..pointLights)
 print(string.format("BOUNDS|x=%.1f..%.1f|z=%.1f..%.1f",minX,maxX,minZ,maxZ))
 print("META|fixtureAttr="..tostring(pass:GetAttribute("FixtureCount")).."|style="..tostring(pass:GetAttribute("LightingStyle")).."|floor1Untouched="..tostring(pass:GetAttribute("Floor1Untouched")))
end

local ps=Players:GetPlayers();local p=ps[1]
if p then
 local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
 if hrp then hrp.CFrame=CFrame.lookAt(Vector3.new(0,27,-8),Vector3.new(0,31,14));print("TELEPORT|ok=true") end
end
local cam=Workspace.CurrentCamera
if cam then
 cam.CameraType=Enum.CameraType.Scriptable
 cam.FieldOfView=76
 cam.CFrame=CFrame.lookAt(Vector3.new(0,28,-18),Vector3.new(3,34,13))
 print("CAMERA|ceiling_overview=true|pos="..tostring(cam.CFrame.Position))
end
task.wait(5)
print("[BBYA_JOB_END:vip-linear-ceiling-qc-006]")
