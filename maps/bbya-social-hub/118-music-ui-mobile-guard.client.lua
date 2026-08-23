-- BBYA SOCIAL HUB — MUSIC UI MOBILE GUARD v1
-- Keeps PLAYLIST / MUTE / PREV / NEXT inside the shared compact music card
-- on every venue and every viewport. Presentation only; no audio logic changes.

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local gui=pg:WaitForChild("BBYAClubUI",30)
if not gui then return end

local camera=workspace.CurrentCamera
local currentCard=nil
local currentDrawer=nil
local bound={}
local acc=0

local function viewport()
 camera=workspace.CurrentCamera or camera
 return (camera and camera.ViewportSize) or Vector2.new(1280,720)
end

local function getButton(card,name)
 local b=card and card:FindFirstChild(name)
 return b and b:IsA("GuiButton") and b or nil
end

local function applyCard(card)
 if not card or not card.Parent then return end
 local vp=viewport()
 local cw=card.AbsoluteSize.X
 local ch=card.AbsoluteSize.Y
 if cw<=0 then cw=card.Size.X.Offset end
 if ch<=0 then ch=card.Size.Y.Offset end

 -- Never allow the compact card itself to exceed the viewport.
 local safeW=math.max(286,vp.X-24)
 if cw>safeW then
  card.Size=UDim2.fromOffset(safeW,math.max(158,ch))
  cw=safeW
 end
 card.ClipsDescendants=true

 local playlist=getButton(card,"PlaylistButtonV7")
 local mute=getButton(card,"MuteButtonV7")
 local prev=getButton(card,"AdminPreviousV7")
 local nextBtn=getButton(card,"AdminNextV7")
 local close=getButton(card,"CompactCloseV7")
 if not playlist or not mute or not prev or not nextBtn then return end

 local pad=14
 local gap=6
 local total=math.max(258,cw-pad*2)
 local y=math.max(116,ch-42)
 local h=30
 local adminVisible=prev.Visible or nextBtn.Visible

 if adminVisible then
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

 -- Defensive final clamp: right edge of every visible control stays inside the card.
 for _,b in ipairs({playlist,mute,prev,nextBtn}) do
  if b.Visible then
   local x=b.Position.X.Offset
   local w=b.Size.X.Offset
   local maxRight=cw-pad
   if x+w>maxRight then b.Size=UDim2.fromOffset(math.max(38,maxRight-x),h) end
  end
 end
 if close then
  close.Position=UDim2.new(1,-46,0,10)
  close.Size=UDim2.fromOffset(32,32)
 end

 card:SetAttribute("BBYAMobileControlsGuard","V1")
 card:SetAttribute("BBYAControlsSafeRight",cw-pad)
end

local function applyDrawer(drawer)
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
 if not card or bound[card] then return end
 bound[card]=true;currentCard=card
 for _,name in ipairs({"AdminPreviousV7","AdminNextV7","PlaylistButtonV7","MuteButtonV7"}) do
  local b=card:FindFirstChild(name)
  if b then
   b:GetPropertyChangedSignal("Visible"):Connect(function()task.defer(function()applyCard(card)end)end)
  end
 end
 card:GetPropertyChangedSignal("Size"):Connect(function()task.defer(function()applyCard(card)end)end)
 task.defer(function()applyCard(card)end)
end

local function scan()
 local layer=gui:FindFirstChild("BBYACompactMusicLayerV7")
 if not layer then return end
 local card=layer:FindFirstChild("CompactMusicCardV7")
 local drawer=layer:FindFirstChild("PlaylistDrawerV7")
 if card then bindCard(card);applyCard(card) end
 if drawer then currentDrawer=drawer;applyDrawer(drawer) end
end

gui.DescendantAdded:Connect(function(d)
 if d.Name=="CompactMusicCardV7" or d.Name=="PlaylistDrawerV7" then task.defer(scan) end
end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
 camera=workspace.CurrentCamera;task.defer(scan)
end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(scan)end) end

-- Small guard cadence handles the original v7 layout function re-applying after venue/viewport refresh.
RunService.Heartbeat:Connect(function(dt)
 acc+=dt;if acc<.35 then return end;acc=0
 if currentCard and currentCard.Parent and currentCard.Visible then applyCard(currentCard) end
 if currentDrawer and currentDrawer.Parent and currentDrawer.Visible then applyDrawer(currentDrawer) end
end)

task.spawn(function()
 for _=1,120 do scan();task.wait(.25) end
end)

print("[BBYA] Music UI Mobile Guard v1 online: shared venue controls clamped inside panel")
