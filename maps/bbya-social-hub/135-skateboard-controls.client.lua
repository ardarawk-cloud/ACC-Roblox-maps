-- BBYA SOCIAL HUB — SKATEBOARD DIRECT CONTROL BRIDGE v5
-- Uses PlayerModule move vector while seated, so mobile thumbstick does not depend on VehicleSeat throttle.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local Workspace=game:GetService("Workspace")

local player=Players.LocalPlayer
local playerScripts=player:WaitForChild("PlayerScripts")
local playerModule=require(playerScripts:WaitForChild("PlayerModule"))
local controls=playerModule:GetControls()
local remote=ReplicatedStorage:WaitForChild("BBYASkateControlV5",30)
if not remote then return end

local lastSend=0
local SEND_INTERVAL=1/20

local function keyboardMove()
 local x,z=0,0
 if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then x-=1 end
 if UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then x+=1 end
 if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then z-=1 end
 if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then z+=1 end
 local v=Vector3.new(x,0,z)
 return v.Magnitude>1 and v.Unit or v
end

local function localMoveVector()
 local move=Vector3.zero
 local ok,result=pcall(function() return controls:GetMoveVector() end)
 if ok and typeof(result)=="Vector3" then move=Vector3.new(result.X,0,result.Z) end
 if move.Magnitude<.05 then move=keyboardMove() end
 return move.Magnitude>1 and move.Unit or move
end

local function worldMove(localMove)
 if localMove.Magnitude<.05 then return Vector3.zero end
 local cam=Workspace.CurrentCamera
 if not cam then return Vector3.zero end
 local look=Vector3.new(cam.CFrame.LookVector.X,0,cam.CFrame.LookVector.Z)
 local right=Vector3.new(cam.CFrame.RightVector.X,0,cam.CFrame.RightVector.Z)
 if look.Magnitude<.05 or right.Magnitude<.05 then return Vector3.zero end
 look=look.Unit;right=right.Unit
 -- PlayerModule uses negative local Z for forward.
 local world=right*localMove.X + look*(-localMove.Z)
 return world.Magnitude>1 and world.Unit or world
end

RunService.RenderStepped:Connect(function()
 local char=player.Character
 local hum=char and char:FindFirstChildOfClass("Humanoid")
 local seat=hum and hum.SeatPart
 if not seat or seat.Name~="BBYASkateSeat" or seat:GetAttribute("BBYASkateSeatV5")~=true then return end
 local model=seat.Parent
 if not model or model:GetAttribute("BBYARideableSkateboard")~=true then return end
 local now=os.clock()
 if now-lastSend<SEND_INTERVAL then return end
 lastSend=now
 local localMove=localMoveVector()
 local move=worldMove(localMove)
 remote:FireServer(model,move.X,move.Z,localMove.Magnitude)
end)
