print("[BBYA_JOB_BEGIN:reception-concierge-cloud-audit-v1]")
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")

task.wait(5)
local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
local front=root and root:FindFirstChild("Floor1FrontPremium")
print("STATE|running="..tostring(RunService:IsRunning()).."|root="..tostring(root~=nil).."|front="..tostring(front~=nil))

local function worldPos(inst)
 local p=inst.Parent
 while p do
  if p:IsA("BasePart") then return p.Position end
  p=p.Parent
 end
 return nil
end

local total=0
for _,d in ipairs(Workspace:GetDescendants()) do
 if d:IsA("ProximityPrompt") then
  local action=string.upper(d.ActionText or "")
  local object=string.upper(d.ObjectText or "")
  local pos=worldPos(d)
  local inFront=pos and pos.Z>=-42 and pos.Z<=-5 and math.abs(pos.X)<=35
  if inFront or action:find("CHECK") or object:find("RECEPTION") or action:find("TRAVEL") or object:find("TRAVEL") then
   total+=1
   print("PROMPT|"..d:GetFullName().."|action="..tostring(d.ActionText).."|object="..tostring(d.ObjectText).."|enabled="..tostring(d.Enabled).."|pos="..tostring(pos))
  end
 end
end
print("PROMPTCOUNT="..total)

if front then
 local reception=front:FindFirstChild("Reception",true)
 print("RECEPTION|present="..tostring(reception~=nil))
 if reception then
  local cf,sz=reception:GetBoundingBox()
  print(string.format("RECEPTIONBOUND|pos=%.1f,%.1f,%.1f|size=%.1f,%.1f,%.1f",cf.Position.X,cf.Position.Y,cf.Position.Z,sz.X,sz.Y,sz.Z))
 end
end

local p=Players:GetPlayers()[1]
if p and p.Character then
 local hrp=p.Character:FindFirstChild("HumanoidRootPart")
 if hrp then
  hrp.Anchored=true
  hrp.CFrame=CFrame.lookAt(Vector3.new(0,2.8,-37),Vector3.new(0,3.8,-24))
 end
end
local cam=Workspace.CurrentCamera
if cam then
 cam.CameraType=Enum.CameraType.Scriptable
 cam.FieldOfView=72
 cam.CFrame=CFrame.lookAt(Vector3.new(0,7.4,-40),Vector3.new(0,4.6,-24))
 print("CAMERA|reception=true|pos="..tostring(cam.CFrame.Position))
end

task.wait(10)
print("[BBYA_JOB_END:reception-concierge-cloud-audit-v1]")
