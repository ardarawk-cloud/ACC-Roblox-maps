-- BBYA SOCIAL HUB — DJ LIVE PERFORMANCE LAYER v4
-- Additive backend over 126-developer-dj-mixer.server.lua.
-- Adds hot cues, waveform seeking, and touch-vinyl jog/nudge without changing v3 routing/FX authority.
-- Access remains ONLY experience CreatorId (RR) + arda_moron123 (AMstudio).

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")

local AM_STUDIO_USERNAME="arda_moron123"
local function identity(player)
 if not player then return nil end
 if string.lower(player.Name)==AM_STUDIO_USERNAME then return "AMSTUDIO" end
 if game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId then return "RR" end
 return nil
end
local function authorized(player)return identity(player)~=nil end

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
if not remotes then return end
local actionRemote=remotes:WaitForChild("DeveloperDJAction",30)
if not actionRemote then return end
local mixer=SoundService:WaitForChild("BBYADeveloperDJMixer",30)
if not mixer then return end
local deckA=mixer:WaitForChild("DeckA",30)
local deckB=mixer:WaitForChild("DeckB",30)
if not (deckA and deckA:IsA("Sound") and deckB and deckB:IsA("Sound")) then return end

mixer:SetAttribute("BBYADeveloperDJPerformanceVersion","V4_TOUCH_VINYL_HOTCUE")
mixer:SetAttribute("HotCueSlotsPerDeck",3)
mixer:SetAttribute("WaveformSeek",true)
mixer:SetAttribute("TouchVinylNudge",true)

local function deckSound(deck)
 if deck=="A" then return deckA end
 if deck=="B" then return deckB end
 return nil
end

local function resetHotCues(sound)
 if not sound then return end
 for slot=1,3 do
  sound:SetAttribute("BBYADJHotCue"..slot,-1)
 end
 sound:SetAttribute("BBYADJHotCueSoundId",sound.SoundId or "")
end

for _,sound in ipairs({deckA,deckB}) do
 resetHotCues(sound)
 sound:GetPropertyChangedSignal("SoundId"):Connect(function()
  resetHotCues(sound)
 end)
end

local lastNudge={}
local function nudgeKey(player,deck)return tostring(player.UserId)..":"..deck end
local function clampPosition(sound,value)
 local length=tonumber(sound.TimeLength) or 0
 local upper=length>0 and math.max(0,length-.03) or math.max(0,value)
 return math.clamp(value,0,upper)
end

local function setHotCue(sound,slot)
 slot=math.clamp(math.floor(tonumber(slot) or 1),1,3)
 local pos=clampPosition(sound,tonumber(sound.TimePosition) or 0)
 sound:SetAttribute("BBYADJHotCue"..slot,pos)
 sound:SetAttribute("BBYADJHotCueSoundId",sound.SoundId or "")
end

local function playHotCue(sound,slot)
 slot=math.clamp(math.floor(tonumber(slot) or 1),1,3)
 local pos=tonumber(sound:GetAttribute("BBYADJHotCue"..slot)) or -1
 if pos<0 or sound.SoundId=="" then return end
 if tostring(sound:GetAttribute("BBYADJHotCueSoundId") or "")~=(sound.SoundId or "") then
  resetHotCues(sound)
  return
 end
 sound.TimePosition=clampPosition(sound,pos)
 if not sound.Playing then sound:Play() end
end

local function clearHotCue(sound,slot)
 slot=math.clamp(math.floor(tonumber(slot) or 1),1,3)
 sound:SetAttribute("BBYADJHotCue"..slot,-1)
end

local function seekRatio(sound,ratio)
 ratio=math.clamp(tonumber(ratio) or 0,0,1)
 local length=tonumber(sound.TimeLength) or 0
 if length<=0 or sound.SoundId=="" then return end
 sound.TimePosition=clampPosition(sound,length*ratio)
end

local function nudge(player,deck,sound,delta)
 if sound.SoundId=="" then return end
 local key=nudgeKey(player,deck)
 local now=os.clock()
 if now-(lastNudge[key] or 0)<.025 then return end
 lastNudge[key]=now
 delta=math.clamp(tonumber(delta) or 0,-.30,.30)
 if math.abs(delta)<.002 then return end
 sound.TimePosition=clampPosition(sound,(tonumber(sound.TimePosition) or 0)+delta)
end

actionRemote.OnServerEvent:Connect(function(player,action,payload)
 if not authorized(player) then return end
 action=string.lower(tostring(action or ""))
 if string.sub(action,1,3)~="v4_" then return end
 payload=type(payload)=="table" and payload or {}
 local deck=string.upper(tostring(payload.deck or ""))
 local sound=deckSound(deck)
 if not sound then return end

 if action=="v4_hotcue_set" then
  setHotCue(sound,payload.slot)
 elseif action=="v4_hotcue_play" then
  playHotCue(sound,payload.slot)
 elseif action=="v4_hotcue_clear" then
  clearHotCue(sound,payload.slot)
 elseif action=="v4_seek_ratio" then
  seekRatio(sound,payload.ratio)
 elseif action=="v4_nudge" then
  nudge(player,deck,sound,payload.delta)
 end
end)

Players.PlayerRemoving:Connect(function(player)
 local prefix=tostring(player.UserId)..":"
 for key in pairs(lastNudge) do
  if string.sub(key,1,#prefix)==prefix then lastNudge[key]=nil end
 end
end)

print("[BBYA] DJ Live Performance v4 backend online: hot cues + waveform seek + touch-vinyl nudge")
