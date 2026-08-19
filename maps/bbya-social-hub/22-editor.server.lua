local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local DataStoreService=game:GetService("DataStoreService")

local remote=ReplicatedStorage:FindFirstChild("BBYAEditRemote") or Instance.new("RemoteEvent")
remote.Name="BBYAEditRemote";remote.Parent=ReplicatedStorage

local CO_OWNER_USERNAMES={
 ["nadmo97"]=true,
}

local deleteStore=DataStoreService:GetDataStore("BBYA_EDITOR_DELETE_V1")
local DELETE_KEY="GLOBAL_TOMBSTONES"
local tombstones={}
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

local function getRoot()
 return Workspace:FindFirstChild("BBYA_ZERO_BUILD")
end

local function editable(inst)
 if not inst or not inst:IsA("BasePart") then return false end
 local root=getRoot()
 return root and inst:IsDescendantOf(root) and not inst:IsA("SpawnLocation")
end

local function relativePath(inst)
 local root=getRoot()
 if not root or not inst or not inst:IsDescendantOf(root) then return nil end
 local names={}
 local cur=inst
 while cur and cur~=root do
  table.insert(names,1,cur.Name)
  cur=cur.Parent
 end
 return table.concat(names,"/")
end

local function saveTombstones()
 local payload={}
 for path in pairs(tombstones) do table.insert(payload,path) end
 table.sort(payload)
 task.spawn(function()
  pcall(function() deleteStore:SetAsync(DELETE_KEY,payload) end)
 end)
end

local function loadTombstones()
 local ok,data=pcall(function() return deleteStore:GetAsync(DELETE_KEY) end)
 if ok and type(data)=="table" then
  for _,path in ipairs(data) do
   if type(path)=="string" then tombstones[path]=true end
  end
 end
end

local function shouldDelete(inst)
 if not inst:IsA("BasePart") then return false end
 local path=relativePath(inst)
 return path and tombstones[path]==true
end

local function applyTombstones(root)
 if not root then return end
 for _,inst in ipairs(root:GetDescendants()) do
  if shouldDelete(inst) then inst:Destroy() end
 end
end

loadTombstones()

task.spawn(function()
 while not getRoot() do task.wait(.25) end
 local root=getRoot()
 applyTombstones(root)
 root.DescendantAdded:Connect(function(inst)
  if inst:IsA("BasePart") then
   task.defer(function()
    if inst.Parent and shouldDelete(inst) then inst:Destroy() end
   end)
  end
 end)
 task.delay(2,function() applyTombstones(root) end)
 task.delay(5,function() applyTombstones(root) end)
end)

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
  local path=relativePath(target)
  local clone=target:Clone();clone.Parent=nil
  table.insert(history,{kind="delete",clone=clone,parent=target.Parent,cf=target.CFrame,path=path})
  if path then tombstones[path]=true;saveTombstones() end
  target:Destroy()
 elseif action=="undo" then
  local h=table.remove(history)
  if h then
   if h.kind=="cf" and h.obj and h.obj.Parent then
    h.obj.CFrame=h.cf
   elseif h.kind=="delete" and h.clone and h.parent then
    if h.path then tombstones[h.path]=nil;saveTombstones() end
    h.clone.CFrame=h.cf;h.clone.Parent=h.parent
   end
  end
 end
end)

print("[BBYA] Runtime editor: persistent delete tombstones enabled")