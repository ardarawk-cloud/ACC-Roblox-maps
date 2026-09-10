-- BBYA SOCIAL HUB — FUNKOT DISKOTIK RUNTIME AUDIO v7
-- Single Funkot playback authority: random autoplay + dual-deck preload + 4s AutoMix crossfade.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local TweenService=game:GetService("TweenService")
local ContentProvider=game:GetService("ContentProvider")

local PLAYLIST={
 {title="Zinyo Funkytone - Siapa Benar - Garam Cina 2025.mp3",id="128141893547516",style="funkot"},
 {title="Zinyo Funky Tone_ Hatiku Bagai Terpenjara 2025.mp3",id="98536948000407",style="funkot"},
 {title="Space Melody '23 _ Dj Deri Rmx • Qiu-Qiu™️.mp3",id="128567852049551",style="funkot"},
 {title="Funkot 05",id="100016584788711",style="funkot"},
 {title="Funkot 08",id="86909888091389",style="funkot"},
 {title="Funkot 09",id="73235337855180",style="funkot"},
 {title="Funkot 010",id="97838388220371",style="funkot"},
 {title="Funkot 012",id="124258279552326",style="funkot"},
 {title="Funkot 013",id="71841168589434",style="funkot"},
 {title="Funkot 014",id="115949536250644",style="funkot"},
 {title="Funkot 016",id="80455182993028",style="funkot"},
 {title="Funkot 018",id="126095451248910",style="funkot"},
 {title="Funkot 020",id="138159857843385",style="funkot"},
}
if #PLAYLIST==0 then return end

local MIX_SECONDS=4.0
local PRELOAD_WINDOW=14.0
local LOAD_TIMEOUT=5.0

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local remote=remotes:FindFirstChild("FunkotMusic")
if remote and not remote:IsA("RemoteEvent") then remote:Destroy();remote=nil end
if not remote then remote=Instance.new("RemoteEvent");remote.Name="FunkotMusic";remote.Parent=remotes end

local group=SoundService:FindFirstChild("BBYAFunkotMaster")
if group and not group:IsA("SoundGroup") then group:Destroy();group=nil end
if not group then group=Instance.new("SoundGroup");group.Name="BBYAFunkotMaster";group.Parent=SoundService end
group.Volume=1.0
group:SetAttribute("Venue","FUNKOT")
group:SetAttribute("PlaylistReady",true)
group:SetAttribute("PlaylistCount",#PLAYLIST)
group:SetAttribute("AudioEngine","FUNKOT_DUAL_DECK_V7")
group:SetAttribute("AutoDJHealthy",true)
group:SetAttribute("AutoMix",true)
group:SetAttribute("MixSeconds",MIX_SECONDS)
group:SetAttribute("ShuffleStartup",true)
group:SetAttribute("VenueGainProfile","FUNKOT_FULL_LEVEL_ROUTER_V9")

ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistEnabled",true)
ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistId","funkot")
ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistCount",#PLAYLIST)

for _,n in ipairs({"BBYAFunkotClubFeed","BBYAFunkotDeck","BBYAFunkotPlaylistV1","BBYAFunkotPlaylistV2","BBYAFunkotPlaylistV3","BBYAFunkotRuntimeV4","BBYAFunkotRuntimeV5","BBYAFunkotRuntimeV6","BBYAFunkotRuntimeV7","BBYAFunkotDeckA","BBYAFunkotDeckB"}) do
 local o=SoundService:FindFirstChild(n)
 if o and o:IsA("Sound") then pcall(function()o:Stop()end);o:Destroy() end
end

local function makeDeck(name)
 local s=Instance.new("Sound")
 s.Name=name;s.SoundGroup=group;s.Volume=0;s.Looped=false;s.Parent=SoundService
 s:SetAttribute("DeckRole","STANDBY")
 s:SetAttribute("PreparedIndex",0)
 s:SetAttribute("PreparedReady",false)
 return s
end

local deckA=makeDeck("BBYAFunkotDeckA")
local deckB=makeDeck("BBYAFunkotDeckB")
local activeDeck,standbyDeck=deckA,deckB
activeDeck:SetAttribute("DeckRole","LIVE")

local current=0
local paused=false
local transitioning=false
local queue={}
local cooldown={}
local retryAfter={}
local health={}
local failCount={}
local shuffleBag={}
local standbyIndex=nil
local standbyFromQueue=false
local standbyLoadToken=0
local seed=os.time()
for i=1,#game.JobId do seed=(seed*33+string.byte(game.JobId,i))%2147483646 end
local rng=Random.new(math.max(1,seed))

local function inZone(p)
 local c=p and p.Character
 local h=c and c:FindFirstChild("HumanoidRootPart")
 if not h then return false end
 local x=h.Position
 return x.Y>-4 and x.Y<34 and math.abs(x.X)<61 and x.Z>157 and x.Z<253
end

local function admin(p)
 return p and (p:GetAttribute("BBYAAdmin")==true or (game.CreatorType==Enum.CreatorType.User and p.UserId==game.CreatorId))
end

local function available(i)
 return PLAYLIST[i] and (not retryAfter[i] or os.clock()>=retryAfter[i])
end

local function deckName(deck)
 return deck==deckA and "A" or "B"
end

local function state()
 local t=PLAYLIST[current]
 local unavailable=0
 for i=1,#PLAYLIST do if retryAfter[i] and os.clock()<retryAfter[i] then unavailable+=1 end end
 return {
  venue="FUNKOT",genre="FUNKOT",index=current,
  title=t and t.title or "Funkot AutoDJ",style="funkot",
  playing=activeDeck.IsPlaying and not paused,library=#PLAYLIST,queue=#queue,
  unavailable=unavailable,audioMode="FUNKOT_DUAL_DECK_AUTOMIX_V7",
  liveDeck=deckName(activeDeck),standbyDeck=deckName(standbyDeck),
  standbyIndex=standbyIndex or 0,
  standbyTitle=(standbyIndex and PLAYLIST[standbyIndex] and PLAYLIST[standbyIndex].title) or "",
  mixSeconds=MIX_SECONDS,
 }
end

local function fire(p)
 if p then remote:FireClient(p,"state",state());return end
 for _,pl in ipairs(Players:GetPlayers()) do if inZone(pl) then remote:FireClient(pl,"state",state()) end end
end

local function ack(p,msg)
 if p then remote:FireClient(p,"ack",msg) end
end

local function markFailure(i,reason)
 failCount[i]=(failCount[i] or 0)+1
 health[i]=false
 local waitSeconds=math.min(120,20*(2^math.min(failCount[i]-1,2)))
 retryAfter[i]=os.clock()+waitSeconds
 local t=PLAYLIST[i]
 group:SetAttribute("LastUnavailableAssetId",t and t.id or "")
 group:SetAttribute("LastUnavailableTitle",t and t.title or "")
 group:SetAttribute("LastUnavailableRetrySeconds",waitSeconds)
 group:SetAttribute("LastUnavailableReason",reason or "playback_failed")
end

local function markHealthy(i)
 failCount[i]=0;health[i]=true;retryAfter[i]=nil
end

local function setCurrentMetadata(i)
 local t=PLAYLIST[i]
 if not t then return end
 current=i
 group:SetAttribute("CurrentAssetId",t.id)
 group:SetAttribute("CurrentTitle",t.title)
 group:SetAttribute("CurrentTrackIndex",i)
 group:SetAttribute("LastSuccessfulAssetId",t.id)
 group:SetAttribute("LastSuccessfulTitle",t.title)
 ReplicatedStorage:SetAttribute("BBYAFunkotCurrentTitle",t.title)
 ReplicatedStorage:SetAttribute("BBYAFunkotCurrentAssetId",t.id)
end

local function waitLoaded(sound,timeout)
 local deadline=os.clock()+(timeout or LOAD_TIMEOUT)
 while os.clock()<deadline do
  if sound.IsLoaded and (sound.TimeLength or 0)>1 then return true end
  task.wait(.12)
 end
 return sound.IsLoaded and (sound.TimeLength or 0)>1
end

local function soundIdFor(i)
 return available(i) and ("rbxassetid://"..tostring(PLAYLIST[i].id)) or nil
end

local function shuffled(indices)
 for i=#indices,2,-1 do
  local j=rng:NextInteger(1,i)
  indices[i],indices[j]=indices[j],indices[i]
 end
 return indices
end

local function rebuildShuffleBag()
 shuffleBag={}
 for i=1,#PLAYLIST do if i~=current and available(i) then table.insert(shuffleBag,i) end end
 shuffled(shuffleBag)
end

local function nextRandom()
 if #shuffleBag==0 then rebuildShuffleBag() end
 while #shuffleBag>0 do
  local i=table.remove(shuffleBag)
  if i~=current and available(i) then return i end
 end
 if current>0 and available(current) then return current end
end

local function firstQueue()
 while #queue>0 do
  if available(queue[1].index) then return queue[1] end
  table.remove(queue,1)
 end
end

local function desiredStandby()
 local q=firstQueue()
 if q then return q.index,true end
 return nextRandom(),false
end

local function prepareStandby(i,fromQueue)
 if not i or not available(i) or transitioning then return false end
 if standbyIndex==i and standbyDeck:GetAttribute("PreparedReady")==true then
  standbyFromQueue=fromQueue==true
  return true
 end
 standbyLoadToken+=1
 local token=standbyLoadToken
 standbyIndex=i
 standbyFromQueue=fromQueue==true
 standbyDeck:Stop();standbyDeck.Volume=0;standbyDeck.TimePosition=0
 standbyDeck.SoundId=soundIdFor(i) or ""
 standbyDeck:SetAttribute("PreparedIndex",i)
 standbyDeck:SetAttribute("PreparedReady",false)
 standbyDeck:SetAttribute("DeckRole","STANDBY")
 fire()
 task.spawn(function()
  local ok=pcall(function()ContentProvider:PreloadAsync({standbyDeck})end)
  if token~=standbyLoadToken or standbyIndex~=i then return end
  if ok and waitLoaded(standbyDeck,LOAD_TIMEOUT) then
   standbyDeck:SetAttribute("PreparedReady",true)
   group:SetAttribute("StandbyReadyIndex",i)
  else
   markFailure(i,"preload_failed")
   standbyDeck:SetAttribute("PreparedReady",false)
   standbyIndex=nil;standbyFromQueue=false
   task.defer(function()
    local ni,nq=desiredStandby()
    if ni then prepareStandby(ni,nq) end
   end)
  end
  fire()
 end)
 return true
end

local function ensureStandby()
 if transitioning then return end
 local i,fromQueue=desiredStandby()
 if i and (standbyIndex~=i or standbyFromQueue~=(fromQueue==true)) then
  prepareStandby(i,fromQueue)
 end
end

local function startOnDeck(deck,i,audible)
 if not i or not available(i) then return false end
 deck:Stop();deck.SoundId=soundIdFor(i) or "";deck.TimePosition=0;deck.Volume=audible and .92 or 0
 local ok=pcall(function()ContentProvider:PreloadAsync({deck})end)
 if not ok or not waitLoaded(deck,LOAD_TIMEOUT) then
  markFailure(i,"load_failed");return false
 end
 deck:Play()
 local p0=deck.TimePosition
 task.wait(.28)
 if not deck.IsPlaying or deck.TimePosition<=p0+.02 then
  deck:Stop();markFailure(i,"timeline_stalled");return false
 end
 markHealthy(i)
 return true
end

local function startInitial()
 local tries={}
 for i=1,#PLAYLIST do if available(i) then table.insert(tries,i) end end
 shuffled(tries)
 for _,i in ipairs(tries) do
  if startOnDeck(activeDeck,i,true) then
   setCurrentMetadata(i)
   activeDeck:SetAttribute("DeckRole","LIVE")
   activeDeck:SetAttribute("PreparedIndex",i)
   activeDeck:SetAttribute("PreparedReady",true)
   standbyDeck:SetAttribute("DeckRole","STANDBY")
   shuffleBag={}
   fire();ensureStandby();return true
  end
 end
 return false
end

local function transitionPrepared(forceImmediate)
 if transitioning or paused then return false end
 ensureStandby()
 local nextIndex=standbyIndex
 if not nextIndex or not available(nextIndex) then return false end
 local ready=standbyDeck:GetAttribute("PreparedReady")==true
 if not ready then
  local deadline=os.clock()+LOAD_TIMEOUT
  while os.clock()<deadline and standbyIndex==nextIndex do
   if standbyDeck:GetAttribute("PreparedReady")==true then ready=true;break end
   task.wait(.1)
  end
 end
 if not ready or standbyIndex~=nextIndex then
  markFailure(nextIndex,"standby_not_ready")
  standbyIndex=nil;standbyFromQueue=false
  ensureStandby();return false
 end

 transitioning=true
 local oldDeck,newDeck=activeDeck,standbyDeck
 local queued=standbyFromQueue
 if queued and queue[1] and queue[1].index==nextIndex then table.remove(queue,1) end
 setCurrentMetadata(nextIndex)
 newDeck.TimePosition=0;newDeck.Volume=forceImmediate and .92 or 0
 newDeck:SetAttribute("DeckRole","MIXING_IN")
 oldDeck:SetAttribute("DeckRole","MIXING_OUT")
 newDeck:Play()
 local p0=newDeck.TimePosition
 task.wait(.25)
 if not newDeck.IsPlaying or newDeck.TimePosition<=p0+.02 then
  newDeck:Stop();newDeck.Volume=0;oldDeck.Volume=.92;oldDeck:SetAttribute("DeckRole","LIVE")
  markFailure(nextIndex,"incoming_stalled")
  transitioning=false;standbyIndex=nil;standbyFromQueue=false
  ensureStandby();fire();return false
 end
 markHealthy(nextIndex)
 fire()
 if forceImmediate then
  oldDeck:Stop();oldDeck.Volume=0
 else
  local ti=TweenInfo.new(MIX_SECONDS,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
  local down=TweenService:Create(oldDeck,ti,{Volume=0})
  local up=TweenService:Create(newDeck,ti,{Volume=.92})
  down:Play();up:Play();up.Completed:Wait();oldDeck:Stop();oldDeck.Volume=0
 end
 activeDeck,standbyDeck=newDeck,oldDeck
 activeDeck:SetAttribute("DeckRole","LIVE")
 activeDeck:SetAttribute("PreparedIndex",current)
 activeDeck:SetAttribute("PreparedReady",true)
 standbyDeck:SetAttribute("DeckRole","STANDBY")
 standbyDeck:SetAttribute("PreparedIndex",0)
 standbyDeck:SetAttribute("PreparedReady",false)
 standbyDeck.SoundId=""
 standbyIndex=nil;standbyFromQueue=false;transitioning=false
 ensureStandby();fire();return true
end

local function forcePlay(i)
 i=tonumber(i)
 if not i or not available(i) then return false end
 transitioning=false;paused=false;standbyLoadToken+=1
 activeDeck:Stop();standbyDeck:Stop();standbyDeck.Volume=0
 if startOnDeck(activeDeck,i,true) then
  setCurrentMetadata(i)
  activeDeck:SetAttribute("DeckRole","LIVE")
  standbyDeck:SetAttribute("DeckRole","STANDBY")
  standbyIndex=nil;standbyFromQueue=false;shuffleBag={}
  fire();ensureStandby();return true
 end
 return false
end

local function onDeckEnded(deck)
 if deck~=activeDeck or transitioning or paused then return end
 task.defer(function()
  if not transitionPrepared(true) then
   task.wait(.4)
   if not transitionPrepared(true) then startInitial() end
  end
 end)
end

deckA.Ended:Connect(function()onDeckEnded(deckA)end)
deckB.Ended:Connect(function()onDeckEnded(deckB)end)

remote.OnServerEvent:Connect(function(p,a,v)
 if a=="list" then remote:FireClient(p,"playlist",PLAYLIST);fire(p);return end
 if a=="state" then fire(p);return end
 if not inZone(p) then return end

 if a=="request" then
  local i=tonumber(v)
  if not i or not PLAYLIST[i] then return end
  local n=os.clock()
  if n-(cooldown[p.UserId] or 0)<3 then return end
  cooldown[p.UserId]=n
  if not available(i) then ack(p,"Track sementara belum tersedia. Coba lagi nanti.");return end
  if not activeDeck.IsPlaying and not transitioning then
   if forcePlay(i) then ack(p,"Diputar: "..PLAYLIST[i].title) else ack(p,"Track belum bisa diputar. AutoDJ lanjut ke track lain.") end
  else
   table.insert(queue,{index=i,userId=p.UserId})
   ack(p,"Request masuk AutoMix: "..PLAYLIST[i].title)
   ensureStandby();fire(p)
  end
 elseif admin(p) and a=="next" then
  transitionPrepared(false)
 elseif admin(p) and a=="play" then
  local i=tonumber(v) or current
  if not forcePlay(i) then task.defer(startInitial) end
 elseif admin(p) and a=="pause" then
  paused=true;pcall(function()activeDeck:Pause()end);fire()
 elseif admin(p) and a=="resume" then
  paused=false;pcall(function()activeDeck:Resume()end)
  if not activeDeck.IsPlaying then task.defer(startInitial) end
  fire()
 end
end)

Players.PlayerRemoving:Connect(function(p)cooldown[p.UserId]=nil end)

task.spawn(function()
 task.wait(1.5)
 if not startInitial() then warn("[BBYA/Funkot] no playable track at startup; watchdog will retry") end
end)

task.spawn(function()
 while task.wait(.20) do
  if not transitioning and not paused and activeDeck.IsPlaying then
   local len,pos=activeDeck.TimeLength,activeDeck.TimePosition
   if len and len>5 then
    local remain=len-pos
    if remain<=PRELOAD_WINDOW then ensureStandby() end
    if remain<=MIX_SECONDS+.35 then task.spawn(function()transitionPrepared(false)end) end
   end
  end
 end
end)

task.spawn(function()
 while task.wait(2) do
  if not paused and not transitioning and not activeDeck.IsPlaying then
   if current>0 then
    ensureStandby()
    if not transitionPrepared(true) then task.defer(startInitial) end
   else
    task.defer(startInitial)
   end
  end
 end
end)

print(string.format("[BBYA] Funkot Dual-Deck AutoMix v7 online: %d tracks / random startup / %.1fs crossfade",#PLAYLIST,MIX_SECONDS))
