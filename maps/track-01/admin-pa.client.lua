local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local TweenService=game:GetService("TweenService")

-- TRACK 01 v4.0 manual PA listener.
-- Receives only server-approved announcement presets. Uses Roblox TTS and built-in chime.
local player=Players.LocalPlayer
if not player then return end
local playerGui=player:WaitForChild("PlayerGui",20)
if not playerGui then return end
local remoteFolder=ReplicatedStorage:WaitForChild("TRACK01_Admin",20)
if not remoteFolder then return end
local announcement=remoteFolder:WaitForChild("Announcement",10)
if not announcement then return end

local gui=Instance.new("ScreenGui")
gui.Name="TRACK01_AdminPA"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=74
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.Parent=playerGui

local busy=false

local function ping(speed,volume)
    local s=Instance.new("Sound")
    s.Name="TRACK01_AdminPAChime"
    s.SoundId="rbxasset://sounds/electronicpingshort.wav"
    s.Volume=volume or 0.84
    s.PlaybackSpeed=speed or 1
    s.Parent=SoundService
    s:Play()
    task.delay(2,function() if s.Parent then s:Destroy() end end)
end

local function chime()
    ping(1.16,0.86)
    task.wait(0.34)
    ping(0.84,0.82)
end

local function showCaption(kicker,text,warning)
    local old=gui:FindFirstChild("PACaption")
    if old then old:Destroy() end
    local frame=Instance.new("Frame")
    frame.Name="PACaption"
    frame.AnchorPoint=Vector2.new(0.5,0)
    frame.Position=UDim2.fromScale(0.5,0.07)
    frame.Size=UDim2.fromScale(0.66,0.105)
    frame.BackgroundColor3=Color3.fromRGB(13,14,14)
    frame.BackgroundTransparency=0.10
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
    stroke.Transparency=0.22
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

    task.delay(7.5,function()
        if not frame.Parent then return end
        TweenService:Create(frame,TweenInfo.new(0.55),{BackgroundTransparency=1}):Play()
        TweenService:Create(top,TweenInfo.new(0.55),{TextTransparency=1}):Play()
        TweenService:Create(body,TweenInfo.new(0.55),{TextTransparency=1}):Play()
        TweenService:Create(stroke,TweenInfo.new(0.55),{Transparency=1}):Play()
        task.wait(0.62)
        if frame.Parent then frame:Destroy() end
    end)
end

local function existingPABusy()
    return SoundService:FindFirstChild("TRACK01_OperationalTTS")~=nil
        or SoundService:FindFirstChild("TRACK01_ArrivalTTS")~=nil
        or SoundService:FindFirstChild("TRACK01_AdminTTS")~=nil
end

local function speak(payload)
    if busy or type(payload)~="table" then return end
    if type(payload.voice)~="string" or type(payload.caption)~="string" or type(payload.kicker)~="string" then return end
    busy=true

    local deadline=os.clock()+20
    while existingPABusy() and os.clock()<deadline do task.wait(0.30) end

    if payload.warning then ping(0.78,0.72) else chime() end
    task.wait(payload.warning and 0.38 or 0.58)
    showCaption(payload.kicker,payload.caption,payload.warning==true)

    local cleaned=false
    local ok,err=pcall(function()
        local tts=Instance.new("AudioTextToSpeech")
        tts.Name="TRACK01_AdminTTS"
        tts.Text=payload.voice
        tts.VoiceId=11
        tts.Pitch=-1
        tts.Speed=0.89
        tts.Volume=1.95
        tts.Parent=SoundService

        local output=Instance.new("AudioDeviceOutput")
        output.Name="TRACK01_AdminPAOutput"
        output.Player=player
        output.Parent=SoundService

        local wire=Instance.new("Wire")
        wire.Name="TRACK01_AdminPAWire"
        wire.SourceInstance=tts
        wire.TargetInstance=output
        wire.Parent=SoundService

        local function cleanup()
            if cleaned then return end
            cleaned=true
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
        busy=false
        warn("[TRACK 01] admin PA TTS unavailable; caption/chime fallback active:",err)
    end
end

announcement.OnClientEvent:Connect(function(payload)
    task.spawn(speak,payload)
end)

print("[TRACK 01] all-player manual PA listener ready v4.0.0")
