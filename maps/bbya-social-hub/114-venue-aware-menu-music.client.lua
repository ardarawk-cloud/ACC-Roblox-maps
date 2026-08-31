-- BBYA SOCIAL HUB — VENUE-AWARE MENU MUSIC v3
-- Keeps the command-menu music button synchronized with the player's active venue.
-- Also guards the shared compact music panel so PLAYLIST / MUTE / PREV / NEXT
-- never overflow the panel on mobile or narrow viewports.
-- v3 bridges the premium Music Suite to the Skatepark catalog/transport authority.

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")

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

-- SKATEPARK MUSIC SUITE BRIDGE v1 -------------------------------------------
local skateControl=ReplicatedStorage:WaitForChild("BBYASkateparkMusicControl",30)
local skateBound={}
local skateAcc=0

local function isAdmin()
 return player:GetAttribute("BBYAAdmin")==true
  or (game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId)
end

local function getSkateTracks()
 local folder=ReplicatedStorage:FindFirstChild("BBYASkateparkPlaylistCatalog")
 if not folder then return {} end
 local tracks={}
 for _,row in ipairs(folder:GetChildren()) do
  if row:IsA("StringValue") then
   local i=tonumber(row:GetAttribute("Index"))
   if i then
    tracks[i]={
     title=row.Value,
     assetId=tostring(row:GetAttribute("AssetId") or ""),
     playbackSpeed=tonumber(row:GetAttribute("PlaybackSpeed")) or 1,
    }
   end
  end
 end
 local out={}
 for i=1,#tracks do if tracks[i] then table.insert(out,tracks[i]) end end
 return out
end

local function skateCorner(o,r)
 local c=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
 c.CornerRadius=UDim.new(0,r or 8);c.Parent=o
end

local function skateLabel(p,n,t,pos,size,ts,col,align)
 local x=Instance.new("TextLabel")
 x.Name=n;x.BackgroundTransparency=1;x.Text=t;x.Position=pos;x.Size=size
 x.Font=Enum.Font.GothamBold;x.TextSize=ts or 8;x.TextColor3=col or Color3.fromRGB(247,247,250)
 x.TextXAlignment=align or Enum.TextXAlignment.Left;x.TextYAlignment=Enum.TextYAlignment.Center
 x.TextTruncate=Enum.TextTruncate.AtEnd;x.Parent=p;return x
end

local function directScrolling(page)
 if not page then return nil end
 for _,d in ipairs(page:GetChildren()) do if d:IsA("ScrollingFrame") then return d end end
 return nil
end

local function suiteParts()
 local suite=pg:FindFirstChild("BBYAMusicSuiteV1")
 if not suite then return nil end
 local lib=suite:FindFirstChild("LIBRARY",true)
 local now=suite:FindFirstChild("NOW",true)
 local queue=suite:FindFirstChild("QUEUE",true)
 return suite,lib,now,queue
end

local function findChipValue(page,heading)
 if not page then return nil end
 for _,h in ipairs(page:GetDescendants()) do
  if h:IsA("TextLabel") and h.Name=="H" and h.Text==heading then
   local p=h.Parent
   local v=p and p:FindFirstChild("V")
   if v and v:IsA("TextLabel") then return v end
  end
 end
 return nil
end

local function countTrackRows(list)
 local n=0
 if not list then return 0 end
 for _,d in ipairs(list:GetChildren()) do
  if d:IsA("Frame") and d.Name:match("^Track_%d+$") then n+=1 end
 end
 return n
end

local function rebuildSkateLibrary(suite,lib,tracks)
 local list=directScrolling(lib)
 if not list then return end
 for _,d in ipairs(list:GetChildren()) do
  if d:IsA("Frame") and d.Name:match("^Track_%d+$") then d:Destroy() end
 end
 local current=tonumber(ReplicatedStorage:GetAttribute("BBYASkateparkCurrentIndex")) or 0
 for i,t in ipairs(tracks) do
  local r=Instance.new("Frame")
  r.Name="Track_"..i;r.LayoutOrder=i;r.Size=UDim2.new(1,-2,0,42)
  r.BackgroundColor3=Color3.fromRGB(21,22,30);r.BorderSizePixel=0;r.Parent=list;skateCorner(r,8)
  local playing=i==current
  skateLabel(r,"No",string.format("%02d",i),UDim2.fromOffset(5,0),UDim2.fromOffset(34,42),7,playing and Color3.fromRGB(38,200,225) or Color3.fromRGB(146,150,164),Enum.TextXAlignment.Center)
  skateLabel(r,"Title",t.title,UDim2.fromOffset(45,3),UDim2.new(1,-180,0,21),9,Color3.fromRGB(247,247,250))
  local speedMeta=(math.abs((t.playbackSpeed or 1)-1)>.001) and string.format("SKATEPARK • %.2fx",t.playbackSpeed) or "SKATEPARK"
  skateLabel(r,"Meta",speedMeta,UDim2.fromOffset(45,22),UDim2.new(1,-180,0,15),6,Color3.fromRGB(146,150,164))
  if playing then skateLabel(r,"Playing","PLAYING",UDim2.new(1,-204,0,0),UDim2.fromOffset(70,42),6,Color3.fromRGB(38,200,225),Enum.TextXAlignment.Center) end
  local req=Instance.new("TextButton")
  req.Name="Req";req.Text="REQUEST";req.Position=UDim2.new(1,-118,0,6);req.Size=UDim2.fromOffset(104,30)
  req.BackgroundColor3=Color3.fromRGB(49,32,70);req.BorderSizePixel=0;req.TextColor3=Color3.fromRGB(247,247,250)
  req.Font=Enum.Font.GothamBold;req.TextSize=7;req.Parent=r;skateCorner(req,8)
  if playing then
   req.Active=false;req.AutoButtonColor=false;req.TextColor3=Color3.fromRGB(146,150,164)
  elseif skateControl then
   req.Activated:Connect(function()skateControl:FireServer("request",i)end)
  end
 end
 list:SetAttribute("BBYASkateparkSuiteRows",#tracks)
 local meta=lib and lib:FindFirstChild("Meta")
 if meta and meta:IsA("TextLabel") then meta.Text=string.format("%d / %d TRACKS",#tracks,#tracks) end
 local trackValue=findChipValue(lib,"TRACKS")
 if trackValue then trackValue.Text=tostring(#tracks);trackValue.TextColor3=Color3.fromRGB(38,200,225) end
 local status=suite:FindFirstChild("SV",true)
 if status and status:IsA("TextLabel") then status.Text=tostring(#tracks).." TRACKS READY" end
end

local function rebuildSkateUpNext(nowPage,tracks)
 if not nowPage or #tracks==0 then return end
 local upList
 for _,d in ipairs(nowPage:GetDescendants()) do
  if d:IsA("ScrollingFrame") then
   local p=d.Parent
   local title=p and p:FindFirstChild("Title")
   if title and title:IsA("TextLabel") and title.Text=="UP NEXT" then upList=d break end
  end
 end
 if not upList then return end
 for _,d in ipairs(upList:GetChildren()) do if d:IsA("Frame") and d.Name:match("^Next_") then d:Destroy() end end
 local current=tonumber(ReplicatedStorage:GetAttribute("BBYASkateparkCurrentIndex")) or 1
 local requested=tonumber(ReplicatedStorage:GetAttribute("BBYASkateparkNextRequestIndex")) or 0
 local order=0
 local used={}
 local function add(idx,meta)
  local t=tracks[idx];if not t then return end
  order+=1;used[idx]=true
  local r=Instance.new("Frame")
  r.Name="Next_"..order;r.Size=UDim2.new(1,-2,0,46);r.BackgroundColor3=Color3.fromRGB(21,22,30);r.BorderSizePixel=0;r.Parent=upList;skateCorner(r,8)
  skateLabel(r,"No",tostring(order),UDim2.fromOffset(4,0),UDim2.fromOffset(28,46),8,meta=="REQUEST QUEUE" and Color3.fromRGB(232,181,82) or Color3.fromRGB(38,200,225),Enum.TextXAlignment.Center)
  skateLabel(r,"T",t.title,UDim2.fromOffset(38,4),UDim2.new(1,-44,0,22),8,Color3.fromRGB(247,247,250))
  skateLabel(r,"M",meta,UDim2.fromOffset(38,24),UDim2.new(1,-44,0,16),6,Color3.fromRGB(146,150,164))
 end
 if requested>0 then add(requested,"REQUEST QUEUE") end
 local idx=current
 while order<5 and order<#tracks do
  idx=(idx%#tracks)+1
  if not used[idx] then add(idx,"AUTO DJ") end
 end
end

local function rebuildSkateQueue(queuePage,tracks)
 if not queuePage then return end
 local list=directScrolling(queuePage)
 if not list then
  for _,d in ipairs(queuePage:GetDescendants()) do if d:IsA("ScrollingFrame") then list=d break end end
 end
 if not list then return end
 for _,d in ipairs(list:GetChildren()) do if d:IsA("Frame") and d.Name:match("^Queue_") then d:Destroy() end end
 local count=tonumber(ReplicatedStorage:GetAttribute("BBYASkateparkQueueCount")) or 0
 local nextIndex=tonumber(ReplicatedStorage:GetAttribute("BBYASkateparkNextRequestIndex")) or 0
 local meta=queuePage:FindFirstChild("Meta")
 if meta and meta:IsA("TextLabel") then meta.Text=tostring(count).." REQUESTS" end
 local chip=findChipValue(suiteParts() and select(2,suiteParts()) or nil,"QUEUE")
 if chip then chip.Text=tostring(count) end
 local r=Instance.new("Frame")
 r.Name="Queue_1";r.Size=UDim2.new(1,-2,0,50);r.BackgroundColor3=Color3.fromRGB(21,22,30);r.BorderSizePixel=0;r.Parent=list;skateCorner(r,8)
 if count<=0 then
  skateLabel(r,"T","REQUEST QUEUE KOSONG",UDim2.fromOffset(14,4),UDim2.new(1,-28,0,24),8,Color3.fromRGB(247,247,250))
  skateLabel(r,"M","Pilih lagu di Library lalu tekan REQUEST",UDim2.fromOffset(14,26),UDim2.new(1,-28,0,16),6,Color3.fromRGB(146,150,164))
 elseif tracks[nextIndex] then
  skateLabel(r,"T",tracks[nextIndex].title,UDim2.fromOffset(14,4),UDim2.new(1,-28,0,24),8,Color3.fromRGB(247,247,250))
  skateLabel(r,"M","NEXT REQUEST • "..tostring(count).." QUEUED",UDim2.fromOffset(14,26),UDim2.new(1,-28,0,16),6,Color3.fromRGB(232,181,82))
 else
  skateLabel(r,"T",tostring(count).." REQUEST QUEUED",UDim2.fromOffset(14,4),UDim2.new(1,-28,0,24),8,Color3.fromRGB(247,247,250))
 end
end

local function bindSkateTransport(suite,nowPage)
 if not nowPage or not skateControl then return end
 local nextBtn=nowPage:FindFirstChild("Next",true)
 local prevBtn=nowPage:FindFirstChild("Prev",true)
 for _,pair in ipairs({{nextBtn,"next"},{prevBtn,"prev"}}) do
  local b,action=pair[1],pair[2]
  if b and b:IsA("GuiButton") and not skateBound[b] then
   skateBound[b]=true
   b.Activated:Connect(function()
    if currentVenue()=="SKATEPARK" and isAdmin() then skateControl:FireServer(action) end
   end)
  end
  if b and currentVenue()=="SKATEPARK" then
   b.Visible=isAdmin();b.Active=isAdmin();b.AutoButtonColor=isAdmin()
  end
 end
end

local function refreshSkateSuite(forceRows)
 if currentVenue()~="SKATEPARK" then return end
 local suite,lib,nowPage,queuePage=suiteParts()
 if not suite or not suite.Enabled then return end
 local tracks=getSkateTracks()
 if #tracks==0 then return end
 local list=directScrolling(lib)
 if forceRows or countTrackRows(list)~=#tracks then rebuildSkateLibrary(suite,lib,tracks) end

 local current=tonumber(ReplicatedStorage:GetAttribute("BBYASkateparkCurrentIndex")) or 1
 local title=tostring(ReplicatedStorage:GetAttribute("BBYASkateparkCurrentTitle") or (tracks[current] and tracks[current].title) or "BELUM ADA LAGU")
 local trackLabel=nowPage and nowPage:FindFirstChild("Track",true)
 if trackLabel and trackLabel:IsA("TextLabel") then trackLabel.Text=title end
 local info=trackLabel and trackLabel.Parent
 local meta=info and info:FindFirstChild("Meta")
 if meta and meta:IsA("TextLabel") then meta.Text="SKATEPARK  •  "..tostring(#tracks).." TRACKS" end
 local skateSound=SoundService:FindFirstChild("BBYASkateparkMasterSound")
 local state=info and info:FindFirstChild("State")
 if state and state:IsA("TextLabel") then state.Text=(skateSound and skateSound.IsPlaying) and "LIVE • PLAYING" or "STANDBY" end
 local elapsed=suite:FindFirstChild("Elapsed",true)
 local duration=suite:FindFirstChild("Duration",true)
 local function fmt(sec)
  sec=math.max(0,math.floor(tonumber(sec) or 0));return string.format("%02d:%02d",math.floor(sec/60),sec%60)
 end
 if elapsed and elapsed:IsA("TextLabel") then elapsed.Text=fmt(skateSound and skateSound.TimePosition or 0) end
 if duration and duration:IsA("TextLabel") then duration.Text=fmt(skateSound and skateSound.TimeLength or 0) end

 local venueValue=findChipValue(lib,"VENUE")
 if venueValue then venueValue.Text="SKATEPARK";venueValue.TextColor3=Color3.fromRGB(38,200,225) end
 local queueValue=findChipValue(lib,"QUEUE")
 if queueValue then queueValue.Text=tostring(tonumber(ReplicatedStorage:GetAttribute("BBYASkateparkQueueCount")) or 0) end
 bindSkateTransport(suite,nowPage)
 rebuildSkateUpNext(nowPage,tracks)
 rebuildSkateQueue(queuePage,tracks)
 suite:SetAttribute("BBYASkateparkMusicSuiteBridge","V1")
end

local function deferSkateRefresh(forceRows)
 task.defer(function()refreshSkateSuite(forceRows==true)end)
end

player:GetAttributeChangedSignal("BBYAAudioVenue"):Connect(function()deferSkateRefresh(true)end)
for _,attr in ipairs({"BBYASkateparkCurrentIndex","BBYASkateparkCurrentTitle","BBYASkateparkQueueCount","BBYASkateparkNextRequestIndex"}) do
 ReplicatedStorage:GetAttributeChangedSignal(attr):Connect(function()deferSkateRefresh(true)end)
end
local skateCatalog=ReplicatedStorage:FindFirstChild("BBYASkateparkPlaylistCatalog")
if skateCatalog then
 skateCatalog.ChildAdded:Connect(function()deferSkateRefresh(true)end)
 skateCatalog.ChildRemoved:Connect(function()deferSkateRefresh(true)end)
end
pg.ChildAdded:Connect(function(child)
 if child.Name=="BBYAMusicSuiteV1" then
  task.delay(.2,function()refreshSkateSuite(true)end)
 end
end)

-- The original v7 layout and premium suite can re-apply after venue/playlist refresh;
-- keep the final safe layout and Skatepark catalog bridge authoritative.
RunService.Heartbeat:Connect(function(dt)
 guardAcc+=dt
 skateAcc+=dt
 if guardAcc>=.35 then
  guardAcc=0
  if currentCard and currentCard.Parent and currentCard.Visible then guardCard(currentCard) end
  if currentDrawer and currentDrawer.Parent and currentDrawer.Visible then guardDrawer(currentDrawer) end
 end
 if skateAcc>=.35 then
  skateAcc=0
  refreshSkateSuite(false)
 end
end)

for i=0,16 do
 task.delay(i*.25,function()refreshMenu();scanMusicPanel();refreshSkateSuite(i==0)end)
end

print("[BBYA] Venue-aware menu music v3 online: venue labels + mobile-safe controls + Skatepark Music Suite bridge")
