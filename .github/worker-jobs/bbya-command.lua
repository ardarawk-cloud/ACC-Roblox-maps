print("[BBYA_JOB_BEGIN:batch-live-visual-qc-001]")
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")
local Terrain=Workspace.Terrain
print("STATE|running="..tostring(RunService:IsRunning()).."|studio="..tostring(RunService:IsStudio()))

local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
local front=root and root:FindFirstChild("Floor1FrontPremium")
local photo=front and front:FindFirstChild("PhotoAreaPremium")
local photoLights=photo and photo:FindFirstChild("PhotoStudioLightingUpgrade")
local street=root and root:FindFirstChild("EntranceStreetScene")
local upper=root and root:FindFirstChild("UpperLevels")
local rooftop=upper and upper:FindFirstChild("R_Rooftop")
local pool=rooftop and rooftop:FindFirstChild("RooftopPool")

local studioSurfaceLights,studioPointLights=0,0
if photoLights then
 for _,d in ipairs(photoLights:GetDescendants()) do
  if d:IsA("SurfaceLight") then studioSurfaceLights+=1 end
  if d:IsA("PointLight") then studioPointLights+=1 end
 end
end
print("PHOTO|front="..tostring(front~=nil).."|photo="..tostring(photo~=nil).."|upgrade="..tostring(photoLights~=nil).."|surfaceLights="..studioSurfaceLights.."|pointLights="..studioPointLights)

local road=street and street:FindFirstChild("MainRoad")
local red=street and street:FindFirstChild("CloudCarSlot_Red")
local blue=street and street:FindFirstChild("CloudCarSlot_Blue")
print("STREET|scene="..tostring(street~=nil).."|road="..tostring(road~=nil).."|redCar="..tostring(red~=nil).."|blueCar="..tostring(blue~=nil))

local roofNeon=0
if rooftop then
 for _,d in ipairs(rooftop:GetDescendants()) do
  if d:IsA("BasePart") and d.Material==Enum.Material.Neon then roofNeon+=1 end
 end
end
local waterFound=false
local ok,err=pcall(function()
 local region=Region3.new(Vector3.new(-4,42,8),Vector3.new(4,46,16)):ExpandToGrid(4)
 local materials,occupancy=Terrain:ReadVoxels(region,4)
 for x=1,#materials do
  for y=1,#materials[x] do
   for z=1,#materials[x][y] do
    if materials[x][y][z]==Enum.Material.Water and occupancy[x][y][z]>0 then waterFound=true end
   end
  end
 end
end)
print("ROOFTOP|exists="..tostring(rooftop~=nil).."|poolModel="..tostring(pool~=nil).."|terrainWater="..tostring(waterFound).."|noNeonAttr="..tostring(rooftop and rooftop:GetAttribute("NoNeon")).."|neonParts="..roofNeon.."|waterCheckOk="..tostring(ok))
if not ok then print("ROOFTOP_WATER_ERROR|"..tostring(err)) end

local p=Players:GetPlayers()[1]
local socialGui=p and p:FindFirstChildOfClass("PlayerGui") and p.PlayerGui:FindFirstChild("BBYASocialHangoutUI")
local safePanel=socialGui and socialGui:FindFirstChild("SocialSafePanel",true)
print("SOCIAL|gui="..tostring(socialGui~=nil).."|safePanel="..tostring(safePanel~=nil))

if p then
 local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
 if hrp then
  hrp.CFrame=CFrame.lookAt(Vector3.new(0,47,-33),Vector3.new(0,46,8))
  print("TELEPORT|rooftop=true")
 end
end

local cam=Workspace.CurrentCamera
if cam then
 cam.CameraType=Enum.CameraType.Scriptable
 cam.FieldOfView=72
 cam.CFrame=CFrame.lookAt(Vector3.new(0,68,-73),Vector3.new(0,46,6))
 print("CAMERA|rooftop_resort=true|pos="..tostring(cam.CFrame.Position))
end

task.wait(8)
print("[BBYA_JOB_END:batch-live-visual-qc-001]")
