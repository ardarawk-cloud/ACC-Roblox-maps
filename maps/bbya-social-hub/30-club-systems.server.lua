-- BBYA SOCIAL HUB — HYBRID AUTODJ v5
-- Random start + shuffled non-repeating rotation + request queue + expanded breakbeat/funkot/indo-bounce library.

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

-- Creator Store / existing BBYA library. Runtime watchdog recovers if Roblox later restricts an individual asset.
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

local CROSSFADE_SECONDS=1.2
local PRELOAD_WINDOW=6

local function isAdmin(player)
 if not player then return false end
 if player:GetAttribute("BBYAAdmin")==true then return true end
 return game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId
end
local function denyTransport(player)
 stateRemote:FireClient(player,"toast","DJ transport controls khusus admin. Gunakan Request untuk antrean lagu.")
end

-- Remove legacy zone feeds so this server owns a single canonical AutoDJ timeline.
local oldZones=Workspace:FindFirstChild("BBYAAudioZones");if oldZones then oldZones:Destroy() end
for _,obj in ipairs(Workspace:GetDescendants()) do
 if obj:IsA("Sound") and (obj.Name=="BBYAClubSound" or obj.Name:match("^BBYAClubSound_")) then obj:Destroy() end
end
for _,name in ipairs({"BBYAClubFeed","BBYAClubDeckA","BBYAClubDeckB"}) do
 local old=SoundService:FindFirstChild(name);if old then old:Destroy() end
end

local group=SoundService:FindFirstChild("BBYAClubMaster")
if not group then group=Instance.new("SoundGroup");group.Name="BBYAClubMaster";group.Parent=SoundService end
group.Volume=1;group:SetAttribute("BBYAAudioMode","HYBRID_AUTODJ_V5")
group:SetAttribute("PlaylistCount",#PLAYLIST)
local eq=group:FindFirstChild("ClubEQ")
if not eq then eq=Instance.new("EqualizerSoundEffect");eq.Name="ClubEQ";eq.Parent=group end
eq.LowGain=1.15;eq.MidGain=-.15;eq.HighGain=.45
local compressor=group:FindFirstChild("VenueCompressor")
if not compressor then compressor=Instance.new("CompressorSoundEffect");compressor.Name="VenueCompressor";compressor.Parent=group end
compressor.Threshold=-10;compressor.Ratio=2.25;compressor.Attack=.06;compressor.Release=.28;compressor.GainMakeup=.5

local function makeDeck(name)
 local s=Instance.new("Sound");s.Name=name;s.Volume=0;s.Looped=false;s.SoundGroup=group;s.Parent=SoundService;return s
end
local deckA=makeDeck("BBYAClubDeckA")
local deckB=makeDeck("BBYAClubDeckB")
local activeDeck,standbyDeck=deckA,deckB

-- Per-server RNG: different server/job starts at a different track and receives a different rotation.
local seed=os.time()
for i=1,#game.JobId do seed=(seed*33+string.byte(game.JobId,i))%2147483646 end
local rng=Random.new(math.max(1,seed))
local current=rng:NextInteger(1,#PLAYLIST)
local shuffleBag={}
local requestQueue={}
local requestCooldown={}
local transitioning=false
local paused=false
local preloadIndex=nil

local function validTrack(i)local t=PLAYLIST[i];return t and t.id and tostring(t.id)~="" end
local function soundIdFor(i)return validTrack(i) and ("rbxassetid://"..tostring(PLAYLIST[i].id)) or nil end
local function fireMusicState(playing)
 local t=PLAYLIST[current]
 stateRemote:FireAllClients("music",{index=current,title=t and t.title or "",style=t and t.style or "",playing=playing,queue=#requestQueue,audioMode="HYBRID_RANDOM",library=#PLAYLIST})
end

local function rebuildShuffleBag()
 shuffleBag={}
 for i=1,#PLAYLIST do if validTrack(i) and (i~=current or #PLAYLIST==1) then table.insert(shuffleBag,i) end end
 for i=#shuffleBag,2,-1 do local j=rng:NextInteger(1,i);shuffleBag[i],shuffleBag[j]=shuffleBag[j],shuffleBag[i] end
end
local function ensureShuffleBag()if #shuffleBag==0 then rebuildShuffleBag() end end
local function peekPlaylistIndex()ensureShuffleBag();return shuffleBag[#shuffleBag] or current end
local function consumePlaylistIndex()ensureShuffleBag();return table.remove(shuffleBag) or current end
local function peekNextIndex()
 for _,req in ipairs(requestQueue) do if validTrack(req.index) then return req.index,true end end
 return peekPlaylistIndex(),false
end
local function consumeNextIndex()
 while #requestQueue>0 do local req=table.remove(requestQueue,1);if validTrack(req.index) then return req.index,true end end
 return consumePlaylistIndex(),false
end

local function preloadStandby(i)
 if not validTrack(i) or transitioning then return end
 if preloadIndex==i and standbyDeck.SoundId==soundIdFor(i) then return end
 preloadIndex=i;standbyDeck:Stop();standbyDeck.Volume=0;standbyDeck.SoundId=soundIdFor(i);standbyDeck.TimePosition=0
 task.spawn(function()pcall(function()ContentProvider:PreloadAsync({standbyDeck})end)end)
end
local function startDeck(deck,i,volume)
 deck:Stop();deck.SoundId=soundIdFor(i);deck.TimePosition=0;deck.Volume=volume or 1;deck:Play()
end
local function playTrackImmediate(i)
 if not validTrack(i) then return false end
 transitioning=false;paused=false;current=i;preloadIndex=nil;shuffleBag={}
 standbyDeck:Stop();standbyDeck.Volume=0;startDeck(activeDeck,i,1);fireMusicState(true)
 local ni=peekNextIndex();if ni then preloadStandby(ni) end
 return true
end
local function transitionToNext(forceImmediate)
 if transitioning then return false end
 local nextIndex,wasRequest=consumeNextIndex();if not validTrack(nextIndex) then return false end
 transitioning=true;paused=false
 local oldDeck,newDeck=activeDeck,standbyDeck
 current=nextIndex;preloadIndex=nil
 if wasRequest then shuffleBag={} end
 if newDeck.SoundId~=soundIdFor(nextIndex) then newDeck:Stop();newDeck.SoundId=soundIdFor(nextIndex);newDeck.TimePosition=0 end
 newDeck.Volume=forceImmediate and 1 or 0;newDeck:Play();fireMusicState(true)
 if wasRequest then stateRemote:FireAllClients("toast",string.format("DJ request now playing: %s",PLAYLIST[nextIndex].title)) end
 if forceImmediate then oldDeck:Stop();oldDeck.Volume=0 else
  local ti=TweenInfo.new(CROSSFADE_SECONDS,Enum.EasingStyle.Linear)
  TweenService:Create(oldDeck,ti,{Volume=0}):Play();local up=TweenService:Create(newDeck,ti,{Volume=1});up:Play();up.Completed:Wait();oldDeck:Stop();oldDeck.Volume=0
 end
 activeDeck,standbyDeck=newDeck,oldDeck;transitioning=false
 local ni=peekNextIndex();if ni then preloadStandby(ni) end
 return true
end

local function queueRequest(player,index)
 index=tonumber(index);if not player or not validTrack(index) then return false end
 local now=os.clock();local last=requestCooldown[player.UserId] or 0
 if now-last<20 then stateRemote:FireClient(player,"toast","Tunggu sebentar sebelum request lagu lagi.");return false end
 if #requestQueue>=8 then stateRemote:FireClient(player,"toast","DJ request queue sedang penuh.");return false end
 for _,req in ipairs(requestQueue) do if req.playerId==player.UserId and req.index==index then stateRemote:FireClient(player,"toast","Request itu sudah ada di antrean.");return false end end
 requestCooldown[player.UserId]=now;table.insert(requestQueue,{playerId=player.UserId,index=index})
 local position=#requestQueue
 stateRemote:FireClient(player,"toast",string.format("Request masuk antrean #%d: %s • AutoMix setelah track saat ini.",position,PLAYLIST[index].title))
 stateRemote:FireClient(player,"djQueue",{position=position,count=#requestQueue,title=PLAYLIST[index].title,now=PLAYLIST[current] and PLAYLIST[current].title or ""})
 fireMusicState(activeDeck.IsPlaying and not paused);if #requestQueue==1 then preloadStandby(index) end;return true
end

local function onDeckEnded(deck)
 if deck~=activeDeck or transitioning or paused then return end
 task.defer(function()transitionToNext(true)end)
end
deckA.Ended:Connect(function()onDeckEnded(deckA)end);deckB.Ended:Connect(function()onDeckEnded(deckB)end)

musicRemote.OnServerEvent:Connect(function(player,action,arg)
 if action=="list" then stateRemote:FireClient(player,"playlist",PLAYLIST);fireMusicState(activeDeck.IsPlaying and not paused)
 elseif action=="request" then queueRequest(player,arg)
 elseif action=="queue" then stateRemote:FireClient(player,"djQueue",{position=0,count=#requestQueue,now=PLAYLIST[current] and PLAYLIST[current].title or ""})
 elseif action=="play" then if isAdmin(player) then playTrackImmediate(tonumber(arg) or current) else denyTransport(player) end
 elseif action=="pause" then if isAdmin(player) then paused=true;activeDeck:Pause();standbyDeck:Pause();fireMusicState(false) else denyTransport(player) end
 elseif action=="resume" then if isAdmin(player) then paused=false;activeDeck:Resume();if standbyDeck.TimePosition>0 and standbyDeck.Volume>0 then standbyDeck:Resume() end;fireMusicState(true) else denyTransport(player) end
 elseif action=="next" then if isAdmin(player) then transitionToNext(false) else denyTransport(player) end end
end)

internalMusic.Event:Connect(function(action,player,arg)
 if action=="request" then queueRequest(player,arg)
 elseif action=="next" then transitionToNext(false)
 elseif action=="random" then playTrackImmediate(consumePlaylistIndex())
 elseif action=="play" then playTrackImmediate(tonumber(arg) or current)
 elseif action=="queue" and player then stateRemote:FireClient(player,"djQueue",{position=0,count=#requestQueue,now=PLAYLIST[current] and PLAYLIST[current].title or ""}) end
end)

supportRemote.OnServerEvent:Connect(function(player,action,arg)
 if action=="list" then stateRemote:FireClient(player,"supportProducts",SUPPORT_PRODUCTS);return end
 if action~="prompt" then return end
 local idx=tonumber(arg);local item=idx and SUPPORT_PRODUCTS[idx];if item then MarketplaceService:PromptProductPurchase(player,item.productId) end
end)

Players.PlayerAdded:Connect(function(player)
 task.delay(2,function()
  if player.Parent then
   stateRemote:FireClient(player,"playlist",PLAYLIST);stateRemote:FireClient(player,"supportProducts",SUPPORT_PRODUCTS)
   local t=PLAYLIST[current];stateRemote:FireClient(player,"music",{index=current,title=t and t.title or "",style=t and t.style or "",playing=activeDeck.IsPlaying and not paused,queue=#requestQueue,audioMode="HYBRID_RANDOM",library=#PLAYLIST})
  end
 end)
end)
Players.PlayerRemoving:Connect(function(player)requestCooldown[player.UserId]=nil end)

task.spawn(function()
 while task.wait(.20) do
  if not transitioning and not paused and activeDeck.IsPlaying then
   local len,pos=activeDeck.TimeLength,activeDeck.TimePosition
   if len and len>5 then
    local remain=len-pos;local ni=peekNextIndex();if ni and remain<=PRELOAD_WINDOW then preloadStandby(ni) end
    if remain<=CROSSFADE_SECONDS+.15 then task.spawn(function()transitionToNext(false)end) end
   end
  end
 end
end)

task.delay(2,function()if not activeDeck.IsPlaying then playTrackImmediate(current) end end)
print(string.format("[BBYA] Hybrid AutoDJ v5 online: %d tracks / random server start / shuffled rotation",#PLAYLIST))
