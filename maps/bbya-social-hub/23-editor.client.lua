local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remote=ReplicatedStorage:WaitForChild("BBYAEditRemote")
local mouse=player:GetMouse()
local selected=nil
local editOn=false

local gui=Instance.new("ScreenGui")
gui.Name="BBYAEditorUI"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=false
gui.DisplayOrder=20
gui.Enabled=false
gui.Parent=player:WaitForChild("PlayerGui")

local function round(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,col,t)local s=Instance.new("UIStroke");s.Color=col;s.Thickness=t or 1;s.Transparency=.25;s.Parent=o end

local openBtn=Instance.new("TextButton")
openBtn.Name="EditorToggle"
openBtn.Size=UDim2.fromOffset(54,40)
openBtn.Position=UDim2.new(0,14,0,82)
openBtn.BackgroundColor3=Color3.fromRGB(22,20,28)
openBtn.TextColor3=Color3.fromRGB(255,80,175)
openBtn.Text="EDIT"
openBtn.TextSize=14
openBtn.Font=Enum.Font.GothamBold
openBtn.BorderSizePixel=0
openBtn.Parent=gui
round(openBtn,10);stroke(openBtn,Color3.fromRGB(255,42,157),1)

local frame=Instance.new("Frame")
frame.Name="EditorPanel"
frame.AnchorPoint=Vector2.new(1,.5)
frame.Position=UDim2.new(1,-12,.5,0)
frame.Size=UDim2.new(0,286,.78,0)
frame.BackgroundColor3=Color3.fromRGB(14,13,18)
frame.BackgroundTransparency=.02
frame.BorderSizePixel=0
frame.Visible=false
frame.ClipsDescendants=true
frame.Parent=gui
round(frame,16);stroke(frame,Color3.fromRGB(255,42,157),1.2)
local limit=Instance.new("UISizeConstraint");limit.MinSize=Vector2.new(260,360);limit.MaxSize=Vector2.new(300,520);limit.Parent=frame

local header=Instance.new("Frame");header.Size=UDim2.new(1,0,0,54);header.BackgroundColor3=Color3.fromRGB(22,19,27);header.BorderSizePixel=0;header.Parent=frame
local title=Instance.new("TextLabel");title.BackgroundTransparency=1;title.Position=UDim2.fromOffset(14,6);title.Size=UDim2.new(1,-70,0,22);title.Text="BBYA EDITOR";title.TextColor3=Color3.fromRGB(245,245,248);title.TextSize=18;title.Font=Enum.Font.GothamBold;title.TextXAlignment=Enum.TextXAlignment.Left;title.Parent=header
local status=Instance.new("TextLabel");status.BackgroundTransparency=1;status.Position=UDim2.fromOffset(14,29);status.Size=UDim2.new(1,-70,0,18);status.Text="OFF";status.TextColor3=Color3.fromRGB(255,91,177);status.TextSize=12;status.Font=Enum.Font.GothamMedium;status.TextXAlignment=Enum.TextXAlignment.Left;status.Parent=header
local close=Instance.new("TextButton");close.Size=UDim2.fromOffset(38,34);close.Position=UDim2.new(1,-46,0,10);close.BackgroundColor3=Color3.fromRGB(35,31,40);close.TextColor3=Color3.fromRGB(240,240,244);close.Text="×";close.TextSize=24;close.Font=Enum.Font.GothamBold;close.BorderSizePixel=0;close.Parent=header;round(close,9)

local body=Instance.new("ScrollingFrame")
body.Position=UDim2.fromOffset(10,64);body.Size=UDim2.new(1,-20,1,-74);body.BackgroundTransparency=1;body.BorderSizePixel=0;body.ScrollBarThickness=3;body.CanvasSize=UDim2.new(0,0,0,390);body.Parent=frame

local function button(text,x,y,w,h,accent)
 local b=Instance.new("TextButton");b.Size=UDim2.fromOffset(w or 120,h or 38);b.Position=UDim2.fromOffset(x,y);b.BackgroundColor3=accent or Color3.fromRGB(34,30,39);b.TextColor3=Color3.fromRGB(244,244,247);b.Text=text;b.TextSize=14;b.Font=Enum.Font.GothamSemibold;b.BorderSizePixel=0;b.Parent=body;round(b,9);return b
end
local toggle=button("EDIT MODE",0,0,256,42,Color3.fromRGB(73,22,54))
local r15=button("ROTATE 15°",0,52,123,38);local r45=button("ROTATE 45°",133,52,123,38)
local forward=button("↑  FORWARD",66,104,124,38)
local left=button("←  LEFT",0,150,123,38);local right=button("RIGHT  →",133,150,123,38)
local back=button("↓  BACK",66,196,124,38)
local up=button("UP +",0,248,123,38);local down=button("DOWN -",133,248,123,38)
local del=button("DELETE",0,300,123,38,Color3.fromRGB(70,26,34));local undo=button("UNDO",133,300,123,38)
local step=Instance.new("TextLabel");step.Position=UDim2.fromOffset(0,346);step.Size=UDim2.fromOffset(256,28);step.BackgroundTransparency=1;step.Text="MOVE STEP  •  1 STUD";step.TextColor3=Color3.fromRGB(150,148,158);step.TextSize=11;step.Font=Enum.Font.GothamMedium;step.Parent=body

local hl=Instance.new("Highlight");hl.FillTransparency=.8;hl.OutlineColor=Color3.fromRGB(255,42,157);hl.Enabled=false;hl.Parent=gui
local function disableEdit()editOn=false;selected=nil;hl.Enabled=false;status.Text="OFF";toggle.Text="EDIT MODE" end
local function setPanel(show)frame.Visible=show;if not show then disableEdit() end end
local function move(v)if selected then remote:FireServer("move",selected,v)end end
local function refreshVisibility()
 local visible=player:GetAttribute("BBYAAdmin")==true and player:GetAttribute("BBYAEditorVisible")==true
 gui.Enabled=visible
 if not visible then setPanel(false) end
end
player:GetAttributeChangedSignal("BBYAAdmin"):Connect(refreshVisibility)
player:GetAttributeChangedSignal("BBYAEditorVisible"):Connect(refreshVisibility)
refreshVisibility()

openBtn.MouseButton1Click:Connect(function()setPanel(not frame.Visible)end)
close.MouseButton1Click:Connect(function()setPanel(false)end)
toggle.MouseButton1Click:Connect(function()
 editOn=not editOn
 if editOn then status.Text="ON • TAP OBJECT";toggle.Text="EDIT MODE: ON" else disableEdit() end
end)
r15.MouseButton1Click:Connect(function()if selected then remote:FireServer("rotate",selected,15)end end)
r45.MouseButton1Click:Connect(function()if selected then remote:FireServer("rotate",selected,45)end end)
forward.MouseButton1Click:Connect(function()move(Vector3.new(0,0,-1))end)
back.MouseButton1Click:Connect(function()move(Vector3.new(0,0,1))end)
left.MouseButton1Click:Connect(function()move(Vector3.new(-1,0,0))end)
right.MouseButton1Click:Connect(function()move(Vector3.new(1,0,0))end)
up.MouseButton1Click:Connect(function()move(Vector3.new(0,1,0))end)
down.MouseButton1Click:Connect(function()move(Vector3.new(0,-1,0))end)
del.MouseButton1Click:Connect(function()if selected then remote:FireServer("delete",selected);selected=nil;hl.Enabled=false;status.Text="ON • TAP OBJECT" end end)
undo.MouseButton1Click:Connect(function()remote:FireServer("undo")end)
mouse.Button1Down:Connect(function()
 if not editOn or not frame.Visible or not gui.Enabled then return end
 local t=mouse.Target;local root=workspace:FindFirstChild("BBYA_ZERO_BUILD")
 if t and root and t:IsDescendantOf(root) and not t:IsA("SpawnLocation") then selected=t;hl.Adornee=t;hl.Enabled=true;status.Text=t.Name end
end)

print("[BBYA] Editor UI hidden; admin toggle via /bbyaedit")