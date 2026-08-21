-- BBYA SOCIAL HUB — HYBRID AUTODJ v6
-- Dual-deck queued AutoMix:
--   Deck A/B alternate LIVE and STANDBY roles.
--   Requests enter FIFO queue, preload to standby, and NEVER start immediately.
--   Standby only goes live during the scheduled AutoMix transition.
--   Failed/private audio is quarantined so the venue cannot stay silent.
-- Roblox Sound has no BPM/beat-grid analyser, so this is a guarded club-style
-- preload + overlap crossfade AutoMix rather than true BPM beatmatching.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")
local Workspace=game:GetService("Workspace")
local SoundService=game:GetService("SoundService")
local TweenService=game:GetService("TweenService")
local ContentProvider=game:GetService("ContentProvider")

local folder=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
folder.Name="BBYAClubRemotes";folder.Parent=ReplicatedStorage
local musicRemote=folder:FindFirstChild("Music") or Instance.new("RemoteEvent");musicRemote.Name="Music";musicRemote.Parent=folder
local supportRemote=folder:FindFirstChild("Support") or Instance.new("RemoteEvent");supportRemote.Name="Support";supportRemote.Parent=folder
local stateRemote=folder:FindFirstChild("State") or Instance.new("RemoteEvent");stateRemote.Name="State";stateRemote.Parent=folder
local internalMusic=folder:FindFirstChild("InternalMusic") or Instance.new("BindableEvent");internalMusic.Name="InternalMusic";internalMusic.Parent=folder

local PLAYLIST={
 {title="Pumpin' And Bumpin' D",id="9040442826",style="club"},
 {title="DJ Party Time",id="90337553112855",style="club"},
 {title="Electronic Music",id="1846869595",style="electronic"},
 {title="Electronic Avenue",id="84504061779927",style="electronic"},
 {title="DJ",id="15878422179",style="club"},
 {title="Welcome",id="137350000972072",style="dance"},
 {title="Store",id="1837393392",style="club"},
 {title="Breakbeat : Pyro Pulse",id="103491797412309",style="breakbeat"},
 {title="Aku Suka Jedag Jedug Full Bass",id="100787734732008",style="breakbeat"},
 {title="DJ Bahagiamu Sayang Funkot",id="110691393637838",style="funkot"},
 {title="DJ Mama Muda Enak Dong",id="134073539670673",style="funkot"},
 {title="Jamilah Itu Bukan Anunya Aisyah",id="116255319981650",style="funkot"},
 {title="DNA Indo Bounce",id="101399039672234",style="indo-bounce"},
 {title="FUNKOT",id="124224888312006",style="funkot"},
 {title="FUNKOT Alt",id="83125775305712",style="funkot"},
 {title="FUNKOT Melody Rhythm",id="95602240268105",style="funkot"},
 {title="DJ Funkot - Karna Kamu Cantik",id="103451932037576",style="funkot"},
 {title="FUNKOT Jangan Pergi",id="139850430998864",style="funkot"},
 {title="Funkot - Aku Tak Berarti Bagimu",id="98095276635738",style="funkot"},
 {title="FUNKOT Ngamen 5",id="134100771661430",style="funkot"},
 {title="FUNKOT Garam Cina",id="79905157574964",style="funkot"},
 {title="DJ Funkot Ego Wong Tuo",id="78891075630689",style="funkot"},
 {title="Breakbeat Sayang Cintaku Istimewa",id="74711864477200",style="breakbeat"},
 {title="Breakbeat Rindu Aku Rindu Kamu",id="133512901677493",style="breakbeat"},
 {title="Despacito Breakbeat Remix",id="72539481653856",style="breakbeat"},
 {title="Breakbeat Yang Telah Merela",id="83142601388157",style="breakbeat"},
 {title="Breakbeat Bawa Dia Kembali",id="86760182936616",style="breakbeat"},
 {title="Breakbeat Remon x Asik Sekali",id="84377101694514",style="breakbeat"},
 {title="Breakbeat Dora Dora",id="105003998270064",style="breakbeat"},
}

local SUPPORT_PRODUCTS={
 {label="10",amount=10,productId=3709047095},{label="25",amount=25,productId=3709047097},
 {label="50",amount=50,productId=3709047101},{label="100",amount=100,productId=3709047104},
 {label="250",amount=250,productId=3709047106},{label="500",amount=500,productId=3709047107},
 {label="1000",amount=1000,productId=3709047109},{label="2000",amount=2000,productId=3709048779},
}

local MIX_SECONDS=4.0
local PRELOAD_WINDOW=14.0
local LOAD_TIMEOUT=5.0
local REQUEST_COOLDOWN=20
local MAX_QUEUE=8
local SAFE_CORE={1,2,3,4,5,6,7}

local function isAdmin(player)
 if not player then return false end
 if player:GetAttribute("BBYAAdmin")==true then return true end
 return game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId
end
local function denyTransport(player)
 stateRemote:FireClient(player,"toast","DJ transport controls khusus admin. Gunakan Request untuk antrean lagu.")
end

-- Single canonical master timeline.
local oldZones=Workspace:FindFirstChild("BBYAAudioZones");if oldZones then oldZones:Destroy() end
for _,obj in ipairs(Workspace:GetDescendants()) do
 if obj:IsA("Sound") and (obj.Name=="BBYAClubSound" or obj.Name:match("^BBYAClubSound_")) then obj:Destroy() end
end
for _,name in ipairs({"BBYAClubFeed","BBYAClubDeckA","BBYAClubDeckB"}) do
 local old=SoundService:FindFirstChild(name);if old then old:Destroy() end
end

local group=SoundService:FindFirstChild("BBYAClubMaster")
if not group then group=Instance.new("SoundGroup");group.Name="BBYAClubMaster";group.Parent=SoundService end
group.Volume=1
group:SetAttribute("BBYAAudioMode","DUAL_DECK_AUTOMIX_V6")
group:SetAttribute("PlaylistCount",#PLAYLIST)
group:SetAttribute("MixSeconds",MIX_SECONDS)
group:SetAttribute("QueuePolicy","FIFO_REQUEST_TO_STANDBY")

local eq=group:FindFirstChild("ClubEQ")
if not eq then eq=Instance.new("EqualizerSoundEffect");eq.Name="ClubEQ";eq.Parent=group end
eq.LowGain=1.15;eq.MidGain=-.15;eq.HighGain=.45
local compressor=group:FindFirstChild("VenueCompressor")
if not compressor then compressor=Instance.new("CompressorSoundEffect");compressor.Name="VenueCompressor";compressor.Parent=group end
compressor.Threshold=-10;compressor.Ratio=2.25;compressor.Attack=.06;compressor.Release=.28;compressor.GainMakeup=.5

local function makeDeck(name)
 local s=Instance.new("Sound")
 s.Name=name;s.Volume=0;s.Looped=false;s.SoundGroup=group;s.Parent=SoundService
 s:SetAttribute("DeckRole","STANDBY")
 s:SetAttribute("PreparedIndex",0)
 s:SetAttribute("PreparedReady",false)
 return s
end

local deckA=makeDeck("BBYAClubDeckA")
local deckB=makeDeck("BBYAClubDeckB")
local activeDeck,standbyDeck=deckA,deckB
activeDeck:SetAttribute("DeckRole","LIVE")

local seed=os.time()
for i=1,#game.JobId do seed=(seed*33+string.byte(game.JobId,i))%2147483646 end
local rng=Random.new(math.max(1,seed))

local current=0
local shuffleBag={}
local requestQueue={}
local requestCooldown={}
local badTracks={}
local transitioning=false
local paused=false
local standbyIndex=nil
local standbyFromRequest=false
local standbyLoadToken=0

local function validTrack(i)
 local t=PLAYLIST[i]
 return t and t.id and tostring(t.id)~="" and not badTracks[i]
end
local function soundIdFor(i)
 return validTrack(i) and ("rbxassetid://"..tostring(PLAYLIST[i].id)) or nil
end
local function deckName(deck)return deck==deckA and "A" or "B" end

local function fireMusicState(playing)
 local t=PLAYLIST[current]
 local qTop=requestQueue[1]
 stateRemote:FireAllClients("music",{
  index=current,title=t and t.title or "",style=t and t.style or "",playing=playing,
  queue=#requestQueue,audioMode="DUAL_DECK_AUTOMIX",library=#PLAYLIST,
  liveDeck=deckName(activeDeck),standbyDeck=deckName(standbyDeck),
  standbyIndex=standbyIndex or 0,standbyTitle=(standbyIndex and PLAYLIST[standbyIndex] and PLAYLIST[standbyIndex].title) or "",
  nextRequest=qTop and qTop.index or 0,mixSeconds=MIX_SECONDS,
 })
end

local function quarantine(i,reason)
 if not i or badTracks[i] then return end
 badTracks[i]=reason or true
 local t=PLAYLIST[i]
 warn(string.format("[BBYA] quarantined track %d %s (%s)",i,t and t.title or "?",tostring(reason)))
 group:SetAttribute("LastBadTrack",i)
 group:SetAttribute("LastBadReason",tostring(reason))
end

local function rebuildShuffleBag()
 shuffleBag={}
 for i=1,#PLAYLIST do
  if validTrack(i) and i~=current then table.insert(shuffleBag,i) end
 end
 for i=#shuffleBag,2,-1 do
  local j=rng:NextInteger(1,i)
  shuffleBag[i],shuffleBag[j]=shuffleBag[j],shuffleBag[i]
 end
end
local function ensureShuffleBag()
 if #shuffleBag==0 then rebuildShuffleBag() end
end
local function peekRandom()
 ensureShuffleBag()
 while #shuffleBag>0 and not validTrack(shuffleBag[#shuffleBag]) do table.remove(shuffleBag) end
 return shuffleBag[#shuffleBag]
end
local function consumeRandom()
 local i=peekRandom();if i then table.remove(shuffleBag) end;return i
end

local function firstValidRequest()
 while #requestQueue>0 do
  local req=requestQueue[1]
  if validTrack(req.index) then return req end
  table.remove(requestQueue,1)
  stateRemote:FireAllClients("toast","Satu request dilewati karena audio tidak tersedia di Roblox.")
 end
end

local function desiredStandby()
 local req=firstValidRequest()
 if req then return req.index,true end
 return peekRandom(),false
end

local function waitLoaded(sound,timeout)
 local deadline=os.clock()+(timeout or LOAD_TIMEOUT)
 while os.clock()<deadline do
  if sound.IsLoaded and (sound.TimeLength or 0)>1 then return true end
  task.wait(.12)
 end
 return sound.IsLoaded and (sound.TimeLength or 0)>1
end

local function prepareStandby(i,fromRequest)
 if not validTrack(i) or transitioning then return false end
 if standbyIndex==i and standbyDeck:GetAttribute("PreparedReady")==true then
  standbyFromRequest=fromRequest==true
  return true
 end
 standbyLoadToken+=1
 local token=standbyLoadToken
 standbyIndex=i
 standbyFromRequest=fromRequest==true
 standbyDeck:Stop();standbyDeck.Volume=0
 standbyDeck.SoundId=soundIdFor(i);standbyDeck.TimePosition=0
 standbyDeck:SetAttribute("PreparedIndex",i)
 standbyDeck:SetAttribute("PreparedReady",false)
 standbyDeck:SetAttribute("DeckRole","STANDBY")
 fireMusicState(activeDeck.IsPlaying and not paused)
 task.spawn(function()
  local ok=pcall(function()ContentProvider:PreloadAsync({standbyDeck})end)
  if token~=standbyLoadToken or standbyIndex~=i then return end
  local loaded=ok and waitLoaded(standbyDeck,LOAD_TIMEOUT)
  if loaded then
   standbyDeck:SetAttribute("PreparedReady",true)
   group:SetAttribute("StandbyReadyIndex",i)
  else
   quarantine(i,"preload_failed")
   standbyDeck:SetAttribute("PreparedReady",false)
   standbyIndex=nil;standbyFromRequest=false
   task.defer(function()
    local ni,nreq=desiredStandby()
    if ni then prepareStandby(ni,nreq) end
   end)
  end
  fireMusicState(activeDeck.IsPlaying and not paused)
 end)
 return true
end

local function ensureDesiredStandby()
 if transitioning then return end
 local i,fromReq=desiredStandby()
 if not i then return end
 -- A new request must replace a random standby preload, but never interrupt live audio.
 if standbyIndex~=i or standbyFromRequest~=(fromReq==true) then
  prepareStandby(i,fromReq)
 end
end

local function playOnDeckGuarded(deck,i,audible)
 if not validTrack(i) then return false end
 deck:Stop();deck.SoundId=soundIdFor(i);deck.TimePosition=0;deck.Volume=audible and 1 or 0
 local ok=pcall(function()ContentProvider:PreloadAsync({deck})end)
 if not ok then quarantine(i,"preload_error");return false end
 deck:Play()
 if not waitLoaded(deck,LOAD_TIMEOUT) then
  deck:Stop();quarantine(i,"load_timeout");return false
 end
 -- Confirm timeline can actually advance. Some restricted assets report playing but never move.
 local p0=deck.TimePosition
 task.wait(.28)
 if deck.TimePosition<=p0+.02 then
  deck:Stop();quarantine(i,"timeline_stalled");return false
 end
 return true
end

local function chooseStartup()
 local tries={}
 for i=1,#PLAYLIST do table.insert(tries,i) end
 for i=#tries,2,-1 do local j=rng:NextInteger(1,i);tries[i],tries[j]=tries[j],tries[i] end
 for _,i in ipairs(tries) do if validTrack(i) then return i end end
 return SAFE_CORE[rng:NextInteger(1,#SAFE_CORE)]
end

local function startInitial()
 local attempt=0
 while attempt<#PLAYLIST+3 do
  attempt+=1
  local i=chooseStartup()
  if playOnDeckGuarded(activeDeck,i,true) then
   current=i
   activeDeck:SetAttribute("DeckRole","LIVE")
   activeDeck:SetAttribute("PreparedIndex",i)
   activeDeck:SetAttribute("PreparedReady",true)
   standbyDeck:SetAttribute("DeckRole","STANDBY")
   shuffleBag={}
   fireMusicState(true)
   ensureDesiredStandby()
   print(string.format("[BBYA] AutoMix startup -> Deck %s / %s",deckName(activeDeck),PLAYLIST[i].title))
   return true
  end
 end
 return false
end

local function popRequestIfMatches(i)
 local req=requestQueue[1]
 if req and req.index==i then
  table.remove(requestQueue,1)
  return req
 end
end

local function transitionPrepared(forceImmediate)
 if transitioning or paused then return false end
 ensureDesiredStandby()
 local nextIndex=standbyIndex
 if not nextIndex or not validTrack(nextIndex) then return false end

 local ready=standbyDeck:GetAttribute("PreparedReady")==true
 if not ready then
  local deadline=os.clock()+LOAD_TIMEOUT
  while os.clock()<deadline and standbyIndex==nextIndex and not transitioning do
   if standbyDeck:GetAttribute("PreparedReady")==true then ready=true;break end
   task.wait(.1)
  end
 end
 if not ready or standbyIndex~=nextIndex then
  quarantine(nextIndex,"standby_not_ready")
  standbyIndex=nil;standbyFromRequest=false
  ensureDesiredStandby()
  return false
 end

 transitioning=true
 local oldDeck,newDeck=activeDeck,standbyDeck
 local wasRequest=standbyFromRequest
 local req=wasRequest and popRequestIfMatches(nextIndex) or nil
 current=nextIndex

 newDeck.TimePosition=0
 newDeck.Volume=forceImmediate and 1 or 0
 newDeck:SetAttribute("DeckRole","MIXING_IN")
 oldDeck:SetAttribute("DeckRole","MIXING_OUT")
 newDeck:Play()

 -- Validate the incoming deck while outgoing deck is still audible.
 local p0=newDeck.TimePosition
 task.wait(.25)
 if not newDeck.IsPlaying or newDeck.TimePosition<=p0+.02 then
  newDeck:Stop();newDeck.Volume=0
  oldDeck.Volume=1;oldDeck:SetAttribute("DeckRole","LIVE")
  quarantine(nextIndex,"incoming_stalled")
  transitioning=false;standbyIndex=nil;standbyFromRequest=false
  if req then stateRemote:FireAllClients("toast","Request dilewati: audio tidak dapat diputar.") end
  ensureDesiredStandby();fireMusicState(oldDeck.IsPlaying)
  return false
 end

 if req then
  stateRemote:FireAllClients("toast",string.format("AutoMix request: %s",PLAYLIST[nextIndex].title))
 end
 fireMusicState(true)

 if forceImmediate then
  oldDeck:Stop();oldDeck.Volume=0
 else
  local ti=TweenInfo.new(MIX_SECONDS,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
  local down=TweenService:Create(oldDeck,ti,{Volume=0})
  local up=TweenService:Create(newDeck,ti,{Volume=1})
  down:Play();up:Play();up.Completed:Wait()
  oldDeck:Stop();oldDeck.Volume=0
 end

 activeDeck,standbyDeck=newDeck,oldDeck
 activeDeck:SetAttribute("DeckRole","LIVE")
 activeDeck:SetAttribute("PreparedIndex",current)
 activeDeck:SetAttribute("PreparedReady",true)
 standbyDeck:SetAttribute("DeckRole","STANDBY")
 standbyDeck:SetAttribute("PreparedIndex",0)
 standbyDeck:SetAttribute("PreparedReady",false)
 standbyDeck.SoundId=""
 standbyIndex=nil;standbyFromRequest=false
 transitioning=false

 -- The deck roles have now swapped. Immediately preload queue head to the free deck.
 ensureDesiredStandby()
 fireMusicState(true)
 return true
end

local function forcePlay(i)
 if not validTrack(i) then return false end
 transitioning=false;paused=false
 activeDeck:Stop();standbyDeck:Stop();standbyDeck.Volume=0
 if playOnDeckGuarded(activeDeck,i,true) then
  current=i;activeDeck:SetAttribute("DeckRole","LIVE");standbyDeck:SetAttribute("DeckRole","STANDBY")
  standbyIndex=nil;standbyFromRequest=false;shuffleBag={}
  fireMusicState(true);ensureDesiredStandby();return true
 end
 ensureDesiredStandby();return false
end

local function queueRequest(player,index)
 index=tonumber(index)
 if not player or not validTrack(index) then
  if player then stateRemote:FireClient(player,"toast","Track itu tidak tersedia untuk diputar.") end
  return false
 end
 local now=os.clock();local last=requestCooldown[player.UserId] or 0
 if now-last<REQUEST_COOLDOWN then
  stateRemote:FireClient(player,"toast","Tunggu sebentar sebelum request lagu lagi.");return false
 end
 if #requestQueue>=MAX_QUEUE then
  stateRemote:FireClient(player,"toast","DJ request queue sedang penuh.");return false
 end
 for _,req in ipairs(requestQueue) do
  if req.playerId==player.UserId and req.index==index then
   stateRemote:FireClient(player,"toast","Request itu sudah ada di antrean.");return false
  end
 end
 requestCooldown[player.UserId]=now
 table.insert(requestQueue,{playerId=player.UserId,index=index,requestedAt=os.time()})
 local position=#requestQueue
 stateRemote:FireClient(player,"toast",string.format("Request antrean #%d: %s • dipreload ke deck standby, tidak langsung nyala.",position,PLAYLIST[index].title))
 stateRemote:FireClient(player,"djQueue",{position=position,count=#requestQueue,title=PLAYLIST[index].title,now=PLAYLIST[current] and PLAYLIST[current].title or ""})
 -- If the standby currently contains a random track, queue head takes priority and replaces it.
 ensureDesiredStandby()
 fireMusicState(activeDeck.IsPlaying and not paused)
 return true
end

local function onDeckEnded(deck)
 if deck~=activeDeck or transitioning or paused then return end
 task.defer(function()
  if not transitionPrepared(true) then
   ensureDesiredStandby()
   task.wait(.35)
   transitionPrepared(true)
  end
 end)
end
deckA.Ended:Connect(function()onDeckEnded(deckA)end)
deckB.Ended:Connect(function()onDeckEnded(deckB)end)

musicRemote.OnServerEvent:Connect(function(player,action,arg)
 if action=="list" then
  stateRemote:FireClient(player,"playlist",PLAYLIST);fireMusicState(activeDeck.IsPlaying and not paused)
 elseif action=="request" then queueRequest(player,arg)
 elseif action=="queue" then
  stateRemote:FireClient(player,"djQueue",{position=0,count=#requestQueue,now=PLAYLIST[current] and PLAYLIST[current].title or ""})
 elseif action=="play" then
  if isAdmin(player) then forcePlay(tonumber(arg) or current) else denyTransport(player) end
 elseif action=="pause" then
  if isAdmin(player) then paused=true;activeDeck:Pause();standbyDeck:Pause();fireMusicState(false) else denyTransport(player) end
 elseif action=="resume" then
  if isAdmin(player) then paused=false;activeDeck:Resume();fireMusicState(true) else denyTransport(player) end
 elseif action=="next" then
  if isAdmin(player) then transitionPrepared(false) else denyTransport(player) end
 end
end)

internalMusic.Event:Connect(function(action,player,arg)
 if action=="request" then queueRequest(player,arg)
 elseif action=="next" then transitionPrepared(false)
 elseif action=="random" then
  -- Recovery: keep queue intact; force a known core track only if active feed is dead.
  local candidates={}
  for _,i in ipairs(SAFE_CORE) do if validTrack(i) then table.insert(candidates,i) end end
  if #candidates>0 then forcePlay(candidates[rng:NextInteger(1,#candidates)]) end
 elseif action=="play" then forcePlay(tonumber(arg) or current)
 elseif action=="queue" and player then
  stateRemote:FireClient(player,"djQueue",{position=0,count=#requestQueue,now=PLAYLIST[current] and PLAYLIST[current].title or ""})
 end
end)

supportRemote.OnServerEvent:Connect(function(player,action,arg)
 if action=="list" then stateRemote:FireClient(player,"supportProducts",SUPPORT_PRODUCTS);return end
 if action~="prompt" then return end
 local idx=tonumber(arg);local item=idx and SUPPORT_PRODUCTS[idx]
 if item then MarketplaceService:PromptProductPurchase(player,item.productId) end
end)

Players.PlayerAdded:Connect(function(player)
 task.delay(2,function()
  if player.Parent then
   stateRemote:FireClient(player,"playlist",PLAYLIST)
   stateRemote:FireClient(player,"supportProducts",SUPPORT_PRODUCTS)
   local t=PLAYLIST[current]
   stateRemote:FireClient(player,"music",{
    index=current,title=t and t.title or "",style=t and t.style or "",playing=activeDeck.IsPlaying and not paused,
    queue=#requestQueue,audioMode="DUAL_DECK_AUTOMIX",library=#PLAYLIST,
    liveDeck=deckName(activeDeck),standbyDeck=deckName(standbyDeck),standbyIndex=standbyIndex or 0,mixSeconds=MIX_SECONDS,
   })
  end
 end)
end)
Players.PlayerRemoving:Connect(function(player)requestCooldown[player.UserId]=nil end)

-- AutoMix scheduler. The standby deck is prepared early, but remains silent until mix time.
task.spawn(function()
 while task.wait(.20) do
  if not transitioning and not paused and activeDeck.IsPlaying then
   local len,pos=activeDeck.TimeLength,activeDeck.TimePosition
   if len and len>5 then
    local remain=len-pos
    if remain<=PRELOAD_WINDOW then ensureDesiredStandby() end
    if remain<=MIX_SECONDS+.35 then
     task.spawn(function()transitionPrepared(false)end)
    end
   end
  end
 end
end)

-- Startup guarded random: try full library, quarantine broken assets, never intentionally start from track 1.
task.spawn(function()
 task.wait(1)
 if not startInitial() then
  warn("[BBYA] AutoMix v6 could not start any playable track; health guard will continue recovery attempts")
 end
end)

print(string.format("[BBYA] Hybrid AutoDJ v6 online: %d tracks / Deck A-B queued AutoMix / %.1fs crossfade",#PLAYLIST,MIX_SECONDS))