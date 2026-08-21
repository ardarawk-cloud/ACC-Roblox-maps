-- BBYA SOCIAL HUB — HYBRID AUTODJ RECOVERY WATCHDOG v2
-- Recovers silent/stopped decks by asking AutoDJ for another random track.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",20)
if not remotes then return end
local internalMusic=remotes:WaitForChild("InternalMusic",20)
if not internalMusic or not internalMusic:IsA("BindableEvent") then return end

local deadFor=0
local function deckState(sound)
 if not sound or not sound:IsA("Sound") then return "missing" end
 if sound.PlaybackState==Enum.PlaybackState.Paused then return "paused" end
 if sound.IsPlaying then return "playing" end
 return "stopped"
end

while task.wait(2.5) do
 local group=SoundService:FindFirstChild("BBYAClubMaster")
 if group and group:IsA("SoundGroup") and group.Volume<=0 then group.Volume=1 end
 local a=SoundService:FindFirstChild("BBYAClubDeckA")
 local b=SoundService:FindFirstChild("BBYAClubDeckB")
 local sa,sb=deckState(a),deckState(b)
 if sa=="paused" or sb=="paused" then deadFor=0
 elseif sa=="playing" or sb=="playing" then deadFor=0
 else
  deadFor+=2.5
  if deadFor>=5 then
   internalMusic:Fire("random")
   deadFor=0
   warn("[BBYA] Hybrid AutoDJ watchdog recovery -> random track")
  end
 end
end
