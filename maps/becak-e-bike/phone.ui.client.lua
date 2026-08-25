-- BECAK E-BIKE — Driver Phone UI v1.8
-- Compact driver app: Beranda, Peta, Job, Garasi, Profil. Safe Area owns layout/scale.
-- v1.8 scopes BillboardGui polish to the BecakEBike namespace to avoid full-Workspace startup/streaming scans.
local Players=game:GetService('Players')
local ReplicatedStorage=game:GetService('ReplicatedStorage')
local Workspace=game:GetService('Workspace')

local player=Players.LocalPlayer
local pg=player:WaitForChild('PlayerGui')
local remotes=ReplicatedStorage:WaitForChild('BecakEBikeRemotes')
local stateEvent=remotes:WaitForChild('State')
local becakRoot=Workspace:FindFirstChild('BecakEBike') or Workspace:WaitForChild('BecakEBike',15)

-- Hide old blocking HUD, but preserve its toast label so gameplay notifications still work.
task.delay(.6,function()
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

local GREEN=Color3.fromRGB(21,155,73)
local GREEN2=Color3.fromRGB(35,191,93)
local DARK=Color3.fromRGB(12,16,19)
local CARD=Color3.fromRGB(24,30,34)
local MUTED=Color3.fromRGB(155,167,174)
local WHITE=Color3.fromRGB(246,248,249)
local BLUE=Color3.fromRGB(44,107,185)
local ORANGE=Color3.fromRGB(190,118,34)
local PURPLE=Color3.fromRGB(111,67,161)

local lastState={coins=25000,level=1,reputation=5,trips=0,battery=100,batteryMax=100,motorLevel=1,batteryLevel=1}
local currentPage='Beranda'

local function corner(o,r)local c=Instance.new('UICorner');c.CornerRadius=UDim.new(0,r or 14);c.Parent=o return c end
local function stroke(o,c,t,tr)local s=Instance.new('UIStroke');s.Color=c or Color3.fromRGB(65,73,78);s.Thickness=t or 1;s.Transparency=tr or .28;s.Parent=o return s end
local function label(parent,text,pos,size,fs,bold,color,align)
    local t=Instance.new('TextLabel');t.BackgroundTransparency=1;t.Text=text;t.Position=pos;t.Size=size;t.TextColor3=color or WHITE;t.TextSize=fs or 14;t.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham;t.TextXAlignment=align or Enum.TextXAlignment.Left;t.TextYAlignment=Enum.TextYAlignment.Center;t.Parent=parent;return t
end
local function button(parent,text,pos,size,color)
    local b=Instance.new('TextButton');b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=color or CARD;b.TextColor3=WHITE;b.TextSize=13;b.Font=Enum.Font.GothamBold;b.AutoButtonColor=true;b.Parent=parent;corner(b,11);return b
end
local function rupiah(n)
    local s=tostring(math.floor(tonumber(n) or 0));local out=''
    while #s>3 do out='.'..s:sub(-3)..out;s=s:sub(1,-4) end
    return 'Rp '..s..out
end
local function pageFrame(screen)
    local p=Instance.new('ScrollingFrame');p.Position=UDim2.fromOffset(12,91);p.Size=UDim2.new(1,-24,1,-158);p.BackgroundTransparency=1;p.BorderSizePixel=0;p.ScrollBarThickness=3;p.ScrollBarImageColor3=GREEN;p.CanvasSize=UDim2.new(0,0,0,650);p.Visible=false;p.Parent=screen;return p
end
local function card(parent,y,h)
    local f=Instance.new('Frame');f.Position=UDim2.fromOffset(0,y);f.Size=UDim2.new(1,0,0,h);f.BackgroundColor3=CARD;f.Parent=parent;corner(f,15);return f
end

local launcher=button(gui,'BE',UDim2.fromOffset(10,140),UDim2.fromOffset(48,48),GREEN)
launcher.Name='PhoneLauncher';launcher.TextSize=16;stroke(launcher,Color3.fromRGB(108,235,145),2,.12)

local phone=Instance.new('Frame')
phone.Name='Phone';phone.AnchorPoint=Vector2.new(0,0);phone.Position=UDim2.fromOffset(10,104);phone.Size=UDim2.fromOffset(326,566);phone.BackgroundColor3=Color3.fromRGB(5,7,8);phone.Visible=false;phone.Parent=gui
corner(phone,32);stroke(phone,Color3.fromRGB(110,116,120),2,.1)
local scaler=Instance.new('UIScale');scaler.Scale=1;scaler.Parent=phone

local screen=Instance.new('Frame');screen.Position=UDim2.fromOffset(9,9);screen.Size=UDim2.new(1,-18,1,-18);screen.BackgroundColor3=DARK;screen.Parent=phone;corner(screen,25)
local notch=Instance.new('Frame');notch.AnchorPoint=Vector2.new(.5,0);notch.Position=UDim2.new(.5,0,0,0);notch.Size=UDim2.fromOffset(92,18);notch.BackgroundColor3=Color3.fromRGB(2,3,4);notch.Parent=screen;corner(notch,9)

local header=Instance.new('Frame');header.Position=UDim2.fromOffset(10,23);header.Size=UDim2.new(1,-20,0,59);header.BackgroundColor3=Color3.fromRGB(17,72,43);header.Parent=screen;corner(header,14)
label(header,'BECAK E-BIKE',UDim2.fromOffset(13,7),UDim2.new(.58,0,0,23),16,true)
local headerSub=label(header,'Driver Nusakarya',UDim2.fromOffset(13,31),UDim2.new(.6,0,0,18),10,false,Color3.fromRGB(201,224,208))
local online=label(header,'ONLINE',UDim2.new(.62,0,0,9),UDim2.new(.22,0,0,20),10,true,Color3.fromRGB(119,247,153),Enum.TextXAlignment.Right)
local close=button(header,'×',UDim2.new(1,-38,0,8),UDim2.fromOffset(29,29),Color3.fromRGB(26,48,37));close.TextSize=19

local home=pageFrame(screen);home.Name='Beranda';home.Visible=true
local map=pageFrame(screen);map.Name='Peta'
local jobs=pageFrame(screen);jobs.Name='Job'
local garage=pageFrame(screen);garage.Name='Garasi'
local profile=pageFrame(screen);profile.Name='Profil'
local pages={Beranda=home,Peta=map,Job=jobs,Garasi=garage,Profil=profile}

-- HOME
local wallet=card(home,0,84)
local money=label(wallet,'Rp 25.000',UDim2.fromOffset(14,11),UDim2.new(.6,0,0,28),21,true)
local meta=label(wallet,'LV 1  •  ★ 5.0',UDim2.fromOffset(14,45),UDim2.new(.6,0,0,20),11,false,MUTED)
local battery=label(wallet,'BATERAI 100%',UDim2.new(.62,0,0,13),UDim2.new(.34,0,0,21),11,true,Color3.fromRGB(125,237,150),Enum.TextXAlignment.Right)
local trips=label(wallet,'0 trip',UDim2.new(.62,0,0,46),UDim2.new(.34,0,0,18),11,false,MUTED,Enum.TextXAlignment.Right)
label(home,'AKSI CEPAT',UDim2.fromOffset(2,96),UDim2.new(1,0,0,18),11,true,MUTED)
local hPassenger=button(home,'CARI PENUMPANG',UDim2.fromOffset(0,120),UDim2.new(1,0,0,56),GREEN)
local hCargo=button(home,'ANTAR CARGO / PAKET',UDim2.fromOffset(0,185),UDim2.new(1,0,0,56),BLUE)
local hGarage=button(home,'GARASI & UPGRADE',UDim2.fromOffset(0,250),UDim2.new(1,0,0,56),ORANGE)
local hMission=button(home,'MISI & STORY',UDim2.fromOffset(0,315),UDim2.new(1,0,0,56),PURPLE)
local status=card(home,385,132)
label(status,'STATUS HARI INI',UDim2.fromOffset(14,8),UDim2.new(1,-28,0,19),11,true,MUTED)
local weather=label(status,'Cuaca  CERAH',UDim2.fromOffset(14,34),UDim2.new(1,-28,0,21),12,true)
local story=label(status,'Story  Chapter 1',UDim2.fromOffset(14,60),UDim2.new(1,-28,0,21),12,true)
local activeCargo=label(status,'Cargo  —',UDim2.fromOffset(14,86),UDim2.new(1,-28,0,21),12,true)
local objective=label(status,'Job  Cari penumpang / cargo',UDim2.fromOffset(14,111),UDim2.new(1,-28,0,18),11,false,Color3.fromRGB(202,215,221))

-- MAP
local mapHero=card(map,0,260);mapHero.BackgroundColor3=Color3.fromRGB(20,48,38)
label(mapHero,'PETA NUSAKARYA',UDim2.fromOffset(15,10),UDim2.new(1,-30,0,24),16,true)
label(mapHero,'8 distrik • rute kota • titik layanan',UDim2.fromOffset(15,36),UDim2.new(1,-30,0,18),10,false,Color3.fromRGB(184,211,195))
local roads=Instance.new('Frame');roads.Position=UDim2.fromOffset(20,70);roads.Size=UDim2.new(1,-40,0,155);roads.BackgroundColor3=Color3.fromRGB(47,84,60);roads.Parent=mapHero;corner(roads,12)
local vroad=Instance.new('Frame');vroad.AnchorPoint=Vector2.new(.5,.5);vroad.Position=UDim2.new(.5,0,.5,0);vroad.Size=UDim2.new(.08,0,.9,0);vroad.BackgroundColor3=Color3.fromRGB(70,73,76);vroad.Parent=roads;corner(vroad,4)
local hroad=Instance.new('Frame');hroad.AnchorPoint=Vector2.new(.5,.5);hroad.Position=UDim2.new(.5,0,.5,0);hroad.Size=UDim2.new(.92,0,.09,0);hroad.BackgroundColor3=Color3.fromRGB(70,73,76);hroad.Parent=roads;corner(hroad,4)
local playerDot=Instance.new('Frame');playerDot.AnchorPoint=Vector2.new(.5,.5);playerDot.Position=UDim2.new(.42,0,.59,0);playerDot.Size=UDim2.fromOffset(14,14);playerDot.BackgroundColor3=GREEN2;playerDot.Parent=roads;corner(playerDot,7);stroke(playerDot,WHITE,2,0)
for _,it in ipairs({{'Pasar',.18,.25},{'Pusat Kota',.67,.36},{'Pantai',.72,.78},{'Terminal',.78,.52},{'Sekolah',.27,.66}}) do
    label(roads,it[1],UDim2.new(it[2],-35,it[3],-10),UDim2.fromOffset(70,20),9,true,WHITE,Enum.TextXAlignment.Center)
end
local mapJob=card(map,275,115)
label(mapJob,'TUJUAN AKTIF',UDim2.fromOffset(14,9),UDim2.new(1,-28,0,20),11,true,MUTED)
local mapObjective=label(mapJob,'Belum ada perjalanan',UDim2.fromOffset(14,36),UDim2.new(1,-28,0,26),14,true)
label(mapJob,'Gunakan marker hijau dan nama jalan di dunia untuk navigasi.',UDim2.fromOffset(14,68),UDim2.new(1,-28,0,37),10,false,Color3.fromRGB(190,201,207));mapJob.ClipsDescendants=true

-- JOBS
label(jobs,'JOB DRIVER',UDim2.fromOffset(2,0),UDim2.new(1,0,0,25),17,true)
local j1=card(jobs,38,100);local j2=card(jobs,150,100);local j3=card(jobs,262,100)
label(j1,'PENUMPANG',UDim2.fromOffset(14,10),UDim2.new(.6,0,0,22),14,true,Color3.fromRGB(115,241,149))
label(j1,'Dekati NPC → Pick Up → antar ke tujuan.',UDim2.fromOffset(14,36),UDim2.new(1,-28,0,40),10,false,Color3.fromRGB(205,215,220))
label(j1,'Bayaran berdasarkan jarak + XP',UDim2.fromOffset(14,73),UDim2.new(1,-28,0,18),10,true,MUTED)
label(j2,'CARGO / LOGISTIK',UDim2.fromOffset(14,10),UDim2.new(.7,0,0,22),14,true,Color3.fromRGB(108,173,242))
label(j2,'Ambil muatan di Nusakarya Logistics.',UDim2.fromOffset(14,36),UDim2.new(1,-28,0,40),10,false,Color3.fromRGB(205,215,220))
label(j2,'Reward dasar Rp35.000',UDim2.fromOffset(14,73),UDim2.new(1,-28,0,18),10,true,MUTED)
label(j3,'TARGET SESI',UDim2.fromOffset(14,10),UDim2.new(.6,0,0,22),14,true,Color3.fromRGB(225,179,92))
local sessionTarget=label(j3,'0 / 10 trip',UDim2.fromOffset(14,38),UDim2.new(.6,0,0,25),16,true)
label(j3,'Selesaikan 10 trip untuk bonus sesi.',UDim2.fromOffset(14,70),UDim2.new(1,-28,0,18),10,false,MUTED)

-- GARAGE
label(garage,'GARASI PAK JAYA',UDim2.fromOffset(2,0),UDim2.new(1,0,0,25),17,true)
local gStatus=card(garage,38,108)
label(gStatus,'BECAK E-BIKE • CARGO E-BIKE 01',UDim2.fromOffset(14,9),UDim2.new(1,-28,0,22),12,true)
local gMotor=label(gStatus,'Motor  Level 1',UDim2.fromOffset(14,39),UDim2.new(.48,0,0,20),11,false)
local gBattery=label(gStatus,'Baterai  Level 1',UDim2.new(.5,0,0,39),UDim2.new(.46,0,0,20),11,false)
local gCondition=label(gStatus,'Kondisi  100%',UDim2.fromOffset(14,68),UDim2.new(.48,0,0,20),11,false)
label(gStatus,'3 roda • 2 depan / 1 belakang',UDim2.new(.5,0,0,68),UDim2.new(.46,0,0,20),10,false,MUTED)
local gUpgrade=card(garage,160,155)
label(gUpgrade,'UPGRADE',UDim2.fromOffset(14,9),UDim2.new(1,-28,0,20),11,true,MUTED)
label(gUpgrade,'Motor',UDim2.fromOffset(14,38),UDim2.new(.45,0,0,20),12,true)
label(gUpgrade,'Naikkan kecepatan & akselerasi',UDim2.fromOffset(14,59),UDim2.new(1,-28,0,19),9,false,MUTED)
label(gUpgrade,'Baterai',UDim2.fromOffset(14,88),UDim2.new(.45,0,0,20),12,true)
label(gUpgrade,'Tambah kapasitas dan jarak tempuh',UDim2.fromOffset(14,109),UDim2.new(1,-28,0,19),9,false,MUTED)
label(gUpgrade,'Datang ke pad GARASI untuk membeli upgrade.',UDim2.fromOffset(14,132),UDim2.new(1,-28,0,18),9,true,Color3.fromRGB(227,179,89))
local gService=card(garage,330,90)
label(gService,'SERVIS & CHARGING',UDim2.fromOffset(14,9),UDim2.new(1,-28,0,20),11,true,MUTED)
label(gService,'Bengkel memperbaiki kondisi. Charging Station mengisi baterai sesuai kebutuhan.',UDim2.fromOffset(14,34),UDim2.new(1,-28,0,46),10,false,Color3.fromRGB(205,215,220))

-- PROFILE
local prof=card(profile,0,132)
label(prof,'DRIVER NUSAKARYA',UDim2.fromOffset(14,12),UDim2.new(1,-28,0,24),15,true)
local pMeta=label(prof,'LV 1  •  ★ 5.0',UDim2.fromOffset(14,41),UDim2.new(1,-28,0,20),11,false,MUTED)
local pTrips=label(prof,'Total Trip  0',UDim2.fromOffset(14,69),UDim2.new(.5,0,0,20),11,true)
local pMoney=label(prof,'Saldo  Rp 25.000',UDim2.fromOffset(14,95),UDim2.new(1,-28,0,20),11,true,Color3.fromRGB(117,239,148))
local storyCard=card(profile,146,126)
label(storyCard,'PROGRES STORY',UDim2.fromOffset(14,9),UDim2.new(1,-28,0,20),11,true,MUTED)
local pStory=label(storyCard,'Chapter 1 • Awal Perjalanan',UDim2.fromOffset(14,36),UDim2.new(1,-28,0,24),13,true)
label(storyCard,'Naikkan jumlah trip untuk membuka chapter berikutnya dan fitur baru.',UDim2.fromOffset(14,66),UDim2.new(1,-28,0,45),10,false,Color3.fromRGB(203,214,220))
local badges=card(profile,286,105)
label(badges,'PENCAPAIAN',UDim2.fromOffset(14,9),UDim2.new(1,-28,0,20),11,true,MUTED)
local badgeText=label(badges,'Pengemudi Baru  •  Eco Driver',UDim2.fromOffset(14,38),UDim2.new(1,-28,0,52),11,true)

-- NAV
local nav=Instance.new('Frame');nav.AnchorPoint=Vector2.new(0,1);nav.Position=UDim2.new(0,10,1,-10);nav.Size=UDim2.new(1,-20,0,54);nav.BackgroundColor3=Color3.fromRGB(18,23,27);nav.Parent=screen;corner(nav,14)
local navButtons={}
local defs={{'Beranda','HOME'},{'Peta','PETA'},{'Job','JOB'},{'Garasi','GARASI'},{'Profil','PROFIL'}}
for i,d in ipairs(defs) do
    local b=button(nav,d[2],UDim2.new((i-1)/5,4,0,5),UDim2.new(.2,-8,1,-10),i==1 and GREEN or Color3.fromRGB(29,35,39));b.TextSize=9;navButtons[d[1]]=b
end
local function setPage(name)
    currentPage=name
    for n,p in pairs(pages) do p.Visible=(n==name) end
    for n,b in pairs(navButtons) do b.BackgroundColor3=(n==name) and GREEN or Color3.fromRGB(29,35,39) end
end
for n,b in pairs(navButtons) do b.MouseButton1Click:Connect(function()setPage(n)end) end
hPassenger.MouseButton1Click:Connect(function()setPage('Job')end)
hCargo.MouseButton1Click:Connect(function()setPage('Job')end)
hGarage.MouseButton1Click:Connect(function()setPage('Garasi')end)
hMission.MouseButton1Click:Connect(function()setPage('Profil')end)

local function refreshObjective()
    local passenger=lastState.trip
    local cargo=player:GetAttribute('CargoDestination')
    if passenger and passenger~='' then
        objective.Text='Job  Antar ke '..tostring(passenger)
        mapObjective.Text='Antar penumpang ke '..tostring(passenger)
        return
    end
    if cargo and cargo~='' then
        objective.Text='Cargo  Antar ke '..tostring(cargo)
        mapObjective.Text='Antar cargo ke '..tostring(cargo)
        return
    end
    objective.Text='Job  Cari penumpang / cargo'
    mapObjective.Text='Belum ada perjalanan'
end

local function refreshMeta()
    weather.Text='Cuaca  '..tostring(Workspace:GetAttribute('BecakWeather') or 'CERAH')
    story.Text='Story  Chapter '..tostring(player:GetAttribute('StoryChapter') or 1)
    local c=player:GetAttribute('CargoDestination');activeCargo.Text='Cargo  '..(c or '—')
    sessionTarget.Text=tostring(player:GetAttribute('SessionTrips') or lastState.trips or 0)..' / 10 trip'
    pStory.Text='Chapter '..tostring(player:GetAttribute('StoryChapter') or 1)..' • '..(((player:GetAttribute('StoryChapter') or 1)==1) and 'Awal Perjalanan' or 'Perjalanan Berkembang')
    refreshObjective()
end

stateEvent.OnClientEvent:Connect(function(s)
    for k,v in pairs(s) do lastState[k]=v end
    money.Text=rupiah(s.coins)
    meta.Text='LV '..tostring(s.level or 1)..'  •  '..string.format('★ %.1f',s.reputation or 5)
    local max=math.max(1,s.batteryMax or 100);local pct=math.floor(((s.battery or 0)/max)*100)
    battery.Text='BATERAI '..pct..'%';trips.Text=tostring(s.trips or 0)..' trip'
    gMotor.Text='Motor  Level '..tostring(s.motorLevel or 1);gBattery.Text='Baterai  Level '..tostring(s.batteryLevel or 1)
    pMeta.Text='LV '..tostring(s.level or 1)..'  •  '..string.format('★ %.1f',s.reputation or 5)
    pTrips.Text='Total Trip  '..tostring(s.trips or 0);pMoney.Text='Saldo  '..rupiah(s.coins)
    refreshMeta()
end)

Workspace:GetAttributeChangedSignal('BecakWeather'):Connect(refreshMeta)
for _,n in ipairs({'StoryChapter','CargoDestination','SessionTrips'}) do player:GetAttributeChangedSignal(n):Connect(refreshMeta) end
refreshMeta()

local function polishBillboard(x)
    if x:IsA('BillboardGui') then x.MaxDistance=48;x.AlwaysOnTop=false end
end
if becakRoot then
    for _,x in ipairs(becakRoot:GetDescendants()) do polishBillboard(x) end
    becakRoot.DescendantAdded:Connect(polishBillboard)
end

-- Safe Area is the single source of truth for phone AnchorPoint, Position, Size and UIScale.
local function setOpen(v)
    phone.Visible=v
    launcher.Visible=not v
end
launcher.MouseButton1Click:Connect(function()setOpen(true)end)
close.MouseButton1Click:Connect(function()setOpen(false)end)

Workspace:SetAttribute('ACC_BecakPhoneUI','v1.8')
Workspace:SetAttribute('BecakPhoneCargoObjective','ON')
Workspace:SetAttribute('BecakPhoneObjectivePriority','PASSENGER_THEN_CARGO')
Workspace:SetAttribute('BecakPhoneLayoutOwner','SAFE_AREA')
Workspace:SetAttribute('BecakPhoneSelfScaling','OFF')
Workspace:SetAttribute('BecakPhonePositionTween','OFF')
Workspace:SetAttribute('BecakPhoneBillboardAuditScope','BECAK_ROOT')
Workspace:SetAttribute('BecakPhoneFullWorkspaceScan','OFF')