-- BBYA SOCIAL HUB — AUDIO RECOVERY WATCHDOG v5 DJ OWNERSHIP SAFE
-- Recovery remains fallback-only. When DJ LIVE is ON, the selected venue is hard-owned by DJ:
-- AutoDJ/fallback sources stay inaudible until DJ LIVE is turned OFF.

local SoundService=game:GetService("SoundService")
local ContentProvider=game:GetService("ContentProvider")

local CHANNELS={
 MAIN={group="BBYAClubMaster",decks={"BBYAClubDeckA","BBYAClubDeckB"},fallback="BBYAMainPublicFallbackV4",djMap="CLUB",mode="MAIN_CREATOR_STORE_RECOVERY_V5",tracks={{title="Stadium Rave (A)",id="1846368080"},{title="Pumpin' And Bumpin' D",id="9040442826"},{title="Fun In Paradise",id="9042578129"}}},
 UNDERGROUND={group="BBYABasementMaster",decks={"BBYABasementDeckA","BBYABasementDeckB"},fallback="BBYAUndergroundBreakbeatFallbackV4",djMap="UNDERGROUND",mode="UNDERGROUND_BREAKBEAT_RECOVERY_V5",tracks={{title="Akim — Breakbeat",id="1843270078"},{title="Mindwinder (a) — Drum n Bass",id="1838075377"},{title="Prison — Drum n Bass",id="1842657372"},{title="Distant Land — Drum n Bass",id="1842643374"},{title="Time Chasing — Gaming Drum n Bass",id="133054925243074"}}},
}

local DJ_AUTO_SOURCES={
 CLUB={"BBYAClubDeckA","BBYAClubDeckB","BBYAMainPublicFallbackV4"},
 VIP={"BBYAVIPPlaylist"},
 UNDERGROUND={"BBYABasementDeckA","BBYABasementDeckB","BBYAUndergroundBreakbeatFallbackV4"},
 FUNKOT={"BBYAFunkotRuntimeV6","BBYAFunkotDeck"},
}
local LOCK_GATE="BBYADJLiveOwnershipGateV1"

local function djState()
 local e=SoundService:FindFirstChild("BBYADJLiveV61Engine")or SoundService:FindFirstChild("BBYADJLiveV6Engine")
 if e and e:GetAttribute("Live")==true then return true,string.upper(tostring(e:GetAttribute("Map")or"CLUB")) end
 return false,""
end
local function djOwns(map)local live,active=djState();return live and active==map end
local function findSound(name)local s=SoundService:FindFirstChild(name,true);return s and s:IsA("Sound")and s or nil end
local function setHardMute(sound,mute)
 if not sound then return end
 local g=sound:FindFirstChild(LOCK_GATE)
 if mute then
  if g and not g:IsA("EqualizerSoundEffect")then g:Destroy();g=nil end
  if not g then g=Instance.new("EqualizerSoundEffect");g.Name=LOCK_GATE;g.Parent=sound end
  g.Enabled=true;g.LowGain=-80;g.MidGain=-80;g.HighGain=-80;sound:SetAttribute("BBYADJLiveHardOwned",true)
 else
  if g then g:Destroy()end;sound:SetAttribute("BBYADJLiveHardOwned",nil)
 end
end
local function enforceDJOwnership()
 local live,map=djState()
 for venue,names in pairs(DJ_AUTO_SOURCES)do
  local mute=live and venue==map
  for _,name in ipairs(names)do setHardMute(findSound(name),mute)end
 end
 SoundService:SetAttribute("BBYADJLiveOwnershipActive",live)
 SoundService:SetAttribute("BBYADJLiveOwnershipVenue",live and map or"")
end

local function primaryHealthy(cfg)
 if djOwns(cfg.djMap)then return false end
 for _,name in ipairs(cfg.decks)do local s=findSound(name);if s and s.IsPlaying and(s.TimeLength or 0)>2 then return true end end
 return false
end
local function waitLoaded(sound,timeout)local deadline=os.clock()+(timeout or 5);while os.clock()<deadline do if sound.IsLoaded and(sound.TimeLength or 0)>2 then return true end;task.wait(.12)end;return sound.IsLoaded and(sound.TimeLength or 0)>2 end

local function runChannel(label,cfg)
 local group=SoundService:WaitForChild(cfg.group,35);if not group or not group:IsA("SoundGroup")then warn("[BBYA/"..label.."] recovery skipped: group missing");return end
 local old=SoundService:FindFirstChild(cfg.fallback);if old then old:Destroy()end
 local sound=Instance.new("Sound");sound.Name=cfg.fallback;sound.Volume=.88;sound.Looped=false;sound.SoundGroup=group;sound.Parent=SoundService;sound:SetAttribute("BBYARecovery",true);sound:SetAttribute("Venue",label)
 group:SetAttribute("RecoveryMode",cfg.mode);group:SetAttribute("RecoveryPrimaryPreferred",true);group:SetAttribute("RecoveryFallbackCount",#cfg.tracks);group:SetAttribute("DJOwnershipAware",true)
 local index=0;local loading=false;local bad={};local unhealthyFor=0
 local function playNext()
  if loading or primaryHealthy(cfg)or djOwns(cfg.djMap)then return false end
  loading=true
  for _=1,#cfg.tracks do
   index=index%#cfg.tracks+1
   if not bad[index]then
    local t=cfg.tracks[index];sound:Stop();sound.SoundId="rbxassetid://"..t.id;sound.TimePosition=0;group:SetAttribute("RecoveryTrying",t.title)
    local ok=pcall(function()ContentProvider:PreloadAsync({sound})end)
    if ok and waitLoaded(sound,5)and not djOwns(cfg.djMap)then sound:Play();local p0=sound.TimePosition;task.wait(.35);if sound.IsPlaying and sound.TimePosition>p0+.02 then group:SetAttribute("RecoveryActive",true);group:SetAttribute("RecoveryTrack",t.title);group:SetAttribute("RecoveryTrackId",t.id);loading=false;return true end end
    sound:Stop();bad[index]=true;group:SetAttribute("RecoveryLastFailed",t.title)
   end
  end
  group:SetAttribute("RecoveryActive",false);group:SetAttribute("RecoveryExhausted",true);loading=false;return false
 end
 task.spawn(function()
  task.wait(3)
  while task.wait(1.5)do
   if djOwns(cfg.djMap)then
    unhealthyFor=0;if sound.IsPlaying then sound:Pause()end;group:SetAttribute("RecoverySuspendedByDJLive",true)
   elseif primaryHealthy(cfg)then
    unhealthyFor=0;if sound.IsPlaying then sound:Stop()end;group:SetAttribute("RecoverySuspendedByDJLive",false);group:SetAttribute("RecoveryActive",false);group:SetAttribute("RecoveryPrimaryHealthy",true)
   else
    group:SetAttribute("RecoverySuspendedByDJLive",false);group:SetAttribute("RecoveryPrimaryHealthy",false);unhealthyFor+=1.5;if unhealthyFor>=4.5 and not sound.IsPlaying and not loading then playNext();unhealthyFor=0 end
   end
  end
 end)
end

for label,cfg in pairs(CHANNELS)do task.spawn(function()runChannel(label,cfg)end)end
SoundService.DescendantAdded:Connect(function(d)if d:IsA("Sound")then task.defer(enforceDJOwnership)end end)
task.spawn(function()while task.wait(.15)do enforceDJOwnership()end end)
enforceDJOwnership()
print("[BBYA] Audio Watchdog v5 online: DJ LIVE hard ownership + recovery only when DJ is OFF")
