-- BBYA SOCIAL HUB — DJ LIVE COMMAND MENU BRIDGE v6
-- One visible DJ LIVE launcher: BBYACommandMenuUI.
-- Strict DJ-role visibility. Opens only BBYADJLiveCleanUI / DJLivePanel.
-- Legacy Developer DJ UI/fallback launcher is retired from player view.
-- Music Suite / audio / playlists / venue routing are untouched here.

local Players=game:GetService("Players")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

for _,name in ipairs({"BBYADJLiveReadinessBridgeV5","BBYADJLiveCommandMenuBridgeV6"}) do
 local old=pg:FindFirstChild(name);if old then old:Destroy() end
end
local marker=Instance.new("ScreenGui")
marker.Name="BBYADJLiveCommandMenuBridgeV6";marker.ResetOnSpawn=false;marker.IgnoreGuiInset=true;marker.DisplayOrder=1;marker.Parent=pg
marker:SetAttribute("LauncherAuthority","COMMAND_MENU_ONLY")
marker:SetAttribute("RoleRequired","DJ")

local panelBound=setmetatable({}, {__mode="k"})
local launcherBound=setmetatable({}, {__mode="k"})

local function hasDJRole()
 return player:GetAttribute("BBYAHasDJRole")==true and player:GetAttribute("BBYAManagedRole")=="DJ"
end
local function commandMenu()return pg:FindFirstChild("BBYACommandMenuUI")end
local function menuParts()
 local menu=commandMenu();if not menu then return nil,nil,nil end
 local drawer=menu:FindFirstChild("FeatureDrawer",true)
 local menuButton=menu:FindFirstChild("MenuButton",true)
 local list=drawer and drawer:FindFirstChild("FeatureList",true)
 return drawer,menuButton,list
end
local function cleanPanel()
 local g=pg:FindFirstChild("BBYADJLiveCleanUI")
 local p=g and g:FindFirstChild("DJLivePanel",true)
 return p and p:IsA("GuiObject") and p or nil
end
local function mainDJButton()
 local _,_,list=menuParts();if not list then return nil end
 for _,d in ipairs(list:GetDescendants()) do
  if d:IsA("TextButton") then
   local t=string.upper(tostring(d.Text or ""))
   if t=="DJ LIVE" or t:find("DJ LIVE",1,true)==1 then return d end
  end
 end
end
local function retireLegacyDJ()
 local legacy=pg:FindFirstChild("BBYADeveloperDJUI")
 if not legacy then return end
 if legacy:IsA("ScreenGui") then legacy.Enabled=false;legacy:SetAttribute("BBYARetiredByCleanDJV2",true) end
 for _,d in ipairs(legacy:GetDescendants()) do
  if d:IsA("GuiObject") and (d.Name=="FallbackDJButton" or d.Name=="DeveloperDJMixerPanel") then d.Visible=false end
  if d:IsA("GuiButton") and d.Name=="FallbackDJButton" then d.Active=false;d.AutoButtonColor=false;d.Selectable=false;pcall(function()d.Interactable=false end) end
 end
end
local function setMenuVisible(visible)
 local drawer,menuButton=menuParts()
 if not visible and drawer and drawer:IsA("GuiObject") then drawer.Visible=false end
 if menuButton and menuButton:IsA("GuiObject") then menuButton.Visible=visible end
end
local function setLauncherState(button,panel)
 if not button or not button.Parent then return end
 local role=hasDJRole();local ready=role and panel~=nil
 button.Visible=role
 button.Active=ready;button.Selectable=ready;button.AutoButtonColor=ready
 pcall(function()button.Interactable=ready end)
 button.Text=ready and "DJ LIVE" or "DJ LIVE • LOADING"
 button.TextTransparency=ready and 0 or .18
 button:SetAttribute("BBYADJConsoleReady",ready)
 button:SetAttribute("BBYADJRoleVisible",role)
 button:SetAttribute("BBYADJLauncherAuthority","COMMAND_MENU_CLEAN_V2")
end
local function bindPanel(panel)
 if not panel or panelBound[panel] then return end;panelBound[panel]=true
 panel:GetPropertyChangedSignal("Visible"):Connect(function()
  if panel.Visible then setMenuVisible(false) else setMenuVisible(true) end
 end)
end
local function bindLauncher(button)
 if not button or launcherBound[button] then return end;launcherBound[button]=true
 button.Activated:Connect(function()
  if not hasDJRole() then return end
  local panel=cleanPanel();if not panel then return end
  local drawer=select(1,menuParts());if drawer and drawer:IsA("GuiObject") then drawer.Visible=false end
  panel.Visible=true;setMenuVisible(false)
 end)
end
local function rescan()
 retireLegacyDJ()
 local panel=cleanPanel();local button=mainDJButton()
 if panel then bindPanel(panel) end
 if button then bindLauncher(button);setLauncherState(button,panel) end
 if panel and not hasDJRole() and panel.Visible then panel.Visible=false end
end

player:GetAttributeChangedSignal("BBYAHasDJRole"):Connect(rescan)
player:GetAttributeChangedSignal("BBYAManagedRole"):Connect(rescan)
pg.DescendantAdded:Connect(function(desc)
 if desc.Name=="BBYACommandMenuUI" or desc.Name=="FeatureDrawer" or desc.Name=="FeatureList" or desc.Name=="BBYADJLiveCleanUI" or desc.Name=="DJLivePanel" or desc.Name=="BBYADeveloperDJUI" or (desc:IsA("TextButton") and string.find(string.upper(tostring(desc.Text or "")),"DJ LIVE",1,true)) then task.defer(rescan) end
end)
pg.DescendantRemoving:Connect(function(desc)if desc.Name=="DJLivePanel" or desc.Name=="BBYADJLiveCleanUI" then task.defer(rescan) end end)

task.spawn(function()
 local deadline=os.clock()+35
 repeat rescan();task.wait(.20) until os.clock()>=deadline
end)
task.defer(rescan)

print("[BBYA] DJ LIVE command-menu bridge v6 online: DJ-only + clean console + legacy UI retired")
