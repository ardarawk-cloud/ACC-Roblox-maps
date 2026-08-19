local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes")
local musicRemote=remotes:WaitForChild("Music")
local supportRemote=remotes:WaitForChild("Support")
local stateRemote=remotes:WaitForChild("State")

local gui=Instance.new("ScreenGui")
gui.Name="BBYAClubUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=false;gui.Parent=player:WaitForChild("PlayerGui")
local function frame(name,pos,size)
 local f=Instance.new("Frame");f.Name=name;f.Position=pos;f.Size=size;f.BackgroundColor3=Color3.fromRGB(15,13,19);f.BackgroundTransparency=.08;f.BorderSizePixel=0;f.Visible=false;f.Parent=gui
 local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,14);c.Parent=f
 local s=Instance.new("UIStroke");s.Color=Color3.fromRGB(255,42,157);s.Thickness=1.4;s.Transparency=.2;s.Parent=f
 return f
end
local function btn(parent,text,pos,size,color)
 local b=Instance.new("TextButton");b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=color or Color3.fromRGB(37,31,43);b.TextColor3=Color3.new(1,1,1);b.Font=Enum.Font.GothamBold;b.TextScaled=true;b.BorderSizePixel=0;b.Parent=parent
 local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,10);c.Parent=b
 return b
end
local musicBtn=btn(gui,"MUSIC",UDim2.new(0,16,.5,-58),UDim2.fromOffset(92,46),Color3.fromRGB(255,42,157))
local supportBtn=btn(gui,"SUPPORT",UDim2.new(0,16,.5,0),UDim2.fromOffset(92,46),Color3.fromRGB(0,174,255))
local music=frame("MusicPanel",UDim2.new(0,120,.5,-120),UDim2.fromOffset(330,300))
local support=frame("SupportPanel",UDim2.new(0,120,.5,-95),UDim2.fromOffset(330,245))
local title=Instance.new("TextLabel");title.BackgroundTransparency=1;title.Position=UDim2.fromOffset(16,10);title.Size=UDim2.new(1,-32,0,36);title.Text="BBYA MUSIC";title.TextColor3=Color3.fromRGB(255,42,157);title.Font=Enum.Font.GothamBold;title.TextScaled=true;title.Parent=music
local now=Instance.new("TextLabel");now.BackgroundTransparency=1;now.Position=UDim2.fromOffset(16,48);now.Size=UDim2.new(1,-32,0,30);now.Text="No track loaded";now.TextColor3=Color3.fromRGB(220,220,225);now.Font=Enum.Font.GothamMedium;now.TextScaled=true;now.Parent=music
local prev=btn(music,"PAUSE",UDim2.fromOffset(16,88),UDim2.fromOffset(92,38))
local nextb=btn(music,"NEXT",UDim2.fromOffset(118,88),UDim2.fromOffset(92,38),Color3.fromRGB(255,42,157))
local resume=btn(music,"RESUME",UDim2.fromOffset(220,88),UDim2.fromOffset(94,38))
prev.MouseButton1Click:Connect(function() musicRemote:FireServer("pause") end)
nextb.MouseButton1Click:Connect(function() musicRemote:FireServer("next") end)
resume.MouseButton1Click:Connect(function() musicRemote:FireServer("resume") end)
local listHolder=Instance.new("ScrollingFrame");listHolder.Position=UDim2.fromOffset(16,138);listHolder.Size=UDim2.new(1,-32,1,-154);listHolder.BackgroundTransparency=1;listHolder.BorderSizePixel=0;listHolder.ScrollBarThickness=4;listHolder.AutomaticCanvasSize=Enum.AutomaticSize.Y;listHolder.CanvasSize=UDim2.new();listHolder.Parent=music
local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,7);layout.Parent=listHolder
local st=Instance.new("TextLabel");st.BackgroundTransparency=1;st.Position=UDim2.fromOffset(16,10);st.Size=UDim2.new(1,-32,0,38);st.Text="SUPPORT BBYA";st.TextColor3=Color3.fromRGB(0,174,255);st.Font=Enum.Font.GothamBold;st.TextScaled=true;st.Parent=support
local sub=Instance.new("TextLabel");sub.BackgroundTransparency=1;sub.Position=UDim2.fromOffset(16,50);sub.Size=UDim2.new(1,-32,0,42);sub.Text="Pilih dukungan untuk venue";sub.TextColor3=Color3.fromRGB(220,220,225);sub.Font=Enum.Font.Gotham;sub.TextScaled=true;sub.Parent=support
local supportHolder=Instance.new("Frame");supportHolder.BackgroundTransparency=1;supportHolder.Position=UDim2.fromOffset(16,103);supportHolder.Size=UDim2.new(1,-32,1,-119);supportHolder.Parent=support
local grid=Instance.new("UIGridLayout");grid.CellSize=UDim2.fromOffset(90,44);grid.CellPadding=UDim2.fromOffset(10,10);grid.Parent=supportHolder
local toast=Instance.new("TextLabel");toast.AnchorPoint=Vector2.new(.5,1);toast.Position=UDim2.new(.5,0,1,-20);toast.Size=UDim2.fromOffset(420,44);toast.BackgroundColor3=Color3.fromRGB(15,13,19);toast.BackgroundTransparency=.08;toast.TextColor3=Color3.new(1,1,1);toast.Font=Enum.Font.GothamMedium;toast.TextScaled=true;toast.Visible=false;toast.Parent=gui;local tc=Instance.new("UICorner");tc.CornerRadius=UDim.new(0,12);tc.Parent=toast
local function showToast(t) toast.Text=t;toast.Visible=true;task.delay(2.5,function() toast.Visible=false end) end
musicBtn.MouseButton1Click:Connect(function() music.Visible=not music.Visible;support.Visible=false;if music.Visible then musicRemote:FireServer("list") end end)
supportBtn.MouseButton1Click:Connect(function() support.Visible=not support.Visible;music.Visible=false;if support.Visible then supportRemote:FireServer("list") end end)
stateRemote.OnClientEvent:Connect(function(kind,data)
 if kind=="playlist" then
  for _,c in ipairs(listHolder:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
  for i,item in ipairs(data) do
   local b=btn(listHolder,(i..". "..item.title),UDim2.new(),UDim2.new(1,-6,0,38),Color3.fromRGB(31,27,36));b.TextScaled=false;b.TextSize=15;b.TextXAlignment=Enum.TextXAlignment.Left
   b.MouseButton1Click:Connect(function() musicRemote:FireServer("play",i) end)
  end
 elseif kind=="music" then now.Text=(data.playing and "▶ " or "Ⅱ ")..tostring(data.title or "")
 elseif kind=="supportProducts" then
  for _,c in ipairs(supportHolder:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
  for i,item in ipairs(data) do local b=btn(supportHolder,tostring(item.label),UDim2.new(),UDim2.fromOffset(90,44),Color3.fromRGB(0,124,190));b.MouseButton1Click:Connect(function() supportRemote:FireServer("prompt",i) end) end
 elseif kind=="toast" then showToast(tostring(data)) end
end)

musicRemote:FireServer("list")
supportRemote:FireServer("list")
