-- BBYA SOCIAL HUB — SOCIAL HANGOUT CLIENT v1
-- Mobile-first SOCIAL menu: EMOTES + consent-based CARRY.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local camera=workspace.CurrentCamera
local remote=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30):WaitForChild("SocialHangout",30)
if not remote then return end

local pg=player:WaitForChild("PlayerGui")
local old=pg:FindFirstChild("BBYASocialHangoutUI")
if old then old:Destroy() end
local gui=Instance.new("ScreenGui")
gui.Name="BBYASocialHangoutUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=44;gui.Parent=pg

local C={bg=Color3.fromRGB(12,11,16),card=Color3.fromRGB(25,22,30),card2=Color3.fromRGB(35,30,40),white=Color3.fromRGB(245,242,247),muted=Color3.fromRGB(161,155,168),pink=Color3.fromRGB(244,48,149),cyan=Color3.fromRGB(31,184,207),gold=Color3.fromRGB(224,178,90),green=Color3.fromRGB(66,205,128),red=Color3.fromRGB(217,72,93)}
local function round(o,r)local x=Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 12);x.Parent=o end
local function stroke(o,c,t,tr)local x=Instance.new("UIStroke");x.Color=c or C.pink;x.Thickness=t or 1;x.Transparency=tr or .45;x.Parent=o end
local function text(parent,value,pos,size,font,ts,color)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=value;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 14;l.TextColor3=color or C.white;l.TextWrapped=true;l.Parent=parent;return l
end
local function btn(parent,value,pos,size,color)
 local b=Instance.new("TextButton");b.Text=value;b.Position=pos;b.Size=size;b.BackgroundColor3=color or C.card2;b.BorderSizePixel=0;b.Font=Enum.Font.GothamSemibold;b.TextSize=13;b.TextColor3=C.white;b.AutoButtonColor=true;b.Parent=parent;round(b,10);return b
end

local launcher=btn(gui,"✦  SOCIAL",UDim2.fromOffset(16,112),UDim2.fromOffset(118,42),Color3.fromRGB(29,23,35));stroke(launcher,C.cyan,1,.45)
local panel=Instance.new("Frame");panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.53);panel.Size=UDim2.fromOffset(430,430);panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0;panel.Visible=false;panel.Parent=gui;round(panel,18);stroke(panel,C.pink,1,.38)
local sizeLimit=Instance.new("UISizeConstraint");sizeLimit.MinSize=Vector2.new(310,330);sizeLimit.MaxSize=Vector2.new(470,520);sizeLimit.Parent=panel

local title=text(panel,"BBYA SOCIAL",UDim2.fromOffset(20,16),UDim2.new(1,-76,0,28),Enum.Font.GothamBlack,20,C.white)
local sub=text(panel,"Emotes & player interactions",UDim2.fromOffset(20,44),UDim2.new(1,-76,0,20),Enum.Font.Gotham,11,C.muted)
local close=btn(panel,"×",UDim2.new(1,-52,0,14),UDim2.fromOffset(36,36),Color3.fromRGB(41,35,47));close.TextSize=21
local emoteTab=btn(panel,"EMOTES",UDim2.fromOffset(18,78),UDim2.new(.5,-27,0,42),Color3.fromRGB(81,30,62))
local carryTab=btn(panel,"CARRY",UDim2.new(.5,9,0,78),UDim2.new(.5,-27,0,42),C.card2)
local body=Instance.new("Frame");body.Position=UDim2.fromOffset(18,132);body.Size=UDim2.new(1,-36,1,-150);body.BackgroundTransparency=1;body.Parent=panel

local activeTab="emotes"
local carryActive=false
local carryRole=nil
local otherName=nil
local pendingRequest=false
local currentRequestCarrierId=nil
local toastToken=0

local function viewportLayout()
 local vp=camera.ViewportSize
 launcher.Position=UDim2.fromOffset(14,math.max(84,math.min(116,vp.Y*.16)))
 local w=math.clamp(vp.X-28,310,470)
 local h=math.clamp(vp.Y-105,330,500)
 panel.Size=UDim2.fromOffset(w,h)
end
viewportLayout();camera:GetPropertyChangedSignal("ViewportSize"):Connect(viewportLayout)

local function toast(msg,color)
 toastToken+=1;local token=toastToken
 local t=Instance.new("TextLabel");t.AnchorPoint=Vector2.new(.5,1);t.Position=UDim2.new(.5,0,1,-22);t.Size=UDim2.new(.82,0,0,42);t.BackgroundColor3=C.bg;t.BackgroundTransparency=.06;t.BorderSizePixel=0;t.Text=tostring(msg);t.TextColor3=C.white;t.TextSize=12;t.Font=Enum.Font.GothamMedium;t.TextWrapped=true;t.ZIndex=100;t.Parent=gui;round(t,10);stroke(t,color or C.pink,1,.5)
 task.delay(2.4,function()if token==toastToken and t.Parent then t:Destroy() elseif t.Parent then t:Destroy() end end)
end
local function clearBody()for _,c in ipairs(body:GetChildren()) do c:Destroy() end end

local EMOTES={{"DANCE 1","dance"},{"DANCE 2","dance2"},{"DANCE 3","dance3"},{"WAVE","wave"},{"CHEER","cheer"},{"LAUGH","laugh"},{"POINT","point"}}
local function playEmote(name)
 local ch=player.Character;local hum=ch and ch:FindFirstChildOfClass("Humanoid")
 if not hum or hum.Health<=0 or carryActive then if carryActive then toast("Emote dinonaktifkan saat Carry aktif.",C.gold) end;return end
 local ok=pcall(function()hum:PlayEmote(name)end)
 if not ok then toast("Emote belum tersedia untuk avatar ini.",C.red) end
end

local renderTab
local function renderEmotes()
 clearBody()
 text(body,"DANCE & EMOTES",UDim2.fromOffset(2,0),UDim2.new(1,-4,0,24),Enum.Font.GothamBold,14,C.white)
 text(body,"Tap sekali untuk langsung play. Bergerak akan mengikuti kontrol avatar normal.",UDim2.fromOffset(2,24),UDim2.new(1,-4,0,36),Enum.Font.Gotham,11,C.muted)
 local grid=Instance.new("Frame");grid.Position=UDim2.fromOffset(0,70);grid.Size=UDim2.new(1,0,1,-70);grid.BackgroundTransparency=1;grid.Parent=body
 local layout=Instance.new("UIGridLayout");layout.CellPadding=UDim2.fromOffset(8,8);layout.CellSize=UDim2.new(.5,-4,0,48);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=grid
 for i,d in ipairs(EMOTES) do
  local b=btn(grid,d[1],UDim2.new(),UDim2.new(),i<=3 and Color3.fromRGB(57,31,52) or C.card2);b.LayoutOrder=i
  stroke(b,i<=3 and C.pink or C.cyan,1,.65)
  b.MouseButton1Click:Connect(function()playEmote(d[2])end)
 end
end

local function rootOf(plr)
 local ch=plr.Character;return ch and ch:FindFirstChild("HumanoidRootPart")
end
local function nearbyPlayers()
 local mine=rootOf(player);if not mine then return {} end
 local out={}
 for _,p in ipairs(Players:GetPlayers()) do
  if p~=player then
   local r=rootOf(p)
   if r then
    local dist=(mine.Position-r.Position).Magnitude
    if dist<=18 then table.insert(out,{p=p,dist=dist}) end
   end
  end
 end
 table.sort(out,function(a,b)return a.dist<b.dist end)
 return out
end

local function renderCarry()
 clearBody()
 if carryActive then
  text(body,carryRole=="carrier" and "CARRY ACTIVE" or "YOU ARE BEING CARRIED",UDim2.fromOffset(2,2),UDim2.new(1,-4,0,28),Enum.Font.GothamBlack,16,C.green)
  text(body,"With "..tostring(otherName or "player")..". Either player can end the carry.",UDim2.fromOffset(2,34),UDim2.new(1,-4,0,46),Enum.Font.Gotham,12,C.muted)
  local d=btn(body,"DROP / END CARRY",UDim2.fromOffset(0,96),UDim2.new(1,0,0,52),Color3.fromRGB(83,31,43));stroke(d,C.red,1,.3)
  d.MouseButton1Click:Connect(function()remote:FireServer("dropCarry")end)
  return
 end
 text(body,"CARRY PLAYER",UDim2.fromOffset(2,0),UDim2.new(1,-4,0,24),Enum.Font.GothamBold,14,C.white)
 text(body,"Pilih player di dekatmu. Carry hanya aktif setelah mereka ACCEPT.",UDim2.fromOffset(2,24),UDim2.new(1,-4,0,36),Enum.Font.Gotham,11,C.muted)
 if pendingRequest then
  local pending=text(body,"Request sedang menunggu jawaban…",UDim2.fromOffset(0,72),UDim2.new(1,0,0,34),Enum.Font.GothamMedium,12,C.gold)
  pending.TextXAlignment=Enum.TextXAlignment.Center
  local cancel=btn(body,"CANCEL REQUEST",UDim2.fromOffset(0,114),UDim2.new(1,0,0,46),C.card2)
  cancel.MouseButton1Click:Connect(function()remote:FireServer("cancelCarryRequest");pendingRequest=false;renderCarry()end)
  return
 end
 local near=nearbyPlayers()
 if #near==0 then
  local none=text(body,"Belum ada player lain dalam jarak Carry.",UDim2.fromOffset(0,82),UDim2.new(1,0,0,46),Enum.Font.GothamMedium,12,C.muted);none.TextXAlignment=Enum.TextXAlignment.Center
  return
 end
 local scroll=Instance.new("ScrollingFrame");scroll.Position=UDim2.fromOffset(0,70);scroll.Size=UDim2.new(1,0,1,-70);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=3;scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.new();scroll.Parent=body
 local list=Instance.new("UIListLayout");list.Padding=UDim.new(0,8);list.Parent=scroll
 for _,item in ipairs(near) do
  local p=item.p
  local row=btn(scroll,string.format("%s  @%s     %.0f studs",p.DisplayName,p.Name,item.dist),UDim2.new(),UDim2.new(1,-4,0,48),C.card2);row.TextXAlignment=Enum.TextXAlignment.Left
  local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,12);pad.Parent=row
  row.MouseButton1Click:Connect(function()pendingRequest=true;remote:FireServer("requestCarry",p.UserId);renderCarry()end)
 end
end

renderTab=function(which)
 activeTab=which
 emoteTab.BackgroundColor3=which=="emotes" and Color3.fromRGB(81,30,62) or C.card2
 carryTab.BackgroundColor3=which=="carry" and Color3.fromRGB(29,66,75) or C.card2
 if which=="emotes" then renderEmotes() else renderCarry() end
end
launcher.MouseButton1Click:Connect(function()panel.Visible=not panel.Visible;if panel.Visible then renderTab(activeTab) end end)
close.MouseButton1Click:Connect(function()panel.Visible=false end)
emoteTab.MouseButton1Click:Connect(function()renderTab("emotes")end)
carryTab.MouseButton1Click:Connect(function()renderTab("carry")end)
renderTab("emotes")

local function incomingRequest(data)
 currentRequestCarrierId=data.carrierUserId
 local modal=Instance.new("Frame");modal.AnchorPoint=Vector2.new(.5,.5);modal.Position=UDim2.fromScale(.5,.53);modal.Size=UDim2.fromOffset(330,190);modal.BackgroundColor3=C.bg;modal.BorderSizePixel=0;modal.ZIndex=80;modal.Parent=gui;round(modal,16);stroke(modal,C.cyan,1,.28)
 text(modal,"CARRY REQUEST",UDim2.fromOffset(18,16),UDim2.new(1,-36,0,28),Enum.Font.GothamBlack,17,C.white).ZIndex=81
 local who=text(modal,tostring(data.carrierName or "Player").." wants to carry you.",UDim2.fromOffset(18,52),UDim2.new(1,-36,0,50),Enum.Font.Gotham,13,C.muted);who.ZIndex=81
 local no=btn(modal,"DECLINE",UDim2.fromOffset(18,124),UDim2.new(.5,-27,0,46),Color3.fromRGB(68,31,39));no.ZIndex=82
 local yes=btn(modal,"ACCEPT",UDim2.new(.5,9,0,124),UDim2.new(.5,-27,0,46),Color3.fromRGB(30,76,64));yes.ZIndex=82
 no.MouseButton1Click:Connect(function()remote:FireServer("declineCarry",data.carrierUserId);currentRequestCarrierId=nil;modal:Destroy()end)
 yes.MouseButton1Click:Connect(function()remote:FireServer("acceptCarry",data.carrierUserId);currentRequestCarrierId=nil;modal:Destroy()end)
 task.delay(15.5,function()if modal.Parent then modal:Destroy();currentRequestCarrierId=nil end end)
end

remote.OnClientEvent:Connect(function(kind,data)
 data=data or {}
 if kind=="carryRequest" then incomingRequest(data)
 elseif kind=="requestSent" then pendingRequest=true;toast("Carry request sent to "..tostring(data.targetName or "player"),C.cyan);if activeTab=="carry" and panel.Visible then renderCarry() end
 elseif kind=="requestClosed" then
  pendingRequest=false
  local reasons={declined="Carry request declined.",expired="Carry request expired.",too_far="Player terlalu jauh.",busy="Player sedang sibuk.",target_pending="Player sedang menerima request lain.",gone="Player sudah tidak tersedia.",cancelled="Carry request dibatalkan."}
  if data.reason and reasons[data.reason] then toast(reasons[data.reason],data.reason=="declined" and C.red or C.gold) end
  if activeTab=="carry" and panel.Visible then renderCarry() end
 elseif kind=="carryState" then
  carryActive=data.active==true;carryRole=data.role;otherName=data.otherName;pendingRequest=false
  launcher.Text=carryActive and "●  CARRY" or "✦  SOCIAL"
  launcher.BackgroundColor3=carryActive and Color3.fromRGB(29,72,59) or Color3.fromRGB(29,23,35)
  if carryActive then toast("Carry active with "..tostring(otherName or "player"),C.green) else toast("Carry ended.",C.muted) end
  if activeTab=="carry" and panel.Visible then renderCarry() end
 end
end)

player.CharacterAdded:Connect(function()carryActive=false;carryRole=nil;otherName=nil;pendingRequest=false;launcher.Text="✦  SOCIAL";panel.Visible=false end)

print("[BBYA] Social Hangout client v1 online: emotes + carry menu")
