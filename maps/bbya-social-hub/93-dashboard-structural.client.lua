-- BBYA SOCIAL HUB — STRUCTURAL DASHBOARD UI v2
-- Noticeable dashboard rebuild: sidebar, wider library, glass header, venue rail, responsive landscape layout.
local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local gui=pg:WaitForChild("BBYAClubUI",30)
if not gui then return end
local camera=workspace.CurrentCamera
local C={bg=Color3.fromRGB(7,8,12),rail=Color3.fromRGB(11,12,17),card=Color3.fromRGB(20,21,28),card2=Color3.fromRGB(27,28,36),line=Color3.fromRGB(57,59,72),pink=Color3.fromRGB(230,34,164),purple=Color3.fromRGB(133,70,255),cyan=Color3.fromRGB(42,197,226),white=Color3.fromRGB(246,246,248),muted=Color3.fromRGB(144,148,160),green=Color3.fromRGB(64,210,133)}
local function corner(o,r)local x=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 12);x.Parent=o end
local function stroke(o,c,t,tr)local x=o:FindFirstChild("DashV2Stroke") or Instance.new("UIStroke");x.Name="DashV2Stroke";x.Color=c or C.line;x.Thickness=t or 1;x.Transparency=tr or .55;x.Parent=o end
local function label(parent,name,value,pos,size,font,ts,color)
 local l=parent:FindFirstChild(name) or Instance.new("TextLabel");l.Name=name;l.BackgroundTransparency=1;l.Text=value;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 11;l.TextColor3=color or C.white;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=parent;return l
end

local panel=gui:FindFirstChild("HubPanel")
local dock=gui:FindFirstChild("TopDock")
if not panel or not dock then return end
panel.ClipsDescendants=true

local rail=panel:FindFirstChild("DashboardSideRailV2") or Instance.new("Frame")
rail.Name="DashboardSideRailV2";rail.BackgroundColor3=C.rail;rail.BorderSizePixel=0;rail.ZIndex=8;rail.Parent=panel
local railAccent=rail:FindFirstChild("Accent") or Instance.new("Frame")
railAccent.Name="Accent";railAccent.Position=UDim2.fromOffset(0,0);railAccent.Size=UDim2.new(0,3,1,0);railAccent.BorderSizePixel=0;railAccent.BackgroundColor3=C.pink;railAccent.ZIndex=9;railAccent.Parent=rail
local grad=railAccent:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient");grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.pink),ColorSequenceKeypoint.new(.52,C.purple),ColorSequenceKeypoint.new(1,C.cyan)});grad.Rotation=90;grad.Parent=railAccent
label(rail,"Brand","BBYA",UDim2.fromOffset(18,22),UDim2.new(1,-28,0,32),Enum.Font.GothamBlack,23,C.white)
label(rail,"Sub","SOCIAL HUB",UDim2.fromOffset(18,52),UDim2.new(1,-28,0,18),Enum.Font.GothamBold,8,C.muted)
local live=label(rail,"Live","●  LIVE",UDim2.fromOffset(18,88),UDim2.new(1,-32,0,26),Enum.Font.GothamBold,9,C.green);live.BackgroundTransparency=0;live.BackgroundColor3=Color3.fromRGB(15,43,32);corner(live,8);stroke(live,C.green,1,.65)
label(rail,"NavHead","VENUES",UDim2.fromOffset(18,142),UDim2.new(1,-28,0,18),Enum.Font.GothamBold,8,C.muted)
local clubs={
 {"RailClub","CLUB",C.pink,170},
 {"RailUnder","UNDERGROUND",C.cyan,204},
 {"RailFunkot","FUNKOT",C.purple,238},
}
for _,v in ipairs(clubs) do
 local t=label(rail,v[1],v[2],UDim2.fromOffset(18,v[4]),UDim2.new(1,-28,0,26),Enum.Font.GothamBold,9,C.white);t.BackgroundTransparency=.18;t.BackgroundColor3=Color3.fromRGB(24,25,33);corner(t,7);stroke(t,v[3],1,.72)
end
label(rail,"StatsHead","SYSTEM",UDim2.fromOffset(18,300),UDim2.new(1,-28,0,18),Enum.Font.GothamBold,8,C.muted)
label(rail,"Stat1","3 VENUES",UDim2.fromOffset(18,326),UDim2.new(1,-28,0,20),Enum.Font.GothamBold,9,C.white)
label(rail,"Stat2","AUTO DJ",UDim2.fromOffset(18,350),UDim2.new(1,-28,0,20),Enum.Font.GothamBold,9,C.white)
label(rail,"Stat3","LIVE REQUEST",UDim2.fromOffset(18,374),UDim2.new(1,-28,0,20),Enum.Font.GothamBold,9,C.white)

local topGlass=panel:FindFirstChild("DashboardTopGlassV2") or Instance.new("Frame")
topGlass.Name="DashboardTopGlassV2";topGlass.BackgroundColor3=Color3.fromRGB(12,13,19);topGlass.BackgroundTransparency=.12;topGlass.BorderSizePixel=0;topGlass.ZIndex=4;topGlass.Parent=panel;corner(topGlass,12);stroke(topGlass,C.line,1,.62)
local topGrad=topGlass:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient");topGrad.Color=ColorSequence.new(Color3.fromRGB(26,18,34),Color3.fromRGB(10,18,24));topGrad.Rotation=0;topGrad.Parent=topGlass

local header
local divider
local content
for _,c in ipairs(panel:GetChildren()) do
 if c:IsA("Frame") and c~=rail and c~=topGlass then
  if c.Position.Y.Offset<=20 and c.Size.Y.Offset>=45 and c.BackgroundTransparency>.8 then header=header or c
  elseif c.Size.Y.Offset<=3 and c.Position.Y.Offset>60 and c.Position.Y.Offset<90 then divider=divider or c
  elseif c.Position.Y.Offset>=85 and c.Size.Y.Scale>.5 then content=content or c end
 end
end
local playerCard=panel:FindFirstChild("PlayerCard",true)
local libraryCard=panel:FindFirstChild("LibraryCard",true)
if playerCard then playerCard.BackgroundColor3=C.card;corner(playerCard,15);stroke(playerCard,C.line,1,.62) end
if libraryCard then libraryCard.BackgroundColor3=C.card;corner(libraryCard,15);stroke(libraryCard,C.line,1,.62) end

local function polishRows()
 if not libraryCard then return end
 for _,d in ipairs(libraryCard:GetDescendants()) do
  if d:IsA("Frame") and d.Name~="LibraryCard" and d.Size.Y.Offset>=40 and d.Size.Y.Offset<=62 then
   d.BackgroundColor3=C.card2;corner(d,10);stroke(d,C.line,1,.72)
  elseif d:IsA("TextButton") and string.upper(d.Text or "")=="REQUEST" then
   d.BackgroundColor3=Color3.fromRGB(72,25,61);corner(d,9);stroke(d,C.pink,1,.62)
  end
 end
end
if libraryCard then libraryCard.DescendantAdded:Connect(function()task.defer(polishRows)end) end

local applying=false
local function apply()
 if applying then return end;applying=true
 camera=workspace.CurrentCamera or camera
 local vp=camera and camera.ViewportSize or Vector2.new(1280,720)
 local touch=UserInputService.TouchEnabled
 local panelW=math.clamp(math.floor(vp.X*(touch and .84 or .76)),720,1040)
 local panelH=math.clamp(math.floor(vp.Y*(touch and .76 or .78)),430,590)
 panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.54);panel.Size=UDim2.fromOffset(panelW,panelH);panel.BackgroundColor3=C.bg
 local railW=math.clamp(math.floor(panelW*.145),112,146)
 rail.Position=UDim2.fromOffset(0,0);rail.Size=UDim2.fromOffset(railW,panelH)
 topGlass.Position=UDim2.fromOffset(railW+14,10);topGlass.Size=UDim2.new(1, -railW-28,0,66)
 if header then header.Position=UDim2.fromOffset(railW+30,15);header.Size=UDim2.new(1, -railW-60,0,56);header.ZIndex=6 end
 if divider then divider.Position=UDim2.fromOffset(railW+22,80);divider.Size=UDim2.new(1,-railW-44,0,1);divider.BackgroundTransparency=.72 end
 if content then
  content.Position=UDim2.fromOffset(railW+22,92);content.Size=UDim2.new(1, -railW-44,1,-108)
  local cw=math.max(500,panelW-railW-44)
  local wide=cw>=650
  if playerCard and libraryCard then
   if wide then
    playerCard.Position=UDim2.fromOffset(0,0);playerCard.Size=UDim2.new(.36,-8,1,0)
    libraryCard.Position=UDim2.new(.36,8,0,0);libraryCard.Size=UDim2.new(.64,-8,1,0)
   else
    playerCard.Position=UDim2.fromOffset(0,0);playerCard.Size=UDim2.new(1,0,0,178)
    libraryCard.Position=UDim2.fromOffset(0,188);libraryCard.Size=UDim2.new(1,0,1,-188)
   end
  end
 end
 dock.AnchorPoint=Vector2.new(.5,0);dock.Position=UDim2.new(.5,railW*.12,0,12);dock.Size=UDim2.fromOffset(math.min(620,panelW-railW-70),48)
 polishRows();applying=false
end

task.delay(1.1,apply)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(apply)end) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(apply)end)
panel:GetPropertyChangedSignal("Visible"):Connect(function()if panel.Visible then task.defer(apply)end end)
task.spawn(function()while task.wait(1.0) do if panel.Visible then apply() end end end)

print("[BBYA] Structural Dashboard v2 online: sidebar + glass header + wide music library")
