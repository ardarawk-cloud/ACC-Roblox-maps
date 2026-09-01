-- BBYA MUSIC UI TEST — COMPACT SECONDARY PANELS v5
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- Mobile-landscape experiment:
-- * MUSIC / MESSAGE / COMMUNITY (COMM) keep their large geometry.
-- * Every other content panel, including the main command menu, uses the same slim right-side size as DANCE/CARRY.
-- * Main command-menu choices use vertical swipe/scroll.
-- * All panels use a transparent/glass background so the game world remains visible behind the UI.
-- * Decorative equalizer / waveform visualizers are hidden.
-- * The redundant BBYA dock button is hidden; MUSIC remains the explicit music launcher.
-- Dance catalog stays owned by 92-freecam + direct scroll host v6.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera

local compacted=setmetatable({}, {__mode="k"})
local hubOriginal=setmetatable({}, {__mode="k"})
local menuHosts=setmetatable({}, {__mode="k"})

local function lower(v)return string.lower(tostring(v or "")) end

local function exemptName(name)
 local n=lower(name)
 if string.find(n,"music",1,true) then return true end
 if string.find(n,"message",1,true) then return true end
 if string.find(n,"community",1,true) then return true end
 -- COMM is an explicit panel alias only. Do not treat "command" as COMM.
 if n=="comm" or n=="commpanel" or n=="commframe" or n=="commwindow" then return true end
 if string.match(n,"^comm[_%-]") or string.match(n,"[_%-]comm$") then return true end
 return false
end

local function hasExemptToken(obj)
 if exemptName(obj.Name) then return true end
 local p=obj.Parent
 for _=1,4 do
  if not p then break end
  if exemptName(p.Name) then return true end
  p=p.Parent
 end
 return false
end

local function viewport()
 camera=workspace.CurrentCamera or camera
 return camera and camera.ViewportSize or Vector2.new(1280,720)
end

local function compactSize()
 local vp=viewport()
 local w=math.clamp(math.floor(vp.X*.17),210,240)
 local h=math.clamp(vp.Y-42,340,620)
 return w,h
end

local function isLargeBackdrop(obj,panel)
 if not obj:IsA("GuiObject") or obj==panel then return false end
 local a=obj.AbsoluteSize
 local p=panel.AbsoluteSize
 if p.X<=0 or p.Y<=0 then return false end
 return a.X>=p.X*.70 and a.Y>=p.Y*.45
end

local function applyGlass(panel)
 if not panel or not panel:IsA("GuiObject") then return end
 -- Root panel: about half-transparent, enough contrast for text while preserving the world behind it.
 if panel:IsA("Frame") or panel:IsA("ScrollingFrame") then
  panel.BackgroundTransparency=math.max(panel.BackgroundTransparency,.42)
  panel:SetAttribute("BBYAGlassPanel","V5")
 end
 -- Remove the heavy black-card feeling from large inner backdrops, but keep buttons/cards readable.
 for _,d in ipairs(panel:GetDescendants()) do
  if (d:IsA("Frame") or d:IsA("ScrollingFrame")) and isLargeBackdrop(d,panel) then
   d.BackgroundTransparency=math.max(d.BackgroundTransparency,.52)
   d:SetAttribute("BBYAGlassBackdrop","V5")
  end
 end
end

local function compactPanel(panel,authority)
 if not panel or not panel:IsA("GuiObject") or hasExemptToken(panel) then return end
 local w,h=compactSize()
 panel.AnchorPoint=Vector2.new(1,.5)
 panel.Position=UDim2.new(1,-12,.5,0)
 panel.Size=UDim2.fromOffset(w,h)
 panel.ClipsDescendants=true
 applyGlass(panel)
 compacted[panel]=true
 panel:SetAttribute("BBYACompactSecondaryPanel",authority or "RIGHT_SLIM_V5")
end

local function titleMode(panel)
 for _,d in ipairs(panel:GetDescendants()) do
  if d:IsA("TextLabel") then
   local t=string.upper(d.Text or "")
   if t=="SUPPORT BBYA" or t=="TRAVEL" or string.find(t,"MOVE THROUGH BBYA",1,true) then return "compact" end
   if t=="MUSIC SYSTEM" or t=="LIBRARY" or t=="NOW PLAYING" then return "music" end
  end
 end
 return nil
end

local function saveHubGeometry(hub)
 if hubOriginal[hub] then return end
 hubOriginal[hub]={AnchorPoint=hub.AnchorPoint,Position=hub.Position,Size=hub.Size,ClipsDescendants=hub.ClipsDescendants}
end

local function restoreHub(hub)
 local s=hubOriginal[hub]
 if not s then return end
 hub.AnchorPoint=s.AnchorPoint
 hub.Position=s.Position
 hub.Size=s.Size
 hub.ClipsDescendants=s.ClipsDescendants
 hub:SetAttribute("BBYACompactSecondaryPanel",nil)
 applyGlass(hub)
end

local function patchHubPanel()
 local gui=pg:FindFirstChild("BBYAClubUI")
 local hub=gui and gui:FindFirstChild("HubPanel")
 if not hub then return end
 saveHubGeometry(hub)
 applyGlass(hub)
 local function apply()
  local mode=titleMode(hub)
  if mode=="compact" then compactPanel(hub,"SUPPORT_TRAVEL_RIGHT_SLIM_V5")
  elseif mode=="music" then restoreHub(hub) end
 end
 if not hub:GetAttribute("BBYACompactHubBoundV5") then
  hub:SetAttribute("BBYACompactHubBoundV5",true)
  for _,d in ipairs(hub:GetDescendants()) do
   if d:IsA("TextLabel") then d:GetPropertyChangedSignal("Text"):Connect(function()task.defer(apply)end) end
  end
  hub.DescendantAdded:Connect(function(d)
   if d:IsA("TextLabel") then d:GetPropertyChangedSignal("Text"):Connect(function()task.defer(apply)end) end
  end)
  hub:GetPropertyChangedSignal("Visible"):Connect(function()if hub.Visible then task.defer(apply)end end)
 end
 task.defer(apply)
end

local function looksLikeVisualizer(frame)
 if not frame:IsA("Frame") then return false end
 local n=lower(frame.Name)
 if string.find(n,"equalizer",1,true) or string.find(n,"visualizer",1,true) or n=="wave" or n=="eqholder" then return true end
 local total,bars=0,0
 for _,c in ipairs(frame:GetChildren()) do
  if c:IsA("Frame") then
   total+=1
   if c.AnchorPoint.Y>=.9 and c.Size.X.Scale>0 and c.Size.X.Scale<=.08 then bars+=1 end
  end
 end
 return total>=12 and bars>=math.floor(total*.75)
end

local function hideVisualizers(root)
 for _,d in ipairs(root:GetDescendants()) do
  if looksLikeVisualizer(d) then
   d.Visible=false
   d:SetAttribute("BBYAVisualizerHidden","V5")
  end
 end
end

local function hideRedundantBrandButton()
 local gui=pg:FindFirstChild("BBYAClubUI")
 local dock=gui and gui:FindFirstChild("TopDock")
 if not dock then return end
 for _,d in ipairs(dock:GetChildren()) do
  if d:IsA("TextButton") and string.upper(d.Text or "")=="BBYA" then
   d.Visible=false
   d.Active=false
   d.AutoButtonColor=false
   d:SetAttribute("BBYARedundantBrandButtonHidden","V5")
  end
 end
end

local function menuSlot(obj)
 return obj:IsA("GuiObject") and string.sub(obj.Name or "",1,5)=="Slot_"
end

local function ensureMenuScroll(drawer)
 if not drawer or not drawer:IsA("GuiObject") then return end
 compactPanel(drawer,"MAIN_MENU_RIGHT_SLIM_V5")
 applyGlass(drawer)

 local grid=drawer:FindFirstChildWhichIsA("UIGridLayout",true)
 local body=grid and grid.Parent
 if not body or not body:IsA("GuiObject") then return end

 local host=menuHosts[drawer]
 if not host or not host.Parent then
  for _,name in ipairs({"BBYAMainMenuScrollV4","BBYAMainMenuScrollV5"}) do local old=drawer:FindFirstChild(name);if old then old:Destroy() end end
  host=Instance.new("ScrollingFrame")
  host.Name="BBYAMainMenuScrollV5"
  host.Position=body.Position
  host.Size=body.Size
  host.BackgroundTransparency=1
  host.BorderSizePixel=0
  host.ScrollBarThickness=4
  host.ScrollBarImageColor3=Color3.fromRGB(244,48,149)
  host.ScrollingDirection=Enum.ScrollingDirection.Y
  host.ElasticBehavior=Enum.ElasticBehavior.WhenScrollable
  host.AutomaticCanvasSize=Enum.AutomaticSize.None
  host.CanvasSize=UDim2.new()
  host.Active=true
  host.ClipsDescendants=true
  host.ZIndex=math.max(body.ZIndex,202)
  host.Parent=drawer

  local gl=Instance.new("UIGridLayout")
  gl.Name="CompactMenuGridV5"
  gl.CellSize=UDim2.new(.48,-4,0,50)
  gl.CellPadding=UDim2.new(.04,0,0,8)
  gl.FillDirection=Enum.FillDirection.Horizontal
  gl.FillDirectionMaxCells=2
  gl.SortOrder=Enum.SortOrder.LayoutOrder
  gl.Parent=host
  gl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
   if host and host.Parent then host.CanvasSize=UDim2.fromOffset(0,math.max(0,gl.AbsoluteContentSize.Y+8)) end
  end)
  menuHosts[drawer]=host
 end

 local hostGrid=host:FindFirstChild("CompactMenuGridV5")
 local moved=0
 for _,d in ipairs(body:GetChildren()) do if menuSlot(d) then d.Parent=host;moved+=1 end end
 for _,d in ipairs(drawer:GetDescendants()) do if d.Parent~=host and menuSlot(d) then d.Parent=host;moved+=1 end end
 if hostGrid and hostGrid:IsA("UIGridLayout") then host.CanvasSize=UDim2.fromOffset(0,math.max(0,hostGrid.AbsoluteContentSize.Y+8)) end
 if moved>0 or #host:GetChildren()>1 then body.Visible=false;drawer:SetAttribute("BBYAMainMenuBrowseMode","SCROLL") end
end

local function patchCommandMenu()
 local gui=pg:FindFirstChild("BBYACommandMenuUI")
 local drawer=gui and gui:FindFirstChild("FeatureDrawer",true)
 if not drawer or not drawer:IsA("GuiObject") then return end
 ensureMenuScroll(drawer)
 if not drawer:GetAttribute("BBYAMainMenuScrollBoundV5") then
  drawer:SetAttribute("BBYAMainMenuScrollBoundV5",true)
  drawer:GetPropertyChangedSignal("Visible"):Connect(function()if drawer.Visible then task.defer(function()ensureMenuScroll(drawer)end) end end)
  drawer.DescendantAdded:Connect(function(d)if menuSlot(d) then task.defer(function()ensureMenuScroll(drawer)end) end end)
 end
end

local function looksLikeContentPanel(d)
 if not d:IsA("Frame") then return false end
 local n=lower(d.Name)
 if string.find(n,"panel",1,true) then return true end
 if d.Name=="FeatureDrawer" then return true end
 return false
end

local function patchNamedPanels(root)
 for _,d in ipairs(root:GetDescendants()) do
  if looksLikeContentPanel(d) then
   -- Transparency applies to ALL content panels, including the three large exceptions.
   applyGlass(d)
   if not hasExemptToken(d) and d.Name~="HubPanel" then
    local a=d.AbsoluteSize
    if d.Name=="DancePanel" or d.Name=="CarryPanel" or d.Name=="PartyStuffPanel" or d.Name=="FeatureDrawer" or a.X>=300 or a.Y>=300 then compactPanel(d) end
   end
  end
 end
end

local function patchDanceAuthority()
 local gui=pg:FindFirstChild("BBYASocialHangoutUI")
 local panel=gui and gui:FindFirstChild("DancePanel")
 if not panel then return end
 panel:SetAttribute("BBYADanceCanvasAuthority","CATALOG_92_PLUS_SCROLL_HOST_V6")
 panel:SetAttribute("BBYADanceBrowseMode","SCROLL")
 compactPanel(panel,"DANCE_RIGHT_SLIM_V5")
 local carry=gui:FindFirstChild("CarryPanel")
 if carry then compactPanel(carry,"CARRY_RIGHT_SLIM_V5") end
end

local function applyAll()
 for _,g in ipairs(pg:GetChildren()) do
  if g:IsA("ScreenGui") then patchNamedPanels(g);hideVisualizers(g) end
 end
 patchDanceAuthority()
 patchHubPanel()
 patchCommandMenu()
 hideRedundantBrandButton()
end

local scheduled=false
local function schedule()
 if scheduled then return end
 scheduled=true
 task.delay(.12,function()scheduled=false;applyAll()end)
end

pg.ChildAdded:Connect(schedule)
pg.DescendantAdded:Connect(function(d)if d:IsA("Frame") or d:IsA("TextButton") or d:IsA("TextLabel") then schedule() end end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
 camera=workspace.CurrentCamera
 if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(schedule) end
 schedule()
end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(schedule) end

for i=1,10 do task.delay(i*.35,schedule) end
task.defer(schedule)
print("[BBYA TEST] Compact panels v5 online: Dance/Carry size for all non Music/Message/Comm + scroll main menu + transparent glass panels + dance host v6")
