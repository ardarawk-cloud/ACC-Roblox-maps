-- BBYA SOCIAL HUB — DEVELOPER DJ MIXER v1
-- Server-authoritative live event mixer. Access is intentionally limited to:
-- 1) the experience CreatorId (RR authority), and 2) arda_moron123 (AMstudio).
-- Normal admins/owners/crew/VIP do NOT inherit access.
-- Audio source is Roblox Audio Asset ID only; no direct device/Drive streaming.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local MarketplaceService=game:GetService("MarketplaceService")
local ContentProvider=game:GetService("ContentProvider")

local AM_STUDIO_USERNAME="arda_moron123"
local VENUE_GROUPS={
 MAIN="BBYAClubMaster",
 UNDERGROUND="BBYABasementMaster",
 VIP="BBYAVIPMaster",
 FUNKOT="BBYAFunkotMaster",
 SKATEPARK="BBYASkateparkMaster",
 ROOFTOP="BBYARooftopMaster",
}

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage

local actionRemote=remotes:FindFirstChild("DeveloperDJAction") or Instance.new("RemoteEvent")
actionRemote.Name="DeveloperDJAction";actionRemote.Parent=remotes
local stateRemote=remotes:FindFirstChild("DeveloperDJState") or Instance.new("RemoteEvent")
stateRemote.Name="DeveloperDJState";stateRemote.Parent=remotes
local getState=remotes:FindFirstChild("DeveloperDJGetState") or Instance.new("RemoteFunction")
getState.Name="DeveloperDJGetState";getState.Parent=remotes

local function usernameKey(player)
 return player and string.lower(player.Name) or ""
end

local function identity(player)
 if not player then return nil end
 if usernameKey(player)==AM_STUDIO_USERNAME then return "AMSTUDIO" end
 if game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId then return "RR" end
 return nil
end

local function authorized(player)
 return identity(player)~=nil
end

local mixer=SoundService:FindFirstChild("BBYADeveloperDJMixer")
if mixer and not mixer:IsA("Folder") then mixer:Destroy();mixer=nil end
if not mixer then mixer=Instance.new("Folder");mixer.Name="BBYADeveloperDJMixer";mixer.Parent=SoundService end
mixer:SetAttribute("BBYADeveloperDJMixerVersion","V1")
mixer:SetAttribute("AccessPolicy","CREATOR_ID_PLUS_ARDA_MORON123_ONLY")

local function ensureGroup(name,deck)
 local g=SoundService:FindFirstChild(name)
 if g and not g:IsA("SoundGroup") then g:Destroy();g=nil end
 if not g then g=Instance.new("SoundGroup");g.Name=name;g.Parent=SoundService end
 g.Volume=1
 g:SetAttribute("BBYADeveloperDJ",true)
 g:SetAttribute("Deck",deck)
 g:SetAttribute("Venue","NONE")
 g:SetAttribute("Live",false)
 return g
end

local groupA=ensureGroup("BBYADeveloperDJDeckA","A")
local groupB=ensureGroup("BBYADeveloperDJDeckB","B")

local function ensureDeck(name,group)
 local s=mixer:FindFirstChild(name)
 if s and not s:IsA("Sound") then s:Destroy();s=nil end
 if not s then s=Instance.new("Sound");s.Name=name;s.Parent=mixer end
 s.SoundGroup=group;s.Looped=false;s.Volume=0;s.PlaybackSpeed=1
 local eq=s:FindFirstChild("MixerEQ")
 if eq and not eq:IsA("EqualizerSoundEffect") then eq:Destroy();eq=nil end
 if not eq then eq=Instance.new("EqualizerSoundEffect");eq.Name="MixerEQ";eq.Parent=s end
 eq.Enabled=true;eq.LowGain=0;eq.MidGain=0;eq.HighGain=0
 local echo=s:FindFirstChild("MixerEcho")
 if echo and not echo:IsA("EchoSoundEffect") then echo:Destroy();echo=nil end
 if not echo then echo=Instance.new("EchoSoundEffect");echo.Name="MixerEcho";echo.Parent=s end
 echo.Enabled=false;echo.Delay=.18;echo.Feedback=.25;echo.DryLevel=0;echo.WetLevel=-10
 local reverb=s:FindFirstChild("MixerReverb")
 if reverb and not reverb:IsA("ReverbSoundEffect") then reverb:Destroy();reverb=nil end
 if not reverb then reverb=Instance.new("ReverbSoundEffect");reverb.Name="MixerReverb";reverb.Parent=s end
 reverb.Enabled=false;reverb.DecayTime=1.2;reverb.Density=.65;reverb.Diffusion=.8;reverb.DryLevel=0;reverb.WetLevel=-8
 return s,eq,echo,reverb
end

local soundA,eqA,echoA,reverbA=ensureDeck("DeckA",groupA)
local soundB,eqB,echoB,reverbB=ensureDeck("DeckB",groupB)

local state={
 live=false,
 venue="MAIN",
 crossfader=.5,
 operator=nil,
 decks={
  A={assetId=0,title="EMPTY",volume=.85,pitch=1,cue=0,low=0,mid=0,high=0,echo=false,reverb=false,preloaded=false},
  B={assetId=0,title="EMPTY",volume=.85,pitch=1,cue=0,low=0,mid=0,high=0,echo=false,reverb=false,preloaded=false},
 },
}

local suppressed={group=nil,volume=nil,venue=nil}

local function clamp(n,a,b)
 n=tonumber(n) or 0
 return math.clamp(n,a,b)
end

local function deckObjects(deck)
 if deck=="A" then return soundA,eqA,echoA,reverbA,groupA,state.decks.A end
 if deck=="B" then return soundB,eqB,echoB,reverbB,groupB,state.decks.B end
 return nil
end

local function resolveVenueGroup(venue)
 local name=VENUE_GROUPS[venue]
 if not name then return nil end
 local g=SoundService:FindFirstChild(name)
 return g and g:IsA("SoundGroup") and g or nil
end

local function restoreVenue()
 local g=suppressed.group
 if g and g.Parent then
  g.Volume=suppressed.volume or 1
  g:SetAttribute("BBYADeveloperDJLiveSuppressed",false)
 end
 suppressed={group=nil,volume=nil,venue=nil}
end

local function suppressVenue(venue)
 restoreVenue()
 local g=resolveVenueGroup(venue)
 if not g then return false,"Venue audio master unavailable." end
 suppressed={group=g,volume=g.Volume,venue=venue}
 g.Volume=0
 g:SetAttribute("BBYADeveloperDJLiveSuppressed",true)
 return true
end

local function applyDeck(deck)
 local sound,eq,echo,reverb,_,d=deckObjects(deck)
 if not sound then return end
 sound.PlaybackSpeed=clamp(d.pitch,.85,1.15)
 eq.LowGain=clamp(d.low,-12,6);eq.MidGain=clamp(d.mid,-12,6);eq.HighGain=clamp(d.high,-12,6)
 echo.Enabled=d.echo==true;reverb.Enabled=d.reverb==true
end

local function applyMix()
 local x=clamp(state.crossfader,0,1)
 local gainA=math.cos(x*math.pi*.5)
 local gainB=math.sin(x*math.pi*.5)
 if state.live then
  soundA.Volume=clamp(state.decks.A.volume,0,1)*gainA
  soundB.Volume=clamp(state.decks.B.volume,0,1)*gainB
 else
  soundA.Volume=0;soundB.Volume=0
 end
 applyDeck("A");applyDeck("B")
end

local function applyLiveRouting()
 local venue=state.live and state.venue or "NONE"
 for _,g in ipairs({groupA,groupB}) do
  g.Volume=1;g:SetAttribute("Venue",venue);g:SetAttribute("Live",state.live)
 end
 mixer:SetAttribute("Live",state.live)
 mixer:SetAttribute("Venue",venue)
end

local function snapshot()
 local function d(deck,sound)
  return {
   assetId=deck.assetId,title=deck.title,volume=deck.volume,pitch=deck.pitch,cue=deck.cue,
   low=deck.low,mid=deck.mid,high=deck.high,echo=deck.echo,reverb=deck.reverb,preloaded=deck.preloaded,
   playing=sound.Playing,timePosition=sound.TimePosition,timeLength=sound.TimeLength,
  }
 end
 return {
  authorized=true,live=state.live,venue=state.venue,crossfader=state.crossfader,operator=state.operator,
  decks={A=d(state.decks.A,soundA),B=d(state.decks.B,soundB)},
 }
end

local function broadcast()
 local snap=snapshot()
 for _,p in ipairs(Players:GetPlayers()) do
  if authorized(p) then stateRemote:FireClient(p,snap) end
 end
end

local function stopLive()
 state.live=false;state.operator=nil
 restoreVenue()
 soundA:Stop();soundB:Stop()
 applyLiveRouting();applyMix();broadcast()
end

local function validAssetId(raw)
 local text=tostring(raw or "")
 local digits=text:match("(%d+)")
 local id=tonumber(digits)
 if not id or id<1 then return nil end
 return math.floor(id)
end

local function refreshTitle(deck,id)
 task.spawn(function()
  local title="AUDIO #"..tostring(id)
  local ok,info=pcall(function()return MarketplaceService:GetProductInfo(id,Enum.InfoType.Asset)end)
  if ok and type(info)=="table" and type(info.Name)=="string" and info.Name~="" then title=info.Name end
  if state.decks[deck].assetId==id then
   state.decks[deck].title=title
   broadcast()
  end
 end)
end

local function preload(deck,sound,id)
 task.spawn(function()
  local ok=pcall(function()ContentProvider:PreloadAsync({sound})end)
  if state.decks[deck].assetId==id then
   state.decks[deck].preloaded=ok
   broadcast()
  end
 end)
end

local function loadDeck(deck,rawId)
 local sound,_,_,_,_,d=deckObjects(deck)
 if not sound then return false,"Invalid deck." end
 local id=validAssetId(rawId)
 if not id then return false,"Enter a valid Roblox Audio Asset ID." end
 sound:Stop();sound.TimePosition=0;sound.SoundId="rbxassetid://"..tostring(id)
 d.assetId=id;d.title="AUDIO #"..tostring(id);d.cue=0;d.preloaded=false
 refreshTitle(deck,id);preload(deck,sound,id)
 return true,"Deck "..deck.." loaded."
end

local function setVenue(venue)
 venue=string.upper(tostring(venue or ""))
 if not VENUE_GROUPS[venue] then return false,"Invalid venue." end
 if state.live and venue~=state.venue then
  local ok,msg=suppressVenue(venue)
  if not ok then return false,msg end
 end
 state.venue=venue
 applyLiveRouting();broadcast()
 return true
end

local function goLive(player)
 if state.live then state.operator=identity(player);broadcast();return true end
 local ok,msg=suppressVenue(state.venue)
 if not ok then return false,msg end
 state.live=true;state.operator=identity(player)
 applyLiveRouting();applyMix();broadcast()
 return true,"DJ LIVE • "..state.venue
end

local function handle(player,action,payload)
 if not authorized(player) then return end
 action=string.lower(tostring(action or ""));payload=type(payload)=="table" and payload or {}
 local deck=string.upper(tostring(payload.deck or ""))
 local sound,_,_,_,_,d=deckObjects(deck)

 if action=="load" then
  loadDeck(deck,payload.assetId)
 elseif action=="play_toggle" and sound and d then
  if d.assetId<1 then return end
  if sound.Playing then sound:Pause() else sound:Play() end
 elseif action=="cue" and sound and d then
  sound.TimePosition=math.max(0,d.cue or 0)
 elseif action=="set_cue" and sound and d then
  d.cue=math.max(0,sound.TimePosition)
 elseif action=="stop" and sound and d then
  sound:Stop();sound.TimePosition=math.max(0,d.cue or 0)
 elseif action=="volume" and d then
  d.volume=clamp(payload.value,0,1);applyMix()
 elseif action=="pitch" and d then
  d.pitch=clamp(payload.value,.85,1.15);applyDeck(deck)
 elseif action=="eq" and d then
  local band=string.lower(tostring(payload.band or ""))
  if band=="low" or band=="mid" or band=="high" then d[band]=clamp(payload.value,-12,6);applyDeck(deck) end
 elseif action=="echo" and d then
  d.echo=payload.value==true;applyDeck(deck)
 elseif action=="reverb" and d then
  d.reverb=payload.value==true;applyDeck(deck)
 elseif action=="crossfader" then
  state.crossfader=clamp(payload.value,0,1);applyMix()
 elseif action=="venue" then
  setVenue(payload.value)
 elseif action=="go_live" then
  goLive(player)
 elseif action=="end_live" then
  stopLive()
 else
  return
 end
 broadcast()
end

actionRemote.OnServerEvent:Connect(handle)
getState.OnServerInvoke=function(player)
 local id=identity(player)
 if not id then return {authorized=false} end
 return snapshot()
end

local function applyAuth(player)
 local id=identity(player)
 player:SetAttribute("BBYADeveloperDJAuthorized",id~=nil)
 player:SetAttribute("BBYADeveloperDJIdentity",id)
end
for _,p in ipairs(Players:GetPlayers()) do applyAuth(p) end
Players.PlayerAdded:Connect(applyAuth)
Players.PlayerRemoving:Connect(function()
 task.defer(function()
  if not state.live then return end
  for _,p in ipairs(Players:GetPlayers()) do if authorized(p) then return end end
  stopLive()
 end)
end)

-- Keep the selected venue's AutoDJ suppressed while a live set is active,
-- even if another venue script tries to restore its master volume.
task.spawn(function()
 while task.wait(.2) do
  if state.live and suppressed.group and suppressed.group.Parent then suppressed.group.Volume=0 end
 end
end)

-- Lightweight state clock for both developer panels.
task.spawn(function()
 while task.wait(.5) do if state.live or soundA.Playing or soundB.Playing then broadcast() end end
end)

game:BindToClose(function()restoreVenue()end)
applyLiveRouting();applyMix()
print("[BBYA] Developer DJ Mixer v1 online: RR CreatorId + arda_moron123 only, 2-deck live venue routing")
