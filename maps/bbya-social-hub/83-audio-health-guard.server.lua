-- BBYA SOCIAL HUB — AUDIO HEALTH GUARD v5 DJ OWNERSHIP SAFE
-- Main AutoDJ health recovery is completely suspended while DJ LIVE owns CLUB.
-- It resumes automatically only after DJ LIVE is turned OFF.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
if not remotes then return end
local internalMusic=remotes:WaitForChild("InternalMusic",30)
if not internalMusic or not internalMusic:IsA("BindableEvent")then return end
local group=SoundService:WaitForChild("BBYAClubMaster",30)
if group and group:IsA("SoundGroup")then
 group:SetAttribute("AudioHealthGuard",true)
 group:SetAttribute("AudioHealthVersion","V5_DJ_OWNERSHIP_SAFE")
 group:SetAttribute("AudioHealthOwnsVolume",false)
end

local function djOwnsClub()
 local e=SoundService:FindFirstChild("BBYADJLiveV61Engine")or SoundService:FindFirstChild("BBYADJLiveV6Engine")
 return e~=nil and e:GetAttribute("Live")==true and string.upper(tostring(e:GetAttribute("Map")or""))=="CLUB"
end
local function decks()return SoundService:FindFirstChild("BBYAClubDeckA"),SoundService:FindFirstChild("BBYAClubDeckB")end
local function isAudibleCandidate(s)if not s or not s:IsA("Sound")then return false end;if s.PlaybackState==Enum.PlaybackState.Paused then return false end;return s.IsPlaying and s.Volume>.04 end
local function healthyLoaded(s)return isAudibleCandidate(s)and(s.TimeLength or 0)>2 end

local lastPositions={};local stagnantFor=0;local noLoadedAudioFor=0;local lastRecoveryAt=0
local function recover(reason)
 if djOwnsClub()then return end
 local now=os.clock();if now-lastRecoveryAt<4 then return end;lastRecoveryAt=now
 internalMusic:Fire("random")
 if group and group:IsA("SoundGroup")then group:SetAttribute("LastRecoveryReason",reason);group:SetAttribute("LastRecoveryAt",os.time())end
end

while task.wait(1.5)do
 if djOwnsClub()then
  stagnantFor=0;noLoadedAudioFor=0;lastPositions={}
  if group and group:IsA("SoundGroup")then group:SetAttribute("AudioHealthSuspendedByDJLive",true)end
  continue
 end
 if group and group:IsA("SoundGroup")then group:SetAttribute("AudioHealthSuspendedByDJLive",false)end
 local a,b=decks();local paused=(a and a.PlaybackState==Enum.PlaybackState.Paused)or(b and b.PlaybackState==Enum.PlaybackState.Paused)
 if paused then stagnantFor=0;noLoadedAudioFor=0;continue end
 local candidates={};if isAudibleCandidate(a)then table.insert(candidates,a)end;if isAudibleCandidate(b)then table.insert(candidates,b)end
 if #candidates==0 then noLoadedAudioFor+=1.5;stagnantFor=0;if noLoadedAudioFor>=4.5 then recover("no_active_deck");noLoadedAudioFor=0 end;continue end
 local anyLoaded=false;local anyAdvanced=false
 for _,s in ipairs(candidates)do if healthyLoaded(s)then anyLoaded=true end;local pos=s.TimePosition or 0;local previous=lastPositions[s]or pos;if pos>previous+.08 then anyAdvanced=true end;lastPositions[s]=pos end
 if anyLoaded then noLoadedAudioFor=0 else noLoadedAudioFor+=1.5 end;if anyAdvanced then stagnantFor=0 else stagnantFor+=1.5 end
 if noLoadedAudioFor>=5 then recover("asset_not_loaded");noLoadedAudioFor=0;stagnantFor=0 elseif stagnantFor>=6 then recover("timeline_not_advancing");stagnantFor=0;noLoadedAudioFor=0 end
end
