-- BBYA SOCIAL HUB — CORE GUI SAFE FOCUS MODE v2
-- Final mobile-safe placement authority while Mall or Travel is open.
-- Keeps Roblox CoreGui visible, pushes BBYA panels below the Roblox top controls,
-- and temporarily hides other BBYA ScreenGuis (including MENU / ROLES).
-- Test candidate only until owner acceptance.

local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local COMMERCE_GUI_NAME="BBYAMallRobuxCommerceUI"
local CLUB_GUI_NAME="BBYAClubUI"
local RENDER_BIND="BBYACoreGuiSafeFocusV2"
local TOP_SAFE_TOUCH=126
local TOP_SAFE_DESKTOP=88
local BOTTOM_SAFE=18
local SIDE_SAFE=18

local activeMode=nil
local activeGui=nil
local activePanel=nil
local savedEnabled={}
local enabledGuards={}
local childConn=nil
local camera=workspace.CurrentCamera
local applying=false

local function topSafe()
 return UserInputService.TouchEnabled and TOP_SAFE_TOUCH or TOP_SAFE_DESKTOP
end

local function disconnectGuards()
 for g,c in pairs(enabledGuards) do
  if c then c:Disconnect() end
  enabledGuards[g]=nil
 end
end

local function hideOtherGui(g)
 if not activeMode or not g:IsA("ScreenGui") or g==activeGui then return end
 if savedEnabled[g]==nil then savedEnabled[g]=g.Enabled end
 if g.Enabled then g.Enabled=false end
 if not enabledGuards[g] then
  enabledGuards[g]=g:GetPropertyChangedSignal("Enabled"):Connect(function()
   if activeMode and g~=activeGui and g.Parent and g.Enabled then
    g.Enabled=false
   end
  end)
 end
end

local function hideAllOtherGuis()
 for _,g in ipairs(pg:GetChildren()) do hideOtherGui(g) end
end

local function restoreAll()
 disconnectGuards()
 for g,wasEnabled in pairs(savedEnabled) do
  if g and g.Parent then g.Enabled=wasEnabled end
 end
 table.clear(savedEnabled)
end

local function viewport()
 camera=workspace.CurrentCamera or camera
 return (camera and camera.ViewportSize) or Vector2.new(1280,720)
end

local function setFrame(frame,anchor,pos,size)
 if frame.AnchorPoint~=anchor then frame.AnchorPoint=anchor end
 if frame.Position~=pos then frame.Position=pos end
 if frame.Size~=size then frame.Size=size end
end

local function fitMall(gui,panel)
 if not gui or not panel then return end
 local vp=viewport()
 local top=topSafe()
 local maxW=math.max(300,vp.X-(SIDE_SAFE*2))
 local maxH=math.max(220,vp.Y-top-BOTTOM_SAFE)
 local desiredW=math.clamp(math.floor(vp.X*(UserInputService.TouchEnabled and .70 or .68)),620,920)
 local desiredH=math.clamp(math.floor(vp.Y*(UserInputService.TouchEnabled and .58 or .56)),320,470)
 local w=math.min(desiredW,maxW)
 local h=math.min(desiredH,maxH)
 gui.IgnoreGuiInset=true
 setFrame(panel,Vector2.new(.5,0),UDim2.fromOffset(math.floor(vp.X/2),top),UDim2.fromOffset(w,h))
 panel:SetAttribute("BBYACoreGuiSafeArea","MALL_V2")
end

local function fitTravel(gui,panel)
 if not gui or not panel then return end
 local vp=viewport()
 local top=topSafe()
 local maxW=math.max(300,vp.X-(SIDE_SAFE*2))
 local maxH=math.max(220,vp.Y-top-BOTTOM_SAFE)
 local desiredW=math.clamp(math.floor(vp.X*(UserInputService.TouchEnabled and .72 or .68)),620,1080)
 local desiredH=math.clamp(math.floor(vp.Y*(UserInputService.TouchEnabled and .66 or .62)),320,470)
 local w=math.min(desiredW,maxW)
 local h=math.min(desiredH,maxH)
 gui.IgnoreGuiInset=true
 setFrame(panel,Vector2.new(.5,0),UDim2.fromOffset(math.floor(vp.X/2),top),UDim2.fromOffset(w,h))
 panel:SetAttribute("BBYACoreGuiSafeArea","TRAVEL_V2")
end

local function applySafeLayout()
 if applying or not activeMode or not activeGui or not activePanel then return end
 applying=true
 if activeMode=="MALL" then fitMall(activeGui,activePanel) else fitTravel(activeGui,activePanel) end
 hideAllOtherGuis()
 applying=false
end

local function findTravelState()
 local gui=pg:FindFirstChild(CLUB_GUI_NAME)
 local hub=gui and gui:FindFirstChild("HubPanel")
 if not gui or not hub then return nil end
 local travel=nil
 local scroller=hub:FindFirstChild("TravelDestinationScroller",true)
 if scroller then travel=scroller.Parent end
 if not travel then
  for _,d in ipairs(hub:GetDescendants()) do
   if d:IsA("TextLabel") and d.Text=="MOVE THROUGH BBYA" then travel=d.Parent;break end
  end
 end
 if travel and travel.Visible and hub.Visible and gui.Enabled then return gui,hub end
 return nil
end

local function findMallState()
 local gui=pg:FindFirstChild(COMMERCE_GUI_NAME)
 local panel=gui and gui:FindFirstChild("Panel")
 if gui and panel and gui.Enabled and panel.Visible then return gui,panel end
 return nil
end

local function stopFocus()
 if not activeMode then return end
 RunService:UnbindFromRenderStep(RENDER_BIND)
 if childConn then childConn:Disconnect();childConn=nil end
 activeMode=nil;activeGui=nil;activePanel=nil
 restoreAll()
 player:SetAttribute("BBYACoreGuiSafeFocus",false)
 player:SetAttribute("BBYAMallCatalogFocusMode",false)
end

local function startFocus(mode,gui,panel)
 if activeMode==mode and activeGui==gui and activePanel==panel then
  applySafeLayout();return
 end
 if activeMode then stopFocus() end
 activeMode=mode;activeGui=gui;activePanel=panel
 if savedEnabled[gui]~=nil then savedEnabled[gui]=nil end
 gui.Enabled=true
 hideAllOtherGuis()
 childConn=pg.ChildAdded:Connect(function(g)
  task.defer(function()hideOtherGui(g)end)
 end)
 RunService:BindToRenderStep(RENDER_BIND,Enum.RenderPriority.Last.Value,function()
  if activeMode then applySafeLayout() end
 end)
 player:SetAttribute("BBYACoreGuiSafeFocus",mode)
 player:SetAttribute("BBYAMallCatalogFocusMode",mode=="MALL")
 applySafeLayout()
end

local function reconcile()
 local mallGui,mallPanel=findMallState()
 if mallGui then startFocus("MALL",mallGui,mallPanel);return end
 local travelGui,travelPanel=findTravelState()
 if travelGui then startFocus("TRAVEL",travelGui,travelPanel);return end
 stopFocus()
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
 camera=workspace.CurrentCamera
 task.defer(reconcile)
end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(applySafeLayout)end) end
pg.ChildAdded:Connect(function()task.defer(reconcile);task.delay(.05,reconcile)end)

player.CharacterAdded:Connect(function()task.delay(.35,reconcile)end)

task.spawn(function()
 while script.Parent do
  reconcile()
  task.wait(.12)
 end
end)

print("[BBYA] CoreGui Safe Focus v2 online: Mall + Travel below Roblox controls; BBYA MENU/ROLES hidden while focused")
