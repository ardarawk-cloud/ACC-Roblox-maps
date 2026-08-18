-- BBYA V6 — UNIFIED MOBILE-SAFE UI
-- One runtime. No stacked legacy ScreenGuis. Panels drag within safe bounds and never disappear.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local ContextActionService=game:GetService("ContextActionService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local net=ReplicatedStorage:WaitForChild("BBYA_V6")
local Notice=net:WaitForChild("Notice")
local Music=net:WaitForChild("Music")
local MusicState=net:WaitForChild("MusicState")
local Teleport=net:WaitForChild("Teleport")
local Lift=net:WaitForChild("Lift")

local old=pg:FindFirstChild("BBYA_V6_UI");if old then old:Destroy() end
local gui=Instance.new("ScreenGui")
gui.Name="BBYA_V6_UI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=false;gui.DisplayOrder=20;gui.Parent=pg

local C={bg=Color3.fromRGB(8,8,13),panel=Color3.fromRGB(17,15,24),panel2=Color3.fromRGB(28,24,37),pink=Color3.fromRGB(255,48,184),cyan=Color3.fromRGB(31,221,255),gold=Color3.fromRGB(255,196,75),white=Color3.fromRGB(245,242,247),muted=Color3.fromRGB(165,158,174),green=Color3.fromRGB(91,225,148)}

local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 12);c.Parent=o end
local function stroke(o,color,thick,trans)local s=Instance.new("UIStroke");s.Color=color or C.pink;s.Thickness=thick or 1;s.Transparency=trans or .15;s.Parent=o;return s end
local function txt(parent,text,size,pos,font,color,align)
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Text=text;t.TextSize=size or 16;t.Font=font or Enum.Font.Gotham;t.TextColor3=color or C.white;t.TextXAlignment=align or Enum.TextXAlignment.Left;t.Size=UDim2.fromOffset(200,28);t.Position=pos or UDim2.fromOffset(0,0);t.Parent=parent;return t
end
local function button(parent,text,size,pos,color)
 local b=Instance.new("TextButton");b.AutoButtonColor=true;b.Text=text;b.TextSize=15;b.Font=Enum.Font.GothamBold;b.TextColor3=C.white;b.BackgroundColor3=color or C.panel2;b.Size=size;b.Position=pos;b.Parent=parent;corner(b,10);return b
end

-- Top status strip: compact, collapsible upward, not giant.
local status=Instance.new("Frame");status.Name="STATUS";status.AnchorPoint=Vector2.new(.5,0);status.Position=UDim2.new(.5,0,0,10);status.Size=UDim2.new(.58,0,0,72);status.BackgroundColor3=C.bg;status.BackgroundTransparency=.08;status.Parent=gui;corner(status,18);stroke(status,C.pink,1.2,.1)
local brand=txt(status,"BBYA",25,UDim2.fromOffset(24,10),Enum.Font.GothamBlack,C.pink);brand.Size=UDim2.fromOffset(110,30)
local who=txt(status,player.DisplayName,14,UDim2.fromOffset(24,40),Enum.Font.GothamBold,C.white);who.Size=UDim2.fromOffset(160,20)
local zoneText=txt(status,"SOCIAL HUB",18,UDim2.new(.25,0,0,13),Enum.Font.GothamBold,C.cyan);zoneText.Size=UDim2.new(.54,0,0,26)
local buildText=txt(status,"V6 CLEANROOM",12,UDim2.new(.25,0,0,42),Enum.Font.Gotham,C.muted);buildText.Size=UDim2.new(.4,0,0,20)
local statusPull=button(status,"⌃",UDim2.fromOffset(56,38),UDim2.new(1,-68,0,17),C.panel2)
local statusParked=false
statusPull.MouseButton1Click:Connect(function()
 statusParked=not statusParked
 if statusParked then status.Position=UDim2.new(.5,0,0,-54);statusPull.Text="⌄" else status.Position=UDim2.new(.5,0,0,10);statusPull.Text="⌃" end
end)

-- Compact edge launchers. They are intentionally small and clear of joystick/jump zones.
local left=Instance.new("Frame");left.Name="LEFT_LAUNCH";left.Position=UDim2.new(0,10,.25,0);left.Size=UDim2.fromOffset(82,280);left.BackgroundColor3=C.bg;left.BackgroundTransparency=.08;left.Parent=gui;corner(left,18);stroke(left,C.pink,1,.12)
local right=Instance.new("Frame");right.Name="RIGHT_LAUNCH";right.AnchorPoint=Vector2.new(1,0);right.Position=UDim2.new(1,-10,.25,0);right.Size=UDim2.fromOffset(82,280);right.BackgroundColor3=C.bg;right.BackgroundTransparency=.08;right.Parent=gui;corner(right,18);stroke(right,C.cyan,1,.12)
local leftItems={{"SOCIAL",C.pink},{"VIP",C.gold},{"PHOTO",C.cyan},{"TP",C.green}}
local rightItems={{"MUSIC",C.pink},{"SAWER",C.pink},{"PROFILE",C.cyan},{"SET",C.gold}}
local launch={}
for i,it in ipairs(leftItems) do local b=button(left,it[1],UDim2.fromOffset(64,54),UDim2.fromOffset(9,10+(i-1)*66),C.panel2);b.TextColor3=it[2];launch[it[1]]=b end
for i,it in ipairs(rightItems) do local b=button(right,it[1],UDim2.fromOffset(64,54),UDim2.fromOffset(9,10+(i-1)*66),C.panel2);b.TextColor3=it[2];launch[it[1]]=b end

local panelRoot=Instance.new("Frame");panelRoot.BackgroundTransparency=1;panelRoot.Size=UDim2.fromScale(1,1);panelRoot.Parent=gui
local active=nil
local function viewport() return workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720) end
local function panelSize()
 local v=viewport();local w=math.min(760,math.max(330,v.X*.72));local h=math.min(520,math.max(320,v.Y*.66));return Vector2.new(w,h)
end
local function clampPanel(p)
 local v=viewport();local s=p.AbsoluteSize;local x=p.AbsolutePosition.X;local y=p.AbsolutePosition.Y
 local minVisible=42;local topSafe=36;local bottomSafe=86
 x=math.clamp(x,-s.X+minVisible,v.X-minVisible)
 y=math.clamp(y,topSafe-s.Y+minVisible,v.Y-bottomSafe-minVisible)
 p.Position=UDim2.fromOffset(x,y)
end
local function centerPanel(p)
 local v=viewport();local s=panelSize();p.Size=UDim2.fromOffset(s.X,s.Y);p.Position=UDim2.fromOffset((v.X-s.X)/2,math.max(94,(v.Y-s.Y)/2));p:SetAttribute("Parked","")
end
local function parkPanel(p,side)
 local v=viewport();local s=p.AbsoluteSize;local visible=36
 if side=="LEFT" then p.Position=UDim2.fromOffset(-s.X+visible,math.clamp(p.AbsolutePosition.Y,48,v.Y-120));p:SetAttribute("Parked","LEFT")
 elseif side=="RIGHT" then p.Position=UDim2.fromOffset(v.X-visible,math.clamp(p.AbsolutePosition.Y,48,v.Y-120));p:SetAttribute("Parked","RIGHT")
 elseif side=="TOP" then p.Position=UDim2.fromOffset(math.clamp(p.AbsolutePosition.X,10,v.X-s.X-10),-s.Y+visible);p:SetAttribute("Parked","TOP") end
end
local function makePanel(name,title)
 local p=Instance.new("Frame");p.Name=name;p.BackgroundColor3=C.panel;p.BackgroundTransparency=.03;p.Visible=false;p.Parent=panelRoot;corner(p,18);stroke(p,C.pink,1.2,.1);centerPanel(p)
 local head=Instance.new("Frame");head.Name="HEADER";head.Size=UDim2.new(1,0,0,58);head.BackgroundColor3=C.bg;head.BackgroundTransparency=.05;head.Parent=p;corner(head,18)
 local ttl=txt(head,title,22,UDim2.fromOffset(22,15),Enum.Font.GothamBlack,C.white);ttl.Size=UDim2.new(1,-150,0,30)
 local move=button(head,"MOVE",UDim2.fromOffset(76,34),UDim2.new(1,-132,0,12),C.panel2);move.TextColor3=C.pink
 local close=button(head,"×",UDim2.fromOffset(42,34),UDim2.new(1,-50,0,12),C.panel2)
 local pull=button(p,"PULL",UDim2.fromOffset(58,30),UDim2.new(0,8,0,8),C.panel2);pull.Visible=false;pull.ZIndex=10
 local body=Instance.new("Frame");body.Name="BODY";body.BackgroundTransparency=1;body.Position=UDim2.fromOffset(14,66);body.Size=UDim2.new(1,-28,1,-80);body.ClipsDescendants=true;body.Parent=p
 close.MouseButton1Click:Connect(function() p.Visible=false;if active==p then active=nil end end)
 pull.MouseButton1Click:Connect(function() centerPanel(p);pull.Visible=false end)
 local dragging=false;local dragStart;local startPos;local dragInput
 local function update(input)
  if not dragging then return end
  local d=input.Position-dragStart;p.Position=UDim2.fromOffset(startPos.X.Offset+d.X,startPos.Y.Offset+d.Y);clampPanel(p)
 end
 move.InputBegan:Connect(function(input)
  if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true;dragStart=input.Position;startPos=p.Position;dragInput=input;pull.Visible=false end
 end)
 UIS.InputChanged:Connect(function(input) if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then update(input) end end)
 UIS.InputEnded:Connect(function(input)
  if dragging and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
   dragging=false;local v=viewport();local a=p.AbsolutePosition;local s=p.AbsoluteSize
   local side=nil
   if a.X<-s.X*.55 then side="LEFT" elseif a.X+s.X>v.X+s.X*.55 then side="RIGHT" elseif a.Y<-s.Y*.55 then side="TOP" end
   if side then parkPanel(p,side);pull.Visible=true else clampPanel(p) end
  end
 end)
 return p,body
end
local function show(p)
 if active and active~=p then active.Visible=false end
 active=p;p.Visible=true
 if p:GetAttribute("Parked") and p:GetAttribute("Parked")~="" then centerPanel(p) end
end

-- MUSIC PANEL: close to approved poster hierarchy, scaled for mobile.
local musicPanel,musicBody=makePanel("MUSIC_PANEL","MUSIC CONTROLLER")
local modeTitle=txt(musicBody,"HYBRID AUTO-DJ",16,UDim2.fromOffset(8,4),Enum.Font.GothamBold,C.pink);modeTitle.Size=UDim2.new(1,-16,0,24)
local now=txt(musicBody,"BBYA 24/7",22,UDim2.fromOffset(8,40),Enum.Font.GothamBlack,C.white);now.Size=UDim2.new(1,-16,0,34)
local meta=txt(musicBody,"AUTO-DJ",13,UDim2.fromOffset(8,76),Enum.Font.Gotham,C.muted);meta.Size=UDim2.new(1,-16,0,24)
local controls=Instance.new("Frame");controls.BackgroundTransparency=1;controls.Position=UDim2.fromOffset(0,112);controls.Size=UDim2.new(1,0,0,56);controls.Parent=musicBody
local playB=button(controls,"PLAY",UDim2.new(.24,-6,1,0),UDim2.fromScale(0,0),C.panel2)
local pauseB=button(controls,"PAUSE",UDim2.new(.24,-6,1,0),UDim2.new(.25,0,0,0),C.panel2)
local nextB=button(controls,"NEXT",UDim2.new(.24,-6,1,0),UDim2.new(.5,0,0,0),C.panel2);nextB.TextColor3=C.cyan
local volB=button(controls,"VOL 58%",UDim2.new(.24,-6,1,0),UDim2.new(.75,0,0,0),C.panel2);volB.TextColor3=C.gold
playB.MouseButton1Click:Connect(function() Music:FireServer("PLAY") end);pauseB.MouseButton1Click:Connect(function() Music:FireServer("PAUSE") end);nextB.MouseButton1Click:Connect(function() Music:FireServer("NEXT") end)
local vol=.58;volB.MouseButton1Click:Connect(function() vol=vol>=.95 and .35 or math.min(1,vol+.1);volB.Text=string.format("VOL %d%%",math.floor(vol*100));Music:FireServer("VOLUME",vol) end)
local modes=Instance.new("Frame");modes.BackgroundTransparency=1;modes.Position=UDim2.fromOffset(0,180);modes.Size=UDim2.new(1,0,0,48);modes.Parent=musicBody
for i,m in ipairs({"ALL","INDO","INTL"}) do local b=button(modes,m,UDim2.new(1/3,-6,1,0),UDim2.new((i-1)/3,0,0,0),C.panel2);b.MouseButton1Click:Connect(function() Music:FireServer("MODE",m) end) end
local queueTitle=txt(musicBody,"PLAYLIST / UP NEXT",15,UDim2.fromOffset(8,244),Enum.Font.GothamBold,C.white);queueTitle.Size=UDim2.new(1,-16,0,24)
local queueBox=Instance.new("Frame");queueBox.Position=UDim2.fromOffset(0,274);queueBox.Size=UDim2.new(1,0,1,-282);queueBox.BackgroundColor3=C.bg;queueBox.BackgroundTransparency=.28;queueBox.Parent=musicBody;corner(queueBox,12)
for i,name in ipairs({"Indo / Breakbeat & Bounce","International / House & EDM","Rooftop / Tropical House","DnB / Techno Rotation"}) do local t=txt(queueBox,string.format("%02d   %s",i,name),14,UDim2.fromOffset(16,10+(i-1)*42),Enum.Font.Gotham,C.white);t.Size=UDim2.new(1,-28,0,30) end
MusicState.OnClientEvent:Connect(function(s) now.Text=s.title or "BBYA 24/7";meta.Text=string.format("%s  •  %s",s.sub or "AUTO-DJ",s.mode or "ALL");vol=s.volume or vol;volB.Text=string.format("VOL %d%%",math.floor(vol*100)) end)
launch.MUSIC.MouseButton1Click:Connect(function() show(musicPanel);Music:FireServer("STATE") end)

-- SAWER PANEL: structurally matches concept; purchases stay disabled until product IDs exist.
local sawerPanel,sawerBody=makePanel("SAWER_PANEL","SAWER / SUPPORT")
local supportCopy=txt(sawerBody,"Dukung creator & Social Hub favoritmu.",15,UDim2.fromOffset(8,8),Enum.Font.Gotham,C.muted);supportCopy.Size=UDim2.new(1,-16,0,28)
local denominations={5,10,25,50,100,250,500}
for i,v in ipairs(denominations) do
 local col=(i-1)%3;local row=math.floor((i-1)/3);local b=button(sawerBody,"R$"..v.."\nPENDING",UDim2.new(1/3,-10,0,72),UDim2.new(col/3,4,0,52+row*82),C.panel2);b.TextColor3=C.muted
 b.MouseButton1Click:Connect(function() Notice:FireServer and Notice:FireServer() end)
end
local pending=txt(sawerBody,"Developer Product ID belum dipasang. Tidak ada transaksi palsu.",14,UDim2.fromOffset(8,312),Enum.Font.Gotham,C.gold);pending.Size=UDim2.new(1,-16,0,44);pending.TextWrapped=true
local top=txt(sawerBody,"TOP SUPPORTERS",15,UDim2.fromOffset(8,370),Enum.Font.GothamBold,C.white);top.Size=UDim2.new(1,-16,0,24)
local topList=txt(sawerBody,"Leaderboard akan memakai receipt server resmi saat produk aktif.",14,UDim2.fromOffset(8,400),Enum.Font.Gotham,C.muted);topList.Size=UDim2.new(1,-16,0,52);topList.TextWrapped=true
launch.SAWER.MouseButton1Click:Connect(function() show(sawerPanel) end)

-- PROFILE PANEL
local profilePanel,profileBody=makePanel("PROFILE_PANEL","PROFILE")
local avatar=Instance.new("ImageLabel");avatar.Size=UDim2.fromOffset(92,92);avatar.Position=UDim2.fromOffset(10,12);avatar.BackgroundColor3=C.panel2;avatar.Parent=profileBody;corner(avatar,46)
local ok,img=pcall(function() return Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size180x180) end);if ok then avatar.Image=img end
local pname=txt(profileBody,player.DisplayName,24,UDim2.fromOffset(120,18),Enum.Font.GothamBlack,C.white);pname.Size=UDim2.new(1,-132,0,34)
local role=txt(profileBody,player:GetAttribute("BBYAQueen") and "BBYA QUEEN" or "SOCIALITE",15,UDim2.fromOffset(120,58),Enum.Font.GothamBold,C.pink);role.Size=UDim2.new(1,-132,0,24)
local socialCopy=txt(profileBody,"BBYA is a social hub: hangout • outfit • photo • rooftop • club",14,UDim2.fromOffset(10,126),Enum.Font.Gotham,C.muted);socialCopy.Size=UDim2.new(1,-20,0,50);socialCopy.TextWrapped=true
launch.PROFILE.MouseButton1Click:Connect(function() show(profilePanel) end)

-- SOCIAL panel: parallel facility choices, not club-first.
local socialPanel,socialBody=makePanel("SOCIAL_PANEL","SOCIAL HUB")
local options={{"COMMONS","A3",C.pink},{"SOCIAL BAR","A5",C.gold},{"CHILL / TALK","A6",C.cyan},{"CLUB / DANCE","A4",C.pink},{"VIP","C1",C.gold},{"ROOFTOP","D1",C.green}}
for i,o in ipairs(options) do local col=(i-1)%2;local row=math.floor((i-1)/2);local b=button(socialBody,o[1],UDim2.new(.5,-8,0,70),UDim2.new(col*.5,4,0,12+row*82),C.panel2);b.TextColor3=o[3];b.MouseButton1Click:Connect(function() Teleport:FireServer(o[2]) end) end
launch.SOCIAL.MouseButton1Click:Connect(function() show(socialPanel) end)

-- TELEPORT/inspection panel.
local tpPanel,tpBody=makePanel("TP_PANEL","ZONE / INSPECTION")
local codes={"A1","A2","A3","A4","A5","A6","B1","B2","B3","C1","C2","C3","D1","D2","D3","D4","D5","D6"}
for i,c in ipairs(codes) do local col=(i-1)%6;local row=math.floor((i-1)/6);local b=button(tpBody,c,UDim2.new(1/6,-6,0,52),UDim2.new(col/6,3,0,12+row*62),C.panel2);b.MouseButton1Click:Connect(function() Teleport:FireServer(c) end) end
local liftTitle=txt(tpBody,"LIFT",15,UDim2.fromOffset(8,210),Enum.Font.GothamBold,C.white);liftTitle.Size=UDim2.fromOffset(80,24)
for i,c in ipairs({"G","VIP","ROOF"}) do local b=button(tpBody,c,UDim2.new(1/3,-8,0,52),UDim2.new((i-1)/3,4,0,242),C.panel2);b.MouseButton1Click:Connect(function() Lift:FireServer(c) end) end
launch.TP.MouseButton1Click:Connect(function() show(tpPanel) end)
launch.VIP.MouseButton1Click:Connect(function() Teleport:FireServer("C1") end)

-- PHOTO / CAMERA PANEL.
local photoPanel,photoBody=makePanel("PHOTO_PANEL","PHOTO / CAMERA")
local cameraMode="NORMAL";local cam=workspace.CurrentCamera;local freeConn=nil;local clean=false;local savedUI={}
local function restoreCamera() if freeConn then freeConn:Disconnect();freeConn=nil end;cameraMode="NORMAL";cam.CameraType=Enum.CameraType.Custom;cam.CameraSubject=player.Character and player.Character:FindFirstChildOfClass("Humanoid") or nil end
local function outfitCam(side)
 restoreCamera();local char=player.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart");if not hrp then return end
 cameraMode="OUTFIT";cam.CameraType=Enum.CameraType.Scriptable
 local yaw=side or 0;local offset=(CFrame.Angles(0,math.rad(yaw),0)*CFrame.new(0,1.8,8)).Position;cam.CFrame=CFrame.new(hrp.Position+offset,hrp.Position+Vector3.new(0,1.8,0))
end
local move={F=false,B=false,L=false,R=false,U=false,D=false};local freeCF=nil
local function startFree()
 restoreCamera();cameraMode="FREE";cam.CameraType=Enum.CameraType.Scriptable;freeCF=cam.CFrame
 freeConn=RunService.RenderStepped:Connect(function(dt)
  local dir=Vector3.zero;if move.F then dir+=Vector3.new(0,0,-1) end;if move.B then dir+=Vector3.new(0,0,1) end;if move.L then dir+=Vector3.new(-1,0,0) end;if move.R then dir+=Vector3.new(1,0,0) end;if move.U then dir+=Vector3.new(0,1,0) end;if move.D then dir+=Vector3.new(0,-1,0) end
  if dir.Magnitude>0 then freeCF=freeCF*CFrame.new(dir.Unit*18*dt);cam.CFrame=freeCF end
 end)
end
local camButtons={{"OUTFIT FRONT",function() outfitCam(0) end},{"OUTFIT LEFT",function() outfitCam(-28) end},{"OUTFIT RIGHT",function() outfitCam(28) end},{"FREECAM",startFree},{"RESET",restoreCamera}}
for i,it in ipairs(camButtons) do local b=button(photoBody,it[1],UDim2.new(.5,-8,0,58),UDim2.new(((i-1)%2)*.5,4,0,12+math.floor((i-1)/2)*68),C.panel2);b.MouseButton1Click:Connect(it[2]) end
local cleanB=button(photoBody,"CLEAN VIEW",UDim2.new(1,-8,0,58),UDim2.new(0,4,0,224),C.panel2);cleanB.TextColor3=C.pink
cleanB.MouseButton1Click:Connect(function() clean=not clean;for _,f in ipairs({status,left,right}) do f.Visible=not clean end;photoPanel.BackgroundTransparency=clean and 1 or .03;photoPanel:FindFirstChild("HEADER").Visible=not clean;photoBody.Visible=not clean end)
local moveFrame=Instance.new("Frame");moveFrame.BackgroundTransparency=1;moveFrame.Position=UDim2.new(0,4,1,-120);moveFrame.Size=UDim2.new(1,-8,0,112);moveFrame.Parent=photoBody
local keyDefs={{"F",.34,0},{"L",.17,.5},{"B",.34,.5},{"R",.51,.5},{"U",.68,0},{"D",.68,.5}}
for _,d in ipairs(keyDefs) do local b=button(moveFrame,d[1],UDim2.new(.15,0,.44,0),UDim2.new(d[2],0,d[3],0),C.panel2);b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then move[d[1]]=true end end);b.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then move[d[1]]=false end end) end
launch.PHOTO.MouseButton1Click:Connect(function() show(photoPanel) end)

-- SETTINGS PANEL
local setPanel,setBody=makePanel("SET_PANEL","SETTINGS")
local resetUI=button(setBody,"RESET UI POSITIONS",UDim2.new(1,-8,0,58),UDim2.new(0,4,0,12),C.panel2)
resetUI.MouseButton1Click:Connect(function() centerPanel(musicPanel);centerPanel(sawerPanel);centerPanel(profilePanel);centerPanel(socialPanel);centerPanel(tpPanel);centerPanel(photoPanel);left.Position=UDim2.new(0,10,.25,0);right.Position=UDim2.new(1,-10,.25,0);status.Position=UDim2.new(.5,0,0,10) end)
launch.SET.MouseButton1Click:Connect(function() show(setPanel) end)

-- Notice toast.
local toast=Instance.new("TextLabel");toast.AnchorPoint=Vector2.new(.5,0);toast.Position=UDim2.new(.5,0,0,92);toast.Size=UDim2.new(.52,0,0,48);toast.BackgroundColor3=C.bg;toast.BackgroundTransparency=.08;toast.TextColor3=C.white;toast.Font=Enum.Font.GothamBold;toast.TextSize=15;toast.Visible=false;toast.Parent=gui;corner(toast,14);stroke(toast,C.pink,1,.35)
Notice.OnClientEvent:Connect(function(m) toast.Text=tostring(m);toast.Visible=true;task.delay(2.2,function() if toast.Text==tostring(m) then toast.Visible=false end end) end)

-- Responsive recalculation.
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function() if active and active.Visible then clampPanel(active) end end)
player:SetAttribute("BBYAV6UI","UNIFIED_SAFE_FLOATING")
