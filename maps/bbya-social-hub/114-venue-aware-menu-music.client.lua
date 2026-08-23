-- BBYA SOCIAL HUB — VENUE-AWARE MENU MUSIC v2
-- Keeps the command-menu music button synchronized with the player's active venue.
-- Also guards the shared compact music panel so PLAYLIST / MUTE / PREV / NEXT
-- never overflow the panel on mobile or narrow viewports.

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera

local LABELS={
 MAIN="CLUB",
 UNDERGROUND="UNDERGROUND",
 VIP="VIP",
 FUNKOT="FUNKOT",
 SKATEPARK="SKATEPARK",
 ROOFTOP="ROOFTOP",
 NONE="MUSIC",
}

local menuGui
local musicButton
local writing=false

local function currentVenue()
 local v=tostring(player:GetAttribute("BBYAAudioVenue") or "NONE")
 return LABELS[v] and v or "NONE"
end

local function resolveMenu()
 if menuGui and menuGui.Parent then return menuGui end
 menuGui=pg:FindFirstChild("BBYACommandMenuUI") or pg:WaitForChild("BBYACommandMenuUI",30)
 return menuGui
end

local function findMusicButton()
 local gui=resolveMenu()
 if not gui then return nil end
 if musicButton and musicButton.Parent and musicButton:GetAttribute("BBYACommandMenuId")=="MUSIC" then return musicButton end
 musicButton=nil
 for _,d in ipairs(gui:GetDescendants()) do
  if d:IsA("TextButton") and d:GetAttribute("BBYACommandMenuId")=="MUSIC" then
   musicButton=d
   break
  end
 end
 return musicButton
end

local function desiredLabel()
 return LABELS[currentVenue()] or "MUSIC"
end

local function updateMusicLabel()
 local b=findMusicButton()
 if not b then return end
 local target=desiredLabel()
 if b.Text~=target then
  writing=true
  b.Text=target
  writing=false
 end
 b:SetAttribute("BBYAVenueAwareMusicLabel",target)
end

local function bindButtonGuard()
 local b=findMusicButton()
 if not b or b:GetAttribute("BBYAVenueAwareTextGuardV2") then return end
 b:SetAttribute("BBYAVenueAwareTextGuardV2",true)
 b:GetPropertyChangedSignal("Text"):Connect(function()
  if writing then return end
  task.defer(updateMusicLabel)
 end)
 b.AncestryChanged:Connect(function()
  task.defer(function()
   musicButton=nil
   bindButtonGuard()
   updateMusicLabel()
  end)
 end)
end

local function refreshMenu()
 bindButtonGuard()
 updateMusicLabel()
end

-- MOBILE MUSIC PANEL GUARD ----------------------------------------------------
local currentCard=nil
local currentDrawer=nil
local panelBound={}
local guardAcc=0

local function viewport()
 camera=workspace.CurrentCamera or camera
 return (camera and camera.ViewportSize) or Vector2.new(1280,720)
end

local function findButton(parent,name)
 local b=parent and parent:FindFirstChild(name)
 return b and b:IsA("GuiButton") and b or nil
end

local function guardCard(card)
 if not card or not card.Parent then return end
 local vp=viewport()
 local cw=card.AbsoluteSize.X
 local ch=card.AbsoluteSize.Y
 if cw<=0 then cw=card.Size.X.Offset end
 if ch<=0 then ch=card.Size.Y.Offset end

 -- Never let the card itself exceed the horizontal safe area.
 local maxW=math.max(286,vp.X-24)
 if cw>maxW then
  card.Size=UDim2.fromOffset(maxW,math.max(158,ch))
  cw=maxW
 end
 card.ClipsDescendants=true

 local playlist=findButton(card,"PlaylistButtonV7")
 local mute=findButton(card,"MuteButtonV7")
 local prev=findButton(card,"AdminPreviousV7")
 local nextBtn=findButton(card,"AdminNextV7")
 local close=findButton(card,"CompactCloseV7")
 if not playlist or not mute or not prev or not nextBtn then return end

 local pad=14
 local gap=6
 local total=math.max(258,cw-pad*2)
 local y=math.max(116,ch-42)
 local h=30
 local adminVisible=prev.Visible or nextBtn.Visible

 if adminVisible then
  -- Use the entire bottom row instead of starting after the cover image.
  -- This guarantees NEXT ends at cardWidth - 14 on every viewport.
  local prevW=math.clamp(math.floor(total*.13),42,58)
  local nextW=prevW
  local muteW=math.clamp(math.floor(total*.22),60,82)
  local playlistW=math.max(92,total-(prevW+nextW+muteW+gap*3))
  local x=pad
  playlist.Position=UDim2.fromOffset(x,y);playlist.Size=UDim2.fromOffset(playlistW,h);x+=playlistW+gap
  mute.Position=UDim2.fromOffset(x,y);mute.Size=UDim2.fromOffset(muteW,h);x+=muteW+gap
  prev.Position=UDim2.fromOffset(x,y);prev.Size=UDim2.fromOffset(prevW,h);x+=prevW+gap
  nextBtn.Position=UDim2.fromOffset(x,y);nextBtn.Size=UDim2.fromOffset(math.max(42,cw-pad-x),h)
 else
  local muteW=math.clamp(math.floor(total*.36),74,120)
  local playlistW=total-gap-muteW
  playlist.Position=UDim2.fromOffset(pad,y);playlist.Size=UDim2.fromOffset(playlistW,h)
  mute.Position=UDim2.fromOffset(pad+playlistW+gap,y);mute.Size=UDim2.fromOffset(muteW,h)
 end

 -- Defensive clamp for every visible control.
 local maxRight=cw-pad
 for _,b in ipairs({playlist,mute,prev,nextBtn}) do
  if b.Visible then
   local x=b.Position.X.Offset
   local w=b.Size.X.Offset
   if x+w>maxRight then b.Size=UDim2.fromOffset(math.max(38,maxRight-x),h) end
  end
 end
 if close then
  close.Position=UDim2.new(1,-46,0,10)
  close.Size=UDim2.fromOffset(32,32)
 end
 card:SetAttribute("BBYAMobileControlsGuard","V1")
end

local function guardDrawer(drawer)
 if not drawer or not drawer.Parent then return end
 local vp=viewport()
 local dw=drawer.AbsoluteSize.X
 local dh=drawer.AbsoluteSize.Y
 if dw<=0 then dw=drawer.Size.X.Offset end
 if dh<=0 then dh=drawer.Size.Y.Offset end
 local maxW=math.max(300,vp.X-24)
 local maxH=math.max(260,vp.Y-24)
 if dw>maxW or dh>maxH then
  drawer.Size=UDim2.fromOffset(math.min(dw,maxW),math.min(dh,maxH))
 end
 drawer.ClipsDescendants=true
 drawer:SetAttribute("BBYAMobileDrawerGuard","V1")
end

local function bindCard(card)
 if not card or panelBound[card] then return end
 panelBound[card]=true
 currentCard=card
 card:GetPropertyChangedSignal("Size"):Connect(function()task.defer(function()guardCard(card)end)end)
 for _,name in ipairs({"AdminPreviousV7","AdminNextV7","PlaylistButtonV7","MuteButtonV7"}) do
  local b=card:FindFirstChild(name)
  if b then b:GetPropertyChangedSignal("Visible"):Connect(function()task.defer(function()guardCard(card)end)end) end
 end
 task.defer(function()guardCard(card)end)
end

local function scanMusicPanel()
 local clubUI=pg:FindFirstChild("BBYAClubUI")
 local layer=clubUI and clubUI:FindFirstChild("BBYACompactMusicLayerV7")
 if not layer then return end
 local card=layer:FindFirstChild("CompactMusicCardV7")
 local drawer=layer:FindFirstChild("PlaylistDrawerV7")
 if card then bindCard(card);guardCard(card) end
 if drawer then currentDrawer=drawer;guardDrawer(drawer) end
end

player:GetAttributeChangedSignal("BBYAAudioVenue"):Connect(function()
 task.defer(refreshMenu)
 task.defer(scanMusicPanel)
end)

pg.ChildAdded:Connect(function(child)
 if child.Name=="BBYACommandMenuUI" then
  menuGui=child
  musicButton=nil
  task.defer(refreshMenu)
 end
 task.defer(scanMusicPanel)
end)

local gui=resolveMenu()
if gui then
 gui.DescendantAdded:Connect(function(d)
  if d:IsA("TextButton") then task.defer(refreshMenu) end
 end)
end

local clubUI=pg:FindFirstChild("BBYAClubUI") or pg:WaitForChild("BBYAClubUI",30)
if clubUI then
 clubUI.DescendantAdded:Connect(function(d)
  if d.Name=="CompactMusicCardV7" or d.Name=="PlaylistDrawerV7" then task.defer(scanMusicPanel) end
 end)
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
 camera=workspace.CurrentCamera
 task.defer(scanMusicPanel)
end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(scanMusicPanel)end) end

-- The original v7 layout can re-apply after venue/viewport refresh; keep the final safe layout authoritative.
RunService.Heartbeat:Connect(function(dt)
 guardAcc+=dt;if guardAcc<.35 then return end;guardAcc=0
 if currentCard and currentCard.Parent and currentCard.Visible then guardCard(currentCard) end
 if currentDrawer and currentDrawer.Parent and currentDrawer.Visible then guardDrawer(currentDrawer) end
end)

for i=0,16 do
 task.delay(i*.25,function()refreshMenu();scanMusicPanel()end)
end

print("[BBYA] Venue-aware menu music v2 online: venue labels + mobile-safe shared music controls")
