local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")
local SoundService=game:GetService("SoundService")

-- TRACK 01 v4.1 operator authority.
-- Server-authoritative DJ/music transport + event operations.
-- No audio asset is uploaded or invented here. Music only becomes playable when an approved source is installed server-side.

local remoteFolder=ReplicatedStorage:FindFirstChild("TRACK01_Admin")
if remoteFolder then remoteFolder:Destroy() end
remoteFolder=Instance.new("Folder")
remoteFolder.Name="TRACK01_Admin"
remoteFolder.Parent=ReplicatedStorage

local command=Instance.new("RemoteEvent")
command.Name="Command"
command.Parent=remoteFolder

local stateEvent=Instance.new("RemoteEvent")
stateEvent.Name="State"
stateEvent.Parent=remoteFolder

local announceEvent=Instance.new("RemoteEvent")
announceEvent.Name="Announcement"
announceEvent.Parent=remoteFolder

local query=Instance.new("RemoteFunction")
query.Name="Query"
query.Parent=remoteFolder

local LOBBY_RECOVERY=CFrame.new(-38,4.5,-123)
local GROUP_ADMIN_MIN_RANK=255
local EXPLICIT_ADMIN_USERNAMES={
    ["ridhoomaukamu"]=true,
}
local lastCommandAt={}
local COMMAND_COOLDOWN=0.20
local serverStarted=os.clock()
local lastOperator="NONE"

local lightingPresets={
    STANDARD={brightness=1.80,exposure=0.12},
    READABLE={brightness=2.02,exposure=0.22},
    LOW_NIGHT={brightness=1.68,exposure=0.05},
}

local paPresets={
    BOARDING={kicker="TRACK 01 • BOARDING CALL",voice="Perhatian. Boarding Track Zero One melalui Platform Zero One sedang dibuka. Pastikan Night Ticket Anda sudah siap sebelum memasuki gerbong.",caption="BOARDING OPEN • NIGHT TICKET REQUIRED • PLATFORM 01",warning=false},
    NIGHT_SERVICE={kicker="TRACK 01 • NIGHT SERVICE",voice="Perhatian. Layanan malam Track Zero One sedang beroperasi. Car Zero One lounge. Car Zero Two bar. Car Zero Three dance. Car Zero Four, End of Line.",caption="NIGHT SERVICE • CAR 01 LOUNGE • 02 BAR • 03 DANCE • 04 END OF LINE",warning=false},
    END_OF_LINE={kicker="TRACK 01 • END OF LINE",voice="End of Line announcement. Car Zero Four dan area The Yard sedang aktif. No destination. Just the night.",caption="END OF LINE • CAR 04 • THE YARD • NO DESTINATION. JUST THE NIGHT.",warning=false},
    LAST_TRAIN={kicker="TRACK 01 • LAST TRAIN",voice="Last train advisory. Layanan malam Track Zero One memasuki fase terakhir. Pastikan barang bawaan Anda tidak tertinggal dan ikuti jalur kembali menuju Station Lobby.",caption="LAST TRAIN ADVISORY • FINAL NIGHT SERVICE PHASE",warning=false},
    CLOSING={kicker="TRACK 01 • CLOSING",voice="Perhatian. Track Zero One memasuki layanan penutupan. Silakan selesaikan aktivitas Anda dan kembali menuju Station Lobby dengan tertib.",caption="CLOSING SERVICE • RETURN TOWARD STATION LOBBY",warning=false},
}

local validVenueStatus={NIGHT_SERVICE=true,BOARDING_HOLD=true,CLOSING=true}
local validEventMode={NONE=true,END_OF_LINE=true,LAST_TRAIN=true}
local validEventPreset={NORMAL=true,BOARDING_HOLD=true,END_OF_LINE=true,LAST_TRAIN=true,CLOSING=true}

-- Music authority. Source is intentionally empty until an approved Roblox audio source is explicitly installed.
local musicFolder=SoundService:FindFirstChild("TRACK01_Music")
if not musicFolder then
    musicFolder=Instance.new("Folder")
    musicFolder.Name="TRACK01_Music"
    musicFolder.Parent=SoundService
end
local musicSound=musicFolder:FindFirstChild("VenueMusic")
if not musicSound or not musicSound:IsA("Sound") then
    if musicSound then musicSound:Destroy() end
    musicSound=Instance.new("Sound")
    musicSound.Name="VenueMusic"
    musicSound.Looped=true
    musicSound.Volume=0.55
    musicSound.SoundId=""
    musicSound.Parent=musicFolder
end
musicSound.Looped=true
local musicLabel="NO APPROVED SOURCE"

local function refreshApprovedMusicSource()
    local approved=Workspace:GetAttribute("TRACK01_APPROVED_MUSIC_SOUND_ID")
    local label=Workspace:GetAttribute("TRACK01_APPROVED_MUSIC_LABEL")
    if type(approved)=="string" and string.match(approved,"^rbxassetid://%d+$") then
        musicSound.SoundId=approved
        musicLabel=(type(label)=="string" and label~="") and string.sub(label,1,48) or "APPROVED VENUE SOURCE"
    elseif musicSound.SoundId=="" then
        musicLabel="NO APPROVED SOURCE"
    end
end
refreshApprovedMusicSource()
Workspace:GetAttributeChangedSignal("TRACK01_APPROVED_MUSIC_SOUND_ID"):Connect(refreshApprovedMusicSource)
Workspace:GetAttributeChangedSignal("TRACK01_APPROVED_MUSIC_LABEL"):Connect(refreshApprovedMusicSource)

local function musicConfigured()
    return type(musicSound.SoundId)=="string" and musicSound.SoundId~=""
end

local function optionalAllowlistContains(userId)
    local raw=Workspace:GetAttribute("TRACK01_ADMIN_USER_IDS")
    if type(raw)~="string" or raw=="" then return false end
    for token in string.gmatch(raw,"[^,%s]+") do
        if tonumber(token)==userId then return true end
    end
    return false
end

local function isAuthorized(player)
    if not player then return false end
    if RunService:IsStudio() then return true end
    if EXPLICIT_ADMIN_USERNAMES[string.lower(player.Name or "")] then return true end
    if optionalAllowlistContains(player.UserId) then return true end
    if game.CreatorType==Enum.CreatorType.User then return player.UserId==game.CreatorId end
    if game.CreatorType==Enum.CreatorType.Group then
        local ok,rank=pcall(function() return player:GetRankInGroup(game.CreatorId) end)
        return ok and rank>=GROUP_ADMIN_MIN_RANK
    end
    return false
end

local function setupPlayer(player)
    player:SetAttribute("TRACK01_ADMIN_AUTHORIZED",isAuthorized(player))
end
for _,player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player) lastCommandAt[player]=nil end)

if Workspace:GetAttribute("TRACK01_VENUE_STATUS")==nil then Workspace:SetAttribute("TRACK01_VENUE_STATUS","NIGHT_SERVICE") end
if Workspace:GetAttribute("TRACK01_EVENT_MODE")==nil then Workspace:SetAttribute("TRACK01_EVENT_MODE","NONE") end
if Workspace:GetAttribute("TRACK01_LIGHT_PULSE_ENABLED")==nil then Workspace:SetAttribute("TRACK01_LIGHT_PULSE_ENABLED",true) end
if Workspace:GetAttribute("TRACK01_LIGHTING_PRESET")==nil then Workspace:SetAttribute("TRACK01_LIGHTING_PRESET","STANDARD") end
if Workspace:GetAttribute("TRACK01_EVENT_PRESET")==nil then Workspace:SetAttribute("TRACK01_EVENT_PRESET","NORMAL") end

local function snapshot()
    return {
        venueStatus=Workspace:GetAttribute("TRACK01_VENUE_STATUS") or "NIGHT_SERVICE",
        eventMode=Workspace:GetAttribute("TRACK01_EVENT_MODE") or "NONE",
        eventPreset=Workspace:GetAttribute("TRACK01_EVENT_PRESET") or "NORMAL",
        pulseEnabled=Workspace:GetAttribute("TRACK01_LIGHT_PULSE_ENABLED")~=false,
        lightingPreset=Workspace:GetAttribute("TRACK01_LIGHTING_PRESET") or "STANDARD",
        featureComplete=Workspace:GetAttribute("ACC_TRACK01_FEATURE_COMPLETE")==true,
        sourceRuntimeVersion=Workspace:GetAttribute("ACC_TRACK01_VERSION") or "UNKNOWN",
        panelVersion="4.1.0",
        playerCount=#Players:GetPlayers(),
        operatorName=lastOperator,
        uptimeSeconds=math.max(0,math.floor(os.clock()-serverStarted)),
        musicConfigured=musicConfigured(),
        musicPlaying=musicSound.Playing,
        musicVolume=musicSound.Volume,
        musicTrack=musicLabel,
    }
end

local function pushState()
    local data=snapshot()
    for _,player in ipairs(Players:GetPlayers()) do
        if isAuthorized(player) then stateEvent:FireClient(player,data) end
    end
end

local function applyLightingPreset(name)
    local preset=lightingPresets[name]
    if not preset then return false end
    Lighting.Brightness=preset.brightness
    Lighting.ExposureCompensation=preset.exposure
    Workspace:SetAttribute("TRACK01_LIGHTING_PRESET",name)
    return true
end

local function returnToLobby(target)
    local character=target and target.Character
    local hrp=character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    hrp.AssemblyLinearVelocity=Vector3.zero
    hrp.AssemblyAngularVelocity=Vector3.zero
    hrp.CFrame=LOBBY_RECOVERY
    target:SetAttribute("TRACK01_RECOVERY_REASON","ADMIN RETURN TO STATION LOBBY")
    target:SetAttribute("TRACK01_RECOVERY_TOKEN",(target:GetAttribute("TRACK01_RECOVERY_TOKEN") or 0)+1)
    return true
end

local function resolveTarget(userId)
    if type(userId)~="number" then return nil end
    for _,player in ipairs(Players:GetPlayers()) do if player.UserId==userId then return player end end
    return nil
end

local function setMusicVolume(delta)
    if type(delta)~="number" then return end
    musicSound.Volume=math.clamp(musicSound.Volume+delta,0,1)
end

local function applyEventPreset(name)
    if not validEventPreset[name] then return false end
    Workspace:SetAttribute("TRACK01_EVENT_PRESET",name)
    if name=="NORMAL" then
        Workspace:SetAttribute("TRACK01_VENUE_STATUS","NIGHT_SERVICE")
        Workspace:SetAttribute("TRACK01_EVENT_MODE","NONE")
        applyLightingPreset("STANDARD")
        Workspace:SetAttribute("TRACK01_LIGHT_PULSE_ENABLED",true)
        announceEvent:FireAllClients(paPresets.NIGHT_SERVICE)
    elseif name=="BOARDING_HOLD" then
        Workspace:SetAttribute("TRACK01_VENUE_STATUS","BOARDING_HOLD")
        Workspace:SetAttribute("TRACK01_EVENT_MODE","NONE")
        applyLightingPreset("READABLE")
        Workspace:SetAttribute("TRACK01_LIGHT_PULSE_ENABLED",false)
        announceEvent:FireAllClients(paPresets.BOARDING)
    elseif name=="END_OF_LINE" then
        Workspace:SetAttribute("TRACK01_VENUE_STATUS","NIGHT_SERVICE")
        Workspace:SetAttribute("TRACK01_EVENT_MODE","END_OF_LINE")
        applyLightingPreset("LOW_NIGHT")
        Workspace:SetAttribute("TRACK01_LIGHT_PULSE_ENABLED",true)
        announceEvent:FireAllClients(paPresets.END_OF_LINE)
    elseif name=="LAST_TRAIN" then
        Workspace:SetAttribute("TRACK01_VENUE_STATUS","CLOSING")
        Workspace:SetAttribute("TRACK01_EVENT_MODE","LAST_TRAIN")
        applyLightingPreset("READABLE")
        Workspace:SetAttribute("TRACK01_LIGHT_PULSE_ENABLED",false)
        announceEvent:FireAllClients(paPresets.LAST_TRAIN)
    elseif name=="CLOSING" then
        Workspace:SetAttribute("TRACK01_VENUE_STATUS","CLOSING")
        Workspace:SetAttribute("TRACK01_EVENT_MODE","NONE")
        applyLightingPreset("READABLE")
        Workspace:SetAttribute("TRACK01_LIGHT_PULSE_ENABLED",false)
        announceEvent:FireAllClients(paPresets.CLOSING)
    end
    return true
end

local function resetOperations()
    Workspace:SetAttribute("TRACK01_EVENT_PRESET","NORMAL")
    Workspace:SetAttribute("TRACK01_VENUE_STATUS","NIGHT_SERVICE")
    Workspace:SetAttribute("TRACK01_EVENT_MODE","NONE")
    Workspace:SetAttribute("TRACK01_LIGHT_PULSE_ENABLED",true)
    applyLightingPreset("STANDARD")
    musicSound:Pause()
    musicSound.Volume=0.55
end

query.OnServerInvoke=function(player)
    local authorized=isAuthorized(player)
    player:SetAttribute("TRACK01_ADMIN_AUTHORIZED",authorized)
    if not authorized then return {authorized=false} end
    local data=snapshot()
    data.authorized=true
    return data
end

command.OnServerEvent:Connect(function(player,action,value)
    if not isAuthorized(player) then
        player:SetAttribute("TRACK01_ADMIN_AUTHORIZED",false)
        return
    end
    local now=os.clock()
    if lastCommandAt[player] and now-lastCommandAt[player]<COMMAND_COOLDOWN then return end
    lastCommandAt[player]=now
    lastOperator=player.DisplayName.." @"..player.Name

    if action=="EVENT_PRESET" and validEventPreset[value] then
        applyEventPreset(value)
    elseif action=="OPS_RESET" then
        resetOperations()
    elseif action=="VENUE_STATUS" and validVenueStatus[value] then
        Workspace:SetAttribute("TRACK01_VENUE_STATUS",value)
        if value=="CLOSING" then announceEvent:FireAllClients(paPresets.CLOSING) end
    elseif action=="EVENT_MODE" and validEventMode[value] then
        Workspace:SetAttribute("TRACK01_EVENT_MODE",value)
        if value=="END_OF_LINE" then announceEvent:FireAllClients(paPresets.END_OF_LINE)
        elseif value=="LAST_TRAIN" then announceEvent:FireAllClients(paPresets.LAST_TRAIN) end
    elseif action=="LIGHTING_PRESET" and type(value)=="string" then
        applyLightingPreset(value)
    elseif action=="PULSE" and type(value)=="boolean" then
        Workspace:SetAttribute("TRACK01_LIGHT_PULSE_ENABLED",value)
    elseif action=="PA_PRESET" and type(value)=="string" and paPresets[value] then
        announceEvent:FireAllClients(paPresets[value])
    elseif action=="MUSIC_PLAY" then
        if musicConfigured() then musicSound:Play() end
    elseif action=="MUSIC_PAUSE" then
        musicSound:Pause()
    elseif action=="MUSIC_VOLUME" then
        setMusicVolume(value)
    elseif action=="MUSIC_RESTART" then
        if musicConfigured() then musicSound.TimePosition=0; musicSound:Play() end
    elseif action=="RETURN_LOBBY" then
        local target=resolveTarget(value)
        if target then returnToLobby(target) end
    elseif action=="RESPAWN" then
        local target=resolveTarget(value)
        if target then target:LoadCharacter() end
    else
        return
    end
    pushState()
end)

Workspace:SetAttribute("ACC_TRACK01_ADMIN_PANEL_READY",true)
Workspace:SetAttribute("ACC_TRACK01_PANEL_VERSION","4.1.0")
Workspace:SetAttribute("ACC_TRACK01_DJ_EVENT_OPS_READY",true)
print("[TRACK 01] v4.1 DJ/music + event operations server ready")
