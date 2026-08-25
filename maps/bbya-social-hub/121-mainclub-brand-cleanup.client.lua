-- BBYA SOCIAL HUB — MAIN CLUB BRAND CLEANUP + RECEPTION CONCIERGE v2
-- Keeps the large BBYA MAIN CLUB identity dominant and adds a free Reception Concierge.
-- Concierge is information-only; opening FAST TRAVEL only reveals the existing Travel UI.
-- No teleport, access bypass, purchase prompt, audio routing, or Travel pricing is implemented here.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")

-- -----------------------------------------------------------------------------
-- RECEPTION CONCIERGE v1
-- -----------------------------------------------------------------------------
task.spawn(function()
 local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
 if not remotes then return end
 local feature=remotes:WaitForChild("Feature",30)
 if not feature then return end

 local oldGui=playerGui:FindFirstChild("BBYAConciergeUI")
 if oldGui then oldGui:Destroy() end
 local gui=Instance.new("ScreenGui")
 gui.Name="BBYAConciergeUI"
 gui.ResetOnSpawn=false
 gui.IgnoreGuiInset=true
 gui.DisplayOrder=36
 gui.Parent=playerGui

 local C={
  bg=Color3.fromRGB(10,10,14),card=Color3.fromRGB(27,24,31),card2=Color3.fromRGB(34,30,39),
  pink=Color3.fromRGB(247,55,158),cyan=Color3.fromRGB(32,190,215),gold=Color3.fromRGB(215,169,96),
  white=Color3.fromRGB(244,243,247),muted=Color3.fromRGB(164,159,169),green=Color3.fromRGB(62,205,124)
 }
 local function round(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
 local function stroke(o,color,tr)local s=Instance.new("UIStroke");s.Color=color or C.pink;s.Thickness=1;s.Transparency=tr or .45;s.Parent=o end
 local function label(parent,text,pos,size,font,ts,color)
  local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 12;l.TextColor3=color or C.white;l.TextWrapped=true;l.TextXAlignment=Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.Parent=parent;return l
 end
 local function button(parent,text,pos,size,color)
  local b=Instance.new("TextButton");b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=color or C.card2;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=12;b.AutoButtonColor=true;b.Parent=parent;round(b,9);return b
 end

 local dim=Instance.new("Frame")
 dim.Name="Dim";dim.Size=UDim2.fromScale(1,1);dim.BackgroundColor3=Color3.new(0,0,0);dim.BackgroundTransparency=.42;dim.BorderSizePixel=0;dim.Visible=false;dim.Parent=gui

 local panel=Instance.new("Frame")
 panel.Name="ConciergePanel";panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.53);panel.Size=UDim2.new(.90,0,0,500);panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0;panel.Visible=false;panel.ZIndex=20;panel.Parent=gui;round(panel,16);stroke(panel,C.pink,.38)
 local limit=Instance.new("UISizeConstraint");limit.MinSize=Vector2.new(300,390);limit.MaxSize=Vector2.new(470,500);limit.Parent=panel

 local title=label(panel,"BBYA CONCIERGE",UDim2.fromOffset(18,14),UDim2.new(1,-70,0,28),Enum.Font.GothamBlack,19,C.white);title.ZIndex=21
 local subtitle=label(panel,"VENUE INFO • FREE SERVICE",UDim2.fromOffset(18,43),UDim2.new(1,-36,0,20),Enum.Font.GothamBold,9,C.cyan);subtitle.ZIndex=21
 local intro=label(panel,"Cari tahu venue yang cocok. Concierge tidak memindahkan player; Fast Travel tetap memakai sistem TRAVEL BBYA.",UDim2.fromOffset(18,66),UDim2.new(1,-36,0,43),Enum.Font.Gotham,10,C.muted);intro.ZIndex=21
 local close=button(panel,"×",UDim2.new(1,-48,0,12),UDim2.fromOffset(34,34),C.card2);close.TextSize=20;close.ZIndex=22

 local holder=Instance.new("ScrollingFrame")
 holder.Name="VenueList";holder.Position=UDim2.fromOffset(16,116);holder.Size=UDim2.new(1,-32,1,-218);holder.BackgroundTransparency=1;holder.BorderSizePixel=0;holder.ScrollBarThickness=3;holder.ScrollBarImageColor3=C.pink;holder.AutomaticCanvasSize=Enum.AutomaticSize.Y;holder.CanvasSize=UDim2.new();holder.ScrollingDirection=Enum.ScrollingDirection.Y;holder.ZIndex=21;holder.Parent=panel
 local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,8);layout.Parent=holder

 local travelNote=label(panel,"",UDim2.new(0,18,1,-94),UDim2.new(1,-36,0,30),Enum.Font.Gotham,9,C.muted);travelNote.ZIndex=21
 local travelButton=button(panel,"OPEN FAST TRAVEL",UDim2.new(0,18,1,-58),UDim2.new(1,-36,0,40),Color3.fromRGB(70,47,27));stroke(travelButton,C.gold,.30);travelButton.ZIndex=22

 local function hide()
  panel.Visible=false;dim.Visible=false
 end
 close.MouseButton1Click:Connect(hide)
 dim.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then hide() end end)

 local function openExistingTravel()
  local clubUI=playerGui:FindFirstChild("BBYAClubUI")
  local hub=clubUI and clubUI:FindFirstChild("HubPanel")
  if not hub then return false,"Travel UI belum siap." end

  local travelFrame=nil
  for _,d in ipairs(hub:GetDescendants()) do
   if d:IsA("TextLabel") and d.Text=="MOVE THROUGH BBYA" then travelFrame=d.Parent;break end
  end
  if not travelFrame then return false,"Travel panel belum siap." end

  local content=travelFrame.Parent
  if content then
   for _,child in ipairs(content:GetChildren()) do
    if child:IsA("Frame") then child.Visible=(child==travelFrame) end
   end
  end

  -- Update only the header frame (identified by its close button), not labels inside page content.
  for _,child in ipairs(hub:GetChildren()) do
   if child:IsA("Frame") then
    local hasClose=false
    for _,c in ipairs(child:GetChildren()) do if c:IsA("TextButton") and c.Text=="×" then hasClose=true break end end
    if hasClose then
     local labels={}
     for _,c in ipairs(child:GetChildren()) do if c:IsA("TextLabel") then table.insert(labels,c) end end
     table.sort(labels,function(a,b)return a.Position.Y.Offset<b.Position.Y.Offset end)
     if labels[1] then labels[1].Text="TRAVEL" end
     if labels[2] then labels[2].Text="Quick access to verified BBYA social zones" end
     break
    end
   end
  end

  hub.Visible=true
  return true
 end

 travelButton.MouseButton1Click:Connect(function()
  hide()
  local ok,msg=openExistingTravel()
  if not ok then
   local toast=Instance.new("TextLabel")
   toast.AnchorPoint=Vector2.new(.5,1);toast.Position=UDim2.new(.5,0,1,-34);toast.Size=UDim2.new(.86,0,0,40);toast.BackgroundColor3=C.bg;toast.BackgroundTransparency=.08;toast.BorderSizePixel=0;toast.Text=msg or "Travel belum siap";toast.TextColor3=C.white;toast.Font=Enum.Font.GothamMedium;toast.TextSize=12;toast.ZIndex=60;toast.Parent=gui;round(toast,10);stroke(toast,C.gold,.45)
   local tl=Instance.new("UISizeConstraint");tl.MaxSize=Vector2.new(420,40);tl.Parent=toast
   task.delay(2.2,function()if toast.Parent then toast:Destroy() end end)
  end
 end)

 local accents={C.pink,C.cyan,Color3.fromRGB(145,78,255),C.gold}
 local function render(data)
  for _,child in ipairs(holder:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
  local venues=(data and data.venues) or {}
  for i,v in ipairs(venues) do
   local card=Instance.new("Frame")
   card.Name="VenueCard"..i;card.Size=UDim2.new(1,-4,0,76);card.BackgroundColor3=C.card;card.BorderSizePixel=0;card.ZIndex=22;card.Parent=holder;round(card,11);stroke(card,accents[i] or C.pink,.55)
   local bar=Instance.new("Frame");bar.Position=UDim2.fromOffset(8,9);bar.Size=UDim2.fromOffset(4,58);bar.BackgroundColor3=accents[i] or C.pink;bar.BorderSizePixel=0;bar.ZIndex=23;bar.Parent=card;round(bar,3)
   local name=label(card,tostring(v.name or "VENUE"),UDim2.fromOffset(22,7),UDim2.new(.63,-22,0,20),Enum.Font.GothamBold,12,C.white);name.ZIndex=23
   local genre=label(card,tostring(v.genre or ""),UDim2.fromOffset(22,27),UDim2.new(.67,-22,0,17),Enum.Font.Gotham,9,C.muted);genre.ZIndex=23
   local dir=label(card,tostring(v.direction or ""),UDim2.fromOffset(22,46),UDim2.new(.68,-22,0,17),Enum.Font.GothamMedium,9,accents[i] or C.cyan);dir.ZIndex=23
   local status=label(card,tostring(v.status or "OPEN"),UDim2.new(.70,0,0,7),UDim2.new(.27,-10,0,20),Enum.Font.GothamBold,9,(v.status=="OPEN") and C.green or C.gold);status.TextXAlignment=Enum.TextXAlignment.Right;status.ZIndex=23
   local access=label(card,tostring(v.access or ""),UDim2.new(.66,0,0,39),UDim2.new(.31,-10,0,22),Enum.Font.GothamBold,8,C.gold);access.TextXAlignment=Enum.TextXAlignment.Right;access.ZIndex=23
  end
  travelNote.Text=tostring((data and data.travelNote) or "Fast Travel tetap memakai sistem TRAVEL BBYA.")
  panel.Visible=true;dim.Visible=true
 end

 feature.OnClientEvent:Connect(function(kind,data)
  if kind=="concierge" then render(data or {}) end
 end)

 player.CharacterAdded:Connect(function()hide()end)
 print("[BBYA] Reception Concierge v1 client online: info-only / Travel authority untouched")
end)

-- -----------------------------------------------------------------------------
-- MAIN CLUB BRAND CLEANUP v1 (existing behavior retained)
-- -----------------------------------------------------------------------------
task.spawn(function()
 local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
 if not root then return end
 local system=root:WaitForChild("DJWallMessageSystem",30)
 if not system then return end
 local final=system:WaitForChild("FinalMountedWall",30)
 if not final then return end
 local screen=final:WaitForChild("PrestigeLED",30)
 if not screen then return end

 local bound={}
 local changing=false
 local function sanitize(label)
  if not label or not label:IsA("TextLabel") then return end
  local up=string.upper(tostring(label.Text or ""))
  if up:find("BBYA",1,true) and up:find("LIVE WAVE",1,true) then
   changing=true
   label.Text="BBYA"
   changing=false
  end
  if not bound[label] then
   bound[label]=true
   label:GetPropertyChangedSignal("Text"):Connect(function()
    if not changing then task.defer(function()sanitize(label)end) end
   end)
  end
 end

 for _,d in ipairs(screen:GetDescendants()) do sanitize(d) end
 screen.DescendantAdded:Connect(function(d)if d:IsA("TextLabel") then task.defer(function()sanitize(d)end) end end)
 screen:SetAttribute("BBYAMainClubSingleBrand",true)
 print("[BBYA] Main Club brand cleanup v1: competing BBYA LIVE WAVE copy removed; main signage remains dominant")
end)
