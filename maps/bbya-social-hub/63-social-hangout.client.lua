-- BBYA SOCIAL HUB — SOCIAL HANGOUT CLIENT v3
-- Compact mobile controls: circular DANCE + CARRY buttons above the native joystick.
-- Nine dance animations + standard emotes; consent carry remains server-authoritative.

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

local C={bg=Color3.fromRGB(12,11,16),card=Color3.fromRGB(29,25,34),card2=Color3.fromRGB(39,34,45),white=Color3.fromRGB(246,244,248),muted=Color3.fromRGB(166,160,172),pink=Color3.fromRGB(244,48,149),cyan=Color3.fromRGB(31,184,207),gold=Color3.fromRGB(224,178,90),green=Color3.fromRGB(66,205,128),red=Color3.fromRGB(217,72,93)}
local function corner(o,r)local x=Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 12);x.Parent=o end
local function circle(o)local x=Instance.new("UICorner");x.CornerRadius=UDim.new(1,0);x.Parent=o end
local function stroke(o,c,t,tr)local x=Instance.new("UIStroke");x.Color=c or C.pink;x.Thickness=t or 1;x.Transparency=tr or .4;x.Parent=o end
local function text(parent,value,pos,size,font,ts,color)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=value;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 13;l.TextColor3=color or C.white;l.TextWrapped=true;l.Parent=parent;return l
end
local function button(parent,value,pos,size,color)
 local b=Instance.new("TextButton");b.Text=value;b.Position=pos;b.Size=size;b.BackgroundColor3=color or C.card;b.BorderSizePixel=0;b.Font=Enum.Font.GothamSemibold;b.TextSize=12;b.TextColor3=C.white;b.AutoButtonColor=true;b.Parent=parent;corner(b,10);return b
end
local function roundButton(parent,value,color)
 local b=Instance.new("TextButton");b.Text=value;b.Size=UDim2.fromOffset(58,58);b.BackgroundColor3=color;b.BorderSizePixel=0;b.Font=Enum.Font.GothamBlack;b.TextSize=11;b.TextColor3=C.white;b.AutoButtonColor=true;b.Parent=parent;circle(b);stroke(b,C.white,1,.72);return b
end

local danceLauncher=roundButton(gui,"DANCE",Color3.fromRGB(76,27,59))
local carryLauncher=roundButton(gui,"CARRY",Color3.fromRGB(22,58,68))

local function makePanel(name,titleValue,accent)
 local p=Instance.new("Frame");p.Name=name;p.AnchorPoint=Vector2.new(0,1);p.Size=UDim2.fromOffset(390,390);p.BackgroundColor3=C.bg;p.BorderSizePixel=0;p.Visible=false;p.Parent=gui;corner(p,18);stroke(p,accent,1,.32)
 text(p,titleValue,UDim2.fromOffset(18,14),UDim2.new(1,-66,0,28),Enum.Font.GothamBlack,19,C.white)
 local close=button(p,"×",UDim2.new(1,-50,0,12),UDim2.fromOffset(36,36),C.card2);close.TextSize=20
 close.MouseButton1Click:Connect(function()p.Visible=false end)
 return p
end
local dancePanel=makePanel("DancePanel","DANCE & EMOTES",C.pink)
local carryPanel=makePanel("CarryPanel","CARRY PLAYER",C.cyan)

local toastToken=0
local function toast(msg,color)
 toastToken+=1;local token=toastToken
 local t=Instance.new("TextLabel");t.AnchorPoint=Vector2.new(.5,1);t.Position=UDim2.new(.5,0,1,-26);t.Size=UDim2.new(.82,0,0,42);t.BackgroundColor3=C.bg;t.BackgroundTransparency=.04;t.BorderSizePixel=0;t.Text=tostring(msg);t.TextColor3=C.white;t.TextSize=12;t.Font=Enum.Font.GothamMedium;t.TextWrapped=true;t.ZIndex=100;t.Parent=gui;corner(t,10);stroke(t,color or C.pink,1,.5)
 task.delay(2.5,function()if token==toastToken and t.Parent then t:Destroy() elseif t.Parent then t:Destroy() end end)
end

local function layout()
 local vp=camera and camera.ViewportSize or Vector2.new(1280,720)
 -- Native Roblox mobile joystick sits bottom-left. These controls are kept just above it.
 local bottom=math.clamp(math.floor(vp.Y*.25),170,220)
 danceLauncher.Position=UDim2.new(0,10,1,-bottom)
 carryLauncher.Position=UDim2.new(0,74,1,-bottom)
 local panelW=math.clamp(vp.X-24,306,420)
 local panelH=math.clamp(vp.Y-150,330,440)
 dancePanel.Size=UDim2.fromOffset(panelW,panelH);carryPanel.Size=UDim2.fromOffset(panelW,panelH)
 dancePanel.Position=UDim2.new(0,10,1,-bottom-12)
 carryPanel.Position=UDim2.new(0,10,1,-bottom-12)
end
layout()
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(layout) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;layout()end)

local carryActive=false
local carryRole=nil
local otherName=nil
local pendingRequest=false
local activeDanceTrack=nil

local DANCES={
 {"DANCE 1",507771019,"dance"},{"DANCE 2",507771955,"dance2"},{"DANCE 3",507772104,"dance3"},
 {"DANCE 4",507776043,"dance2"},{"DANCE 5",507776720,"dance3"},{"DANCE 6",507776879,"dance"},
 {"DANCE 7",507777268,"dance3"},{"DANCE 8",507777451,"dance"},{"DANCE 9",507777623,"dance2"},
}
local function humanoid()
 local ch=player.Character
 return ch and ch:FindFirstChildOfClass("Humanoid")
end
local function stopDance()
 if activeDanceTrack then pcall(function()activeDanceTrack:Stop(.15)end);activeDanceTrack=nil end
end
local function playDance(assetId,fallback)
 if carryActive then toast("Dance dinonaktifkan saat Carry aktif.",C.gold);return end
 local hum=humanoid();if not hum or hum.Health<=0 then return end
 stopDance()
 if hum.RigType==Enum.HumanoidRigType.R15 then
  local animator=hum:FindFirstChildOfClass("Animator") or Instance.new("Animator",hum)
  local anim=Instance.new("Animation");anim.AnimationId="rbxassetid://"..tostring(assetId)
  local ok,track=pcall(function()return animator:LoadAnimation(anim)end)
  anim:Destroy()
  if ok and track then
   track.Priority=Enum.AnimationPriority.Action;track.Looped=true;track:Play(.12);activeDanceTrack=track;return
  end
 end
 pcall(function()hum:PlayEmote(fallback or "dance")end)
end
local function playStandard(name)
 if carryActive then toast("Emote dinonaktifkan saat Carry aktif.",C.gold);return end
 stopDance();local hum=humanoid();if hum then pcall(function()hum:PlayEmote(name)end)end
end

text(dancePanel,"9 dances + standard emotes • move to stop the custom loop",UDim2.fromOffset(18,46),UDim2.new(1,-36,0,30),Enum.Font.Gotham,10,C.muted)
local danceScroll=Instance.new("ScrollingFrame");danceScroll.Position=UDim2.fromOffset(16,82);danceScroll.Size=UDim2.new(1,-32,1,-98);danceScroll.BackgroundTransparency=1;danceScroll.BorderSizePixel=0;danceScroll.ScrollBarThickness=3;danceScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;danceScroll.CanvasSize=UDim2.new();danceScroll.Parent=dancePanel
local danceGrid=Instance.new("UIGridLayout");danceGrid.CellPadding=UDim2.fromOffset(8,8);danceGrid.CellSize=UDim2.new(.5,-5,0,44);danceGrid.Parent=danceScroll
for i,d in ipairs(DANCES) do
 local b=button(danceScroll,d[1],UDim2.new(),UDim2.new(),i%2==0 and Color3.fromRGB(50,31,48) or Color3.fromRGB(58,30,49));stroke(b,C.pink,1,.66)
 b.MouseButton1Click:Connect(function()playDance(d[2],d[3])end)
end
for _,e in ipairs({{"WAVE","wave"},{"CHEER","cheer"},{"LAUGH","laugh"},{"POINT","point"}}) do
 local b=button(danceScroll,e[1],UDim2.new(),UDim2.new(),C.card2);stroke(b,C.cyan,1,.7);b.MouseButton1Click:Connect(function()playStandard(e[2])end)
end
local stop=button(danceScroll,"STOP",UDim2.new(),UDim2.new(),Color3.fromRGB(72,31,39));stroke(stop,C.red,1,.55);stop.MouseButton1Click:Connect(stopDance)

danceLauncher.MouseButton1Click:Connect(function()
 carryPanel.Visible=false;dancePanel.Visible=not dancePanel.Visible
end)
carryLauncher.MouseButton1Click:Connect(function()
 dancePanel.Visible=false;carryPanel.Visible=not carryPanel.Visible
end)

local function rootOf(plr)local ch=plr.Character;return ch and ch:FindFirstChild("HumanoidRootPart")end
local function nearbyPlayers()
 local mine=rootOf(player);if not mine then return {} end
 local out={}
 for _,p in ipairs(Players:GetPlayers()) do
  if p~=player then local r=rootOf(p);if r then local dist=(mine.Position-r.Position).Magnitude;if dist<=18 then table.insert(out,{p=p,dist=dist})end end end
 end
 table.sort(out,function(a,b)return a.dist<b.dist end);return out
end
local function clearCarryBody()
 for _,c in ipairs(carryPanel:GetChildren()) do
  if c:GetAttribute("CarryDynamic")==true then c:Destroy() end
 end
end
local function mark(o)o:SetAttribute("CarryDynamic",true);return o end
local renderCarry
renderCarry=function()
 clearCarryBody()
 if carryActive then
  local a=mark(text(carryPanel,carryRole=="carrier" and "CARRY ACTIVE" or "YOU ARE BEING CARRIED",UDim2.fromOffset(18,58),UDim2.new(1,-36,0,28),Enum.Font.GothamBlack,15,C.green))
  local b=mark(text(carryPanel,"With "..tostring(otherName or "player"),UDim2.fromOffset(18,92),UDim2.new(1,-36,0,28),Enum.Font.Gotham,12,C.muted))
  local drop=mark(button(carryPanel,"DROP / END CARRY",UDim2.fromOffset(18,132),UDim2.new(1,-36,0,50),Color3.fromRGB(76,31,42)));stroke(drop,C.red,1,.35);drop.MouseButton1Click:Connect(function()remote:FireServer("dropCarry")end)
  return
 end
 local hint=mark(text(carryPanel,"Nearby players • consent required",UDim2.fromOffset(18,52),UDim2.new(1,-36,0,26),Enum.Font.Gotham,10,C.muted))
 if pendingRequest then
  local waiting=mark(text(carryPanel,"Waiting for response…",UDim2.fromOffset(18,92),UDim2.new(1,-36,0,34),Enum.Font.GothamBold,12,C.gold));waiting.TextXAlignment=Enum.TextXAlignment.Center
  local cancel=mark(button(carryPanel,"CANCEL REQUEST",UDim2.fromOffset(18,138),UDim2.new(1,-36,0,46),C.card2));cancel.MouseButton1Click:Connect(function()remote:FireServer("cancelCarryRequest");pendingRequest=false;renderCarry()end)
  return
 end
 local near=nearbyPlayers()
 if #near==0 then
  local none=mark(text(carryPanel,"No player within carry range.",UDim2.fromOffset(18,106),UDim2.new(1,-36,0,44),Enum.Font.GothamMedium,12,C.muted));none.TextXAlignment=Enum.TextXAlignment.Center
  return
 end
 local scroll=mark(Instance.new("ScrollingFrame"));scroll.Position=UDim2.fromOffset(16,88);scroll.Size=UDim2.new(1,-32,1,-104);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=3;scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.new();scroll.Parent=carryPanel
 local list=Instance.new("UIListLayout");list.Padding=UDim.new(0,8);list.Parent=scroll
 for _,item in ipairs(near) do
  local p=item.p
  local row=button(scroll,string.format("%s  •  %.0f studs",p.DisplayName,item.dist),UDim2.new(),UDim2.new(1,-4,0,46),C.card2);row.TextXAlignment=Enum.TextXAlignment.Left
  local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,12);pad.Parent=row
  row.MouseButton1Click:Connect(function()pendingRequest=true;remote:FireServer("requestCarry",p.UserId);renderCarry()end)
 end
end
carryLauncher.MouseButton1Click:Connect(function()if carryPanel.Visible then renderCarry()end end)

local function incomingRequest(data)
 local modal=Instance.new("Frame");modal.AnchorPoint=Vector2.new(.5,.5);modal.Position=UDim2.fromScale(.5,.52);modal.Size=UDim2.fromOffset(330,190);modal.BackgroundColor3=C.bg;modal.BorderSizePixel=0;modal.ZIndex=80;modal.Parent=gui;corner(modal,16);stroke(modal,C.cyan,1,.28)
 text(modal,"CARRY REQUEST",UDim2.fromOffset(18,16),UDim2.new(1,-36,0,28),Enum.Font.GothamBlack,17,C.white).ZIndex=81
 local who=text(modal,tostring(data.carrierName or "Player").." wants to carry you.",UDim2.fromOffset(18,52),UDim2.new(1,-36,0,50),Enum.Font.Gotham,13,C.muted);who.ZIndex=81
 local no=button(modal,"DECLINE",UDim2.fromOffset(18,124),UDim2.new(.5,-27,0,46),Color3.fromRGB(68,31,39));no.ZIndex=82
 local yes=button(modal,"ACCEPT",UDim2.new(.5,9,0,124),UDim2.new(.5,-27,0,46),Color3.fromRGB(30,76,64));yes.ZIndex=82
 no.MouseButton1Click:Connect(function()remote:FireServer("declineCarry",data.carrierUserId);modal:Destroy()end)
 yes.MouseButton1Click:Connect(function()remote:FireServer("acceptCarry",data.carrierUserId);modal:Destroy()end)
 task.delay(15.5,function()if modal.Parent then modal:Destroy()end end)
end

remote.OnClientEvent:Connect(function(kind,data)
 data=data or {}
 if kind=="carryRequest" then incomingRequest(data)
 elseif kind=="requestSent" then pendingRequest=true;toast("Carry request sent to "..tostring(data.targetName or "player"),C.cyan);if carryPanel.Visible then renderCarry()end
 elseif kind=="requestClosed" then
  pendingRequest=false
  local reasons={declined="Carry request declined.",expired="Carry request expired.",too_far="Player terlalu jauh.",busy="Player sedang sibuk.",target_pending="Player sedang menerima request lain.",gone="Player sudah tidak tersedia.",cancelled="Carry request dibatalkan."}
  if data.reason and reasons[data.reason] then toast(reasons[data.reason],data.reason=="declined" and C.red or C.gold)end
  if carryPanel.Visible then renderCarry()end
 elseif kind=="carryState" then
  carryActive=data.active==true;carryRole=data.role;otherName=data.otherName;pendingRequest=false;stopDance()
  carryLauncher.BackgroundColor3=carryActive and Color3.fromRGB(27,78,60) or Color3.fromRGB(22,58,68)
  carryLauncher.Text=carryActive and "DROP" or "CARRY"
  if carryPanel.Visible then renderCarry()end
 end
end)

local movementConn=nil
local function bindCharacter(ch)
 stopDance();carryActive=false;carryRole=nil;otherName=nil;pendingRequest=false;dancePanel.Visible=false;carryPanel.Visible=false;carryLauncher.Text="CARRY"
 if movementConn then movementConn:Disconnect();movementConn=nil end
 local hum=ch:WaitForChild("Humanoid",10)
 if hum then movementConn=hum.Running:Connect(function(speed)if speed>1.5 then stopDance()end end)end
end
if player.Character then task.defer(bindCharacter,player.Character)end
player.CharacterAdded:Connect(bindCharacter)

print("[BBYA] Social Hangout client v3 online: compact DANCE + CARRY / 9 dances")
