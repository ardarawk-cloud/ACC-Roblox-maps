-- BBYA MUSIC UI TEST — PARTY STUFF STANDALONE v5
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- Party is standalone, visually matches DancePanel, and gear equip is server-authoritative.

local Players=game:GetService("Players")
local StarterGui=game:GetService("StarterGui")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local menuGui=pg:WaitForChild("BBYACommandMenuUI",30)
if not menuGui then return end
local drawer=menuGui:WaitForChild("FeatureDrawer",20)
if not drawer then return end
local grid=drawer:FindFirstChildWhichIsA("UIGridLayout",true)
local body=grid and grid.Parent
if not body then return end
local camera=workspace.CurrentCamera

local C={card=Color3.fromRGB(27,28,37),panel=Color3.fromRGB(13,14,19),white=Color3.fromRGB(246,246,249),muted=Color3.fromRGB(157,160,172),pink=Color3.fromRGB(234,46,163),cyan=Color3.fromRGB(38,194,222),gold=Color3.fromRGB(220,171,92),line=Color3.fromRGB(72,75,89)}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 9);c.Parent=o end
local function stroke(o,col,tr)local s=Instance.new("UIStroke");s.Color=col or C.line;s.Thickness=1;s.Transparency=tr or .55;s.Parent=o end
local function label(parent,value,pos,size,font,ts,color)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=value;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 10;l.TextColor3=color or C.white;l.TextXAlignment=Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.Parent=parent;return l
end
local function hideBackpack()pcall(function()StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)end)end

local oldSlot=body:FindFirstChild("Slot_PARTY_STUFF")
if oldSlot then oldSlot:Destroy() end
local oldPanel=menuGui:FindFirstChild("PartyStuffPanel",true)
if oldPanel then oldPanel:Destroy() end

local slot=Instance.new("Frame")
slot.Name="Slot_PARTY_STUFF";slot.LayoutOrder=10;slot.BackgroundColor3=C.card;slot.BackgroundTransparency=.28;slot.BorderSizePixel=0;slot.ZIndex=202;slot.Parent=body
corner(slot,9);stroke(slot,C.gold,.58)
local partyButton=Instance.new("TextButton")
partyButton.Name="PartyStuffButton";partyButton.Size=UDim2.fromScale(1,1);partyButton.BackgroundColor3=C.card;partyButton.BackgroundTransparency=.30;partyButton.BorderSizePixel=0;partyButton.Text="PARTY STUFF";partyButton.TextColor3=C.white;partyButton.Font=Enum.Font.GothamBold;partyButton.TextSize=9;partyButton.ZIndex=206;partyButton.Parent=slot
corner(partyButton,9);stroke(partyButton,C.gold,.66)

local panel=Instance.new("Frame")
panel.Name="PartyStuffPanel";panel.AnchorPoint=Vector2.new(1,.5);panel.BackgroundColor3=C.panel;panel.BackgroundTransparency=.38;panel.BorderSizePixel=0;panel.Visible=false;panel.ZIndex=500;panel.Active=true;panel.ClipsDescendants=true;panel.Parent=menuGui
corner(panel,14);stroke(panel,C.gold,.35)
label(panel,"PARTY STUFF",UDim2.fromOffset(16,12),UDim2.new(1,-72,0,24),Enum.Font.GothamBlack,15,C.white)
label(panel,"Equip or put away cosmetic gear",UDim2.fromOffset(16,36),UDim2.new(1,-32,0,18),Enum.Font.GothamMedium,9,C.muted)
local back=Instance.new("TextButton")
back.Name="PartyBack";back.AnchorPoint=Vector2.new(1,0);back.Position=UDim2.new(1,-12,0,10);back.Size=UDim2.fromOffset(52,30);back.BackgroundColor3=C.card;back.BackgroundTransparency=.22;back.BorderSizePixel=0;back.Text="BACK";back.TextColor3=C.white;back.Font=Enum.Font.GothamBold;back.TextSize=9;back.ZIndex=510;back.Parent=panel
corner(back,8);stroke(back,C.line,.55)

local list=Instance.new("Frame")
list.Position=UDim2.fromOffset(14,68);list.Size=UDim2.new(1,-28,1,-82);list.BackgroundTransparency=1;list.ZIndex=501;list.Parent=panel
local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,10);layout.FillDirection=Enum.FillDirection.Vertical;layout.HorizontalAlignment=Enum.HorizontalAlignment.Center;layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=list

local function danceMetrics()
 local social=pg:FindFirstChild("BBYASocialHangoutUI")
 local dance=social and social:FindFirstChild("DancePanel")
 if dance then
  local scale=dance:FindFirstChild("BBYAViewportScaleV1") or dance:FindFirstChildWhichIsA("UIScale")
  return dance,scale and scale.Scale or 1
 end
 return nil,1
end
local function applyDanceScale(target,scale)
 local s=target:FindFirstChild("BBYAMatchDanceScaleV5")
 if not s then s=Instance.new("UIScale");s.Name="BBYAMatchDanceScaleV5";s.Parent=target end
 s.Scale=scale
end
local function layoutPanel()
 camera=workspace.CurrentCamera or camera
 local dance,scale=danceMetrics()
 panel.AnchorPoint=Vector2.new(1,.5);panel.Position=UDim2.new(1,-12,.5,0)
 if dance then
  panel.AnchorPoint=dance.AnchorPoint;panel.Position=dance.Position;panel.Size=dance.Size
 else
  local v=camera and camera.ViewportSize or Vector2.new(1280,720)
  panel.Size=UDim2.fromOffset(math.clamp(math.floor(v.X*.19),270,320),math.clamp(math.floor(v.Y*.72),470,560))
 end
 applyDanceScale(panel,scale)
 panel:SetAttribute("BBYAPartyGeometry","MATCH_DANCE_SIZE_SCALE_V5")
end
layoutPanel()
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutPanel) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(layoutPanel)end)
pg.ChildAdded:Connect(function(child)if child.Name=="BBYASocialHangoutUI" then task.defer(layoutPanel);task.delay(.2,layoutPanel) end end)

local GEAR={{name="Money Gun",label="MONEY GUN",accent=Color3.fromRGB(66,230,124)},{name="Glowstick",label="GLOWSTICK",accent=C.cyan},{name="Party Sparkler",label="PARTY SPARKLER",accent=C.gold}}
local gearRemote=nil
local function remote()
 if gearRemote and gearRemote.Parent then return gearRemote end
 local folder=ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
 gearRemote=folder and folder:FindFirstChild("ClubGear")
 return gearRemote
end
local function closePanel(showMenu)
 panel.Visible=false
 if showMenu then drawer.Visible=true end
 hideBackpack()
end
local function equip(name)
 local r=remote()
 if r and r:IsA("RemoteEvent") then
  r:FireServer("equip",name)
 else
  local char=player.Character;local hum=char and char:FindFirstChildOfClass("Humanoid");local backpack=player:FindFirstChildOfClass("Backpack")
  local tool=backpack and backpack:FindFirstChild(name)
  if hum and tool and tool:IsA("Tool") then hum:UnequipTools();hum:EquipTool(tool) end
 end
 player:SetAttribute("BBYAPartyGearStored",false)
 task.delay(.08,function()closePanel(false)end)
end
local function putAway()
 local r=remote();if r and r:IsA("RemoteEvent") then r:FireServer("putAway") else local ch=player.Character;local h=ch and ch:FindFirstChildOfClass("Humanoid");if h then h:UnequipTools() end end
 player:SetAttribute("BBYAPartyGearStored",true);closePanel(false)
end
for i,g in ipairs(GEAR) do
 local b=Instance.new("TextButton");b.Name="Party_"..g.label:gsub(" ","_");b.LayoutOrder=i;b.Size=UDim2.new(1,0,0,58);b.BackgroundColor3=C.card;b.BackgroundTransparency=.22;b.BorderSizePixel=0;b.Text=g.label;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=11;b.ZIndex=505;b.Active=true;b.Selectable=true;b.Parent=list
 corner(b,10);stroke(b,g.accent,.48);b.Activated:Connect(function()equip(g.name)end)
end
local put=Instance.new("TextButton")
put.Name="Party_PUT_AWAY";put.LayoutOrder=4;put.Size=UDim2.new(1,0,0,58);put.BackgroundColor3=Color3.fromRGB(35,31,40);put.BackgroundTransparency=.18;put.BorderSizePixel=0;put.Text="SIMPAN / PUT AWAY";put.TextColor3=C.white;put.Font=Enum.Font.GothamBlack;put.TextSize=10;put.ZIndex=505;put.Active=true;put.Selectable=true;put.Parent=list
corner(put,10);stroke(put,C.pink,.35);put.Activated:Connect(putAway)

partyButton.Activated:Connect(function()layoutPanel();drawer.Visible=false;panel.Visible=true;panel.ZIndex=500;hideBackpack()end)
back.Activated:Connect(function()closePanel(true)end)

player:SetAttribute("BBYACustomPartyGearUI",true);player:SetAttribute("BBYAPartyGearStored",true)
for i=1,6 do task.delay(i*.35,hideBackpack) end
player.CharacterAdded:Connect(function()task.delay(1.2,function()player:SetAttribute("BBYAPartyGearStored",true);hideBackpack()end)end)
task.defer(hideBackpack)
menuGui:SetAttribute("BBYAPartyStuffAuthority","V5_MATCH_DANCE_SCALE_SERVER_GEAR")
print("[BBYA TEST] Party Stuff v5 online: Dance visual scale + server gear equip")
