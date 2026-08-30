local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")

-- TRACK 01 v4.0 admin panel server authority.
-- Compact operator controls only. No uploaded audio, currency, ticket economy, or map redesign.
-- Every state-changing command is re-authorized on the server.

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
local GROUP_ADMIN_MIN_RANK=200
local lastCommandAt={}
local COMMAND_COOLDOWN=0.20

local lightingPresets={
    STANDARD={brightness=1.80,exposure=0.12}, -- v3.9.1 verified night balance
    READABLE={brightness=2.02,exposure=0.22}, -- modest mobile readability lift, still night
    LOW_NIGHT={brightness=1.55,exposure=-0.02},
}

local paPresets={
    BOARDING={
        kicker="TRACK 01 • BOARDING CALL",
        voice="Perhatian. Boarding Track Zero One melalui Platform Zero One sedang dibuka. Pastikan Night Ticket Anda sudah siap sebelum memasuki gerbong.",
        caption="BOARDING OPEN • NIGHT TICKET REQUIRED • PLATFORM 01",
        warning=false,
    },
    NIGHT_SERVICE={
        kicker="TRACK 01 • NIGHT SERVICE",
        voice="Perhatian. Layanan malam Track Zero One sedang beroperasi. Car Zero One lounge. Car Zero Two bar. Car Zero Three dance. Car Zero Four, End of Line.",
        caption="NIGHT SERVICE • CAR 01 LOUNGE • 02 BAR • 03 DANCE • 04 END OF LINE",
        warning=false,
    },
    END_OF_LINE={
        kicker="TRACK 01 • END OF LINE",
        voice="End of Line announcement. Car Zero Four dan area The Yard sedang aktif. No destination. Just the night.",
        caption="END OF LINE • CAR 04 • THE YARD • NO DESTINATION. JUST THE NIGHT.",
        warning=false,
    },
    CLOSING={
        kicker="TRACK 01 • CLOSING",
        voice="Perhatian. Track Zero One memasuki layanan penutupan. Silakan selesaikan aktivitas Anda dan kembali menuju Station Lobby dengan tertib.",
        caption="CLOSING SERVICE • RETURN TOWARD STATION LOBBY",
        warning=false,
    },
}

local validVenueStatus={NIGHT_SERVICE=true,BOARDING_HOLD=true,CLOSING=true}
local validEventMode={NONE=true,END_OF_LINE=true,LAST_TRAIN=true}

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
    if optionalAllowlistContains(player.UserId) then return true end
    if game.CreatorType==Enum.CreatorType.User then
        return player.UserId==game.CreatorId
    end
    if game.CreatorType==Enum.CreatorType.Group then
        local ok,rank=pcall(function()
            return player:GetRankInGroup(game.CreatorId)
        end)
        return ok and rank>=GROUP_ADMIN_MIN_RANK
    end
    return false
end

local function setupPlayer(player)
    player:SetAttribute("TRACK01_ADMIN_AUTHORIZED",isAuthorized(player))
end
for _,player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
    lastCommandAt[player]=nil
end)

if Workspace:GetAttribute("TRACK01_VENUE_STATUS")==nil then
    Workspace:SetAttribute("TRACK01_VENUE_STATUS","NIGHT_SERVICE")
end
if Workspace:GetAttribute("TRACK01_EVENT_MODE")==nil then
    Workspace:SetAttribute("TRACK01_EVENT_MODE","NONE")
end
if Workspace:GetAttribute("TRACK01_LIGHT_PULSE_ENABLED")==nil then
    Workspace:SetAttribute("TRACK01_LIGHT_PULSE_ENABLED",true)
end
if Workspace:GetAttribute("TRACK01_LIGHTING_PRESET")==nil then
    Workspace:SetAttribute("TRACK01_LIGHTING_PRESET","STANDARD")
end

local function snapshot()
    return {
        venueStatus=Workspace:GetAttribute("TRACK01_VENUE_STATUS") or "NIGHT_SERVICE",
        eventMode=Workspace:GetAttribute("TRACK01_EVENT_MODE") or "NONE",
        pulseEnabled=Workspace:GetAttribute("TRACK01_LIGHT_PULSE_ENABLED")~=false,
        lightingPreset=Workspace:GetAttribute("TRACK01_LIGHTING_PRESET") or "STANDARD",
        featureComplete=Workspace:GetAttribute("ACC_TRACK01_FEATURE_COMPLETE")==true,
        liveSourceVersion=Workspace:GetAttribute("ACC_TRACK01_VERSION") or "UNKNOWN",
        playerCount=#Players:GetPlayers(),
    }
end

local function pushState()
    local data=snapshot()
    for _,player in ipairs(Players:GetPlayers()) do
        if isAuthorized(player) then
            stateEvent:FireClient(player,data)
        end
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
    for _,player in ipairs(Players:GetPlayers()) do
        if player.UserId==userId then return player end
    end
    return nil
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

    if action=="VENUE_STATUS" and validVenueStatus[value] then
        Workspace:SetAttribute("TRACK01_VENUE_STATUS",value)
        if value=="CLOSING" then announceEvent:FireAllClients(paPresets.CLOSING) end
    elseif action=="EVENT_MODE" and validEventMode[value] then
        Workspace:SetAttribute("TRACK01_EVENT_MODE",value)
        if value=="END_OF_LINE" then announceEvent:FireAllClients(paPresets.END_OF_LINE) end
    elseif action=="LIGHTING_PRESET" and type(value)=="string" then
        applyLightingPreset(value)
    elseif action=="PULSE" and type(value)=="boolean" then
        Workspace:SetAttribute("TRACK01_LIGHT_PULSE_ENABLED",value)
    elseif action=="PA_PRESET" and type(value)=="string" and paPresets[value] then
        announceEvent:FireAllClients(paPresets[value])
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
Workspace:SetAttribute("ACC_TRACK01_PANEL_VERSION","4.0.0")
print("[TRACK 01] server-authoritative admin panel ready v4.0.0")
