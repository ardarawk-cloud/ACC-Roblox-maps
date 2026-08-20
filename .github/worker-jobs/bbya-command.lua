print("[BBYA_JOB_BEGIN:vip-minimal-standing-qc-008]")
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")
print("STATE|running="..tostring(RunService:IsRunning()).."|studio="..tostring(RunService:IsStudio()))

local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
local upper=root and root:FindFirstChild("UpperLevels")
local vip=upper and upper:FindFirstChild("L2_VIP_Level")
local minimal=vip and vip:FindFirstChild("VIPMinimalStanding")
local oldPremium=vip and vip:FindFirstChild("PremiumVIPPass")
local oldCeiling=vip and vip:FindFirstChild("VIPCeiling")
print("VIP|root="..tostring(root~=nil).."|upper="..tostring(upper~=nil).."|level="..tostring(vip~=nil).."|minimal="..tostring(minimal~=nil).."|oldPremium="..tostring(oldPremium~=nil).."|oldCeiling="..tostring(oldCeiling~=nil))

local parts,seats,neon,surfaces,prompts,sounds=0,0,0,0,0,0
local soundPlaying=false
local soundVolume=-1
local soundMax=-1
local named={}
if minimal then
 for _,d in ipairs(minimal:GetDescendants()) do
  if d:IsA("BasePart") then
   parts+=1
   if d:IsA("Seat") or d:IsA("VehicleSeat") then seats+=1 end
   if d.Material==Enum.Material.Neon then neon+=1 end
   named[d.Name]=true
  elseif d:IsA("SurfaceGui") or d:IsA("BillboardGui") then
   surfaces+=1
  elseif d:IsA("ProximityPrompt") then
   prompts+=1
  elseif d:IsA("Sound") then
   sounds+=1
   if d.Name=="VIPAmbientSound" then
    soundPlaying=d.IsPlaying
    soundVolume=d.Volume
    soundMax=d.RollOffMaxDistance
   end
  end
 end
 print("META|standingOnly="..tostring(minimal:GetAttribute("StandingOnly")).."|furniture="..tostring(minimal:GetAttribute("FurnitureCount")).."|decor="..tostring(minimal:GetAttribute("DecorCount")).."|floor1Untouched="..tostring(minimal:GetAttribute("Floor1Untouched")))
end
print("COUNTS|parts="..parts.."|seats="..seats.."|neon="..neon.."|gui="..surfaces.."|prompts="..prompts.."|sounds="..sounds)
print("SOUND|playing="..tostring(soundPlaying).."|volume="..tostring(soundVolume).."|maxDistance="..tostring(soundMax))
print("ESSENTIAL|north="..tostring(named.NorthStandingFloor==true).."|south="..tostring(named.SouthStandingFloor==true).."|west="..tostring(named.WestStandingFloor==true).."|east="..tostring(named.EastStandingFloor==true).."|speakerL="..tostring(named.VIPSpeakerL==true).."|speakerR="..tostring(named.VIPSpeakerR==true))

local ps=Players:GetPlayers();local p=ps[1]
if p then
 local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
 if hrp then hrp.CFrame=CFrame.lookAt(Vector3.new(46,27,-5),Vector3.new(0,26,22));print("TELEPORT|ok=true") end
end
local cam=Workspace.CurrentCamera
if cam then
 cam.CameraType=Enum.CameraType.Scriptable
 cam.FieldOfView=82
 cam.CFrame=CFrame.lookAt(Vector3.new(49,32,-22),Vector3.new(0,26,22))
 print("CAMERA|minimal_vip_overview=true|pos="..tostring(cam.CFrame.Position))
end
task.wait(5)
print("[BBYA_JOB_END:vip-minimal-standing-qc-008]")
