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

local emitter=Workspace:FindFirstChild("BBYAClubSoundEmitter")
if not emitter then
 emitter=Instance.new("Part");emitter.Name="BBYAClubSoundEmitter";emitter.Size=Vector3.new(.5,.5,.5);emitter.CFrame=CFrame.new(0,7,35);emitter.Anchored=true;emitter.CanCollide=false;emitter.CanTouch=false;emitter.CanQuery=false;emitter.Transparency=1;emitter.Parent=Workspace
end
local group=SoundService:FindFirstChild("BBYAClubMaster")
if not group then group=Instance.new("SoundGroup");group.Name="BBYAClubMaster";group.Volume=.95;group.Parent=SoundService end
local eq=group:FindFirstChild("ClubEQ")
if not eq then eq=Instance.new("EqualizerSoundEffect");eq.Name="ClubEQ";eq.LowGain=2.5;eq.MidGain=-.5;eq.HighGain=1;eq.Parent=group end
local sound=Workspace:FindFirstChild("BBYAClubSound",true) or Instance.new("Sound")
sound.Name="BBYAClubSound";sound.Volume=.7;sound.Looped=false;sound.RollOffMode=Enum.RollOffMode.InverseTapered;sound.RollOffMinDistance=28;sound.RollOffMaxDistance=260;sound.EmitterSize=34;sound.SoundGroup=group;sound.Parent=emitter

local current=1
local requestQueue={}
local requestCooldown={}
local function validTrack(i)local t=PLAYLIST[i];return t and t.id and tostring(t.id)~="" end
local function playTrack(i)
 if not validTrack(i) then return false end
 current=i;sound.SoundId="rbxassetid://"..tostring(PLAYLIST[i].id);sound.TimePosition=0;sound:Play()
 stateRemote:FireAllClients("music",{index=i,title=PLAYLIST[i].title,playing=true})
 return true
end
local function nextTrack()
 while #requestQueue>0 do
  local req=table.remove(requestQueue,1)
  if validTrack(req.index) then
   playTrack(req.index)
   stateRemote:FireAllClients("toast",string.format("DJ request: %s",PLAYLIST[req.index].title))
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
 stateRemote:FireClient(player,"toast",string.format("Request masuk: %s",PLAYLIST[index].title))
 if not sound.IsPlaying then nextTrack() end
 return true
end
sound.Ended:Connect(nextTrack)

musicRemote.OnServerEvent:Connect(function(player,action,arg)
 if action=="list" then stateRemote:FireClient(player,"playlist",PLAYLIST)
 elseif action=="play" then playTrack(tonumber(arg) or current)
 elseif action=="request" then queueRequest(player,arg)
 elseif action=="pause" then sound:Pause();stateRemote:FireAllClients("music",{index=current,title=PLAYLIST[current].title,playing=false})
 elseif action=="resume" then sound:Resume();stateRemote:FireAllClients("music",{index=current,title=PLAYLIST[current].title,playing=true})
 elseif action=="next" then nextTrack() end
end)
internalMusic.Event:Connect(function(action,player,arg)
 if action=="request" then queueRequest(player,arg)
 elseif action=="next" then nextTrack()
 elseif action=="play" then playTrack(tonumber(arg) or current) end
end)

supportRemote.OnServerEvent:Connect(function(player,action,arg)
 if action=="list" then stateRemote:FireClient(player,"supportProducts",SUPPORT_PRODUCTS);return end
 if action~="prompt" then return end
 local idx=tonumber(arg);local item=idx and SUPPORT_PRODUCTS[idx];if not item then return end
 if item.productId and item.productId>0 then MarketplaceService:PromptProductPurchase(player,item.productId)
 else stateRemote:FireClient(player,"toast","Sawer siap. Product ID experience belum dipasang.") end
end)

Players.PlayerAdded:Connect(function(player)
 task.delay(2,function()if player.Parent then stateRemote:FireClient(player,"playlist",PLAYLIST);stateRemote:FireClient(player,"supportProducts",SUPPORT_PRODUCTS);if sound.IsPlaying then stateRemote:FireClient(player,"music",{index=current,title=PLAYLIST[current].title,playing=true}) end end end)
end)
Players.PlayerRemoving:Connect(function(player)requestCooldown[player.UserId]=nil end)
task.delay(2,function()if not sound.IsPlaying then playTrack(1) end end)
print("[BBYA] Main Club spatial DJ audio + request queue online")