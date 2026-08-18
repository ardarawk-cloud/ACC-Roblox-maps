-- BBYA V6 — UNIFIED MOBILE-SAFE UI
-- One ScreenGui. Windows never disappear on drag. Edge parking leaves a recoverable strip.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
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

local C={bg=Color3.fromRGB(8,8,13),panel=Color3.fromRGB(18,15,25),panel2=Color3.fromRGB(29,24,39),pink=Color3.fromRGB(255,48,184),cyan=Color3.fromRGB(31,221,255),gold=Color3.fromRGB(255,196,75),white=Color3.fromRGB(245,242,247),muted=Color3.fromRGB(165,158,174),green=Color3.fromRGB(91,225,148)}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 12);c.Parent=o end
local function stroke(o,color,thick,trans)local s=Instance.new("UIStroke");s.Color=color or C.pink;s.Thickness=thick or 1;s.Transparency=trans or .2;s.Parent=o end
local function text(parent,value,size,pos,font,color)
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Text=value;t.TextSize=size or 15;t.Font=font or Enum.Font.Gotham;t.TextColor3=color or C.white;t.TextXAlignment=Enum.TextXAlignment.Left;t.Position=pos or UDim2.fromOffset(0,0);t.Size=UDim2.fromOffset(220,28);t.Parent=parent;return t
end
local function button(parent,value,size,pos,color)
 local b=Instance.new("TextButton");b.Text=value;b.TextSize=14;b.Font=Enum.Font.GothamBold;b.TextColor3=C.white;b.BackgroundColor3=color or C.panel2;b.Size=size;b.Position=pos;b.Parent=parent;corner(b,10);return b
end

local function viewport()return workspace.CurrentCamera.ViewportSize end
local function toast(msg)
 local t=gui:FindFirstChild("TOAST")
 if not t then t=Instance.new("TextLabel");t.Name="TOAST";t.AnchorPoint=Vector2.new(.5,0);t.Position=UDim2.new(.5,0,0,86);t.Size=UDim2.new(.5,0,0,44);t.BackgroundColor3=C.bg;t.BackgroundTransparency=.06;t.TextColor3=C.white;t.Font=Enum.Font.GothamBold;t.TextSize=14;t.Parent=gui;corner(t,12);stroke(t,C.pink,1,.35) end
 t.Text=tostring(msg);t.Visible=true;local stamp=os.clock();t:SetAttribute("Stamp",stamp);task.delay(2.2,function()if t:GetAttribute("Stamp")==stamp then t.Visible=false end end)
end
Notice.OnClientEvent:Connect(toast)

-- Compact top status, not a giant banner.
local status=Instance.new("Frame");status.AnchorPoint=Vector2.new(.5,0);status.Position=UDim2.new(.5,0,0,8);status.Size=UDim2.new(.56,0,0,66);status.BackgroundColor3=C.bg;status.BackgroundTransparency=.06;status.Parent=gui;corner(status,16);stroke(status,C.pink,1,.15)
local brand=text(status,"BBYA",23,UDim2.fromOffset(20,8),Enum.Font.GothamBlack,C.pink);brand.Size=UDim2.fromOffset(100,26)
local who=text(status,player.DisplayName,13,UDim2.fromOffset(20,38),Enum.Font.GothamBold,C.white);who.Size=UDim2.fromOffset(150,20)
local zone=text(status,"SOCIAL HUB",17,UDim2.new(.28,0,0,11),Enum.Font.GothamBold,C.cyan);zone.Size=UDim2.new(.5,0,0,24)
local build=text(status,"V6 CLEANROOM",11,UDim2.new(.28,0,0,39),Enum.Font.Gotham,C.muted);build.Size=UDim2.new(.4,0,0,18)
local topToggle=button(status,"⌃",UDim2.fromOffset(48,34),UDim2.new(1,-58,0,16),C.panel2)
local topPark=false
topToggle.MouseButton1Click:Connect(function()topPark=not topPark;if topPark then status.Position=UDim2.new(.5,0,0,-48);topToggle.Text="⌄" else status.Position=UDim2.new(.5,0,0,8);topToggle.Text="⌃" end end)

-- Small launcher rails. Bottom control zones remain clear.
local function rail(xScale,xOffset,strokeColor)
 local f=Instance.new("Frame");f.AnchorPoint=Vector2.new(xScale==1 and 1 or 0,0);f.Position=UDim2.new(xScale,xOffset,.24,0);f.Size=UDim2.fromOffset(78,270);f.BackgroundColor3=C.bg;f.BackgroundTransparency=.06;f.Parent=gui;corner(f,16);stroke(f,strokeColor,1,.18);return f
end
local left=rail(0,10,C.pink);local right=rail(1,-10,C.cyan)
local launch={}
local function fillRail(parent,items)
 for i,it in ipairs(items) do local b=button(parent,it[1],UDim2.fromOffset(60,52),UDim2.fromOffset(9,9+(i-1)*64),C.panel2);b.TextColor3=it[2];launch[it[1]]=b end
end
fillRail(left,{{"SOCIAL",C.pink},{"VIP",C.gold},{"PHOTO",C.cyan},{"TP",C.green}})
fillRail(right,{{"MUSIC",C.pink},{"SAWER",C.pink},{"PROFILE",C.cyan},{"SET",C.gold}})

local panelLayer=Instance.new("Frame");panelLayer.Size=UDim2.fromScale(1,1);panelLayer.BackgroundTransparency=1;panelLayer.Parent=gui
local active=nil
local function desiredSize()local v=viewport();return Vector2.new(math.min(760,math.max(340,v.X*.72)),math.min(520,math.max(320,v.Y*.66))) end
local function centerPanel(p)local v=viewport();local s=desiredSize();p.Size=UDim2.fromOffset(s.X,s.Y);p.Position=UDim2.fromOffset((v.X-s.X)/2,math.max(84,(v.Y-s.Y)/2));p:SetAttribute("Parked","") end
local function constrain(p)
 local v=viewport();local s=p.AbsoluteSize;local a=p.AbsolutePosition;local visible=44;local bottomSafe=92
 local x=math.clamp(a.X,-s.X+visible,v.X-visible);local y=math.clamp(a.Y,36-s.Y+visible,v.Y-bottomSafe-visible);p.Position=UDim2.fromOffset(x,y)
end
local function positionPull(p,pull,side)
 if side=="LEFT" then pull.AnchorPoint=Vector2.new(1,.5);pull.Position=UDim2.new(1,-4,.5,0);pull.Text="›"
 elseif side=="RIGHT" then pull.AnchorPoint=Vector2.new(0,.5);pull.Position=UDim2.new(0,4,.5,0);pull.Text="‹"
 elseif side=="TOP" then pull.AnchorPoint=Vector2.new(.5,1);pull.Position=UDim2.new(.5,0,1,-4);pull.Text="⌄"
 else pull.AnchorPoint=Vector2.new(0,0);pull.Position=UDim2.fromOffset(6,6);pull.Text="PULL" end
end
local function park(p,side)
 local v=viewport();local s=p.AbsoluteSize;local visible=38
 if side=="LEFT" then p.Position=UDim2.fromOffset(-s.X+visible,math.clamp(p.AbsolutePosition.Y,50,v.Y-120))
 elseif side=="RIGHT" then p.Position=UDim2.fromOffset(v.X-visible,math.clamp(p.AbsolutePosition.Y,50,v.Y-120))
 elseif side=="TOP" then p.Position=UDim2.fromOffset(math.clamp(p.AbsolutePosition.X,8,v.X-s.X-8),-s.Y+visible) end
 p:SetAttribute("Parked",side)
 local pull=p:FindFirstChild("PULL");if pull then positionPull(p,pull,side);pull.Visible=true end
end
local function makePanel(name,titleValue)
 local p=Instance.new("Frame");p.Name=name;p.BackgroundColor3=C.panel;p.BackgroundTransparency=.02;p.Visible=false;p.Parent=panelLayer;corner(p,18);stroke(p,C.pink,1.2,.12);centerPanel(p)
 local head=Instance.new("Frame");head.Name="HEADER";head.Size=UDim2.new(1,0,0,56);head.BackgroundColor3=C.bg;head.BackgroundTransparency=.03;head.Parent=p;corner(head,18)
 local title=text(head,titleValue,21,UDim2.fromOffset(20,14),Enum.Font.GothamBlack,C.white);title.Size=UDim2.new(1,-156,0,28)
 local move=button(head,"MOVE",UDim2.fromOffset(72,32),UDim2.new(1,-124,0,12),C.panel2);move.TextColor3=C.pink
 local close=button(head,"×",UDim2.fromOffset(38,32),UDim2.new(1,-46,0,12),C.panel2)
 local pull=button(p,"PULL",UDim2.fromOffset(56,28),UDim2.fromOffset(6,6),C.panel2);pull.Name="PULL";pull.ZIndex=20;pull.Visible=false
 local body=Instance.new("ScrollingFrame");body.Name="BODY";body.Position=UDim2.fromOffset(14,64);body.Size=UDim2.new(1,-28,1,-78);body.BackgroundTransparency=1;body.BorderSizePixel=0;body.ScrollBarThickness=3;body.ScrollBarImageColor3=C.pink;body.ScrollingDirection=Enum.ScrollingDirection.Y;body.AutomaticCanvasSize=Enum.AutomaticSize.Y;body.CanvasSize=UDim2.new(0,0,0,0);body.Parent=p
 close.MouseButton1Click:Connect(function()p.Visible=false;if active==p then active=nil end end)
 pull.MouseButton1Click:Connect(function()centerPanel(p);positionPull(p,pull,nil);pull.Visible=false end)
 local dragging=false;local startInput;local startPos
 move.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true;startInput=i.Position;startPos=p.Position;pull.Visible=false end end)
 UIS.InputChanged:Connect(function(i)if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-startInput;p.Position=UDim2.fromOffset(startPos.X.Offset+d.X,startPos.Y.Offset+d.Y);constrain(p) end end)
 UIS.InputEnded:Connect(function(i)if dragging and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then dragging=false;local v=viewport();local a=p.AbsolutePosition;local s=p.AbsoluteSize;local side=nil;if a.X<-s.X*.52 then side="LEFT" elseif a.X+s.X>v.X+s.X*.52 then side="RIGHT" elseif a.Y<-s.Y*.52 then side="TOP" end;if side then park(p,side) else constrain(p) end end end)
 return p,body
end
local function show(p)if active and active~=p then active.Visible=false end;active=p;p.Visible=true;if p:GetAttribute("Parked")~="" then centerPanel(p);local pull=p:FindFirstChild("PULL");if pull then positionPull(p,pull,nil);pull.Visible=false end end end

-- MUSIC
local musicPanel,musicBody=makePanel("MUSIC_PANEL","MUSIC CONTROLLER")
local auto=text(musicBody,"HYBRID AUTO-DJ",15,UDim2.fromOffset(6,4),Enum.Font.GothamBold,C.pink);auto.Size=UDim2.new(1,-12,0,24)
local now=text(musicBody,"BBYA 24/7",22,UDim2.fromOffset(6,38),Enum.Font.GothamBlack,C.white);now.Size=UDim2.new(1,-12,0,32)
local meta=text(musicBody,"AUTO-DJ",12,UDim2.fromOffset(6,72),Enum.Font.Gotham,C.muted);meta.Size=UDim2.new(1,-12,0,22)
local controls=Instance.new("Frame");controls.Position=UDim2.fromOffset(0,106);controls.Size=UDim2.new(1,0,0,54);controls.BackgroundTransparency=1;controls.Parent=musicBody
local play=button(controls,"PLAY",UDim2.new(.24,-5,1,0),UDim2.new(0,0,0,0),C.panel2);local pause=button(controls,"PAUSE",UDim2.new(.24,-5,1,0),UDim2.new(.25,0,0,0),C.panel2);local nextB=button(controls,"NEXT",UDim2.new(.24,-5,1,0),UDim2.new(.5,0,0,0),C.panel2);nextB.TextColor3=C.cyan;local volB=button(controls,"VOL 58%",UDim2.new(.24,-5,1,0),UDim2.new(.75,0,0,0),C.panel2);volB.TextColor3=C.gold
play.MouseButton1Click:Connect(function()Music:FireServer("PLAY")end);pause.MouseButton1Click:Connect(function()Music:FireServer("PAUSE")end);nextB.MouseButton1Click:Connect(function()Music:FireServer("NEXT")end)
local volume=.58;volB.MouseButton1Click:Connect(function()volume=volume>=.95 and .35 or math.min(1,volume+.1);volB.Text=string.format("VOL %d%%",math.floor(volume*100));Music:FireServer("VOLUME",volume)end)
local modes=Instance.new("Frame");modes.Position=UDim2.fromOffset(0,174);modes.Size=UDim2.new(1,0,0,46);modes.BackgroundTransparency=1;modes.Parent=musicBody
for i,m in ipairs({"ALL","INDO","INTL"})do local b=button(modes,m,UDim2.new(1/3,-6,1,0),UDim2.new((i-1)/3,2,0,0),C.panel2);b.MouseButton1Click:Connect(function()Music:FireServer("MODE",m)end)end
local qTitle=text(musicBody,"PLAYLIST / UP NEXT",14,UDim2.fromOffset(6,236),Enum.Font.GothamBold,C.white);qTitle.Size=UDim2.new(1,-12,0,22)
local q=Instance.new("Frame");q.Position=UDim2.fromOffset(0,266);q.Size=UDim2.new(1,0,0,170);q.BackgroundColor3=C.bg;q.BackgroundTransparency=.25;q.Parent=musicBody;corner(q,12)
for i,n in ipairs({"Indo Bounce / Breakbeat","House / EDM","Tropical House","Techno / DnB"})do local t=text(q,string.format("%02d   %s",i,n),13,UDim2.fromOffset(14,10+(i-1)*38),Enum.Font.Gotham,C.white);t.Size=UDim2.new(1,-24,0,28)end
MusicState.OnClientEvent:Connect(function(s)now.Text=s.title or "BBYA 24/7";meta.Text=string.format("%s • %s",s.sub or "AUTO-DJ",s.mode or "ALL");volume=s.volume or volume;volB.Text=string.format("VOL %d%%",math.floor(volume*100))end)
launch.MUSIC.MouseButton1Click:Connect(function()show(musicPanel);Music:FireServer("STATE")end)

-- SAWER: real layout, safely disabled until IDs exist.
local sawerPanel,sawerBody=makePanel("SAWER_PANEL","SAWER / SUPPORT")
local copy=text(sawerBody,"Dukung creator & BBYA Social Hub.",14,UDim2.fromOffset(6,4),Enum.Font.Gotham,C.muted);copy.Size=UDim2.new(1,-12,0,26)
local denoms={5,10,25,50,100,250,500}
for i,v in ipairs(denoms)do local col=(i-1)%3;local row=math.floor((i-1)/3);local b=button(sawerBody,"R$"..v.."\nPENDING",UDim2.new(1/3,-8,0,66),UDim2.new(col/3,3,0,44+row*76),C.panel2);b.TextColor3=C.muted;b.MouseButton1Click:Connect(function()toast("Developer Product belum dipasang")end)end
local pending=text(sawerBody,"Tidak ada transaksi palsu. Tombol aktif hanya setelah Product ID resmi dipasang.",13,UDim2.fromOffset(6,286),Enum.Font.Gotham,C.gold);pending.Size=UDim2.new(1,-12,0,48);pending.TextWrapped=true
local top=text(sawerBody,"TOP SUPPORTERS",14,UDim2.fromOffset(6,348),Enum.Font.GothamBold,C.white);top.Size=UDim2.new(1,-12,0,24)
local topCopy=text(sawerBody,"Leaderboard akan memakai receipt server resmi.",13,UDim2.fromOffset(6,378),Enum.Font.Gotham,C.muted);topCopy.Size=UDim2.new(1,-12,0,40);topCopy.TextWrapped=true
launch.SAWER.MouseButton1Click:Connect(function()show(sawerPanel)end)

-- PROFILE
local profilePanel,profileBody=makePanel("PROFILE_PANEL","PROFILE")
local avatar=Instance.new("ImageLabel");avatar.Size=UDim2.fromOffset(90,90);avatar.Position=UDim2.fromOffset(8,10);avatar.BackgroundColor3=C.panel2;avatar.Parent=profileBody;corner(avatar,45)
local ok,img=pcall(function()return Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size180x180)end);if ok then avatar.Image=img end
local pname=text(profileBody,player.DisplayName,23,UDim2.fromOffset(116,16),Enum.Font.GothamBlack,C.white);pname.Size=UDim2.new(1,-126,0,32)
local role=text(profileBody,player:GetAttribute("BBYAQueen") and "BBYA QUEEN" or "SOCIALITE",14,UDim2.fromOffset(116,54),Enum.Font.GothamBold,C.pink);role.Size=UDim2.new(1,-126,0,24)
local pcopy=text(profileBody,"Hangout • outfit • photo • rooftop • bar • club",14,UDim2.fromOffset(8,124),Enum.Font.Gotham,C.muted);pcopy.Size=UDim2.new(1,-16,0,40);pcopy.TextWrapped=true
launch.PROFILE.MouseButton1Click:Connect(function()show(profilePanel)end)

-- SOCIAL HUB choices are parallel; club is only one option.
local socialPanel,socialBody=makePanel("SOCIAL_PANEL","SOCIAL HUB")
local options={{"COMMONS","A3",C.pink},{"SOCIAL BAR","A5",C.gold},{"CHILL / TALK","A6",C.cyan},{"CLUB / DANCE","A4",C.pink},{"VIP","C1",C.gold},{"ROOFTOP","D1",C.green}}
for i,o in ipairs(options)do local c=(i-1)%2;local r=math.floor((i-1)/2);local b=button(socialBody,o[1],UDim2.new(.5,-8,0,64),UDim2.new(c*.5,3,0,10+r*74),C.panel2);b.TextColor3=o[3];b.MouseButton1Click:Connect(function()Teleport:FireServer(o[2])end)end
launch.SOCIAL.MouseButton1Click:Connect(function()show(socialPanel)end);launch.VIP.MouseButton1Click:Connect(function()Teleport:FireServer("C1")end)

-- TP / LIFT
local tpPanel,tpBody=makePanel("TP_PANEL","ZONE / INSPECTION")
local codes={"A1","A2","A3","A4","A5","A6","B1","B2","B3","C1","C2","C3","D1","D2","D3","D4","D5","D6"}
for i,c in ipairs(codes)do local col=(i-1)%6;local row=math.floor((i-1)/6);local b=button(tpBody,c,UDim2.new(1/6,-5,0,48),UDim2.new(col/6,2,0,8+row*58),C.panel2);b.MouseButton1Click:Connect(function()Teleport:FireServer(c)end)end
local liftLabel=text(tpBody,"LIFT (masuk cab dulu)",14,UDim2.fromOffset(4,190),Enum.Font.GothamBold,C.white);liftLabel.Size=UDim2.fromOffset(190,22)
for i,c in ipairs({"G","VIP","ROOF"})do local b=button(tpBody,c,UDim2.new(1/3,-6,0,48),UDim2.new((i-1)/3,2,0,220),C.panel2);b.MouseButton1Click:Connect(function()Lift:FireServer(c)end)end
launch.TP.MouseButton1Click:Connect(function()show(tpPanel)end)

-- PHOTO / CAMERA with guaranteed recovery from CLEAN VIEW.
local photoPanel,photoBody=makePanel("PHOTO_PANEL","PHOTO / CAMERA")
local cam=workspace.CurrentCamera
local freeConn=nil
local moveState={F=false,B=false,L=false,R=false,U=false,D=false}
local freeCF=nil
local freeYaw=0
local freePitch=0
local mouseLook=false
local touchLook=nil
local touchLast=nil
local function resetCam()if freeConn then freeConn:Disconnect();freeConn=nil end;mouseLook=false;touchLook=nil;cam.CameraType=Enum.CameraType.Custom;cam.CameraSubject=player.Character and player.Character:FindFirstChildOfClass("Humanoid") or nil end
local function outfit(yaw)local char=player.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart");if not hrp then return end;resetCam();cam.CameraType=Enum.CameraType.Scriptable;local base=CFrame.new(hrp.Position)*CFrame.Angles(0,math.rad(yaw or 0),0);local pos=(base*CFrame.new(0,1.8,8)).Position;cam.CFrame=CFrame.new(pos,hrp.Position+Vector3.new(0,1.8,0))end
local function applyLook(dx,dy)
 if not freeConn or not freeCF then return end
 freeYaw-=dx*.004;freePitch=math.clamp(freePitch-dy*.004,-1.35,1.35)
 freeCF=CFrame.new(freeCF.Position)*CFrame.Angles(freePitch,freeYaw,0)
 cam.CFrame=freeCF
end
local function freecam()
 resetCam();cam.CameraType=Enum.CameraType.Scriptable;freeCF=cam.CFrame
 local rx,ry=freeCF:ToOrientation();freePitch=rx;freeYaw=ry
 freeConn=RunService.RenderStepped:Connect(function(dt)
  local d=Vector3.zero;if moveState.F then d+=Vector3.new(0,0,-1)end;if moveState.B then d+=Vector3.new(0,0,1)end;if moveState.L then d+=Vector3.new(-1,0,0)end;if moveState.R then d+=Vector3.new(1,0,0)end;if moveState.U then d+=Vector3.new(0,1,0)end;if moveState.D then d+=Vector3.new(0,-1,0)end
  if d.Magnitude>0 then freeCF=freeCF*CFrame.new(d.Unit*18*dt);cam.CFrame=freeCF end
 end)
end
UIS.InputBegan:Connect(function(i,processed)if freeConn and not processed and i.UserInputType==Enum.UserInputType.MouseButton2 then mouseLook=true end end)
UIS.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton2 then mouseLook=false end end)
UIS.InputChanged:Connect(function(i)if freeConn and mouseLook and i.UserInputType==Enum.UserInputType.MouseMovement then applyLook(i.Delta.X,i.Delta.Y) end end)
UIS.TouchStarted:Connect(function(i,processed)if freeConn and not processed and not touchLook then touchLook=i;touchLast=i.Position end end)
UIS.TouchMoved:Connect(function(i)if freeConn and i==touchLook and touchLast then local d=i.Position-touchLast;touchLast=i.Position;applyLook(d.X,d.Y) end end)
UIS.TouchEnded:Connect(function(i)if i==touchLook then touchLook=nil;touchLast=nil end end)
local camDefs={{"FRONT",function()outfit(0)end},{"LEFT 3/4",function()outfit(-28)end},{"RIGHT 3/4",function()outfit(28)end},{"FREECAM",freecam},{"RESET",resetCam}}
for i,d in ipairs(camDefs)do local c=(i-1)%2;local r=math.floor((i-1)/2);local b=button(photoBody,d[1],UDim2.new(.5,-8,0,54),UDim2.new(c*.5,3,0,8+r*64),C.panel2);b.MouseButton1Click:Connect(d[2])end
local clean=button(photoBody,"CLEAN VIEW",UDim2.new(1,-6,0,54),UDim2.new(0,3,0,202),C.panel2);clean.TextColor3=C.pink
local cleanRestore=button(gui,"RETURN UI",UDim2.fromOffset(92,38),UDim2.new(1,-106,0,14),C.bg);cleanRestore.TextColor3=C.pink;cleanRestore.Visible=false;cleanRestore.ZIndex=50;stroke(cleanRestore,C.pink,1,.15)
local cleanMode=false
local function setClean(on)cleanMode=on;status.Visible=not on;left.Visible=not on;right.Visible=not on;panelLayer.Visible=not on;cleanRestore.Visible=on end
clean.MouseButton1Click:Connect(function()setClean(true)end);cleanRestore.MouseButton1Click:Connect(function()setClean(false);show(photoPanel)end)
local mover=Instance.new("Frame");mover.Position=UDim2.new(0,3,1,-116);mover.Size=UDim2.new(1,-6,0,110);mover.BackgroundTransparency=1;mover.Parent=photoBody
local defs={{"F",.34,0},{"L",.17,.52},{"B",.34,.52},{"R",.51,.52},{"U",.68,0},{"D",.68,.52}}
for _,d in ipairs(defs)do local b=button(mover,d[1],UDim2.new(.14,0,.42,0),UDim2.new(d[2],0,d[3],0),C.panel2);b.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then moveState[d[1]]=true end end);b.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then moveState[d[1]]=false end end)end
launch.PHOTO.MouseButton1Click:Connect(function()show(photoPanel)end)

-- SETTINGS
local setPanel,setBody=makePanel("SET_PANEL","SETTINGS")
local resetUI=button(setBody,"RESET UI POSITIONS",UDim2.new(1,-6,0,56),UDim2.new(0,3,0,8),C.panel2)
resetUI.MouseButton1Click:Connect(function()for _,p in ipairs({musicPanel,sawerPanel,profilePanel,socialPanel,tpPanel,photoPanel,setPanel})do centerPanel(p);local pull=p:FindFirstChild("PULL");if pull then positionPull(p,pull,nil);pull.Visible=false end end;status.Position=UDim2.new(.5,0,0,8);left.Position=UDim2.new(0,10,.24,0);right.Position=UDim2.new(1,-10,.24,0);setClean(false)end)
launch.SET.MouseButton1Click:Connect(function()show(setPanel)end)

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()if active and active.Visible then constrain(active)end end)
player:SetAttribute("BBYAV6UI","UNIFIED_SAFE_FLOATING")