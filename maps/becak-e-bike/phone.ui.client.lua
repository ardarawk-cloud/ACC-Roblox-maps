-- BECAK E-BIKE — Driver Phone UI v1.0
-- Consolidates gameplay HUD into a Gojek-like in-world driver app presentation.

local Players=game:GetService('Players')
local ReplicatedStorage=game:GetService('ReplicatedStorage')
local Workspace=game:GetService('Workspace')
local TweenService=game:GetService('TweenService')

local player=Players.LocalPlayer
local pg=player:WaitForChild('PlayerGui')
local remotes=ReplicatedStorage:WaitForChild('BecakEBikeRemotes')
local stateEvent=remotes:WaitForChild('State')

-- Keep legacy toast notifications but remove the large blocking HUD frames.
task.delay(.8,function()
    local legacy=pg:FindFirstChild('BecakEBikeHUD')
    if legacy then
        for _,x in ipairs(legacy:GetChildren()) do
            if x:IsA('Frame') then x.Visible=false end
        end
    end
    local master=pg:FindFirstChild('BecakMasterplanHUD')
    if master then master.Enabled=false end
end)

local gui=Instance.new('ScreenGui')
gui.Name='BecakDriverPhone'
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=false
gui.DisplayOrder=30
gui.Parent=pg

local GREEN=Color3.fromRGB(26,155,76)
local GREEN2=Color3.fromRGB(34,185,91)
local DARK=Color3.fromRGB(14,19,23)
local CARD=Color3.fromRGB(25,32,37)
local MUTED=Color3.fromRGB(164,175,181)
local WHITE=Color3.fromRGB(245,247,248)

local function corner(o,r)local c=Instance.new('UICorner');c.CornerRadius=UDim.new(0,r or 14);c.Parent=o end
local function stroke(o,c,t)local s=Instance.new('UIStroke');s.Color=c or Color3.fromRGB(60,70,75);s.Thickness=t or 1;s.Transparency=.3;s.Parent=o end
local function label(parent,text,pos,size,fs,bold,color)
    local t=Instance.new('TextLabel');t.BackgroundTransparency=1;t.Text=text;t.Position=pos;t.Size=size;t.TextColor3=color or WHITE;t.TextSize=fs or 14;t.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham;t.TextXAlignment=Enum.TextXAlignment.Left;t.Parent=parent;return t
end
local function button(parent,text,pos,size,color)
    local b=Instance.new('TextButton');b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=color or CARD;b.TextColor3=WHITE;b.TextSize=14;b.Font=Enum.Font.GothamBold;b.AutoButtonColor=true;b.Parent=parent;corner(b,12);return b
end

-- Floating app launcher
local launcher=button(gui,'🛺',UDim2.new(1,-78,1,-90),UDim2.fromOffset(58,58),GREEN)
launcher.Name='PhoneLauncher';launcher.TextSize=28;stroke(launcher,Color3.fromRGB(95,230,135),2)

-- Phone body
local phone=Instance.new('Frame')
phone.Name='Phone'
phone.AnchorPoint=Vector2.new(1,1)
phone.Position=UDim2.new(1,-20,1,-22)
phone.Size=UDim2.new(0,330,0,560)
phone.BackgroundColor3=Color3.fromRGB(7,9,11)
phone.Visible=false
phone.Parent=gui
corner(phone,34);stroke(phone,Color3.fromRGB(100,108,112),2)

local screen=Instance.new('Frame')
screen.Position=UDim2.fromOffset(10,10);screen.Size=UDim2.new(1,-20,1,-20);screen.BackgroundColor3=DARK;screen.Parent=phone
corner(screen,26)

local notch=Instance.new('Frame');notch.AnchorPoint=Vector2.new(.5,0);notch.Position=UDim2.new(.5,0,0,0);notch.Size=UDim2.fromOffset(100,20);notch.BackgroundColor3=Color3.fromRGB(3,4,5);notch.Parent=screen;corner(notch,10)

local header=Instance.new('Frame');header.Position=UDim2.fromOffset(12,25);header.Size=UDim2.new(1,-24,0,58);header.BackgroundColor3=Color3.fromRGB(20,73,46);header.Parent=screen;corner(header,15)
local title=label(header,'BECAK E-BIKE',UDim2.fromOffset(14,8),UDim2.new(.6,0,0,22),17,true)
local online=label(header,'● ONLINE',UDim2.new(.62,0,0,9),UDim2.new(.34,0,0,20),12,true,Color3.fromRGB(112,245,145));online.TextXAlignment=Enum.TextXAlignment.Right
local sub=label(header,'Driver Nusakarya',UDim2.fromOffset(14,31),UDim2.new(.6,0,0,18),11,false,Color3.fromRGB(204,225,211))
local close=button(header,'×',UDim2.new(1,-40,0,8),UDim2.fromOffset(30,30),Color3.fromRGB(27,47,38));close.TextSize=20

local content=Instance.new('ScrollingFrame');content.Name='Home';content.Position=UDim2.fromOffset(12,92);content.Size=UDim2.new(1,-24,1,-160);content.BackgroundTransparency=1;content.BorderSizePixel=0;content.ScrollBarThickness=3;content.ScrollBarImageColor3=GREEN;content.CanvasSize=UDim2.new(0,0,0,620);content.Parent=screen

local wallet=Instance.new('Frame');wallet.Position=UDim2.fromOffset(0,0);wallet.Size=UDim2.new(1,0,0,82);wallet.BackgroundColor3=CARD;wallet.Parent=content;corner(wallet,16)
local money=label(wallet,'Rp 25.000',UDim2.fromOffset(14,13),UDim2.new(.6,0,0,25),21,true)
local meta=label(wallet,'LV 1  •  ★ 5.0',UDim2.fromOffset(14,45),UDim2.new(.6,0,0,20),12,false,MUTED)
local battery=label(wallet,'🔋 100%',UDim2.new(.65,0,0,15),UDim2.new(.3,0,0,22),13,true,Color3.fromRGB(122,235,145));battery.TextXAlignment=Enum.TextXAlignment.Right
local trips=label(wallet,'0 trip',UDim2.new(.65,0,0,45),UDim2.new(.3,0,0,20),12,false,MUTED);trips.TextXAlignment=Enum.TextXAlignment.Right

local section=label(content,'MAU KERJA APA?',UDim2.fromOffset(2,96),UDim2.new(1,0,0,20),12,true,MUTED)
local passenger=button(content,'🚕  CARI PENUMPANG\n      Antar warga ke tujuan',UDim2.fromOffset(0,122),UDim2.new(1,0,0,66),GREEN)
passenger.TextXAlignment=Enum.TextXAlignment.Left
local cargo=button(content,'📦  ANTAR PAKET / CARGO\n      Ambil job di Cargo Depot',UDim2.fromOffset(0,198),UDim2.new(1,0,0,66),Color3.fromRGB(43,100,165));cargo.TextXAlignment=Enum.TextXAlignment.Left
local garage=button(content,'🔧  GARASI & UPGRADE\n      Motor • baterai • servis',UDim2.fromOffset(0,274),UDim2.new(1,0,0,66),Color3.fromRGB(176,111,32));garage.TextXAlignment=Enum.TextXAlignment.Left
local mission=button(content,'🏆  MISI & STORY\n      Chapter dan target sesi',UDim2.fromOffset(0,350),UDim2.new(1,0,0,66),Color3.fromRGB(105,63,155));mission.TextXAlignment=Enum.TextXAlignment.Left

local status=Instance.new('Frame');status.Position=UDim2.fromOffset(0,432);status.Size=UDim2.new(1,0,0,130);status.BackgroundColor3=CARD;status.Parent=content;corner(status,16)
label(status,'STATUS HARI INI',UDim2.fromOffset(14,10),UDim2.new(1,-28,0,20),12,true,MUTED)
local weather=label(status,'Cuaca  CERAH',UDim2.fromOffset(14,39),UDim2.new(1,-28,0,20),13,true)
local story=label(status,'Story  Chapter 1',UDim2.fromOffset(14,66),UDim2.new(1,-28,0,20),13,true)
local activeCargo=label(status,'Cargo  —',UDim2.fromOffset(14,93),UDim2.new(1,-28,0,20),13,true)

local nav=Instance.new('Frame');nav.AnchorPoint=Vector2.new(0,1);nav.Position=UDim2.new(0,12,1,-12);nav.Size=UDim2.new(1,-24,0,52);nav.BackgroundColor3=Color3.fromRGB(18,23,27);nav.Parent=screen;corner(nav,15)
local navHome=button(nav,'⌂\nBeranda',UDim2.new(0,4,0,4),UDim2.new(.24,-4,1,-8),GREEN)
local navMap=button(nav,'⌖\nPeta',UDim2.new(.25,0,0,4),UDim2.new(.24,-4,1,-8),Color3.fromRGB(30,37,42))
local navJobs=button(nav,'▣\nJob',UDim2.new(.5,0,0,4),UDim2.new(.24,-4,1,-8),Color3.fromRGB(30,37,42))
local navProfile=button(nav,'●\nProfil',UDim2.new(.75,0,0,4),UDim2.new(.24,-4,1,-8),Color3.fromRGB(30,37,42))
for _,b in ipairs({navHome,navMap,navJobs,navProfile}) do b.TextSize=11 end

local function rupiah(n)
    local s=tostring(math.floor(tonumber(n) or 0));local out=''
    while #s>3 do out='.'..s:sub(-3)..out;s=s:sub(1,-4) end
    return 'Rp '..s..out
end

stateEvent.OnClientEvent:Connect(function(s)
    money.Text=rupiah(s.coins)
    meta.Text='LV '..tostring(s.level or 1)..'  •  '..string.format('★ %.1f',s.reputation or 5)
    local max=math.max(1,s.batteryMax or 100)
    battery.Text='🔋 '..math.floor(((s.battery or 0)/max)*100)..'%'
    trips.Text=tostring(s.trips or 0)..' trip'
end)

local function refreshMeta()
    weather.Text='Cuaca  '..tostring(Workspace:GetAttribute('BecakWeather') or 'CERAH')
    story.Text='Story  Chapter '..tostring(player:GetAttribute('StoryChapter') or 1)
    local c=player:GetAttribute('CargoDestination');activeCargo.Text='Cargo  '..(c or '—')
end
Workspace:GetAttributeChangedSignal('BecakWeather'):Connect(refreshMeta)
player:GetAttributeChangedSignal('StoryChapter'):Connect(refreshMeta)
player:GetAttributeChangedSignal('CargoDestination'):Connect(refreshMeta)
refreshMeta()

local opened=false
local function setOpen(v)
    opened=v
    if v then
        phone.Visible=true
        phone.Position=UDim2.new(1,370,1,-22)
        TweenService:Create(phone,TweenInfo.new(.22,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(1,-20,1,-22)}):Play()
        launcher.Visible=false
    else
        TweenService:Create(phone,TweenInfo.new(.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.new(1,370,1,-22)}):Play()
        task.delay(.2,function()phone.Visible=false;launcher.Visible=true end)
    end
end
launcher.MouseButton1Click:Connect(function()setOpen(true)end)
close.MouseButton1Click:Connect(function()setOpen(false)end)

passenger.MouseButton1Click:Connect(function()setOpen(false)end)
cargo.MouseButton1Click:Connect(function()setOpen(false)end)
garage.MouseButton1Click:Connect(function()setOpen(false)end)
mission.MouseButton1Click:Connect(function()setOpen(false)end)

Workspace:SetAttribute('ACC_BecakPhoneUI','v1.0')
