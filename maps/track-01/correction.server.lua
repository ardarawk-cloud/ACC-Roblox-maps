local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")

-- TRACK 01 v2.2 color-correction pass.
-- Runs after the v2 upgrade + v2.1 polish and specifically fixes the visual issue
-- seen in live mobile preview: the train must read as an OLD RED TRAIN first,
-- with rust only as localized weathering.
local deadline=os.clock()+30
repeat task.wait(0.15) until Workspace:GetAttribute("ACC_TRACK01_POLISH_READY") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
local train=world and world:FindFirstChild("TrainCars")
local upgrade=world and world:FindFirstChild("TRACK01_Upgrade_v2")
local polish=world and world:FindFirstChild("TRACK01_FinalPolish_v21")
local architecture=world and world:FindFirstChild("Architecture")
if not (world and train and upgrade and architecture) then return end

root:SetAttribute("CorrectionVersion","2.2.0")
root:SetAttribute("TrainVisualLock","Faded dark-red painted railcar; localized rust only")

local C={
    red=Color3.fromRGB(112,30,33),
    red2=Color3.fromRGB(124,36,37),
    redDark=Color3.fromRGB(67,22,25),
    redShadow=Color3.fromRGB(82,25,28),
    rust=Color3.fromRGB(105,53,39),
    rustDark=Color3.fromRGB(67,39,33),
    charcoal=Color3.fromRGB(30,31,31),
    steel=Color3.fromRGB(72,74,73),
    steel2=Color3.fromRGB(92,93,89),
    cream=Color3.fromRGB(170,151,116),
    glass=Color3.fromRGB(48,60,64),
    neutralWarm=Color3.fromRGB(235,220,201),
}

-- Painted body pass: keep the carriage old and matte-looking without using the
-- orange-heavy CorrodedMetal material over the whole shell.
for carNumber,car in ipairs(train:GetChildren()) do
    if car:IsA("Folder") then
        local bodyColor=(carNumber%2==0) and C.red2 or C.red
        for _,obj in ipairs(car:GetDescendants()) do
            if obj:IsA("BasePart") then
                if obj.Name=="LowerBody" then
                    obj.Color=bodyColor
                    obj.Material=Enum.Material.Metal
                    obj.Reflectance=0.02
                elseif obj.Name=="EndSideL" or obj.Name=="EndSideR" then
                    obj.Color=C.redShadow
                    obj.Material=Enum.Material.Metal
                    obj.Reflectance=0.01
                elseif obj.Name=="UpperRail" then
                    obj.Color=C.redDark
                    obj.Material=Enum.Material.Metal
                elseif obj.Name=="Stripe" then
                    obj.Color=C.cream
                    obj.Material=Enum.Material.Metal
                    obj.Transparency=0.18
                elseif obj.Name=="WindowSill" or obj.Name=="WindowTop" then
                    obj.Color=C.steel2
                    obj.Material=Enum.Material.Metal
                elseif string.find(obj.Name,"DoorFrame") or obj.Name=="DoorHeader" then
                    obj.Color=C.steel
                    obj.Material=Enum.Material.Metal
                elseif obj.Name=="RoofBand" then
                    obj.Color=C.charcoal
                    obj.Material=Enum.Material.Metal
                elseif obj.Name=="WindowGlass" then
                    obj.Color=C.glass
                elseif obj.Name=="Bogie" then
                    obj.Color=Color3.fromRGB(20,21,21)
                    obj.Material=Enum.Material.Metal
                elseif obj.Name=="Wheel" or obj.Name=="Hub" then
                    obj.Color=Color3.fromRGB(40,40,38)
                    obj.Material=Enum.Material.Metal
                elseif string.find(obj.Name,"Coupler") then
                    obj.Color=C.rustDark
                    obj.Material=Enum.Material.CorrodedMetal
                end
            end
        end
    end
end

-- Reduce the v2 weathering layer. The previous pass was intentionally heavy,
-- but on Roblox mobile CorrodedMetal made the whole train read orange.
local trainDetails=upgrade:FindFirstChild("RustyTrainDetails")
if trainDetails then
    for _,obj in ipairs(trainDetails:GetDescendants()) do
        if obj:IsA("BasePart") then
            if obj.Name=="RustPatch" then
                obj.Color=C.rust
                obj.Transparency=0.58
                obj.Size=Vector3.new(obj.Size.X,math.max(0.35,obj.Size.Y*0.55),math.max(0.65,obj.Size.Z*0.55))
            elseif obj.Name=="RustDrip" then
                obj.Color=C.rustDark
                obj.Transparency=0.68
                obj.Size=Vector3.new(obj.Size.X,math.max(0.45,obj.Size.Y*0.62),obj.Size.Z)
            elseif obj.Name=="RoofOxide" then
                obj.Color=C.rustDark
                obj.Transparency=0.72
            elseif obj.Name=="GrimeSkirt" then
                obj.Color=Color3.fromRGB(27,28,27)
                obj.Transparency=0.20
            elseif obj.Name=="BodyRib" then
                obj.Color=C.redDark
                obj.Material=Enum.Material.Metal
                obj.Transparency=0.05
            elseif obj.Name=="FadedCreamLine" then
                obj.Color=C.cream
                obj.Material=Enum.Material.Metal
                obj.Transparency=0.34
            elseif obj.Name=="OldCarPlate" then
                obj.Color=C.redDark
                obj.Material=Enum.Material.Metal
            elseif obj.Name=="Rivet" then
                obj.Color=C.rustDark
                obj.Transparency=0.20
            end
        end
    end
end

-- Make platform/canopy structure dark steel rather than another large rusty-orange mass.
for _,obj in ipairs(architecture:GetDescendants()) do
    if obj:IsA("BasePart") then
        if obj.Name=="CanopyColumn" or obj.Name=="CanopyBrace" or obj.Name=="CanopyBrace2" then
            obj.Color=C.steel
            obj.Material=Enum.Material.Metal
        elseif obj.Name=="CanopyRoof" then
            obj.Color=Color3.fromRGB(50,52,52)
            obj.Material=Enum.Material.Metal
        end
    end
end

-- Rebalance wash lights so the red paint remains visibly red instead of orange-brown.
if polish then
    local venue=polish:FindFirstChild("VenueDetail")
    if venue then
        for _,obj in ipairs(venue:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name=="TrainWashFixture" then
                for _,light in ipairs(obj:GetChildren()) do
                    if light:IsA("SpotLight") then
                        light.Color=C.neutralWarm
                        light.Brightness=0.72
                        light.Range=16
                    end
                end
            end
        end
    end
end

-- More neutral scene grade. Club red/amber fixtures remain, but ambient light no longer
-- shifts the whole carriage body toward orange.
Lighting.Brightness=1.72
Lighting.Ambient=Color3.fromRGB(40,42,44)
Lighting.OutdoorAmbient=Color3.fromRGB(49,50,51)
Lighting.EnvironmentDiffuseScale=0.38
Lighting.EnvironmentSpecularScale=0.38
local cc=Lighting:FindFirstChild("TRACK01_Color")
if cc and cc:IsA("ColorCorrectionEffect") then
    cc.Brightness=0.015
    cc.Contrast=0.15
    cc.Saturation=-0.05
    cc.TintColor=Color3.fromRGB(242,234,226)
end
local atmosphere=Lighting:FindFirstChild("TRACK01_Atmosphere")
if atmosphere and atmosphere:IsA("Atmosphere") then
    atmosphere.Density=0.28
    atmosphere.Haze=1.65
    atmosphere.Decay=Color3.fromRGB(74,76,78)
end

-- Small painted replacement panels make the old-red identity visible even at distance.
local corrections=Instance.new("Folder")
corrections.Name="RedPaintCorrectionDetails"
corrections.Parent=world
local centers={-58,-5,48,101}
for i,z in ipairs(centers) do
    local shade=(i%2==0) and C.red or C.red2
    for _,sx in ipairs({-1,1}) do
        local x=22+sx*8.60
        for _,dz in ipairs({-16,-5,8,18}) do
            local p=Instance.new("Part")
            p.Name="FadedRedRepairPanel"
            p.Size=Vector3.new(0.10,1.15,3.4)
            p.CFrame=CFrame.new(x,6.6,z+dz)
            p.Color=shade
            p.Material=Enum.Material.Metal
            p.Anchored=true
            p.CanCollide=false
            p.CanTouch=false
            p.CanQuery=true
            p.Transparency=0.24
            p.Parent=corrections
        end
    end
end

Workspace:SetAttribute("ACC_TRACK01_CORRECTION_READY",true)
Workspace:SetAttribute("ACC_TRACK01_VERSION","2.2.0")
print("[TRACK 01] red-train correction ready v2.2.0")