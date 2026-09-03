-- BBYA SOCIAL HUB — ADMIN NEXT + EDITOR HOTFIX v8
-- Makes admin NEXT effective for primary AutoDJ and recovery/fallback audio.
-- Runtime EDIT stays hidden by default for all admins; /bbyaedit can still show it when needed.
-- v8 retires the duplicate Community Wall neon geometry hotfix; 34-support-dashboard is sole visual authority.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local Workspace=game:GetService("Workspace")

local STATIC_ADMIN_USERNAMES={
 ["arda_moron123"]=true,
}

local function usernameKey(player)
 return player and string.lower(player.Name) or ""
end

local function isStaticAdmin(player)
 return player and STATIC_ADMIN_USERNAMES[usernameKey(player)]==true
end

local function grantStaticAdminAccess(player)
 if not isStaticAdmin(player) then return end
 player:SetAttribute("BBYAManagedRole","ADMIN")
 player:SetAttribute("BBYAAdmin",true)
 player:SetAttribute("BBYAStaff",true)
 player:SetAttribute("BBYAVIPBypass",true)
 player:SetAttribute("BBYARooftopBypass",true)
 player:SetAttribute("BBYASecretRoomBypass",true)
 player:SetAttribute("BBYATravelBypass",true)
end

local function bindStaticAdmin(player)
 if not isStaticAdmin(player) then return end
 grantStaticAdminAccess(player)
 local watched={
  BBYAManagedRole="ADMIN",
  BBYAAdmin=true,
  BBYAStaff=true,
  BBYAVIPBypass=true,
  BBYARooftopBypass=true,
  BBYASecretRoomBypass=true,
  BBYATravelBypass=true,
 }
 for attribute,expected in pairs(watched) do
  player:GetAttributeChangedSignal(attribute):Connect(function()
   if player.Parent and player:GetAttribute(attribute)~=expected then
    task.defer(function()
     if player.Parent then grantStaticAdminAccess(player) end
    end)
   end
  end)
 end
 task.delay(3,function()
  if player.Parent then grantStaticAdminAccess(player) end
 end)
end

for _,p in ipairs(Players:GetPlayers()) do bindStaticAdmin(p) end
Players.PlayerAdded:Connect(bindStaticAdmin)

-- Community Wall visual geometry is owned only by 34-support-dashboard.server.lua.
-- Do not mutate its neon trims here.

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
if not remotes then return end
local musicRemote=remotes:WaitForChild("Music",30)
local stateRemote=remotes:FindFirstChild("State")
local internalMusic=remotes:FindFirstChild("InternalMusic")
local basementMusic=remotes:FindFirstChild("BasementMusic")

local function isAdmin(player)
 if not player then return false end
 if isStaticAdmin(player) then return true end
 if player:GetAttribute("BBYAAdmin")==true then return true end
 return game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId
end

local function toast(player,msg)
 if stateRemote and stateRemote:IsA("RemoteEvent") then
  stateRemote:FireClient(player,"toast",msg)
 end
end

local function venue(player)
 local ch=player and player.Character
 local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 if not hrp then return "NONE" end
 local p=hrp.Position
 if p.Y<-4.5 then return "UNDERGROUND" end
 if p.Y>-4 and p.Y<34 and math.abs(p.X)<61 and p.Z>157 and p.Z<253 then return "FUNKOT" end
 if p.Y>-4 and p.Y<18 and math.abs(p.X)<=61 and p.Z>=0 and p.Z<70 then return "MAIN" end
 return "NONE"
end

local function stopRecovery(v)
 local groupName=v=="UNDERGROUND" and "BBYABasementMaster" or "BBYAClubMaster"
 local fallbackName=v=="UNDERGROUND" and "BBYAUndergroundBreakbeatFallbackV4" or "BBYAMainPublicFallbackV4"
 local group=SoundService:FindFirstChild(groupName)
 local fallback=SoundService:FindFirstChild(fallbackName)
 local active=(group and group:GetAttribute("RecoveryActive")==true) or (fallback and fallback:IsA("Sound") and fallback.IsPlaying)
 if active and fallback and fallback:IsA("Sound") then
  fallback:Stop()
  if group then group:SetAttribute("RecoveryActive",false);group:SetAttribute("AdminRecoverySkipAt",os.time()) end
  return true
 end
 return false
end

-- Keep the runtime editor hidden by default. The existing /bbyaedit command in the editor server
-- remains available to authorized admins whenever the editor is needed again.
local function hideEditorByDefault(player)
 if not player then return end
 player:SetAttribute("BBYAEditorVisible",false)
 player:SetAttribute("BBYAEditorAutoShownV1",false)
end

for _,p in ipairs(Players:GetPlayers()) do
 task.delay(2,function()
  if p.Parent then hideEditorByDefault(p) end
 end)
end
Players.PlayerAdded:Connect(function(p)
 task.delay(2,function()
  if p.Parent then hideEditorByDefault(p) end
 end)
end)

-- Observe the existing Music remote. Existing engine handlers still own normal playback.
-- This late guard only handles cases where NEXT previously appeared dead.
musicRemote.OnServerEvent:Connect(function(player,action)
 if action~="next" or not isAdmin(player) then return end
 local v=venue(player)
 if v~="MAIN" and v~="UNDERGROUND" then return end

 if stopRecovery(v) then
  toast(player,"NEXT • recovery track dilewati")
  return
 end

 -- Existing engine receives the same RemoteEvent and attempts its normal transition.
 -- Retry once after preload time if the first attempt did not have a ready standby.
 task.delay(1.0,function()
  if not player.Parent then return end
  if v=="UNDERGROUND" then
   if basementMusic and basementMusic:IsA("BindableEvent") then basementMusic:Fire("next",player) end
  else
   if internalMusic and internalMusic:IsA("BindableEvent") then internalMusic:Fire("next",player) end
  end
 end)
 toast(player,"NEXT • skip diproses")
end)

-- FUNKOT CLEAN ENTRY v1 --------------------------------------------------------
-- The large blackout box is retired. Remove only the small arrival debris that its
-- follow-up passes still recreate: queue posts/rope/sconces/header and the v2.1
-- portal/lens/plaque model. The original Funkot venue, sign, stage, dance floor,
-- lights, bar, audio and paid-zone/travel authority remain untouched.
local function cleanFunkotEntryDebris()
 local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
 local club=root and root:FindFirstChild("FunkotClub")
 if not club then return false end

 local premium=club:FindFirstChild("FunkotDiskotikPremiumV2")
 if premium then
  local arrival=premium:FindFirstChild("DiskotikArrivalV2")
  if arrival then arrival:Destroy() end
 end

 local identity=club:FindFirstChild("FunkotDiskotikIdentityV21")
 if identity then identity:Destroy() end

 club:SetAttribute("CleanEntryProfile","NO_BLACKOUT_NO_DEBRIS_V1")
 club:SetAttribute("ArrivalDebrisRetired",true)
 return true
end

task.spawn(function()
 -- RuntimeQC may build the retired arrival passes late; re-sweep only during startup.
 for _,delaySeconds in ipairs({1,3,6,10,18,30,45,60}) do
  task.delay(delaySeconds,cleanFunkotEntryDebris)
 end
end)

print("[BBYA] Admin NEXT + editor hotfix v8 online: static admin + full bypass; EDIT hidden by default; Community Wall neon authority retired here; Funkot entrance debris cleanup active")
