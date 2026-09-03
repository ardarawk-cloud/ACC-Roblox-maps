-- BBYA SOCIAL HUB — MALL TEST bottom safe-area + selection actions fix v2
-- Publish trigger only: canonical selection-action fix lives in 133-mall-robux-commerce.client.lua.
-- Keeps the V12 top position unchanged, raises only the lower edge by exactly 50 px,
-- and exposes TRY / CART / SAVE / BUY immediately after a live product card is selected.

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

local function bindProductButton(button,root,products,action)
 if not button:IsA("TextButton")then return end
 if button.Name:sub(1,5)~="Item_"then return end
 if button:GetAttribute("BBYASelectionActionsBound")then return end
 button:SetAttribute("BBYASelectionActionsBound",true)
 table.insert(connections,button.Activated:Connect(function()
  task.defer(function()
   if root.Parent and root.Visible and products.Parent and products.Visible and action.Parent then
    action.Visible=true
   end
  end)
 end))
end

local function bind(gui)
 clearConnections()
 local root=gui:WaitForChild("CatalogRoot",10)
 local shell=root and root:WaitForChild("PreciseShell",10)
 local avatar=shell and shell:WaitForChild("AvatarCard",10)
 local host=shell and shell:WaitForChild("ModuleHost",10)
 local products=host and host:WaitForChild("PRODUCTS",10)
 local action=shell and shell:WaitForChild("SelectedActions",10)
 if not root or not shell or not avatar or not host or not products or not action then return end

 local function refresh()task.defer(function()apply(gui)end)end
 table.insert(connections,root:GetPropertyChangedSignal("Visible"):Connect(refresh))
 table.insert(connections,shell:GetPropertyChangedSignal("Size"):Connect(refresh))
 table.insert(connections,avatar:GetPropertyChangedSignal("Size"):Connect(function()if not guard then refresh()end end))

 for _,d in ipairs(products:GetDescendants())do bindProductButton(d,root,products,action)end
 table.insert(connections,products.DescendantAdded:Connect(function(d)
  bindProductButton(d,root,products,action)
 end))
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

print("[BBYA] Mall bottom safe + selection actions fix active: lower edge +50px safe, TRY panel on product select")
