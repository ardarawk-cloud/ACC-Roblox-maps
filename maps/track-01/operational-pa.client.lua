local Players=game:GetService("Players")
local SoundService=game:GetService("SoundService")
local TweenService=game:GetService("TweenService")
local Workspace=game:GetService("Workspace")

-- TRACK 01 v3.7 operational station PA.
-- Generic station/airport-style announcements run locally so every visitor hears a clean,
-- non-overlapping PA feed. No uploaded voice or chime assets are required.
local player=Players.LocalPlayer
if not player then return end
if not game:IsLoaded() then game.Loaded:Wait() end
local playerGui=player:WaitForChild("PlayerGui",20)
if not playerGui then return end

local rng=Random.new()
local busy=false
local lastOperational=-math.huge
local MIN_OPERATIONAL_GAP=360 -- never more than one normal/special PA every 6 minutes
local restrictedCooldownUntil=0

local gui=Instance.new("ScreenGui")
gui.Name="TRACK01_OperationalPA"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=72
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.Parent=playerGui

local function showCaption(kicker,text,warning,duration)
    local old=gui:FindFirstChild("PACaption")
    if old then old:Destroy() end
    local frame=Instance.new("Frame")
    frame.Name="PACaption"
    frame.AnchorPoint=Vector2.new(0.5,0)
    frame.Position=UDim2.fromScale(0.5,0.07)
    frame.Size=UDim2.fromScale(0.66,0.105)
    frame.BackgroundColor3=Color3.fromRGB(13,14,14)
    frame.BackgroundTransparency=0.12
    frame.BorderSizePixel=0
    frame.Parent=gui
    local size=Instance.new("UISizeConstraint")
    size.MinSize=Vector2.new(280,78)
    size.MaxSize=Vector2.new(760,112)
    size.Parent=frame
    local corner=Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,5)
    corner.Parent=frame
    local stroke=Instance.new("UIStroke")
    stroke.Color=warning and Color3.fromRGB(166,46,40) or Color3.fromRGB(112,83,55)
    stroke.Thickness=1
    stroke.Transparency=0.25
    stroke.Parent=frame

    local top=Instance.new("TextLabel")
    top.BackgroundTransparency=1
    top.Position=UDim2.fromScale(0.035,0.08)
    top.Size=UDim2.fromScale(0.93,0.25)
    top.Font=Enum.Font.RobotoMono
    top.Text=kicker
    top.TextColor3=warning and Color3.fromRGB(224,96,83) or Color3.fromRGB(211,179,127)
    top.TextSize=13
    top.TextXAlignment=Enum.TextXAlignment.Left
    top.Parent=frame

    local body=Instance.new("TextLabel")
    body.BackgroundTransparency=1
    body.Position=UDim2.fromScale(0.035,0.35)
    body.Size=UDim2.fromScale(0.93,0.52)
    body.Font=Enum.Font.GothamMedium
    body.Text=text
    body.TextColor3=Color3.fromRGB(235,226,208)
    body.TextWrapped=true
    body.TextScaled=true
    body.TextXAlignment=Enum.TextXAlignment.Left
    body.Parent=frame
    local textSize=Instance.new("UITextSizeConstraint")
    textSize.MinTextSize=12
    textSize.MaxTextSize=18
    textSize.Parent=body

    task.delay(duration or 6,function()
        if not frame.Parent then return end
        TweenService:Create(frame,TweenInfo.new(0.55),{BackgroundTransparency=1}):Play()
        TweenService:Create(top,TweenInfo.new(0.55),{TextTransparency=1}):Play()
        TweenService:Create(body,TweenInfo.new(0.55),{TextTransparency=1}):Play()
        TweenService:Create(stroke,TweenInfo.new(0.55),{Transparency=1}):Play()
        task.wait(0.62)
        if frame.Parent then frame:Destroy() end
    end)
end

local function ping(speed,volume)
    local s=Instance.new("Sound")
    s.Name="TRACK01_PAChime"
    s.SoundId="rbxasset://sounds/electronicpingshort.wav"
    s.Volume=volume or 0.46
    s.PlaybackSpeed=speed or 1
    s.Parent=SoundService
    s:Play()
    task.delay(2,function() if s.Parent then s:Destroy() end end)
end

local function chime()
    ping(1.16,0.48)
    task.wait(0.34)
    ping(0.84,0.46)
end

local function speak(text,kicker,caption,warning)
    if busy then return false end
    busy=true
    if warning then
        ping(0.78,0.42)
    else
        chime()
    end
    task.wait(warning and 0.38 or 0.58)
    showCaption(kicker,caption or text,warning,7.5)

    local finished=false
    local ok,err=pcall(function()
        local tts=Instance.new("AudioTextToSpeech")
        tts.Name="TRACK01_OperationalTTS"
        tts.Text=text
        tts.VoiceId=11
        tts.Pitch=-1
        tts.Speed=0.89
        tts.Volume=0.94
        tts.Parent=SoundService

        local output=Instance.new("AudioDeviceOutput")
        output.Name="TRACK01_OperationalPAOutput"
        output.Player=player
        output.Parent=SoundService

        local wire=Instance.new("Wire")
        wire.Name="TRACK01_OperationalPAWire"
        wire.SourceInstance=tts
        wire.TargetInstance=output
        wire.Parent=SoundService

        local function cleanup()
            if finished then return end
            finished=true
            if wire.Parent then wire:Destroy() end
            if tts.Parent then tts:Destroy() end
            if output.Parent then output:Destroy() end
            busy=false
        end
        local connection
        connection=tts.Ended:Connect(function()
            if connection then connection:Disconnect() end
            cleanup()
        end)
        tts:Play()
        task.delay(22,cleanup)
    end)
    if not ok then
        warn("[TRACK 01] operational TTS unavailable; caption/chime fallback active:",err)
        busy=false
    end
    return true
end

local regular={
    {
        voice="Perhatian. Layanan malam Track Zero One sedang beroperasi. Car Zero One untuk lounge. Car Zero Two untuk bar. Car Zero Three untuk dance floor. Car Zero Four, End of Line.",
        caption="NIGHT SERVICE • CAR 01 LOUNGE • CAR 02 BAR • CAR 03 DANCE • CAR 04 END OF LINE",
    },
    {
        voice="Para pengunjung Track Zero One. Pastikan tiket malam Anda sudah diambil sebelum memasuki gerbong. Gunakan Platform Zero One sebagai akses utama.",
        caption="NIGHT TICKET REQUIRED • BOARD VIA PLATFORM 01",
    },
    {
        voice="Perhatian. Gunakan koridor penghubung saat berpindah antar gerbong. Tetap berada di jalur penumpang dan hindari area terbatas.",
        caption="USE INTER-CAR VESTIBULES • STAY INSIDE THE PASSENGER ROUTE",
    },
    {
        voice="Night service announcement. No destination. Just the night. Nikmati perjalanan Anda di Track Zero One.",
        caption="NO DESTINATION. JUST THE NIGHT.",
    },
}

local special={
    {
        voice="Perhatian. Layanan menuju End of Line tersedia melalui Car Zero Four. Area di luar jalur penumpang tetap terbatas.",
        caption="END OF LINE • CAR 04 • RESTRICTED AREAS REMAIN CLOSED",
    },
    {
        voice="Last train advisory. Layanan malam tetap berjalan. Pastikan barang bawaan Anda tidak tertinggal di dalam gerbong.",
        caption="LAST TRAIN ADVISORY • NIGHT SERVICE CONTINUES",
    },
    {
        voice="Track Zero One night service. Platform Zero One tetap aktif. No destination. Just the night.",
        caption="PLATFORM 01 • NIGHT SERVICE ACTIVE",
    },
}

local function operational(item,kicker)
    local now=os.clock()
    local remaining=MIN_OPERATIONAL_GAP-(now-lastOperational)
    if remaining>0 then task.wait(remaining) end
    if speak(item.voice,kicker,item.caption,false) then
        lastOperational=os.clock()
    end
end

-- Normal station PA: roughly every 8–12 minutes after the personalized arrival has settled.
task.spawn(function()
    task.wait(rng:NextInteger(480,720))
    local index=rng:NextInteger(1,#regular)
    while gui.Parent do
        operational(regular[index],"TRACK 01 • STATION ANNOUNCEMENT")
        index=(index%#regular)+1
        task.wait(rng:NextInteger(480,720))
    end
end)

-- Special/lore PA: roughly every 22–30 minutes, still respecting the 6-minute global gap.
task.spawn(function()
    task.wait(rng:NextInteger(1320,1800))
    local index=rng:NextInteger(1,#special)
    while gui.Parent do
        operational(special[index],"TRACK 01 • NIGHT SERVICE")
        index=(index%#special)+1
        task.wait(rng:NextInteger(1320,1800))
    end
end)

-- Ticket-denied feedback is immediate but intentionally short and mostly visual.
local lastDeniedToken=player:GetAttribute("TRACK01_ACCESS_DENIED_TOKEN") or 0
player:GetAttributeChangedSignal("TRACK01_ACCESS_DENIED_TOKEN"):Connect(function()
    local token=player:GetAttribute("TRACK01_ACCESS_DENIED_TOKEN") or 0
    if token==lastDeniedToken then return end
    lastDeniedToken=token
    local car=player:GetAttribute("TRACK01_ACCESS_DENIED_CAR") or 0
    ping(0.72,0.38)
    showCaption("TICKET REQUIRED • ACCESS DENIED",string.format("CLAIM YOUR NIGHT TICKET BEFORE ENTERING CAR %02d",car),true,5.0)
end)

-- Restricted-area warning: tied to actual red warning beacon locations, not a timer.
task.spawn(function()
    while gui.Parent do
        task.wait(1.0)
        local character=player.Character
        local hrp=character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local root=Workspace:FindFirstChild("ACC_TRACK01")
        local world=root and root:FindFirstChild("World")
        local signal=world and world:FindFirstChild("TRACK01_SignalNight_v33")
        local warnings=signal and signal:FindFirstChild("RestrictedWarningSignals")
        if not warnings then continue end
        local near=false
        for _,obj in ipairs(warnings:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Position-hrp.Position).Magnitude<=9 then
                near=true
                break
            end
        end
        if near and os.clock()>=restrictedCooldownUntil and not busy then
            restrictedCooldownUntil=os.clock()+90
            speak("Perhatian. Area di depan adalah area terbatas. Silakan kembali ke jalur penumpang.","TRACK 01 • RESTRICTED AREA","RESTRICTED AREA • RETURN TO THE PASSENGER ROUTE",true)
        end
    end
end)

print("[TRACK 01] ACC_TRACK01_OPERATIONAL_PA_READY v3.7.0")
