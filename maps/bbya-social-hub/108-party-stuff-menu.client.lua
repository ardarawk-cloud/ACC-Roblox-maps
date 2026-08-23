-- BBYA SOCIAL HUB — PARTY STUFF + TRANSPARENT COMMAND MENU v1
-- Consolidates cosmetic club gear into one menu entry and removes the Roblox hotbar clutter.
-- Keeps the command drawer translucent so the avatar/world remains visible behind it.

local Players=game:GetService("Players")
local StarterGui=game:GetService("StarterGui")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local menuGui=pg:WaitForChild("BBYACommandMenuUI",30)
if not menuGui then return end
local drawer=menuGui:WaitForChild("FeatureDrawer",20)
if not drawer then return end
local grid=drawer:FindFirstChildWhichIsA("UIGridLayout",true)
local body=grid and grid.Parent
if not body then return end

local C={
 card=Color3.fromRGB(27,28,37),panel=Color3.fromRGB(13,14,19),white=Color3.fromRGB(246,246,249),
 muted=Color3.fromRGB(157,160,172),pink=Color3.fromRGB(234,46,163),cyan=Color3.fromRGB(38,194,222),gold=Color3.fromRGB(220,171,92),line=Color3.fromRGB(72,75,89),
}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 9);c.Parent=o end
local function stroke(o,col,tr)local s=Instance.new("UIStroke");s.Color=col or C.line;s.Thickness=1;s.Transparency=tr or .55;s.Parent=o end
local function text(parent,value,pos,size,font,ts,color,align)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=value;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 10;l.TextColor3=color or C.white;l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.ZIndex=255;l.Parent=parent;return l
end

-- Make only the command-menu surfaces translucent.
drawer.BackgroundTransparency=.34
local menuButton=menuGui:FindFirstChild("MenuButton",true)
if menuButton and menuButton:IsA("TextButton") then menuButton.BackgroundTransparency=.18 end
for _,d in ipairs(drawer:GetDescendants()) do
 if d:IsA("Frame") and d~=body and d.BackgroundTransparency<1 then
  if d.Name:match("^Slot_") then d.BackgroundTransparency=.28 else d.BackgroundTransparency=.25 end
 elseif d:IsA("TextButton") and d:GetAttribute("BBYACommandMenuItem")==true then
  d.BackgroundTransparency=.30
 end
end

-- Reserve the 10th command-menu slot for Party Stuff.
local old=body:FindFirstChild("Slot_PARTY_STUFF")
if old then old:Destroy() end
local slot=Instance.new("Frame")
slot.Name="Slot_PARTY_STUFF";slot.LayoutOrder=10;slot.BackgroundColor3=C.card;slot.BackgroundTransparency=.28;slot.BorderSizePixel=0;slot.ZIndex=202;slot.Parent=body
corner(slot,9);stroke(slot,C.gold,.58)
local partyButton=Instance.new("TextButton")
partyButton.Name="PartyStuffButton";partyButton.Size=UDim2.fromScale(1,1);partyButton.BackgroundColor3=C.card;partyButton.BackgroundTransparency=.30;partyButton.BorderSizePixel=0
partyButton.Text="PARTY STUFF";partyButton.TextColor3=C.white;partyButton.Font=Enum.Font.GothamBold;partyButton.TextSize=8;partyButton.ZIndex=206;partyButton.Parent=slot
corner(partyButton,9);stroke(partyButton,C.gold,.66)

local panel=Instance.new("Frame")
panel.Name="PartyStuffPanel";panel.Position=UDim2.fromOffset(10,70);panel.Size=UDim2.new(1,-20,1,-80);panel.BackgroundColor3=C.panel;panel.BackgroundTransparency=.16;panel.BorderSizePixel=0;panel.Visible=false;panel.ZIndex=245;panel.Parent=drawer
corner(panel,12);stroke(panel,C.gold,.38)
text(panel,"PARTY STUFF",UDim2.fromOffset(14,10),UDim2.new(1,-70,0,24),Enum.Font.GothamBlack,13,C.white)
text(panel,"Equip cosmetic gear",UDim2.fromOffset(14,32),UDim2.new(1,-28,0,18),Enum.Font.GothamMedium,8,C.muted)
local back=Instance.new("TextButton")
back.Name="PartyBack";back.AnchorPoint=Vector2.new(1,0);back.Position=UDim2.new(1,-10,0,10);back.Size=UDim2.fromOffset(46,28);back.BackgroundColor3=C.card;back.BackgroundTransparency=.22;back.BorderSizePixel=0;back.Text="BACK";back.TextColor3=C.white;back.Font=Enum.Font.GothamBold;back.TextSize=8;back.ZIndex=256;back.Parent=panel
corner(back,8);stroke(back,C.line,.55)

local list=Instance.new("Frame");list.Position=UDim2.fromOffset(14,62);list.Size=UDim2.new(1,-28,1,-76);list.BackgroundTransparency=1;list.ZIndex=246;list.Parent=panel
local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,8);layout.FillDirection=Enum.FillDirection.Vertical;layout.HorizontalAlignment=Enum.HorizontalAlignment.Center;layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=list

local GEAR={
 {name="Money Gun",label="MONEY GUN",accent=Color3.fromRGB(66,230,124)},
 {name="Glowstick",label="GLOWSTICK",accent=C.cyan},
 {name="Party Sparkler",label="PARTY SPARKLER",accent=C.gold},
}
local function hideBackpack()
 pcall(function()StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)end)
end
local function equip(name)
 local char=player.Character
 local hum=char and char:FindFirstChildOfClass("Humanoid")
 local backpack=player:FindFirstChildOfClass("Backpack")
 if not hum or not backpack then return end
 hum:UnequipTools();task.wait()
 local tool=backpack:FindFirstChild(name)
 if tool and tool:IsA("Tool") then hum:EquipTool(tool) end
 panel.Visible=false;drawer.Visible=false
 if menuButton and menuButton:IsA("TextButton") then menuButton.Text="MENU" end
 hideBackpack()
end
for i,g in ipairs(GEAR) do
 local b=Instance.new("TextButton");b.Name="Party_"..g.label:gsub(" ","_");b.LayoutOrder=i;b.Size=UDim2.new(1,0,0,42);b.BackgroundColor3=C.card;b.BackgroundTransparency=.20;b.BorderSizePixel=0
 b.Text=g.label;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=9;b.ZIndex=250;b.Parent=list;corner(b,9);stroke(b,g.accent,.48)
 b.Activated:Connect(function()equip(g.name)end)
end

partyButton.Activated:Connect(function()panel.Visible=true end)
back.Activated:Connect(function()panel.Visible=false end)
drawer:GetPropertyChangedSignal("Visible"):Connect(function()if not drawer.Visible then panel.Visible=false end end)

-- The three cosmetic tools stay in Backpack internally but the Roblox hotbar no longer occupies the screen.
player:SetAttribute("BBYACustomPartyGearUI",true)
for i=1,6 do task.delay(i*.35,hideBackpack) end
player.CharacterAdded:Connect(function()task.delay(1.2,hideBackpack)end)
local clubUI=pg:FindFirstChild("BBYAClubUI")
local hubPanel=clubUI and clubUI:FindFirstChild("HubPanel")
if hubPanel then hubPanel:GetPropertyChangedSignal("Visible"):Connect(function()task.delay(.08,hideBackpack)end) end
menuGui:GetPropertyChangedSignal("Enabled"):Connect(function()task.delay(.05,hideBackpack)end)
drawer:GetPropertyChangedSignal("Visible"):Connect(function()task.delay(.05,hideBackpack)end)

task.defer(hideBackpack)
menuGui:SetAttribute("BBYAPartyStuffAuthority","V1_CUSTOM_GEAR")
print("[BBYA] Party Stuff v1 online: compact gear menu / Roblox hotbar hidden / translucent command drawer")
