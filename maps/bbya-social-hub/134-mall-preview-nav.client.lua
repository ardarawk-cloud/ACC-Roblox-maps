-- BBYA SOCIAL HUB — MALL PREVIEW/NAV CONTROLLER v1
-- TEST ONLY. Sub-authority for TRY interaction, avatar framing, and product back affordance.
-- The Mall shell/catalog remains owned by 133-mall-robux-commerce.client.lua.

local Players=game:GetService("Players")
local MarketplaceService=game:GetService("MarketplaceService")
local AvatarEditorService=game:GetService("AvatarEditorService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local gui=pg:WaitForChild("BBYAMallRobuxCommerceUI",30)
if not gui then return end
local root=gui:WaitForChild("CatalogRoot",10)
if not root then return end
local avatar=root:WaitForChild("AvatarCard",10)
local viewport=avatar and avatar:WaitForChild("AvatarViewport",10)
local world=viewport and viewport:FindFirstChildOfClass("WorldModel")
local cam=viewport and viewport.CurrentCamera
local host=root:WaitForChild("ModuleHost",10)
local products=host and host:WaitForChild("PRODUCTS",10)
local productList=products and products:FindFirstChildOfClass("ScrollingFrame")
local action=root:WaitForChild("SelectedActions",20)
if not (avatar and viewport and world and cam and products and productList and action) then return end

gui:SetAttribute("BBYAMallPreviewAuthority","V1_TRY_FRONT_FULLBODY")

local selectedId=nil
local selectedKind="Asset"
local selectedName="Item"
local selectedLabel=avatar:FindFirstChildWhichIsA("TextLabel",true)
local previewDescription=nil

local typeByValue={}
for _,e in ipairs(Enum.AvatarAssetType:GetEnumItems()) do typeByValue[e.Value]=e.Name end

local accessoryMap={
 Hat="Hat",HairAccessory="Hair",FaceAccessory="Face",NeckAccessory="Neck",ShoulderAccessory="Shoulder",
 FrontAccessory="Front",BackAccessory="Back",WaistAccessory="Waist",TShirtAccessory="TShirt",
 ShirtAccessory="Shirt",SweaterAccessory="Sweater",JacketAccessory="Jacket",PantsAccessory="Pants",
 ShortsAccessory="Shorts",DressSkirtAccessory="DressSkirt",LeftShoeAccessory="LeftShoe",
 RightShoeAccessory="RightShoe",EyebrowAccessory="Eyebrow",EyelashAccessory="Eyelash",
}
local directDesc={
 Head="Head",Face="Face",Torso="Torso",RightArm="RightArm",LeftArm="LeftArm",LeftLeg="LeftLeg",RightLeg="RightLeg",
 ClimbAnimation="ClimbAnimation",FallAnimation="FallAnimation",IdleAnimation="IdleAnimation",JumpAnimation="JumpAnimation",
 RunAnimation="RunAnimation",SwimAnimation="SwimAnimation",WalkAnimation="WalkAnimation",MoodAnimation="MoodAnimation",
}

local function currentDescription()
 local ch=player.Character
 local hum=ch and ch:FindFirstChildOfClass("Humanoid")
 if hum then
  local ok,d=pcall(function()return hum:GetAppliedDescription()end)
  if ok and d then return d end
 end
 local ok,d=pcall(function()return Players:GetHumanoidDescriptionFromUserId(player.UserId)end)
 if ok then return d end
end

local function frontFrame()
 cam=viewport.CurrentCamera or cam
 local m=world:FindFirstChildOfClass("Model")
 if not (m and cam) then return end
 local ok,cf,sz=pcall(function()local a,b=m:GetBoundingBox();return a,b end)
 if not ok or not cf or not sz then return end
 local rootPart=m:FindFirstChild("HumanoidRootPart",true)
 local h=math.max(sz.Y,5)
 local w=math.max(sz.X,3)
 local target=(rootPart and rootPart.Position or cf.Position)+Vector3.new(0,h*.015,0)
 local forward=rootPart and rootPart.CFrame.LookVector or Vector3.new(0,0,-1)
 forward=Vector3.new(forward.X,0,forward.Z)
 if forward.Magnitude<.01 then forward=Vector3.new(0,0,-1) else forward=forward.Unit end
 local dist=math.max(h*1.72,w*1.45)
 cam.FieldOfView=30
 cam.CFrame=CFrame.lookAt(target+forward*dist+Vector3.new(0,h*.015,0),target,Vector3.yAxis)
end

local function cleanModel(m)
 for _,d in ipairs(m:GetDescendants()) do
  if d:IsA("Script") or d:IsA("LocalScript") then d:Destroy()
  elseif d:IsA("BasePart") then d.Anchored=true;d.CanCollide=false;d.CanTouch=false;d.CanQuery=false end
 end
end

local function renderDescription(desc)
 if not desc then return false end
 world:ClearAllChildren()
 local ok,m=pcall(function()return Players:CreateHumanoidModelFromDescription(desc,Enum.HumanoidRigType.R15)end)
 if not ok or not m then return false end
 cleanModel(m)
 m.Parent=world
 task.defer(frontFrame)
 return true
end

local function assetTypeName(assetId)
 local ok,info=pcall(function()return MarketplaceService:GetProductInfo(assetId,Enum.InfoType.Asset)end)
 if not ok or typeof(info)~="table" then return nil end
 local n=tonumber(info.AssetTypeId)
 return n and typeByValue[n] or nil
end

local function applyAsset(desc,assetId,typeName)
 if not (desc and assetId and typeName) then return false end
 if typeName=="Shirt" then desc.Shirt=assetId;return true end
 if typeName=="TShirt" then desc.GraphicTShirt=assetId;return true end
 if typeName=="Pants" then desc.Pants=assetId;return true end
 local prop=directDesc[typeName]
 if prop then return pcall(function()desc[prop]=assetId end) end
 local mapped=accessoryMap[typeName]
 if mapped then
  local ok,accType=pcall(function()return Enum.AccessoryType[mapped]end)
  if not ok or not accType then return false end
  local ok2,list=pcall(function()return desc:GetAccessories(true)end)
  if not ok2 then return false end
  if mapped=="Hair" or mapped=="LeftShoe" or mapped=="RightShoe" then
   for i=#list,1,-1 do if list[i].AccessoryType==accType then table.remove(list,i) end end
  end
  table.insert(list,{AssetId=assetId,AccessoryType=accType,Order=#list+1})
  return pcall(function()desc:SetAccessories(list,true)end)
 end
 return false
end

local function trySelected()
 if not selectedId then return false,"Pilih item dulu." end
 previewDescription=previewDescription or currentDescription()
 if not previewDescription then return false,"Avatar belum siap." end
 local d=previewDescription:Clone()
 local changed=false
 if selectedKind=="Bundle" then
  local ok,details=pcall(function()return AvatarEditorService:GetItemDetails(selectedId,Enum.AvatarItemType.Bundle)end)
  local items=ok and details and (details.BundledItems or details.Items) or nil
  if items then
   for _,bi in ipairs(items) do
    local bid=tonumber(bi.Id or bi.AssetId)
    local kind=tostring(bi.Type or "Asset")
    if bid and kind=="Asset" then changed=applyAsset(d,bid,assetTypeName(bid)) or changed end
   end
  end
 else
  changed=applyAsset(d,selectedId,assetTypeName(selectedId))
 end
 if not changed then return false,"Item ini belum bisa dipreview." end
 previewDescription=d
 renderDescription(d)
 return true,"TRY aktif • "..selectedName
end

local status=nil
for _,x in ipairs(products:GetChildren()) do
 if x:IsA("TextLabel") and x.Position.Y.Offset>=35 and x.Position.Y.Offset<=55 then status=x break end
end

local function setStatus(text,ok)
 if status then
  status.Text=text
  status.TextColor3=ok and Color3.fromRGB(75,235,125) or Color3.fromRGB(233,73,89)
 end
end

local function bindCard(card)
 if not card:IsA("TextButton") then return end
 local kind,id=card.Name:match("^Item_(Asset)_(%d+)$")
 if not id then kind,id=card.Name:match("^Item_(Bundle)_(%d+)$") end
 if not id then return end
 card.Activated:Connect(function()
  selectedId=tonumber(id)
  selectedKind=kind
  task.defer(function()
   local label=avatar:FindFirstChildWhichIsA("TextLabel",true)
   if label and label.Text~="" then selectedName=label.Text:gsub("^TRY%s*•%s*","") end
  end)
 end)
end
for _,c in ipairs(productList:GetChildren()) do bindCard(c) end
productList.ChildAdded:Connect(function(c)task.defer(function()bindCard(c)end)end)

local oldTry=nil
for _,x in ipairs(action:GetChildren()) do if x:IsA("TextButton") and x.Text=="TRY" then oldTry=x break end end
if oldTry then
 oldTry.Visible=false;oldTry.Active=false
 local b=Instance.new("TextButton")
 b.Name="TryPreviewAuthority";b.Text="TRY";b.Position=oldTry.Position;b.Size=oldTry.Size;b.BackgroundColor3=oldTry.BackgroundColor3
 b.TextColor3=oldTry.TextColor3;b.Font=oldTry.Font;b.TextSize=oldTry.TextSize;b.BorderSizePixel=0;b.AutoButtonColor=true;b.ZIndex=oldTry.ZIndex+5;b.Parent=action
 local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,9);c.Parent=b
 b.Activated:Connect(function()
  local ok,msg=trySelected();setStatus(msg,ok)
  if ok then
   local label=avatar:FindFirstChildWhichIsA("TextLabel",true)
   if label then label.Text="TRY • "..selectedName end
  end
 end)
end

for _,x in ipairs(products:GetChildren()) do
 if x:IsA("TextButton") and x.Text:find("KATALOG",1,true) then
  x.Text="‹ KEMBALI";x.TextColor3=Color3.fromRGB(61,201,230);x.Size=UDim2.fromOffset(118,34)
 end
end

world.ChildAdded:Connect(function()task.defer(frontFrame)end)
viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()task.defer(frontFrame)end)
root:GetPropertyChangedSignal("Visible"):Connect(function()
 if root.Visible then previewDescription=currentDescription();task.delay(.08,frontFrame) else selectedId=nil end
end)
player.CharacterAdded:Connect(function()previewDescription=nil end)

task.defer(frontFrame)
print("[BBYA] Mall Preview/Nav Controller v1 online: explicit back + reliable TRY + front full-body framing")