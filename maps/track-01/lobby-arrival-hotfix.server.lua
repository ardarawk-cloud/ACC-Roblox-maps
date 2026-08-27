local Workspace=game:GetService("Workspace")
local Players=game:GetService("Players")

-- TRACK 01 v3.7.1 lobby-arrival correction.
-- First arrival belongs inside the old-station lobby, facing ticketing, not on Platform 01.
-- The existing Night Ticket / check-in / boarding flow remains unchanged.
local deadline=os.clock()+30
local root
local spawn
repeat
    root=Workspace:FindFirstChild("ACC_TRACK01")
    spawn=root and root:FindFirstChild("TRACK01_SPAWN",true)
    if spawn and spawn:IsA("BasePart") then break end
    task.wait(0.10)
until os.clock()>deadline

if not (root and spawn and spawn:IsA("BasePart")) then
    warn("[TRACK 01] v3.7.1 lobby arrival: TRACK01_SPAWN missing")
    return
end

-- Inner lobby: safely clear of the ticket counter and ticket machine.
-- Camera faces toward ticketing so the first thing a visitor reads is the entry flow,
-- while Platform 01 remains the destination after ticket/check-in.
local LOBBY_POS=Vector3.new(-38,2.05,-123)
local TICKETING_LOOK=Vector3.new(-20,4.0,-118)
local LOBBY_CF=CFrame.lookAt(LOBBY_POS,TICKETING_LOOK)

spawn.CFrame=LOBBY_CF
spawn.Size=Vector3.new(8,1,8)
spawn.Transparency=1
spawn.CanCollide=false
spawn.Neutral=true

-- Guarantee the first character of a freshly-created server is also corrected even if
-- CharacterAutoLoads wins a race against this server script. Subsequent respawns use
-- the corrected SpawnLocation and are not forcibly teleported.
local function placeFirstArrival(plr,character)
    if plr:GetAttribute("TRACK01_LOBBY_FIRST_ARRIVAL_DONE") then return end
    local hrp=character:WaitForChild("HumanoidRootPart",8)
    if not hrp then return end
    task.wait(0.12)
    if plr:GetAttribute("TRACK01_LOBBY_FIRST_ARRIVAL_DONE") then return end
    hrp.CFrame=LOBBY_CF*CFrame.new(0,3.2,0)
    hrp.AssemblyLinearVelocity=Vector3.zero
    hrp.AssemblyAngularVelocity=Vector3.zero
    plr:SetAttribute("TRACK01_LOBBY_FIRST_ARRIVAL_DONE",true)
end

local function bind(plr)
    if plr.Character then task.spawn(placeFirstArrival,plr,plr.Character) end
    plr.CharacterAdded:Connect(function(character)
        task.spawn(placeFirstArrival,plr,character)
    end)
end
for _,plr in ipairs(Players:GetPlayers()) do bind(plr) end
Players.PlayerAdded:Connect(bind)

root:SetAttribute("LobbyArrivalVersion","3.7.1")
root:SetAttribute("LobbySpawnX",LOBBY_POS.X)
root:SetAttribute("LobbySpawnZ",LOBBY_POS.Z)
Workspace:SetAttribute("ACC_TRACK01_LOBBY_ARRIVAL_READY",true)
print("[TRACK 01] v3.7.1 lobby arrival corrected",LOBBY_POS)
