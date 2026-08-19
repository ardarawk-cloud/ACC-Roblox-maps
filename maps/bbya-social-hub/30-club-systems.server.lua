local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")
local Workspace=game:GetService("Workspace")

local folder=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
folder.Name="BBYAClubRemotes";folder.Parent=ReplicatedStorage
local musicRemote=folder:FindFirstChild("Music") or Instance.new("RemoteEvent");musicRemote.Name="Music";musicRemote.Parent=folder
local supportRemote=folder:FindFirstChild("Support") or Instance.new("RemoteEvent");supportRemote.Name="Support";supportRemote.Parent=folder
local stateRemote=folder:FindFirstChild("State") or Instance.new("RemoteEvent");stateRemote.Name="State";stateRemote.Parent=folder

-- Verified Creator Store audio IDs. These are public Creator Store music assets.
local PLAYLIST={
 {title="Pumpin' And Bumpin' D",id="9040442826"},
 {title="DJ Party Time",id="90337553112855"},
 {title="Electronic Music",id="1846869595"},
 {title="Electronic Avenue",id="84504061779927"},
 {title="DJ",id="15878422179"},
 {title="Welcome",id="137350000972072"},
 {title="Store",id="1837393392"},
}

-- Sawer buttons remain wired; real Developer Product IDs must belong to this experience.
local SUPPORT_PRODUCTS={
 {label="10",productId=0},
 {label="25",productId=0},
 {label="50",productId=0},
 {label="100",productId=0},
 {label="250",productId=0},
}

local sound=Workspace:FindFirstChild("BBYAClubSound") or Instance.new("Sound")
sound.Name="BBYAClubSound";sound.Volume=.62;sound.Looped=false;sound.RollOffMode=Enum.RollOffMode.InverseTapered;sound.RollOffMinDistance=18;sound.RollOffMaxDistance=220;sound.EmitterSize=28;sound.Parent=Workspace
local current=1
local function validTrack(i)local t=PLAYLIST[i];return t and t.id and tostring(t.id)~="" end
local function playTrack(i)
 if not validTrack(i) then return false end
 current=i;sound.SoundId="rbxassetid://"..tostring(PLAYLIST[i].id);sound.TimePosition=0;sound:Play()
 stateRemote:FireAllClients("music",{index=i,title=PLAYLIST[i].title,playing=true})
 return true
end
local function nextTrack()
 for step=1,#PLAYLIST do local i=((current-1+step)%#PLAYLIST)+1;if playTrack(i) then return true end end
 return false
end
sound.Ended:Connect(nextTrack)

musicRemote.OnServerEvent:Connect(function(player,action,arg)
 if action=="list" then stateRemote:FireClient(player,"playlist",PLAYLIST)
 elseif action=="play" then playTrack(tonumber(arg) or current)
 elseif action=="pause" then sound:Pause();stateRemote:FireAllClients("music",{index=current,title=PLAYLIST[current].title,playing=false})
 elseif action=="resume" then sound:Resume();stateRemote:FireAllClients("music",{index=current,title=PLAYLIST[current].title,playing=true})
 elseif action=="next" then nextTrack() end
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

task.delay(2,function()if not sound.IsPlaying then playTrack(1) end end)
print("[BBYA] Hybrid DJ LIVE with Creator Store playlist")