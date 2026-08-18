-- BBYA SOCIAL HUB — FINAL ARRIVAL SPAWN v1.0
-- Positions the player at the premium arrival court. No duplicate signage or neon box.

local Players = game:GetService("Players")

local spawn
for _,obj in ipairs(workspace:GetDescendants()) do
 if obj:IsA("SpawnLocation") then spawn=obj break end
end

if not spawn then
 spawn=Instance.new("SpawnLocation")
 spawn.Name="BBYA Arrival Spawn"
 spawn.Size=Vector3.new(10,1,10)
 spawn.Anchored=true
 spawn.Parent=workspace
end

-- Premium arrival courtyard faces toward the lobby/club (negative Z).
spawn.CFrame=CFrame.new(0,3,111)*CFrame.Angles(0,math.rad(180),0)
spawn.Transparency=1
spawn.CanCollide=false
spawn.CanTouch=false
spawn.Neutral=true
spawn.Duration=0

local function safeArrival(character)
 local hrp=character:WaitForChild("HumanoidRootPart",8)
 if not hrp then return end
 -- Only correct clearly invalid/fallen spawn positions; normal respawn remains native.
 if hrp.Position.Y < -20 then
  character:PivotTo(spawn.CFrame*CFrame.new(0,4,0))
 end
end

local function hook(player)
 player.CharacterAdded:Connect(function(character) task.defer(safeArrival,character) end)
end
Players.PlayerAdded:Connect(hook)
for _,player in ipairs(Players:GetPlayers()) do hook(player) end

workspace:SetAttribute("BBYAFinalSpawnReady",true)
print("[BBYA] Final Arrival Spawn v1.0 loaded")
