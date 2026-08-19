local W=game:GetService("Workspace")
local InsertService=game:GetService("InsertService")
local root=W:WaitForChild("BBYA_ZERO_BUILD")

-- Single authoritative asset pass. No procedural furniture/equipment is generated here.
local old=root:FindFirstChild("MeshAssetPass")
if old then old:Destroy() end
local out=Instance.new("Folder")
out.Name="MeshAssetPass"
out.Parent=root

-- Remove rejected procedural props that caused the blocky/Minecraft look.
for _,name in ipairs({"StageSoundStacks","UndergroundFurnishAndLight","BBYARealismPass","RealismPass","MeshAssetSlots"}) do
 local obj=root:FindFirstChild(name)
 if obj then obj:Destroy() end
end

local floor1=root:FindFirstChild("Floor1Core")
if floor1 then
 local salon=floor1:FindFirstChild("04_SalonLookStudio")
 if salon then
  for _,obj in ipairs(salon:GetChildren()) do
   if obj.Name:match("SalonConsole") then obj:Destroy() end
  end
 end
 local dj=floor1:FindFirstChild("06_DJBooth")
 if dj then
  for _,obj in ipairs(dj:GetChildren()) do
   if obj.Name=="DJDesk" or obj.Name=="DJDeskGlow" then obj:Destroy() end
  end
 end
end

local ug=root:FindFirstChild("Underground")
if ug then
 local removeExact={
  DJDesk=true,DeckBody=true,Mixer=true,LaptopBase=true,LaptopStand=true,LaptopScreen=true,LaptopDisplay=true,
  BarCounter=true,BarTop=true,BarBlueEdge=true,BarYellowEdge=true,BartenderTorso=true,BartenderHead=true,BartenderApron=true,
 }
 local badPrefixes={"SideBench","SofaBack","Sub","Woofer","Jog","Pad","Fader","MixerLED","Bottle"}
 for _,obj in ipairs(ug:GetChildren()) do
  local kill=removeExact[obj.Name]==true
  if not kill then
   for _,prefix in ipairs(badPrefixes) do
    if obj.Name:sub(1,#prefix)==prefix then kill=true break end
   end
  end
  if kill then obj:Destroy() end
 end
 local npc=ug:FindFirstChild("UndergroundBartender")
 if npc then npc:Destroy() end
end

local ASSET={
 -- Public Creator Store assets; loaded at runtime and aggressively sanitized.
 DJ=10823585593,              -- multi-MeshPart DJ equipment/model
 SPEAKER=9380977481,          -- line-array stage speaker system
 SALON_CHAIR=15058709461,     -- chair MeshPart
 MIRROR=10306409140,          -- mirror model
 SOFA=17149922176,            -- couch MeshPart
 BAR_STOOL=5580435847,        -- bar stool model
}

local function sanitize(container)
 for _,d in ipairs(container:GetDescendants()) do
  if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") or d:IsA("Sound") or d:IsA("Tool") then
   d:Destroy()
  elseif d:IsA("BasePart") then
   d.Anchored=true
   d.CanCollide=false
   d.CanTouch=false
   d.CanQuery=true
   if d:IsA("MeshPart") then
    d.RenderFidelity=Enum.RenderFidelity.Automatic
    d.CollisionFidelity=Enum.CollisionFidelity.Box
   end
  end
 end
end

local function getModel(assetId,name)
 local ok,pack=pcall(function() return InsertService:LoadAsset(assetId) end)
 if not ok or not pack then
  warn("[BBYA] Creator Store asset failed",assetId,name)
  return nil
 end
 sanitize(pack)
 local model=Instance.new("Model")
 model.Name=name
 for _,child in ipairs(pack:GetChildren()) do child.Parent=model end
 pack:Destroy()
 model.Parent=out
 return model
end

local function normalizeAndPlace(model,cf,targetMax)
 if not model then return nil end
 local ok,size=pcall(function() return model:GetExtentsSize() end)
 if ok and targetMax and size then
  local largest=math.max(size.X,size.Y,size.Z)
  if largest>0 then
   local scale=targetMax/largest
   scale=math.clamp(scale,0.05,12)
   pcall(function() model:ScaleTo(scale) end)
  end
 end
 pcall(function() model:PivotTo(cf) end)
 return model
end

local function load(assetId,name,cf,targetMax)
 return normalizeAndPlace(getModel(assetId,name),cf,targetMax)
end

-- SALON / LOOK STUDIO: three real mesh chairs, three mesh mirrors and spacing that reads like a salon.
for i,z in ipairs({-10,-3,4}) do
 load(ASSET.SALON_CHAIR,"SalonChair_"..i,CFrame.new(-41.5,1.45,z)*CFrame.Angles(0,math.rad(90),0),5.2)
 load(ASSET.MIRROR,"SalonMirror_"..i,CFrame.new(-48.6,4.3,z)*CFrame.Angles(0,math.rad(-90),0),7.0)
end

-- MAIN CLUB: complete real mesh DJ package and mirrored line-array systems.
load(ASSET.DJ,"MainClub_DJMesh",CFrame.new(0,3.7,32)*CFrame.Angles(0,math.rad(180),0),16)
load(ASSET.SPEAKER,"MainClub_Speaker_L",CFrame.new(-27,5.2,42)*CFrame.Angles(0,math.rad(180),0),14)
load(ASSET.SPEAKER,"MainClub_Speaker_R",CFrame.new(27,5.2,42)*CFrame.Angles(0,math.rad(180),0),14)

-- UNDERGROUND: complete DJ package, line arrays and actual couch meshes facing the dance floor.
load(ASSET.DJ,"Underground_DJMesh",CFrame.new(0,-10.1,31)*CFrame.Angles(0,math.rad(180),0),17)
load(ASSET.SPEAKER,"Underground_Speaker_L",CFrame.new(-27,-10.5,34)*CFrame.Angles(0,math.rad(180),0),13)
load(ASSET.SPEAKER,"Underground_Speaker_R",CFrame.new(27,-10.5,34)*CFrame.Angles(0,math.rad(180),0),13)
for i,z in ipairs({-14,2,18}) do
 load(ASSET.SOFA,"Underground_Sofa_L_"..i,CFrame.new(-47,-13.4,z)*CFrame.Angles(0,math.rad(90),0),10)
 load(ASSET.SOFA,"Underground_Sofa_R_"..i,CFrame.new(47,-13.4,z)*CFrame.Angles(0,math.rad(-90),0),10)
end

-- BAR: keep only the approved rear/opposite-DJ zone, replace fake stools with model assets.
for i,x in ipairs({-12,-8,-4,0,4,8,12}) do
 load(ASSET.BAR_STOOL,"Underground_BarStool_"..i,CFrame.new(x,-13.5,-29.5)*CFrame.Angles(0,math.rad(180),0),3.2)
end

print("[BBYA] Mesh asset pass loaded: salon, DJ equipment, line arrays, lounge sofas, bar stools")