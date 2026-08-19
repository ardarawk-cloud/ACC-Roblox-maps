local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local player=Players.LocalPlayer
local remote=ReplicatedStorage:WaitForChild("BBYAEditRemote")
local mouse=player:GetMouse()
local selected=nil
local editOn=false

local gui=Instance.new("ScreenGui")
gui.Name="BBYAEditorUI";gui.ResetOnSpawn=false;gui.Parent=player:WaitForChild("PlayerGui")
local frame=Instance.new("Frame")
frame.Size=UDim2.fromOffset(250,280);frame.Position=UDim2.new(1,-265,.5,-140);frame.BackgroundColor3=Color3.fromRGB(18,18,24);frame.BackgroundTransparency=.08;frame.Parent=gui
local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,42);title.BackgroundTransparency=1;title.Text="BBYA EDIT MODE";title.TextColor3=Color3.fromRGB(255,255,255);title.TextScaled=true;title.Font=Enum.Font.GothamBold;title.Parent=frame
local status=Instance.new("TextLabel")
status.Position=UDim2.fromOffset(10,45);status.Size=UDim2.new(1,-20,0,40);status.BackgroundTransparency=1;status.Text="OFF";status.TextColor3=Color3.fromRGB(255,100,170);status.TextScaled=true;status.Font=Enum.Font.GothamMedium;status.Parent=frame
local function button(text,y)
 local b=Instance.new("TextButton");b.Size=UDim2.new(1,-20,0,38);b.Position=UDim2.fromOffset(10,y);b.BackgroundColor3=Color3.fromRGB(39,34,48);b.TextColor3=Color3.fromRGB(255,255,255);b.Text=text;b.TextScaled=true;b.Font=Enum.Font.GothamMedium;b.Parent=frame;return b
end
local toggle=button("EDIT ON / OFF",90)
local r15=button("ROTATE 15°",132)
local r45=button("ROTATE 45°",174)
local del=button("DELETE",216)
local undo=button("UNDO",258)
frame.Size=UDim2.fromOffset(250,310)
local hl=Instance.new("Highlight")
hl.FillTransparency=.75;hl.OutlineColor=Color3.fromRGB(255,42,157);hl.Enabled=false;hl.Parent=gui

toggle.MouseButton1Click:Connect(function()
 editOn=not editOn;status.Text=editOn and "ON - TAP OBJECT" or "OFF";if not editOn then selected=nil;hl.Enabled=false end
end)
r15.MouseButton1Click:Connect(function() if selected then remote:FireServer("rotate",selected,15) end end)
r45.MouseButton1Click:Connect(function() if selected then remote:FireServer("rotate",selected,45) end end)
del.MouseButton1Click:Connect(function() if selected then remote:FireServer("delete",selected);selected=nil;hl.Enabled=false end end)
undo.MouseButton1Click:Connect(function() remote:FireServer("undo") end)

mouse.Button1Down:Connect(function()
 if not editOn then return end
 local t=mouse.Target
 if t and t:IsDescendantOf(workspace:FindFirstChild("BBYA_ZERO_BUILD") or workspace) and not t:IsA("SpawnLocation") then
  selected=t;hl.Adornee=t;hl.Enabled=true;status.Text=t.Name
 end
end)
