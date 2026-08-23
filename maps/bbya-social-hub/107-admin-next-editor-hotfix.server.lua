-- BBYA SOCIAL HUB — ADMIN NEXT + EDITOR HOTFIX v2
-- Makes admin NEXT effective for primary AutoDJ and recovery/fallback audio.
-- Runtime editor stays hidden by default; authorized admins can still toggle it with /bbyaedit.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
if not remotes then return end
local musicRemote=remotes:WaitForChild("Music",30)
local stateRemote=remotes:FindFirstChild("State")
local internalMusic=remotes:FindFirstChild("InternalMusic")
local basementMusic=remotes:FindFirstChild("BasementMusic")

local function isAdmin(player)
 if not player then return false end
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

local function keepEditorHidden(player)
 if not isAdmin(player) then return end
 -- Do not auto-expose the runtime editor. 22-editor.server.lua owns the explicit
 -- /bbyaedit toggle and starts every authorized session hidden.
 player:SetAttribute("BBYAEditorVisible",false)
 player:SetAttribute("BBYAEditorAutoShownV1",false)
end

for _,p in ipairs(Players:GetPlayers()) do task.delay(2,function()if p.Parent then keepEditorHidden(p) end end) end
Players.PlayerAdded:Connect(function(p)
 task.delay(2,function()if p.Parent then keepEditorHidden(p) end end)
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

print("[BBYA] Admin NEXT + editor hotfix v2 online: EDIT hidden by default; /bbyaedit preserved")
