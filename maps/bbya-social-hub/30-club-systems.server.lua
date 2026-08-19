local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")
local Workspace=game:GetService("Workspace")

local folder=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
folder.Name="BBYAClubRemotes";folder.Parent=ReplicatedStorage
local musicRemote=folder:FindFirstChild("Music") or Instance.new("RemoteEvent");musicRemote.Name="Music";musicRemote.Parent=folder
local supportRemote=folder:FindFirstChild("Support") or Instance.new("RemoteEvent");supportRemote.Name="Support";supportRemote.Parent=folder
local stateRemote=folder:FindFirstChild("State") or Instance.new("RemoteEvent");stateRemote.Name="State";stateRemote.Parent=folder

-- Replace/add approved Roblox audio IDs here. Empty IDs stay unavailable instead of breaking playback.
local PLAYLIST={
 {title="BBYA Opening",id=""},
 {title="Indo Bounce",id=""},
 {title="Breakbeat",id=""},
 {title="Funkot",id=""},
 {title="Late Night",id=""},
}

-- Developer Product IDs are intentionally optional. Set real product IDs later; buttons remain preview-safe until then.
local SUPPORT_PRODUCTS={
 {label="10",productId=0},
 {label="25",productId=0},
 {label="50",productId=0},
 {label="100",productId=0},
 {label="250",productId=0},
}

local sound=Workspace:FindFirstChild("BBYAClubSound") or Instance.new("Sound")
sound.Name="BBYAClubSound";sound.Volume=.55;sound.Looped=false;sound.RollOffMaxDistance=180;sound.Parent=Workspace
local current=1
local function validTrack(i)
 local t=PLAYLIST[i]
 return t and t.id and tostring(t.id)~=""
end
local function playTrack(i)
 if not validTrack(i) then return false end
 current=i
 sound.SoundId="rbxassetid://"..tostring(PLAYLIST[i].id)
 sound:Play()
 stateRemote:FireAllClients("music",{index=i,title=PLAYLIST[i].title,playing=true})
 return true
end
sound.Ended:Connect(function()
 for step=1,#PLAYLIST do
  local i=((current-1+step)%#PLAYLIST)+1
  if playTrack(i) then return end
 end
end)

musicRemote.OnServerEvent:Connect(function(player,action,arg)
 if action=="list" then stateRemote:FireClient(player,"playlist",PLAYLIST)
 elseif action=="play" then playTrack(tonumber(arg) or current)
 elseif action=="pause" then sound:Pause();stateRemote:FireAllClients("music",{index=current,title=PLAYLIST[current].title,playing=false})
 elseif action=="resume" then sound:Resume();stateRemote:FireAllClients("music",{index=current,title=PLAYLIST[current].title,playing=true})
 elseif action=="next" then
  for step=1,#PLAYLIST do local i=((current-1+step)%#PLAYLIST)+1;if playTrack(i) then break end end
 end
end)

supportRemote.OnServerEvent:Connect(function(player,action,arg)
 if action=="list" then stateRemote:FireClient(player,"supportProducts",SUPPORT_PRODUCTS);return end
 if action~="prompt" then return end
 local idx=tonumber(arg);local item=idx and SUPPORT_PRODUCTS[idx]
 if not item then return end
 if item.productId and item.productId>0 then
  MarketplaceService:PromptProductPurchase(player,item.productId)
 else
  stateRemote:FireClient(player,"toast","Support button siap; Product ID belum dipasang.")
 end
end)

Players.PlayerAdded:Connect(function(player)
 task.delay(2,function()
  if player.Parent then
   stateRemote:FireClient(player,"playlist",PLAYLIST)
   stateRemote:FireClient(player,"supportProducts",SUPPORT_PRODUCTS)
  end
 end)
end)

print("[BBYA] Music + support backend ready")