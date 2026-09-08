-- HANGAR EXCLUSIVE CLUB — LAB VISUAL FIREWALL v10
-- TEST LAB ONLY. Prevents legacy v1/v7/v8/v9 visuals from flashing/reappearing.
-- OWNER LOCK: NO LASERS. NO CYAN SPAWN. NO LEGACY PROXY GEOMETRY.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local LAB_PLACE_ID = 124607344716828
if game.PlaceId ~= LAB_PLACE_ID then
    return
end

Workspace:SetAttribute("HangarLabVisualFirewall", "V10_ACTIVE")
Workspace:SetAttribute("HangarLabLasers", "DISABLED_BY_OWNER")

local function destroyIf(parent, name)
    if not parent then return end
    local x = parent:FindFirstChild(name)
    if x then x:Destroy() end
end

local function sanitize()
    -- Never allow sky/galaxy/cloud leakage in the LAB hangar.
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") or child:IsA("Atmosphere") then
            child:Destroy()
        end
    end
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        for _, child in ipairs(terrain:GetChildren()) do
            if child:IsA("Clouds") then child:Destroy() end
        end
    end

    -- Cyan spawn slab must never be visible.
    local spawn = Workspace:FindFirstChild("HangarSpawn")
    if spawn and spawn:IsA("SpawnLocation") then
        spawn.Transparency = 1
        spawn.Material = Enum.Material.SmoothPlastic
        spawn.Color = Color3.fromRGB(28, 30, 34)
        spawn.CanCollide = false
        spawn.Duration = 0
    end

    -- Owner directive: absolutely no laser system in Hangar LAB.
    local lightingSystem = Workspace:FindFirstChild("LightingSystem")
    if lightingSystem then
        destroyIf(lightingSystem, "Lasers")
        destroyIf(lightingSystem, "StageLights")
    end

    local map = Workspace:FindFirstChild("Map")
    if map then
        destroyIf(map, "MovingLaserRigV10")
        destroyIf(map, "HangarV7EnclosedInterior")
        destroyIf(map, "HangarFullMeshV8")
        destroyIf(map, "HangarFullMeshV8_BUILDING")
        destroyIf(map, "HangarFullMeshV9_STATIC")
        destroyIf(map, "HangarXLVisualRescue")
        destroyIf(map, "FullMeshV2")

        -- These folders belong to the old procedural/proxy builder only.
        -- The reference-locked v10 static model is parented directly under Map.
        for _, folderName in ipairs({"Architecture", "Vehicles", "Furniture"}) do
            local folder = map:FindFirstChild(folderName)
            if folder then
                for _, child in ipairs(folder:GetChildren()) do
                    child:Destroy()
                end
            end
        end
    end

    -- Keep DJMusic Sound authority but hide any old speaker boxes.
    local audioSystem = Workspace:FindFirstChild("AudioSystem")
    local speakers = audioSystem and audioSystem:FindFirstChild("MainSpeakers")
    if speakers then
        for _, d in ipairs(speakers:GetDescendants()) do
            if d:IsA("BasePart") then
                d.Transparency = 1
                d.CanCollide = false
                d.CastShadow = false
            end
        end
    end
end

-- Run immediately, then every frame during startup so club.server cannot race
-- legacy visuals back into the LAB scene. After startup, keep a light watchdog.
sanitize()
local started = os.clock()
local conn
conn = RunService.Heartbeat:Connect(function()
    sanitize()
    if os.clock() - started > 20 then
        conn:Disconnect()
        task.spawn(function()
            while game.PlaceId == LAB_PLACE_ID do
                sanitize()
                task.wait(2)
            end
        end)
    end
end)

print("[HANGAR LAB V10] visual firewall active — no lasers / no cyan spawn / no legacy proxies")
