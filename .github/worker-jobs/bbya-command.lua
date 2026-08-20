print("[BBYA_JOB_BEGIN:vip-live-visual-qc-009]")
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")
print("STATE|running="..tostring(RunService:IsRunning()).."|studio="..tostring(RunService:IsStudio()))

local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
local upper=root and root:FindFirstChild("UpperLevels")
local vip=upper and upper:FindFirstChild("L2_VIP_Level")
local minimal=vip and vip:FindFirstChild("VIPMinimalStanding")
local restore=minimal and minimal:FindFirstChild("VIPNeonRoofSoundRestore")
local neonPass=restore and restore:FindFirstChild("PerimeterNeonTrim")
local roofPass=restore and restore:FindFirstChild("RoofDownlights")
local soundPass=restore and restore:FindFirstChild("SuspendedCornerSound")

print("VIP|root="..tostring(root~=nil).."|upper="..tostring(upper~=nil).."|level="..tostring(vip~=nil).."|minimal="..tostring(minimal~=nil).."|restore="..tostring(restore~=nil))

local neonCount,downlightCount,clusterCount,speakerCount,soundCount=0,0,0,0,0
if neonPass then
 for _,d in ipairs(neonPass:GetDescendants()) do
  if d:IsA("BasePart") and d.Material==Enum.Material.Neon then neonCount+=1 end
 end
end
if roofPass then
 for _,d in ipairs(roofPass:GetDescendants()) do
  if d:IsA("SurfaceLight") and d.Name=="RoofDownlight" then downlightCount+=1 end
 end
end
if soundPass then
 for _,d in ipairs(soundPass:GetChildren()) do
  if d:IsA("Model") and d.Name:match("^CornerCluster_") then clusterCount+=1 end
 end
 for _,d in ipairs(soundPass:GetDescendants()) do
  if d:IsA("BasePart") and (d.Name=="SpeakerUpper" or d.Name=="SpeakerLower") then speakerCount+=1 end
  if d:IsA("Sound") and d.Name=="CornerSpatialAudio" then soundCount+=1 end
 end
end

print("RESTORE|neon="..neonCount.."|downlights="..downlightCount.."|clusters="..clusterCount.."|speakers="..speakerCount.."|sounds="..soundCount)
if restore then
 print("ATTR|neonSegments="..tostring(restore:GetAttribute("NeonSegmentCount")).."|roofLights="..tostring(restore:GetAttribute("RoofDownlightCount")).."|speakerCabinets="..tostring(restore:GetAttribute("SpeakerCabinetCount")).."|speakerClusters="..tostring(restore:GetAttribute("SpeakerClusterCount")))
end

local ps=Players:GetPlayers();local p=ps[1]
if p then
 local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
 if hrp then
  hrp.CFrame=CFrame.lookAt(Vector3.new(0,27,-31),Vector3.new(0,34,0))
  print("TELEPORT|ok=true")
 end
end

local cam=Workspace.CurrentCamera
if cam then
 cam.CameraType=Enum.CameraType.Scriptable
 cam.FieldOfView=78
 cam.CFrame=CFrame.lookAt(Vector3.new(0,34,-58),Vector3.new(0,38,2))
 print("CAMERA|vip_neon_roof_sound=true|pos="..tostring(cam.CFrame.Position))
end

task.wait(6)
print("[BBYA_JOB_END:vip-live-visual-qc-009]")
