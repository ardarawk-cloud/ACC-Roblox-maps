-- BBYA SOCIAL HUB — AFK DETECTOR v2
-- Automatic inactivity remains status-only. Manual AFK SIGN is never cleared by ordinary input/movement; only a second Party Stuff tap clears it.
-- Does not stop/replace animations, emotes, dance, carry, tools, movement, or camera.

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
local autoReported=false
local lastMovementCheck=0

local function manualActive()return player:GetAttribute("BBYAAFKManual")==true end
local function reportAuto(value)
 value=value==true
 if manualActive() then autoReported=false;return end
 if autoReported==value then return end
 autoReported=value
 remote:FireServer(value)
end
local function markActive()
 lastActive=os.clock()
 if not manualActive() and autoReported then reportAuto(false) end
end

player.Idled:Connect(function()
 if not manualActive() and os.clock()-lastActive>=IDLE_SECONDS-2 then reportAuto(true) end
end)
UserInputService.InputBegan:Connect(function()markActive()end)
UserInputService.InputChanged:Connect(function(input)
 local t=input.UserInputType
 if t==Enum.UserInputType.MouseMovement or t==Enum.UserInputType.MouseWheel or t==Enum.UserInputType.Touch
  or t==Enum.UserInputType.Gamepad1 or t==Enum.UserInputType.Gamepad2 or t==Enum.UserInputType.Gamepad3 or t==Enum.UserInputType.Gamepad4 then markActive() end
end)

local function bindCharacter(character)
 lastActive=os.clock();autoReported=false
 if not manualActive() then remote:FireServer(false) end
 character:WaitForChild("Humanoid",10)
end
if player.Character then task.defer(bindCharacter,player.Character) end
player.CharacterAdded:Connect(bindCharacter)
player:GetAttributeChangedSignal("BBYAAFKManual"):Connect(function()
 lastActive=os.clock();autoReported=false
end)

RunService.Heartbeat:Connect(function()
 local now=os.clock();if now-lastMovementCheck<.25 then return end;lastMovementCheck=now
 local character=player.Character;local humanoid=character and character:FindFirstChildOfClass("Humanoid")
 if humanoid and humanoid.MoveDirection.Magnitude>.05 then
  markActive()
 elseif not manualActive() and not autoReported and now-lastActive>=IDLE_SECONDS then
  reportAuto(true)
 end
end)

print("[BBYA] AFK detector v2 online: auto 120s + manual-sign-safe activity handling")