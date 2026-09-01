-- BBYA MUSIC UI TEST — SECONDARY PANEL VISUAL AUTHORITY v13
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- Dance itself is the visual reference and is NOT resized here.
-- Every secondary panel matches Dance Size + UIScale.
-- EXCEPTIONS: Music stays large/glass. Developer DJ is untouched/full-screen.
-- Party and Menu have their own single-purpose scripts but use the same Dance scale rule.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera

local MATCH_SCALE="BBYAMatchDanceScaleV13"

local function viewport()
 camera=workspace.CurrentCamera or camera
 return camera and camera.ViewportSize or Vector2.new(1280,720)
end
local function getDance()
 local gui=pg:FindFirstChild("BBYASocialHangoutUI")
 local dance=gui and gui:FindFirstChild("DancePanel")
 if not dance then return nil,1 end
 local s=dance:FindFirstChild("BBYAOwnerPanelScaleV7") or dance:FindFirstChildWhichIsA("UIScale")
 return dance,s and s.Scale or 1
end
local function ownScale(target,value)
 local s=target:FindFirstChild(MATCH_SCALE)
 if not s then s=Instance.new("UIScale");s.Name=MATCH_SCALE;s.Parent=target end
 s.Scale=value
end
local function clearOwnScale(target)
 local s=target and target:FindFirstChild(MATCH_SCALE)
 if s then s:Destroy() end
end
local function matchDance(target,tag)
 if not target or not target:IsA("GuiObject") then return end
 local dance,scale=getDance()
 if not dance then return end
 target.AnchorPoint=dance.AnchorPoint
 target.Position=dance.Position
 target.Size=dance.Size
 target.ClipsDescendants=true
 -- Carry and Community already receive responsive UIScale objects from OwnerUI.
 -- Reuse those instead of stacking a second scale.
 local native=target:FindFirstChild("BBYAOwnerPanelScaleV7") or target:FindFirstChild("BBYAOwnerCommunityScaleV7")
 if native and native:IsA("UIScale") then
  clearOwnScale(target)
  native.Scale=scale
 else
  ownScale(target,scale)
 end
 target:SetAttribute("BBYAMatchDanceVisual",tag or "V13")
end
local function hideWave(root)
 if not root then return end
 for _,d in ipairs(root:GetDescendants()) do
  if d:IsA("TextLabel") then
   local u=string.upper(tostring(d.Text or ""))
   if string.find(u,"LIVE WAVE",1,true) or string.find(u,"EQUALIZER",1,true) then
    local p=d.Parent
    if p and p:IsA("GuiObject") then p.Visible=false else d.Visible=false end
   end
  end
 end
end
local function enableScroll(root)
 if not root then return end
 for _,d in ipairs(root:GetDescendants()) do
  if d:IsA("ScrollingFrame") then d.Active=true;d.ScrollingEnabled=true;d.ScrollBarThickness=math.max(d.ScrollBarThickness,3) end
 end
end

-- Carry already owns its real content in 63-social-hangout.client.lua.
local function carry()
 local gui=pg:FindFirstChild("BBYASocialHangoutUI")
 local panel=gui and gui:FindFirstChild("CarryPanel")
 if panel then matchDance(panel,"CARRY_V13");panel.BackgroundTransparency=math.max(panel.BackgroundTransparency,.42);enableScroll(panel) end
end

local function hubParts()
 local club=pg:FindFirstChild("BBYAClubUI")
 local hub=club and club:FindFirstChild("HubPanel")
 if not hub then return end
 local content=nil
 for _,c in ipairs(hub:GetChildren()) do
  if c:IsA("Frame") and c.BackgroundTransparency==1 and c.Position.Y.Offset>=70 then content=c break end
 end
 if not content then
  for _,d in ipairs(hub:GetDescendants()) do
   if d:IsA("GuiObject") and (d.Name=="TravelDestinationScroller" or d.Name=="SupportGrid") then content=d.Parent and d.Parent.Parent;break end
  end
 end
 return club,hub,content
end
local function activePage(content)
 if not content then return nil end
 for _,c in ipairs(content:GetChildren()) do if c:IsA("GuiObject") and c.Visible then return c end end
end
local function titleText(hub)
 for _,d in ipairs(hub:GetDescendants()) do
  if d:IsA("TextLabel") then
   local u=string.upper(tostring(d.Text or ""))
   if u=="MUSIC SYSTEM" or u=="SUPPORT" or u=="SUPPORT BBYA" or u=="TRAVEL" then return u end
  end
 end
 return ""
end
local function hub()
 local _,panel,content=hubParts()
 if not panel or not panel.Visible then return end
 local active=activePage(content)
 if not active then return end
 local name=string.upper(active.Name or "")
 local title=titleText(panel)
 local isMusic=(name=="MUSIC" or title=="MUSIC SYSTEM")
 local isSupport=(name=="SUPPORT" or active:FindFirstChild("SupportGrid",true)~=nil or title=="SUPPORT" or title=="SUPPORT BBYA")
 local isTravel=(name=="TRAVEL" or active:FindFirstChild("TravelDestinationScroller",true)~=nil or title=="TRAVEL")
 if isMusic then
  clearOwnScale(panel)
  local v=viewport()
  panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.53)
  panel.Size=UDim2.fromOffset(math.clamp(v.X-100,720,980),math.clamp(v.Y-38,500,680))
  panel.BackgroundTransparency=math.max(panel.BackgroundTransparency,.62)
  local pc=panel:FindFirstChild("PlayerCard",true);local lc=panel:FindFirstChild("LibraryCard",true)
  if pc and pc:IsA("GuiObject") then pc.BackgroundTransparency=math.max(pc.BackgroundTransparency,.34) end
  if lc and lc:IsA("GuiObject") then lc.BackgroundTransparency=math.max(lc.BackgroundTransparency,.34) end
 elseif isSupport or isTravel then
  matchDance(panel,isSupport and "SUPPORT_V13" or "TRAVEL_V13")
  panel.BackgroundTransparency=math.max(panel.BackgroundTransparency,.48)
  hideWave(panel);enableScroll(panel)
  if isSupport then
   local intro=panel:FindFirstChild("SupportIntro",true);if intro then intro.Visible=false end
  end
 end
end

local function community()
 local club=pg:FindFirstChild("BBYAClubUI")
 local shade=club and club:FindFirstChild("CommunityOverlay",true)
 local panel=shade and shade:FindFirstChild("CommunityPanel",true)
 if not shade or not panel then return end
 shade.BackgroundTransparency=1;shade.Active=false
 matchDance(panel,"COMMUNITY_V13")
 panel.BackgroundTransparency=math.max(panel.BackgroundTransparency,.40)
 hideWave(panel);enableScroll(panel)
end

local function message()
 local gui=pg:FindFirstChild("BBYADJWallUI")
 local panel=gui and gui:FindFirstChild("DJWallComposerPanel",true)
 if not gui or not panel then return end
 for _,d in ipairs(gui:GetChildren()) do
  if d:IsA("Frame") and d~=panel and d.Size.X.Scale>=.95 and d.Size.Y.Scale>=.95 then d.BackgroundTransparency=1;d.Active=false end
 end
 matchDance(panel,"MESSAGE_V13")
 panel.BackgroundTransparency=math.max(panel.BackgroundTransparency,.30)
 enableScroll(panel)
 local footer=panel:FindFirstChild("StickyFooter",true)
 if footer and footer:IsA("GuiObject") then
  footer.Visible=true
  for _,d in ipairs(footer:GetDescendants()) do if d:IsA("TextButton") then d.Visible=true;d.Active=true;d.Selectable=true end end
 end
end

local function apply()
 carry();hub();community();message()
end

pg.ChildAdded:Connect(function()task.defer(apply);task.delay(.2,apply)end)
pg.DescendantAdded:Connect(function(d)if d:IsA("GuiObject") then task.defer(apply) end end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(apply)end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(apply)end) end
task.spawn(function()while true do task.wait(.35);apply() end end)
task.defer(apply)
print("[BBYA TEST] Secondary panel authority v13: match Dance Size+UIScale; Music/DJ exempt")
