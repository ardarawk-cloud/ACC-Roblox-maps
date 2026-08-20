print("[BBYA_JOB_BEGIN:vip-geometric-white-ceiling-qc-007]")
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")
print("STATE|running="..tostring(RunService:IsRunning()).."|studio="..tostring(RunService:IsStudio()))

local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
local upper=root and root:FindFirstChild("UpperLevels")
local vip=upper and upper:FindFirstChild("L2_VIP_Level")
local premium=vip and vip:FindFirstChild("PremiumVIPPass")
local ceiling=premium and premium:FindFirstChild("VIPCeiling")
local pass=ceiling and ceiling:FindFirstChild("GeometricWhiteCeiling")
print("VIP|root="..tostring(root~=nil).."|upper="..tostring(upper~=nil).."|level="..tostring(vip~=nil).."|premium="..tostring(premium~=nil).."|ceiling="..tostring(ceiling~=nil).."|geo="..tostring(pass~=nil))

local segments=0
local emitters=0
local downlights=0
local nonWhite=0
local minY,maxY=999,-999
local minX,maxX,minZ,maxZ=999,-999,999,-999
if pass then
 for _,d in ipairs(pass:GetDescendants()) do
  if d:IsA("Model") and d.Name:match("_S%d%d$") then segments+=1 end
  if d:IsA("SurfaceLight") and d.Name=="Downlight" then downlights+=1 end
  if d:IsA("BasePart") and d.Name=="Emitter" then
   emitters+=1
   local p=d.Position
   minY=math.min(minY,p.Y);maxY=math.max(maxY,p.Y)
   minX=math.min(minX,p.X);maxX=math.max(maxX,p.X);minZ=math.min(minZ,p.Z);maxZ=math.max(maxZ,p.Z)
   local c=d.Color
   if math.abs(c.R-c.G)>.015 or math.abs(c.G-c.B)>.015 or c.R<.92 then nonWhite+=1 end
  end
 end
 print("COUNTS|segments="..segments.."|emitters="..emitters.."|downlights="..downlights.."|nonWhite="..nonWhite)
 print(string.format("HEIGHT|emitterY=%.2f..%.2f|roofUnderside=44.00|gap=%.2f",minY,maxY,44-maxY))
 print(string.format("BOUNDS|x=%.1f..%.1f|z=%.1f..%.1f",minX,maxX,minZ,maxZ))
 print("META|ceilingY="..tostring(pass:GetAttribute("CeilingY")).."|style="..tostring(pass:GetAttribute("LightingStyle")).."|whiteOnly="..tostring(pass:GetAttribute("WhiteOnly")).."|shape="..tostring(pass:GetAttribute("ReferenceShape")))
end

local ps=Players:GetPlayers();local p=ps[1]
if p then
 local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
 if hrp then hrp.CFrame=CFrame.lookAt(Vector3.new(0,26,-8),Vector3.new(0,40,10));print("TELEPORT|ok=true") end
end
local cam=Workspace.CurrentCamera
if cam then
 cam.CameraType=Enum.CameraType.Scriptable
 cam.FieldOfView=72
 cam.CFrame=CFrame.lookAt(Vector3.new(0,29,-27),Vector3.new(0,43.5,8))
 print("CAMERA|ceiling_reference_view=true|pos="..tostring(cam.CFrame.Position))
end
task.wait(5)
print("[BBYA_JOB_END:vip-geometric-white-ceiling-qc-007]")
