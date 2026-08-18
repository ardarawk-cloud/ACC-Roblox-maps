-- BBYA SOCIAL HUB — CLEAN REBUILD RUNTIME

local spawn=Instance.new("SpawnLocation")
spawn.Name="BBYA ARRIVAL SPAWN"
spawn.Size=Vector3.new(12,.6,8)
spawn.CFrame=CFrame.new(0,1.4,-79)*CFrame.Angles(0,math.rad(180),0)
spawn.Anchored=true
spawn.Neutral=true
spawn.CanCollide=true
spawn.Transparency=.82
spawn.Material=Enum.Material.SmoothPlastic
spawn.Color=Color3.fromRGB(72,190,126)
spawn.Parent=A1

local safeCFrame=CFrame.new(0,4,-72)*CFrame.Angles(0,math.rad(180),0)
local function bindCharacter(char)
    local root=char:WaitForChild("HumanoidRootPart",10)
    if not root then return end
    task.spawn(function()
        while char.Parent and root.Parent do
            if root.Position.Y < -28 then
                root.CFrame=safeCFrame
                root.AssemblyLinearVelocity=Vector3.zero
                root.AssemblyAngularVelocity=Vector3.zero
            end
            task.wait(.5)
        end
    end)
end

for _,plr in ipairs(Players:GetPlayers()) do
    if plr.Character then bindCharacter(plr.Character) end
    plr.CharacterAdded:Connect(bindCharacter)
end
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(bindCharacter)
end)

-- Small in-world route signs only; architecture remains the primary navigation.
sign(A2,"ROUTE CLUB","CLUB  ←",CFrame.new(-2,6,-4),Vector3.new(11,2,.25),C.pink,Enum.NormalId.Front)
sign(A2,"ROUTE VIP","VIP  →",CFrame.new(38,6,-4),Vector3.new(11,2,.25),C.gold,Enum.NormalId.Front)
sign(A5,"ROUTE ROOF","ROOFTOP  ↑",CFrame.new(92,8,74),Vector3.new(14,2,.25),C.cyan,Enum.NormalId.Front)

ROOT:SetAttribute("SpawnReady",true)
ROOT:SetAttribute("SafetyRuntime",true)
ROOT:SetAttribute("RuntimePhase","PHASE_2_PREMIUM_BUILD")
workspace:SetAttribute("BBYARuntime","ACTIVE_PHASE_2")
