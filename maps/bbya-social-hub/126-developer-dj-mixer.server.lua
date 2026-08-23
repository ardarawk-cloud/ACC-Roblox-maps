-- BBYA SOCIAL HUB — DEVELOPER DJ MIXER v2
-- Full-screen mobile live-event mixer backend.
-- Access: experience CreatorId (RR) + arda_moron123 (AMstudio) ONLY.
-- Audio source remains Roblox Audio Asset IDs only.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local MarketplaceService=game:GetService("MarketplaceService")
local ContentProvider=game:GetService("ContentProvider")

local AM_STUDIO_USERNAME="arda_moron123"
local VENUE_GROUPS={
 MAIN="BBYAClubMaster",UNDERGROUND="BBYABasementMaster",VIP="BBYAVIPMaster",
 FUNKOT="BBYAFunkotMaster",SKATEPARK="BBYASkateparkMaster",ROOFTOP="BBYARooftopMaster",
}

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local actionRemote=remotes:FindFirstChild("DeveloperDJAction") or Instance.new("RemoteEvent")
actionRemote.Name="DeveloperDJAction";actionRemote.Parent=remotes
local stateRemote=remotes:FindFirstChild("DeveloperDJState") or Instance.new("RemoteEvent")
stateRemote.Name="DeveloperDJState";stateRemote.Parent=remotes
local getState=remotes:FindFirstChild("DeveloperDJGetState") or Instance.new("RemoteFunction")
getState.Name="DeveloperDJGetState";getState.Parent=remotes

local function usernameKey(p)return p and string.lower(p.Name) or "" end
local function identity(p)
 if not p then return nil end
 if usernameKey(p)==AM_STUDIO_USERNAME then return "AMSTUDIO" end
 if game.CreatorType==Enum.CreatorType.User and p.UserId==game.CreatorId then return "RR" end
 return nil
end
local function authorized(p)return identity(p)~=nil end

local mixer=SoundService:FindFirstChild("BBYADeveloperDJMixer")
if mixer and not mixer:IsA("Folder") then mixer:Destroy();mixer=nil end
if not mixer then mixer=Instance.new("Folder");mixer.Name="BBYADeveloperDJMixer";mixer.Parent=SoundService end
mixer:SetAttribute("BBYADeveloperDJMixerVersion","V2_FULLSCREEN_VINYL_FX")
mixer:SetAttribute("AccessPolicy","CREATOR_ID_PLUS_ARDA_MORON123_ONLY")

local function ensureGroup(name,deck)
 local g=SoundService:FindFirstChild(name)
 if g and not g:IsA("SoundGroup") then g:Destroy();g=nil end
 if not g then g=Instance.new("SoundGroup");g.Name=name;g.Parent=SoundService end
 g.Volume=1;g:SetAttribute("BBYADeveloperDJ",true);g:SetAttribute("Deck",deck);g:SetAttribute("Venue","NONE");g:SetAttribute("Live",false)
 return g
end
local groupA=ensureGroup("BBYADeveloperDJDeckA","A")
local groupB=ensureGroup("BBYADeveloperDJDeckB","B")

local function ensureEffect(sound,className,name)
 local e=sound:FindFirstChild(name)
 if e and e.ClassName~=className then e:Destroy();e=nil end
 if not e then e=Instance.new(className);e.Name=name;e.Parent=sound end
 return e
end

local function ensureDeck(name,group)
 local s=mixer:FindFirstChild(name)
 if s and not s:IsA("Sound") then s:Destroy();s=nil end
 if not s then s=Instance.new("Sound");s.Name=name;s.Parent=mixer end
 s.SoundGroup=group;s.Looped=false;s.Volume=0;s.PlaybackSpeed=1

 local filter=ensureEffect(s,"EqualizerSoundEffect","MixerFilter")
 filter.Enabled=false;filter.LowGain=2;filter.MidGain=-4;filter.HighGain=-14
 local echo=ensureEffect(s,"EchoSoundEffect","MixerEcho")
 echo.Enabled=false;echo.Delay=.18;echo.Feedback=.35;echo.DryLevel=0;echo.WetLevel=-7
 local reverb=ensureEffect(s,"ReverbSoundEffect","MixerReverb")
 reverb.Enabled=false;reverb.DecayTime=1.7;reverb.Density=.72;reverb.Diffusion=.85;reverb.DryLevel=0;reverb.WetLevel=-7
 local flange=ensureEffect(s,"FlangeSoundEffect","MixerFlange")
 flange.Enabled=false;flange.Depth=.7;flange.Mix=.55;flange.Rate=.45
 local chorus=ensureEffect(s,"ChorusSoundEffect","MixerChorus")
 chorus.Enabled=false;chorus.Depth=.6;chorus.Mix=.5;chorus.Rate=.65
 local distort=ensureEffect(s,"DistortionSoundEffect","MixerDistort")
 distort.Enabled=false;distort.Level=.28
 return s,{filter=filter,echo=echo,reverb=reverb,flange=flange,chorus=chorus,distort=distort}
end

local soundA,fxA=ensureDeck("DeckA",groupA)
local soundB,fxB=ensureDeck("DeckB",groupB)

local function freshDeckState()
 return {assetId=0,title="EMPTY",volume=.92,pitch=1,cue=0,preloaded=false,
  fx={echo=false,reverb=false,filter=false,flange=false,chorus=false,distort=false},busyFx=nil}
end
local state={live=false,venue="MAIN",crossfader=.5,operator=nil,decks={A=freshDeckState(),B=freshDeckState()}}
local suppressed={group=nil,volume=nil,venue=nil}
local fxTokens={A=0,B=0}

local function clamp(n,a,b)return math.clamp(tonumber(n) or 0,a,b) end
local function deckObjects(deck)
 if deck=="A" then return soundA,fxA,groupA,state.decks.A end
 if deck=="B" then return soundB,fxB,groupB,state.decks.B end
 return nil
end
local function otherDeck(deck)return deck=="A" and "B" or "A" end

local function resolveVenueGroup(venue)
 local name=VENUE_GROUPS[venue];if not name then return nil end
 local g=SoundService:FindFirstChild(name);return g and g:IsA("SoundGroup") and g or nil
end
local function restoreVenue()
 local g=suppressed.group
 if g and g.Parent then g.Volume=suppressed.volume or 1;g:SetAttribute("BBYADeveloperDJLiveSuppressed",false) end
 suppressed={group=nil,volume=nil,venue=nil}
end
local function suppressVenue(venue)
 restoreVenue();local g=resolveVenueGroup(venue)
 if not g then return false,"Venue audio master unavailable." end
 suppressed={group=g,volume=g.Volume,venue=venue};g.Volume=0;g:SetAttribute("BBYADeveloperDJLiveSuppressed",true);return true
end

local function applyDeck(deck)
 local sound,fx,_,d=deckObjects(deck);if not sound then return end
 if d.busyFx~="BRAKE" then sound.PlaybackSpeed=clamp(d.pitch,.85,1.15) end
 for k,e in pairs(fx) do e.Enabled=d.fx[k]==true end
end
local function applyMix()
 local x=clamp(state.crossfader,0,1)
 local gainA=math.cos(x*math.pi*.5);local gainB=math.sin(x*math.pi*.5)
 soundA.Volume=state.live and clamp(state.decks.A.volume,0,1)*gainA or 0
 soundB.Volume=state.live and clamp(state.decks.B.volume,0,1)*gainB or 0
 applyDeck("A");applyDeck("B")
end
local function applyLiveRouting()
 local venue=state.live and state.venue or "NONE"
 for _,g in ipairs({groupA,groupB}) do g.Volume=1;g:SetAttribute("Venue",venue);g:SetAttribute("Live",state.live) end
 mixer:SetAttribute("Live",state.live);mixer:SetAttribute("Venue",venue)
end

local function snapshot()
 local function d(st,sound)
  return {assetId=st.assetId,title=st.title,volume=st.volume,pitch=st.pitch,cue=st.cue,preloaded=st.preloaded,
   fx=table.clone(st.fx),busyFx=st.busyFx,playing=sound.Playing,timePosition=sound.TimePosition,timeLength=sound.TimeLength}
 end
 return {authorized=true,version="V2_FULLSCREEN_VINYL_FX",live=state.live,venue=state.venue,crossfader=state.crossfader,operator=state.operator,
  decks={A=d(state.decks.A,soundA),B=d(state.decks.B,soundB)}}
end
local function broadcast()
 local snap=snapshot();for _,p in ipairs(Players:GetPlayers()) do if authorized(p) then stateRemote:FireClient(p,snap) end end
end

local function cancelMomentary(deck)
 fxTokens[deck]+=1
 local sound,_,_,d=deckObjects(deck)
 if d then d.busyFx=nil end
 if sound and sound.Parent then sound.PlaybackSpeed=d and d.pitch or 1 end
end
local function stopLive()
 state.live=false;state.operator=nil;restoreVenue();cancelMomentary("A");cancelMomentary("B")
 soundA:Stop();soundB:Stop();applyLiveRouting();applyMix();broadcast()
end

local function validAssetId(raw)
 local digits=tostring(raw or ""):match("(%d+)");local id=tonumber(digits)
 return id and id>=1 and math.floor(id) or nil
end
local function refreshTitle(deck,id)
 task.spawn(function()
  local title="AUDIO #"..tostring(id)
  local ok,info=pcall(function()return MarketplaceService:GetProductInfo(id,Enum.InfoType.Asset)end)
  if ok and type(info)=="table" and type(info.Name)=="string" and info.Name~="" then title=info.Name end
  if state.decks[deck].assetId==id then state.decks[deck].title=title;broadcast() end
 end)
end
local function preload(deck,sound,id)
 task.spawn(function()
  local ok=pcall(function()ContentProvider:PreloadAsync({sound})end)
  if state.decks[deck].assetId==id then state.decks[deck].preloaded=ok;broadcast() end
 end)
end
local function loadDeck(deck,rawId)
 local sound,_,_,d=deckObjects(deck);if not sound then return false end
 local id=validAssetId(rawId);if not id then return false end
 cancelMomentary(deck);sound:Stop();sound.TimePosition=0;sound.SoundId="rbxassetid://"..tostring(id)
 d.assetId=id;d.title="AUDIO #"..id;d.cue=0;d.preloaded=false
 refreshTitle(deck,id);preload(deck,sound,id);return true
end

local function setVenue(venue)
 venue=string.upper(tostring(venue or ""));if not VENUE_GROUPS[venue] then return false end
 if state.live and venue~=state.venue then local ok=suppressVenue(venue);if not ok then return false end end
 state.venue=venue;applyLiveRouting();broadcast();return true
end
local function goLive(player)
 if state.live then state.operator=identity(player);broadcast();return true end
 local ok=suppressVenue(state.venue);if not ok then return false end
 state.live=true;state.operator=identity(player);applyLiveRouting();applyMix();broadcast();return true
end

local function syncDeck(deck)
 local target,_,_,td=deckObjects(deck);local source,_,_,sd=deckObjects(otherDeck(deck))
 if not target or not source or td.assetId<1 or sd.assetId<1 then return end
 td.pitch=sd.pitch;target.PlaybackSpeed=source.PlaybackSpeed
 if source.Playing then
  local phase=source.TimePosition%2
  local base=math.floor(math.max(0,target.TimePosition)/2)*2
  local pos=base+phase
  if target.TimeLength>0 then pos=math.min(pos,math.max(0,target.TimeLength-.05)) end
  target.TimePosition=pos
  if not target.Playing then target:Play() end
 end
end

local function toggleFx(deck,name)
 local _,_,_,d=deckObjects(deck);if not d or d.fx[name]==nil then return end
 d.fx[name]=not d.fx[name];applyDeck(deck)
end

local function momentaryBrake(deck)
 local sound,_,_,d=deckObjects(deck);if not sound or not d or d.assetId<1 then return end
 fxTokens[deck]+=1;local token=fxTokens[deck];d.busyFx="BRAKE"
 local start=math.max(.85,sound.PlaybackSpeed)
 task.spawn(function()
  for i=1,12 do
   if fxTokens[deck]~=token or not sound.Parent then return end
   sound.PlaybackSpeed=math.max(.08,start*(1-i/13));task.wait(.045)
  end
  if fxTokens[deck]==token then sound:Pause();sound.PlaybackSpeed=d.pitch;d.busyFx=nil;broadcast() end
 end)
end

local function momentaryRoll(deck,step)
 local sound,_,_,d=deckObjects(deck);if not sound or not d or d.assetId<1 or not sound.Playing then return end
 fxTokens[deck]+=1;local token=fxTokens[deck];d.busyFx=step<=.18 and "ROLL 1/4" or "ROLL 1/2"
 local start=sound.TimePosition;local finish=os.clock()+1.35
 task.spawn(function()
  while os.clock()<finish do
   if fxTokens[deck]~=token or not sound.Parent then return end
   sound.TimePosition=start;task.wait(step)
  end
  if fxTokens[deck]==token then d.busyFx=nil;broadcast() end
 end)
end

local function handle(player,action,payload)
 if not authorized(player) then return end
 action=string.lower(tostring(action or ""));payload=type(payload)=="table" and payload or {}
 local deck=string.upper(tostring(payload.deck or ""));local sound,_,_,d=deckObjects(deck)
 if action=="load" then loadDeck(deck,payload.assetId)
 elseif action=="play_toggle" and sound and d then if d.assetId<1 then return end;if sound.Playing then sound:Pause() else sound:Play() end
 elseif action=="cue" and sound and d then sound.TimePosition=math.max(0,d.cue or 0)
 elseif action=="set_cue" and sound and d then d.cue=math.max(0,sound.TimePosition)
 elseif action=="sync" and d then syncDeck(deck)
 elseif action=="fx_toggle" and d then toggleFx(deck,string.lower(tostring(payload.fx or "")))
 elseif action=="fx_trigger" and d then
  local fx=string.upper(tostring(payload.fx or ""))
  if fx=="BRAKE" then momentaryBrake(deck) elseif fx=="ROLL_HALF" then momentaryRoll(deck,.32) elseif fx=="ROLL_QUARTER" then momentaryRoll(deck,.16) end
 elseif action=="crossfader" then state.crossfader=clamp(payload.value,0,1);applyMix()
 elseif action=="venue" then setVenue(payload.value)
 elseif action=="go_live" then goLive(player)
 elseif action=="end_live" then stopLive()
 else return end
 broadcast()
end

actionRemote.OnServerEvent:Connect(handle)
getState.OnServerInvoke=function(player)if not authorized(player) then return {authorized=false} end;return snapshot() end
local function applyAuth(p)local id=identity(p);p:SetAttribute("BBYADeveloperDJAuthorized",id~=nil);p:SetAttribute("BBYADeveloperDJIdentity",id) end
for _,p in ipairs(Players:GetPlayers()) do applyAuth(p) end
Players.PlayerAdded:Connect(applyAuth)
Players.PlayerRemoving:Connect(function()
 task.defer(function()if not state.live then return end;for _,p in ipairs(Players:GetPlayers()) do if authorized(p) then return end end;stopLive() end)
end)

task.spawn(function()while task.wait(.2) do if state.live and suppressed.group and suppressed.group.Parent then suppressed.group.Volume=0 end end end)
task.spawn(function()while task.wait(.35) do if state.live or soundA.Playing or soundB.Playing then broadcast() end end end)
game:BindToClose(function()restoreVenue()end)
applyLiveRouting();applyMix()
print("[BBYA] Developer DJ Mixer v2 online: fullscreen vinyl UI backend + SYNC + 9 FX/deck")
