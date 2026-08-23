-- BBYA SOCIAL HUB — THREE VENUE MUSIC UI v4
-- Playlist-first UI: CLUB / UNDERGROUND / FUNKOT all show their actual request list.
-- Removed the empty-search-first Funkot experience. Venue switching remains automatic.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local gui=pg:WaitForChild("BBYAClubUI",30)
if not gui then return end
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local funkotRemote=remotes:WaitForChild("FunkotMusic",30)
local stateRemote=remotes:WaitForChild("State",30)

local C={bg=Color3.fromRGB(11,12,17),card=Color3.fromRGB(22,23,30),card2=Color3.fromRGB(31,31,40),pink=Color3.fromRGB(232,35,163),cyan=Color3.fromRGB(35,196,226),gold=Color3.fromRGB(232,181,79),white=Color3.fromRGB(245,245,248),muted=Color3.fromRGB(153,156,168),line=Color3.fromRGB(65,67,79)}
local function corner(o,r)local x=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 10);x.Parent=o end
local function stroke(o,c,tr)local x=o:FindFirstChild("VenueStroke") or Instance.new("UIStroke");x.Name="VenueStroke";x.Color=c;x.Thickness=1;x.Transparency=tr or .58;x.Parent=o end

local panel=gui:FindFirstChild("HubPanel")
local dock=gui:FindFirstChild("TopDock")
local playerCard=panel and panel:FindFirstChild("PlayerCard",true)
local libraryCard=panel and panel:FindFirstChild("LibraryCard",true)
if not panel or not dock or not playerCard or not libraryCard then return end
playerCard.BackgroundColor3=C.card;libraryCard.BackgroundColor3=C.card;corner(playerCard,14);corner(libraryCard,14);stroke(playerCard,C.line,.62);stroke(libraryCard,C.line,.50)

local function findMusicTab()
 -- The command menu reparents the original button, so search the whole BBYA UI tree.
 for _,b in ipairs(gui:GetDescendants()) do
  if b:IsA("TextButton") then
   local up=string.upper(b.Text or "")
   if up:find("MUSIC",1,true) or up=="CLUB" or up=="UNDERGROUND" or up=="FUNKOT" then return b end
  end
 end
end
local musicTab=findMusicTab()
local function findTitleLabel()
 for _,d in ipairs(panel:GetDescendants()) do
  if d:IsA("TextLabel") and d.TextSize>=17 and not d.TextScaled then
   local up=string.upper(d.Text or "")
   if up=="MUSIC SYSTEM" or up=="MUSIC DASHBOARD" or up=="CLUB" or up=="UNDERGROUND" or up=="FUNKOT" or up=="UNDERGROUND / INDO ROOM" then return d end
  end
 end
end
local function findSubtitle()
 for _,d in ipairs(panel:GetDescendants()) do
  if d:IsA("TextLabel") and d.TextSize<=12 then
   local txt=string.lower(d.Text or "")
   if txt:find("channel",1,true) or txt:find("autodj",1,true) or txt:find("progressive",1,true) then return d end
  end
 end
end
local function findNowTitle()
 for _,d in ipairs(playerCard:GetDescendants()) do if d:IsA("TextLabel") and not d.TextScaled and d.TextSize>=16 and string.upper(d.Text or "")~="BBYA" then return d end end
end
local function findMeta()
 for _,d in ipairs(playerCard:GetDescendants()) do
  if d:IsA("TextLabel") and d.TextSize<=10 then local up=string.upper(d.Text or "");if up:find("MAIN",1,true) or up:find("UNDERGROUND",1,true) or up:find("WESTERN",1,true) then return d end end
 end
end
local function findLibraryHead()
 for _,d in ipairs(libraryCard:GetDescendants()) do if d:IsA("TextLabel") then local up=string.upper(d.Text or "");if up:find("LIBRARY",1,true) or up:find("PLAYLIST",1,true) then return d end end end
end
local pageTitle=findTitleLabel();local pageSub=findSubtitle();local nowTitle=findNowTitle();local nowMeta=findMeta();local libHead=findLibraryHead()

local venueBadge=panel:FindFirstChild("VenueBadgeV4") or Instance.new("TextLabel")
venueBadge.Name="VenueBadgeV4";venueBadge.AnchorPoint=Vector2.new(1,0);venueBadge.Position=UDim2.new(1,-68,0,44);venueBadge.Size=UDim2.fromOffset(112,26);venueBadge.BackgroundColor3=C.card2;venueBadge.BorderSizePixel=0;venueBadge.TextColor3=C.white;venueBadge.Font=Enum.Font.GothamBold;venueBadge.TextSize=9;venueBadge.ZIndex=70;venueBadge.Parent=panel;corner(venueBadge,9);stroke(venueBadge,C.pink,.52)

-- Main / Underground playlist scroller is created by 31-club-ui. Keep it front-and-center.
local nativeScrollers={}
for _,d in ipairs(libraryCard:GetDescendants()) do
 if d:IsA("ScrollingFrame") and d.Name~="FunkotPlaylistV4" then
  table.insert(nativeScrollers,d);d.Position=UDim2.fromOffset(12,58);d.Size=UDim2.new(1,-24,1,-70);d.ZIndex=61;d.Active=true;d.ScrollingEnabled=true;d.ScrollBarThickness=4
 end
end
libraryCard.DescendantAdded:Connect(function(d)
 if d:IsA("ScrollingFrame") and d.Name~="FunkotPlaylistV4" then
  task.defer(function()if d.Parent then d.Position=UDim2.fromOffset(12,58);d.Size=UDim2.new(1,-24,1,-70);d.ZIndex=61;d.Active=true;d.ScrollingEnabled=true;d.ScrollBarThickness=4;table.insert(nativeScrollers,d) end end)
 end
end)

-- Remove the old Funkot search-first controls if a stale instance exists.
for _,name in ipairs({"FunkotSearchV2","FunkotPlaylistV2","FunkotSearchV3","FunkotPlaylistV3"}) do local x=libraryCard:FindFirstChild(name);if x then x:Destroy() end end
local funkotList=Instance.new("ScrollingFrame")
funkotList.Name="FunkotPlaylistV4";funkotList.Position=UDim2.fromOffset(12,58);funkotList.Size=UDim2.new(1,-24,1,-70);funkotList.BackgroundTransparency=1;funkotList.BorderSizePixel=0
funkotList.ScrollBarThickness=4;funkotList.AutomaticCanvasSize=Enum.AutomaticSize.Y;funkotList.CanvasSize=UDim2.new();funkotList.Visible=false;funkotList.Active=true;funkotList.ScrollingEnabled=true;funkotList.ZIndex=61;funkotList.Parent=libraryCard
local listLayout=Instance.new("UIListLayout");listLayout.Padding=UDim.new(0,7);listLayout.Parent=funkotList
local listPad=Instance.new("UIPadding");listPad.PaddingBottom=UDim.new(0,28);listPad.Parent=funkotList

local currentVenue="MAIN"
local lastFunkotState=nil
local counts={MAIN=0,UNDERGROUND=0,FUNKOT=0}

local function zone()
 local ch=player.Character;local hrp=ch and ch:FindFirstChild("HumanoidRootPart");if not hrp then return "MAIN" end
 local p=hrp.Position;if p.Y<-4.5 then return "UNDERGROUND" end
 if p.Y>-4 and p.Y<34 and math.abs(p.X)<61 and p.Z>157 and p.Z<253 then return "FUNKOT" end
 return "MAIN"
end
local function setNativeVisible(v)for _,s in ipairs(nativeScrollers) do if s and s.Parent then s.Visible=v end end end
local function updateLibraryHead()
 if not libHead then return end
 local count=counts[currentVenue] or 0
 local prefix=(currentVenue=="MAIN" and "CLUB PLAYLIST") or (currentVenue=="UNDERGROUND" and "UNDERGROUND PLAYLIST") or "FUNKOT PLAYLIST"
 libHead.Text=count>0 and string.format("%s • %d TRACKS",prefix,count) or (prefix.." / REQUEST")
end
local function applyCopy(v)
 currentVenue=v
 if not musicTab or not musicTab.Parent then musicTab=findMusicTab() end
 if musicTab then musicTab.Text=(v=="MAIN" and "CLUB") or (v=="UNDERGROUND" and "UNDERGROUND") or "FUNKOT" end
 if pageTitle then pageTitle.Text=(v=="MAIN" and "CLUB MUSIC") or (v=="UNDERGROUND" and "UNDERGROUND MUSIC") or "FUNKOT MUSIC" end
 if pageSub then pageSub.Text=(v=="MAIN" and "PROGRESSIVE AUTODJ • MAIN FLOOR") or (v=="UNDERGROUND" and "BREAKBEAT / INDO BOUNCE • UNDERGROUND") or "FUNKOT AUTODJ • REAR CLUB" end
 if nowMeta then nowMeta.Text=(v=="MAIN" and "CLUB • PROGRESSIVE") or (v=="UNDERGROUND" and "UNDERGROUND • INDO") or "FUNKOT • DEDICATED CHANNEL" end
 venueBadge.Text=(v=="MAIN" and "● CLUB") or (v=="UNDERGROUND" and "● UNDERGROUND") or "● FUNKOT"
 venueBadge.TextColor3=(v=="UNDERGROUND" and C.cyan) or (v=="FUNKOT" and C.gold) or C.pink
 if v=="FUNKOT" then setNativeVisible(false);funkotList.Visible=true else funkotList.Visible=false;setNativeVisible(true) end
 updateLibraryHead()
end

local function populateFunkot(data)
 counts.FUNKOT=#(data or {})
 for _,c in ipairs(funkotList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
 for i,item in ipairs(data or {}) do
  local row=Instance.new("Frame");row.Name="FunkotTrack"..i;row.Size=UDim2.new(1,-4,0,54);row.BackgroundColor3=C.card2;row.BorderSizePixel=0;row.ZIndex=62;row.Parent=funkotList;corner(row,10);stroke(row,C.pink,.62)
  local num=Instance.new("TextLabel");num.BackgroundTransparency=1;num.Position=UDim2.fromOffset(9,8);num.Size=UDim2.fromOffset(30,36);num.Text=string.format("%02d",i);num.TextColor3=C.gold;num.Font=Enum.Font.GothamBold;num.TextSize=10;num.ZIndex=63;num.Parent=row
  local title=Instance.new("TextLabel");title.BackgroundTransparency=1;title.Position=UDim2.fromOffset(44,5);title.Size=UDim2.new(1,-142,0,44);title.Text=tostring(item.title or "Funkot Track");title.TextWrapped=true;title.TextXAlignment=Enum.TextXAlignment.Left;title.TextYAlignment=Enum.TextYAlignment.Center;title.TextColor3=C.white;title.Font=Enum.Font.GothamSemibold;title.TextSize=10;title.ZIndex=63;title.Parent=row
  local rq=Instance.new("TextButton");rq.AnchorPoint=Vector2.new(1,.5);rq.Position=UDim2.new(1,-8,.5,0);rq.Size=UDim2.fromOffset(82,34);rq.BackgroundColor3=Color3.fromRGB(72,26,61);rq.BorderSizePixel=0;rq.Text="REQUEST";rq.TextColor3=C.white;rq.Font=Enum.Font.GothamBold;rq.TextSize=9;rq.ZIndex=64;rq.Parent=row;corner(rq,9);stroke(rq,C.pink,.55)
  rq.Activated:Connect(function()funkotRemote:FireServer("request",i)end)
 end
 updateLibraryHead()
end

local function applyFunkotState(data)
 if data then lastFunkotState=data end
 if currentVenue=="FUNKOT" and lastFunkotState and nowTitle then nowTitle.Text=tostring(lastFunkotState.title or "Funkot AutoDJ") end
end
funkotRemote.OnClientEvent:Connect(function(kind,data)
 if kind=="playlist" then populateFunkot(data) elseif kind=="state" then applyFunkotState(data) end
end)
stateRemote.OnClientEvent:Connect(function(kind,data)
 if kind=="playlist" and type(data)=="table" and currentVenue~="FUNKOT" then counts[currentVenue]=#data;task.defer(updateLibraryHead)
 elseif kind=="music" and currentVenue=="FUNKOT" then task.defer(function()applyFunkotState(lastFunkotState)end) end
end)

local last=zone();applyCopy(last);if last=="FUNKOT" then funkotRemote:FireServer("list") end

task.spawn(function()
 while task.wait(.25) do
  local v=zone()
  if v~=last then last=v;applyCopy(v);if v=="FUNKOT" then funkotRemote:FireServer("list") end
  else applyCopy(v);if v=="FUNKOT" then applyFunkotState(lastFunkotState) end end
 end
end)

-- 31-club-ui owns Main/Underground mixing. This controller only owns Funkot override.
RunService.RenderStepped:Connect(function()
 local fg=SoundService:FindFirstChild("BBYAFunkotMaster")
 if currentVenue=="FUNKOT" then
  local mg=SoundService:FindFirstChild("BBYAClubMaster");if mg then mg.Volume=0 end
  local ug=SoundService:FindFirstChild("BBYABasementMaster");if ug then ug.Volume=0 end
  if fg then fg.Volume=.96 end
 else if fg then fg.Volume=0 end end
end)

task.defer(function()if last=="FUNKOT" then funkotRemote:FireServer("list") end end)
print("[BBYA] Three Venue Music UI v4: playlist-first CLUB / UNDERGROUND / FUNKOT, no empty search panel")
