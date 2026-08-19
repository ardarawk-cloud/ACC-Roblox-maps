local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local remote=ReplicatedStorage:FindFirstChild("BBYAEditRemote") or Instance.new("RemoteEvent")
remote.Name="BBYAEditRemote";remote.Parent=ReplicatedStorage

local history={}
local function editable(inst)
 if not inst or not inst:IsA("BasePart") then return false end
 local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
 return root and inst:IsDescendantOf(root) and not inst:IsA("SpawnLocation")
end

remote.OnServerEvent:Connect(function(player,action,target,arg)
 if action=="rotate" and editable(target) then
  table.insert(history,{kind="cf",obj=target,cf=target.CFrame})
  target.CFrame=target.CFrame*CFrame.Angles(0,math.rad(tonumber(arg) or 15),0)
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
