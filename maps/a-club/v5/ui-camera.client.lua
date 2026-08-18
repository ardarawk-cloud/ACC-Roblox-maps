-- [SYS-CAM CLIENT] BBYA PHOTO CAMERA / FREECAM
-- Social-club camera tools: clean outfit framing + freecam without touching server character state.
local ContextActionService=game:GetService("ContextActionService")
local camera=workspace.CurrentCamera
local freecam=false
local looking=false
local freePos=Vector3.zero
local yaw,pitch=0,0
local speed=26
local move={F=false,B=false,L=false,R=false,U=false,D=false}
local saved={}
local controls=nil

-- Fit camera controls into the existing PHOTO panel rather than creating another permanent rail.
goPhoto.Position=UDim2.new(0,10,0,128)
local camStatus=text(ph,"CAMERA • NORMAL",UDim2.new(1,-20,0,22),UDim2.fromOffset(10,174),11,MUTED,true);camStatus.ZIndex=26
local freeB=smallButton(ph,"FREECAM",UDim2.new(0,10,0,198),UDim2.new(.36,-8,0,36),CYAN)
local cleanB=smallButton(ph,"CLEAN VIEW",UDim2.new(.36,6,0,198),UDim2.new(.34,-8,0,36),PINK)
local resetB=smallButton(ph,"RESET CAM",UDim2.new(.70,2,0,198),UDim2.new(.30,-12,0,36),GOLD)

local pad=Instance.new("Frame")
pad.Name="BBYA_FreecamPad";pad.AnchorPoint=Vector2.new(.5,1);pad.BackgroundColor3=BG;pad.BackgroundTransparency=.08
pad.Size=UDim2.fromOffset(286,92);pad.Position=UDim2.new(.5,0,1,-118);pad.Visible=false;pad.ZIndex=120;pad.Parent=gui
corner(pad,14);stroke(pad,CYAN,.45,1)
text(pad,"FREECAM",UDim2.fromOffset(68,18),UDim2.fromOffset(10,6),10,CYAN,true).ZIndex=121
text(pad,"drag view",UDim2.fromOffset(76,18),UDim2.fromOffset(76,6),9,MUTED,false).ZIndex=121

local function padButton(label,x,y,w,flag)
 local b=button(pad,label,CYAN);b.Position=UDim2.fromOffset(x,y);b.Size=UDim2.fromOffset(w,28);b.ZIndex=122
 b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then move[flag]=true end end)
 b.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then move[flag]=false end end)
 return b
end
padButton("FWD",10,30,54,"F");padButton("BACK",68,30,54,"B");padButton("LEFT",126,30,48,"L");padButton("RIGHT",178,30,48,"R")
padButton("UP",230,30,46,"U");padButton("DOWN",230,60,46,"D")
local exitPad=button(pad,"EXIT",PINK);exitPad.Position=UDim2.fromOffset(10,60);exitPad.Size=UDim2.fromOffset(72,24);exitPad.ZIndex=122
local slowPad=button(pad,"SPEED 26",GOLD);slowPad.Position=UDim2.fromOffset(88,60);slowPad.Size=UDim2.fromOffset(92,24);slowPad.ZIndex=122
local cleanPad=button(pad,"CLEAN",WHITE);cleanPad.Position=UDim2.fromOffset(186,60);cleanPad.Size=UDim2.fromOffset(40,24);cleanPad.TextSize=8;cleanPad.ZIndex=122

local function getControls()
 if controls then return controls end
 local ok,result=pcall(function()
  local pm=require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
  return pm:GetControls()
 end)
 if ok then controls=result end
 return controls
end

local function resetMove() for k in pairs(move) do move[k]=false end end

local function restoreCamera()
 if not camera then camera=workspace.CurrentCamera end
 if saved.type then camera.CameraType=saved.type else camera.CameraType=Enum.CameraType.Custom end
 if saved.subject and saved.subject.Parent then camera.CameraSubject=saved.subject end
 camera.FieldOfView=saved.fov or 70
 local c=getControls();if c then pcall(function() c:Enable() end) end
 ContextActionService:UnbindAction("BBYA_FREECAM_MOVE")
 UserInputService.MouseBehavior=Enum.MouseBehavior.Default
 looking=false;resetMove();pad.Visible=false;freecam=false
 freeB.Text="FREECAM";camStatus.Text="CAMERA • NORMAL"
 player:SetAttribute("BBYAFreecamActive",false)
end

local function movementAction(_,state,input)
 local map={[Enum.KeyCode.W]="F",[Enum.KeyCode.S]="B",[Enum.KeyCode.A]="L",[Enum.KeyCode.D]="R",[Enum.KeyCode.E]="U",[Enum.KeyCode.Q]="D"}
 local key=map[input.KeyCode];if key then move[key]=state~=Enum.UserInputState.End end
 return Enum.ContextActionResult.Sink
end

local function startFreecam()
 if freecam then restoreCamera();return end
 camera=workspace.CurrentCamera;if not camera then return end
 saved.type=camera.CameraType;saved.subject=camera.CameraSubject;saved.fov=camera.FieldOfView
 freePos=camera.CFrame.Position
 local p,y,_=camera.CFrame:ToOrientation();pitch=math.clamp(p,math.rad(-80),math.rad(80));yaw=y
 camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=68
 local c=getControls();if c then pcall(function() c:Disable() end) end
 ContextActionService:BindActionAtPriority("BBYA_FREECAM_MOVE",movementAction,false,3000,Enum.KeyCode.W,Enum.KeyCode.S,Enum.KeyCode.A,Enum.KeyCode.D,Enum.KeyCode.Q,Enum.KeyCode.E)
 freecam=true;pad.Visible=true;freeB.Text="EXIT FREECAM";camStatus.Text="CAMERA • FREECAM"
 player:SetAttribute("BBYAFreecamActive",true)
 notify("Freecam aktif • drag untuk lihat • FWD/BACK/LEFT/RIGHT/UP/DOWN")
end

freeB.Activated:Connect(startFreecam)
exitPad.Activated:Connect(restoreCamera)
resetB.Activated:Connect(restoreCamera)
slowPad.Activated:Connect(function() speed=(speed==26 and 12) or (speed==12 and 44) or 26;slowPad.Text="SPEED "..speed end)

local function cleanView()
 if collapse then collapse("TOP");collapse("LEFT");collapse("RIGHT") end
 for _,spec in pairs(panelSpecs) do spec.panel.Visible=false end
 activeKey=nil
 notify("Clean view aktif • gunakan tab tepi untuk buka UI lagi")
end
cleanB.Activated:Connect(cleanView);cleanPad.Activated:Connect(cleanView)

UserInputService.InputBegan:Connect(function(input,processed)
 if not freecam or processed then return end
 if input.UserInputType==Enum.UserInputType.MouseButton2 then looking=true;UserInputService.MouseBehavior=Enum.MouseBehavior.LockCurrentPosition end
end)
UserInputService.InputEnded:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.MouseButton2 then looking=false;if freecam then UserInputService.MouseBehavior=Enum.MouseBehavior.Default end end
end)
UserInputService.InputChanged:Connect(function(input,processed)
 if not freecam or processed then return end
 if input.UserInputType==Enum.UserInputType.MouseMovement and looking then
  yaw-=input.Delta.X*.0032;pitch=math.clamp(pitch-input.Delta.Y*.0032,math.rad(-82),math.rad(82))
 elseif input.UserInputType==Enum.UserInputType.Touch then
  yaw-=input.Delta.X*.0038;pitch=math.clamp(pitch-input.Delta.Y*.0038,math.rad(-82),math.rad(82))
 elseif input.UserInputType==Enum.UserInputType.MouseWheel then
  camera.FieldOfView=math.clamp(camera.FieldOfView-input.Position.Z*3,35,85)
 end
end)

RunService:BindToRenderStep("BBYA_FREECAM_RENDER",Enum.RenderPriority.Camera.Value+2,function(dt)
 if not freecam or not camera then return end
 local rot=CFrame.fromOrientation(pitch,yaw,0)
 local dir=Vector3.zero
 if move.F then dir+=rot.LookVector end;if move.B then dir-=rot.LookVector end
 if move.R then dir+=rot.RightVector end;if move.L then dir-=rot.RightVector end
 if move.U then dir+=Vector3.yAxis end;if move.D then dir-=Vector3.yAxis end
 if dir.Magnitude>0 then freePos+=dir.Unit*speed*dt end
 camera.CFrame=CFrame.new(freePos)*rot
end)

player.CharacterAdded:Connect(function() if freecam then task.defer(restoreCamera) end end)
player:SetAttribute("BBYACameraSystem","1.0")
