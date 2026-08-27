local Players=game:GetService("Players")
local SoundService=game:GetService("SoundService")

-- TRACK 01 v3.7.1 PA loudness + lobby wording hotfix.
-- Roblox TTS remains the source; this only raises amplitude for mobile audibility.
local player=Players.LocalPlayer
if not player then return end

local function tune(obj)
    if obj:IsA("AudioTextToSpeech") then
        if obj.Name=="TRACK01_ArrivalTTS" then
            obj.Volume=2.15
        elseif obj.Name=="TRACK01_OperationalTTS" then
            obj.Volume=1.95
        end
    elseif obj:IsA("Sound") then
        if obj.Name=="TRACK01_ChimeHigh" then
            obj.Volume=1.00
        elseif obj.Name=="TRACK01_ChimeLow" then
            obj.Volume=0.94
        elseif obj.Name=="TRACK01_PAChime" then
            obj.Volume=0.86
        end
    end
end

for _,obj in ipairs(SoundService:GetChildren()) do tune(obj) end
SoundService.ChildAdded:Connect(tune)

-- The personalized arrival now happens in the old-station lobby, so keep the visual
-- language consistent instead of telling a fresh visitor they are already on Platform 01.
task.spawn(function()
    local playerGui=player:WaitForChild("PlayerGui",15)
    if not playerGui then return end
    local welcomeGui=playerGui:WaitForChild("TRACK01_StationWelcome",12)
    if not welcomeGui then return end
    local card=welcomeGui:FindFirstChild("ArrivalCard")
    local header=card and card:FindFirstChild("Header")
    if header and header:IsA("TextLabel") then
        header.Text="TRACK 01  •  STATION LOBBY  •  ARRIVAL"
    end
end)

print("[TRACK 01] ACC_TRACK01_PA_VOLUME_HOTFIX_READY v3.7.1")
