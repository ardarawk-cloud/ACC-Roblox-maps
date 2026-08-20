print("[BBYA_JOB_BEGIN:vip-live-audit-004]")
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")
print("STATE|running="..tostring(RunService:IsRunning()).."|studio="..tostring(RunService:IsStudio()))
local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
local upper=root and root:FindFirstChild("UpperLevels")
local vip=upper and upper:FindFirstChild("L2_VIP_Level")
local pass=vip and vip:FindFirstChild("PremiumVIPPass")
print("VIP|root="..tostring(root~=nil).."|upper="..tostring(upper~=nil).."|level="..tostring(vip~=nil).."|pass="..tostring(pass~=nil))
local function report(name,obj)
 if not obj then print("OBJ|"..name.."|missing") return end
 local count=#obj:GetDescendants()
 print("OBJ|"..name.."|"..obj.ClassName.."|desc="..tostring(count))
end
if pass then
 for _,name in ipairs({"VIPEntry","GlassBalcony","NorthSkyLounge","VIPBar","PrivateSocialBooths","VIPCeiling"}) do report(name,pass:FindFirstChild(name)) end
 local parts=0;local seats=0;local lights=0
 for _,d in ipairs(pass:GetDescendants()) do
  if d:IsA("BasePart") then parts+=1 end
  if d:IsA("Seat") then seats+=1 end
  if d:IsA("Light") then lights+=1 end
 end
 print("COUNTS|parts="..parts.."|seats="..seats.."|lights="..lights)
end
local ps=Players:GetPlayers();local player=ps[1]
if player then
 local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if hrp then hrp.CFrame=CFrame.lookAt(Vector3.new(5,27,-14),Vector3.new(0,27,30));print("TELEPORT|ok=true") end
end
local cam=Workspace.CurrentCamera
if cam then
 cam.CameraType=Enum.CameraType.Scriptable
 cam.FieldOfView=72
 cam.CFrame=CFrame.lookAt(Vector3.new(0,33,-34),Vector3.new(0,28,31))
 print("CAMERA|overview=true|pos="..tostring(cam.CFrame.Position))
end
task.wait(4)
print("[BBYA_JOB_END:vip-live-audit-004]")
