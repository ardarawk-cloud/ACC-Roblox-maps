-- BBYA SOCIAL HUB — MAIN CLUB AUTODJ v7
-- Main/VIP/Rooftop = western/international channel.
-- Basement requests are routed to the independent BasementMusic engine.
-- Dual-deck queued AutoMix: LIVE deck + silent STANDBY preload + 4s crossfade.

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
local basementMusic=folder:FindFirstChild("BasementMusic") or Instance.new("BindableEvent");basementMusic.Name="BasementMusic";basementMusic.Parent=folder

local PLAYLIST={
-- MAIN_PROGRESSIVE_UPLOAD_BEGIN
 {title="1.Walking On Air",id="96983528563473",style="progressive"},
 {title="10. CHRISYE - PERGILAH KASIH",id="105877233550276",style="progressive"},
 {title="10A - 130 - 10A - 130 - Always Loving You",id="94337788677482",style="progressive"},
 {title="11A - 130 - 01.runaway (mumu remix)",id="112322493409786",style="progressive"},
 {title="11A - 130 - 11A - 130 - 11A - 130 - Run_away_remix",id="89165355590583",style="progressive"},
 {title="11A - 130 - RUN AWAY - Unknown Artist",id="99998363156285",style="progressive"},
 {title="11B - 126 - People (Eelke Kleijn People of the Sun Extended Mix)",id="134057367195123",style="progressive"},
 {title="11B - 128 - Nadia_Ali_-_People_(Eelke_Kleijn_People_of_the_Sun_Extended_Mix)",id="91900235935901",style="progressive"},
 {title="1A - 128 - Dreaming (Original Mix)",id="115774171488936",style="progressive"},
 {title="2A - 130 - 2A - 130 -tru love  - Viemix Remix",id="100162128635185",style="progressive"},
 {title="2A - 132 - Stadium - The Time",id="82993942539950",style="progressive"},
 {title="3A - 128 - 3A - 128 - M O M M E N T m.o.m.e.n.t_44100",id="109286172792690",style="progressive"},
 {title="3A - 128 - Desert Rose - Stadium Mix 2011",id="94547306143480",style="progressive"},
 {title="3A - 130 - DESTINATION CALABRIA ORI - Unknown Artist",id="109116552044147",style="progressive"},
-- MAIN_PROGRESSIVE_UPLOAD_END
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
local function forMainPlayers(fn)
 for _,p in ipairs(Players:GetPlayers()) do if not isBasement(p) then fn(p) end end
end
local function toastMain(msg)
 forMainPlayers(function(p)stateRemote:FireClient(p,"toast",msg)end)
end
local function denyTransport(player)
 stateRemote:FireClient(player,"toast","DJ transport controls khusus admin. Gunakan Request untuk antrean lagu.")
end

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
group:SetAttribute("BBYAAudioMode","MAIN_PROGRESSIVE_DUAL_DECK_V8")
group:SetAttribute("Venue","MAIN")
group:SetAttribute("GenrePolicy","PROGRESSIVE_ONLY")
group:SetAttribute("PlaylistCount",#PLAYLIST)
group:SetAttribute("MixSeconds",MIX_SECONDS)
group:SetAttribute("QueuePolicy","FIFO_REQUEST_TO_STANDBY")
local eq=group:FindFirstChild("ClubEQ") or Instance.new("EqualizerSoundEffect");eq.Name="ClubEQ";eq.LowGain=1.15;eq.MidGain=-.15;eq.HighGain=.45;eq.Parent=group
local compressor=group:FindFirstChild("VenueCompressor") or Instance.new("CompressorSoundEffect");compressor.Name="VenueCompressor";compressor.Threshold=-10;compressor.Ratio=2.25;compressor.Attack=.06;compressor.Release=.28;compressor.GainMakeup=.5;compressor.Parent=group

local function makeDeck(name)
 local old=SoundService:FindFirstChild(name);if old then old:Destroy() end
 local s=Instance.new("Sound");s.Name=name;s.Volume=0;s.Looped=false;s.SoundGroup=group;s.Parent=SoundService
 s:SetAttribute("DeckRole","STANDBY");s:SetAttribute("PreparedIndex",0);s:SetAttribute("PreparedReady",false);return s
end
local deckA=makeDeck("BBYAClubDeckA")
local deckB=makeDeck("BBYAClubDeckB")
local activeDeck,standbyDeck=deckA,deckB;activeDeck:SetAttribute("DeckRole","LIVE")

local seed=os.time();for i=1,#game.JobId do seed=(seed*33+string.byte(game.JobId,i))%2147483646 end
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
 return {index=current,title=t and t.title or "",style=t and t.style or "",playing=activeDeck.IsPlaying and not paused,queue=#requestQueue,audioMode="MAIN_PROGRESSIVE_AUTOMIX",venue="MAIN",genre="PROGRESSIVE",library=#PLAYLIST,liveDeck=deckName(activeDeck),standbyDeck=deckName(standbyDeck),standbyIndex=standbyIndex or 0,standbyTitle=(standbyIndex and PLAYLIST[standbyIndex] and PLAYLIST[standbyIndex].title) or "",nextRequest=qTop and qTop.index or 0,mixSeconds=MIX_SECONDS}
end
local function fireMusicState(target)
 if target then stateRemote:FireClient(target,"music",stateData());return end
 forMainPlayers(function(p)stateRemote:FireClient(p,"music",stateData())end)
end
local function quarantine(i,reason)
 if not i or badTracks[i] then return end
 badTracks[i]=reason or true;shuffleBag={};warn(string.format("[BBYA/Main] quarantined %d %s (%s)",i,PLAYLIST[i] and PLAYLIST[i].title or "?",tostring(reason)));group:SetAttribute("LastBadTrack",i);group:SetAttribute("LastBadReason",tostring(reason))
end
local function rebuildShuffleBag()
 shuffleBag={};for i=1,#PLAYLIST do if validTrack(i) and i~=current then table.insert(shuffleBag,i) end end
 for i=#shuffleBag,2,-1 do local j=rng:NextInteger(1,i);shuffleBag[i],shuffleBag[j]=shuffleBag[j],shuffleBag[i] end
end
local function peekRandom()
 if #shuffleBag==0 then rebuildShuffleBag() end
 while #shuffleBag>0 and (not validTrack(shuffleBag[#shuffleBag]) or shuffleBag[#shuffleBag]==current) do table.remove(shuffleBag) end
 return shuffleBag[#shuffleBag]
end
local function firstValidRequest()
 while #requestQueue>0 do local req=requestQueue[1];if validTrack(req.index) then return req end;table.remove(requestQueue,1) end
end
local function desiredStandby()local req=firstValidRequest();if req then return req.index,true end;return peekRandom(),false end
local function waitLoaded(sound,timeout)
 local deadline=os.clock()+(timeout or LOAD_TIMEOUT);while os.clock()<deadline do if sound.IsLoaded and (sound.TimeLength or 0)>1 then return true end;task.wait(.12) end;return sound.IsLoaded and (sound.TimeLength or 0)>1
end
local function prepareStandby(i,fromRequest)
 if not validTrack(i) or transitioning then return false end
 if standbyIndex==i and standbyDeck:GetAttribute("PreparedReady")==true then standbyFromRequest=fromRequest==true;return true end
 standbyLoadToken+=1;local token=standbyLoadToken;standbyIndex=i;standbyFromRequest=fromRequest==true
 standbyDeck:Stop();standbyDeck.Volume=0;standbyDeck.SoundId=soundIdFor(i);standbyDeck.TimePosition=0;standbyDeck:SetAttribute("PreparedIndex",i);standbyDeck:SetAttribute("PreparedReady",false);standbyDeck:SetAttribute("DeckRole","STANDBY");fireMusicState()
 task.spawn(function()
  local ok=pcall(function()ContentProvider:PreloadAsync({standbyDeck})end)
  if token~=standbyLoadToken or standbyIndex~=i then return end
  if ok and waitLoaded(standbyDeck,LOAD_TIMEOUT) then standbyDeck:SetAttribute("PreparedReady",true);group:SetAttribute("StandbyReadyIndex",i)
  else quarantine(i,"preload_failed");standbyDeck:SetAttribute("PreparedReady",false);standbyIndex=nil;standbyFromRequest=false;task.defer(function()local ni,nreq=desiredStandby();if ni then prepareStandby(ni,nreq) end end) end
  fireMusicState()
 end);return true
end
local function ensureDesiredStandby()
 if transitioning then return end
 local i,fromReq=desiredStandby();if i and (standbyIndex~=i or standbyFromRequest~=(fromReq==true)) then prepareStandby(i,fromReq) end
end
local function playOnDeckGuarded(deck,i,audible)
 if not validTrack(i) then return false end
 deck:Stop();deck.SoundId=soundIdFor(i);deck.TimePosition=0;deck.Volume=audible and 1 or 0
 local ok=pcall(function()ContentProvider:PreloadAsync({deck})end);if not ok then quarantine(i,"preload_error");return false end
 deck:Play();if not waitLoaded(deck,LOAD_TIMEOUT) then deck:Stop();quarantine(i,"load_timeout");return false end
 local p0=deck.TimePosition;task.wait(.28);if deck.TimePosition<=p0+.02 then deck:Stop();quarantine(i,"timeline_stalled");return false end;return true
end
local function chooseStartup()
 local tries={};for i=1,#PLAYLIST do table.insert(tries,i) end
 for i=#tries,2,-1 do local j=rng:NextInteger(1,i);tries[i],tries[j]=tries[j],tries[i] end
 for _,i in ipairs(tries) do if validTrack(i) then return i end end
end
local function startInitial()
 for _=1,#PLAYLIST+2 do local i=chooseStartup();if not i then break end;if playOnDeckGuarded(activeDeck,i,true) then current=i;activeDeck:SetAttribute("DeckRole","LIVE");activeDeck:SetAttribute("PreparedIndex",i);activeDeck:SetAttribute("PreparedReady",true);standbyDeck:SetAttribute("DeckRole","STANDBY");shuffleBag={};fireMusicState();ensureDesiredStandby();return true end end;return false
end
local function popRequestIfMatches(i)local req=requestQueue[1];if req and req.index==i then table.remove(requestQueue,1);return req end end
local function transitionPrepared(forceImmediate)
 if transitioning or paused then return false end
 ensureDesiredStandby();local nextIndex=standbyIndex;if not nextIndex or not validTrack(nextIndex) then return false end
 local ready=standbyDeck:GetAttribute("PreparedReady")==true
 if not ready then local deadline=os.clock()+LOAD_TIMEOUT;while os.clock()<deadline and standbyIndex==nextIndex do if standbyDeck:GetAttribute("PreparedReady")==true then ready=true;break end;task.wait(.1) end end
 if not ready or standbyIndex~=nextIndex then quarantine(nextIndex,"standby_not_ready");standbyIndex=nil;standbyFromRequest=false;ensureDesiredStandby();return false end
 transitioning=true;local oldDeck,newDeck=activeDeck,standbyDeck;local wasRequest=standbyFromRequest;local req=wasRequest and popRequestIfMatches(nextIndex) or nil;current=nextIndex
 newDeck.TimePosition=0;newDeck.Volume=forceImmediate and 1 or 0;newDeck:SetAttribute("DeckRole","MIXING_IN");oldDeck:SetAttribute("DeckRole","MIXING_OUT");newDeck:Play()
 local p0=newDeck.TimePosition;task.wait(.25)
 if not newDeck.IsPlaying or newDeck.TimePosition<=p0+.02 then newDeck:Stop();newDeck.Volume=0;oldDeck.Volume=1;oldDeck:SetAttribute("DeckRole","LIVE");quarantine(nextIndex,"incoming_stalled");transitioning=false;standbyIndex=nil;standbyFromRequest=false;if req then toastMain("Request dilewati: audio tidak dapat diputar.") end;ensureDesiredStandby();fireMusicState();return false end
 if req then toastMain("AutoMix request: "..PLAYLIST[nextIndex].title) end;fireMusicState()
 if forceImmediate then oldDeck:Stop();oldDeck.Volume=0 else local ti=TweenInfo.new(MIX_SECONDS,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut);local down=TweenService:Create(oldDeck,ti,{Volume=0});local up=TweenService:Create(newDeck,ti,{Volume=1});down:Play();up:Play();up.Completed:Wait();oldDeck:Stop();oldDeck.Volume=0 end
 activeDeck,standbyDeck=newDeck,oldDeck;activeDeck:SetAttribute("DeckRole","LIVE");activeDeck:SetAttribute("PreparedIndex",current);activeDeck:SetAttribute("PreparedReady",true);standbyDeck:SetAttribute("DeckRole","STANDBY");standbyDeck:SetAttribute("PreparedIndex",0);standbyDeck:SetAttribute("PreparedReady",false);standbyDeck.SoundId=""
 standbyIndex=nil;standbyFromRequest=false;shuffleBag={};transitioning=false;ensureDesiredStandby();fireMusicState();return true
end
local function forcePlay(i)
 if not validTrack(i) then return false end
 transitioning=false;paused=false;activeDeck:Stop();standbyDeck:Stop();standbyDeck.Volume=0
 if playOnDeckGuarded(activeDeck,i,true) then current=i;standbyIndex=nil;standbyFromRequest=false;shuffleBag={};activeDeck:SetAttribute("DeckRole","LIVE");standbyDeck:SetAttribute("DeckRole","STANDBY");fireMusicState();ensureDesiredStandby();return true end;return false
end
local function queueRequest(player,index)
 index=tonumber(index);if not player or not validTrack(index) then if player then stateRemote:FireClient(player,"toast","Track itu tidak tersedia.") end;return false end
 local now=os.clock();local last=requestCooldown[player.UserId] or 0;if now-last<REQUEST_COOLDOWN then stateRemote:FireClient(player,"toast","Tunggu sebentar sebelum request lagi.");return false end
 if #requestQueue>=MAX_QUEUE then stateRemote:FireClient(player,"toast","DJ request queue sedang penuh.");return false end
 for _,req in ipairs(requestQueue) do if req.playerId==player.UserId and req.index==index then stateRemote:FireClient(player,"toast","Request itu sudah ada di antrean.");return false end end
 requestCooldown[player.UserId]=now;table.insert(requestQueue,{playerId=player.UserId,index=index,requestedAt=os.time()});stateRemote:FireClient(player,"toast",string.format("Main Club queue #%d: %s • standby deck, tidak langsung nyala.",#requestQueue,PLAYLIST[index].title));stateRemote:FireClient(player,"djQueue",{position=#requestQueue,count=#requestQueue,title=PLAYLIST[index].title,now=PLAYLIST[current] and PLAYLIST[current].title or "",venue="MAIN"});ensureDesiredStandby();fireMusicState();return true
end

local function onDeckEnded(deck)if deck~=activeDeck or transitioning or paused then return end;task.defer(function()if not transitionPrepared(true) then ensureDesiredStandby();task.wait(.35);transitionPrepared(true) end end)end
deckA.Ended:Connect(function()onDeckEnded(deckA)end);deckB.Ended:Connect(function()onDeckEnded(deckB)end)

musicRemote.OnServerEvent:Connect(function(player,action,arg)
 if isBasement(player) then basementMusic:Fire(action,player,arg);return end
 if action=="list" then stateRemote:FireClient(player,"playlist",PLAYLIST);fireMusicState(player)
 elseif action=="request" then queueRequest(player,arg)
 elseif action=="queue" then stateRemote:FireClient(player,"djQueue",{position=0,count=#requestQueue,now=PLAYLIST[current] and PLAYLIST[current].title or "",venue="MAIN"})
 elseif action=="play" then if isAdmin(player) then forcePlay(tonumber(arg) or current) else denyTransport(player) end
 elseif action=="pause" then if isAdmin(player) then paused=true;activeDeck:Pause();fireMusicState() else denyTransport(player) end
 elseif action=="resume" then if isAdmin(player) then paused=false;activeDeck:Resume();fireMusicState() else denyTransport(player) end
 elseif action=="next" then if isAdmin(player) then transitionPrepared(false) else denyTransport(player) end end
end)
internalMusic.Event:Connect(function(action,player,arg)
 if action=="request" and player and isBasement(player) then basementMusic:Fire(action,player,arg);return end
 if action=="request" then queueRequest(player,arg)
 elseif action=="next" then transitionPrepared(false)
 elseif action=="random" then local i=chooseStartup();if i then forcePlay(i) end
 elseif action=="play" then forcePlay(tonumber(arg) or current)
 elseif action=="queue" and player then stateRemote:FireClient(player,"djQueue",{position=0,count=#requestQueue,now=PLAYLIST[current] and PLAYLIST[current].title or "",venue="MAIN"}) end
end)
supportRemote.OnServerEvent:Connect(function(player,action,arg)
 if action=="list" then stateRemote:FireClient(player,"supportProducts",SUPPORT_PRODUCTS);return end
 if action~="prompt" then return end
 local idx=tonumber(arg);local item=idx and SUPPORT_PRODUCTS[idx];if item then MarketplaceService:PromptProductPurchase(player,item.productId) end
end)
Players.PlayerAdded:Connect(function(player)task.delay(2,function()if player.Parent then stateRemote:FireClient(player,"supportProducts",SUPPORT_PRODUCTS);if not isBasement(player) then stateRemote:FireClient(player,"playlist",PLAYLIST);fireMusicState(player) end end end)end)
Players.PlayerRemoving:Connect(function(player)requestCooldown[player.UserId]=nil end)
task.spawn(function()while task.wait(.20) do if not transitioning and not paused and activeDeck.IsPlaying then local len,pos=activeDeck.TimeLength,activeDeck.TimePosition;if len and len>5 then local remain=len-pos;if remain<=PRELOAD_WINDOW then ensureDesiredStandby() end;if remain<=MIX_SECONDS+.35 then task.spawn(function()transitionPrepared(false)end) end end end end end)
task.spawn(function()task.wait(1);if not startInitial() then warn("[BBYA/Main] No playable western track at startup; watchdog will retry") end end)
print(string.format("[BBYA] Main AutoDJ v7 online: %d western tracks / Basement routed separately",#PLAYLIST))