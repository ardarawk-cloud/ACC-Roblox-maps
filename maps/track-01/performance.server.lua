local Workspace=game:GetService("Workspace")

-- TRACK 01 v2.8 performance/QC pass.
-- Keeps all venue detail while trimming avoidable mobile render/query cost.
local deadline=os.clock()+55
repeat task.wait(0.15) until Workspace:GetAttribute("ACC_TRACK01_OPERATIONS_READY") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
local dynamicLights=root:FindFirstChild("DynamicLights")
if not (world and dynamicLights) then return end

local noShadowNames={
    RustPatch=true,RustDrip=true,Rivet=true,BodyRib=true,FadedRedRepairPanel=true,
    VentSlat=true,MeterNeedle=true,LeverCap=true,SignalMarker=true,YardStringBulb=true,
    FireGlow=true,FacadeLampBulb=true,FloorGuide=true,LockerVent=true,LockerHandle=true,
    ExtinguisherBracket=true,ColumnBolt=true,MaintenanceScar=true,RoofOxide=true,
}

local optimizedParts=0
local queryDisabled=0
for _,obj in ipairs(world:GetDescendants()) do
    if obj:IsA("BasePart") then
        obj.CanTouch=false
        local small=obj.Size.X*obj.Size.Y*obj.Size.Z < 8
        local decorative=noShadowNames[obj.Name] or obj.Material==Enum.Material.Neon
        if decorative or small then
            obj.CastShadow=false
            optimizedParts+=1
        end
        -- Only remove query cost from parts that were already non-collidable.
        if not obj.CanCollide and (decorative or small) then
            obj.CanQuery=false
            queryDisabled+=1
        end
    end
end

local pulseCount=0
for _,obj in ipairs(dynamicLights:GetDescendants()) do
    if obj:IsA("PointLight") or obj:IsA("SpotLight") then
        if obj:GetAttribute("ACCBaseBrightness")==nil then
            obj:SetAttribute("ACCBaseBrightness",obj.Brightness)
        end
        -- Dynamic club lights do not need expensive per-frame shadow maps.
        obj.Shadows=false
        pulseCount+=1
    end
end

root:SetAttribute("PerformanceVersion","2.8.0")
root:SetAttribute("OptimizedDecorativeParts",optimizedParts)
root:SetAttribute("QueryDisabledDecorativeParts",queryDisabled)
root:SetAttribute("PulseLightCount",pulseCount)
Workspace:SetAttribute("ACC_TRACK01_PERFORMANCE_READY",true)
Workspace:SetAttribute("ACC_TRACK01_VERSION","2.8.0")
print(string.format("[TRACK 01] performance QC ready v2.8.0 | decor=%d queryOff=%d pulse=%d",optimizedParts,queryDisabled,pulseCount))
