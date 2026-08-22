-- BBYA SOCIAL HUB — FREE CAMERA v1
-- Public cinematic freecam. Mobile: on-screen controls + swipe look. Desktop: WASD/QE + RMB look.
local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local ContextActionService=game:GetService("ContextActionService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera
local enabled=false
local yaw,pitch=0,0
local pos=Vector3.zero
local velocity=Vector3.zero
local move={f=0,b=0,l=0,r=0,u=0,d=0}
local lastTouch
local saved={}

local gui=Instance.new("ScreenGui")
gui.Name="BBYAFreecamUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=70;gui.Parent=pg
local toggle=Instance.new("TextButton")
toggle.Name="FreecamToggle";toggle.AnchorPoint=Vector2.new(1,0);toggle.Position=UDim2.new(1,-18,0,78);toggle.Size=UDim2.fromOffset(92,34);toggle.BackgroundColor3=Color3.fromRGB(18,20,27);toggle.BorderSizePixel=0;toggle.Text="FREECAM";toggle.TextColor3=Color3.fromRGB(241,241,245);toggle.Font=Enum.Font.GothamBold;toggle.TextSize=10;toggle.Parent=gui
local tc=Instance.new("UICorner");tc.CornerRadius=UDim.new(0,10);tc.Parent=toggle
local ts=Instance.new("UIStroke");ts.Color=Color3.fromRGB(120,75,255);ts.Transparency=.38;ts.Parent=toggle

local controls=Instance.new("Frame")
controls.Name="MobileControls";controls.AnchorPoint=Vector2.new(1,1);controls.Position=UDim2.new(1,-18,1,-88);controls.Size=UDim2.fromOffset(190,132);controls.BackgroundColor3=Color3.fromRGB(9,10,15);controls.BackgroundTransparency=.22;controls.BorderSizePixel=0;controls.Visible=false;controls.Parent=gui
local cc=Instance.new("UICorner");cc.CornerRadius=UDim.new(0,14);cc.Parent=controls
local cs=Instance.new("UIStroke");cs.Color=Color3.fromRGB(45,179,220);cs.Transparency=.55;cs.Parent=controls

local function button(name,text,x,y,w,h)
 local b=Instance.new("TextButton");b.Name=name;b.Text=text;b.Position=UDim2.fromOffset(x,y);b.Size=UDim2.fromOffset(w,h);b.BackgroundColor3=Color3.fromRGB(29,31,40);b.BorderSizePixel=0;b.TextColor3=Color3.fromRGB(242,242,246);b.Font=Enum.Font.GothamBold;b.TextSize=14;b.Parent=controls
 local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,9);c.Parent=b
 return b
end
local up=button("Up","↑",56,8,42,34);local down=button("Down","↓",56,86,42,34);local left=button("Left","←",8,47,42,34);local right=button("Right","→",104,47,42,34)
local rise=button("Rise","+",151,8,32,49);local fall=button("Fall","−",151,70,32,49)
local hint=Instance.new("TextLabel");hint.BackgroundTransparency=1;hint.Position=UDim2.fromOffset(48,47);hint.Size=UDim2.fromOffset(56,34);hint.Text="DRAG\nLOOK";hint.TextColor3=Color3.fromRGB(154,158,170);hint.Font=Enum.Font.GothamBold;hint.TextSize=8;hint.Parent=controls

local held={}
local function bindHold(btn,key)
 btn.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then held[key]=true end end)
 btn.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then held[key]=false end end)
end
bindHold(up,"f");bindHold(down,"b");bindHold(left,"l");bindHold(right,"r");bindHold(rise,"u");bindHold(fall,"d")

local function anglesFromCF(cf)
 local x,y,_=cf:ToOrientation()
 return y,x
end
local function subjectHumanoid()
 local ch=player.Character
 return ch and ch:FindFirstChildOfClass("Humanoid")
end
local function setEnabled(value)
 value=value==true
 if enabled==value then return end
 enabled=value;camera=workspace.CurrentCamera or camera
 if enabled then
  saved.type=camera.CameraType;saved.subject=camera.CameraSubject;saved.cf=camera.CFrame;saved.fov=camera.FieldOfView
  pos=camera.CFrame.Position;yaw,pitch=anglesFromCF(camera.CFrame);velocity=Vector3.zero
  camera.CameraType=Enum.CameraType.Scriptable
  toggle.Text="EXIT CAM";toggle.BackgroundColor3=Color3.fromRGB(55,28,72);controls.Visible=UserInputService.TouchEnabled
 else
  controls.Visible=false;toggle.Text="FREECAM";toggle.BackgroundColor3=Color3.fromRGB(18,20,27)
  camera.CameraType=saved.type or Enum.CameraType.Custom
  camera.CameraSubject=saved.subject or subjectHumanoid()
  camera.FieldOfView=saved.fov or 70
  for k in pairs(held) do held[k]=false end
 end
end

toggle.MouseButton1Click:Connect(function()setEnabled(not enabled)end)

local keyMap={
 [Enum.KeyCode.W]="f",[Enum.KeyCode.S]="b",[Enum.KeyCode.A]="l",[Enum.KeyCode.D]="r",[Enum.KeyCode.E]="u",[Enum.KeyCode.Q]="d"
}
UserInputService.InputBegan:Connect(function(input,gp)
 if gp then return end
 if input.KeyCode==Enum.KeyCode.P and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then setEnabled(not enabled);return end
 local k=keyMap[input.KeyCode];if enabled and k then held[k]=true end
end)
UserInputService.InputEnded:Connect(function(input)
 local k=keyMap[input.KeyCode];if k then held[k]=false end
end)
UserInputService.InputChanged:Connect(function(input,gp)
 if not enabled then return end
 if input.UserInputType==Enum.UserInputType.MouseMovement and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
  yaw-=input.Delta.X*.0034;pitch=math.clamp(pitch-input.Delta.Y*.0034,-1.42,1.42)
 elseif input.UserInputType==Enum.UserInputType.Touch and not gp then
  local p=input.Position
  if lastTouch then local d=p-lastTouch;yaw-=d.X*.0036;pitch=math.clamp(pitch-d.Y*.0036,-1.42,1.42) end
  lastTouch=p
 end
end)
UserInputService.TouchEnded:Connect(function()lastTouch=nil end)

RunService:BindToRenderStep("BBYAFreecam",Enum.RenderPriority.Camera.Value+2,function(dt)
 if not enabled then return end
 camera=workspace.CurrentCamera or camera
 if camera.CameraType~=Enum.CameraType.Scriptable then camera.CameraType=Enum.CameraType.Scriptable end
 local cf=CFrame.fromOrientation(pitch,yaw,0)
 local dir=Vector3.new((held.r and 1 or 0)-(held.l and 1 or 0),(held.u and 1 or 0)-(held.d and 1 or 0),(held.b and 1 or 0)-(held.f and 1 or 0))
 local speed=UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 58 or 30
 local target=Vector3.zero
 if dir.Magnitude>0 then target=(cf:VectorToWorldSpace(dir.Unit))*speed end
 velocity=velocity:Lerp(target,math.clamp(dt*7,0,1));pos+=velocity*dt
 camera.CFrame=CFrame.new(pos)*cf
end)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera or camera;if enabled and camera then camera.CameraType=Enum.CameraType.Scriptable end end)
print("[BBYA] Freecam v1 online: mobile controls + desktop WASD/QE")
