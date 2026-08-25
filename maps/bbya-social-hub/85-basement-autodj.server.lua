-- BBYA SOCIAL HUB — BASEMENT INDO AUTODJ v1
-- Independent underground channel: Indo breakbeat / indo-bounce only.
-- Uses its own Deck A/B, FIFO request queue and 4-second AutoMix.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local TweenService=game:GetService("TweenService")
local ContentProvider=game:GetService("ContentProvider")

local folder=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
folder.Name="BBYAClubRemotes";folder.Parent=ReplicatedStorage
local stateRemote=folder:FindFirstChild("State") or Instance.new("RemoteEvent");stateRemote.Name="State";stateRemote.Parent=folder
local basementMusic=folder:FindFirstChild("BasementMusic") or Instance.new("BindableEvent");basementMusic.Name="BasementMusic";basementMusic.Parent=folder

local PLAYLIST={
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
 {title="666 L3 - TONY RAY PUT YOUR HAND'S UP BKB REVOLUTIONS",id="116771187608517",style="underground"},
 {title="17.Mugwanti (Mahesa & hmp BKB Edit)",id="113698017406179",style="underground"},
 {title="06. ARIA PIL KB (EANN BKB EDIT)",id="109573287368195",style="underground"}
}

local MIX_SECONDS=4.0
local PRELOAD_WINDOW=14.0
local LOAD_TIMEOUT=5.0
local REQUEST_COOLDOWN=20
local MAX_QUEUE=8

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

for _,name in ipairs({"BBYABasementDeckA","BBYABasementDeckB"}) do local old=SoundService:FindFirstChild(name);if old then old:Destroy() end end
local group=SoundService:FindFirstChild("BBYABasementMaster");if group then group:Destroy() end
group=Instance.new("SoundGroup");group.Name="BBYABasementMaster";group.Volume=1;group.Parent=SoundService
group:SetAttribute("BBYAAudioMode","UNDERGROUND_OWNER_DUAL_DECK_V2");group:SetAttribute("Venue","BASEMENT");group:SetAttribute("GenrePolicy","UNDERGROUND_OWNER_LIBRARY");group:SetAttribute("PlaylistCount",#PLAYLIST);group:SetAttribute("MixSeconds",MIX_SECONDS);group:SetAttribute("QueuePolicy","FIFO_REQUEST_TO_STANDBY")
local eq=Instance.new("EqualizerSoundEffect");eq.Name="BasementEQ";eq.LowGain=2.35;eq.MidGain=-.75;eq.HighGain=-1.1;eq.Parent=group
local comp=Instance.new("CompressorSoundEffect");comp.Name="BasementCompressor";comp.Threshold=-11;comp.Ratio=2.5;comp.Attack=.05;comp.Release=.24;comp.GainMakeup=.7;comp.Parent=group
local room=Instance.new("ReverbSoundEffect");room.Name="BasementRoom";room.DecayTime=1.15;room.Density=.86;room.Diffusion=.9;room.DryLevel=-1;room.WetLevel=-11;room.Parent=group

local function makeDeck(name)local s=Instance.new("Sound");s.Name=name;s.Volume=0;s.Looped=false;s.SoundGroup=group;s.Parent=SoundService;s:SetAttribute("DeckRole","STANDBY");s:SetAttribute("PreparedIndex",0);s:SetAttribute("PreparedReady",false);return s end
local deckA=makeDeck("BBYABasementDeckA")
local deckB=makeDeck("BBYABasementDeckB")
local activeDeck,standbyDeck=deckA,deckB;activeDeck:SetAttribute("DeckRole","LIVE")
local seed=os.time()+971;for i=1,#game.JobId do seed=(seed*31+string.byte(game.JobId,i))%2147483646 end
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

local function validTrack(i)local t=PLAYLIST[i];return t and t.id and tostring(t.id)~="" and not badTracks[i] end
local function soundIdFor(i)return validTrack(i) and ("rbxassetid://"..tostring(PLAYLIST[i].id)) or nil end
local function deckName(deck)return deck==deckA and "A" or "B" end
local function stateData()
 local t=PLAYLIST[current];local qTop=requestQueue[1]
 return {index=current,title=t and t.title or "",style=t and t.style or "",playing=activeDeck.IsPlaying and not paused,queue=#requestQueue,audioMode="BASEMENT_INDO_AUTOMIX",venue="BASEMENT",genre="INDO",library=#PLAYLIST,liveDeck=deckName(activeDeck),standbyDeck=deckName(standbyDeck),standbyIndex=standbyIndex or 0,standbyTitle=(standbyIndex and PLAYLIST[standbyIndex] and PLAYLIST[standbyIndex].title) or "",nextRequest=qTop and qTop.index or 0,mixSeconds=MIX_SECONDS}
end
local function fireState(target)if target then stateRemote:FireClient(target,"music",stateData());return end;forBasementPlayers(function(p)stateRemote:FireClient(p,"music",stateData())end)end
local function quarantine(i,reason)if not i or badTracks[i] then return end;badTracks[i]=reason or true;shuffleBag={};warn(string.format("[BBYA/Basement] quarantined %d %s (%s)",i,PLAYLIST[i] and PLAYLIST[i].title or "?",tostring(reason)));group:SetAttribute("LastBadTrack",i);group:SetAttribute("LastBadReason",tostring(reason))end
local function rebuildShuffleBag()shuffleBag={};for i=1,#PLAYLIST do if validTrack(i) and i~=current then table.insert(shuffleBag,i) end end;for i=#shuffleBag,2,-1 do local j=rng:NextInteger(1,i);shuffleBag[i],shuffleBag[j]=shuffleBag[j],shuffleBag[i] end end
local function peekRandom()if #shuffleBag==0 then rebuildShuffleBag() end;while #shuffleBag>0 and (not validTrack(shuffleBag[#shuffleBag]) or shuffleBag[#shuffleBag]==current) do table.remove(shuffleBag) end;return shuffleBag[#shuffleBag] end
local function firstValidRequest()while #requestQueue>0 do local req=requestQueue[1];if validTrack(req.index) then return req end;table.remove(requestQueue,1) end end
local function desiredStandby()local req=firstValidRequest();if req then return req.index,true end;return peekRandom(),false end
local function waitLoaded(sound,timeout)local deadline=os.clock()+(timeout or LOAD_TIMEOUT);while os.clock()<deadline do if sound.IsLoaded and (sound.TimeLength or 0)>1 then return true end;task.wait(.12) end;return sound.IsLoaded and (sound.TimeLength or 0)>1 end
local function prepareStandby(i,fromRequest)
 if not validTrack(i) or transitioning then return false end
 if standbyIndex==i and standbyDeck:GetAttribute("PreparedReady")==true then standbyFromRequest=fromRequest==true;return true end
 standbyLoadToken+=1;local token=standbyLoadToken;standbyIndex=i;standbyFromRequest=fromRequest==true;standbyDeck:Stop();standbyDeck.Volume=0;standbyDeck.SoundId=soundIdFor(i);standbyDeck.TimePosition=0;standbyDeck:SetAttribute("PreparedIndex",i);standbyDeck:SetAttribute("PreparedReady",false);standbyDeck:SetAttribute("DeckRole","STANDBY");fireState()
 task.spawn(function()
  local ok=pcall(function()ContentProvider:PreloadAsync({standbyDeck})end)
  if token~=standbyLoadToken or standbyIndex~=i then return end
  if ok and waitLoaded(standbyDeck,LOAD_TIMEOUT) then standbyDeck:SetAttribute("PreparedReady",true);group:SetAttribute("StandbyReadyIndex",i)
  else quarantine(i,"preload_failed");standbyDeck:SetAttribute("PreparedReady",false);standbyIndex=nil;standbyFromRequest=false;task.defer(function()local ni,nreq=desiredStandby();if ni then prepareStandby(ni,nreq) end end) end
  fireState()
 end);return true
end
local function ensureStandby()if transitioning then return end;local i,fromReq=desiredStandby();if i and (standbyIndex~=i or standbyFromRequest~=(fromReq==true)) then prepareStandby(i,fromReq) end end
local function playGuarded(deck,i,audible)
 if not validTrack(i) then return false end
 deck:Stop();deck.SoundId=soundIdFor(i);deck.TimePosition=0;deck.Volume=audible and 1 or 0;local ok=pcall(function()ContentProvider:PreloadAsync({deck})end);if not ok then quarantine(i,"preload_error");return false end;deck:Play();if not waitLoaded(deck,LOAD_TIMEOUT) then deck:Stop();quarantine(i,"load_timeout");return false end;local p0=deck.TimePosition;task.wait(.28);if deck.TimePosition<=p0+.02 then deck:Stop();quarantine(i,"timeline_stalled");return false end;return true
end
local function chooseStartup()local tries={};for i=1,#PLAYLIST do table.insert(tries,i) end;for i=#tries,2,-1 do local j=rng:NextInteger(1,i);tries[i],tries[j]=tries[j],tries[i] end;for _,i in ipairs(tries) do if validTrack(i) then return i end end end
local function startInitial()for _=1,#PLAYLIST+2 do local i=chooseStartup();if not i then break end;if playGuarded(activeDeck,i,true) then current=i;activeDeck:SetAttribute("DeckRole","LIVE");activeDeck:SetAttribute("PreparedIndex",i);activeDeck:SetAttribute("PreparedReady",true);standbyDeck:SetAttribute("DeckRole","STANDBY");shuffleBag={};fireState();ensureStandby();return true end end;return false end
local function popRequestIfMatches(i)local req=requestQueue[1];if req and req.index==i then table.remove(requestQueue,1);return req end end
local function transition(forceImmediate)
 if transitioning or paused then return false end
 ensureStandby();local nextIndex=standbyIndex;if not nextIndex or not validTrack(nextIndex) then return false end
 local ready=standbyDeck:GetAttribute("PreparedReady")==true;if not ready then local deadline=os.clock()+LOAD_TIMEOUT;while os.clock()<deadline and standbyIndex==nextIndex do if standbyDeck:GetAttribute("PreparedReady")==true then ready=true;break end;task.wait(.1) end end
 if not ready or standbyIndex~=nextIndex then quarantine(nextIndex,"standby_not_ready");standbyIndex=nil;standbyFromRequest=false;ensureStandby();return false end
 transitioning=true;local oldDeck,newDeck=activeDeck,standbyDeck;local req=standbyFromRequest and popRequestIfMatches(nextIndex) or nil;current=nextIndex;newDeck.TimePosition=0;newDeck.Volume=forceImmediate and 1 or 0;newDeck:SetAttribute("DeckRole","MIXING_IN");oldDeck:SetAttribute("DeckRole","MIXING_OUT");newDeck:Play()
 local p0=newDeck.TimePosition;task.wait(.25)
 if not newDeck.IsPlaying or newDeck.TimePosition<=p0+.02 then newDeck:Stop();newDeck.Volume=0;oldDeck.Volume=1;oldDeck:SetAttribute("DeckRole","LIVE");quarantine(nextIndex,"incoming_stalled");transitioning=false;standbyIndex=nil;standbyFromRequest=false;if req then toastBasement("Request Basement dilewati: audio tidak tersedia.") end;ensureStandby();fireState();return false end
 if req then toastBasement("Basement AutoMix request: "..PLAYLIST[nextIndex].title) end;fireState()
 if forceImmediate then oldDeck:Stop();oldDeck.Volume=0 else local ti=TweenInfo.new(MIX_SECONDS,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut);local down=TweenService:Create(oldDeck,ti,{Volume=0});local up=TweenService:Create(newDeck,ti,{Volume=1});down:Play();up:Play();up.Completed:Wait();oldDeck:Stop();oldDeck.Volume=0 end
 activeDeck,standbyDeck=newDeck,oldDeck;activeDeck:SetAttribute("DeckRole","LIVE");activeDeck:SetAttribute("PreparedIndex",current);activeDeck:SetAttribute("PreparedReady",true);standbyDeck:SetAttribute("DeckRole","STANDBY");standbyDeck:SetAttribute("PreparedIndex",0);standbyDeck:SetAttribute("PreparedReady",false);standbyDeck.SoundId="";standbyIndex=nil;standbyFromRequest=false;shuffleBag={};transitioning=false;ensureStandby();fireState();return true
end
local function forcePlay(i)if not validTrack(i) then return false end;transitioning=false;paused=false;activeDeck:Stop();standbyDeck:Stop();standbyDeck.Volume=0;if playGuarded(activeDeck,i,true) then current=i;standbyIndex=nil;standbyFromRequest=false;shuffleBag={};activeDeck:SetAttribute("DeckRole","LIVE");standbyDeck:SetAttribute("DeckRole","STANDBY");fireState();ensureStandby();return true end;return false end
local function queueRequest(player,index)
 index=tonumber(index);if not player or not validTrack(index) then if player then stateRemote:FireClient(player,"toast","Track Basement itu tidak tersedia.") end;return false end
 local now=os.clock();local last=requestCooldown[player.UserId] or 0;if now-last<REQUEST_COOLDOWN then stateRemote:FireClient(player,"toast","Tunggu sebentar sebelum request lagi.");return false end
 if #requestQueue>=MAX_QUEUE then stateRemote:FireClient(player,"toast","Basement DJ queue sedang penuh.");return false end
 for _,req in ipairs(requestQueue) do if req.playerId==player.UserId and req.index==index then stateRemote:FireClient(player,"toast","Request itu sudah ada di antrean Basement.");return false end end
 requestCooldown[player.UserId]=now;table.insert(requestQueue,{playerId=player.UserId,index=index,requestedAt=os.time()});stateRemote:FireClient(player,"toast",string.format("Basement queue #%d: %s • standby deck, tidak langsung nyala.",#requestQueue,PLAYLIST[index].title));stateRemote:FireClient(player,"djQueue",{position=#requestQueue,count=#requestQueue,title=PLAYLIST[index].title,now=PLAYLIST[current] and PLAYLIST[current].title or "",venue="BASEMENT"});ensureStandby();fireState();return true
end

local function deny(player)stateRemote:FireClient(player,"toast","DJ transport Basement khusus admin.")end
basementMusic.Event:Connect(function(action,player,arg)
 if action=="list" and player then stateRemote:FireClient(player,"playlist",PLAYLIST);fireState(player)
 elseif action=="request" then queueRequest(player,arg)
 elseif action=="queue" and player then stateRemote:FireClient(player,"djQueue",{position=0,count=#requestQueue,now=PLAYLIST[current] and PLAYLIST[current].title or "",venue="BASEMENT"})
 elseif action=="play" and player then if isAdmin(player) then forcePlay(tonumber(arg) or current) else deny(player) end
 elseif action=="pause" and player then if isAdmin(player) then paused=true;activeDeck:Pause();fireState() else deny(player) end
 elseif action=="resume" and player then if isAdmin(player) then paused=false;activeDeck:Resume();fireState() else deny(player) end
 elseif action=="next" and player then if isAdmin(player) then transition(false) else deny(player) end end
end)
deckA.Ended:Connect(function()if not transitioning and not paused then task.defer(function()if not transition(true) then ensureStandby();task.wait(.35);transition(true) end end)end end)
deckB.Ended:Connect(function()if not transitioning and not paused then task.defer(function()if not transition(true) then ensureStandby();task.wait(.35);transition(true) end end)end end)
Players.PlayerRemoving:Connect(function(player)requestCooldown[player.UserId]=nil end)
task.spawn(function()while task.wait(.20) do if not transitioning and not paused and activeDeck.IsPlaying then local len,pos=activeDeck.TimeLength,activeDeck.TimePosition;if len and len>5 then local remain=len-pos;if remain<=PRELOAD_WINDOW then ensureStandby() end;if remain<=MIX_SECONDS+.35 then task.spawn(function()transition(false)end) end end end end end)
task.spawn(function()task.wait(1.4);if not startInitial() then warn("[BBYA/Basement] No playable Indo track at startup") end;local deadFor=0;while task.wait(2.5) do if paused or activeDeck.IsPlaying then deadFor=0 else deadFor+=2.5;if deadFor>=5 then local i=chooseStartup();if i then forcePlay(i) end;deadFor=0 end end end end)
print(string.format("[BBYA] Basement Indo AutoDJ online: %d tracks / independent A-B queue",#PLAYLIST))