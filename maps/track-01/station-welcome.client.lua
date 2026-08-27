local Players=game:GetService("Players")
local SoundService=game:GetService("SoundService")
local TweenService=game:GetService("TweenService")

-- TRACK 01 v3.6 station welcome.
-- Per-player, once-per-join arrival experience: built-in two-tone station chime,
-- personalized Roblox AudioTextToSpeech announcement, and a mobile-safe welcome card.
-- No uploaded audio asset is required.
local player=Players.LocalPlayer
if not player then return end
if not game:IsLoaded() then game.Loaded:Wait() end

task.wait(2.25)

local playerGui=player:WaitForChild("PlayerGui",15)
if not playerGui then return end
if playerGui:FindFirstChild("TRACK01_StationWelcome") then return end

local displayName=player.DisplayName
if displayName=="" then displayName=player.Name end

local gui=Instance.new("ScreenGui")
gui.Name="TRACK01_StationWelcome"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=80
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.Parent=playerGui

local frame=Instance.new("Frame")
frame.Name="ArrivalCard"
frame.AnchorPoint=Vector2.new(0.5,1)
frame.Position=UDim2.fromScale(0.5,0.90)
frame.Size=UDim2.fromScale(0.72,0.16)
frame.BackgroundColor3=Color3.fromRGB(13,14,14)
frame.BackgroundTransparency=0.10
frame.BorderSizePixel=0
frame.Parent=gui

local sizeConstraint=Instance.new("UISizeConstraint")
sizeConstraint.MinSize=Vector2.new(280,104)
sizeConstraint.MaxSize=Vector2.new(760,150)
sizeConstraint.Parent=frame

local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(0,5)
corner.Parent=frame

local stroke=Instance.new("UIStroke")
stroke.Color=Color3.fromRGB(112,56,48)
stroke.Thickness=1
stroke.Transparency=0.25
stroke.Parent=frame

local accent=Instance.new("Frame")
accent.Name="SignalAccent"
accent.Size=UDim2.new(0,5,1,0)
accent.BackgroundColor3=Color3.fromRGB(167,42,37)
accent.BorderSizePixel=0
accent.Parent=frame
local accentCorner=Instance.new("UICorner")
accentCorner.CornerRadius=UDim.new(0,5)
accentCorner.Parent=accent

local header=Instance.new("TextLabel")
header.Name="Header"
header.BackgroundTransparency=1
header.Position=UDim2.fromScale(0.045,0.08)
header.Size=UDim2.fromScale(0.91,0.20)
header.Font=Enum.Font.RobotoMono
header.Text="TRACK 01  •  PLATFORM 01  •  ARRIVAL"
header.TextColor3=Color3.fromRGB(211,179,127)
header.TextSize=14
header.TextXAlignment=Enum.TextXAlignment.Left
header.Parent=frame

local welcome=Instance.new("TextLabel")
welcome.Name="WelcomeName"
welcome.BackgroundTransparency=1
welcome.Position=UDim2.fromScale(0.045,0.29)
welcome.Size=UDim2.fromScale(0.91,0.30)
welcome.Font=Enum.Font.GothamBold
welcome.Text="SELAMAT DATANG, "..string.upper(displayName)
welcome.TextColor3=Color3.fromRGB(238,226,206)
welcome.TextScaled=true
welcome.TextXAlignment=Enum.TextXAlignment.Left
welcome.Parent=frame
local welcomeConstraint=Instance.new("UITextSizeConstraint")
welcomeConstraint.MinTextSize=17
welcomeConstraint.MaxTextSize=27
welcomeConstraint.Parent=welcome

local instruction=Instance.new("TextLabel")
instruction.Name="Instruction"
instruction.BackgroundTransparency=1
instruction.Position=UDim2.fromScale(0.045,0.62)
instruction.Size=UDim2.fromScale(0.91,0.26)
instruction.Font=Enum.Font.Gotham
instruction.Text="AMBIL NIGHT TICKET  →  PILIH CAR 01–04  •  NO DESTINATION. JUST THE NIGHT."
instruction.TextColor3=Color3.fromRGB(185,184,174)
instruction.TextScaled=true
instruction.TextWrapped=true
instruction.TextXAlignment=Enum.TextXAlignment.Left
instruction.Parent=frame
local instructionConstraint=Instance.new("UITextSizeConstraint")
instructionConstraint.MinTextSize=10
instructionConstraint.MaxTextSize=15
instructionConstraint.Parent=instruction

-- Built-in Roblox sound only. Two pitches create a restrained station 'ding-dong'
-- without uploading a new audio asset.
local function playStationChime()
    local function note(name,speed,volume)
        local s=Instance.new("Sound")
        s.Name=name
        s.SoundId="rbxasset://sounds/electronicpingshort.wav"
        s.Volume=volume
        s.PlaybackSpeed=speed
        s.RollOffMode=Enum.RollOffMode.Linear
        s.Parent=SoundService
        s:Play()
        task.delay(2,function()
            if s.Parent then s:Destroy() end
        end)
    end
    note("TRACK01_ChimeHigh",1.18,0.52)
    task.wait(0.34)
    note("TRACK01_ChimeLow",0.84,0.50)
end

local function playPersonalizedTTS()
    local ok,err=pcall(function()
        local tts=Instance.new("AudioTextToSpeech")
        tts.Name="TRACK01_ArrivalTTS"
        tts.Text="Selamat datang di Track Zero One, "..displayName..". Silakan ambil tiket malam Anda, lalu menuju gerbong yang Anda inginkan. No destination. Just the night."
        tts.VoiceId=11
        tts.Pitch=-2
        tts.Speed=0.92
        tts.Volume=1.05
        tts.Parent=SoundService

        local output=Instance.new("AudioDeviceOutput")
        output.Name="TRACK01_ArrivalOutput"
        output.Player=player
        output.Parent=SoundService

        local wire=Instance.new("Wire")
        wire.Name="TRACK01_ArrivalWire"
        wire.SourceInstance=tts
        wire.TargetInstance=output
        wire.Parent=SoundService

        local cleaned=false
        local function cleanup()
            if cleaned then return end
            cleaned=true
            if wire.Parent then wire:Destroy() end
            if tts.Parent then tts:Destroy() end
            if output.Parent then output:Destroy() end
        end
        local connection
        connection=tts.Ended:Connect(function()
            if connection then connection:Disconnect() end
            cleanup()
        end)
        tts:Play()
        task.delay(18,cleanup)
    end)
    if not ok then
        warn("[TRACK 01] AudioTextToSpeech unavailable; visual/chime fallback active:",err)
    end
end

playStationChime()
task.wait(0.60)
playPersonalizedTTS()

-- Keep the card long enough to read, then fade it away. It never returns on respawn
-- because this LocalScript lives in StarterPlayerScripts and the ScreenGui ResetOnSpawn is false.
task.delay(10,function()
    if not frame.Parent then return end
    local tween=TweenService:Create(frame,TweenInfo.new(0.65,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=1})
    tween:Play()
    for _,obj in ipairs(frame:GetDescendants()) do
        if obj:IsA("TextLabel") then
            TweenService:Create(obj,TweenInfo.new(0.65),{TextTransparency=1}):Play()
        elseif obj:IsA("Frame") then
            TweenService:Create(obj,TweenInfo.new(0.65),{BackgroundTransparency=1}):Play()
        elseif obj:IsA("UIStroke") then
            TweenService:Create(obj,TweenInfo.new(0.65),{Transparency=1}):Play()
        end
    end
    task.wait(0.75)
    if gui.Parent then gui:Destroy() end
end)

print("[TRACK 01] ACC_TRACK01_WELCOME_TTS_READY v3.6.0 for",displayName)
