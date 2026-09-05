-- BBYA SOCIAL HUB — AFK DETECTOR v1
-- Detects genuine local inactivity and reports status only.
-- Any input or Humanoid MoveDirection clears AFK. Does not stop/replace animations, emotes, dance, carry, tools, or camera.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local remote=remotes and remotes:WaitForChild("AFKStatus",30)
if not remote then return end

local IDLE_SECONDS=120
local lastActive=os.clock()
local localAfk=false
local lastMovementCheck=0

local function report(value)
 value=value==true
 if localAfk==value then return end
 localAfk=value
 remote:FireServer(value)
end

local function markActive()
 lastActive=os.clock()
 if localAfk then report(false) end
end

player.Idled:Connect(function()
 if os.clock()-lastActive>=IDLE_SECONDS-2 then report(true) end
end)

UserInputService.InputBegan:Connect(function(_,gameProcessed)
 -- Game-processed input still proves the player is present (chat/menu/UI counts as activity).
 markActive()
end)

UserInputService.InputChanged:Connect(function(input)
 local t=input.UserInputType
 if t==Enum.UserInputType.MouseMovement
  or t==Enum.UserInputType.MouseWheel
  or t==Enum.UserInputType.Touch
  or t==Enum.UserInputType.Gamepad1
  or t==Enum.UserInputType.Gamepad2
  or t==Enum.UserInputType.Gamepad3
  or t==Enum.UserInputType.Gamepad4 then
  markActive()
 end
end)

local function bindCharacter(character)
 lastActive=os.clock()
 report(false)
 character:WaitForChild("Humanoid",10)
end
if player.Character then task.defer(bindCharacter,player.Character) end
player.CharacterAdded:Connect(bindCharacter)

RunService.Heartbeat:Connect(function()
 local now=os.clock()
 if now-lastMovementCheck<.25 then return end
 lastMovementCheck=now
 local character=player.Character
 local humanoid=character and character:FindFirstChildOfClass("Humanoid")
 if humanoid and humanoid.MoveDirection.Magnitude>.05 then
  markActive()
 elseif not localAfk and now-lastActive>=IDLE_SECONDS then
  report(true)
 end
end)

print("[BBYA] AFK detector v1 online: 120s idle / any input or movement clears / animation-safe")
