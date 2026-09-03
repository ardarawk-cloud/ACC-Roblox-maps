-- BBYA SOCIAL HUB — MALL TEST bottom safe-area trim v1
-- Keeps the V12 top position unchanged and raises only the lower edge by exactly 50 px.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local CUT=50
local connections={}
local guard=false

local function clearConnections()
 for _,c in ipairs(connections)do c:Disconnect()end
 table.clear(connections)
end

local function apply(gui)
 if guard or not gui or not gui.Parent then return end
 local root=gui:FindFirstChild("CatalogRoot")
 local shell=root and root:FindFirstChild("PreciseShell")
 local avatar=shell and shell:FindFirstChild("AvatarCard")
 local host=shell and shell:FindFirstChild("ModuleHost")
 local action=shell and shell:FindFirstChild("SelectedActions")
 if not shell or not avatar or not host or not action then return end
 local shellH=shell.Size.Y.Offset
 local bodyY=avatar.Position.Y.Offset
 if shellH<=0 or bodyY<=0 then return end
 local bodyH=math.max(250,shellH-bodyY-CUT)
 local actionY=math.max(bodyY+bodyH,shellH-CUT)
 guard=true
 avatar.Size=UDim2.fromOffset(avatar.Size.X.Offset,bodyH)
 host.Size=UDim2.fromOffset(host.Size.X.Offset,bodyH)
 action.Position=UDim2.fromOffset(action.Position.X.Offset,actionY)
 guard=false
end

local function bind(gui)
 clearConnections()
 local root=gui:WaitForChild("CatalogRoot",10)
 local shell=root and root:WaitForChild("PreciseShell",10)
 local avatar=shell and shell:WaitForChild("AvatarCard",10)
 if not root or not shell or not avatar then return end
 local function refresh()task.defer(function()apply(gui)end)end
 table.insert(connections,root:GetPropertyChangedSignal("Visible"):Connect(refresh))
 table.insert(connections,shell:GetPropertyChangedSignal("Size"):Connect(refresh))
 table.insert(connections,avatar:GetPropertyChangedSignal("Size"):Connect(function()if not guard then refresh()end end))
 refresh()
end

local current=pg:FindFirstChild("BBYAMallRobuxCommerceUI")
if current then task.defer(function()bind(current)end)end
pg.ChildAdded:Connect(function(ch)
 if ch.Name=="BBYAMallRobuxCommerceUI"then task.defer(function()bind(ch)end)end
end)
pg.ChildRemoved:Connect(function(ch)
 if ch.Name=="BBYAMallRobuxCommerceUI"then clearConnections()end
end)

print("[BBYA] Mall bottom safe trim active: lower edge raised 50px")
