-- ZONA PERANG FPS client v0.3.1
-- MOBILE_PLAYABILITY_RESCUE_V1
-- DEFAULT_ROBLOX_MOVEMENT_AND_JUMP: custom combat UI never occupies the native joystick/jump zones.
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
local mobile = UserInputService.TouchEnabled

local oldGui = playerGui:FindFirstChild("FPS_HUD")
if oldGui then oldGui:Destroy() end
local oldVm = Workspace.CurrentCamera and Workspace.CurrentCamera:FindFirstChild("FPS_ViewModel")
if oldVm then oldVm:Destroy() end
RunService:UnbindFromRenderStep("ZONA_PERANG_CAMERA")
RunService:UnbindFromRenderStep("BBYAVATAR_FPS_CAMERA")

local function applyCameraPolicy()
    player.CameraMode = Enum.CameraMode.Classic
    player.CameraMinZoomDistance = 0.5
    player.CameraMaxZoomDistance = 14
end
applyCameraPolicy()
if not mobile then UserInputService.MouseIconEnabled = false end

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
local lastLocalShot = 0
local lastHealth = Config.MaxHealth
local killfeedLines = {}

local gui = Instance.new("ScreenGui")
gui.Name = "FPS_HUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 20
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui:SetAttribute("LayoutAuthority", "MOBILE_PLAYABILITY_RESCUE_V1")
gui.Parent = playerGui

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
end

local function stroke(parent, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(185, 193, 203)
    s.Transparency = transparency or 0.55
    s.Thickness = thickness or 1
    s.Parent = parent
end

local function makeText(parent, name, size, pos, anchor, value, textSize, align)
    local t = Instance.new("TextLabel")
    t.Name = name
    t.Size = size
    t.Position = pos
    t.AnchorPoint = anchor or Vector2.new(0, 0)
    t.BackgroundTransparency = 1
    t.Text = value or ""
    t.TextColor3 = Color3.fromRGB(244, 247, 250)
    t.TextStrokeTransparency = 0.75
    t.Font = Enum.Font.GothamBold
    t.TextSize = textSize or 16
    t.TextXAlignment = align or Enum.TextXAlignment.Left
    t.Parent = parent
    return t
end

local function makePanel(parent, name, size, pos, anchor, transparency)
    local f = Instance.new("Frame")
    f.Name = name
    f.Size = size
    f.Position = pos
    f.AnchorPoint = anchor or Vector2.new(0, 0)
    f.BackgroundColor3 = Color3.fromRGB(13, 18, 24)
    f.BackgroundTransparency = transparency or 0.14
    f.BorderSizePixel = 0
    f.Parent = parent
    corner(f, 9)
    stroke(f, 0.7, 1)
    return f
end

-- Compact HUD. Nothing is placed in the native bottom-left joystick or bottom-right jump zones.
local scoreBar = makePanel(gui, "ScoreBar", mobile and UDim2.new(0.54,0,0,46) or UDim2.fromOffset(420,54), mobile and UDim2.new(0.5,0,0,8) or UDim2.new(0.5,0,0,18), Vector2.new(0.5,0), 0.12)
local alphaScore = makeText(scoreBar, "Alpha", UDim2.fromScale(0.31,1), UDim2.fromScale(0.03,0), nil, "ALPHA  0", mobile and 13 or 16, Enum.TextXAlignment.Left)
alphaScore.TextColor3 = Color3.fromRGB(112, 184, 255)
local timerLabel = makeText(scoreBar, "Timer", UDim2.fromScale(0.38,0.60), UDim2.fromScale(0.31,0.03), nil, "08:00", mobile and 16 or 18, Enum.TextXAlignment.Center)
local modeLabel = makeText(scoreBar, "Mode", UDim2.fromScale(0.38,0.32), UDim2.fromScale(0.31,0.62), nil, "TEAM DEATHMATCH", mobile and 8 or 10, Enum.TextXAlignment.Center)
modeLabel.TextColor3 = Color3.fromRGB(176, 184, 194)
local bravoScore = makeText(scoreBar, "Bravo", UDim2.fromScale(0.31,1), UDim2.fromScale(0.66,0), nil, "0  BRAVO", mobile and 13 or 16, Enum.TextXAlignment.Right)
bravoScore.TextColor3 = Color3.fromRGB(255, 127, 118)

local healthText = makeText(gui, "Health", UDim2.fromOffset(150,24), mobile and UDim2.new(0,18,0,86) or UDim2.new(0,28,1,-52), nil, "100 HP", mobile and 13 or 16, Enum.TextXAlignment.Left)
local healthBar = makePanel(gui, "HealthBar", UDim2.fromOffset(mobile and 155 or 220, mobile and 12 or 16), mobile and UDim2.new(0,18,0,112) or UDim2.new(0,28,1,-30), mobile and Vector2.new(0,0) or Vector2.new(0,1), 0.5)
local healthFill = Instance.new("Frame")
healthFill.Size = UDim2.fromScale(1,1)
healthFill.BackgroundColor3 = Color3.fromRGB(235, 239, 242)
healthFill.BorderSizePixel = 0
healthFill.Parent = healthBar
corner(healthFill, 6)

local weaponLabel = makeText(gui, "Weapon", UDim2.fromOffset(230,24), mobile and UDim2.new(1,-18,0,78) or UDim2.new(1,-30,1,-112), Vector2.new(1,0), "AR-4 RIFLE", mobile and 14 or 18, Enum.TextXAlignment.Right)
local weaponClass = makeText(gui, "WeaponClass", UDim2.fromOffset(230,18), mobile and UDim2.new(1,-18,0,101) or UDim2.new(1,-30,1,-88), Vector2.new(1,0), "ASSAULT", mobile and 9 or 10, Enum.TextXAlignment.Right)
weaponClass.TextColor3 = Color3.fromRGB(174, 183, 194)
local ammoLabel = makeText(gui, "Ammo", UDim2.fromOffset(230,34), mobile and UDim2.new(1,-18,0,119) or UDim2.new(1,-30,1,-64), Vector2.new(1,0), "30 / 120", mobile and 23 or 31, Enum.TextXAlignment.Right)

local statusLabel = makeText(gui, "Status", mobile and UDim2.new(0.52,0,0,30) or UDim2.fromOffset(480,34), UDim2.new(0.5,0,0.72,0), Vector2.new(0.5,0.5), "", mobile and 14 or 18, Enum.TextXAlignment.Center)
local protectLabel = makeText(gui, "Protection", UDim2.fromOffset(280,22), UDim2.new(0.5,0,0.77,0), Vector2.new(0.5,0.5), "", mobile and 10 or 12, Enum.TextXAlignment.Center)
protectLabel.TextColor3 = Color3.fromRGB(125, 203, 255)

local damageFlash = Instance.new("Frame")
damageFlash.Name = "DamageFlash"
damageFlash.Size = UDim2.fromScale(1,1)
damageFlash.BackgroundColor3 = Color3.fromRGB(165, 25, 25)
damageFlash.BackgroundTransparency = 1
damageFlash.BorderSizePixel = 0
damageFlash.ZIndex = 1
damageFlash.Parent = gui

local killfeed = makeText(gui, "Killfeed", mobile and UDim2.fromOffset(280,74) or UDim2.fromOffset(430,120), mobile and UDim2.new(1,-18,0,164) or UDim2.new(1,-24,0,88), Vector2.new(1,0), "", mobile and 11 or 14, Enum.TextXAlignment.Right)
killfeed.TextYAlignment = Enum.TextYAlignment.Top

local crosshair = Instance.new("TextLabel")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.fromOffset(42,42)
crosshair.Position = UDim2.fromScale(0.5,0.5)
crosshair.AnchorPoint = Vector2.new(0.5,0.5)
crosshair.BackgroundTransparency = 1
crosshair.Text = "+"
crosshair.TextColor3 = Color3.fromRGB(244,247,250)
crosshair.TextStrokeTransparency = 0.65
crosshair.Font = Enum.Font.GothamBold
crosshair.TextSize = mobile and 26 or 30
crosshair.ZIndex = 5
crosshair.Parent = gui

local hitmarker = makeText(gui, "Hitmarker", UDim2.fromOffset(60,60), UDim2.fromScale(0.5,0.5), Vector2.new(0.5,0.5), "×", 44, Enum.TextXAlignment.Center)
hitmarker.TextTransparency = 1
hitmarker.ZIndex = 6

local function setStatus(value, duration)
    statusLabel.Text = value or ""
    if duration then
        local mark = tostring(os.clock())
        statusLabel:SetAttribute("Mark", mark)
        task.delay(duration, function()
            if statusLabel:GetAttribute("Mark") == mark then statusLabel.Text = "" end
        end)
    end
end

local function currentCfg()
    return Config.Weapons[weaponKey]
end

local function updateScore()
    alphaScore.Text = "ALPHA  " .. tostring(scores.ALPHA or 0)
    bravoScore.Text = tostring(scores.BRAVO or 0) .. "  BRAVO"
end

local function updateAmmo()
    local a = ammo[weaponKey]
    local cfg = currentCfg()
    if cfg then
        weaponLabel.Text = cfg.DisplayName
        weaponClass.Text = cfg.Class or ""
    end
    if a then
        ammoLabel.Text = string.format("%02d / %03d", a.mag or 0, a.reserve or 0)
    else
        ammoLabel.Text = "-- / ---"
    end
end

local function setWeapon(key)
    if roundEnding or not Config.Weapons[key] then return end
    weaponKey = key
    reloading = false
    adsHeld = false
    Equip:FireServer(key)
    updateAmmo()
    setStatus(Config.Weapons[key].DisplayName, 0.55)
end

-- Small loadout strip, never a fullscreen modal.
local loadoutStrip = makePanel(gui, "LoadoutStrip", mobile and UDim2.fromOffset(356,70) or UDim2.fromOffset(500,78), mobile and UDim2.new(0.5,0,0.27,0) or UDim2.new(0.5,0,0.18,0), Vector2.new(0.5,0.5), 0.08)
loadoutStrip.Visible = false
local stripLayout = Instance.new("UIListLayout")
stripLayout.FillDirection = Enum.FillDirection.Horizontal
stripLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
stripLayout.VerticalAlignment = Enum.VerticalAlignment.Center
stripLayout.Padding = UDim.new(0,6)
stripLayout.Parent = loadoutStrip

for _, key in ipairs(Config.Loadout) do
    local cfg = Config.Weapons[key]
    local b = Instance.new("TextButton")
    b.Name = "Loadout_" .. key
    b.Size = mobile and UDim2.fromOffset(80,52) or UDim2.fromOffset(112,58)
    b.BackgroundColor3 = Color3.fromRGB(25,31,39)
    b.BackgroundTransparency = 0.06
    b.BorderSizePixel = 0
    b.Text = cfg.DisplayName
    b.TextWrapped = true
    b.TextColor3 = Color3.fromRGB(241,244,248)
    b.Font = Enum.Font.GothamBold
    b.TextSize = mobile and 10 or 12
    b.Parent = loadoutStrip
    corner(b,7)
    stroke(b,0.6,1)
    b.Activated:Connect(function()
        setWeapon(key)
        loadoutOpen = false
        loadoutStrip.Visible = false
    end)
end

local function toggleLoadout()
    loadoutOpen = not loadoutOpen
    loadoutStrip.Visible = loadoutOpen
    triggerHeld = false
    if loadoutOpen then adsHeld = false end
end

-- MOBILE COMBAT CONTROLS. Native joystick and jump corners are deliberately empty.
local mobileFrame = Instance.new("Frame")
mobileFrame.Name = "MobileCombatControls"
mobileFrame.Size = UDim2.fromScale(1,1)
mobileFrame.BackgroundTransparency = 1
mobileFrame.Active = false
mobileFrame.Visible = mobile
mobileFrame.Parent = gui

local function roundButton(name, label, size, pos)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.fromOffset(size,size)
    b.Position = pos
    b.AnchorPoint = Vector2.new(0.5,0.5)
    b.BackgroundColor3 = Color3.fromRGB(18,24,31)
    b.BackgroundTransparency = 0.18
    b.BorderSizePixel = 0
    b.Text = label
    b.TextColor3 = Color3.fromRGB(245,248,250)
    b.Font = Enum.Font.GothamBold
    b.TextSize = math.floor(size * 0.20)
    b.Parent = mobileFrame
    corner(b, size)
    stroke(b,0.48,1)
    return b
end

local fireButton = roundButton("Fire", "FIRE", 72, UDim2.fromScale(0.86,0.50))
local adsButton = roundButton("ADS", "ADS", 54, UDim2.fromScale(0.76,0.42))
local reloadButton = roundButton("Reload", "R", 48, UDim2.fromScale(0.88,0.65))
local swapButton = roundButton("Swap", "SWAP", 48, UDim2.fromScale(0.76,0.60))
local gunsButton = roundButton("Guns", "GUNS", 48, UDim2.fromScale(0.66,0.69))
-- Intentionally no RUN button on mobile P0; native movement must remain unobstructed.

local function setADS(on)
    if reloading or roundEnding or loadoutOpen then on = false end
    adsHeld = on
    if mobile then adsButton.Text = adsHeld and "ADS ON" or "ADS" end
end

local function setSprint(on)
    if mobile then return end
    if adsHeld or reloading or roundEnding then on = false end
    sprintHeld = on
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = on and Config.SprintSpeed or Config.WalkSpeed end
end

local function reload()
    local cfg = currentCfg()
    local a = ammo[weaponKey]
    if not cfg or not a or reloading or roundEnding or a.mag >= cfg.Magazine or a.reserve <= 0 then return end
    triggerHeld = false
    setADS(false)
    Reload:FireServer()
end

local function movementAmount()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and math.clamp(hum.MoveDirection.Magnitude,0,1) or 0
end

local function spreadDirection()
    local cfg = currentCfg()
    local camera = Workspace.CurrentCamera
    if not cfg or not camera then return Vector3.new(0,0,-1) end
    local spread = adsHeld and cfg.SpreadADS or cfg.SpreadHip
    spread += (cfg.SpreadMove or 0) * movementAmount()
    local yaw = math.rad((math.random()-0.5) * 2 * spread)
    local pitch = math.rad((math.random()-0.5) * 2 * spread)
    return (camera.CFrame * CFrame.Angles(pitch,yaw,0)).LookVector
end

local muzzleFlashToken = 0
local function flashCrosshair()
    muzzleFlashToken += 1
    local token = muzzleFlashToken
    crosshair.TextColor3 = Color3.fromRGB(255,221,145)
    task.delay(0.045,function()
        if token == muzzleFlashToken then crosshair.TextColor3 = Color3.fromRGB(244,247,250) end
    end)
end

local function shootOnce()
    if roundEnding or reloading or loadoutOpen or sprintHeld then return end
    local cfg = currentCfg()
    local a = ammo[weaponKey]
    if not cfg or not a then return end
    local now = os.clock()
    local interval = 60 / cfg.RPM
    if now - lastLocalShot < interval then return end
    lastLocalShot = now
    if (a.mag or 0) <= 0 then
        setStatus("EMPTY • RELOAD", 0.5)
        return
    end
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local head = char and char:FindFirstChild("Head")
    if not hum or hum.Health <= 0 or not head then return end
    a.mag -= 1
    updateAmmo()
    Fire:FireServer({origin = head.Position, direction = spreadDirection()})
    flashCrosshair()
end

local function cycleWeapon()
    local index = table.find(Config.Loadout, weaponKey) or 1
    index = index % #Config.Loadout + 1
    setWeapon(Config.Loadout[index])
end

fireButton.MouseButton1Down:Connect(function()
    triggerHeld = true
    shootOnce()
end)
fireButton.MouseButton1Up:Connect(function() triggerHeld = false end)
adsButton.Activated:Connect(function() setADS(not adsHeld) end)
reloadButton.Activated:Connect(reload)
swapButton.Activated:Connect(cycleWeapon)
gunsButton.Activated:Connect(toggleLoadout)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
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
    end
end)

local function showHit(data)
    hitmarker.TextColor3 = data and data.headshot and Color3.fromRGB(255,207,91) or Color3.fromRGB(255,255,255)
    hitmarker.TextTransparency = 0
    hitmarker.TextSize = data and data.killed and 54 or 44
    TweenService:Create(hitmarker, TweenInfo.new(0.18), {TextTransparency = 1}):Play()
end

local function showKillfeed(data)
    local line = string.format("%s  ▸  %s", tostring(data.killer or "?"), tostring(data.victim or "?"))
    table.insert(killfeedLines, 1, line)
    while #killfeedLines > (mobile and 3 or 5) do table.remove(killfeedLines) end
    killfeed.Text = table.concat(killfeedLines, "\n")
    task.delay(5, function()
        local i = table.find(killfeedLines, line)
        if i then table.remove(killfeedLines, i) killfeed.Text = table.concat(killfeedLines, "\n") end
    end)
end

State.OnClientEvent:Connect(function(kind, data)
    data = data or {}
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
        if reloading then setADS(false) setStatus("RELOADING") else setStatus("",0.05) end
    elseif kind == "hit" then
        showHit(data)
    elseif kind == "kill" then
        setStatus("ELIMINATION • STREAK " .. tostring(data.streak or 1), 0.8)
    elseif kind == "death" then
        triggerHeld = false
        setADS(false)
        setStatus("ELIMINATED BY " .. tostring(data.killer or "ENEMY"), 1.2)
    elseif kind == "spawnSafe" then
        triggerHeld = false
        setADS(false)
        setStatus("DEPLOYED", 0.7)
    elseif kind == "score" then
        scores = data.scores or scores
        roundEndsAt = data.roundEndsAt or roundEndsAt
        updateScore()
    elseif kind == "killfeed" then
        showKillfeed(data)
    elseif kind == "streak" then
        setStatus(string.format("%s • %d KILL STREAK", tostring(data.player), tonumber(data.count) or 0), 1.0)
    elseif kind == "roundEnd" then
        roundEnding = true
        triggerHeld = false
        setADS(false)
        setStatus("ROUND OVER • " .. tostring(data.winner), math.max(1, (data.nextRoundIn or 6)-0.3))
    elseif kind == "roundStart" then
        roundEnding = false
        scores = data.scores or {ALPHA=0,BRAVO=0}
        roundEndsAt = data.roundEndsAt or (Workspace:GetServerTimeNow()+Config.RoundTime)
        updateScore()
        setStatus("FIGHT", 0.8)
    elseif kind == "dry" then
        setStatus("EMPTY • RELOAD", 0.5)
    end
end)

FX.OnClientEvent:Connect(function(kind, data)
    if kind ~= "shot" or typeof(data) ~= "table" or typeof(data.from) ~= "Vector3" or typeof(data.to) ~= "Vector3" then return end
    local delta = data.to - data.from
    local dist = delta.Magnitude
    if dist < 0.2 then return end
    local visible = math.min(dist, 90)
    local tracer = Instance.new("Part")
    tracer.Name = "Tracer"
    tracer.Anchored = true
    tracer.CanCollide = false
    tracer.CanTouch = false
    tracer.CanQuery = false
    tracer.CastShadow = false
    tracer.Material = Enum.Material.Neon
    tracer.Color = Color3.fromRGB(240,225,166)
    tracer.Transparency = 0.28
    tracer.Size = Vector3.new(0.04,0.04,visible)
    local mid = data.from + delta.Unit * (visible * 0.5)
    tracer.CFrame = CFrame.lookAt(mid, mid + delta.Unit)
    tracer.Parent = Workspace
    Debris:AddItem(tracer, 0.05)
end)

-- Small first-person-only viewmodel. It disappears automatically when the user zooms out.
local vm = Instance.new("Model")
vm.Name = "FPS_ViewModel"
vm.Parent = Workspace.CurrentCamera
local function vmPart(name, size, color)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = false
    p.Material = Enum.Material.Metal
    p.Color = color
    p.Parent = vm
    return p
end
local vmBody = vmPart("Receiver", Vector3.new(0.34,0.40,1.55), Color3.fromRGB(45,48,54))
local vmBarrel = vmPart("Barrel", Vector3.new(0.12,0.12,0.95), Color3.fromRGB(23,25,29))
local vmGrip = vmPart("Grip", Vector3.new(0.20,0.45,0.22), Color3.fromRGB(33,36,41))
local vmParts = {vmBody, vmBarrel, vmGrip}

local function bindCharacter(character)
    applyCameraPolicy()
    lastHealth = Config.MaxHealth
    local hum = character:WaitForChild("Humanoid",10)
    if not hum then return end
    local function updateHealth(h)
        local ratio = math.clamp(h / math.max(hum.MaxHealth,1), 0, 1)
        healthFill.Size = UDim2.fromScale(ratio,1)
        healthText.Text = string.format("%d HP", math.max(0, math.floor(h+0.5)))
        if h < lastHealth and h > 0 then
            damageFlash.BackgroundTransparency = 0.84
            TweenService:Create(damageFlash, TweenInfo.new(0.30), {BackgroundTransparency=1}):Play()
        end
        lastHealth = h
    end
    updateHealth(hum.Health)
    hum.HealthChanged:Connect(updateHealth)
    local function refreshProtection()
        protectLabel.Text = character:FindFirstChild("SpawnProtection") and "SPAWN PROTECTION" or ""
    end
    character.ChildAdded:Connect(function(child) if child.Name == "SpawnProtection" then refreshProtection() end end)
    character.ChildRemoved:Connect(function(child) if child.Name == "SpawnProtection" then refreshProtection() end end)
    refreshProtection()
end

player.CharacterAdded:Connect(bindCharacter)
if player.Character then bindCharacter(player.Character) end

RunService:BindToRenderStep("ZONA_PERANG_CAMERA", Enum.RenderPriority.Camera.Value + 1, function(dt)
    local camera = Workspace.CurrentCamera
    if not camera then return end
    if vm.Parent ~= camera then vm.Parent = camera end
    local cfg = currentCfg()
    if not cfg then return end
    if triggerHeld and cfg.Auto then shootOnce() end

    local targetFov = adsHeld and cfg.ADSFOV or cfg.FOV
    camera.FieldOfView += (targetFov - camera.FieldOfView) * math.min(1, dt * 10)

    local char = player.Character
    local head = char and char:FindFirstChild("Head")
    local firstPerson = head and (camera.CFrame.Position - head.Position).Magnitude < 1.35
    local visibility = firstPerson and 0 or 1
    for _, p in ipairs(vmParts) do p.Transparency = visibility end
    crosshair.Visible = not loadoutOpen

    if firstPerson then
        local base = camera.CFrame * CFrame.new(0.43, -0.43, -1.18)
        vmBody.CFrame = base
        vmBarrel.CFrame = base * CFrame.new(0,0,-1.17)
        vmGrip.CFrame = base * CFrame.new(0,-0.34,0.22)
    end

    timerLabel.Text = string.format("%02d:%02d", math.floor(math.max(0,roundEndsAt-Workspace:GetServerTimeNow())/60), math.floor(math.max(0,roundEndsAt-Workspace:GetServerTimeNow()))%60)
end)

print("[ZONA PERANG] MOBILE_PLAYABILITY_RESCUE_V1 ready — default movement/jump + zoomable camera")
