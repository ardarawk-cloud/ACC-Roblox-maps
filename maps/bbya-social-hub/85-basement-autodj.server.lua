-- BBYA SOCIAL HUB — UNDERGROUND AUTODJ + APK MIRROR v3
-- One playback authority only. Existing Underground catalog remains fallback until a valid APK catalog arrives.
-- APK transport: Roblox OAuth -> Universe Messaging -> this script -> native DataStore -> existing Deck A/B + panel state.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local TweenService=game:GetService("TweenService")
local ContentProvider=game:GetService("ContentProvider")
local MessagingService=game:GetService("MessagingService")
local DataStoreService=game:GetService("DataStoreService")
local HttpService=game:GetService("HttpService")

local SYNC_TOPIC="BBYA_MUSIC_UNDERGROUND_V1"
local STORE_NAME="BBYAMusicCatalogV1"
local STORE_KEY="zone:underground"
local MIX_SECONDS=4.0
local PRELOAD_WINDOW=14.0
local LOAD_TIMEOUT=6.0
local REQUEST_COOLDOWN=20
local MAX_QUEUE=8

-- HP-confirmed owner library preserved as safety fallback. It is not deleted by the mirror feature.
local FALLBACK_PLAYLIST={
 {title="Tabola Bale - Kienzy x Ajun Perwira BKB EDIT",id="77926481439798",style="underground"},
 {title="SOLEDAD [ DESTRA PRAYOGO ]#BKB2K25",id="112400686884526",style="underground"},
 {title="SIAPKAH JATUH CINTA LAGI [ DESTRA PRAYOGO ]#BKB2K25",id="75709298846740",style="underground"},
 {title="MASIH DENGANMU [ DESTRA PRAYOGO ]#BKB2K25",id="140443777425109",style="underground"},
 {title="MACARENA 2026 - ZHAK (BKB EDIT)",id="135670059308492",style="underground"},
 {title="JAUH KO PERGI BKB - NATALINO DE [ ND MIX ]",id="114038149273002",style="underground"},
 {title="JANGAN TUNGGU LAMA LAMA BKB VOL 5 ( SAHRUL AGAM )",id="99406970263948",style="underground"},
 {title="I NEED A DOCTOR 2025 - VAY BREAKS #BKB STYLE",id="129689050998627",style="underground"},
 {title="I KNOW YOU WANT ME - KIN BKB EDIT",id="117479133947987",style="underground"},
 {title="EMANG DASAR -IVNSYH-",id="125107386771710",style="underground"},
 {title="EM - KUNTUL PANJANG - [ GERALD ATIMANG BOOTLEG ] 2026",id="95368919127704",style="underground"},
 {title="BANG BANG BANG - KIN EDIT",id="123499438012066",style="underground"},
 {title="ANIMA BINTANG [ DESTRA PRAYOGO ]#BKB2K25",id="140442667497371",style="underground"},
 {title="ANAK SINGKONG [ DESTRA PRAYOGO ]#BKB2K25",id="90986894139778",style="underground"},
 {title="Adry WG - GAK ENGGA DULU (BKB)#LocalPACK2026",id="130909529715712",style="underground"},
 {title="666 L3 - TONY RAY PUT YOUR HAND'S UP BKB REVOLUTIONS",id="116771187608517",style="underground"},
 {title="17.Mugwanti (Mahesa & hmp BKB Edit)",id="113698017406179",style="underground"},
 {title="06. ARIA PIL KB (EANN BKB EDIT)",id="109573287368195",style="underground"},
 {title="11A - 130 - RUN AWAY - Unknown Artist",id="99998363156285",style="underground"},
 {title="TOR MONITOR KETUA - QMUNK AMSTRONG#BKB PRIVAT",id="105712830643792",style="underground"},
 {title="SIK ASIK - Mail Alektra (BKB EDIT) - MAIL ALEKTRA",id="81832495836167",style="underground"},
 {title="SEDIA AKU SEBELUM HUJAN -QMUNK AMSTRONG #BKB",id="117476404561871",style="underground"},
 {title="POK ANI ANI - DJ VINNIE PARGOY, BILLIE KOPLO",id="139454814636865",style="underground"},
 {title="PICA PICA 2 - ARIEF RASIT (BKB EDIT)",id="94631926635772",style="underground"},
 {title="pararam-bkb-ipan-agstyan",id="99942691456392",style="underground"},
 {title="Om Abidin - Ani Ani ( Club Mix )",id="103410156771684",style="underground"},
 {title="Ni De Wan Shui Qian Shan - Aldy alvaro, DJ U",id="106769175117849",style="underground"},
 {title="Ni De Da An - Aldy alvaro, Putra Crazy BKB e",id="90741742310621",style="underground"},
 {title="NGAPAIN REPOT (RAYEN BKB EDIT)",id="117103573334654",style="underground"},
 {title="NGAPAIN REPOT (DEKA EDIT)",id="105840679569825",style="underground"},
 {title="Ngapain Repot ( Aldy Alvaro BKB edit )",id="106277277729828",style="underground"},
 {title="MORENA BKB (HARLY EDIT)",id="97696234195316",style="underground"},
 {title="MATTA BAND - KETAHUAN BKB (VIP LORDBOY EDIT)-1",id="106194805739169",style="underground"},
}

local function cleanText(value,maxLen,fallback)
 local s=tostring(value or fallback or "")
 s=s:gsub("[%c]"," "):gsub("%s+"," ")
 if #s>maxLen then s=s:sub(1,maxLen) end
 return s
end
local function validAssetId(value)
 local s=tostring(value or "")
 return s:match("^%d+$")~=nil and #s>=5 and #s<=20
end
local function validTrackId(value)
 local s=tostring(value or "")
 return #s>=1 and #s<=80 and s:match("^[%w%-%._:]+$")~=nil
end

local catalogStore=DataStoreService:GetDataStore(STORE_NAME)
local mirror={active=false,revision=0,tracks={}}

local function sanitizeStored(raw)
 local out={active=false,revision=0,tracks={}}
 if type(raw)~="table" then return out end
 out.active=raw.active==true
 out.revision=math.max(0,tonumber(raw.revision) or 0)
 if type(raw.tracks)~="table" then return out end
 for _,t in ipairs(raw.tracks) do
  if type(t)=="table" and validTrackId(t.trackId) and validAssetId(t.id or t.assetId) then
   table.insert(out.tracks,{
    trackId=tostring(t.trackId),title=cleanText(t.title,160,"Imported Track"),artist=cleanText(t.artist,100,"Unknown Artist"),
    id=tostring(t.id or t.assetId),style="underground",order=math.max(1,math.floor(tonumber(t.order) or 1)),
    enabled=t.enabled~=false,rev=math.max(0,tonumber(t.rev) or 0),
   })
  end
 end
 return out
end

local okLoad,stored=pcall(function()return catalogStore:GetAsync(STORE_KEY)end)
if okLoad then mirror=sanitizeStored(stored) else warn("[BBYA/UndergroundMirror] DataStore load failed: "..tostring(stored)) end

local function mirrorPlaylist()
 if not mirror.active then return nil end
 local out={}
 for _,t in ipairs(mirror.tracks) do
  if t.enabled~=false and validAssetId(t.id) then
   table.insert(out,{trackId=t.trackId,title=t.title,artist=t.artist,id=t.id,style="underground",order=t.order})
  end
 end
 table.sort(out,function(a,b)if a.order==b.order then return a.trackId<b.trackId end return a.order<b.order end)
 return out
end

local PLAYLIST=mirrorPlaylist() or FALLBACK_PLAYLIST
local catalogSource=mirror.active and "APK_MIRROR" or "FALLBACK_OWNER_LIBRARY"

local folder=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
folder.Name="BBYAClubRemotes";folder.Parent=ReplicatedStorage
local stateRemote=folder:FindFirstChild("State") or Instance.new("RemoteEvent")
stateRemote.Name="State";stateRemote.Parent=folder
local basementMusic=folder:FindFirstChild("BasementMusic") or Instance.new("BindableEvent")
basementMusic.Name="BasementMusic";basementMusic.Parent=folder

for _,name in ipairs({"BBYABasementDeckA","BBYABasementDeckB"}) do
 local old=SoundService:FindFirstChild(name);if old then old:Destroy() end
end
local oldGroup=SoundService:FindFirstChild("BBYABasementMaster");if oldGroup then oldGroup:Destroy() end
local group=Instance.new("SoundGroup")
group.Name="BBYABasementMaster";group.Volume=1;group.Parent=SoundService
group:SetAttribute("BBYAAudioMode","UNDERGROUND_APK_MIRROR_DUAL_DECK_V3")
group:SetAttribute("Venue","BASEMENT")
group:SetAttribute("GenrePolicy","UNDERGROUND_OWNER_LIBRARY")
group:SetAttribute("MixSeconds",MIX_SECONDS)
group:SetAttribute("QueuePolicy","FIFO_REQUEST_TO_STANDBY")
group:SetAttribute("MirrorTopic",SYNC_TOPIC)
group:SetAttribute("CatalogSource",catalogSource)
group:SetAttribute("CatalogRevision",mirror.revision)
group:SetAttribute("PlaylistCount",#PLAYLIST)
local eq=Instance.new("EqualizerSoundEffect");eq.Name="BasementEQ";eq.LowGain=2.35;eq.MidGain=-.75;eq.HighGain=-1.1;eq.Parent=group
local comp=Instance.new("CompressorSoundEffect");comp.Name="BasementCompressor";comp.Threshold=-11;comp.Ratio=2.5;comp.Attack=.05;comp.Release=.24;comp.GainMakeup=.7;comp.Parent=group
local room=Instance.new("ReverbSoundEffect");room.Name="BasementRoom";room.DecayTime=1.15;room.Density=.86;room.Diffusion=.9;room.DryLevel=-1;room.WetLevel=-11;room.Parent=group

local function makeDeck(name)
 local s=Instance.new("Sound");s.Name=name;s.Volume=0;s.Looped=false;s.SoundGroup=group;s.Parent=SoundService
 s:SetAttribute("DeckRole","STANDBY");s:SetAttribute("PreparedIndex",0);s:SetAttribute("PreparedReady",false)
 return s
end
local deckA=makeDeck("BBYABasementDeckA")
local deckB=makeDeck("BBYABasementDeckB")
local activeDeck,standbyDeck=deckA,deckB
activeDeck:SetAttribute("DeckRole","LIVE")

local seed=os.time()+971
for i=1,#game.JobId do seed=(seed*31+string.byte(game.JobId,i))%2147483646 end
local rng=Random.new(math.max(1,seed))
local current=0
local shuffleBag={}
local requestQueue={}
local requestCooldown={}
local badTracks={}
local transitioning=false
local paused=false
local standbyIndex=nil
local standbyLoadToken=0

local function isBasement(player)
 local ch=player and player.Character
 local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 return hrp and hrp.Position.Y<-4.5 or false
end
local function isAdmin(player)
 if not player then return false end
 if player:GetAttribute("BBYAAdmin")==true then return true end
 return game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId
end
local function forBasementPlayers(fn)for _,p in ipairs(Players:GetPlayers()) do if isBasement(p) then fn(p) end end end
local function toastBasement(msg)forBasementPlayers(function(p)stateRemote:FireClient(p,"toast",msg)end)end
local function validTrack(i)local t=PLAYLIST[i];return t and validAssetId(t.id) and not badTracks[i] end
local function soundIdFor(i)return validTrack(i) and ("rbxassetid://"..tostring(PLAYLIST[i].id)) or nil end
local function deckName(deck)return deck==deckA and "A" or "B" end

local function stateData()
 local t=PLAYLIST[current]
 return {
  index=current,title=t and t.title or "",artist=t and t.artist or "",style=t and t.style or "underground",
  playing=activeDeck.IsPlaying and not paused,queue=#requestQueue,audioMode="UNDERGROUND_APK_MIRROR_AUTOMIX",
  venue="BASEMENT",genre="UNDERGROUND",library=#PLAYLIST,liveDeck=deckName(activeDeck),standbyDeck=deckName(standbyDeck),
  standbyIndex=standbyIndex or 0,standbyTitle=(standbyIndex and PLAYLIST[standbyIndex] and PLAYLIST[standbyIndex].title) or "",
  mixSeconds=MIX_SECONDS,catalogSource=catalogSource,catalogRevision=mirror.revision,
 }
end
local function fireState(target)
 if target then stateRemote:FireClient(target,"music",stateData());return end
 forBasementPlayers(function(p)stateRemote:FireClient(p,"music",stateData())end)
end

local function quarantine(i,reason)
 if not i or badTracks[i] then return end
 badTracks[i]=reason or true;shuffleBag={}
 warn(string.format("[BBYA/Underground] quarantined %d %s (%s)",i,PLAYLIST[i] and PLAYLIST[i].title or "?",tostring(reason)))
 group:SetAttribute("LastBadTrack",i);group:SetAttribute("LastBadReason",tostring(reason))
end
local function rebuildShuffleBag()
 shuffleBag={}
 for i=1,#PLAYLIST do if validTrack(i) and i~=current then table.insert(shuffleBag,i) end end
 if #shuffleBag==0 and validTrack(current) then table.insert(shuffleBag,current) end
 for i=#shuffleBag,2,-1 do local j=rng:NextInteger(1,i);shuffleBag[i],shuffleBag[j]=shuffleBag[j],shuffleBag[i] end
end
local function nextRandom()
 if #shuffleBag==0 then rebuildShuffleBag() end
 while #shuffleBag>0 do local i=table.remove(shuffleBag);if validTrack(i) then return i end end
 return nil
end
local function nextDesired()
 while #requestQueue>0 do
  local req=requestQueue[1]
  if validTrack(req.index) then return req.index,true end
  table.remove(requestQueue,1)
 end
 return nextRandom(),false
end
local function waitLoaded(sound,timeout)
 local deadline=os.clock()+(timeout or LOAD_TIMEOUT)
 while os.clock()<deadline do if sound.IsLoaded and (sound.TimeLength or 0)>1 then return true end;task.wait(.12) end
 return sound.IsLoaded and (sound.TimeLength or 0)>1
end
local function loadDeck(deck,i)
 if not validTrack(i) then return false end
 deck:Stop();deck.Volume=0;deck.TimePosition=0;deck.SoundId=soundIdFor(i)
 local ok=pcall(function()ContentProvider:PreloadAsync({deck})end)
 return ok and waitLoaded(deck,LOAD_TIMEOUT)
end
local function prepareStandby(i)
 if not validTrack(i) or transitioning then return false end
 if standbyIndex==i and standbyDeck:GetAttribute("PreparedReady")==true then return true end
 standbyLoadToken+=1;local token=standbyLoadToken
 standbyIndex=i;standbyDeck:SetAttribute("PreparedReady",false);standbyDeck:SetAttribute("PreparedIndex",i);standbyDeck:SetAttribute("DeckRole","STANDBY")
 task.spawn(function()
  local ready=loadDeck(standbyDeck,i)
  if token~=standbyLoadToken or standbyIndex~=i then return end
  if ready then standbyDeck:SetAttribute("PreparedReady",true) else quarantine(i,"preload_failed");standbyIndex=nil end
  fireState()
 end)
 return true
end
local function ensureStandby()
 if transitioning or #PLAYLIST==0 then return end
 local i=nextDesired();if i then prepareStandby(i) end
end

local function startIndex(i)
 if not validTrack(i) then return false end
 transitioning=false;paused=false;standbyLoadToken+=1
 activeDeck:Stop();standbyDeck:Stop();standbyDeck.Volume=0
 if not loadDeck(activeDeck,i) then quarantine(i,"load_failed");return false end
 current=i;activeDeck.Volume=1;activeDeck:SetAttribute("DeckRole","LIVE");activeDeck:SetAttribute("PreparedIndex",i);activeDeck:SetAttribute("PreparedReady",true)
 activeDeck:Play();task.wait(.22)
 if not activeDeck.IsPlaying then quarantine(i,"play_failed");return false end
 standbyIndex=nil;shuffleBag={};fireState();ensureStandby();return true
end

local function transition(forceImmediate)
 if transitioning or paused or #PLAYLIST==0 then return false end
 if not standbyIndex or standbyDeck:GetAttribute("PreparedReady")~=true then
  local i,fromRequest=nextDesired();if not i then return false end
  if fromRequest then table.remove(requestQueue,1) end
  if not loadDeck(standbyDeck,i) then quarantine(i,"standby_load_failed");standbyIndex=nil;return false end
  standbyIndex=i;standbyDeck:SetAttribute("PreparedReady",true)
 else
  if #requestQueue>0 and requestQueue[1].index==standbyIndex then table.remove(requestQueue,1) end
 end
 local nextIndex=standbyIndex;if not validTrack(nextIndex) then standbyIndex=nil;return false end
 transitioning=true
 local oldDeck,newDeck=activeDeck,standbyDeck
 newDeck.TimePosition=0;newDeck.Volume=forceImmediate and 1 or 0;newDeck:SetAttribute("DeckRole","MIXING_IN");oldDeck:SetAttribute("DeckRole","MIXING_OUT")
 newDeck:Play();task.wait(.20)
 if not newDeck.IsPlaying then quarantine(nextIndex,"incoming_stalled");newDeck:Stop();newDeck.Volume=0;oldDeck.Volume=1;transitioning=false;standbyIndex=nil;return false end
 current=nextIndex;fireState()
 if forceImmediate then oldDeck:Stop();oldDeck.Volume=0 else
  local ti=TweenInfo.new(MIX_SECONDS,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
  local down=TweenService:Create(oldDeck,ti,{Volume=0});local up=TweenService:Create(newDeck,ti,{Volume=1})
  down:Play();up:Play();up.Completed:Wait();oldDeck:Stop();oldDeck.Volume=0
 end
 activeDeck,standbyDeck=newDeck,oldDeck
 activeDeck:SetAttribute("DeckRole","LIVE");standbyDeck:SetAttribute("DeckRole","STANDBY");standbyDeck:SetAttribute("PreparedReady",false);standbyDeck:SetAttribute("PreparedIndex",0);standbyDeck.SoundId=""
 standbyIndex=nil;shuffleBag={};transitioning=false;fireState();ensureStandby();return true
end

local function stopAll()
 paused=false;transitioning=false;standbyLoadToken+=1;standbyIndex=nil
 deckA:Stop();deckB:Stop();deckA.Volume=0;deckB.Volume=0;current=0;fireState()
end

local function applyRuntimeCatalog(reason)
 local dynamic=mirrorPlaylist()
 if mirror.active then PLAYLIST=dynamic or {};catalogSource="APK_MIRROR" else PLAYLIST=FALLBACK_PLAYLIST;catalogSource="FALLBACK_OWNER_LIBRARY" end
 badTracks={};shuffleBag={};requestQueue={};standbyIndex=nil;standbyLoadToken+=1
 group:SetAttribute("CatalogSource",catalogSource);group:SetAttribute("CatalogRevision",mirror.revision);group:SetAttribute("PlaylistCount",#PLAYLIST);group:SetAttribute("LastCatalogApplyReason",reason)
 if #PLAYLIST==0 then stopAll();return end
 task.spawn(function()
  task.wait(.05)
  if not startIndex(1) then
   for i=2,#PLAYLIST do if startIndex(i) then break end end
  end
 end)
end

local function saveMirrorAsync()
 local snapshot={active=mirror.active,revision=mirror.revision,tracks=mirror.tracks}
 task.spawn(function()
  local ok,err=pcall(function()catalogStore:SetAsync(STORE_KEY,snapshot)end)
  if not ok then warn("[BBYA/UndergroundMirror] DataStore save failed: "..tostring(err)) end
 end)
end

local function handleDelta(raw)
 if type(raw)~="string" or #raw<2 or #raw>1024 then return end
 local ok,data=pcall(function()return HttpService:JSONDecode(raw)end)
 if not ok or type(data)~="table" or tonumber(data.v)~=1 or data.z~="underground" then return end
 local op=tostring(data.op or "")
 local rev=math.max(0,math.floor(tonumber(data.rev) or 0))
 if op=="upsert" then
  if not validTrackId(data.trackId) or not validAssetId(data.assetId) then return end
  local trackId=tostring(data.trackId);local existingIndex=nil;local oldRev=-1
  for i,t in ipairs(mirror.tracks) do if t.trackId==trackId then existingIndex=i;oldRev=tonumber(t.rev) or 0;break end end
  if rev<oldRev then return end
  local item={trackId=trackId,title=cleanText(data.title,160,"Imported Track"),artist=cleanText(data.artist,100,"Unknown Artist"),id=tostring(data.assetId),style="underground",order=math.max(1,math.floor(tonumber(data.order) or 1)),enabled=data.enabled~=false,rev=rev}
  if existingIndex then mirror.tracks[existingIndex]=item else table.insert(mirror.tracks,item) end
  mirror.active=true;mirror.revision=math.max(mirror.revision,rev);saveMirrorAsync();applyRuntimeCatalog("MESSAGE_UPSERT")
 elseif op=="delete" then
  if not validTrackId(data.trackId) then return end
  local nextTracks={};local changed=false
  for _,t in ipairs(mirror.tracks) do
   if t.trackId==tostring(data.trackId) and rev>=(tonumber(t.rev) or 0) then changed=true else table.insert(nextTracks,t) end
  end
  if changed then mirror.tracks=nextTracks;mirror.active=true;mirror.revision=math.max(mirror.revision,rev);saveMirrorAsync();applyRuntimeCatalog("MESSAGE_DELETE") end
 elseif op=="clear" then
  if rev>=mirror.revision then mirror.active=true;mirror.revision=rev;mirror.tracks={};saveMirrorAsync();applyRuntimeCatalog("MESSAGE_CLEAR") end
 elseif op=="fallback" then
  if rev>=mirror.revision then mirror.active=false;mirror.revision=rev;saveMirrorAsync();applyRuntimeCatalog("MESSAGE_FALLBACK") end
 end
end

local function queueRequest(player,index)
 index=tonumber(index)
 if not player or not validTrack(index) then if player then stateRemote:FireClient(player,"toast","Track Underground itu tidak tersedia.") end;return end
 local now=os.clock();local last=requestCooldown[player.UserId] or 0
 if now-last<REQUEST_COOLDOWN then stateRemote:FireClient(player,"toast","Tunggu sebentar sebelum request lagi.");return end
 if #requestQueue>=MAX_QUEUE then stateRemote:FireClient(player,"toast","Underground DJ queue sedang penuh.");return end
 requestCooldown[player.UserId]=now;table.insert(requestQueue,{playerId=player.UserId,index=index})
 stateRemote:FireClient(player,"toast",string.format("Underground queue #%d: %s",#requestQueue,PLAYLIST[index].title));fireState();ensureStandby()
end

basementMusic.Event:Connect(function(action,player,arg)
 if action=="list" and player then stateRemote:FireClient(player,"playlist",PLAYLIST);fireState(player)
 elseif action=="request" then queueRequest(player,arg)
 elseif action=="queue" and player then stateRemote:FireClient(player,"djQueue",{position=0,count=#requestQueue,now=PLAYLIST[current] and PLAYLIST[current].title or "",venue="BASEMENT"})
 elseif action=="play" and player then if isAdmin(player) then startIndex(tonumber(arg) or current) else stateRemote:FireClient(player,"toast","DJ transport Underground khusus admin.") end
 elseif action=="pause" and player then if isAdmin(player) then paused=true;activeDeck:Pause();fireState() end
 elseif action=="resume" and player then if isAdmin(player) then paused=false;activeDeck:Resume();fireState() end
 elseif action=="next" and player then if isAdmin(player) then transition(false) end end
end)

for _,deck in ipairs({deckA,deckB}) do
 deck.Ended:Connect(function()
  if not transitioning and not paused then task.defer(function()if not transition(true) and #PLAYLIST>0 then startIndex(1) end end) end
 end)
end
Players.PlayerRemoving:Connect(function(player)requestCooldown[player.UserId]=nil end)

task.spawn(function()
 while task.wait(.20) do
  if not transitioning and not paused and activeDeck.IsPlaying then
   local len,pos=activeDeck.TimeLength,activeDeck.TimePosition
   if len and len>5 then local remain=len-pos;if remain<=PRELOAD_WINDOW then ensureStandby() end;if remain<=MIX_SECONDS+.35 then task.spawn(function()transition(false)end) end end
  end
 end
end)

task.spawn(function()
 local ok,err=pcall(function()
  MessagingService:SubscribeAsync(SYNC_TOPIC,function(message)handleDelta(message.Data)end)
 end)
 if ok then group:SetAttribute("MirrorSubscriber","CONNECTED") else group:SetAttribute("MirrorSubscriber","ERROR");warn("[BBYA/UndergroundMirror] Subscribe failed: "..tostring(err)) end
end)

task.spawn(function()
 task.wait(1.4)
 if #PLAYLIST>0 and not startIndex(rng:NextInteger(1,#PLAYLIST)) then
  for i=1,#PLAYLIST do if startIndex(i) then break end end
 end
 local deadFor=0
 while task.wait(2.5) do
  if #PLAYLIST==0 or paused or activeDeck.IsPlaying then deadFor=0 else deadFor+=2.5;if deadFor>=5 then for i=1,#PLAYLIST do if startIndex(i) then break end end;deadFor=0 end end
 end
end)

print(string.format("[BBYA] Underground AutoDJ v3 online: %d tracks / source=%s / mirror rev=%d",#PLAYLIST,catalogSource,mirror.revision))
