-- BBYA SOCIAL HUB — MALL CATALOG FOCUS MODE v1
-- Hides BBYA custom UI while Mall catalog is open and keeps Roblox CoreGui unobstructed.
-- Test candidate only until owner acceptance.

local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local COMMERCE_GUI_NAME="BBYAMallRobuxCommerceUI"
local TOP_SAFE_TOUCH=118
local TOP_SAFE_DESKTOP=88
local BOTTOM_SAFE=18
local SIDE_SAFE=18

local saved={}
local focusActive=false
local childConn=nil
local camera=workspace.CurrentCamera

local function hideGui(g)
 if not focusActive or not g:IsA("ScreenGui") or g.Name==COMMERCE_GUI_NAME then return end
 if saved[g]==nil then saved[g]=g.Enabled end
 g.Enabled=false
end

local function restoreAll()
 for g,wasEnabled in pairs(saved) do
  if g and g.Parent then g.Enabled=wasEnabled end
 end
 table.clear(saved)
end

local function fitPanel(gui,panel)
 camera=workspace.CurrentCamera or camera
 if not camera or not panel then return end
 local vp=camera.ViewportSize
 local topSafe=UserInputService.TouchEnabled and TOP_SAFE_TOUCH or TOP_SAFE_DESKTOP
 local maxW=math.max(520,vp.X-(SIDE_SAFE*2))
 local maxH=math.max(300,vp.Y-topSafe-BOTTOM_SAFE)
 local w=math.clamp(math.floor(vp.X*(UserInputService.TouchEnabled and .76 or .70)),620,920)
 local h=math.clamp(math.floor(vp.Y*(UserInputService.TouchEnabled and .60 or .58)),350,470)
 w=math.min(w,maxW)
 h=math.min(h,maxH)
 panel.AnchorPoint=Vector2.new(.5,.5)
 panel.Size=UDim2.fromOffset(w,h)
 panel.Position=UDim2.fromOffset(math.floor(vp.X/2),math.floor(topSafe+(maxH/2)))
 gui.IgnoreGuiInset=true
end

local function enterFocus(gui,panel)
 if focusActive then fitPanel(gui,panel);return end
 focusActive=true
 for _,g in ipairs(pg:GetChildren()) do hideGui(g) end
 gui.Enabled=true
 if childConn then childConn:Disconnect() end
 childConn=pg.ChildAdded:Connect(function(g)
  task.defer(function()hideGui(g)end)
 end)
 fitPanel(gui,panel)
 player:SetAttribute("BBYAMallCatalogFocusMode",true)
end

local function leaveFocus()
 if not focusActive then return end
 focusActive=false
 if childConn then childConn:Disconnect();childConn=nil end
 restoreAll()
 player:SetAttribute("BBYAMallCatalogFocusMode",false)
end

local function bindCommerce(gui)
 if not gui:IsA("ScreenGui") then return end
 local panel=gui:WaitForChild("Panel",10)
 if not panel then return end
 local function sync()
  if panel.Visible and gui.Enabled then enterFocus(gui,panel) else leaveFocus() end
 end
 panel:GetPropertyChangedSignal("Visible"):Connect(sync)
 gui:GetPropertyChangedSignal("Enabled"):Connect(sync)
 sync()

 local function refit()
  if focusActive and panel.Visible then fitPanel(gui,panel) end
 end
 if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(refit) end
 workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
  camera=workspace.CurrentCamera
  if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(refit) end
  task.defer(refit)
 end)
end

local existing=pg:FindFirstChild(COMMERCE_GUI_NAME)
if existing then task.defer(bindCommerce,existing) end
pg.ChildAdded:Connect(function(g)
 if g.Name==COMMERCE_GUI_NAME then task.defer(bindCommerce,g) end
end)

player.CharacterAdded:Connect(function()
 task.defer(function()
  local gui=pg:FindFirstChild(COMMERCE_GUI_NAME)
  local panel=gui and gui:FindFirstChild("Panel")
  if gui and panel and panel.Visible then enterFocus(gui,panel) end
 end)
end)

print("[BBYA] Mall Catalog Focus Mode v1 online: BBYA UI hidden while catalog open; Roblox CoreGui preserved")
