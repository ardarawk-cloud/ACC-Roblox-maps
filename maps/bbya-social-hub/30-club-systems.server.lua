local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")
local Workspace=game:GetService("Workspace")
local SoundService=game:GetService("SoundService")

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

local function isAdmin(player)
 if not player then return false end
 if player:GetAttribute("BBYAAdmin")==true then return true end
 if game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId then return true end
 return false
end
local function denyTransport(player)
 stateRemote:FireClient(player,"toast","DJ transport controls khusus admin. Gunakan Request untuk antrean lagu.")
end

-- AUDIO V3: one server-authoritative non-spatial feed.
-- The previous five independent 3D Sounds could drift/echo. A single feed keeps every listener on one timeline;
-- each client applies local zone volume so the venue still feels spatial without phase delay.
local oldZones=Workspace:FindFirstChild("BBYAAudioZones")
if oldZones then oldZones:Destroy() end
for _,obj in ipairs(Workspace:GetDescendants()) do
 if obj:IsA("Sound") and (obj.Name=="BBYAClubSound" or obj.Name:match("^BBYAClubSound_")) then obj:Destroy() end
end
local oldFeed=SoundService:FindFirstChild("BBYAClubFeed")
if oldFeed then oldFeed:Destroy() end

local group=SoundService:FindFirstChild("BBYAClubMaster")
if not group then group=Instance.new("SoundGroup");group.Name="BBYAClubMaster";group.Parent=SoundService end
group.Volume=1
group:SetAttribute("BBYAAudioMode","SYNCED_MASTER_V3")

local eq=group:FindFirstChild("ClubEQ")
if not eq then eq=Instance.new("EqualizerSoundEffect");eq.Name="ClubEQ";eq.Parent=group end
eq.LowGain=1.15;eq.MidGain=-.15;eq.HighGain=.45
local compressor=group:FindFirstChild("VenueCompressor")
if not compressor then compressor=Instance.new("CompressorSoundEffect");compressor.Name="VenueCompressor";compressor.Parent=group end
compressor.Threshold=-10;compressor.Ratio=2.25;compressor.Attack=.06;compressor.Release=.28;compressor.GainMakeup=.5

local masterSound=Instance.new("Sound")
masterSound.Name="BBYAClubFeed"
masterSound.Volume=1
masterSound.Looped=false
masterSound.SoundGroup=group
masterSound.Parent=SoundService

local current=1
local requestQueue={}
local requestCooldown={}
local function validTrack(i)local t=PLAYLIST[i];return t and t.id and tostring(t.id)~="" end
local function fireMusicState(playing)
 stateRemote:FireAllClients("music",{index=current,title=PLAYLIST[current] and PLAYLIST[current].title or "",playing=playing,queue=#requestQueue,audioMode="SYNCED"})
end
local function playTrack(i)
 if not validTrack(i) then return false end
 current=i
 masterSound:Stop()
 masterSound.SoundId="rbxassetid://"..tostring(PLAYLIST[i].id)
 masterSound.TimePosition=0
 masterSound:Play()
 fireMusicState(true)
 return true
end
local function nextTrack()
 while #requestQueue>0 do
  local req=table.remove(requestQueue,1)
  if validTrack(req.index) then
   playTrack(req.index)
   stateRemote:FireAllClients("toast",string.format("DJ request now playing: %s",PLAYLIST[req.index].title))
   return true
  end
 end
 for step=1,#PLAYLIST do
  local i=((current-1+step)%#PLAYLIST)+1
  if playTrack(i) then return true end
 end
 return false
end
local function queueRequest(player,index)
 index=tonumber(index)
 if not player or not validTrack(index) then return false end
 local now=os.clock();local last=requestCooldown[player.UserId] or 0
 if now-last<20 then stateRemote:FireClient(player,"toast","Tunggu sebentar sebelum request lagu lagi.");return false end
 if #requestQueue>=8 then stateRemote:FireClient(player,"toast","DJ request queue sedang penuh.");return false end
 for _,req in ipairs(requestQueue) do
  if req.playerId==player.UserId and req.index==index then
   stateRemote:FireClient(player,"toast","Request itu sudah ada di antrean.");return false
  end
 end
 requestCooldown[player.UserId]=now
 table.insert(requestQueue,{playerId=player.UserId,index=index})
 stateRemote:FireClient(player,"toast",string.format("Request masuk #%d: %s",#requestQueue,PLAYLIST[index].title))
 stateRemote:FireClient(player,"djQueue",{position=#requestQueue,count=#requestQueue,title=PLAYLIST[index].title,now=PLAYLIST[current] and PLAYLIST[current].title or ""})
 if not masterSound.IsPlaying then nextTrack() end
 return true
end
masterSound.Ended:Connect(nextTrack)

musicRemote.OnServerEvent:Connect(function(player,action,arg)
 if action=="list" then
  stateRemote:FireClient(player,"playlist",PLAYLIST)
  stateRemote:FireClient(player,"music",{index=current,title=PLAYLIST[current] and PLAYLIST[current].title or "",playing=masterSound.IsPlaying,queue=#requestQueue,audioMode="SYNCED"})
 elseif action=="request" then queueRequest(player,arg)
 elseif action=="queue" then stateRemote:FireClient(player,"djQueue",{position=0,count=#requestQueue,now=PLAYLIST[current] and PLAYLIST[current].title or ""})
 elseif action=="play" then if isAdmin(player) then playTrack(tonumber(arg) or current) else denyTransport(player) end
 elseif action=="pause" then if isAdmin(player) then masterSound:Pause();fireMusicState(false) else denyTransport(player) end
 elseif action=="resume" then if isAdmin(player) then masterSound:Resume();fireMusicState(true) else denyTransport(player) end
 elseif action=="next" then if isAdmin(player) then nextTrack() else denyTransport(player) end
 end
end)

internalMusic.Event:Connect(function(action,player,arg)
 if action=="request" then queueRequest(player,arg)
 elseif action=="next" then nextTrack()
 elseif action=="play" then playTrack(tonumber(arg) or current)
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
   stateRemote:FireClient(player,"music",{index=current,title=PLAYLIST[current] and PLAYLIST[current].title or "",playing=masterSound.IsPlaying,queue=#requestQueue,audioMode="SYNCED"})
  end
 end)
end)
Players.PlayerRemoving:Connect(function(player)requestCooldown[player.UserId]=nil end)

task.delay(2,function()if not masterSound.IsPlaying then playTrack(1) end end)
print("[BBYA] Synced master club feed online; client zone-volume balancing enabled")