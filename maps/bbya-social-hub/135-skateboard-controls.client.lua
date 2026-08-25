-- BBYA SOCIAL HUB — SKATEBOARD MOBILE CONTROL BRIDGE v4
-- Sends the active rider's local joystick / VehicleSeat input to the server authority.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local remote=ReplicatedStorage:WaitForChild("BBYASkateControlV4",30)
if not remote then return end

local lastSend=0
RunService.RenderStepped:Connect(function()
 local char=player.Character
 local hum=char and char:FindFirstChildOfClass("Humanoid")
 local seat=hum and hum.SeatPart
 if not seat or seat.Name~="BBYASkateSeat" or seat:GetAttribute("BBYASkateSeatV4")~=true then return end
 local model=seat.Parent
 if not model or not model:GetAttribute("BBYARideableSkateboard") then return end

 local now=os.clock()
 if now-lastSend<0.05 then return end
 lastSend=now

 local move=hum.MoveDirection
 local throttle=seat:IsA("VehicleSeat") and seat.ThrottleFloat or 0
 local steer=seat:IsA("VehicleSeat") and seat.SteerFloat or 0
 remote:FireServer(model,move.X,move.Z,throttle,steer)
end)
