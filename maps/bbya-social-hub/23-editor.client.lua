local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remote=ReplicatedStorage:WaitForChild("BBYAEditRemote")
local mouse=player:GetMouse();local selected=nil;local editOn=false
local gui=Instance.new("ScreenGui");gui.Name="BBYAEditorUI";gui.ResetOnSpawn=false;gui.Parent=player:WaitForChild("PlayerGui")
local frame=Instance.new("Frame");frame.Size=UDim2.fromOffset(250,500);frame.Position=UDim2.new(1,-265,.5,-250);frame.BackgroundColor3=Color3.fromRGB(18,18,24);frame.BackgroundTransparency=.08;frame.Parent=gui
local title=Instance.new("TextLabel");title.Size=UDim2.new(1,0,0,38);title.BackgroundTransparency=1;title.Text="BBYA EDIT MODE";title.TextColor3=Color3.new(1,1,1);title.TextScaled=true;title.Font=Enum.Font.GothamBold;title.Parent=frame
local status=Instance.new("TextLabel");status.Position=UDim2.fromOffset(10,40);status.Size=UDim2.new(1,-20,0,34);status.BackgroundTransparency=1;status.Text="OFF";status.TextColor3=Color3.fromRGB(255,100,170);status.TextScaled=true;status.Font=Enum.Font.GothamMedium;status.Parent=frame
local function button(text,x,y,w)local b=Instance.new("TextButton");b.Size=UDim2.fromOffset(w or 110,36);b.Position=UDim2.fromOffset(x,y);b.BackgroundColor3=Color3.fromRGB(39,34,48);b.TextColor3=Color3.new(1,1,1);b.Text=text;b.TextScaled=true;b.Font=Enum.Font.GothamMedium;b.Parent=frame;return b end
local toggle=button("EDIT ON / OFF",10,78,230)
local r15=button("ROTATE 15°",10,120,110);local r45=button("ROTATE 45°",130,120,110)
local forward=button("↑ FORWARD",70,170,110);local left=button("← LEFT",10,212,105);local right=button("RIGHT →",135,212,105);local back=button("↓ BACK",70,254,110)
local up=button("UP +",10,300,110);local down=button("DOWN -",130,300,110)
local del=button("DELETE",10,352,110);local undo=button("UNDO",130,352,110)
local stepLabel=Instance.new("TextLabel");stepLabel.Position=UDim2.fromOffset(10,400);stepLabel.Size=UDim2.new(1,-20,0,30);stepLabel.BackgroundTransparency=1;stepLabel.Text="MOVE STEP: 1 STUD";stepLabel.TextColor3=Color3.fromRGB(190,190,200);stepLabel.TextScaled=true;stepLabel.Parent=frame
local hl=Instance.new("Highlight");hl.FillTransparency=.75;hl.OutlineColor=Color3.fromRGB(255,42,157);hl.Enabled=false;hl.Parent=gui
local function move(v)if selected then remote:FireServer("move",selected,v)end end
toggle.MouseButton1Click:Connect(function()editOn=not editOn;status.Text=editOn and "ON - TAP OBJECT" or "OFF";if not editOn then selected=nil;hl.Enabled=false end end)
r15.MouseButton1Click:Connect(function()if selected then remote:FireServer("rotate",selected,15)end end);r45.MouseButton1Click:Connect(function()if selected then remote:FireServer("rotate",selected,45)end end)
forward.MouseButton1Click:Connect(function()move(Vector3.new(0,0,-1))end);back.MouseButton1Click:Connect(function()move(Vector3.new(0,0,1))end);left.MouseButton1Click:Connect(function()move(Vector3.new(-1,0,0))end);right.MouseButton1Click:Connect(function()move(Vector3.new(1,0,0))end);up.MouseButton1Click:Connect(function()move(Vector3.new(0,1,0))end);down.MouseButton1Click:Connect(function()move(Vector3.new(0,-1,0))end)
del.MouseButton1Click:Connect(function()if selected then remote:FireServer("delete",selected);selected=nil;hl.Enabled=false end end);undo.MouseButton1Click:Connect(function()remote:FireServer("undo")end)
mouse.Button1Down:Connect(function()if not editOn then return end;local t=mouse.Target;local root=workspace:FindFirstChild("BBYA_ZERO_BUILD");if t and root and t:IsDescendantOf(root) and not t:IsA("SpawnLocation") then selected=t;hl.Adornee=t;hl.Enabled=true;status.Text=t.Name end end)