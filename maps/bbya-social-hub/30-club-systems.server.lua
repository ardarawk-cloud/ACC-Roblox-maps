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
 {title="Pumpin' And Bumpin' D",id="9040442826"},
 {title="DJ Party Time",id="90337553112855"},
 {title="Electronic Music",id="1846869595"},
 {title="Electronic Avenue",id="84504061779927"},
 {title="DJ",id="15878422179"},
 {title="Welcome",id="137350000972072"},
 {title="Store",id="1837393392"},
}
local SUPPORT_PRODUCTS={{label="10",productId=0},{label="25",productId=0},{label="50",productId=0},{label="100",productId=0},{label="250",productId=0}}

local CROSSFADE_SECONDS=1.2
local PRELOAD_WINDOW=6

local function isAdmin(player)
 if not player then return false end
 if player:GetAttribute("BBYAAdmin")==true then return true end
 if game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId then return true end
 return false
end
local function denyTransport(player)
 stateRemote:FireClient(player,"toast","DJ transport controls khusus admin. Gunakan Request untuk antrean lagu.")
end

-- AUDIO V4: one timeline, two non-spatial decks for preload + short AutoDJ crossfade.
local oldZones=Workspace:FindFirstChild("BBYAAudioZones")
if oldZones then oldZones:Destroy() end
for _,obj in ipairs(Workspace:GetDescendants()) do
 if obj:IsA("Sound") and (obj.Name=="BBYAClubSound" or obj.Name:match("^BBYAClubSound_")) then obj:Destroy() end
end
for _,name in ipairs({"BBYAClubFeed","BBYAClubDeckA","BBYAClubDeckB"}) do
 local old=SoundService:FindFirstChild(name)
 if old then old:Destroy() end
end

local group=SoundService:FindFirstChild("BBYAClubMaster")
if not group then group=Instance.new("SoundGroup");group.Name="BBYAClubMaster";group.Parent=SoundService end
group.Volume=1
group:SetAttribute("BBYAAudioMode","AUTODJ_V4")

local eq=group:FindFirstChild("ClubEQ")
if not eq then eq=Instance.new("EqualizerSoundEffect");eq.Name="ClubEQ";eq.Parent=group end
eq.LowGain=1.15;eq.MidGain=-.15;eq.HighGain=.45
local compressor=group:FindFirstChild("VenueCompressor")
if not compressor then compressor=Instance.new("CompressorSoundEffect");compressor.Name="VenueCompressor";compressor.Parent=group end
compressor.Threshold=-10;compressor.Ratio=2.25;compressor.Attack=.06;compressor.Release=.28;compressor.GainMakeup=.5

local function makeDeck(name)
 local s=Instance.new("Sound")
 s.Name=name;s.Volume=0;s.Looped=false;s.SoundGroup=group;s.Parent=SoundService
 return s
end
local deckA=makeDeck("BBYAClubDeckA")
local deckB=makeDeck("BBYAClubDeckB")
local activeDeck=deckA
local standbyDeck=deckB

local current=1
local requestQueue={}
local requestCooldown={}
local transitioning=false
local paused=false
local preloadIndex=nil

local function validTrack(i)local t=PLAYLIST[i];return t and t.id and tostring(t.id)~="" end
local function soundIdFor(i)return validTrack(i) and ("rbxassetid://"..tostring(PLAYLIST[i].id)) or nil end
local function fireMusicState(playing)
 stateRemote:FireAllClients("music",{index=current,title=PLAYLIST[current] and PLAYLIST[current].title or "",playing=playing,queue=#requestQueue,audioMode="AUTODJ"})
end
local function nextPlaylistIndex()
 for step=1,#PLAYLIST do
  local i=((current-1+step)%#PLAYLIST)+1
  if validTrack(i) then return i end
 end
 return current
end
local function peekNextIndex()
 for _,req in ipairs(requestQueue) do if validTrack(req.index) then return req.index,true end end
 return nextPlaylistIndex(),false
end
local function consumeNextIndex()
 while #requestQueue>0 do
  local req=table.remove(requestQueue,1)
  if validTrack(req.index) then return req.index,true end
 end
 return nextPlaylistIndex(),false
end
local function preloadStandby(i)
 if not validTrack(i) or transitioning then return end
 if preloadIndex==i and standbyDeck.SoundId==soundIdFor(i) then return end
 preloadIndex=i
 standbyDeck:Stop();standbyDeck.Volume=0;standbyDeck.SoundId=soundIdFor(i);standbyDeck.TimePosition=0
 task.spawn(function()pcall(function()ContentProvider:PreloadAsync({standbyDeck})end)end)
end
local function startDeck(deck,i,volume)
 deck:Stop();deck.SoundId=soundIdFor(i);deck.TimePosition=0;deck.Volume=volume or 1;deck:Play()
end
local function playTrackImmediate(i)
 if not validTrack(i) then return false end
 transitioning=false;paused=false;current=i;preloadIndex=nil
 standbyDeck:Stop();standbyDeck.Volume=0
 startDeck(activeDeck,i,1)
 fireMusicState(true)
 local ni=peekNextIndex();if ni then preloadStandby(ni) end
 return true
end
local function transitionToNext(forceImmediate)
 if transitioning then return false end
 local nextIndex,wasRequest=consumeNextIndex()
 if not validTrack(nextIndex) then return false end
 transitioning=true;paused=false
 local oldDeck=activeDeck
 local newDeck=standbyDeck
 current=nextIndex
 preloadIndex=nil
 if newDeck.SoundId~=soundIdFor(nextIndex) then
  newDeck:Stop();newDeck.SoundId=soundIdFor(nextIndex);newDeck.TimePosition=0
 end
 newDeck.Volume=forceImmediate and 1 or 0
 newDeck:Play()
 fireMusicState(true)
 if wasRequest then stateRemote:FireAllClients("toast",string.format("DJ request now playing: %s",PLAYLIST[nextIndex].title)) end
 if forceImmediate then
  oldDeck:Stop();oldDeck.Volume=0
 else
  local ti=TweenInfo.new(CROSSFADE_SECONDS,Enum.EasingStyle.Linear)
  TweenService:Create(oldDeck,ti,{Volume=0}):Play()
  local up=TweenService:Create(newDeck,ti,{Volume=1});up:Play();up.Completed:Wait()
  oldDeck:Stop();oldDeck.Volume=0
 end
 activeDeck=newDeck;standbyDeck=oldDeck;transitioning=false
 local ni=peekNextIndex();if ni then preloadStandby(ni) end
 return true
end

local function queueRequest(player,index)
 index=tonumber(index)
 if not player or not validTrack(index) then return false end
 local now=os.clock();local last=requestCooldown[player.UserId] or 0
 if now-last<20 then stateRemote:FireClient(player,"toast","Tunggu sebentar sebelum request lagu lagi.");return false end
 if #requestQueue>=8 then stateRemote:FireClient(player,"toast","DJ request queue sedang penuh.");return false end
 for _,req in ipairs(requestQueue) do
  if req.playerId==player.UserId and req.index==index then stateRemote:FireClient(player,"toast","Request itu sudah ada di antrean.");return false end
 end
 requestCooldown[player.UserId]=now
 table.insert(requestQueue,{playerId=player.UserId,index=index})
 local position=#requestQueue
 stateRemote:FireClient(player,"toast",string.format("Request masuk antrean #%d: %s • AutoMix setelah track saat ini.",position,PLAYLIST[index].title))
 stateRemote:FireClient(player,"djQueue",{position=position,count=#requestQueue,title=PLAYLIST[index].title,now=PLAYLIST[current] and PLAYLIST[current].title or ""})
 fireMusicState(activeDeck.IsPlaying and not paused)
 if #requestQueue==1 then preloadStandby(index) end
 return true
end

local function onDeckEnded(deck)
 if deck~=activeDeck or transitioning or paused then return end
 task.defer(function()transitionToNext(true) end)
end
deckA.Ended:Connect(function()onDeckEnded(deckA)end)
deckB.Ended:Connect(function()onDeckEnded(deckB)end)

musicRemote.OnServerEvent:Connect(function(player,action,arg)
 if action=="list" then
  stateRemote:FireClient(player,"playlist",PLAYLIST)
  stateRemote:FireClient(player,"music",{index=current,title=PLAYLIST[current] and PLAYLIST[current].title or "",playing=activeDeck.IsPlaying and not paused,queue=#requestQueue,audioMode="AUTODJ"})
 elseif action=="request" then queueRequest(player,arg)
 elseif action=="queue" then stateRemote:FireClient(player,"djQueue",{position=0,count=#requestQueue,now=PLAYLIST[current] and PLAYLIST[current].title or ""})
 elseif action=="play" then if isAdmin(player) then playTrackImmediate(tonumber(arg) or current) else denyTransport(player) end
 elseif action=="pause" then if isAdmin(player) then paused=true;activeDeck:Pause();standbyDeck:Pause();fireMusicState(false) else denyTransport(player) end
 elseif action=="resume" then if isAdmin(player) then paused=false;activeDeck:Resume();if standbyDeck.TimePosition>0 and standbyDeck.Volume>0 then standbyDeck:Resume() end;fireMusicState(true) else denyTransport(player) end
 elseif action=="next" then if isAdmin(player) then transitionToNext(false) else denyTransport(player) end
 end
end)

internalMusic.Event:Connect(function(action,player,arg)
 if action=="request" then queueRequest(player,arg)
 elseif action=="next" then transitionToNext(false)
 elseif action=="play" then playTrackImmediate(tonumber(arg) or current)
 elseif action=="queue" and player then stateRemote:FireClient(player,"djQueue",{position=0,count=#requestQueue,now=PLAYLIST[current] and PLAYLIST[current].title or ""}) end
end)

supportRemote.OnServerEvent:Connect(function(player,action,arg)
 if action=="list" then stateRemote:FireClient(player,"supportProducts",SUPPORT_PRODUCTS);return end
 if action~="prompt" then return end
 local idx=tonumber(arg);local item=idx and SUPPORT_PRODUCTS[idx];if not item then return end
 if item.productId and item.productId>0 then MarketplaceService:PromptProductPurchase(player,item.productId)
 else stateRemote:FireClient(player,"toast","Support siap. Product ID experience belum dipasang.") end
end)

Players.PlayerAdded:Connect(function(player)
 task.delay(2,function()
  if player.Parent then
   stateRemote:FireClient(player,"playlist",PLAYLIST)
   stateRemote:FireClient(player,"supportProducts",SUPPORT_PRODUCTS)
   stateRemote:FireClient(player,"music",{index=current,title=PLAYLIST[current] and PLAYLIST[current].title or "",playing=activeDeck.IsPlaying and not paused,queue=#requestQueue,audioMode="AUTODJ"})
  end
 end)
end)
Players.PlayerRemoving:Connect(function(player)requestCooldown[player.UserId]=nil end)

-- AutoDJ monitor: preload next track, then crossfade just before the current track ends.
task.spawn(function()
 while task.wait(.20) do
  if not transitioning and not paused and activeDeck.IsPlaying then
   local len=activeDeck.TimeLength
   local pos=activeDeck.TimePosition
   if len and len>5 then
    local remain=len-pos
    local ni=peekNextIndex()
    if ni and remain<=PRELOAD_WINDOW then preloadStandby(ni) end
    if remain<=CROSSFADE_SECONDS+.15 then task.spawn(function()transitionToNext(false)end) end
   end
  end
 end
end)

task.delay(2,function()if not activeDeck.IsPlaying then playTrackImmediate(1) end end)
print("[BBYA] AutoDJ v4 online: queue-only requests + preloaded 1.2s crossfade")