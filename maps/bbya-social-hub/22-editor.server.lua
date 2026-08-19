local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")

local remote=ReplicatedStorage:FindFirstChild("BBYAEditRemote") or Instance.new("RemoteEvent")
remote.Name="BBYAEditRemote";remote.Parent=ReplicatedStorage

local CO_OWNER_USERNAMES={
 ["nadmo97"]=true,
}

local history={}

local function isAdmin(player)
 if not player then return false end
 if CO_OWNER_USERNAMES[string.lower(player.Name)] then return true end
 if game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId then return true end
 return player:GetAttribute("BBYAAdmin")==true
end

local function applyAdminFlags(player)
 if isAdmin(player) then
  player:SetAttribute("BBYAAdmin",true)
  player:SetAttribute("BBYACoOwner",CO_OWNER_USERNAMES[string.lower(player.Name)]==true)
  player:SetAttribute("BBYAVIPBypass",true)
  player:SetAttribute("BBYARooftopBypass",true)
  player:SetAttribute("BBYASecretRoomBypass",true)
 end
end

for _,player in ipairs(Players:GetPlayers()) do applyAdminFlags(player) end
Players.PlayerAdded:Connect(applyAdminFlags)

local function editable(inst)
 if not inst or not inst:IsA("BasePart") then return false end
 local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
 return root and inst:IsDescendantOf(root) and not inst:IsA("SpawnLocation")
end

local function saveCF(target)
 table.insert(history,{kind="cf",obj=target,cf=target.CFrame})
end

remote.OnServerEvent:Connect(function(player,action,target,arg)
 if not isAdmin(player) then return end
 if action=="rotate" and editable(target) then
  saveCF(target);target.CFrame=target.CFrame*CFrame.Angles(0,math.rad(tonumber(arg) or 15),0)
 elseif action=="move" and editable(target) and typeof(arg)=="Vector3" then
  saveCF(target);target.CFrame=target.CFrame+CFrame.new(arg).Position
 elseif action=="delete" and editable(target) then
  local clone=target:Clone();clone.Parent=nil
  table.insert(history,{kind="delete",clone=clone,parent=target.Parent,cf=target.CFrame})
  target:Destroy()
 elseif action=="undo" then
  local h=table.remove(history)
  if h then
   if h.kind=="cf" and h.obj and h.obj.Parent then h.obj.CFrame=h.cf
   elseif h.kind=="delete" and h.clone and h.parent then h.clone.CFrame=h.cf;h.clone.Parent=h.parent end
  end
 end
end)
