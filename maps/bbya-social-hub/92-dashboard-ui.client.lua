-- BBYA SOCIAL HUB — DASHBOARD UI UPGRADE v1
-- Visual upgrade inspired by modern music dashboards; keeps existing functional remotes and pages.
local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local gui=pg:WaitForChild("BBYAClubUI",30)
if not gui then return end

local C={bg=Color3.fromRGB(8,9,13),panel=Color3.fromRGB(14,15,20),card=Color3.fromRGB(22,23,30),card2=Color3.fromRGB(28,29,38),line=Color3.fromRGB(59,61,75),pink=Color3.fromRGB(227,31,166),purple=Color3.fromRGB(133,72,255),cyan=Color3.fromRGB(43,198,229),white=Color3.fromRGB(244,244,247),muted=Color3.fromRGB(151,154,166),green=Color3.fromRGB(61,210,132)}
local function corner(o,r)local x=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 12);x.Parent=o end
local function stroke(o,color,t,tr)local x=o:FindFirstChild("BBYADashboardStroke") or Instance.new("UIStroke");x.Name="BBYADashboardStroke";x.Color=color or C.line;x.Thickness=t or 1;x.Transparency=tr or .48;x.Parent=o end
local function gradient(o,a,b,rotation)
 local g=o:FindFirstChild("BBYADashboardGradient") or Instance.new("UIGradient");g.Name="BBYADashboardGradient";g.Color=ColorSequence.new(a,b);g.Rotation=rotation or 0;g.Parent=o
end
local function findText(value)
 for _,d in ipairs(gui:GetDescendants()) do if d:IsA("TextLabel") and string.upper(d.Text or "")==string.upper(value) then return d end end
end

local panel=gui:FindFirstChild("HubPanel")
local dock=gui:FindFirstChild("TopDock")
if panel then
 panel.BackgroundColor3=C.bg;panel.BackgroundTransparency=.02;corner(panel,18);stroke(panel,C.purple,1.15,.46)
 local shadow=panel:FindFirstChild("DashboardShadow") or Instance.new("ImageLabel")
 shadow.Name="DashboardShadow";shadow.AnchorPoint=Vector2.new(.5,.5);shadow.Position=UDim2.fromScale(.5,.51);shadow.Size=UDim2.new(1,42,1,42);shadow.BackgroundTransparency=1;shadow.Image="rbxassetid://1316045217";shadow.ImageColor3=Color3.new(0,0,0);shadow.ImageTransparency=.45;shadow.ScaleType=Enum.ScaleType.Slice;shadow.SliceCenter=Rect.new(10,10,118,118);shadow.ZIndex=0;shadow.Parent=panel
 local topLine=panel:FindFirstChild("DashboardAccent") or Instance.new("Frame")
 topLine.Name="DashboardAccent";topLine.Position=UDim2.fromOffset(22,72);topLine.Size=UDim2.new(1,-44,0,2);topLine.BorderSizePixel=0;topLine.BackgroundColor3=C.pink;topLine.ZIndex=3;topLine.Parent=panel;gradient(topLine,C.pink,C.cyan,0)
end
if dock then
 dock.BackgroundColor3=Color3.fromRGB(11,12,17);dock.BackgroundTransparency=.04;corner(dock,15);stroke(dock,C.line,1,.52)
 gradient(dock,Color3.fromRGB(16,14,24),Color3.fromRGB(9,15,20),0)
 for _,b in ipairs(dock:GetChildren()) do
  if b:IsA("TextButton") then b.BackgroundColor3=Color3.fromRGB(21,22,29);b.TextColor3=C.white;corner(b,10);stroke(b,C.line,1,.62) end
 end
end

local title=findText("MUSIC SYSTEM")
if title then title.Text="MUSIC DASHBOARD";title.TextColor3=C.white;title.Font=Enum.Font.GothamBlack end
local subtitle
for _,d in ipairs(gui:GetDescendants()) do
 if d:IsA("TextLabel") and (d.Text or ""):lower():find("progressive channel",1,true) then subtitle=d;break end
end
if subtitle then subtitle.Text="MAIN CLUB • PROGRESSIVE • LIVE AUTODJ";subtitle.TextColor3=C.muted end

local playerCard=panel and panel:FindFirstChild("PlayerCard",true)
local libraryCard=panel and panel:FindFirstChild("LibraryCard",true)
for _,card in ipairs({playerCard,libraryCard}) do
 if card and card:IsA("Frame") then card.BackgroundColor3=C.card;corner(card,15);stroke(card,C.line,1,.58) end
end
if playerCard then
 local accent=playerCard:FindFirstChild("DashboardPlayerAccent") or Instance.new("Frame");accent.Name="DashboardPlayerAccent";accent.Size=UDim2.new(1,0,0,3);accent.BackgroundColor3=C.pink;accent.BorderSizePixel=0;accent.Parent=playerCard;gradient(accent,C.pink,C.purple,0)
 local live=playerCard:FindFirstChild("OnlineAboveBBYA") or Instance.new("TextLabel")
 live.Name="OnlineAboveBBYA";live.AnchorPoint=Vector2.new(.5,0);live.Position=UDim2.new(.5,0,0,5);live.Size=UDim2.fromOffset(92,22);live.BackgroundColor3=Color3.fromRGB(16,48,36);live.BackgroundTransparency=.04;live.BorderSizePixel=0;live.Text="●  ONLINE";live.TextColor3=C.green;live.Font=Enum.Font.GothamBold;live.TextSize=9;live.ZIndex=65;live.Parent=playerCard;corner(live,9);stroke(live,C.green,1,.55)
end
if libraryCard then
 local lib=findText("LIBRARY / REQUEST");if lib then lib.Text="MUSIC LIBRARY";lib.Font=Enum.Font.GothamBlack;lib.TextColor3=C.white end
 local search=libraryCard:FindFirstChild("DashboardSearch") or Instance.new("TextBox")
 search.Name="DashboardSearch";search.Position=UDim2.new(0,12,0,58);search.Size=UDim2.new(1,-24,0,34);search.BackgroundColor3=Color3.fromRGB(15,16,22);search.BorderSizePixel=0;search.PlaceholderText="Search track...";search.PlaceholderColor3=C.muted;search.Text="";search.ClearTextOnFocus=false;search.TextColor3=C.white;search.Font=Enum.Font.Gotham;search.TextSize=10;search.TextXAlignment=Enum.TextXAlignment.Left;search.ZIndex=30;search.Parent=libraryCard;corner(search,9);stroke(search,C.line,1,.55)
 local pad=search:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,12);pad.Parent=search
 local list
 for _,d in ipairs(libraryCard:GetDescendants()) do if d:IsA("ScrollingFrame") then list=d;break end end
 if list then
  list.Position=UDim2.new(0,12,0,100);list.Size=UDim2.new(1,-24,1,-112);list.ScrollBarThickness=2;list.ScrollBarImageColor3=C.purple
  local function filter()
   local q=string.lower(search.Text or "")
   for _,row in ipairs(list:GetChildren()) do
    if row:IsA("Frame") then
     local hay=""
     for _,d in ipairs(row:GetDescendants()) do if d:IsA("TextLabel") then hay=hay.." "..string.lower(d.Text or "") end end
     row.Visible=(q=="" or hay:find(q,1,true)~=nil)
     row.BackgroundColor3=C.card2;corner(row,10);stroke(row,C.line,1,.67)
    end
   end
  end
  search:GetPropertyChangedSignal("Text"):Connect(filter)
  list.ChildAdded:Connect(function()task.defer(filter)end)
  task.defer(filter)
 end
end

-- Upgrade all page cards without altering their functional hierarchy.
for _,d in ipairs(gui:GetDescendants()) do
 if d:IsA("Frame") and d~=panel and d~=dock and d.BackgroundTransparency<.95 then
  if d.Name:find("Card") or d.Name:find("Destination") or d.Name:find("Support") then
   d.BackgroundColor3=C.card;corner(d,12)
  end
 elseif d:IsA("TextButton") then
  if d.Text=="REQUEST" then d.BackgroundColor3=Color3.fromRGB(70,25,63);d.TextColor3=C.white;corner(d,9);stroke(d,C.pink,1,.62) end
 end
end

print("[BBYA] Dashboard UI v1 online: modern music dashboard / online above BBYA / searchable library")
