local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes")
local musicRemote=remotes:WaitForChild("Music")
local supportRemote=remotes:WaitForChild("Support")
local stateRemote=remotes:WaitForChild("State")
local gui=Instance.new("ScreenGui");gui.Name="BBYAClubUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=false;gui.Parent=player:WaitForChild("PlayerGui")
local function round(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function btn(parent,text,pos,size,color)local b=Instance.new("TextButton");b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=color or Color3.fromRGB(37,31,43);b.TextColor3=Color3.new(1,1,1);b.Font=Enum.Font.GothamBold;b.TextScaled=true;b.BorderSizePixel=0;b.Parent=parent;round(b,10);return b end
local menuBtn=btn(gui,"☰",UDim2.new(1,-68,0,18),UDim2.fromOffset(50,50),Color3.fromRGB(255,42,157));menuBtn.AnchorPoint=Vector2.new(0,0)
local menu=Instance.new("Frame");menu.Name="ClubMenu";menu.AnchorPoint=Vector2.new(1,0);menu.Position=UDim2.new(1,-18,0,76);menu.Size=UDim2.fromOffset(350,410);menu.BackgroundColor3=Color3.fromRGB(15,13,19);menu.BackgroundTransparency=.06;menu.BorderSizePixel=0;menu.Visible=false;menu.Parent=gui;round(menu,14)
local stroke=Instance.new("UIStroke");stroke.Color=Color3.fromRGB(255,42,157);stroke.Thickness=1.4;stroke.Transparency=.2;stroke.Parent=menu
local head=Instance.new("TextLabel");head.BackgroundTransparency=1;head.Position=UDim2.fromOffset(16,10);head.Size=UDim2.new(1,-32,0,34);head.Text="BBYA MENU";head.TextColor3=Color3.new(1,1,1);head.Font=Enum.Font.GothamBold;head.TextScaled=true;head.Parent=menu
local musicTab=btn(menu,"MUSIC",UDim2.fromOffset(16,54),UDim2.fromOffset(151,40),Color3.fromRGB(255,42,157))
local supportTab=btn(menu,"SUPPORT",UDim2.fromOffset(183,54),UDim2.fromOffset(151,40),Color3.fromRGB(0,174,255))
local content=Instance.new("Frame");content.BackgroundTransparency=1;content.Position=UDim2.fromOffset(16,104);content.Size=UDim2.new(1,-32,1,-120);content.Parent=menu
local music=Instance.new("Frame");music.BackgroundTransparency=1;music.Size=UDim2.fromScale(1,1);music.Parent=content
local title=Instance.new("TextLabel");title.BackgroundTransparency=1;title.Size=UDim2.new(1,0,0,30);title.Text="BBYA MUSIC";title.TextColor3=Color3.fromRGB(255,42,157);title.Font=Enum.Font.GothamBold;title.TextScaled=true;title.Parent=music
local now=Instance.new("TextLabel");now.BackgroundTransparency=1;now.Position=UDim2.fromOffset(0,34);now.Size=UDim2.new(1,0,0,28);now.Text="No track loaded";now.TextColor3=Color3.fromRGB(220,220,225);now.Font=Enum.Font.GothamMedium;now.TextScaled=true;now.Parent=music
local pause=btn(music,"PAUSE",UDim2.fromOffset(0,70),UDim2.fromOffset(96,36));local nextb=btn(music,"NEXT",UDim2.fromOffset(106,70),UDim2.fromOffset(96,36),Color3.fromRGB(255,42,157));local resume=btn(music,"RESUME",UDim2.fromOffset(212,70),UDim2.fromOffset(106,36))
pause.MouseButton1Click:Connect(function()musicRemote:FireServer("pause")end);nextb.MouseButton1Click:Connect(function()musicRemote:FireServer("next")end);resume.MouseButton1Click:Connect(function()musicRemote:FireServer("resume")end)
local listHolder=Instance.new("ScrollingFrame");listHolder.Position=UDim2.fromOffset(0,116);listHolder.Size=UDim2.new(1,0,1,-116);listHolder.BackgroundTransparency=1;listHolder.BorderSizePixel=0;listHolder.ScrollBarThickness=4;listHolder.AutomaticCanvasSize=Enum.AutomaticSize.Y;listHolder.CanvasSize=UDim2.new();listHolder.Parent=music;local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,7);layout.Parent=listHolder
local support=Instance.new("Frame");support.BackgroundTransparency=1;support.Size=UDim2.fromScale(1,1);support.Visible=false;support.Parent=content
local st=Instance.new("TextLabel");st.BackgroundTransparency=1;st.Size=UDim2.new(1,0,0,36);st.Text="SUPPORT BBYA";st.TextColor3=Color3.fromRGB(0,174,255);st.Font=Enum.Font.GothamBold;st.TextScaled=true;st.Parent=support
local sub=Instance.new("TextLabel");sub.BackgroundTransparency=1;sub.Position=UDim2.fromOffset(0,42);sub.Size=UDim2.new(1,0,0,40);sub.Text="Pilih dukungan untuk venue";sub.TextColor3=Color3.fromRGB(220,220,225);sub.Font=Enum.Font.Gotham;sub.TextScaled=true;sub.Parent=support
local supportHolder=Instance.new("Frame");supportHolder.BackgroundTransparency=1;supportHolder.Position=UDim2.fromOffset(0,96);supportHolder.Size=UDim2.new(1,0,1,-96);supportHolder.Parent=support;local grid=Instance.new("UIGridLayout");grid.CellSize=UDim2.fromOffset(96,44);grid.CellPadding=UDim2.fromOffset(10,10);grid.Parent=supportHolder
local toast=Instance.new("TextLabel");toast.AnchorPoint=Vector2.new(.5,1);toast.Position=UDim2.new(.5,0,1,-20);toast.Size=UDim2.fromOffset(420,44);toast.BackgroundColor3=Color3.fromRGB(15,13,19);toast.BackgroundTransparency=.08;toast.TextColor3=Color3.new(1,1,1);toast.Font=Enum.Font.GothamMedium;toast.TextScaled=true;toast.Visible=false;toast.Parent=gui;round(toast,12)
local function showToast(t)toast.Text=t;toast.Visible=true;task.delay(2.5,function()toast.Visible=false end)end
menuBtn.MouseButton1Click:Connect(function()menu.Visible=not menu.Visible;if menu.Visible then musicRemote:FireServer("list") end end)
musicTab.MouseButton1Click:Connect(function()music.Visible=true;support.Visible=false;musicRemote:FireServer("list")end)
supportTab.MouseButton1Click:Connect(function()music.Visible=false;support.Visible=true;supportRemote:FireServer("list")end)
stateRemote.OnClientEvent:Connect(function(kind,data)
 if kind=="playlist" then for _,c in ipairs(listHolder:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end;for i,item in ipairs(data)do local b=btn(listHolder,(i..". "..item.title),UDim2.new(),UDim2.new(1,-6,0,38),Color3.fromRGB(31,27,36));b.TextScaled=false;b.TextSize=15;b.TextXAlignment=Enum.TextXAlignment.Left;b.MouseButton1Click:Connect(function()musicRemote:FireServer("play",i)end)end
 elseif kind=="music" then now.Text=(data.playing and "▶ " or "Ⅱ ")..tostring(data.title or "")
 elseif kind=="supportProducts" then for _,c in ipairs(supportHolder:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end;for i,item in ipairs(data)do local b=btn(supportHolder,tostring(item.label),UDim2.new(),UDim2.fromOffset(96,44),Color3.fromRGB(0,124,190));b.MouseButton1Click:Connect(function()supportRemote:FireServer("prompt",i)end)end
 elseif kind=="toast" then showToast(tostring(data)) end
end)
musicRemote:FireServer("list");supportRemote:FireServer("list")