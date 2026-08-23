-- BBYAVATAR FPS client: first-person controls, HUD, mobile controls, recoil and tracers
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local Config = require(ReplicatedStorage:WaitForChild("FPSConfig"))
local Remotes = ReplicatedStorage:WaitForChild("FPSRemotes")
local Fire = Remotes:WaitForChild("Fire")
local Reload = Remotes:WaitForChild("Reload")
local Equip = Remotes:WaitForChild("Equip")
local State = Remotes:WaitForChild("State")
local FX = Remotes:WaitForChild("FX")

player.CameraMode = Enum.CameraMode.LockFirstPerson
UserInputService.MouseIconEnabled = false

local weaponKey = Config.Loadout[1]
local ammo = {}
local scores = {ALPHA = 0, BRAVO = 0}
local triggerHeld = false
local adsHeld = false
local sprintHeld = false
local reloading = false
local lastLocalShot = 0
local hitSerial = 0
local killfeedSerial = 0

local gui = Instance.new("ScreenGui")
gui.Name = "FPS_HUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local function text(parent, name, size, pos, anchor, value, fontSize, alignment)
    local t = Instance.new("TextLabel")
    t.Name = name
    t.Size = size
    t.Position = pos
    t.AnchorPoint = anchor or Vector2.new(0,0)
    t.BackgroundTransparency = 1
    t.Text = value or ""
    t.TextColor3 = Color3.fromRGB(238,242,248)
    t.TextStrokeTransparency = 0.72
    t.Font = Enum.Font.GothamBold
    t.TextSize = fontSize or 18
    t.TextXAlignment = alignment or Enum.TextXAlignment.Left
    t.Parent = parent
    return t
end

local scoreBar = Instance.new("Frame")
scoreBar.Name = "ScoreBar"
scoreBar.Size = UDim2.fromOffset(330, 48)
scoreBar.Position = UDim2.new(0.5, 0, 0, 22)
scoreBar.AnchorPoint = Vector2.new(0.5, 0)
scoreBar.BackgroundColor3 = Color3.fromRGB(16,20,26)
scoreBar.BackgroundTransparency = 0.16
scoreBar.BorderSizePixel = 0
scoreBar.Parent = gui
local scoreCorner = Instance.new("UICorner")
scoreCorner.CornerRadius = UDim.new(0,8)
scoreCorner.Parent = scoreBar

local alphaScore = text(scoreBar,"Alpha",UDim2.fromScale(0.38,1),UDim2.fromScale(0.02,0),nil,"ALPHA  0",17,Enum.TextXAlignment.Left)
alphaScore.TextColor3 = Color3.fromRGB(109,181,255)
local modeLabel = text(scoreBar,"Mode",UDim2.fromScale(0.24,1),UDim2.fromScale(0.38,0),nil,"TDM",15,Enum.TextXAlignment.Center)
modeLabel.TextColor3 = Color3.fromRGB(196,203,212)
local bravoScore = text(scoreBar,"Bravo",UDim2.fromScale(0.38,1),UDim2.fromScale(0.60,0),nil,"0  BRAVO",17,Enum.TextXAlignment.Right)
bravoScore.TextColor3 = Color3.fromRGB(255,123,113)

local weaponLabel = text(gui,"Weapon",UDim2.fromOffset(320,30),UDim2.new(1,-32,1,-118),Vector2.new(1,1),"AR-4 RIFLE",19,Enum.TextXAlignment.Right)
local ammoLabel = text(gui,"Ammo",UDim2.fromOffset(320,56),UDim2.new(1,-32,1,-58),Vector2.new(1,1),"30 / 120",34,Enum.TextXAlignment.Right)
local statusLabel = text(gui,"Status",UDim2.fromOffset(300,28),UDim2.new(0.5,0,0.78,0),Vector2.new(0.5,0.5),"",18,Enum.TextXAlignment.Center)
local killfeed = text(gui,"Killfeed",UDim2.fromOffset(430,120),UDim2.new(1,-24,0,82),Vector2.new(1,0),"",15,Enum.TextXAlignment.Right)
killfeed.TextYAlignment = Enum.TextYAlignment.Top

local healthFrame = Instance.new("Frame")
healthFrame.Size = UDim2.fromOffset(220, 16)
healthFrame.Position = UDim2.new(0,28,1,-46)
healthFrame.AnchorPoint = Vector2.new(0,1)
healthFrame.BackgroundColor3 = Color3.fromRGB(31,34,39)
healthFrame.BorderSizePixel = 0
healthFrame.Parent = gui
local healthFill = Instance.new("Frame")
healthFill.Size = UDim2.fromScale(1,1)
healthFill.BackgroundColor3 = Color3.fromRGB(231,237,241)
healthFill.BorderSizePixel = 0
healthFill.Parent = healthFrame
local healthText = text(gui,"Health",UDim2.fromOffset(220,26),UDim2.new(0,28,1,-50),Vector2.new(0,1),"100 HP",17,Enum.TextXAlignment.Left)

local crosshair = Instance.new("Frame")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.fromOffset(42,42)
crosshair.Position = UDim2.fromScale(0.5,0.5)
crosshair.AnchorPoint = Vector2.new(0.5,0.5)
crosshair.BackgroundTransparency = 1
crosshair.Parent = gui
local crossLines = {}
local function crossLine(name,size,pos)
    local f = Instance.new("Frame")
    f.Name = name
    f.Size = size
    f.Position = pos
    f.AnchorPoint = Vector2.new(0.5,0.5)
    f.BackgroundColor3 = Color3.fromRGB(242,245,248)
    f.BorderSizePixel = 0
    f.Parent = crosshair
    crossLines[#crossLines+1] = f
end
crossLine("Top",UDim2.fromOffset(2,8),UDim2.fromOffset(21,8))
crossLine("Bottom",UDim2.fromOffset(2,8),UDim2.fromOffset(21,34))
crossLine("Left",UDim2.fromOffset(8,2),UDim2.fromOffset(8,21))
crossLine("Right",UDim2.fromOffset(8,2),UDim2.fromOffset(34,21))

local hitmarker = Instance.new("TextLabel")
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
    b.TextSize = math.floor(size*0.24)
    b.AutoButtonColor = true
    b.Parent = mobileFrame
    local c=Instance.new("UICorner") c.CornerRadius=UDim.new(1,0) c.Parent=b
    local stroke=Instance.new("UIStroke") stroke.Thickness=1 stroke.Transparency=0.45 stroke.Parent=b
    return b
end

local fireButton = roundButton("Fire","FIRE",104,UDim2.new(1,-86,1,-150))
local adsButton = roundButton("ADS","ADS",78,UDim2.new(1,-180,1,-238))
local reloadButton = roundButton("Reload","R",68,UDim2.new(1,-210,1,-132))
local swapButton = roundButton("Swap","SWAP",68,UDim2.new(1,-290,1,-195))
local sprintButton = roundButton("Sprint","RUN",72,UDim2.new(0,86,1,-160))

local vm = Instance.new("Model")
vm.Name = "FPS_ViewModel"
vm.Parent = camera
local vmBody = Instance.new("Part")
vmBody.Name = "Body"
vmBody.Anchored = true
vmBody.CanCollide = false
vmBody.CanTouch = false
vmBody.CastShadow = false
vmBody.Material = Enum.Material.Metal
vmBody.Color = Color3.fromRGB(47,50,56)
vmBody.Size = Vector3.new(0.42,0.55,2.2)
vmBody.Parent = vm
local vmBarrel = Instance.new("Part")
vmBarrel.Name = "Barrel"
vmBarrel.Anchored = true
vmBarrel.CanCollide = false
vmBarrel.CanTouch = false
vmBarrel.CastShadow = false
vmBarrel.Material = Enum.Material.Metal
vmBarrel.Color = Color3.fromRGB(25,27,31)
vmBarrel.Size = Vector3.new(0.18,0.18,1.35)
vmBarrel.Parent = vm
local vmSight = Instance.new("Part")
vmSight.Name = "Sight"
vmSight.Anchored = true
vmSight.CanCollide = false
vmSight.CanTouch = false
vmSight.CastShadow = false
vmSight.Material = Enum.Material.Metal
vmSight.Color = Color3.fromRGB(32,35,39)
vmSight.Size = Vector3.new(0.26,0.18,0.42)
vmSight.Parent = vm

local function currentCfg()
    return Config.Weapons[weaponKey]
end

local function setStatus(value, duration)
    statusLabel.Text = value or ""
    if duration then
        local mark = tostring(os.clock())
        statusLabel:SetAttribute("StatusMark", mark)
        task.delay(duration,function()
            if statusLabel:GetAttribute("StatusMark") == mark then statusLabel.Text = "" end
        end)
    end
end

local function updateAmmo()
    local a = ammo[weaponKey]
    if a then
        ammoLabel.Text = string.format("%02d / %03d", a.mag or 0, a.reserve or 0)
    else
        ammoLabel.Text = "-- / ---"
    end
    local cfg=currentCfg()
    if cfg then weaponLabel.Text=cfg.DisplayName end
end

local function updateScore()
    alphaScore.Text = "ALPHA  "..tostring(scores.ALPHA or 0)
    bravoScore.Text = tostring(scores.BRAVO or 0).."  BRAVO"
end

local function showHit(data)
    hitSerial += 1
    local serial=hitSerial
    hitmarker.TextColor3 = data and data.headshot and Color3.fromRGB(255,205,90) or Color3.fromRGB(255,255,255)
    hitmarker.TextTransparency = 0
    hitmarker.TextSize = data and data.killed and 56 or 45
    task.delay(0.11,function()
        if serial==hitSerial then
            TweenService:Create(hitmarker,TweenInfo.new(0.13),{TextTransparency=1}):Play()
        end
    end)
end

local function showKillfeed(data)
    killfeedSerial += 1
    local serial=killfeedSerial
    local line = string.format("%s   ▸   %s", tostring(data.killer or "?"), tostring(data.victim or "?"))
    killfeed.Text = line.."\n"..killfeed.Text
    local lines = {}
    for s in string.gmatch(killfeed.Text,"[^\n]+") do lines[#lines+1]=s end
    while #lines>5 do table.remove(lines) end
    killfeed.Text=table.concat(lines,"\n")
    task.delay(5,function()
        if serial <= killfeedSerial-4 then return end
    end)
end

local function setWeapon(key)
    if not Config.Weapons[key] then return end
    weaponKey=key
    reloading=false
    Equip:FireServer(key)
    updateAmmo()
    local cfg=currentCfg()
    camera.FieldOfView = cfg.FOV
    local scale = key=="P12" and 0.78 or (key=="SM9" and 0.9 or (key=="DMR7" and 1.15 or 1))
    vmBody.Size=Vector3.new(0.42*scale,0.55*scale,2.2*scale)
    vmBarrel.Size=Vector3.new(0.18*scale,0.18*scale,1.35*scale)
end

local function reload()
    local a=ammo[weaponKey]
    local cfg=currentCfg()
    if not a or not cfg or reloading or a.mag>=cfg.Magazine or a.reserve<=0 then return end
    Reload:FireServer()
end

local function spreadDirection()
    local cfg=currentCfg()
    local spread=adsHeld and cfg.SpreadADS or cfg.SpreadHip
    if sprintHeld then spread*=1.6 end
    local yaw=math.rad((math.random()-0.5)*2*spread)
    local pitch=math.rad((math.random()-0.5)*2*spread)
    return (camera.CFrame*CFrame.Angles(pitch,yaw,0)).LookVector
end

local function shootOnce()
    local cfg=currentCfg()
    local a=ammo[weaponKey]
    if not cfg or not a or reloading then return end
    local now=os.clock()
    local interval=60/cfg.RPM
    if now-lastLocalShot < interval then return end
    lastLocalShot=now
    if a.mag<=0 then
        setStatus("RELOAD",0.35)
        return
    end
    local character=player.Character
    local head=character and character:FindFirstChild("Head")
    if not head then return end
    a.mag-=1
    updateAmmo()
    Fire:FireServer({origin=head.Position,direction=spreadDirection()})
    local recoil=cfg.Recoil*(adsHeld and 0.66 or 1)
    camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(-recoil*(0.75+math.random()*0.35)),math.rad((math.random()-0.5)*recoil*0.4),0)
end

local function cycleWeapon()
    local idx=table.find(Config.Loadout,weaponKey) or 1
    idx=idx%#Config.Loadout+1
    setWeapon(Config.Loadout[idx])
end

local function setADS(on)
    adsHeld=on
    for _,l in ipairs(crossLines) do l.Visible=not on end
end

local function setSprint(on)
    sprintHeld=on
    local ch=player.Character
    local hum=ch and ch:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed=on and 22 or 16 end
end

UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        triggerHeld=true
        shootOnce()
    elseif input.UserInputType==Enum.UserInputType.MouseButton2 then
        setADS(true)
    elseif input.KeyCode==Enum.KeyCode.R then
        reload()
    elseif input.KeyCode==Enum.KeyCode.LeftShift then
        setSprint(true)
    elseif input.KeyCode==Enum.KeyCode.One then setWeapon(Config.Loadout[1])
    elseif input.KeyCode==Enum.KeyCode.Two then setWeapon(Config.Loadout[2])
    elseif input.KeyCode==Enum.KeyCode.Three then setWeapon(Config.Loadout[3])
    elseif input.KeyCode==Enum.KeyCode.Four then setWeapon(Config.Loadout[4]) end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then triggerHeld=false
    elseif input.UserInputType==Enum.UserInputType.MouseButton2 then setADS(false)
    elseif input.KeyCode==Enum.KeyCode.LeftShift then setSprint(false) end
end)

fireButton.MouseButton1Down:Connect(function() triggerHeld=true shootOnce() end)
fireButton.MouseButton1Up:Connect(function() triggerHeld=false end)
adsButton.MouseButton1Down:Connect(function() setADS(true) end)
adsButton.MouseButton1Up:Connect(function() setADS(false) end)
reloadButton.Activated:Connect(reload)
swapButton.Activated:Connect(cycleWeapon)
sprintButton.MouseButton1Down:Connect(function() setSprint(true) end)
sprintButton.MouseButton1Up:Connect(function() setSprint(false) end)

State.OnClientEvent:Connect(function(kind,data)
    if kind=="snapshot" then
        weaponKey=data.weapon or weaponKey
        ammo=data.ammo or ammo
        scores=data.scores or scores
        updateAmmo();updateScore()
    elseif kind=="ammo" and data.weapon==weaponKey then
        ammo[weaponKey]=ammo[weaponKey] or {}
        ammo[weaponKey].mag=data.mag
        ammo[weaponKey].reserve=data.reserve
        updateAmmo()
    elseif kind=="weapon" then
        weaponKey=data.weapon or weaponKey
        if data.ammo then ammo[weaponKey]=data.ammo end
        updateAmmo()
    elseif kind=="reload" and data.weapon==weaponKey then
        reloading=data.active==true
        setStatus(reloading and "RELOADING" or "", reloading and nil or 0.2)
    elseif kind=="hit" then
        showHit(data)
    elseif kind=="kill" then
        setStatus("ELIMINATION",0.55)
    elseif kind=="score" then
        scores=data.scores or scores
        updateScore()
    elseif kind=="killfeed" then
        showKillfeed(data)
    elseif kind=="roundEnd" then
        setStatus("ROUND WINNER: "..tostring(data.winner),5)
    elseif kind=="roundStart" then
        setStatus("ROUND "..tostring(data.round),1.2)
    elseif kind=="dry" then
        setStatus("EMPTY",0.35)
    end
end)

FX.OnClientEvent:Connect(function(kind,data)
    if kind~="shot" or type(data)~="table" or typeof(data.from)~="Vector3" or typeof(data.to)~="Vector3" then return end
    local delta=data.to-data.from
    local dist=delta.Magnitude
    if dist<0.1 then return end
    local tracer=Instance.new("Part")
    tracer.Name="Tracer"
    tracer.Anchored=true
    tracer.CanCollide=false
    tracer.CanTouch=false
    tracer.CastShadow=false
    tracer.Material=Enum.Material.Neon
    tracer.Color=Color3.fromRGB(236,224,166)
    tracer.Transparency=0.18
    tracer.Size=Vector3.new(0.045,0.045,math.min(dist,120))
    local mid=data.from+delta.Unit*(tracer.Size.Z*0.5)
    tracer.CFrame=CFrame.lookAt(mid,mid+delta.Unit)
    tracer.Parent=workspace
    Debris:AddItem(tracer,0.055)
end)

local function bindCharacter(character)
    player.CameraMode=Enum.CameraMode.LockFirstPerson
    local hum=character:WaitForChild("Humanoid",10)
    if not hum then return end
    hum.HealthChanged:Connect(function(h)
        local ratio=math.clamp(h/math.max(hum.MaxHealth,1),0,1)
        healthFill.Size=UDim2.fromScale(ratio,1)
        healthText.Text=string.format("%d HP",math.max(0,math.floor(h+0.5)))
    end)
end
player.CharacterAdded:Connect(bindCharacter)
if player.Character then bindCharacter(player.Character) end

RunService.RenderStepped:Connect(function(dt)
    camera=workspace.CurrentCamera or camera
    local cfg=currentCfg()
    if triggerHeld and cfg and cfg.Auto then shootOnce() end
    local targetFov
    if sprintHeld then targetFov=82
    elseif adsHeld then targetFov=cfg and cfg.ADSFOV or 58
    else targetFov=cfg and cfg.FOV or 74 end
    camera.FieldOfView += (targetFov-camera.FieldOfView)*math.min(1,dt*12)

    if vm.Parent~=camera then vm.Parent=camera end
    local bob=math.sin(os.clock()*8)*0.012
    local base=adsHeld and CFrame.new(0,-0.12,-0.78) or CFrame.new(0.48,-0.48,-1.12)
    if sprintHeld then base=CFrame.new(0.65,-0.68,-0.9)*CFrame.Angles(0,0,math.rad(-18)) end
    local cf=camera.CFrame*base*CFrame.new(0,bob,0)
    vmBody.CFrame=cf
    vmBarrel.CFrame=cf*CFrame.new(0,0,-1.65)
    vmSight.CFrame=cf*CFrame.new(0,0.34,-0.15)
end)

setWeapon(weaponKey)
updateScore()
setStatus("TDM PROTOTYPE",1.5)
print("[BBYAVATAR FPS] Client ready")
