-- BBYA MUSIC UI TEST — SOCIAL HANGOUT CORE v5
-- FUNCTION ONLY. UI KERNEL v1 owns all outer geometry/placement/visibility coordination.
-- 92-freecam.client.lua owns the 212-entry Dance catalog content.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local remote=remotes and remotes:WaitForChild("SocialHangout",30)
if not remote then return end
local pg=player:WaitForChild("PlayerGui")
local old=pg:FindFirstChild("BBYASocialHangoutUI");if old then old:Destroy() end

local C={bg=Color3.fromRGB(12,11,16),card=Color3.fromRGB(29,25,34),card2=Color3.fromRGB(39,34,45),white=Color3.fromRGB(246,244,248),muted=Color3.fromRGB(166,160,172),pink=Color3.fromRGB(244,48,149),cyan=Color3.fromRGB(31,184,207),gold=Color3.fromRGB(224,178,90),green=Color3.fromRGB(66,205,128)}
local function corner(o,r)local x=Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 12);x.Parent=o end
local function stroke(o,c,tr)local x=Instance.new("UIStroke");x.Color=c;x.Thickness=1;x.Transparency=tr or .4;x.Parent=o end
local function text(parent,value,pos,size,font,ts,color)local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=value;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 13;l.TextColor3=color or C.white;l.TextWrapped=true;l.Parent=parent;return l end
local function button(parent,value,pos,size,color)local b=Instance.new("TextButton");b.Text=value;b.Position=pos or UDim2.new();b.Size=size or UDim2.new();b.BackgroundColor3=color or C.card;b.BorderSizePixel=0;b.Font=Enum.Font.GothamSemibold;b.TextSize=12;b.TextColor3=C.white;b.AutoButtonColor=true;b.Parent=parent;corner(b,10);return b end

local gui=Instance.new("ScreenGui");gui.Name="BBYASocialHangoutUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=44;gui.Parent=pg
gui:SetAttribute("BBYADanceShellAuthority","TEST_V5_FUNCTION_ONLY");gui:SetAttribute("BBYADanceCatalogCount",212)
local danceLauncher=button(gui,"DANCE",UDim2.new(1,40,0,0),UDim2.fromOffset(58,40),Color3.fromRGB(76,27,59));danceLauncher.Name="DanceLauncher";danceLauncher.Visible=false
local carryLauncher=button(gui,"CARRY",UDim2.new(1,40,0,44),UDim2.fromOffset(58,40),Color3.fromRGB(22,58,68));carryLauncher.Name="CarryLauncher";carryLauncher.Visible=false

local function makePanel(name,titleValue,accent)
 local p=Instance.new("Frame");p.Name=name;p.AnchorPoint=Vector2.new(1,0);p.Position=UDim2.new(1,-96,0,48);p.Size=UDim2.fromOffset(240,500);p.BackgroundColor3=C.bg;p.BackgroundTransparency=.28;p.BorderSizePixel=0;p.Visible=false;p.ClipsDescendants=true;p.Parent=gui;corner(p,16);stroke(p,accent,.32)
 text(p,titleValue,UDim2.fromOffset(14,10),UDim2.new(1,-56,0,30),Enum.Font.GothamBlack,16,C.white)
 local close=button(p,"×",UDim2.new(1,-44,0,8),UDim2.fromOffset(34,34),C.card2);close.TextSize=18;close.Activated:Connect(function()p.Visible=false end)
 return p
end
local dancePanel=makePanel("DancePanel","DANCE & EMOTES • 212",C.pink)
local carryPanel=makePanel("CarryPanel","CARRY PLAYER",C.cyan)
text(dancePanel,"Loading 212 dance catalog...",UDim2.fromOffset(14,46),UDim2.new(1,-28,0,24),Enum.Font.GothamMedium,9,C.muted)
dancePanel:SetAttribute("BBYADanceCatalogExpected",212)

danceLauncher.Activated:Connect(function()carryPanel.Visible=false;dancePanel.Visible=not dancePanel.Visible end)
carryLauncher.Activated:Connect(function()dancePanel.Visible=false;carryPanel.Visible=not carryPanel.Visible end)

local carryActive=false;local carryRole=nil;local otherName=nil;local pending=false
local function rootOf(plr)local ch=plr.Character;return ch and ch:FindFirstChild("HumanoidRootPart")end
local function nearbyPlayers()
 local mine=rootOf(player);if not mine then return {} end
 local out={};for _,p in ipairs(Players:GetPlayers()) do if p~=player then local r=rootOf(p);if r then local dist=(mine.Position-r.Position).Magnitude;if dist<=18 then table.insert(out,{p=p,dist=dist})end end end end
 table.sort(out,function(a,b)return a.dist<b.dist end);return out
end
local function clearCarry()for _,o in ipairs(carryPanel:GetChildren()) do if o:GetAttribute("CarryDynamic")==true then o:Destroy() end end end
local function dyn(o)o:SetAttribute("CarryDynamic",true);return o end
local renderCarry
renderCarry=function()
 clearCarry()
 if carryActive then
  dyn(text(carryPanel,carryRole=="carrier" and "CARRY ACTIVE" or "YOU ARE BEING CARRIED",UDim2.fromOffset(14,52),UDim2.new(1,-28,0,28),Enum.Font.GothamBlack,13,C.green))
  dyn(text(carryPanel,"With "..tostring(otherName or "player"),UDim2.fromOffset(14,82),UDim2.new(1,-28,0,22),Enum.Font.Gotham,10,C.muted))
  local drop=dyn(button(carryPanel,"DROP / END CARRY",UDim2.fromOffset(14,118),UDim2.new(1,-28,0,42),Color3.fromRGB(76,31,42)));drop.Activated:Connect(function()remote:FireServer("dropCarry")end);return
 end
 dyn(text(carryPanel,"Nearby players • consent required",UDim2.fromOffset(14,48),UDim2.new(1,-28,0,22),Enum.Font.Gotham,9,C.muted))
 if pending then dyn(text(carryPanel,"Waiting for response...",UDim2.fromOffset(14,78),UDim2.new(1,-28,0,28),Enum.Font.GothamBold,10,C.gold));return end
 local near=nearbyPlayers();if #near==0 then dyn(text(carryPanel,"No player within carry range.",UDim2.fromOffset(14,86),UDim2.new(1,-28,0,40),Enum.Font.GothamMedium,10,C.muted));return end
 local scroll=dyn(Instance.new("ScrollingFrame"));scroll.Position=UDim2.fromOffset(12,78);scroll.Size=UDim2.new(1,-24,1,-92);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=3;scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.new();scroll.Active=true;scroll.Parent=carryPanel
 local list=Instance.new("UIListLayout");list.Padding=UDim.new(0,7);list.Parent=scroll
 for _,item in ipairs(near) do local p=item.p;local row=button(scroll,string.format("%s • %.0f studs",p.DisplayName,item.dist),nil,UDim2.new(1,-4,0,42),C.card2);row.TextXAlignment=Enum.TextXAlignment.Left;local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,8);pad.Parent=row;row.Activated:Connect(function()pending=true;remote:FireServer("requestCarry",p.UserId);renderCarry()end) end
end
carryPanel:GetPropertyChangedSignal("Visible"):Connect(function()if carryPanel.Visible then renderCarry()end end)

remote.OnClientEvent:Connect(function(kind,data)
 data=data or {}
 if kind=="requestSent" then pending=true;if carryPanel.Visible then renderCarry()end
 elseif kind=="requestClosed" then pending=false;if carryPanel.Visible then renderCarry()end
 elseif kind=="carryState" then carryActive=data.active==true;carryRole=data.role;otherName=data.otherName;pending=false;carryLauncher.Text=carryActive and "DROP" or "CARRY";if carryPanel.Visible then renderCarry()end
 elseif kind=="carryRequest" then
  local modal=Instance.new("Frame");modal.AnchorPoint=Vector2.new(.5,.5);modal.Position=UDim2.fromScale(.5,.52);modal.Size=UDim2.fromOffset(330,186);modal.BackgroundColor3=C.bg;modal.BorderSizePixel=0;modal.ZIndex=80;modal.Parent=gui;corner(modal,16);stroke(modal,C.cyan,.28)
  text(modal,"CARRY REQUEST",UDim2.fromOffset(18,14),UDim2.new(1,-36,0,28),Enum.Font.GothamBlack,16,C.white);text(modal,tostring(data.carrierName or "Player").." wants to carry you.",UDim2.fromOffset(18,50),UDim2.new(1,-36,0,48),Enum.Font.Gotham,12,C.muted)
  local no=button(modal,"DECLINE",UDim2.fromOffset(18,122),UDim2.new(.5,-27,0,44),Color3.fromRGB(68,31,39));local yes=button(modal,"ACCEPT",UDim2.new(.5,9,0,122),UDim2.new(.5,-27,0,44),Color3.fromRGB(30,76,64))
  no.Activated:Connect(function()remote:FireServer("declineCarry",data.carrierUserId);modal:Destroy()end);yes.Activated:Connect(function()remote:FireServer("acceptCarry",data.carrierUserId);modal:Destroy()end);task.delay(15,function()if modal.Parent then modal:Destroy()end end)
 end
end)
print("[BBYA TEST] Social Hangout core v5 online: function-only, UI Kernel owns shell")
