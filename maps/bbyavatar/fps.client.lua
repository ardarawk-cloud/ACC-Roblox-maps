-- BBYAVATAR FPS client v0.2: gunfeel, HUD, loadout, scoreboard and mobile controls
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Config = require(ReplicatedStorage:WaitForChild("FPSConfig"))
local Remotes = ReplicatedStorage:WaitForChild("FPSRemotes")
local Fire = Remotes:WaitForChild("Fire")
local Reload = Remotes:WaitForChild("Reload")
local Equip = Remotes:WaitForChild("Equip")
local State = Remotes:WaitForChild("State")
local FX = Remotes:WaitForChild("FX")

local oldGui = playerGui:FindFirstChild("FPS_HUD")
if oldGui then oldGui:Destroy() end
RunService:UnbindFromRenderStep("BBYAVATAR_FPS_CAMERA")

player.CameraMode = Enum.CameraMode.LockFirstPerson
UserInputService.MouseIconEnabled = false

local weaponKey = Config.Loadout[1]
local ammo = {}
local scores = {ALPHA = 0, BRAVO = 0}
local roundEndsAt = Workspace:GetServerTimeNow() + Config.RoundTime
local roundEnding = false
local triggerHeld = false
local adsHeld = false
local sprintHeld = false
local reloading = false
local loadoutOpen = false
local scoreboardOpen = false
local lastLocalShot = 0
local recoilPitch = 0
local recoilYaw = 0
local crossKick = 0
local swayTime = 0
local hitSerial = 0
local killfeedLines = {}
local lastHealth = Config.MaxHealth

local gui = Instance.new("ScreenGui")
gui.Name = "FPS_HUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 20
gui.Parent = playerGui

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function addStroke(parent, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(169,178,188)
    s.Transparency = transparency or 0.55
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function text(parent, name, size, pos, anchor, value, fontSize, alignment)
    local t = Instance.new("TextLabel")
    t.Name = name
    t.Size = size
    t.Position = pos
    t.AnchorPoint = anchor or Vector2.new(0,0)
    t.BackgroundTransparency = 1
    t.Text = value or ""
    t.TextColor3 = Color3.fromRGB(238,242,248)
    t.TextStrokeTransparency = 0.78
    t.Font = Enum.Font.GothamBold
    t.TextSize = fontSize or 18
    t.TextXAlignment = alignment or Enum.TextXAlignment.Left
    t.Parent = parent
    return t
end

local function panel(parent, name, size, pos, anchor, transparency)
    local f = Instance.new("Frame")
    f.Name = name
    f.Size = size
    f.Position = pos
    f.AnchorPoint = anchor or Vector2.new(0,0)
    f.BackgroundColor3 = Color3.fromRGB(14,18,24)
    f.BackgroundTransparency = transparency or 0.16
    f.BorderSizePixel = 0
    f.Parent = parent
    addCorner(f, 9)
    addStroke(f, 0.66, 1)
    return f
end

-- top match bar
local scoreBar = panel(gui,"ScoreBar",UDim2.fromOffset(410,54),UDim2.new(0.5,0,0,20),Vector2.new(0.5,0),0.12)
local alphaScore = text(scoreBar,"Alpha",UDim2.fromScale(0.32,1),UDim2.fromScale(0.025,0),nil,"ALPHA  0",17,Enum.TextXAlignment.Left)
alphaScore.TextColor3 = Color3.fromRGB(109,181,255)
local timerLabel = text(scoreBar,"Timer",UDim2.fromScale(0.36,0.58),UDim2.fromScale(0.32,0.05),nil,"08:00",18,Enum.TextXAlignment.Center)
local modeLabel = text(scoreBar,"Mode",UDim2.fromScale(0.36,0.35),UDim2.fromScale(0.32,0.58),nil,"TEAM DEATHMATCH",10,Enum.TextXAlignment.Center)
modeLabel.TextColor3 = Color3.fromRGB(176,184,195)
local bravoScore = text(scoreBar,"Bravo",UDim2.fromScale(0.32,1),UDim2.fromScale(0.655,0),nil,"0  BRAVO",17,Enum.TextXAlignment.Right)
bravoScore.TextColor3 = Color3.fromRGB(255,123,113)

-- weapon and health HUD
local weaponLabel = text(gui,"Weapon",UDim2.fromOffset(360,30),UDim2.new(1,-32,1,-124),Vector2.new(1,1),"AR-4 RIFLE",19,Enum.TextXAlignment.Right)
local weaponClass = text(gui,"WeaponClass",UDim2.fromOffset(360,20),UDim2.new(1,-32,1,-99),Vector2.new(1,1),"ASSAULT",11,Enum.TextXAlignment.Right)
weaponClass.TextColor3 = Color3.fromRGB(166,176,190)
local ammoLabel = text(gui,"Ammo",UDim2.fromOffset(360,58),UDim2.new(1,-32,1,-45),Vector2.new(1,1),"30 / 120",34,Enum.TextXAlignment.Right)
local statusLabel = text(gui,"Status",UDim2.fromOffset(460,38),UDim2.new(0.5,0,0.77,0),Vector2.new(0.5,0.5),"",20,Enum.TextXAlignment.Center)
local protectLabel = text(gui,"Protection",UDim2.fromOffset(300,24),UDim2.new(0.5,0,0.83,0),Vector2.new(0.5,0.5),"",13,Enum.TextXAlignment.Center)
protectLabel.TextColor3 = Color3.fromRGB(126,204,255)

local healthFrame = panel(gui,"HealthFrame",UDim2.fromOffset(230,18),UDim2.new(0,28,1,-42),Vector2.new(0,1),0.42)
local healthFill = Instance.new("Frame")
healthFill.Size = UDim2.fromScale(1,1)
healthFill.BackgroundColor3 = Color3.fromRGB(231,237,241)
healthFill.BorderSizePixel = 0
healthFill.Parent = healthFrame
addCorner(healthFill,7)
local healthText = text(gui,"Health",UDim2.fromOffset(230,28),UDim2.new(0,28,1,-48),Vector2.new(0,1),"100 HP",17,Enum.TextXAlignment.Left)

-- damage flash
local damageFlash = Instance.new("Frame")
damageFlash.Name = "DamageFlash"
damageFlash.Size = UDim2.fromScale(1,1)
damageFlash.BackgroundColor3 = Color3.fromRGB(170,24,24)
damageFlash.BackgroundTransparency = 1
damageFlash.BorderSizePixel = 0
damageFlash.ZIndex = -1
damageFlash.Parent = gui

-- killfeed
local killfeed = text(gui,"Killfeed",UDim2.fromOffset(460,130),UDim2.new(1,-24,0,88),Vector2.new(1,0),"",15,Enum.TextXAlignment.Right)
killfeed.TextYAlignment = Enum.TextYAlignment.Top

-- crosshair
local crosshair = Instance.new("Frame")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.fromOffset(80,80)
crosshair.Position = UDim2.fromScale(0.5,0.5)
crosshair.AnchorPoint = Vector2.new(0.5,0.5)
crosshair.BackgroundTransparency = 1
crosshair.Parent = gui
local crossLines = {}
local function crossLine(name,size)
    local f = Instance.new("Frame")
    f.Name = name
    f.Size = size
    f.AnchorPoint = Vector2.new(0.5,0.5)
    f.BackgroundColor3 = Color3.fromRGB(242,245,248)
    f.BorderSizePixel = 0
    f.Parent = crosshair
    crossLines[name] = f
    return f
end
crossLine("Top",UDim2.fromOffset(2,8))
crossLine("Bottom",UDim2.fromOffset(2,8))
crossLine("Left",UDim2.fromOffset(8,2))
crossLine("Right",UDim2.fromOffset(8,2))
local centerDot = crossLine("Dot",UDim2.fromOffset(2,2))

local hitmarker = Instance.new("TextLabel")
hitmarker.Name = "Hitmarker"
hitmarker.Size = UDim2.fromOffset(70,70)
hitmarker.Position = UDim2.fromScale(0.5,0.5)
hitmarker.AnchorPoint = Vector2.new(0.5,0.5)
hitmarker.BackgroundTransparency = 1
hitmarker.Font = Enum.Font.GothamBold
hitmarker.Text = "×"
hitmarker.TextSize = 45
hitmarker.TextColor3 = Color3.fromRGB(255,255,255)
hitmarker.TextTransparency = 1
hitmarker.Parent = gui

-- scoreboard
local scoreboard = panel(gui,"Scoreboard",UDim2.fromOffset(580,430),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5),0.07)
scoreboard.Visible = false
local sbTitle = text(scoreboard,"Title",UDim2.new(1,-36,0,52),UDim2.fromOffset(18,10),nil,"MATCH SCOREBOARD",22,Enum.TextXAlignment.Left)
local sbHint = text(scoreboard,"Hint",UDim2.new(1,-36,0,26),UDim2.fromOffset(18,48),nil,"PLAYER                              K        D        TEAM",12,Enum.TextXAlignment.Left)
sbHint.TextColor3 = Color3.fromRGB(164,174,186)
local sbRows = Instance.new("ScrollingFrame")
sbRows.Name = "Rows"
sbRows.Size = UDim2.new(1,-36,1,-92)
sbRows.Position = UDim2.fromOffset(18,78)
sbRows.BackgroundTransparency = 1
sbRows.BorderSizePixel = 0
sbRows.ScrollBarThickness = 4
sbRows.CanvasSize = UDim2.new()
sbRows.Parent = scoreboard
local sbLayout = Instance.new("UIListLayout")
sbLayout.Padding = UDim.new(0,4)
sbLayout.Parent = sbRows

local function rebuildScoreboard()
    for _, child in ipairs(sbRows:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    local list = Players:GetPlayers()
    table.sort(list,function(a,b)
        local ak = a:FindFirstChild("leaderstats") and a.leaderstats:FindFirstChild("Kills") and a.leaderstats.Kills.Value or 0
        local bk = b:FindFirstChild("leaderstats") and b.leaderstats:FindFirstChild("Kills") and b.leaderstats.Kills.Value or 0
        return ak > bk
    end)
    for _, p in ipairs(list) do
        local stats = p:FindFirstChild("leaderstats")
        local k = stats and stats:FindFirstChild("Kills") and stats.Kills.Value or 0
        local d = stats and stats:FindFirstChild("Deaths") and stats.Deaths.Value or 0
        local team = p.Team and p.Team.Name or "-"
        local row = text(sbRows,"Row_"..p.UserId,UDim2.new(1,-6,0,32),UDim2.new(),nil,string.format("%-30s   %3d     %3d      %s",p.DisplayName,k,d,team),14,Enum.TextXAlignment.Left)
        if team == "ALPHA" then row.TextColor3 = Color3.fromRGB(146,199,255) end
        if team == "BRAVO" then row.TextColor3 = Color3.fromRGB(255,158,149) end
    end
    sbRows.CanvasSize = UDim2.fromOffset(0, math.max(0,#list*36))
end

-- loadout panel
local loadout = panel(gui,"Loadout",UDim2.fromOffset(620,390),UDim2.fromScale(0.5,0.52),Vector2.new(0.5,0.5),0.06)
loadout.Visible = false
local loadoutTitle = text(loadout,"Title",UDim2.new(1,-40,0,48),UDim2.fromOffset(20,12),nil,"SELECT LOADOUT",24,Enum.TextXAlignment.Left)
local loadoutSub = text(loadout,"Sub",UDim2.new(1,-40,0,28),UDim2.fromOffset(20,54),nil,"Choose a weapon. Press L to close.",12,Enum.TextXAlignment.Left)
loadoutSub.TextColor3 = Color3.fromRGB(166,176,190)
local loadoutButtons = {}

local function closeMenus()
    loadoutOpen = false
    scoreboardOpen = false
    loadout.Visible = false
    scoreboard.Visible = false
end

local function setStatus(value,duration)
    statusLabel.Text = value or ""
    if duration then
        local mark = tostring(os.clock())
        statusLabel:SetAttribute("StatusMark",mark)
        task.delay(duration,function()
            if statusLabel:GetAttribute("StatusMark") == mark then statusLabel.Text = "" end
        end)
    end
end

local function currentCfg()
    return Config.Weapons[weaponKey]
end

local function updateAmmo()
    local a = ammo[weaponKey]
    if a then
        ammoLabel.Text = string.format("%02d / %03d",a.mag or 0,a.reserve or 0)
    else
        ammoLabel.Text = "-- / ---"
    end
    local cfg = currentCfg()
    if cfg then
        weaponLabel.Text = cfg.DisplayName
        weaponClass.Text = cfg.Class or ""
    end
end

local function updateScore()
    alphaScore.Text = "ALPHA  "..tostring(scores.ALPHA or 0)
    bravoScore.Text = tostring(scores.BRAVO or 0).."  BRAVO"
end

local function setWeapon(key)
    if not Config.Weapons[key] or roundEnding then return end
    weaponKey = key
    reloading = false
    adsHeld = false
    Equip:FireServer(key)
    updateAmmo()
    setStatus(Config.Weapons[key].DisplayName,0.6)
end

for i,key in ipairs(Config.Loadout) do
    local cfg = Config.Weapons[key]
    local b = Instance.new("TextButton")
    b.Name = key
    b.Size = UDim2.fromOffset(280,112)
    b.Position = UDim2.fromOffset(20 + ((i-1)%2)*300, 94 + math.floor((i-1)/2)*128)
    b.BackgroundColor3 = Color3.fromRGB(25,31,39)
    b.BackgroundTransparency = 0.08
    b.BorderSizePixel = 0
    b.Text = string.format("%s\n%s  •  %d DMG  •  %d RPM",cfg.DisplayName,cfg.Class or "WEAPON",cfg.Damage,cfg.RPM)
    b.TextColor3 = Color3.fromRGB(238,242,248)
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Font = Enum.Font.GothamBold
    b.TextSize = 15
    b.Parent = loadout
    addCorner(b,8)
    addStroke(b,0.58,1)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0,14)
    pad.Parent = b
    b.Activated:Connect(function()
        setWeapon(key)
        closeMenus()
    end)
    loadoutButtons[key] = b
end

local function toggleLoadout()
    loadoutOpen = not loadoutOpen
    scoreboardOpen = false
    scoreboard.Visible = false
    loadout.Visible = loadoutOpen
    if loadoutOpen then
        triggerHeld = false
        adsHeld = false
    end
end

local function toggleScoreboard(on)
    scoreboardOpen = on
    scoreboard.Visible = on
    if on then
        loadoutOpen = false
        loadout.Visible = false
        rebuildScoreboard()
    end
end

-- mobile controls
local mobile = UserInputService.TouchEnabled
local mobileFrame = Instance.new("Frame")
mobileFrame.Name = "MobileControls"
mobileFrame.Size = UDim2.fromScale(1,1)
mobileFrame.BackgroundTransparency = 1
mobileFrame.Visible = mobile
mobileFrame.Parent = gui

local function roundButton(name,label,size,pos)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.fromOffset(size,size)
    b.Position = pos
    b.AnchorPoint = Vector2.new(0.5,0.5)
    b.BackgroundColor3 = Color3.fromRGB(22,27,34)
    b.BackgroundTransparency = 0.2
    b.Text = label
    b.TextColor3 = Color3.fromRGB(245,247,250)
    b.Font = Enum.Font.GothamBold
    b.TextSize = math.floor(size*0.22)
    b.AutoButtonColor = true
    b.Parent = mobileFrame
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1,0) c.Parent = b
    addStroke(b,0.48,1)
    return b
end

local fireButton = roundButton("Fire","FIRE",104,UDim2.new(1,-86,1,-150))
local adsButton = roundButton("ADS","ADS",78,UDim2.new(1,-180,1,-238))
local reloadButton = roundButton("Reload","R",68,UDim2.new(1,-210,1,-132))
local swapButton = roundButton("Swap","SWAP",68,UDim2.new(1,-290,1,-195))
local sprintButton = roundButton("Sprint","RUN",72,UDim2.new(0,86,1,-160))
local loadoutButton = roundButton("Loadout","GUNS",72,UDim2.new(0,170,1,-225))

-- local viewmodel
local oldVm = Workspace.CurrentCamera and Workspace.CurrentCamera:FindFirstChild("FPS_ViewModel")
if oldVm then oldVm:Destroy() end
local vm = Instance.new("Model")
vm.Name = "FPS_ViewModel"
vm.Parent = Workspace.CurrentCamera

local function vmPart(name,size,color,material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = false
    p.Material = material or Enum.Material.Metal
    p.Color = color
    p.Parent = vm
    return p
end

local vmBody = vmPart("Receiver",Vector3.new(0.42,0.55,2.2),Color3.fromRGB(47,50,56))
local vmBarrel = vmPart("Barrel",Vector3.new(0.18,0.18,1.45),Color3.fromRGB(24,26,30))
local vmSight = vmPart("Sight",Vector3.new(0.28,0.19,0.44),Color3.fromRGB(32,35,39))
local vmStock = vmPart("Stock",Vector3.new(0.48,0.48,0.82),Color3.fromRGB(42,45,51))
local vmMag = vmPart("Magazine",Vector3.new(0.32,0.72,0.48),Color3.fromRGB(31,34,38))
local vmGrip = vmPart("Grip",Vector3.new(0.25,0.58,0.28),Color3.fromRGB(35,38,43))
local vmMuzzle = vmPart("MuzzleFlash",Vector3.new(0.16,0.16,0.16),Color3.fromRGB(255,214,126),Enum.Material.Neon)
vmMuzzle.Transparency = 1
local muzzleLight = Instance.new("PointLight")
muzzleLight.Color = Color3.fromRGB(255,204,116)
muzzleLight.Brightness = 0
muzzleLight.Range = 7
muzzleLight.Parent = vmMuzzle

local function flashMuzzle()
    vmMuzzle.Transparency = 0.05
    muzzleLight.Brightness = 2.4
    task.delay(0.035,function()
        if vmMuzzle.Parent then vmMuzzle.Transparency = 1 end
        if muzzleLight.Parent then muzzleLight.Brightness = 0 end
    end)
end

local function reload()
    local a = ammo[weaponKey]
    local cfg = currentCfg()
    if not a or not cfg or reloading or roundEnding or a.mag >= cfg.Magazine or a.reserve <= 0 then return end
    adsHeld = false
    triggerHeld = false
    Reload:FireServer()
end

local function setADS(on)
    if sprintHeld or reloading or loadoutOpen or scoreboardOpen or roundEnding then on = false end
    adsHeld = on
end

local function setSprint(on)
    if adsHeld or reloading or loadoutOpen or scoreboardOpen or roundEnding then on = false end
    sprintHeld = on
    if on then adsHeld = false end
    local ch = player.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = on and Config.SprintSpeed or Config.WalkSpeed end
end

local function movementAmount()
    local ch = player.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if not hum then return 0 end
    return math.clamp(hum.MoveDirection.Magnitude,0,1)
end

local function spreadDirection()
    local cfg = currentCfg()
    local move = movementAmount()
    local spread = adsHeld and cfg.SpreadADS or cfg.SpreadHip
    spread += (cfg.SpreadMove or 0) * move
    if sprintHeld then spread += cfg.SpreadSprint or 1 end
    local yaw = math.rad((math.random()-0.5)*2*spread)
    local pitch = math.rad((math.random()-0.5)*2*spread)
    local camera = Workspace.CurrentCamera
    return (camera.CFrame * CFrame.Angles(pitch,yaw,0)).LookVector
end

local function shootOnce()
    if loadoutOpen or scoreboardOpen or roundEnding or sprintHeld then return end
    local cfg = currentCfg()
    local a = ammo[weaponKey]
    if not cfg or not a or reloading then return end
    local now = os.clock()
    local interval = 60/cfg.RPM
    if now-lastLocalShot < interval then return end
    lastLocalShot = now
    if a.mag <= 0 then
        setStatus("RELOAD",0.35)
        return
    end

    local character = player.Character
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    local head = character and character:FindFirstChild("Head")
    if not hum or hum.Health <= 0 or not head then return end

    a.mag -= 1
    updateAmmo()
    Fire:FireServer({origin=head.Position,direction=spreadDirection()})

    local recoil = cfg.Recoil * (adsHeld and 0.68 or 1)
    recoilPitch += recoil * (0.82 + math.random()*0.32)
    recoilYaw += (math.random()-0.5) * recoil * 0.55
    crossKick = math.min(18,crossKick + (cfg.CrosshairKick or 3))
    flashMuzzle()
end

local function cycleWeapon()
    local idx = table.find(Config.Loadout,weaponKey) or 1
    idx = idx % #Config.Loadout + 1
    setWeapon(Config.Loadout[idx])
end

local function showHit(data)
    hitSerial += 1
    local serial = hitSerial
    hitmarker.TextColor3 = data and data.headshot and Color3.fromRGB(255,205,90) or Color3.fromRGB(255,255,255)
    hitmarker.TextTransparency = 0
    hitmarker.TextSize = data and data.killed and 56 or 45
    task.delay(0.1,function()
        if serial == hitSerial then
            TweenService:Create(hitmarker,TweenInfo.new(0.13),{TextTransparency=1}):Play()
        end
    end)
end

local function showKillfeed(data)
    local line = string.format("%s   ▸   %s",tostring(data.killer or "?"),tostring(data.victim or "?"))
    table.insert(killfeedLines,1,line)
    while #killfeedLines > 5 do table.remove(killfeedLines) end
    killfeed.Text = table.concat(killfeedLines,"\n")
    local snapshot = line
    task.delay(5,function()
        local index = table.find(killfeedLines,snapshot)
        if index then
            table.remove(killfeedLines,index)
            killfeed.Text = table.concat(killfeedLines,"\n")
        end
    end)
end

local function formatTime(seconds)
    seconds = math.max(0,math.floor(seconds+0.5))
    return string.format("%02d:%02d",math.floor(seconds/60),seconds%60)
end

-- keyboard and mouse
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        triggerHeld = true
        shootOnce()
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        setADS(true)
    elseif input.KeyCode == Enum.KeyCode.R then
        reload()
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        setSprint(true)
    elseif input.KeyCode == Enum.KeyCode.L then
        toggleLoadout()
    elseif input.KeyCode == Enum.KeyCode.Tab then
        toggleScoreboard(true)
    elseif input.KeyCode == Enum.KeyCode.One then setWeapon(Config.Loadout[1])
    elseif input.KeyCode == Enum.KeyCode.Two then setWeapon(Config.Loadout[2])
    elseif input.KeyCode == Enum.KeyCode.Three then setWeapon(Config.Loadout[3])
    elseif input.KeyCode == Enum.KeyCode.Four then setWeapon(Config.Loadout[4]) end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        triggerHeld = false
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        setADS(false)
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        setSprint(false)
    elseif input.KeyCode == Enum.KeyCode.Tab then
        toggleScoreboard(false)
    end
end)

-- mobile bindings
fireButton.MouseButton1Down:Connect(function() triggerHeld=true shootOnce() end)
fireButton.MouseButton1Up:Connect(function() triggerHeld=false end)
adsButton.MouseButton1Down:Connect(function() setADS(true) end)
adsButton.MouseButton1Up:Connect(function() setADS(false) end)
reloadButton.Activated:Connect(reload)
swapButton.Activated:Connect(cycleWeapon)
sprintButton.MouseButton1Down:Connect(function() setSprint(true) end)
sprintButton.MouseButton1Up:Connect(function() setSprint(false) end)
loadoutButton.Activated:Connect(toggleLoadout)

State.OnClientEvent:Connect(function(kind,data)
    if kind == "snapshot" then
        weaponKey = data.weapon or weaponKey
        ammo = data.ammo or ammo
        scores = data.scores or scores
        roundEndsAt = data.roundEndsAt or roundEndsAt
        roundEnding = data.roundEnding == true
        modeLabel.Text = data.mode or Config.Mode
        updateAmmo()
        updateScore()
    elseif kind == "ammo" and data.weapon == weaponKey then
        ammo[weaponKey] = ammo[weaponKey] or {}
        ammo[weaponKey].mag = data.mag
        ammo[weaponKey].reserve = data.reserve
        updateAmmo()
    elseif kind == "weapon" then
        weaponKey = data.weapon or weaponKey
        if data.ammo then ammo[weaponKey] = data.ammo end
        updateAmmo()
    elseif kind == "reload" and data.weapon == weaponKey then
        reloading = data.active == true
        if reloading then
            setADS(false)
            setSprint(false)
            setStatus("RELOADING")
        else
            setStatus("",0.1)
        end
    elseif kind == "hit" then
        showHit(data)
    elseif kind == "kill" then
        setStatus("ELIMINATION  •  STREAK "..tostring(data.streak or 1),0.75)
    elseif kind == "death" then
        triggerHeld = false
        setADS(false)
        setSprint(false)
        setStatus("ELIMINATED BY "..tostring(data.killer or "ENEMY"),1.4)
    elseif kind == "score" then
        scores = data.scores or scores
        roundEndsAt = data.roundEndsAt or roundEndsAt
        updateScore()
    elseif kind == "killfeed" then
        showKillfeed(data)
    elseif kind == "streak" then
        setStatus(string.format("%s  •  %d KILL STREAK",tostring(data.player),tonumber(data.count) or 0),1.2)
    elseif kind == "roundEnd" then
        roundEnding = true
        triggerHeld = false
        setADS(false)
        setSprint(false)
        closeMenus()
        setStatus("ROUND OVER  •  "..tostring(data.winner),math.max(1,(data.nextRoundIn or 6)-0.3))
    elseif kind == "roundStart" then
        roundEnding = false
        scores = data.scores or {ALPHA=0,BRAVO=0}
        roundEndsAt = data.roundEndsAt or (Workspace:GetServerTimeNow()+Config.RoundTime)
        updateScore()
        setStatus("ROUND "..tostring(data.round).."  •  FIGHT",1.2)
    elseif kind == "dry" then
        setStatus("EMPTY  •  RELOAD",0.45)
    end
end)

FX.OnClientEvent:Connect(function(kind,data)
    if kind ~= "shot" or type(data) ~= "table" or typeof(data.from) ~= "Vector3" or typeof(data.to) ~= "Vector3" then return end
    local delta = data.to-data.from
    local dist = delta.Magnitude
    if dist < 0.1 then return end
    local visible = math.min(dist,115)
    local tracer = Instance.new("Part")
    tracer.Name = "Tracer"
    tracer.Anchored = true
    tracer.CanCollide = false
    tracer.CanTouch = false
    tracer.CanQuery = false
    tracer.CastShadow = false
    tracer.Material = Enum.Material.Neon
    tracer.Color = Color3.fromRGB(236,224,166)
    tracer.Transparency = 0.2
    tracer.Size = Vector3.new(0.045,0.045,visible)
    local mid = data.from + delta.Unit*(visible*0.5)
    tracer.CFrame = CFrame.lookAt(mid,mid+delta.Unit)
    tracer.Parent = Workspace
    Debris:AddItem(tracer,0.055)
end)

local function bindCharacter(character)
    player.CameraMode = Enum.CameraMode.LockFirstPerson
    lastHealth = Config.MaxHealth
    local hum = character:WaitForChild("Humanoid",10)
    if not hum then return end

    local function updateHealth(h)
        local ratio = math.clamp(h/math.max(hum.MaxHealth,1),0,1)
        healthFill.Size = UDim2.fromScale(ratio,1)
        healthText.Text = string.format("%d HP",math.max(0,math.floor(h+0.5)))
        if h < lastHealth and h > 0 then
            damageFlash.BackgroundTransparency = 0.82
            TweenService:Create(damageFlash,TweenInfo.new(0.32),{BackgroundTransparency=1}):Play()
        end
        lastHealth = h
    end
    updateHealth(hum.Health)
    hum.HealthChanged:Connect(updateHealth)

    local function refreshProtection()
        protectLabel.Text = character:FindFirstChild("SpawnProtection") and "SPAWN PROTECTION" or ""
    end
    character.ChildAdded:Connect(function(child)
        if child.Name == "SpawnProtection" then refreshProtection() end
    end)
    character.ChildRemoved:Connect(function(child)
        if child.Name == "SpawnProtection" then refreshProtection() end
    end)
    refreshProtection()
end

player.CharacterAdded:Connect(bindCharacter)
if player.Character then bindCharacter(player.Character) end

local function positionCrosshair(gap)
    local center = 40
    crossLines.Top.Position = UDim2.fromOffset(center,center-gap)
    crossLines.Bottom.Position = UDim2.fromOffset(center,center+gap)
    crossLines.Left.Position = UDim2.fromOffset(center-gap,center)
    crossLines.Right.Position = UDim2.fromOffset(center+gap,center)
    centerDot.Position = UDim2.fromOffset(center,center)
end

RunService:BindToRenderStep("BBYAVATAR_FPS_CAMERA",Enum.RenderPriority.Camera.Value+1,function(dt)
    local camera = Workspace.CurrentCamera
    if not camera then return end
    if vm.Parent ~= camera then vm.Parent = camera end

    local cfg = currentCfg()
    if not cfg then return end
    if triggerHeld and cfg.Auto then shootOnce() end

    local move = movementAmount()
    swayTime += dt * (sprintHeld and 12 or 7)
    local swayX = math.sin(swayTime)*0.012*move
    local swayY = math.abs(math.cos(swayTime*0.5))*0.012*move

    local targetFov
    if sprintHeld then targetFov = 82
    elseif adsHeld then targetFov = cfg.ADSFOV
    else targetFov = cfg.FOV end
    camera.FieldOfView += (targetFov-camera.FieldOfView)*math.min(1,dt*12)

    camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(-recoilPitch),math.rad(recoilYaw),0)
    local recover = cfg.RecoilRecover or 9
    recoilPitch *= math.exp(-recover*dt)
    recoilYaw *= math.exp(-recover*1.15*dt)
    crossKick *= math.exp(-11*dt)

    local targetGap = 10 + move*4 + crossKick
    if sprintHeld then targetGap += 8 end
    positionCrosshair(targetGap)
    for _, line in pairs(crossLines) do line.Visible = not adsHeld end
    centerDot.Visible = not adsHeld

    local reloadDrop = reloading and 0.28 or 0
    local base
    if adsHeld then
        base = CFrame.new(0,-0.14-reloadDrop,-0.8)
    elseif sprintHeld then
        base = CFrame.new(0.68,-0.72,-0.92)*CFrame.Angles(0,0,math.rad(-20))
    else
        base = CFrame.new(0.48+swayX,-0.49-reloadDrop+swayY,-1.12)
    end

    local scale = weaponKey=="P12" and 0.78 or (weaponKey=="SM9" and 0.9 or (weaponKey=="DMR7" and 1.15 or 1))
    local cf = camera.CFrame*base
    vmBody.Size = Vector3.new(0.42*scale,0.55*scale,2.2*scale)
    vmBody.CFrame = cf
    vmBarrel.Size = Vector3.new(0.18*scale,0.18*scale,1.45*scale)
    vmBarrel.CFrame = cf*CFrame.new(0,0,-1.72*scale)
    vmSight.CFrame = cf*CFrame.new(0,0.35*scale,-0.18*scale)
    vmStock.CFrame = cf*CFrame.new(0,0,1.2*scale)
    vmMag.CFrame = cf*CFrame.new(0,-0.53*scale,0.2*scale)*CFrame.Angles(math.rad(8),0,0)
    vmGrip.CFrame = cf*CFrame.new(0,-0.52*scale,-0.58*scale)*CFrame.Angles(math.rad(-12),0,0)
    vmMuzzle.CFrame = cf*CFrame.new(0,0,-2.48*scale)

    timerLabel.Text = formatTime(roundEndsAt-Workspace:GetServerTimeNow())
end)

setWeapon(weaponKey)
updateScore()
positionCrosshair(10)
setStatus("TDM PROTOTYPE v0.2",1.5)
print("[BBYAVATAR FPS] Client v0.2 ready")
