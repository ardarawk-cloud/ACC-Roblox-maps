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

local group=SoundService:FindFirstChild("BBYAClubMaster")
if not group then group=Instance.new("SoundGroup");group.Name="BBYAClubMaster";group.Parent=SoundService end
group.Volume=.92
local eq=group:FindFirstChild("ClubEQ")
if not eq then eq=Instance.new("EqualizerSoundEffect");eq.Name="ClubEQ";eq.Parent=group end
eq.LowGain=2.0;eq.MidGain=-.35;eq.HighGain=.75
local compressor=group:FindFirstChild("VenueCompressor")
if not compressor then compressor=Instance.new("CompressorSoundEffect");compressor.Name="VenueCompressor";compressor.Parent=group end
compressor.Threshold=-12;compressor.Ratio=3;compressor.Attack=.08;compressor.Release=.22;compressor.GainMakeup=1

local oldEmitter=Workspace:FindFirstChild("BBYAClubSoundEmitter")
if oldEmitter then oldEmitter:Destroy() end
local oldSound=Workspace:FindFirstChild("BBYAClubSound",true)
if oldSound then oldSound:Destroy() end
local oldZones=Workspace:FindFirstChild("BBYAAudioZones")
if oldZones then oldZones:Destroy() end

local zones=Instance.new("Folder");zones.Name="BBYAAudioZones";zones.Parent=Workspace
local ZONE_SPECS={
 {name="StageMain",pos=Vector3.new(3,7,34.5),volume=.70,min=28,max=175,size=32},
 {name="BarFill",pos=Vector3.new(38,6,11),volume=.32,min=18,max=92,size=20},
 {name="VIPLoungeFill",pos=Vector3.new(-38,5,14),volume=.30,min=18,max=92,size=20},
 {name="TransitionFill",pos=Vector3.new(0,5,-8),volume=.19,min=14,max=68,size=15},
 {name="FrontHallFill",pos=Vector3.new(0,4,-24),volume=.12,min=12,max=48,size=12},
}
local sounds={}
for _,spec in ipairs(ZONE_SPECS) do
 local emitter=Instance.new("Part")
 emitter.Name="Emitter_"..spec.name;emitter.Size=Vector3.new(.4,.4,.4);emitter.CFrame=CFrame.new(spec.pos);emitter.Anchored=true;emitter.CanCollide=false;emitter.CanTouch=false;emitter.CanQuery=false;emitter.Transparency=1;emitter.Parent=zones
 local s=Instance.new("Sound")
 s.Name="BBYAClubSound_"..spec.name;s.Volume=spec.volume;s.Looped=false;s.RollOffMode=Enum.RollOffMode.InverseTapered;s.RollOffMinDistance=spec.min;s.RollOffMaxDistance=spec.max;s.EmitterSize=spec.size;s.SoundGroup=group;s.Parent=emitter
 table.insert(sounds,s)
end
local masterSound=sounds[1]

local current=1
local requestQueue={}
local requestCooldown={}
local function validTrack(i)local t=PLAYLIST[i];return t and t.id and tostring(t.id)~="" end
local function fireMusicState(playing)
 stateRemote:FireAllClients("music",{index=current,title=PLAYLIST[current] and PLAYLIST[current].title or "",playing=playing,queue=#requestQueue})
end
local function setAllTrack(i)
 local soundId="rbxassetid://"..tostring(PLAYLIST[i].id)
 for _,s in ipairs(sounds) do s.SoundId=soundId;s.TimePosition=0 end
end
local function playAll()
 for _,s in ipairs(sounds) do s:Play() end
end
local function pauseAll()for _,s in ipairs(sounds) do s:Pause() end end
local function resumeAll()for _,s in ipairs(sounds) do s:Resume() end end
local function playTrack(i)
 if not validTrack(i) then return false end
 current=i;setAllTrack(i);playAll();fireMusicState(true);return true
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
 for step=1,#PLAYLIST do local i=((current-1+step)%#PLAYLIST)+1;if playTrack(i) then return true end end
 return false
end
local function queueRequest(player,index)
 index=tonumber(index)
 if not player or not validTrack(index) then return false end
 local now=os.clock();local last=requestCooldown[player.UserId] or 0
 if now-last<20 then stateRemote:FireClient(player,"toast","Tunggu sebentar sebelum request lagu lagi.");return false end
 if #requestQueue>=8 then stateRemote:FireClient(player,"toast","DJ request queue sedang penuh.");return false end
 for _,req in ipairs(requestQueue) do if req.playerId==player.UserId and req.index==index then stateRemote:FireClient(player,"toast","Request itu sudah ada di antrean.");return false end end
 requestCooldown[player.UserId]=now
 table.insert(requestQueue,{playerId=player.UserId,index=index})
 stateRemote:FireClient(player,"toast",string.format("Request masuk #%d: %s",#requestQueue,PLAYLIST[index].title))
 stateRemote:FireClient(player,"djQueue",{position=#requestQueue,count=#requestQueue,title=PLAYLIST[index].title,now=PLAYLIST[current] and PLAYLIST[current].title or ""})
 if not masterSound.IsPlaying then nextTrack() end
 return true
end
masterSound.Ended:Connect(nextTrack)

musicRemote.OnServerEvent:Connect(function(player,action,arg)
 if action=="list" then stateRemote:FireClient(player,"playlist",PLAYLIST)
 elseif action=="play" then playTrack(tonumber(arg) or current)
 elseif action=="request" then queueRequest(player,arg)
 elseif action=="queue" then stateRemote:FireClient(player,"djQueue",{position=0,count=#requestQueue,now=PLAYLIST[current] and PLAYLIST[current].title or ""})
 elseif action=="pause" then pauseAll();fireMusicState(false)
 elseif action=="resume" then resumeAll();fireMusicState(true)
 elseif action=="next" then nextTrack() end
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
 else stateRemote:FireClient(player,"toast","Sawer siap. Product ID experience belum dipasang.") end
end)

Players.PlayerAdded:Connect(function(player)
 task.delay(2,function()
  if player.Parent then
   stateRemote:FireClient(player,"playlist",PLAYLIST)
   stateRemote:FireClient(player,"supportProducts",SUPPORT_PRODUCTS)
   stateRemote:FireClient(player,"audioZones",{count=#ZONE_SPECS})
   if masterSound.IsPlaying then stateRemote:FireClient(player,"music",{index=current,title=PLAYLIST[current].title,playing=true,queue=#requestQueue}) end
  end
 end)
end)
Players.PlayerRemoving:Connect(function(player)requestCooldown[player.UserId]=nil end)

-- Keep secondary emitters tightly aligned to the stage master without restarting music.
task.spawn(function()
 while task.wait(6) do
  if masterSound and masterSound.Parent and masterSound.IsPlaying then
   for i=2,#sounds do
    local s=sounds[i]
    if s and s.Parent then
     if not s.IsPlaying then s.TimePosition=masterSound.TimePosition;s:Play()
     elseif math.abs(s.TimePosition-masterSound.TimePosition)>.35 then s.TimePosition=masterSound.TimePosition end
    end
   end
  end
 end
end)

task.delay(2,function()if not masterSound.IsPlaying then playTrack(1) end end)
print("[BBYA] Multi-zone synchronized club audio online: stage, bar, VIP, transition and front hall")