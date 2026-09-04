-- BBYA SOCIAL HUB — MUSIC + DJ LAUNCHER ADAPTER v4.1
-- UI/NAVIGATION ONLY. Does not resize panels, change playlists, route audio, or own playback.
-- MUSIC replaces only the launcher button in-place so navigation can transition atomically.
-- BBYAMusicSuiteV1 remains the premium Music Suite authority and owns the real open path.
-- DJ adopts the native Developer DJ launcher and removes the kernel duplicate.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local boundDJ=false
local boundMusicButtons=setmetatable({}, {__mode="k"})
local watchedMenus=setmetatable({}, {__mode="k"})
local suiteRecoveryBound=setmetatable({}, {__mode="k"})
local musicRequestToken=0
local bindMusic

local function findMenu()
 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 if not menu then return nil end
 local list=menu:FindFirstChild("FeatureList",true)
 local drawer=menu:FindFirstChild("FeatureDrawer",true)
 local menuButton=menu:FindFirstChild("MenuButton",true)
 return menu,list,drawer,menuButton
end

local function findMusicButton(list)
 if not list then return nil end
 local slot=list:FindFirstChild("Slot_MUSIC")
 if slot then
  for _,o in ipairs(slot:GetDescendants()) do
   if o:IsA("TextButton") then return o end
  end
 end
 -- Backward-compatible fallback for an older direct FeatureList button.
 for _,o in ipairs(list:GetDescendants()) do
  if o:IsA("TextButton") and string.upper(tostring(o.Text or ""))=="MUSIC" then
   return o
  end
 end
 return nil
end

local function legacyOpenParts()
 local club=pg:FindFirstChild("BBYAClubUI")
 local hub=club and club:FindFirstChild("HubPanel",true)
 local playerCard=hub and hub:FindFirstChild("PlayerCard",true)
 local legacy=playerCard and playerCard.Parent
 return legacy,hub
end

local function restoreNavigation(reopenDrawer)
 local _,_,drawer,menuButton=findMenu()
 if menuButton and menuButton.Parent then
  menuButton.Visible=true
  menuButton.Text="MENU"
 end
 if reopenDrawer and drawer and drawer.Parent then
  drawer.Visible=true
 end
end

local function bindSuiteRecovery(suite)
 if not suite or not suite:IsA("ScreenGui") or suiteRecoveryBound[suite] then return end
 suiteRecoveryBound[suite]=true
 suite:GetPropertyChangedSignal("Enabled"):Connect(function()
  if not suite.Enabled and suite:GetAttribute("BBYAMusicAtomicTransitionV2")==true then
   suite:SetAttribute("BBYAMusicAtomicTransitionV2",false)
   restoreNavigation(false)
  end
 end)
end

local function commitMusicTransition(suite)
 if not suite or not suite:IsA("ScreenGui") or not suite.Enabled then return false end
 bindSuiteRecovery(suite)
 suite:SetAttribute("BBYAMusicAtomicTransitionV2",true)
 local _,_,drawer,menuButton=findMenu()
 if drawer and drawer.Parent then drawer.Visible=false end
 if menuButton and menuButton.Parent then
  menuButton.Text="MENU"
  menuButton.Visible=false
 end
 return true
end

local function triggerExistingMusicOpenPath()
 local suite=pg:FindFirstChild("BBYAMusicSuiteV1")
 if not suite or not suite:IsA("ScreenGui") then return false,nil end
 bindSuiteRecovery(suite)
 if suite.Enabled then return true,suite end

 -- 103-music-ui-final.client.lua owns open(). Its established compatibility
 -- bridge listens for the legacy music container becoming visible. We retry
 -- that bridge only while navigation remains available; no direct purchase,
 -- audio, playlist, or server behavior is touched here.
 local legacy=legacyOpenParts()
 if legacy and legacy:IsA("GuiObject") then
  if legacy.Visible then legacy.Visible=false end
  legacy.Visible=true
  task.wait(0.06)
  if suite.Parent and suite.Enabled then return true,suite end
  if legacy.Parent and legacy.Visible then legacy.Visible=false end
 end
 return suite.Parent and suite.Enabled,suite
end

local function requestMusicOpen()
 musicRequestToken+=1
 local token=musicRequestToken
 local _,_,drawer=findMenu()
 local reopenDrawer=drawer and drawer.Visible==true

 -- Never hide MENU/ROLES here. The retry runs off-thread; transition commits
 -- only after BBYAMusicSuiteV1.Enabled is confirmed true.
 task.spawn(function()
  local deadline=os.clock()+45
  while token==musicRequestToken and os.clock()<deadline do
   local suite=pg:FindFirstChild("BBYAMusicSuiteV1")
   if suite and suite:IsA("ScreenGui") and suite.Enabled then
    commitMusicTransition(suite)
    return
   end

   -- If the player intentionally left the drawer for another feature while
   -- MUSIC was still loading, cancel this pending request instead of popping
   -- Music later over the new destination.
   local _,_,currentDrawer,currentMenuButton=findMenu()
   if currentMenuButton and currentMenuButton.Visible==false then
    restoreNavigation(false)
    return
   end
   if reopenDrawer and currentDrawer and currentDrawer.Visible==false then
    return
   end

   local opened,resolvedSuite=triggerExistingMusicOpenPath()
   if opened and resolvedSuite then
    commitMusicTransition(resolvedSuite)
    return
   end

   -- Fail-open recovery: if the target is not ready, preserve the exact
   -- current navigation instead of leaving MENU and ROLES stranded.
   restoreNavigation(reopenDrawer)
   task.wait(0.20)
  end

  if token==musicRequestToken then restoreNavigation(reopenDrawer) end
 end)
end

local function makeAtomicMusicButton(list)
 local old=findMusicButton(list)
 if not old then return nil end
 if old:GetAttribute("BBYAMusicAtomicNavV2")==true then return old end

 -- The UI Kernel's original MUSIC button has an unconditional hide callback.
 -- Disable it immediately, then clone it in-place. Roblox event connections are
 -- not cloned, so the old hide-first callback is retired without duplicating UI.
 old.Active=false
 old.Selectable=false
 local parent=old.Parent
 if not parent then return nil end
 local replacement=old:Clone()
 replacement:SetAttribute("BBYAMusicAtomicNavV2",true)
 replacement:SetAttribute("BBYAMusicSuiteAdapterV4",true)
 replacement.Active=true
 replacement.Selectable=true
 replacement.Parent=parent
 old:Destroy()
 return replacement
end

bindMusic=function()
 local menu,list=findMenu()
 if not menu or not list then return false end
 local musicButton=makeAtomicMusicButton(list)
 if not musicButton then return false end
 -- Safety after any menu rebuild/DescendantAdded sequence.
 musicButton.Active=true
 musicButton.Selectable=true
 if boundMusicButtons[musicButton] then return true end
 boundMusicButtons[musicButton]=true
 musicButton.Activated:Connect(requestMusicOpen)
 print("[BBYA] Music launcher adapter v4.1 atomic button bound through Slot_MUSIC")
 return true
end

local function watchMenu(menu)
 if not menu or watchedMenus[menu] then return end
 watchedMenus[menu]=true
 menu.DescendantAdded:Connect(function(desc)
  if desc:IsA("TextButton") and desc.Parent and desc.Parent.Name=="Slot_MUSIC"
   and desc:GetAttribute("BBYAMusicAtomicNavV2")~=true then
   -- Close the tiny startup race before the kernel can expose a clickable
   -- hide-first MUSIC button. Styling finishes in the same frame; replacement
   -- happens deferred immediately after.
   desc.Active=false
   desc.Selectable=false
   task.defer(bindMusic)
  end
 end)
end

local function bindDJ()
 if boundDJ then return true end
 local menu,list,drawer,menuButton=findMenu()
 local dj=pg:FindFirstChild("BBYADeveloperDJUI")
 if not menu or not list or not dj then return false end
 local panel=dj:FindFirstChild("DeveloperDJMixerPanel",true)
 local native=dj:FindFirstChild("FallbackDJButton",true) or dj:FindFirstChild("DeveloperDJMenuButton",true)
 if not panel or not native or not native:IsA("TextButton") then return false end

 -- Kernel v2 accidentally created its own DJ LIVE entry while the Developer DJ
 -- client already owns a launcher. Remove only those duplicate list buttons.
 for _,o in ipairs(list:GetChildren()) do
  if o:IsA("TextButton") and o~=native and string.upper(tostring(o.Text or ""))=="DJ LIVE" then
   o:Destroy()
  end
 end

 boundDJ=true
 native.Parent=list
 native.LayoutOrder=9
 native.AnchorPoint=Vector2.new(0,0)
 native.Position=UDim2.new()
 native.Size=UDim2.new(1,-4,0,44)
 native.BackgroundColor3=Color3.fromRGB(29,29,39)
 native.BackgroundTransparency=0
 native.Text="DJ LIVE"
 native.TextColor3=Color3.fromRGB(246,246,249)
 native.Font=Enum.Font.GothamBold
 native.TextSize=10
 native.ZIndex=204
 local oldCorner=native:FindFirstChildOfClass("UICorner")
 if not oldCorner then local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,9);c.Parent=native end

 native.Activated:Connect(function()
  if drawer then drawer.Visible=false end
  if menuButton then menuButton.Text="MENU" end
 end)
 panel:GetPropertyChangedSignal("Visible"):Connect(function()
  if menuButton then menuButton.Visible=not panel.Visible end
  if panel.Visible and drawer then drawer.Visible=false end
 end)
 if menuButton then menuButton.Visible=not panel.Visible end
 print("[BBYA] Single native DJ launcher adopted; duplicate removed")
 return true
end

local function attach()
 local menu=findMenu()
 if menu then watchMenu(menu) end
 local a=bindMusic()
 local b=bindDJ()
 return a and b
end

task.defer(attach)
for i=1,12 do task.delay(i*.25,attach) end
pg.ChildAdded:Connect(function(child)
 if child.Name=="BBYACommandMenuUI" then
  watchMenu(child)
  task.defer(attach)
 elseif child.Name=="BBYADeveloperDJUI" or child.Name=="BBYAMusicSuiteV1" then
  task.defer(attach)
 end
end)