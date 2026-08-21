-- BBYA SOCIAL HUB — AUDIO HEALTH GUARD v3
-- Detects the Roblox failure mode where Sound:IsPlaying is true but the asset never loads/advances.
-- Keeps Main Club + Basement from going permanently silent while preserving the expanded 29-track library.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
if not remotes then return end
local internalMusic=remotes:WaitForChild("InternalMusic",30)
if not internalMusic or not internalMusic:IsA("BindableEvent") then return end

local group=SoundService:WaitForChild("BBYAClubMaster",30)
if group and group:IsA("SoundGroup") then
    group:SetAttribute("AudioHealthGuard",true)
    group:SetAttribute("AudioHealthVersion","V3_LOAD_PROGRESS")
end

-- These are the original BBYA core tracks that were already used before the expanded library.
-- We use them only as recovery anchors; the 22 additional tracks remain available in the library/rotation.
local SAFE_CORE={1,2,3,4,5,6,7}
local rng=Random.new(os.time()%2147483646)
local lastRecovery=0
local lastPositions={}
local stagnantFor=0
local noLoadedAudioFor=0

local function decks()
    return SoundService:FindFirstChild("BBYAClubDeckA"),SoundService:FindFirstChild("BBYAClubDeckB")
end

local function isAudibleCandidate(s)
    if not s or not s:IsA("Sound") then return false end
    if s.PlaybackState==Enum.PlaybackState.Paused then return false end
    return s.IsPlaying and s.Volume>.04
end

local function healthyLoaded(s)
    if not isAudibleCandidate(s) then return false end
    return (s.TimeLength or 0)>2
end

local function chooseSafe()
    local pick=SAFE_CORE[rng:NextInteger(1,#SAFE_CORE)]
    if #SAFE_CORE>1 and pick==lastRecovery then
        for _=1,4 do
            local alt=SAFE_CORE[rng:NextInteger(1,#SAFE_CORE)]
            if alt~=lastRecovery then pick=alt;break end
        end
    end
    lastRecovery=pick
    return pick
end

local function recover(reason)
    local idx=chooseSafe()
    internalMusic:Fire("play",nil,idx)
    if group and group:IsA("SoundGroup") then
        group.Volume=math.max(group.Volume,.94)
        group:SetAttribute("LastRecoveryReason",reason)
        group:SetAttribute("LastRecoveryTrack",idx)
        group:SetAttribute("LastRecoveryAt",os.time())
    end
    warn(string.format("[BBYA] Audio health recovery (%s) -> core track %d",reason,idx))
end

while task.wait(1.5) do
    local a,b=decks()
    if group and group:IsA("SoundGroup") and group.Volume<=0 then group.Volume=1 end

    local paused=(a and a.PlaybackState==Enum.PlaybackState.Paused) or (b and b.PlaybackState==Enum.PlaybackState.Paused)
    if paused then
        stagnantFor=0;noLoadedAudioFor=0
        continue
    end

    local candidates={}
    if isAudibleCandidate(a) then table.insert(candidates,a) end
    if isAudibleCandidate(b) then table.insert(candidates,b) end

    if #candidates==0 then
        noLoadedAudioFor+=1.5
        stagnantFor=0
        if noLoadedAudioFor>=4.5 then
            recover("no_active_deck")
            noLoadedAudioFor=0
        end
        continue
    end

    local anyLoaded=false
    local anyAdvanced=false
    for _,s in ipairs(candidates) do
        if healthyLoaded(s) then anyLoaded=true end
        local pos=s.TimePosition or 0
        local previous=lastPositions[s] or pos
        if pos>previous+.08 then anyAdvanced=true end
        lastPositions[s]=pos
    end

    if not anyLoaded then
        noLoadedAudioFor+=1.5
    else
        noLoadedAudioFor=0
    end

    if anyAdvanced then stagnantFor=0 else stagnantFor+=1.5 end

    -- A Sound can report IsPlaying=true while an inaccessible/private asset has TimeLength 0 forever.
    if noLoadedAudioFor>=5 then
        recover("asset_not_loaded")
        noLoadedAudioFor=0;stagnantFor=0
    elseif stagnantFor>=6 then
        recover("timeline_not_advancing")
        stagnantFor=0;noLoadedAudioFor=0
    end
end
