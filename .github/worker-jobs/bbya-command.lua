print("[BBYA_JOB_BEGIN:funkot-diskotik-cloud-audit-v444]")
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local RunService=game:GetService("RunService")
print("STATE|running="..tostring(RunService:IsRunning()).."|studio="..tostring(RunService:IsStudio()).."|clock="..string.format("%.2f",Lighting.ClockTime))

task.wait(4)
local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
local club=root and root:FindFirstChild("FunkotClub")
print("FUNKOT|root="..tostring(root~=nil).."|club="..tostring(club~=nil).."|pass="..tostring(club and club:GetAttribute("Pass")).."|diskotikV2="..tostring(club and club:GetAttribute("DiskotikPremiumV2")))
if club then
 local cf,sz=club:GetBoundingBox()
 print(string.format("BOUND|pos=%.1f,%.1f,%.1f|size=%.1f,%.1f,%.1f",cf.Position.X,cf.Position.Y,cf.Position.Z,sz.X,sz.Y,sz.Z))
 for _,name in ipairs({"Stage","DJBoothBody","FunkotSign","EntrySign","CeilingTruss","MovingHeads","LaserRig","FunkotDiskotikPremiumV2"}) do
  local d=club:FindFirstChild(name,true)
  if d then
   if d:IsA("BasePart") then
    print(string.format("OBJECT|%s|%s|pos=%.1f,%.1f,%.1f|size=%.1f,%.1f,%.1f",name,d.ClassName,d.Position.X,d.Position.Y,d.Position.Z,d.Size.X,d.Size.Y,d.Size.Z))
   else
    print("OBJECT|"..name.."|"..d.ClassName.."|present=true")
   end
  else
   print("OBJECT|"..name.."|MISSING")
  end
 end
 local v2=club:FindFirstChild("FunkotDiskotikPremiumV2")
 if v2 then
  for _,name in ipairs({"DiskotikArrivalV2","MainDanceFloorV2","StagePrestigeV2","DiskotikCeilingFocalV2","DiskotikBarV2","BottleServiceV2","WallTreatmentV2"}) do
   local d=v2:FindFirstChild(name)
   print("V2MODEL|"..name.."="..tostring(d~=nil))
  end
  local seats=0 local lights=0 local parts=0
  for _,d in ipairs(v2:GetDescendants()) do
   if d:IsA("Seat") then seats+=1 end
   if d:IsA("Light") then lights+=1 end
   if d:IsA("BasePart") then parts+=1 end
  end
  print("V2COUNT|parts="..parts.."|seats="..seats.."|lights="..lights)
 end
end

local p=Players:GetPlayers()[1]
if p and p.Character then
 local hrp=p.Character:FindFirstChild("HumanoidRootPart")
 if hrp then
  hrp.Anchored=true
  hrp.CFrame=CFrame.lookAt(Vector3.new(0,3.2,181),Vector3.new(0,6,239))
 end
end
local cam=Workspace.CurrentCamera
if cam then
 cam.CameraType=Enum.CameraType.Scriptable
 cam.FieldOfView=82
 cam.CFrame=CFrame.lookAt(Vector3.new(0,10.5,178),Vector3.new(0,7.0,238))
 print("CAMERA|funkot_wide=true|pos="..tostring(cam.CFrame.Position))
end

task.wait(10)
print("[BBYA_JOB_END:funkot-diskotik-cloud-audit-v444]")
