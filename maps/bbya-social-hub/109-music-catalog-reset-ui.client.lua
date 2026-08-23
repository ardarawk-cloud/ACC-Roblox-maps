-- BBYA SOCIAL HUB — MUSIC CATALOG RESET UI v2
-- Clean empty-catalog authority after the owner-requested music reset.
-- Removes legacy playlist ghosts instead of covering them, hides unusable transport,
-- keeps VIP as its own venue identity, makes hub panels translucent, and keeps the
-- admin editor accessible without covering NOW PLAYING.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local gui=pg:WaitForChild("BBYAClubUI",30)
if not gui then return end
local panel=gui:WaitForChild("HubPanel",30)
if not panel then return end

local VENUES={
 MAIN={title="CLUB MUSIC",sub="MAIN CLUB • PLAYLIST RESET",short="CLUB",accent=Color3.fromRGB(232,38,165)},
 UNDERGROUND={title="UNDERGROUND MUSIC",sub="UNDERGROUND • PLAYLIST RESET",short="UNDERGROUND",accent=Color3.fromRGB(39,196,225)},
 VIP={title="VIP MUSIC",sub="PRIVATE CLUB • SEPARATE CHANNEL",short="VIP",accent=Color3.fromRGB(220,173,86)},
 FUNKOT={title="FUNKOT MUSIC",sub="FUNKOT • PLAYLIST RESET",short="FUNKOT",accent=Color3.fromRGB(143,82,255)},
 SKATEPARK={title="SKATEPARK MUSIC",sub="SKATEPARK • PLAYLIST RESET",short="SKATEPARK",accent=Color3.fromRGB(39,196,225)},
 ROOFTOP={title="ROOFTOP MUSIC",sub="ROOFTOP • PLAYLIST RESET",short="ROOFTOP",accent=Color3.fromRGB(220,173,86)},
 NONE={title="MUSIC",sub="NO VENUE AUDIO HERE",short="MUSIC",accent=Color3.fromRGB(151,155,168)},
}

local function venueAtPosition(p)
 if p.Y<-4.5 then return "UNDERGROUND" end
 if p.Y>=40 and p.Y<=60 and math.abs(p.X)<=62 and p.Z>=-48 and p.Z<=48 then return "ROOFTOP" end
 if p.Y>=20 and p.Y<40 and math.abs(p.X)<=58 and p.Z>=-46 and p.Z<=46 then return "VIP" end
 if p.Y>-4 and p.Y<34 and math.abs(p.X)<61 and p.Z>157 and p.Z<253 then return "FUNKOT" end
 if p.Y>-4 and p.Y<20 and math.abs(p.X)<=61 and p.Z>=72 and p.Z<=152 then return "SKATEPARK" end
 if p.Y>-4 and p.Y<18 and math.abs(p.X)<=61 and p.Z>=0 and p.Z<70 then return "MAIN" end
 return "NONE"
end

local function currentVenue()
 local v=tostring(player:GetAttribute("BBYAAudioVenue") or "")
 if VENUES[v] then return v end
 local ch=player.Character
 local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 return hrp and venueAtPosition(hrp.Position) or "NONE"
end

local function resetActive()
 return ReplicatedStorage:GetAttribute("BBYAMusicCatalogReset")==true
end

local function core()
 return panel:FindFirstChild("PlayerCard",true),panel:FindFirstChild("LibraryCard",true)
end

local function findHeader()
 for _,f in ipairs(panel:GetChildren()) do
  if f:IsA("Frame") then
   for _,d in ipairs(f:GetChildren()) do
    if d:IsA("TextButton") and (d.Text=="×" or d.Text=="X") then return f end
   end
  end
 end
end

local function headerLabels(header)
 local title,sub
 if not header then return nil,nil end
 for _,d in ipairs(header:GetChildren()) do
  if d:IsA("TextLabel") then
   if d.TextSize>=16 then title=title or d else sub=sub or d end
  end
 end
 return title,sub
end

local function ensureEmpty(libraryCard)
 if not libraryCard then return nil end
 local empty=libraryCard:FindFirstChild("MusicCatalogEmptyV1")
 if not empty then
  empty=Instance.new("Frame")
  empty.Name="MusicCatalogEmptyV1"
  empty.BorderSizePixel=0
  empty.BackgroundColor3=Color3.fromRGB(18,19,25)
  empty.Parent=libraryCard
  local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,10);c.Parent=empty
  local s=Instance.new("UIStroke");s.Name="ResetStroke";s.Thickness=1;s.Transparency=.45;s.Parent=empty
  local big=Instance.new("TextLabel");big.Name="EmptyTitle";big.BackgroundTransparency=1;big.Position=UDim2.fromOffset(18,18);big.Size=UDim2.new(1,-36,0,30);big.Font=Enum.Font.GothamBold;big.TextSize=14;big.TextColor3=Color3.fromRGB(246,246,249);big.TextXAlignment=Enum.TextXAlignment.Left;big.Parent=empty
  local sub=Instance.new("TextLabel");sub.Name="EmptySub";sub.BackgroundTransparency=1;sub.Position=UDim2.fromOffset(18,52);sub.Size=UDim2.new(1,-36,0,42);sub.Font=Enum.Font.Gotham;sub.TextSize=10;sub.TextColor3=Color3.fromRGB(160,163,174);sub.TextXAlignment=Enum.TextXAlignment.Left;sub.TextWrapped=true;sub.Parent=empty
 end
 empty.Position=UDim2.fromOffset(12,12)
 empty.Size=UDim2.new(1,-24,1,-24)
 empty.BackgroundTransparency=.34
 empty.ZIndex=180
 for _,d in ipairs(empty:GetDescendants()) do if d:IsA("GuiObject") then d.ZIndex=math.max(d.ZIndex,181) end end
 return empty
end

local function removeLegacyLibrary(libraryCard,empty)
 if not libraryCard or not empty then return end
 for _,child in ipairs(libraryCard:GetChildren()) do
  if child~=empty and child:IsA("GuiObject") then
   child.Visible=false
   if child:IsA("TextButton") then child.Active=false end
  end
 end
 -- Some older playlist rows are recreated below nested containers; force them off too.
 for _,d in ipairs(libraryCard:GetDescendants()) do
  if not d:IsDescendantOf(empty) and d~=empty and d:IsA("GuiObject") then
   d.Visible=false
   if d:IsA("TextButton") then d.Active=false end
  end
 end
 empty.Visible=true
end

local function hideTransport()
 for _,d in ipairs(panel:GetDescendants()) do
  if d:IsA("TextButton") then
   local up=string.upper((d.Text or ""):match("^%s*(.-)%s*$") or "")
   if up=="NEXT" or up=="PREV" or up=="PREVIOUS" or up=="PAUSE" or up=="RESUME" then
    d.Visible=false;d.Active=false;d.AutoButtonColor=false
   end
  end
 end
end

local function syncPlayerCard(playerCard,spec)
 if not playerCard then return end
 local bigCandidate=nil
 for _,d in ipairs(playerCard:GetDescendants()) do
  if d:IsA("TextLabel") then
   local up=string.upper(d.Text or "")
   if up=="NOW PLAYING" then
    d.Text="NOW PLAYING"
   elseif d.TextSize>=16 and (not bigCandidate or d.TextSize>bigCandidate.TextSize) then
    bigCandidate=d
   end
   if up:find("PROGRESSIVE",1,true) or up:find("BREAKBEAT",1,true) or up:find("INDO",1,true) or up:find("FUNKOT",1,true) or up:find("RECOVERY",1,true) then
    d.Text=spec.short.." • 0 TRACKS"
    d.TextColor3=spec.accent
   elseif up=="LIVE" or up:find("PLAYING",1,true) or up:find("PAUSED",1,true) then
    d.Text="●  READY"
    d.TextColor3=spec.accent
   end
  end
 end
 if bigCandidate then bigCandidate.Text="BELUM ADA LAGU" end
end

local function syncVenueChip(musicFrame,spec)
 if not musicFrame then return end
 for _,d in ipairs(musicFrame:GetDescendants()) do
  if d:IsA("TextLabel") or d:IsA("TextButton") then
   local up=string.upper((d.Text or ""):match("^%s*(.-)%s*$") or "")
   if up=="CLUB" or up=="● CLUB" or up=="UNDERGROUND" or up=="● UNDERGROUND" or up=="FUNKOT" or up=="● FUNKOT" or up=="VIP" or up=="● VIP" then
    d.Text="● "..spec.short
   end
  end
 end
end

local function makeHubTranslucent()
 -- Applies to all HubPanel pages, not only Music, so HOME/SUPPORT/TRAVEL/etc share one visual language.
 if panel:IsA("Frame") and panel.BackgroundTransparency<.24 then panel.BackgroundTransparency=.24 end
 for _,d in ipairs(panel:GetDescendants()) do
  if d:IsA("Frame") then
   if d.BackgroundTransparency<.28 then d.BackgroundTransparency=.28 end
  elseif d:IsA("ScrollingFrame") then
   if d.BackgroundTransparency<.32 then d.BackgroundTransparency=.32 end
  elseif d:IsA("TextButton") then
   if d.BackgroundTransparency<.16 then d.BackgroundTransparency=.16 end
  end
 end
end

local function moveEditorToggle()
 local editor=pg:FindFirstChild("BBYAEditorUI")
 local b=editor and editor:FindFirstChild("EditorToggle",true)
 if not b or not b:IsA("GuiObject") then return end
 -- Keep EDIT available to the owner, but never on top of NOW PLAYING.
 b.AnchorPoint=Vector2.new(0,1)
 b.Position=UDim2.new(0,16,1,-16)
 b.Size=UDim2.fromOffset(60,38)
 b.ZIndex=900
end

local function enforce()
 if not resetActive() then return end
 local playerCard,libraryCard=core()
 if not playerCard or not libraryCard then return end
 local v=currentVenue();local spec=VENUES[v] or VENUES.NONE
 local musicFrame=playerCard.Parent
 local empty=ensureEmpty(libraryCard)
 removeLegacyLibrary(libraryCard,empty)
 hideTransport()
 syncPlayerCard(playerCard,spec)
 syncVenueChip(musicFrame,spec)
 local header=findHeader();local pageTitle,pageSub=headerLabels(header)
 if pageTitle and musicFrame and musicFrame.Visible then pageTitle.Text=spec.title end
 if pageSub and musicFrame and musicFrame.Visible then pageSub.Text=spec.sub end
 local emptyTitle=empty and empty:FindFirstChild("EmptyTitle")
 local emptySub=empty and empty:FindFirstChild("EmptySub")
 local stroke=empty and empty:FindFirstChild("ResetStroke")
 if emptyTitle then emptyTitle.Text=spec.short.." PLAYLIST • 0 TRACKS" end
 if emptySub then emptySub.Text="Playlist dikosongkan. Susun ulang lagu untuk venue ini secara terpisah." end
 if stroke and stroke:IsA("UIStroke") then stroke.Color=spec.accent end
 makeHubTranslucent()
 moveEditorToggle()
 panel:SetAttribute("BBYAMusicPanelVenue",v)
 panel:SetAttribute("BBYAMusicPlaylistCount",0)
 panel:SetAttribute("BBYALegacyPlaylistHidden",true)
 panel:SetAttribute("BBYAResetUIVersion","V2_CLEAN")
end

panel.DescendantAdded:Connect(function()task.defer(enforce)end)
pg.ChildAdded:Connect(function()task.defer(enforce)end)
player:GetAttributeChangedSignal("BBYAAudioVenue"):Connect(function()task.defer(enforce)end)
ReplicatedStorage:GetAttributeChangedSignal("BBYAMusicCatalogReset"):Connect(function()task.defer(enforce)end)
player.CharacterAdded:Connect(function()task.delay(.5,enforce)end)

local acc=0
RunService.Heartbeat:Connect(function(dt)
 acc+=dt
 if acc<.15 then return end
 acc=0
 enforce()
end)

task.delay(1,enforce)
print("[BBYA] Music Catalog Reset UI v2: no legacy playlist ghosts / no empty transport / VIP separate / hub translucent")
