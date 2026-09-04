-- BBYA SOCIAL HUB — MUSIC + DJ LAUNCHER ADAPTER v4
-- UI/NAVIGATION ONLY. Does not resize panels, change playlists, route audio, or own playback.
-- MUSIC bridges UI Kernel Slot_MUSIC into the existing premium Music Suite open path.
-- DJ adopts the authorized native Developer DJ launcher, survives late UI creation,
-- and removes the stale UI Kernel DJ fallback / empty legacy slot.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local boundDJ=nil
local boundMusic=nil

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
 local root=slot or list
 for _,o in ipairs(root:GetDescendants()) do
  if o:IsA("TextButton") and string.upper(tostring(o.Text or ""))=="MUSIC" then
   return o
  end
 end
 return nil
end

local function bindMusic()
 if boundMusic and boundMusic.Parent then return true end
 boundMusic=nil
 local menu,list=findMenu()
 if not menu or not list then return false end
 local musicButton=findMusicButton(list)
 if not musicButton then return false end
 boundMusic=musicButton
 musicButton:SetAttribute("BBYAMusicSuiteAdapterV4",true)
 musicButton.Activated:Connect(function()
  task.defer(function()
   local suite=pg:FindFirstChild("BBYAMusicSuiteV1")
   local club=pg:FindFirstChild("BBYAClubUI")
   local hub=club and club:FindFirstChild("HubPanel",true)
   local playerCard=hub and hub:FindFirstChild("PlayerCard",true)
   local legacy=playerCard and playerCard.Parent
   if legacy and legacy:IsA("GuiObject") then
    if legacy.Visible then legacy.Visible=false end
    legacy.Visible=true
   elseif suite and suite:IsA("ScreenGui") then
    suite.Enabled=true
    if hub then hub.Visible=false end
   end
  end)
 end)
 print("[BBYA] Music launcher adapter v4 bound through Slot_MUSIC")
 return true
end

local function removeStaleDJEntries(list,native,oldParent)
 if not list then return end
 -- Native v3 creates Slot_DJ_LIVE first. Once its real button has been adopted,
 -- the now-empty wrapper must go or UIListLayout still reserves a blank row.
 if oldParent and oldParent~=list and oldParent.Parent==list and oldParent.Name=="Slot_DJ_LIVE" then
  oldParent:Destroy()
 end
 for _,o in ipairs(list:GetChildren()) do
  if o~=native then
   if o:IsA("TextButton") and string.upper(tostring(o.Text or ""))=="DJ LIVE" then
    -- UI Kernel v2 fallback. Its callback can only emit DJ LIVE NOT AVAILABLE
    -- when the native developer console wins the load race later.
    o:Destroy()
   elseif o:IsA("GuiObject") and o.Name=="Slot_DJ_LIVE" then
    local real=o:FindFirstChild("DeveloperDJMenuButton",true) or o:FindFirstChild("FallbackDJButton",true)
    if not real then o:Destroy() end
   end
  end
 end
end

local function bindDJ()
 if boundDJ and boundDJ.Parent then return true end
 boundDJ=nil
 local menu,list,drawer,menuButton=findMenu()
 local dj=pg:FindFirstChild("BBYADeveloperDJUI")
 if not menu or not list or not dj then return false end
 local panel=dj:FindFirstChild("DeveloperDJMixerPanel",true)
 local native=dj:FindFirstChild("FallbackDJButton",true) or dj:FindFirstChild("DeveloperDJMenuButton",true)
 if not native then
  -- The authorized client normally creates DeveloperDJMenuButton under
  -- BBYACommandMenuUI rather than BBYADeveloperDJUI.
  native=menu:FindFirstChild("DeveloperDJMenuButton",true)
 end
 if not panel or not native or not native:IsA("TextButton") then return false end

 local oldParent=native.Parent
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
 native.Visible=true
 native.Active=true
 native.Selectable=true
 native.AutoButtonColor=true
 native:SetAttribute("BBYACompactDJAdapterV4",true)
 local oldCorner=native:FindFirstChildOfClass("UICorner")
 if not oldCorner then local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,9);c.Parent=native end
 removeStaleDJEntries(list,native,oldParent)

 boundDJ=native
 native.Activated:Connect(function()
  if drawer then drawer.Visible=false end
  if menuButton then menuButton.Text="MENU" end
 end)
 panel:GetPropertyChangedSignal("Visible"):Connect(function()
  if menuButton then menuButton.Visible=not panel.Visible end
  if panel.Visible and drawer then drawer.Visible=false end
 end)
 if menuButton then menuButton.Visible=not panel.Visible end
 print("[BBYA] Native DJ launcher adapter v4 bound; stale fallback and empty slot removed")
 return true
end

local function attach()
 local a=bindMusic()
 local b=bindDJ()
 return a and b
end

task.defer(attach)
-- Cover normal startup as well as slower RemoteFunction authorization / mobile load.
task.spawn(function()
 for _=1,60 do
  if attach() then return end
  task.wait(.5)
 end
end)

-- v3 listened only to PlayerGui.ChildAdded. BBYADeveloperDJUI is parented before
-- its panel/menu button are created, so that callback could fire too early and
-- never run again. DescendantAdded closes that race deterministically.
pg.DescendantAdded:Connect(function(obj)
 local n=obj.Name
 if n=="BBYACommandMenuUI" or n=="FeatureList" or n=="Slot_MUSIC" or n=="BBYAMusicSuiteV1"
  or n=="BBYADeveloperDJUI" or n=="DeveloperDJMixerPanel" or n=="DeveloperDJMenuButton" or n=="FallbackDJButton" then
  task.defer(attach)
 end
end)

pg.DescendantRemoving:Connect(function(obj)
 if obj==boundDJ then boundDJ=nil end
 if obj==boundMusic then boundMusic=nil end
end)