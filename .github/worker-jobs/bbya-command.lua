print("[BBYA_JOB_BEGIN:mainclub-cloud-visual-v377]")
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")
print("STATE|running="..tostring(RunService:IsRunning()).."|studio="..tostring(RunService:IsStudio()))

task.wait(4)
local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
local front=root and root:FindFirstChild("Floor1FrontPremium")
local luxury=root and root:FindFirstChild("Floor1LuxuryFinish")
local ultra=root and root:FindFirstChild("Floor1UltraPremium")
local authority=root and root:FindFirstChild("MainClubFinalAuthorityV1")
local prior=root and root:FindFirstChild("ClubPurityMallStudiosV1")
local club=root and root:FindFirstChild("MainClubRealism")
local mall=root and root:FindFirstChild("BBYAMall")

local photo=front and front:FindFirstChild("PhotoAreaPremium")
local salon=front and front:FindFirstChild("SalonLookStudioPremium")
local oldPhoto=luxury and luxury:FindFirstChild("EditorialPhotoRoom")
local oldLook=luxury and luxury:FindFirstChild("LookLab")
local oldPhotoRef=ultra and ultra:FindFirstChild("EditorialPhotoRefinement")
local oldLookRef=ultra and ultra:FindFirstChild("LookLabRefinement")
local glow=mall and mall:FindFirstChild("Tenant_glow")
print("AUTHORITY|root="..tostring(root~=nil).."|authority="..tostring(authority~=nil).."|pass="..tostring(authority and authority:GetAttribute("Pass")))
print("OLD_ZONE|photo="..tostring(photo~=nil).."|salon="..tostring(salon~=nil).."|luxPhoto="..tostring(oldPhoto~=nil).."|luxLook="..tostring(oldLook~=nil).."|refPhoto="..tostring(oldPhotoRef~=nil).."|refLook="..tostring(oldLookRef~=nil))
print("MALL|glowLab="..tostring(glow~=nil).."|department="..tostring(glow and glow:GetAttribute("Department")))

local djSeats,djParts=0,0
local suspects={}
if root then
 for _,d in ipairs(root:GetDescendants()) do
  if d:IsA("BasePart") then
   local p=d.Position
   if p.X>=-22 and p.X<=28 and p.Z>=27 and p.Z<=45 and p.Y<13 then
    djParts+=1
    if d:IsA("Seat") or d:IsA("VehicleSeat") then djSeats+=1 end
    local n=d.Name:lower()
    if n:find("stool") or n:find("chair") or n:find("table") or n:find("seat") then
     if #suspects<30 then table.insert(suspects,d:GetFullName().."@"..tostring(p)) end
    end
   end
  end
 end
end
print("DJ|parts="..djParts.."|physicalSeats="..djSeats.."|suspects="..#suspects)
for i,v in ipairs(suspects) do print("DJ_SUSPECT_"..i.."|"..v) end

local legacyZoneParts=0
local legacyNames={}
if root then
 for _,d in ipairs(root:GetDescendants()) do
  if d:IsA("BasePart") then
   local p=d.Position
   if p.X>=-52 and p.X<=-27 and p.Z>=-36 and p.Z<=7 and p.Y<15 then
    legacyZoneParts+=1
    local n=d.Name:lower()
    if n:find("shelf") or n:find("salon") or n:find("photo") or n:find("softbox") or n:find("mirror") or n:find("product") then
     if #legacyNames<40 then table.insert(legacyNames,d:GetFullName().."@"..tostring(p)) end
    end
   end
  end
 end
end
print("LEGACY_ZONE|parts="..legacyZoneParts.."|namedSuspects="..#legacyNames)
for i,v in ipairs(legacyNames) do print("LEGACY_SUSPECT_"..i.."|"..v) end

local p=Players:GetPlayers()[1]
if p and p.Character then
 local hrp=p.Character:FindFirstChild("HumanoidRootPart")
 if hrp then hrp.CFrame=CFrame.lookAt(Vector3.new(0,3,-10),Vector3.new(3,5,38)) end
end
local cam=Workspace.CurrentCamera
if cam then
 cam.CameraType=Enum.CameraType.Scriptable
 cam.FieldOfView=70
 cam.CFrame=CFrame.lookAt(Vector3.new(0,8,-13),Vector3.new(3,5.2,38))
 print("CAMERA|mainclub_dj=true|pos="..tostring(cam.CFrame.Position))
end

task.wait(10)
print("[BBYA_JOB_END:mainclub-cloud-visual-v377]")
