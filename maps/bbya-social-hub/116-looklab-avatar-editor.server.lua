-- BBYA SOCIAL HUB — LOOK LAB AVATAR EDITOR v1
-- In-experience catalog try-on for Look Lab. Temporary preview + reset; platform save is handled client-side.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local features=root:WaitForChild("Floor1Features",30)
if not features then return end

local old=root:FindFirstChild("LookLabAvatarEditorV1")
if old then old:Destroy() end
local runtime=Instance.new("Model")
runtime.Name="LookLabAvatarEditorV1"
runtime:SetAttribute("Pass","LOOK_LAB_AVATAR_EDITOR_V1")
runtime:SetAttribute("AutoSeat",true)
runtime:SetAttribute("CatalogTryOn",true)
runtime:SetAttribute("TemporaryPreview",true)
runtime.Parent=root

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local remote=remotes:FindFirstChild("LookLabAvatar") or Instance.new("RemoteEvent")
remote.Name="LookLabAvatar";remote.Parent=remotes

-- Retire the older roleplay-only chair prompts. Wash station remains available.
for _,obj in ipairs(features:GetDescendants()) do
 if obj:IsA("ProximityPrompt") then
  local parent=obj.Parent
  if parent and tostring(parent.Name):match("^LookChairInteract") then obj.Enabled=false end
 end
end

local originalDescriptions={}
local touchDebounce={}

local function getHumanoid(plr)
 local ch=plr.Character
 if not ch then return nil,nil end
 return ch:FindFirstChildOfClass("Humanoid"),ch
end

local function nearLookLab(plr)
 local _,ch=getHumanoid(plr)
 local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 if not hrp then return false end
 return (hrp.Position-Vector3.new(-42,2,-3)).Magnitude<=22
end

local TOP_TYPES={
 [Enum.AccessoryType.TShirt]=true,[Enum.AccessoryType.Shirt]=true,[Enum.AccessoryType.Jacket]=true,[Enum.AccessoryType.Sweater]=true,
}
local BOTTOM_TYPES={
 [Enum.AccessoryType.Pants]=true,[Enum.AccessoryType.Shorts]=true,[Enum.AccessoryType.DressSkirt]=true,
}

local TYPE_MAP={
 HairAccessory={acc=Enum.AccessoryType.Hair,group="HAIR",layered=false},
 Hat={acc=Enum.AccessoryType.Hat,group="SAME",layered=false},
 FaceAccessory={acc=Enum.AccessoryType.Face,group="SAME",layered=false},
 NeckAccessory={acc=Enum.AccessoryType.Neck,group="SAME",layered=false},
 ShoulderAccessory={acc=Enum.AccessoryType.Shoulder,group="SAME",layered=false},
 FrontAccessory={acc=Enum.AccessoryType.Front,group="SAME",layered=false},
 BackAccessory={acc=Enum.AccessoryType.Back,group="SAME",layered=false},
 WaistAccessory={acc=Enum.AccessoryType.Waist,group="SAME",layered=false},
 TShirtAccessory={acc=Enum.AccessoryType.TShirt,group="TOP",layered=true},
 ShirtAccessory={acc=Enum.AccessoryType.Shirt,group="TOP",layered=true},
 JacketAccessory={acc=Enum.AccessoryType.Jacket,group="TOP",layered=true},
 SweaterAccessory={acc=Enum.AccessoryType.Sweater,group="TOP",layered=true},
 PantsAccessory={acc=Enum.AccessoryType.Pants,group="BOTTOM",layered=true},
 ShortsAccessory={acc=Enum.AccessoryType.Shorts,group="BOTTOM",layered=true},
 DressSkirtAccessory={acc=Enum.AccessoryType.DressSkirt,group="BOTTOM",layered=true},
}
local CLASSIC={Shirt="Shirt",Pants="Pants",TShirt="GraphicTShirt"}

local function cleanTypeName(v)
 local s=tostring(v or "")
 s=s:gsub("Enum%.AvatarAssetType%.","")
 return s
end

local function applyDescription(hum,desc)
 local ok,err=pcall(function() hum:ApplyDescriptionAsync(desc) end)
 if not ok then warn("[BBYA LookLab] ApplyDescriptionAsync failed:",err) end
 return ok
end

local function rememberOriginal(plr,hum)
 if originalDescriptions[plr] then return end
 local ok,desc=pcall(function() return hum:GetAppliedDescription() end)
 if ok and desc then originalDescriptions[plr]=desc:Clone() end
end

local function replaceAccessory(desc,assetId,spec)
 local ok,list=pcall(function() return desc:GetAccessories(true) end)
 if not ok then return false end
 local kept={}
 for _,entry in ipairs(list) do
  local t=entry.AccessoryType
  local remove=false
  if spec.group=="HAIR" then remove=(t==Enum.AccessoryType.Hair)
  elseif spec.group=="TOP" then remove=TOP_TYPES[t]==true
  elseif spec.group=="BOTTOM" then remove=BOTTOM_TYPES[t]==true
  elseif spec.group=="SAME" then remove=(t==spec.acc) end
  if not remove then table.insert(kept,entry) end
 end
 local add={AssetId=assetId,AccessoryType=spec.acc}
 if spec.layered then
  add.Order=(spec.group=="TOP") and 2 or 5
  add.Puffiness=0
 end
 table.insert(kept,add)
 return pcall(function() desc:SetAccessories(kept,true) end)
end

remote.OnServerEvent:Connect(function(plr,action,payload)
 local hum=getHumanoid(plr)
 if not hum then return end
 if action=="tryOn" then
  if not nearLookLab(plr) then return end
  if typeof(payload)~="table" then return end
  local assetId=tonumber(payload.assetId)
  local typeName=cleanTypeName(payload.assetType)
  if not assetId or assetId<=0 or assetId>999999999999999 then return end
  rememberOriginal(plr,hum)
  local ok,desc=pcall(function() return hum:GetAppliedDescription() end)
  if not ok or not desc then return end
  local classic=CLASSIC[typeName]
  local changed=false
  if classic then
   local safe=pcall(function() desc[classic]=assetId end)
   changed=safe
  else
   local spec=TYPE_MAP[typeName]
   if spec then changed=replaceAccessory(desc,assetId,spec) end
  end
  if not changed then remote:FireClient(plr,"status","Item type belum didukung di Look Lab.");return end
  if applyDescription(hum,desc) then remote:FireClient(plr,"status","TRY ON aktif — RESET kapan saja.") else remote:FireClient(plr,"status","Item tidak bisa dipakai pada avatar ini.") end
 elseif action=="reset" then
  local original=originalDescriptions[plr]
  if original and nearLookLab(plr) then
   if applyDescription(hum,original:Clone()) then
    originalDescriptions[plr]=nil
    remote:FireClient(plr,"status","Avatar dikembalikan ke tampilan awal.")
   end
  else
   remote:FireClient(plr,"status","Belum ada perubahan untuk di-reset.")
  end
 end
end)

-- Auto-seat at the three existing Look Lab styling chairs.
local chairZ={-10,-3,4}
for i,z in ipairs(chairZ) do
 local chair=Instance.new("Model");chair.Name="LookLabStation"..i;chair.Parent=runtime
 local seat=Instance.new("Seat")
 seat.Name="LookLabSeat"..i
 seat.Size=Vector3.new(2.2,.45,2.0)
 seat.CFrame=CFrame.new(-42,2.08,z)*CFrame.Angles(0,math.rad(90),0)
 seat.Transparency=1;seat.Anchored=true;seat.CanCollide=false;seat.CanTouch=false;seat.CanQuery=false;seat.Parent=chair
 local trigger=Instance.new("Part")
 trigger.Name="AutoStyleTrigger"..i
 trigger.Size=Vector3.new(3.2,3.0,3.4)
 trigger.CFrame=CFrame.new(-40.55,2.55,z)
 trigger.Transparency=1;trigger.Anchored=true;trigger.CanCollide=false;trigger.CanTouch=true;trigger.CanQuery=false;trigger.Parent=chair
 trigger.Touched:Connect(function(hit)
  local ch=hit and hit:FindFirstAncestorOfClass("Model")
  local hum=ch and ch:FindFirstChildOfClass("Humanoid")
  local plr=ch and Players:GetPlayerFromCharacter(ch)
  if not hum or not plr or hum.Health<=0 then return end
  if seat.Occupant or hum.Sit then return end
  local now=os.clock();if (touchDebounce[plr] or 0)+2>now then return end;touchDebounce[plr]=now
  seat:Sit(hum)
  task.delay(.18,function()
   if plr.Parent and hum.Parent and hum.SeatPart==seat then remote:FireClient(plr,"open",{station=i}) end
  end)
 end)
end

Players.PlayerRemoving:Connect(function(plr) originalDescriptions[plr]=nil;touchDebounce[plr]=nil end)
Players.PlayerAdded:Connect(function(plr)
 plr.CharacterAdded:Connect(function() originalDescriptions[plr]=nil end)
end)
for _,plr in ipairs(Players:GetPlayers()) do plr.CharacterAdded:Connect(function() originalDescriptions[plr]=nil end) end

print("[BBYA] Look Lab Avatar Editor v1 online: auto-seat + catalog try-on + reset")