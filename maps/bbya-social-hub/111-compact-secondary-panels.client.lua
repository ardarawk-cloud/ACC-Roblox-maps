-- BBYA MUSIC UI TEST — COMPACT SECONDARY PANELS v3
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- Experiment requested for mobile landscape:
-- * MUSIC / MESSAGE / COMMUNITY stay large.
-- * Other panels become a slim right-side card so the avatar stays visible.
-- * Long catalog/menu content is expected to use vertical swipe/scroll.
-- * Decorative equalizer / waveform visualizers are hidden.
-- * The redundant BBYA dock button is hidden; MUSIC remains the explicit music launcher.
-- Dance list/canvas ownership stays with 92-freecam + the v5 direct scroll host.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera

local EXEMPT_TOKENS={"music","message","community","comm"}
local compacted=setmetatable({}, {__mode="k"})

local function lower(v)return string.lower(tostring(v or "")) end

local function hasExemptToken(obj)
 local s=lower(obj.Name)
 for _,t in ipairs(EXEMPT_TOKENS) do if string.find(s,t,1,true) then return true end end
 -- ScreenGui / ancestor names are also authoritative for explicit exceptions.
 local p=obj.Parent
 for _=1,4 do
  if not p then break end
  local n=lower(p.Name)
  for _,t in ipairs(EXEMPT_TOKENS) do if string.find(n,t,1,true) then return true end end
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

local function compactPanel(panel)
 if not panel or not panel:IsA("GuiObject") or hasExemptToken(panel) then return end
 if panel.Name=="HubPanel" then return end -- SUPPORT/TRAVEL handled by page title below.
 local w,h=compactSize()
 panel.AnchorPoint=Vector2.new(1,.5)
 panel.Position=UDim2.new(1,-12,.5,0)
 panel.Size=UDim2.fromOffset(w,h)
 panel.ClipsDescendants=true
 compacted[panel]=true
 panel:SetAttribute("BBYACompactSecondaryPanel","RIGHT_SLIM_V3")
end

local function titleMode(panel)
 for _,d in ipairs(panel:GetDescendants()) do
  if d:IsA("TextLabel") then
   local t=string.upper(d.Text or "")
   if t=="SUPPORT BBYA" or t=="TRAVEL" or string.find(t,"MOVE THROUGH BBYA",1,true) then return "compact" end
   if t=="MUSIC SYSTEM" then return "music" end
  end
 end
 return nil
end

local function patchHubPanel()
 local gui=pg:FindFirstChild("BBYAClubUI")
 local hub=gui and gui:FindFirstChild("HubPanel")
 if not hub then return end
 local function apply()
  local mode=titleMode(hub)
  if mode=="compact" then
   local w,h=compactSize()
   hub.AnchorPoint=Vector2.new(1,.5)
   hub.Position=UDim2.new(1,-12,.5,0)
   hub.Size=UDim2.fromOffset(w,h)
   hub.ClipsDescendants=true
   hub:SetAttribute("BBYACompactSecondaryPanel","SUPPORT_TRAVEL_RIGHT_SLIM_V3")
  end
 end
 for _,d in ipairs(hub:GetDescendants()) do
  if d:IsA("TextLabel") then d:GetPropertyChangedSignal("Text"):Connect(function()task.defer(apply)end) end
 end
 hub:GetPropertyChangedSignal("Visible"):Connect(function()if hub.Visible then task.defer(apply)end end)
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
   d:SetAttribute("BBYAVisualizerHidden","V3")
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
   d:SetAttribute("BBYARedundantBrandButtonHidden","V3")
  end
 end
end

local function patchNamedPanels(root)
 for _,d in ipairs(root:GetDescendants()) do
  if d:IsA("Frame") and string.find(lower(d.Name),"panel",1,true) and not hasExemptToken(d) then
   -- Only actual content panels: avoid tiny status/pill frames that merely happen to contain "panel".
   local a=d.AbsoluteSize
   if d.Name=="DancePanel" or d.Name=="CarryPanel" or d.Name=="PartyStuffPanel" or a.X>=300 or a.Y>=300 then
    compactPanel(d)
   end
  end
 end
end

local function patchDanceAuthority()
 local gui=pg:FindFirstChild("BBYASocialHangoutUI")
 local panel=gui and gui:FindFirstChild("DancePanel")
 if not panel then return end
 panel:SetAttribute("BBYADanceCanvasAuthority","CATALOG_92_PLUS_SCROLL_HOST_V5")
 panel:SetAttribute("BBYADanceBrowseMode","SCROLL")
 compactPanel(panel)
 local carry=gui:FindFirstChild("CarryPanel")
 if carry then compactPanel(carry) end
end

local function applyAll()
 for _,g in ipairs(pg:GetChildren()) do
  if g:IsA("ScreenGui") then
   patchNamedPanels(g)
   hideVisualizers(g)
  end
 end
 patchDanceAuthority()
 patchHubPanel()
 hideRedundantBrandButton()
end

local scheduled=false
local function schedule()
 if scheduled then return end
 scheduled=true
 task.delay(.12,function()
  scheduled=false
  applyAll()
 end)
end

pg.ChildAdded:Connect(schedule)
pg.DescendantAdded:Connect(function(d)
 if d:IsA("Frame") or d:IsA("TextButton") or d:IsA("TextLabel") then schedule() end
end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
 camera=workspace.CurrentCamera
 if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(schedule) end
 schedule()
end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(schedule) end

for i=1,8 do task.delay(i*.35,schedule) end
task.defer(schedule)
print("[BBYA TEST] Compact secondary panels v3 online: right-side slim panels / scroll-first / visualizers hidden / redundant BBYA dock button hidden")