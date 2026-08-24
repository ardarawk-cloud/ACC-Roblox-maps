print("[BBYA_JOB_BEGIN:mall-cloud-visual-l1-commerce-v410]")
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")
print("STATE|running="..tostring(RunService:IsRunning()).."|studio="..tostring(RunService:IsStudio()))

task.wait(4)
local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
local mall=root and root:FindFirstChild("BBYAMall")
print("MALL|root="..tostring(root~=nil).."|mall="..tostring(mall~=nil).."|pass="..tostring(mall and mall:GetAttribute("Pass")).."|floors="..tostring(mall and mall:GetAttribute("Floors")))
if mall then
 for _,id in ipairs({"luma","stride","muse","north","glow"}) do
  local unit=mall:FindFirstChild("Tenant_"..id)
  if unit and unit:IsA("Model") then
   local cf,sz=unit:GetBoundingBox()
   print(string.format("TENANT|%s|pos=%.1f,%.1f,%.1f|size=%.1f,%.1f,%.1f|native=%s",id,cf.Position.X,cf.Position.Y,cf.Position.Z,sz.X,sz.Y,sz.Z,tostring(unit:GetAttribute("NativeRobuxShop"))))
   for _,name in ipairs({"SideA","SideB","StoreGlass","StoreDoor","StoreSign","Counter","Interact"}) do
    local d=unit:FindFirstChild(name)
    if d and d:IsA("BasePart") then
     print(string.format("PART|%s/%s|pos=%.1f,%.1f,%.1f|size=%.1f,%.1f,%.1f|trans=%.2f|collide=%s",id,name,d.Position.X,d.Position.Y,d.Position.Z,d.Size.X,d.Size.Y,d.Size.Z,d.Transparency,tostring(d.CanCollide)))
    end
   end
  else
   print("TENANT|"..id.."|MISSING")
  end
 end
 for _,name in ipairs({"MallArchitectureV3","MallLiveUpgradeV2","MallRobuxCommerceV1","StorefrontAuthorityV4"}) do
  local d=mall:FindFirstChild(name)
  print("MODEL|"..name.."="..tostring(d~=nil))
 end
end

local p=Players:GetPlayers()[1]
if p and p.Character then
 local hrp=p.Character:FindFirstChild("HumanoidRootPart")
 if hrp then
  hrp.Anchored=true
  hrp.CFrame=CFrame.lookAt(Vector3.new(0,5,323),Vector3.new(70,6,330))
 end
end
local cam=Workspace.CurrentCamera
if cam then
 cam.CameraType=Enum.CameraType.Scriptable
 cam.FieldOfView=72
 cam.CFrame=CFrame.lookAt(Vector3.new(0,7,323),Vector3.new(70,6,330))
 print("CAMERA|mall_l1_commerce=true|pos="..tostring(cam.CFrame.Position))
end

task.wait(10)
print("[BBYA_JOB_END:mall-cloud-visual-l1-commerce-v410]")
