-- BBYA SOCIAL HUB — MESSAGE CLIENT v4.1 FUNCTION-ONLY
-- Public DJ WALL identity retired. Existing legacy GUI/remote identifiers remain internal for UI Kernel compatibility.
-- Nine Roblox-verified MESSAGE tiers: 2 / 5 / 10 / 25 / 50 / 100 / 250 / 500 / 1000 R$.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes")
local wallRemote=remotes:WaitForChild("DJWall") -- internal compatibility remote

local old=pg:FindFirstChild("BBYADJWallUI")
if old then old:Destroy() end
local oldPublic=pg:FindFirstChild("BBYAMessageUI")
if oldPublic then oldPublic:Destroy() end

local C={BG=Color3.fromRGB(10,10,14),PANEL=Color3.fromRGB(19,17,24),CARD=Color3.fromRGB(29,25,34),PINK=Color3.fromRGB(247,55,158),WHITE=Color3.fromRGB(244,243,247),MUTED=Color3.fromRGB(158,154,166),GOLD=Color3.fromRGB(215,169,96),CYAN=Color3.fromRGB(39,191,218)}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,col,tr)local s=Instance.new("UIStroke");s.Color=col;s.Thickness=1;s.Transparency=tr or .45;s.Parent=o;return s end
local function label(parent,text,pos,size,font,ts,col)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 10;l.TextColor3=col or C.WHITE;l.TextWrapped=true;l.TextXAlignment=Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.Parent=parent;return l
end
local function button(parent,text,pos,size,bg)
 local b=Instance.new("TextButton");b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=bg or C.CARD;b.BorderSizePixel=0;b.TextColor3=C.WHITE;b.Font=Enum.Font.GothamBold;b.TextSize=9;b.AutoButtonColor=true;b.Parent=parent;corner(b,9);return b
end

local gui=Instance.new("ScreenGui")
-- Internal legacy name is intentionally preserved because UI Kernel locates this object by identifier.
gui.Name="BBYADJWallUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=35;gui.Parent=pg
gui:SetAttribute("PublicName","MESSAGE")
gui:SetAttribute("LegacyDJWallPublicNameRetired",true)

local panel=Instance.new("Frame")
-- Internal panel name is intentionally preserved; all player-visible copy is MESSAGE.
panel.Name="DJWallComposerPanel";panel.AnchorPoint=Vector2.new(1,0);panel.Position=UDim2.new(1,-96,0,48);panel.Size=UDim2.fromOffset(268,500)
panel.BackgroundColor3=C.BG;panel.BackgroundTransparency=.18;panel.BorderSizePixel=0;panel.Visible=false;panel.ClipsDescendants=true;panel.Parent=gui
corner(panel,14);stroke(panel,C.PINK,.32)
panel:SetAttribute("BBYAOuterLayoutOwner","UI_KERNEL")
panel:SetAttribute("PublicName","MESSAGE")
panel:SetAttribute("LegacyDJWallPublicNameRetired",true)

label(panel,"MESSAGE",UDim2.fromOffset(14,10),UDim2.new(1,-58,0,28),Enum.Font.GothamBlack,15,C.WHITE)
label(panel,"Send a filtered message to the BBYA big screen",UDim2.fromOffset(14,38),UDim2.new(1,-28,0,24),Enum.Font.Gotham,9,C.MUTED)
local close=button(panel,"×",UDim2.new(1,-42,0,8),UDim2.fromOffset(32,32),C.CARD);close.TextSize=18

local categories={{"BIRTHDAY","BIRTHDAY"},{"LOVE","LOVE"},{"SHOUTOUT","SHOUTOUT"},{"CUSTOM","CUSTOM"}}
local category="BIRTHDAY"
local cats=Instance.new("Frame");cats.Position=UDim2.fromOffset(12,68);cats.Size=UDim2.new(1,-24,0,36);cats.BackgroundTransparency=1;cats.Parent=panel
local catButtons={}
for i,c in ipairs(categories)do
 local b=button(cats,c[2],UDim2.new((i-1)*.25,0,0,0),UDim2.new(.25,-3,1,0),C.CARD)
 b.TextSize=8;catButtons[c[1]]=b
 b.Activated:Connect(function()
  category=c[1]
  for k,x in pairs(catButtons)do x.BackgroundColor3=(k==category)and Color3.fromRGB(91,28,66)or C.CARD end
 end)
end
catButtons.BIRTHDAY.BackgroundColor3=Color3.fromRGB(91,28,66)

local box=Instance.new("TextBox")
box.Position=UDim2.fromOffset(12,114);box.Size=UDim2.new(1,-24,0,98);box.BackgroundColor3=C.PANEL;box.BorderSizePixel=0;box.ClearTextOnFocus=false;box.MultiLine=true;box.Text=""
box.PlaceholderText="Write your message...";box.PlaceholderColor3=Color3.fromRGB(112,106,119);box.TextColor3=C.WHITE;box.Font=Enum.Font.GothamMedium;box.TextSize=10;box.TextWrapped=true;box.TextXAlignment=Enum.TextXAlignment.Left;box.TextYAlignment=Enum.TextYAlignment.Top;box.Parent=panel
corner(box,10);stroke(box,Color3.fromRGB(62,51,67),.45)
local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,10);pad.PaddingRight=UDim.new(0,10);pad.PaddingTop=UDim.new(0,8);pad.PaddingBottom=UDim.new(0,8);pad.Parent=box
local count=label(panel,"0 / 80",UDim2.new(1,-94,0,214),UDim2.fromOffset(80,18),Enum.Font.GothamBold,8,C.MUTED);count.TextXAlignment=Enum.TextXAlignment.Right

label(panel,"MESSAGE TIER",UDim2.fromOffset(14,236),UDim2.new(1,-28,0,16),Enum.Font.GothamBold,8,C.MUTED)
local tiersHolder=Instance.new("Frame");tiersHolder.Position=UDim2.fromOffset(12,256);tiersHolder.Size=UDim2.new(1,-24,0,96);tiersHolder.BackgroundTransparency=1;tiersHolder.Parent=panel
local tierGrid=Instance.new("UIGridLayout");tierGrid.CellPadding=UDim2.fromOffset(5,5);tierGrid.CellSize=UDim2.new(1/3,-4,0,28);tierGrid.FillDirectionMaxCells=3;tierGrid.SortOrder=Enum.SortOrder.LayoutOrder;tierGrid.Parent=tiersHolder

local LOCKED_TIERS={2,5,10,25,50,100,250,500,1000}
local selectedAmount=2
local tierButtons={}
local config={tiers=LOCKED_TIERS,available={},maxChars=80,admin=false,publicName="MESSAGE"}
local refresh
for i,amount in ipairs(LOCKED_TIERS)do
 local b=button(tiersHolder,tostring(amount).." R$",UDim2.new(),UDim2.new(),C.CARD);b.LayoutOrder=i;b.TextSize=8;tierButtons[amount]=b
 b.Activated:Connect(function()
  if config.admin or config.available[amount]~=false then selectedAmount=amount end
  if refresh then refresh() end
 end)
end

local send=button(panel,"SEND MESSAGE • 2 R$",UDim2.fromOffset(12,366),UDim2.new(1,-24,0,44),Color3.fromRGB(91,28,66));send.TextSize=9;stroke(send,C.PINK,.30)
local hint=label(panel,"Roblox filter applies before display. Tier changes price only; message flow stays the same.",UDim2.fromOffset(14,417),UDim2.new(1,-28,0,46),Enum.Font.Gotham,8,C.MUTED);hint.TextYAlignment=Enum.TextYAlignment.Top
local status=label(panel,"",UDim2.fromOffset(14,466),UDim2.new(1,-28,0,22),Enum.Font.GothamBold,8,C.CYAN)

local busy=false
refresh=function()
 if not config.admin and config.available[selectedAmount]==false then
  for _,amount in ipairs(LOCKED_TIERS)do
   if config.available[amount]~=false then selectedAmount=amount;break end
  end
 end
 for amount,b in pairs(tierButtons)do
  local selected=amount==selectedAmount
  local available=config.admin or config.available[amount]~=false
  b.Active=available;b.AutoButtonColor=available
  b.BackgroundColor3=selected and Color3.fromRGB(91,28,66)or C.CARD
  b.TextColor3=available and C.WHITE or Color3.fromRGB(93,91,99)
 end
 send.Text=config.admin and "TEST MESSAGE • FREE" or ("SEND MESSAGE • "..tostring(selectedAmount).." R$")
 status.Text=config.admin and "OWNER / ADMIN PREVIEW" or "ROBLOX PURCHASE REQUIRED"
end
local function showToast(text)
 local oldToast=gui:FindFirstChild("MessageToast")
 if oldToast then oldToast:Destroy() end
 local t=label(gui,tostring(text),UDim2.new(.5,-160,1,-58),UDim2.fromOffset(320,38),Enum.Font.GothamBold,9,C.WHITE);t.Name="MessageToast";t.BackgroundColor3=C.PANEL;t.BackgroundTransparency=.08;t.BorderSizePixel=0;t.TextXAlignment=Enum.TextXAlignment.Center;t.ZIndex=50;corner(t,9);stroke(t,C.PINK,.45);task.delay(2.5,function()if t.Parent then t:Destroy()end end)
end
local function applyConfig(data)
 if type(data)~="table" then return end
 config=data
 config.available=type(config.available)=="table" and config.available or {}
 refresh()
end
local function openPanel(data)applyConfig(data);panel.Visible=true end
local function closePanel()panel.Visible=false;box:ReleaseFocus()end
close.Activated:Connect(closePanel)

box:GetPropertyChangedSignal("Text"):Connect(function()
 local max=tonumber(config.maxChars)or 80
 if #box.Text>max then box.Text=box.Text:sub(1,max);box.CursorPosition=#box.Text+1 end
 count.Text=string.format("%d / %d",#box.Text,max)
end)

send.Activated:Connect(function()
 if busy then return end
 if #box.Text<2 then showToast("Tulis pesan dulu.");return end
 if not config.admin and config.available[selectedAmount]==false then showToast("Tier ini belum tersedia.");return end
 busy=true;send.Text="CHECKING MESSAGE..."
 wallRemote:FireServer("submit",{category=category,text=box.Text,amount=selectedAmount})
 task.delay(1.5,function()busy=false;if panel.Visible then refresh()end end)
end)

wallRemote.OnClientEvent:Connect(function(action,data)
 if action=="open" then openPanel(data)
 elseif action=="config" and type(data)=="table" then applyConfig(data)
 elseif action=="toast" then busy=false;showToast(tostring(data));if panel.Visible then refresh()end
 elseif action=="purchase" then
  busy=false
  local amount=(type(data)=="table" and tonumber(data.amount))or selectedAmount
  showToast("Pesan lolos filter. Selesaikan pembelian "..tostring(amount).." Robux.")
  refresh()
 elseif action=="queued" then
  busy=false
  local pos=(type(data)=="table" and data.position)or 1
  showToast("MESSAGE masuk antrean #"..tostring(pos)..".")
  box.Text="";closePanel()
 end
end)

refresh();wallRemote:FireServer("config")
print("[BBYA] MESSAGE client v4.1 online: 9 tiers / UI Kernel compatibility preserved / no public DJ WALL")
