-- BBYA SOCIAL HUB — TRAVEL UI PATCH v10
-- Reliable touch-first Travel list. Never writes CanvasPosition after user scrolls.
-- Mobile uses one large card per row; Backpack is hidden only while Travel is actually open.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local StarterGui=game:GetService("StarterGui")
local player=Players.LocalPlayer
local camera=workspace.CurrentCamera
local gui=player:WaitForChild("PlayerGui"):WaitForChild("BBYAClubUI",30)
local remote=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30):WaitForChild("Teleport",30)
if not gui or not remote then return end
local hubPanel=gui:FindFirstChild("HubPanel")

local function findTravel()
 for _,d in ipairs(gui:GetDescendants()) do
  if d:IsA("TextLabel") and d.Text=="MOVE THROUGH BBYA" then return d.Parent end
 end
end
local travel=findTravel();if not travel then task.wait(1);travel=findTravel() end
if not travel then warn("[BBYA Travel v10] travel frame not found");return end
travel.ClipsDescendants=true
travel.ZIndex=70

for _,d in ipairs(travel:GetDescendants()) do
 if d:IsA("TextLabel") and (d.Text:find("Only destinations") or d.Text:find("Paid destinations")) then
  d.Text="Tap destination • paid access is a permanent one-time unlock.";d.TextSize=9;d.ZIndex=72
 end
end
for _,child in ipairs(travel:GetChildren()) do
 if child:IsA("Frame") and child:FindFirstChildOfClass("UIGridLayout") then child:Destroy() end
 if child:IsA("ScrollingFrame") and child.Name=="TravelDestinationScroller" then child:Destroy() end
end

local holder=Instance.new("ScrollingFrame")
holder.Name="TravelDestinationScroller"
holder.Position=UDim2.fromOffset(0,50)
holder.Size=UDim2.new(1,0,1,-50)
holder.BackgroundTransparency=1;holder.BorderSizePixel=0
holder.ScrollBarThickness=5;holder.ScrollBarImageTransparency=.05
holder.AutomaticCanvasSize=Enum.AutomaticSize.None;holder.CanvasSize=UDim2.fromOffset(0,0)
holder.ScrollingDirection=Enum.ScrollingDirection.Y;holder.ElasticBehavior=Enum.ElasticBehavior.Always
holder.ScrollingEnabled=true;holder.Active=true;holder.Selectable=false;holder.ClipsDescendants=true;holder.ZIndex=80;holder.Parent=travel

local grid=Instance.new("UIGridLayout")
grid.CellPadding=UDim2.fromOffset(7,7);grid.SortOrder=Enum.SortOrder.LayoutOrder
 grid.FillDirection=Enum.FillDirection.Horizontal;grid.FillDirectionMaxCells=1
 grid.HorizontalAlignment=Enum.HorizontalAlignment.Left;grid.VerticalAlignment=Enum.VerticalAlignment.Top;grid.Parent=holder
local pad=Instance.new("UIPadding");pad.PaddingTop=UDim.new(0,2);pad.PaddingBottom=UDim.new(0,116);pad.PaddingLeft=UDim.new(0,2);pad.PaddingRight=UDim.new(0,4);pad.Parent=holder

local C={card=Color3.fromRGB(27,24,31),white=Color3.fromRGB(244,243,247),muted=Color3.fromRGB(160,156,166),pink=Color3.fromRGB(247,55,158),cyan=Color3.fromRGB(32,190,215),gold=Color3.fromRGB(215,169,96),purple=Color3.fromRGB(145,78,255),mall=Color3.fromRGB(228,145,65),market=Color3.fromRGB(230,82,55)}
local destinations={
 {"ARRIVAL","Arrival","FREE",nil,C.cyan},{"PHOTO STUDIO","Photo","FREE",nil,C.cyan},{"LOOK LAB","LookLab","FREE",nil,C.cyan},{"MAIN CLUB","MainClub","FREE",nil,C.pink},
 {"VIP LEVEL","VIP","ONE-TIME",5,C.gold},{"SKATEPARK","Skatepark","ONE-TIME",5,C.gold},{"ROOFTOP","Rooftop","ONE-TIME",10,C.gold},{"UNDERGROUND","Basement","ONE-TIME",20,C.gold},
 {"FUNKOT CLUB","Funkot","ONE-TIME",10,C.purple},{"BBYA MALL","Mall","ONE-TIME",10,C.mall},{"PASAR MALAM","NightMarket","ONE-TIME",10,C.market},
}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 9);c.Parent=o end
local function stroke(o,c)local s=Instance.new("UIStroke");s.Color=c;s.Thickness=1;s.Transparency=.50;s.Parent=o end
local function label(parent,value,pos,size,font,ts,color)local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=value;l.Position=pos;l.Size=size;l.Font=font;l.TextSize=ts;l.TextColor3=color;l.TextXAlignment=Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.ZIndex=83;l.Parent=parent;return l end

for i,d in ipairs(destinations) do
 local card=Instance.new("Frame");card.Name="Travel_"..d[2];card.BackgroundColor3=C.card;card.BorderSizePixel=0;card.LayoutOrder=i;card.ZIndex=81;card.Parent=holder;corner(card,10);stroke(card,d[5])
 local bar=Instance.new("Frame");bar.Size=UDim2.new(0,4,1,-14);bar.Position=UDim2.fromOffset(7,7);bar.BackgroundColor3=d[5];bar.BorderSizePixel=0;bar.ZIndex=82;bar.Parent=card;corner(bar,3)
 label(card,d[1],UDim2.fromOffset(19,7),UDim2.new(.55,-16,0,22),Enum.Font.GothamBold,11,C.white)
 local meta=d[4] and string.format("%s • %d R$",d[3],d[4]) or "FREE TELEPORT"
 label(card,meta,UDim2.fromOffset(19,30),UDim2.new(.55,-16,0,18),Enum.Font.GothamBold,8,d[4] and C.gold or C.muted)
 local go=Instance.new("TextButton");go.Text=d[4] and "UNLOCK / GO" or "GO";go.AnchorPoint=Vector2.new(1,.5);go.Position=UDim2.new(1,-9,.5,0);go.Size=UDim2.new(.40,0,0,38)
 go.BackgroundColor3=Color3.fromRGB(40,36,46);go.BorderSizePixel=0;go.Font=Enum.Font.GothamBold;go.TextSize=9;go.TextColor3=C.white;go.Selectable=false;go.Active=true;go.ZIndex=86;go.Parent=card;corner(go,8);stroke(go,d[5])
 go.Activated:Connect(function()remote:FireServer(d[2]);if hubPanel then hubPanel.Visible=false end end)
end

local function updateCanvas()
 task.defer(function()if holder.Parent then holder.CanvasSize=UDim2.fromOffset(0,math.max(0,grid.AbsoluteContentSize.Y+124)) end end)
end
local function applyLayout()
 camera=workspace.CurrentCamera or camera
 local vp=camera and camera.ViewportSize or Vector2.new(1280,720)
 local touch=UserInputService.TouchEnabled or vp.X<900
 local cols=touch and 1 or 2
 grid.FillDirectionMaxCells=cols
 local usable=math.max(260,holder.AbsoluteSize.X-8)
 local cellW=touch and usable or math.floor((usable-7)/2)
 grid.CellSize=UDim2.fromOffset(cellW,touch and 66 or 72)
 pad.PaddingBottom=UDim.new(0,touch and 128 or 30)
 updateCanvas()
end
grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(applyLayout)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyLayout) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(applyLayout)end)

-- CoreGui hotbar guard only while Travel itself is the visible page.
local backpackWas=true
local backpackHidden=false
local function travelIsOpen()return travel.Visible and (not hubPanel or hubPanel.Visible) end
local function syncBackpack()
 local open=travelIsOpen()
 if open and not backpackHidden then
  pcall(function()backpackWas=StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack)end)
  pcall(function()StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)end);backpackHidden=true
 elseif not open and backpackHidden then
  pcall(function()StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,backpackWas)end);backpackHidden=false
 end
end
travel:GetPropertyChangedSignal("Visible"):Connect(function()task.defer(syncBackpack)end)
if hubPanel then hubPanel:GetPropertyChangedSignal("Visible"):Connect(function()task.defer(syncBackpack)end) end

task.defer(function()applyLayout();updateCanvas();syncBackpack()end)
print("[BBYA] Travel UI v10 online: no scroll snap / one-column mobile / full bottom touch access")
