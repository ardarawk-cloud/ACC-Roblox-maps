-- BBYA SOCIAL HUB — AUTODJ RECOVERY WATCHDOG v1
-- Recovers silent/stopped decks without interfering with an intentional pause.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",20)
if not remotes then return end
local internalMusic=remotes:WaitForChild("InternalMusic",20)
if not internalMusic or not internalMusic:IsA("BindableEvent") then return end

local deadFor=0
local recoveryIndex=1
local RECOVERY_ORDER={1,2,3,4,5,6,7}

local function deckState(sound)
 if not sound or not sound:IsA("Sound") then return "missing" end
 if sound.PlaybackState==Enum.PlaybackState.Paused then return "paused" end
 if sound.IsPlaying then return "playing" end
 return "stopped"
end

while task.wait(2.5) do
 local group=SoundService:FindFirstChild("BBYAClubMaster")
 if group and group:IsA("SoundGroup") then
  -- Local client balancing still applies independently; server master must never be accidentally zeroed.
  if group.Volume<=0 then group.Volume=1 end
 end

 local a=SoundService:FindFirstChild("BBYAClubDeckA")
 local b=SoundService:FindFirstChild("BBYAClubDeckB")
 local sa=deckState(a)
 local sb=deckState(b)

 if sa=="paused" or sb=="paused" then
  deadFor=0
 elseif sa=="playing" or sb=="playing" then
  deadFor=0
  recoveryIndex=1
 else
  deadFor+=2.5
  if deadFor>=5 then
   local track=RECOVERY_ORDER[recoveryIndex]
   recoveryIndex=(recoveryIndex%#RECOVERY_ORDER)+1
   internalMusic:Fire("play",nil,track)
   deadFor=0
   warn(string.format("[BBYA] AutoDJ watchdog recovery -> track %d",track))
  end
 end
end
