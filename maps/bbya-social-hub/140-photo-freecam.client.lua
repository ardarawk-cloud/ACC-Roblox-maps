-- BBYA SOCIAL HUB — PHOTO MODE / FREE CAMERA v1
-- Non-destructive camera-only freecam for photo/video capture.
-- Never moves Humanoid, never stops animations/emotes/dance/carry, never changes tools or character state.

local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local old=pg:FindFirstChild("BBYAPhotoModeUI")
if old then old:Destroy() end

local gui=Instance.new("ScreenGui")
gui.Name="BBYAPhotoModeUI"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=82
gui.Parent=pg

local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,col,tr)local s=Instance.new("UIStroke");s.Color=col;s.Transparency=tr or .45;s.Thickness=1;s.Parent=o end
local function button(parent,name,text,pos,size)
 local b=Instance.new("TextButton")
 b.Name=name;b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=Color3.fromRGB(20,20,27);b.BackgroundTransparency=.12;b.BorderSizePixel=0
 b.TextColor3=Color3.fromRGB(245,245,248);b.Font=Enum.Font.GothamBold;b.TextSize=10;b.AutoButtonColor=true;b.Parent=parent;corner(b,10);stroke(b,Color3.fromRGB(113,116,130),.45);return b
end

local toggle=button(gui,"PhotoModeToggle","PHOTO",UDim2.new(1,-86,0,54),UDim2.fromOffset(72,36))
toggle.AnchorPoint=Vector2.new(0,0)

local controls=Instance.new("Frame")
controls.Name="PhotoControls"
controls.AnchorPoint=Vector2.new(1,1)
controls.Position=UDim2.new(1,-14,1,-86)
controls.Size=UDim2.fromOffset(190,152)
controls.BackgroundTransparency=1
controls.Visible=false
controls.Parent=gui

local forward=button(controls,"Forward","▲",UDim2.fromOffset(62,0),UDim2.fromOffset(54,44));forward.TextSize=16
local left=button(controls,"Left","◀",UDim2.fromOffset(4,48),UDim2.fromOffset(54,44));left.TextSize=16
local back=button(controls,"Back","▼",UDim2.fromOffset(62,48),UDim2.fromOffset(54,44));back.TextSize=16
local right=button(controls,"Right","▶",UDim2.fromOffset(120,48),UDim2.fromOffset(54,44));right.TextSize=16
local up=button(controls,"Up","UP",UDim2.fromOffset(4,96),UDim2.fromOffset(82,42))
local down=button(controls,"Down","DOWN",UDim2.fromOffset(92,96),UDim2.fromOffset(82,42))

local active=false
local camera=workspace.CurrentCamera
local saved={}
local yaw=0
local pitch=0
local speed=22
local key={W=false,A=false,S=false,D=false,Q=false,E=false,Fast=false}
local touchMove={F=false,B=false,L=false,R=false,U=false,D=false}
local rotating=false
local rotateTouch=nil
local lastPointer=nil

local function cameraAngles(cf)
 local look=cf.LookVector
 local y=math.asin(math.clamp(look.Y,-1,1))
 local x=math.atan2(-look.X,-look.Z)
 return x,y
end

local function restore()
 if not active then return end
 active=false
 controls.Visible=false
 toggle.Text="PHOTO"
 UserInputService.MouseBehavior=Enum.MouseBehavior.Default
 camera=workspace.CurrentCamera or camera
 if camera then
  camera.CameraType=saved.type or Enum.CameraType.Custom
  if saved.subject and saved.subject.Parent then camera.CameraSubject=saved.subject end
  camera.FieldOfView=saved.fov or 70
 end
 table.clear(saved)
 rotating=false;rotateTouch=nil;lastPointer=nil
 for k in pairs(key) do key[k]=false end
 for k in pairs(touchMove) do touchMove[k]=false end
end

local function start()
 if active then return end
 camera=workspace.CurrentCamera
 if not camera then return end
 saved={type=camera.CameraType,subject=camera.CameraSubject,fov=camera.FieldOfView}
 yaw,pitch=cameraAngles(camera.CFrame)
 camera.CameraType=Enum.CameraType.Scriptable
 active=true
 controls.Visible=UserInputService.TouchEnabled
 toggle.Text="EXIT PHOTO"
end

toggle.Activated:Connect(function()if active then restore() else start() end end)

local keyMap={
 [Enum.KeyCode.W]="W",[Enum.KeyCode.A]="A",[Enum.KeyCode.S]="S",[Enum.KeyCode.D]="D",
 [Enum.KeyCode.Q]="Q",[Enum.KeyCode.E]="E",
}
UserInputService.InputBegan:Connect(function(input,gp)
 if not active then return end
 local k=keyMap[input.KeyCode];if k then key[k]=true end
 if input.KeyCode==Enum.KeyCode.LeftShift or input.KeyCode==Enum.KeyCode.RightShift then key.Fast=true end
 if input.UserInputType==Enum.UserInputType.MouseButton2 then rotating=true;lastPointer=input.Position;UserInputService.MouseBehavior=Enum.MouseBehavior.LockCurrentPosition end
 if input.KeyCode==Enum.KeyCode.Escape then restore() end
end)
UserInputService.InputEnded:Connect(function(input)
 local k=keyMap[input.KeyCode];if k then key[k]=false end
 if input.KeyCode==Enum.KeyCode.LeftShift or input.KeyCode==Enum.KeyCode.RightShift then key.Fast=false end
 if input.UserInputType==Enum.UserInputType.MouseButton2 then rotating=false;lastPointer=nil;if active then UserInputService.MouseBehavior=Enum.MouseBehavior.Default end end
 if input==rotateTouch then rotateTouch=nil;lastPointer=nil end
end)
UserInputService.InputChanged:Connect(function(input)
 if not active then return end
 if input.UserInputType==Enum.UserInputType.MouseMovement and rotating then
  yaw-=input.Delta.X*.0035;pitch=math.clamp(pitch-input.Delta.Y*.0035,-1.45,1.45)
 elseif input.UserInputType==Enum.UserInputType.MouseWheel then
  speed=math.clamp(speed+input.Position.Z*4,6,80)
 elseif input.UserInputType==Enum.UserInputType.Touch and input==rotateTouch and lastPointer then
  local delta=input.Position-lastPointer;lastPointer=input.Position
  yaw-=delta.X*.0042;pitch=math.clamp(pitch-delta.Y*.0042,-1.45,1.45)
 end
end)

-- Touch drag anywhere outside the movement control cluster rotates camera.
UserInputService.TouchStarted:Connect(function(input,gp)
 if not active or gp then return end
 local p=input.Position
 local vp=camera and camera.ViewportSize or Vector2.new(1000,700)
 if p.X>vp.X-225 and p.Y>vp.Y-265 then return end
 rotateTouch=input;lastPointer=p
end)

local function hold(btn,keyName)
 btn.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then touchMove[keyName]=true end end)
 btn.InputEnded:Connect(function(input)if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then touchMove[keyName]=false end end)
end
hold(forward,"F");hold(back,"B");hold(left,"L");hold(right,"R");hold(up,"U");hold(down,"D")

RunService.RenderStepped:Connect(function(dt)
 if not active then return end
 camera=workspace.CurrentCamera or camera
 if not camera then restore();return end
 camera.CameraType=Enum.CameraType.Scriptable
 local rot=CFrame.fromOrientation(pitch,yaw,0)
 local x=(key.D and 1 or 0)-(key.A and 1 or 0)+(touchMove.R and 1 or 0)-(touchMove.L and 1 or 0)
 local z=(key.S and 1 or 0)-(key.W and 1 or 0)+(touchMove.B and 1 or 0)-(touchMove.F and 1 or 0)
 local y=(key.E and 1 or 0)-(key.Q and 1 or 0)+(touchMove.U and 1 or 0)-(touchMove.D and 1 or 0)
 local move=Vector3.new(x,y,z)
 if move.Magnitude>1 then move=move.Unit end
 local mult=key.Fast and 2.4 or 1
 local world=(rot.RightVector*move.X)+(Vector3.yAxis*move.Y)+(rot.LookVector*(-move.Z))
 local pos=camera.CFrame.Position+world*speed*mult*dt
 camera.CFrame=CFrame.new(pos)*rot
end)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
 camera=workspace.CurrentCamera
 if active and camera then camera.CameraType=Enum.CameraType.Scriptable end
end)
player.CharacterAdded:Connect(function()if active then restore() end end)

print("[BBYA] Photo Mode free camera v1 online: camera-only / desktop+mobile / dance-carry safe")
