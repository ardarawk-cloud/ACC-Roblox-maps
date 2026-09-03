-- BBYA SOCIAL HUB — MUSIC + DJ LAUNCHER ADAPTER v3
-- UI/NAVIGATION ONLY. Does not resize panels, change playlists, route audio, or own playback.
-- MUSIC bridges UI Kernel Slot_MUSIC into the existing premium Music Suite open path.
-- DJ adopts the native Developer DJ launcher and removes the kernel duplicate.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local boundDJ=false
local boundMusic=false

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
 -- UI Kernel v2 wraps MUSIC inside Slot_MUSIC. The old adapter searched only
 -- direct FeatureList children, so it never saw the actual TextButton.
 local slot=list:FindFirstChild("Slot_MUSIC")
 local root=slot or list
 for _,o in ipairs(root:GetDescendants()) do
  if o:IsA("TextButton") and string.upper(tostring(o.Text or ""))=="MUSIC" then
   return o
  end
 end
 return nil
end

local function bindMusic()
 if boundMusic then return true end
 local menu,list=findMenu()
 if not menu or not list then return false end
 local musicButton=findMusicButton(list)
 if not musicButton then return false end
 boundMusic=true
 musicButton:SetAttribute("BBYAMusicSuiteAdapterV3",true)
 musicButton.Activated:Connect(function()
  task.defer(function()
   local suite=pg:FindFirstChild("BBYAMusicSuiteV1")
   local club=pg:FindFirstChild("BBYAClubUI")
   local hub=club and club:FindFirstChild("HubPanel",true)
   local playerCard=hub and hub:FindFirstChild("PlayerCard",true)
   local legacy=playerCard and playerCard.Parent
   -- 103-music-ui-final.client.lua owns the real open() path and listens for
   -- this legacy container becoming visible. Trigger that established UI-only
   -- contract so request/refresh/switch logic remains owned by Music Suite.
   if legacy and legacy:IsA("GuiObject") then
    if legacy.Visible then legacy.Visible=false end
    legacy.Visible=true
   elseif suite and suite:IsA("ScreenGui") then
    -- Fail-soft visual fallback only. Normal path above is expected in BBYA.
    suite.Enabled=true
    if hub then hub.Visible=false end
   end
  end)
 end)
 print("[BBYA] Music launcher adapter v3 bound through Slot_MUSIC")
 return true
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
 local a=bindMusic()
 local b=bindDJ()
 return a and b
end

task.defer(attach)
for i=1,12 do task.delay(i*.25,attach) end
pg.ChildAdded:Connect(function(child)
 if child.Name=="BBYACommandMenuUI" or child.Name=="BBYADeveloperDJUI" or child.Name=="BBYAMusicSuiteV1" then
  task.defer(attach)
 end
end)