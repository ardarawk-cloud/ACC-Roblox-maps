-- BBYA SOCIAL HUB — THREE VENUE MUSIC UI v2
-- MAIN => CLUB / Progressive, UNDERGROUND => Underground / Indo, FUNKOT => Funkot / Funkot playlist.
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

local C={bg=Color3.fromRGB(13,14,19),card=Color3.fromRGB(24,25,32),pink=Color3.fromRGB(232,35,163),cyan=Color3.fromRGB(35,196,226),gold=Color3.fromRGB(232,181,79),white=Color3.fromRGB(245,245,248),muted=Color3.fromRGB(153,156,168)}
local function corner(o,r)local x=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 10);x.Parent=o end
local function stroke(o,c)local x=o:FindFirstChild("VenueStroke") or Instance.new("UIStroke");x.Name="VenueStroke";x.Color=c;x.Thickness=1;x.Transparency=.58;x.Parent=o end

local panel=gui:FindFirstChild("HubPanel")
local dock=gui:FindFirstChild("TopDock")
local playerCard=panel and panel:FindFirstChild("PlayerCard",true)
local libraryCard=panel and panel:FindFirstChild("LibraryCard",true)
if not panel or not dock or not playerCard or not libraryCard then return end

local function findMusicTab()
 for _,b in ipairs(dock:GetChildren()) do
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
 local best
 for _,d in ipairs(panel:GetDescendants()) do
  if d:IsA("TextLabel") and d.TextSize<=12 then
   local txt=string.lower(d.Text or "")
   if txt:find("channel",1,true) or txt:find("autodj",1,true) or txt:find("progressive",1,true) then best=d;break end
  end
 end
 return best
end
local function findNowTitle()
 for _,d in ipairs(playerCard:GetDescendants()) do
  if d:IsA("TextLabel") and not d.TextScaled and d.TextSize>=16 and string.upper(d.Text or "")~="BBYA" then return d end
 end
end
local function findMeta()
 for _,d in ipairs(playerCard:GetDescendants()) do
  if d:IsA("TextLabel") and d.TextSize<=10 then
   local up=string.upper(d.Text or "")
   if up:find("MAIN",1,true) or up:find("UNDERGROUND",1,true) or up:find("WESTERN",1,true) then return d end
  end
 end
end
local function findLibraryHead()
 for _,d in ipairs(libraryCard:GetDescendants()) do
  if d:IsA("TextLabel") then
   local up=string.upper(d.Text or "")
   if up:find("LIBRARY",1,true) or up:find("PLAYLIST",1,true) then return d end
  end
 end
end
local pageTitle=findTitleLabel()
local pageSub=findSubtitle()
local nowTitle=findNowTitle()
local nowMeta=findMeta()
local libHead=findLibraryHead()

local venueBadge=panel:FindFirstChild("VenueBadgeV2") or Instance.new("TextLabel")
venueBadge.Name="VenueBadgeV2";venueBadge.AnchorPoint=Vector2.new(1,0);venueBadge.Position=UDim2.new(1,-68,0,20);venueBadge.Size=UDim2.fromOffset(112,26);venueBadge.BackgroundColor3=C.card;venueBadge.BorderSizePixel=0;venueBadge.TextColor3=C.white;venueBadge.Font=Enum.Font.GothamBold;venueBadge.TextSize=9;venueBadge.ZIndex=70;venueBadge.Parent=panel;corner(venueBadge,9);stroke(venueBadge,C.pink)

local nativeScrollers={}
for _,d in ipairs(libraryCard:GetDescendants()) do if d:IsA("ScrollingFrame") then table.insert(nativeScrollers,d) end end
local funkotSearch=libraryCard:FindFirstChild("FunkotSearchV2") or Instance.new("TextBox")
funkotSearch.Name="FunkotSearchV2";funkotSearch.Position=UDim2.fromOffset(12,58);funkotSearch.Size=UDim2.new(1,-24,0,34);funkotSearch.BackgroundColor3=Color3.fromRGB(15,16,22);funkotSearch.BorderSizePixel=0;funkotSearch.PlaceholderText="Search Funkot track...";funkotSearch.PlaceholderColor3=C.muted;funkotSearch.Text="";funkotSearch.TextColor3=C.white;funkotSearch.Font=Enum.Font.Gotham;funkotSearch.TextSize=10;funkotSearch.TextXAlignment=Enum.TextXAlignment.Left;funkotSearch.ZIndex=61;funkotSearch.Visible=false;funkotSearch.Parent=libraryCard;corner(funkotSearch,9);stroke(funkotSearch,C.pink)
local pad=funkotSearch:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,12);pad.Parent=funkotSearch
local funkotList=libraryCard:FindFirstChild("FunkotPlaylistV2") or Instance.new("ScrollingFrame")
funkotList.Name="FunkotPlaylistV2";funkotList.Position=UDim2.fromOffset(12,100);funkotList.Size=UDim2.new(1,-24,1,-112);funkotList.BackgroundTransparency=1;funkotList.BorderSizePixel=0;funkotList.ScrollBarThickness=2;funkotList.AutomaticCanvasSize=Enum.AutomaticSize.Y;funkotList.CanvasSize=UDim2.new();funkotList.Visible=false;funkotList.ZIndex=61;funkotList.Parent=libraryCard
local listLayout=funkotList:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout");listLayout.Padding=UDim.new(0,7);listLayout.Parent=funkotList

local currentVenue="MAIN"
local funkotPlaylist={}
local lastFunkotState=nil

local function zone()
 local ch=player.Character
 local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 if not hrp then return "MAIN" end
 local p=hrp.Position
 if p.Y<-4.5 then return "UNDERGROUND" end
 if p.Y>-4 and p.Y<34 and math.abs(p.X)<61 and p.Z>157 and p.Z<253 then return "FUNKOT" end
 return "MAIN"
end
local function setNativeVisible(v)
 for _,s in ipairs(nativeScrollers) do if s and s.Parent then s.Visible=v end end
end
local function applyCopy(v)
 currentVenue=v
 if musicTab then
  musicTab.Text=(v=="MAIN" and "CLUB") or (v=="UNDERGROUND" and "UNDERGROUND") or "FUNKOT"
 end
 if pageTitle then pageTitle.Text=(v=="MAIN" and "CLUB") or (v=="UNDERGROUND" and "UNDERGROUND") or "FUNKOT" end
 if pageSub then
  pageSub.Text=(v=="MAIN" and "PROGRESSIVE AUTODJ • MAIN FLOOR") or (v=="UNDERGROUND" and "INDO AUTODJ • BREAKBEAT / BOUNCE") or "FUNKOT AUTODJ • REAR CLUB"
 end
 if nowMeta then
  nowMeta.Text=(v=="MAIN" and "CLUB • PROGRESSIVE") or (v=="UNDERGROUND" and "UNDERGROUND • INDO") or "FUNKOT • DEDICATED CHANNEL"
 end
 if libHead then libHead.Text=(v=="MAIN" and "CLUB PLAYLIST / REQUEST") or (v=="UNDERGROUND" and "UNDERGROUND PLAYLIST / REQUEST") or "FUNKOT PLAYLIST / REQUEST" end
 venueBadge.Text=(v=="MAIN" and "● CLUB") or (v=="UNDERGROUND" and "● UNDERGROUND") or "● FUNKOT"
 venueBadge.TextColor3=(v=="UNDERGROUND" and C.cyan) or (v=="FUNKOT" and C.gold) or C.pink
 if v=="FUNKOT" then
  setNativeVisible(false);funkotSearch.Visible=true;funkotList.Visible=true
 else
  funkotSearch.Visible=false;funkotList.Visible=false;setNativeVisible(true)
 end
end

local function filterFunkot()
 local q=string.lower(funkotSearch.Text or "")
 for _,row in ipairs(funkotList:GetChildren()) do
  if row:IsA("Frame") then row.Visible=(q=="" or string.lower(row:GetAttribute("TrackTitle") or ""):find(q,1,true)~=nil) end
 end
end
funkotSearch:GetPropertyChangedSignal("Text"):Connect(filterFunkot)

local function populateFunkot(data)
 funkotPlaylist=data or {}
 for _,c in ipairs(funkotList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
 for i,item in ipairs(funkotPlaylist) do
  local row=Instance.new("Frame");row.Name="FunkotTrack"..i;row.Size=UDim2.new(1,-4,0,52);row.BackgroundColor3=Color3.fromRGB(27,25,34);row.BorderSizePixel=0;row.ZIndex=62;row:SetAttribute("TrackTitle",tostring(item.title or ""));row.Parent=funkotList;corner(row,10);stroke(row,C.pink)
  local num=Instance.new("TextLabel");num.BackgroundTransparency=1;num.Position=UDim2.fromOffset(10,8);num.Size=UDim2.fromOffset(28,34);num.Text=string.format("%02d",i);num.TextColor3=C.pink;num.Font=Enum.Font.GothamBold;num.TextSize=10;num.ZIndex=63;num.Parent=row
  local title=Instance.new("TextLabel");title.BackgroundTransparency=1;title.Position=UDim2.fromOffset(44,5);title.Size=UDim2.new(1,-144,0,42);title.Text=tostring(item.title or "Funkot Track");title.TextWrapped=true;title.TextXAlignment=Enum.TextXAlignment.Left;title.TextColor3=C.white;title.Font=Enum.Font.GothamSemibold;title.TextSize=10;title.ZIndex=63;title.Parent=row
  local rq=Instance.new("TextButton");rq.AnchorPoint=Vector2.new(1,.5);rq.Position=UDim2.new(1,-8,.5,0);rq.Size=UDim2.fromOffset(82,34);rq.BackgroundColor3=Color3.fromRGB(72,26,61);rq.BorderSizePixel=0;rq.Text="REQUEST";rq.TextColor3=C.white;rq.Font=Enum.Font.GothamBold;rq.TextSize=9;rq.ZIndex=64;rq.Parent=row;corner(rq,9);stroke(rq,C.pink)
  rq.MouseButton1Click:Connect(function()funkotRemote:FireServer("request",i)end)
 end
 filterFunkot()
end

local function applyFunkotState(data)
 if data then lastFunkotState=data end
 if currentVenue~="FUNKOT" then return end
 if lastFunkotState and nowTitle then nowTitle.Text=tostring(lastFunkotState.title or "Funkot AutoDJ") end
 applyCopy("FUNKOT")
end
funkotRemote.OnClientEvent:Connect(function(kind,data)
 if kind=="playlist" then populateFunkot(data)
 elseif kind=="state" then applyFunkotState(data) end
end)
stateRemote.OnClientEvent:Connect(function(kind)
 if kind=="music" and currentVenue=="FUNKOT" then task.defer(function()applyFunkotState(lastFunkotState)end) end
end)
if musicTab then musicTab.MouseButton1Click:Connect(function()if currentVenue=="FUNKOT" then task.defer(function()funkotRemote:FireServer("list");applyCopy("FUNKOT")end)end end) end

local last=zone();applyCopy(last)
if last=="FUNKOT" then funkotRemote:FireServer("list") end

task.spawn(function()
 while task.wait(.15) do
  local v=zone()
  if v~=last then
   last=v;applyCopy(v)
   if v=="FUNKOT" then funkotRemote:FireServer("list") end
  elseif v=="FUNKOT" then applyFunkotState(lastFunkotState) end
 end
end)

-- 31-club-ui owns Main/Underground mixing. This later venue controller only overrides while inside Funkot.
RunService.RenderStepped:Connect(function()
 local fg=SoundService:FindFirstChild("BBYAFunkotMaster")
 if currentVenue=="FUNKOT" then
  local mg=SoundService:FindFirstChild("BBYAClubMaster");if mg then mg.Volume=0 end
  local ug=SoundService:FindFirstChild("BBYABasementMaster");if ug then ug.Volume=0 end
  if fg then fg.Volume=.96 end
 else
  if fg then fg.Volume=0 end
 end
end)

print("[BBYA] Three Venue Music UI v2: CLUB / UNDERGROUND / FUNKOT automatic switching")
