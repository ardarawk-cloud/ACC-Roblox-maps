-- BBYA SOCIAL HUB — MUSIC CATALOG RESET UI v1
-- Shows an honest empty catalog after the owner-requested reset.
-- VIP has its own music panel identity/channel instead of inheriting CLUB.

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local gui=pg:WaitForChild("BBYAClubUI",30)
if not gui then return end
local panel=gui:WaitForChild("HubPanel",30)
if not panel then return end
local playerCard=panel:FindFirstChild("PlayerCard",true)
local libraryCard=panel:FindFirstChild("LibraryCard",true)
if not playerCard or not libraryCard then return end
local musicFrame=playerCard.Parent

local VENUES={
 MAIN={title="CLUB MUSIC",sub="MAIN CLUB • PLAYLIST RESET",short="CLUB",accent=Color3.fromRGB(232,38,165)},
 UNDERGROUND={title="UNDERGROUND MUSIC",sub="UNDERGROUND • PLAYLIST RESET",short="UNDERGROUND",accent=Color3.fromRGB(39,196,225)},
 VIP={title="VIP MUSIC",sub="PRIVATE CLUB • SEPARATE CHANNEL",short="VIP",accent=Color3.fromRGB(220,173,86)},
 FUNKOT={title="FUNKOT MUSIC",sub="FUNKOT • PLAYLIST RESET",short="FUNKOT",accent=Color3.fromRGB(143,82,255)},
 SKATEPARK={title="SKATEPARK MUSIC",sub="SKATEPARK • PLAYLIST RESET",short="SKATEPARK",accent=Color3.fromRGB(39,196,225)},
 ROOFTOP={title="ROOFTOP MUSIC",sub="ROOFTOP • PLAYLIST RESET",short="ROOFTOP",accent=Color3.fromRGB(220,173,86)},
 NONE={title="MUSIC",sub="NO VENUE AUDIO HERE",short="NONE",accent=Color3.fromRGB(151,155,168)},
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
 local v=player:GetAttribute("BBYAAudioVenue")
 if VENUES[v] then return v end
 local ch=player.Character;local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 return hrp and venueAtPosition(hrp.Position) or "NONE"
end

local header
for _,f in ipairs(panel:GetChildren()) do
 if f:IsA("Frame") then
  for _,d in ipairs(f:GetChildren()) do
   if d:IsA("TextButton") and (d.Text=="×" or d.Text=="X") then header=f;break end
  end
 end
 if header then break end
end
local pageTitle,pageSub
if header then
 for _,d in ipairs(header:GetChildren()) do
  if d:IsA("TextLabel") then
   if d.TextSize>=16 then pageTitle=pageTitle or d else pageSub=pageSub or d end
  end
 end
end

local nowSmall,nowTitle,nowMeta,statusText,eqHolder
for _,d in ipairs(playerCard:GetChildren()) do
 if d:IsA("TextLabel") then
  local up=string.upper(d.Text or "")
  if up=="NOW PLAYING" then nowSmall=d
  elseif d.TextSize>=16 then nowTitle=nowTitle or d
  elseif up:find("PROGRESSIVE",1,true) or up:find("UNDERGROUND",1,true) or up:find("FUNKOT",1,true) or up:find("CLUB",1,true) then nowMeta=nowMeta or d end
 elseif d:IsA("Frame") then
  local bars=0
  for _,x in ipairs(d:GetChildren()) do if x:IsA("Frame") then bars+=1 end end
  if bars>=10 then eqHolder=d end
  for _,x in ipairs(d:GetDescendants()) do
   if x:IsA("TextLabel") and (string.upper(x.Text or ""):find("PLAYING",1,true) or string.upper(x.Text or ""):find("LIVE",1,true) or string.upper(x.Text or ""):find("PAUSED",1,true)) then statusText=x end
  end
 end
end

local empty=libraryCard:FindFirstChild("MusicCatalogEmptyV1")
if not empty then
 empty=Instance.new("Frame");empty.Name="MusicCatalogEmptyV1";empty.Position=UDim2.fromOffset(12,42);empty.Size=UDim2.new(1,-24,1,-54);empty.BackgroundColor3=Color3.fromRGB(18,19,25);empty.BackgroundTransparency=.38;empty.BorderSizePixel=0;empty.ZIndex=160;empty.Parent=libraryCard
 local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,10);c.Parent=empty
 local s=Instance.new("UIStroke");s.Name="ResetStroke";s.Thickness=1;s.Transparency=.5;s.Parent=empty
 local big=Instance.new("TextLabel");big.Name="EmptyTitle";big.BackgroundTransparency=1;big.Position=UDim2.fromOffset(18,14);big.Size=UDim2.new(1,-36,0,28);big.Text="PLAYLIST KOSONG";big.Font=Enum.Font.GothamBold;big.TextSize=14;big.TextColor3=Color3.fromRGB(246,246,249);big.TextXAlignment=Enum.TextXAlignment.Left;big.ZIndex=161;big.Parent=empty
 local sub=Instance.new("TextLabel");sub.Name="EmptySub";sub.BackgroundTransparency=1;sub.Position=UDim2.fromOffset(18,44);sub.Size=UDim2.new(1,-36,0,38);sub.Text="0 TRACKS • playlist sedang disusun ulang";sub.Font=Enum.Font.Gotham;sub.TextSize=10;sub.TextColor3=Color3.fromRGB(160,163,174);sub.TextXAlignment=Enum.TextXAlignment.Left;sub.TextWrapped=true;sub.ZIndex=161;sub.Parent=empty
end

local function hideLegacyCatalog()
 for _,d in ipairs(libraryCard:GetDescendants()) do
  if d:IsA("ScrollingFrame") then d.Visible=false
  elseif d:IsA("TextButton") and string.upper(d.Text or ""):find("REQUEST",1,true) then d.Visible=false end
 end
 for _,d in ipairs(playerCard:GetDescendants()) do
  if d:IsA("TextButton") then
   local up=string.upper(d.Text or "")
   if up=="NEXT" or up=="PREV" or up=="PREVIOUS" or up=="PAUSE" or up=="RESUME" then d.Visible=false end
  end
 end
end

local lastVenue
local function enforce()
 hideLegacyCatalog()
 if eqHolder then eqHolder.Visible=false end
 empty.Visible=true
 local v=currentVenue();local spec=VENUES[v] or VENUES.NONE
 panel:SetAttribute("BBYAMusicPanelVenue",v)
 panel:SetAttribute("BBYAMusicPlaylistCount",0)
 if pageTitle and musicFrame.Visible then pageTitle.Text=spec.title end
 if pageSub and musicFrame.Visible then pageSub.Text=spec.sub end
 if nowSmall then nowSmall.Text="NOW PLAYING" end
 if nowTitle then nowTitle.Text="BELUM ADA LAGU" end
 if nowMeta then nowMeta.Text=spec.short.." • 0 TRACKS • SEPARATE VENUE CHANNEL";nowMeta.TextColor3=spec.accent end
 if statusText then statusText.Text="●  READY";statusText.TextColor3=spec.accent end
 local emptyTitle=empty:FindFirstChild("EmptyTitle");if emptyTitle then emptyTitle.Text=spec.short.." PLAYLIST • 0 TRACKS" end
 local emptySub=empty:FindFirstChild("EmptySub");if emptySub then emptySub.Text="Playlist dikosongkan. Susun ulang lagu untuk venue ini secara terpisah." end
 local stroke=empty:FindFirstChild("ResetStroke");if stroke and stroke:IsA("UIStroke") then stroke.Color=spec.accent end
 -- Replace legacy venue chip text without changing button behavior/layout.
 for _,d in ipairs(musicFrame:GetDescendants()) do
  if d:IsA("TextLabel") or d:IsA("TextButton") then
   local up=string.upper(d.Text or "")
   if up=="● CLUB" or up=="CLUB" or up=="● UNDERGROUND" or up=="● FUNKOT" then d.Text="● "..spec.short end
  end
 end
 if v~=lastVenue then lastVenue=v end
end

libraryCard.DescendantAdded:Connect(function()task.defer(enforce)end)
player:GetAttributeChangedSignal("BBYAAudioVenue"):Connect(function()task.defer(enforce)end)
player.CharacterAdded:Connect(function()task.delay(.5,enforce)end)
local acc=0
RunService.Heartbeat:Connect(function(dt)acc+=dt;if acc>=.25 then acc=0;enforce() end end)
task.delay(1,enforce)

print("[BBYA] Music Catalog Reset UI v1: honest 0-track panels / VIP separated from CLUB")
