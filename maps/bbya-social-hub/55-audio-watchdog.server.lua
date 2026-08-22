-- BBYA SOCIAL HUB — AUDIO RECOVERY WATCHDOG v4
-- Keeps Main/Underground alive without depending on private-upload permissions.
-- Primary AutoDJ always wins. Creator Store fallback only runs when its venue decks are dead.

local SoundService=game:GetService("SoundService")
local ContentProvider=game:GetService("ContentProvider")

local CHANNELS={
 MAIN={
  group="BBYAClubMaster",
  decks={"BBYAClubDeckA","BBYAClubDeckB"},
  fallback="BBYAMainPublicFallbackV4",
  mode="MAIN_CREATOR_STORE_RECOVERY_V4",
  tracks={
   {title="Stadium Rave (A)",id="1846368080"},
   {title="Pumpin' And Bumpin' D",id="9040442826"},
   {title="Fun In Paradise",id="9042578129"},
  },
 },
 UNDERGROUND={
  group="BBYABasementMaster",
  decks={"BBYABasementDeckA","BBYABasementDeckB"},
  fallback="BBYAUndergroundBreakbeatFallbackV4",
  mode="UNDERGROUND_BREAKBEAT_RECOVERY_V4",
  tracks={
   {title="Akim — Breakbeat",id="1843270078"},
   {title="Mindwinder (a) — Drum n Bass",id="1838075377"},
   {title="Prison — Drum n Bass",id="1842657372"},
   {title="Distant Land — Drum n Bass",id="1842643374"},
   {title="Time Chasing — Gaming Drum n Bass",id="133054925243074"},
  },
 },
}

local function primaryHealthy(cfg)
 for _,name in ipairs(cfg.decks) do
  local s=SoundService:FindFirstChild(name)
  if s and s:IsA("Sound") and s.IsPlaying and (s.TimeLength or 0)>2 then
   return true
  end
 end
 return false
end

local function waitLoaded(sound,timeout)
 local deadline=os.clock()+(timeout or 5)
 while os.clock()<deadline do
  if sound.IsLoaded and (sound.TimeLength or 0)>2 then return true end
  task.wait(.12)
 end
 return sound.IsLoaded and (sound.TimeLength or 0)>2
end

local function runChannel(label,cfg)
 local group=SoundService:WaitForChild(cfg.group,35)
 if not group or not group:IsA("SoundGroup") then
  warn(string.format("[BBYA/%s] recovery skipped: %s missing",label,cfg.group))
  return
 end

 local old=SoundService:FindFirstChild(cfg.fallback)
 if old then old:Destroy() end
 local sound=Instance.new("Sound")
 sound.Name=cfg.fallback
 sound.Volume=.88
 sound.Looped=false
 sound.SoundGroup=group
 sound.Parent=SoundService
 sound:SetAttribute("BBYARecovery",true)
 sound:SetAttribute("Venue",label)
 sound:SetAttribute("SourcePolicy","ROBLOX_CREATOR_STORE_PUBLIC_FALLBACK")
 group:SetAttribute("RecoveryMode",cfg.mode)
 group:SetAttribute("RecoveryPrimaryPreferred",true)
 group:SetAttribute("RecoveryFallbackCount",#cfg.tracks)

 local index=0
 local loading=false
 local bad={}
 local unhealthyFor=0

 local function playNext()
  if loading or primaryHealthy(cfg) then return false end
  loading=true
  for _=1,#cfg.tracks do
   index=(index%#cfg.tracks)+1
   if not bad[index] then
    local track=cfg.tracks[index]
    sound:Stop()
    sound.SoundId="rbxassetid://"..track.id
    sound.TimePosition=0
    group:SetAttribute("RecoveryTrying",track.title)
    local ok=pcall(function()ContentProvider:PreloadAsync({sound})end)
    if ok and waitLoaded(sound,5) then
     sound:Play()
     local p0=sound.TimePosition
     task.wait(.35)
     if sound.IsPlaying and sound.TimePosition>p0+.02 then
      group:SetAttribute("RecoveryActive",true)
      group:SetAttribute("RecoveryTrack",track.title)
      group:SetAttribute("RecoveryTrackId",track.id)
      group:SetAttribute("RecoveryLastStart",os.time())
      loading=false
      print(string.format("[BBYA/%s] public fallback playing: %s",label,track.title))
      return true
     end
    end
    sound:Stop()
    bad[index]=true
    group:SetAttribute("RecoveryLastFailed",track.title)
   end
  end
  group:SetAttribute("RecoveryActive",false)
  group:SetAttribute("RecoveryExhausted",true)
  loading=false
  warn(string.format("[BBYA/%s] no Creator Store fallback could start",label))
  return false
 end

 task.spawn(function()
  task.wait(3)
  while task.wait(1.5) do
   if primaryHealthy(cfg) then
    unhealthyFor=0
    if sound.IsPlaying then sound:Stop() end
    group:SetAttribute("RecoveryActive",false)
    group:SetAttribute("RecoveryPrimaryHealthy",true)
   else
    group:SetAttribute("RecoveryPrimaryHealthy",false)
    unhealthyFor+=1.5
    if unhealthyFor>=4.5 and not sound.IsPlaying and not loading then
     playNext()
     unhealthyFor=0
    end
   end
  end
 end)
end

for label,cfg in pairs(CHANNELS) do
 task.spawn(function()runChannel(label,cfg)end)
end

print("[BBYA] Audio Recovery Watchdog v4 online: Main public EDM fallback + Underground breakbeat fallback")
