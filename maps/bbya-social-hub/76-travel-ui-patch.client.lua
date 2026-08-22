-- BBYA SOCIAL HUB — TRAVEL UI PATCH v8
-- Compact phone-first travel panel. Paid destinations are permanent one-time Game Pass unlocks.
-- v8: adds BBYA Pasar Malam behind Mall as a 10 R$ permanent Travel destination.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local camera=workspace.CurrentCamera
local gui=player:WaitForChild("PlayerGui"):WaitForChild("BBYAClubUI",30)
local remote=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30):WaitForChild("Teleport",30)
if not gui or not remote then return end

local function findTravel()
 for _,d in ipairs(gui:GetDescendants()) do
  if d:IsA("TextLabel") and d.Text=="MOVE THROUGH BBYA" then return d.Parent end
 end
end
local travel=findTravel();if not travel then task.wait(1);travel=findTravel() end
if not travel then warn("[BBYA TravelPatch] travel frame not found");return end

for _,d in ipairs(travel:GetDescendants()) do
 if d:IsA("TextLabel") and d.Text:find("Only destinations") then
  d.Text="Paid destinations are permanent one-time unlocks.";d.TextSize=9
 end
end
for _,child in ipairs(travel:GetChildren()) do
 if child:IsA("Frame") and child:FindFirstChildOfClass("UIGridLayout") then child:Destroy() end
 if child:IsA("ScrollingFrame") and child.Name=="TravelDestinationScroller" then child:Destroy() end
end

local holder=Instance.new("ScrollingFrame")
holder.Name="TravelDestinationScroller"
holder.Position=UDim2.fromOffset(0,52)
holder.Size=UDim2.new(1,0,1,-52)
holder.BackgroundTransparency=1
holder.BorderSizePixel=0
holder.ScrollBarThickness=3
holder.ScrollBarImageTransparency=.18
holder.AutomaticCanvasSize=Enum.AutomaticSize.None
holder.CanvasSize=UDim2.fromOffset(0,0)
holder.ScrollingDirection=Enum.ScrollingDirection.Y
holder.ElasticBehavior=Enum.ElasticBehavior.WhenScrollable
holder.ScrollingEnabled=true
holder.Active=true
holder.Selectable=false
holder.Parent=travel

local grid=Instance.new("UIGridLayout")
grid.CellPadding=UDim2.fromOffset(6,6)
grid.SortOrder=Enum.SortOrder.LayoutOrder
grid.FillDirection=Enum.FillDirection.Horizontal
grid.HorizontalAlignment=Enum.HorizontalAlignment.Left
grid.VerticalAlignment=Enum.VerticalAlignment.Top
grid.Parent=holder

local C={card=Color3.fromRGB(27,24,31),white=Color3.fromRGB(244,243,247),muted=Color3.fromRGB(160,156,166),pink=Color3.fromRGB(247,55,158),cyan=Color3.fromRGB(32,190,215),gold=Color3.fromRGB(215,169,96),purple=Color3.fromRGB(145,78,255),mall=Color3.fromRGB(228,145,65),market=Color3.fromRGB(230,82,55)}
local destinations={
 {"ARRIVAL","Arrival","FREE",nil,C.cyan},
 {"PHOTO STUDIO","Photo","FREE",nil,C.cyan},
 {"LOOK LAB","LookLab","FREE",nil,C.cyan},
 {"MAIN CLUB","MainClub","FREE",nil,C.pink},
 {"VIP LEVEL","VIP","ONE-TIME",5,C.gold},
 {"SKATEPARK","Skatepark","ONE-TIME",5,C.gold},
 {"ROOFTOP","Rooftop","ONE-TIME",10,C.gold},
 {"UNDERGROUND","Basement","ONE-TIME",20,C.gold},
 {"FUNKOT CLUB","Funkot","ONE-TIME",10,C.purple},
 {"BBYA MALL","Mall","ONE-TIME",10,C.mall},
 {"PASAR MALAM","NightMarket","ONE-TIME",10,C.market},
}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 9);c.Parent=o end
local function stroke(o,c)local s=Instance.new("UIStroke");s.Color=c;s.Thickness=1;s.Transparency=.55;s.Parent=o end
local function label(parent,value,pos,size,font,ts,color)local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=value;l.Position=pos;l.Size=size;l.Font=font;l.TextSize=ts;l.TextColor3=color;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=parent;return l end

for i,d in ipairs(destinations) do
 local card=Instance.new("Frame");card.Name="Travel_"..d[2];card.BackgroundColor3=C.card;card.BorderSizePixel=0;card.LayoutOrder=i;card.Parent=holder;corner(card,9);stroke(card,d[5])
 local bar=Instance.new("Frame");bar.Size=UDim2.new(0,3,1,-12);bar.Position=UDim2.fromOffset(6,6);bar.BackgroundColor3=d[5];bar.BorderSizePixel=0;bar.Parent=card;corner(bar,3)
 label(card,d[1],UDim2.fromOffset(16,8),UDim2.new(1,-22,0,18),Enum.Font.GothamBold,10,C.white)
 local meta=d[4] and string.format("%s • %d R$",d[3],d[4]) or "FREE TELEPORT"
 label(card,meta,UDim2.fromOffset(16,27),UDim2.new(1,-22,0,14),Enum.Font.GothamBold,8,d[4] and C.gold or C.muted)
 local go=Instance.new("TextButton");go.Text=d[4] and "UNLOCK / GO" or "GO";go.Position=UDim2.new(0,16,1,-27);go.Size=UDim2.new(1,-22,0,21);go.BackgroundColor3=Color3.fromRGB(38,34,43);go.BorderSizePixel=0;go.Font=Enum.Font.GothamSemibold;go.TextSize=8;go.TextColor3=C.white;go.Selectable=false;go.Parent=card;corner(go,6)
 go.MouseButton1Click:Connect(function()
  remote:FireServer(d[2])
  local panel=gui:FindFirstChild("HubPanel");if panel then panel.Visible=false end
 end)
end

local layingOut=false
local function syncCanvas(keepY)
 if layingOut then return end
 layingOut=true
 local oldY=keepY and holder.CanvasPosition.Y or 0
 local contentY=math.max(0,grid.AbsoluteContentSize.Y+10)
 holder.CanvasSize=UDim2.fromOffset(0,contentY)
 task.defer(function()
  local maxY=math.max(0,contentY-holder.AbsoluteWindowSize.Y)
  holder.CanvasPosition=Vector2.new(0,math.clamp(oldY,0,maxY))
  layingOut=false
 end)
end

local function applyGrid()
 camera=workspace.CurrentCamera or camera
 local vp=camera and camera.ViewportSize or Vector2.new(1280,720)
 local phone=UserInputService.TouchEnabled or vp.X<900
 local cols=phone and 2 or 3
 local width=math.max(280,holder.AbsoluteSize.X)
 local cellW=math.max(118,math.floor((width-(cols-1)*6)/cols))
 local oldY=holder.CanvasPosition.Y
 grid.CellSize=UDim2.fromOffset(cellW,phone and 72 or 82)
 task.defer(function()syncCanvas(true);holder.CanvasPosition=Vector2.new(0,oldY)end)
end

grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()syncCanvas(true)end)
holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(applyGrid)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyGrid) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
 camera=workspace.CurrentCamera
 task.defer(applyGrid)
end)
task.defer(function()applyGrid();syncCanvas(false)end)

print("[BBYA] Travel UI v8 online: Pasar Malam 10R / stable manual canvas")