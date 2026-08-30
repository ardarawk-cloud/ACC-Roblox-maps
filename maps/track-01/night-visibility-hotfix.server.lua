local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")

-- TRACK 01 v3.9.1 night visibility balance.
-- Slightly lifts mobile readability and adds restrained local fill to The Yard.
-- Keeps the venue night-time, preserves signal colors, and adds no uploaded assets/audio.
local deadline=os.clock()+90
repeat task.wait(0.20) until Workspace:GetAttribute("ACC_TRACK01_FINAL_QC_READY") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
if not world then return end

local old=world:FindFirstChild("TRACK01_NightVisibility_v391")
if old then old:Destroy() end
local folder=Instance.new("Folder")
folder.Name="TRACK01_NightVisibility_v391"
folder.Parent=world

-- Global lift is deliberately modest: enough to read avatars and furniture on phones,
-- but still clearly a dark railway nightclub.
Lighting.Brightness=1.80
Lighting.ExposureCompensation=0.12
Lighting.Ambient=Color3.fromRGB(52,51,49)
Lighting.OutdoorAmbient=Color3.fromRGB(64,62,58)
Lighting.EnvironmentDiffuseScale=0.40
Lighting.EnvironmentSpecularScale=0.46
Lighting.ShadowSoftness=0.38

local cc=Lighting:FindFirstChild("TRACK01_CinematicGrade")
if cc and cc:IsA("ColorCorrectionEffect") then
    cc.Brightness=0.035
    cc.Contrast=0.055
    cc.Saturation=-0.08
end

local baseAtmosphere=Lighting:FindFirstChild("TRACK01_Atmosphere")
if baseAtmosphere and baseAtmosphere:IsA("Atmosphere") then
    baseAtmosphere.Density=math.min(baseAtmosphere.Density,0.27)
    baseAtmosphere.Haze=math.min(baseAtmosphere.Haze,1.45)
end

local function makeFill(name,pos,color,brightness,range)
    local anchor=Instance.new("Part")
    anchor.Name=name
    anchor.Size=Vector3.new(0.4,0.4,0.4)
    anchor.CFrame=CFrame.new(pos)
    anchor.Anchored=true
    anchor.CanCollide=false
    anchor.CanTouch=false
    anchor.CanQuery=false
    anchor.CastShadow=false
    anchor.Transparency=1
    anchor.Parent=folder

    local light=Instance.new("PointLight")
    light.Name="YardReadabilityFill"
    light.Color=color
    light.Brightness=brightness
    light.Range=range
    light.Shadows=false
    light.Parent=anchor
end

local warm=Color3.fromRGB(228,205,174)
local neutralWarm=Color3.fromRGB(205,207,196)
-- Social / bench cluster.
makeFill("YardFill01",Vector3.new(-61,6.3,55),warm,0.52,17)
makeFill("YardFill02",Vector3.new(-42,6.3,56),warm,0.48,16)
makeFill("YardFill03",Vector3.new(-61,6.3,80),warm,0.50,17)
makeFill("YardFill04",Vector3.new(-42,6.3,80),warm,0.46,16)
-- Central walking line + photo wall. Neutral-warm prevents everything becoming orange.
makeFill("YardFillCenter",Vector3.new(-51,6.8,68),neutralWarm,0.44,18)
makeFill("YardFillPhoto",Vector3.new(-68,6.8,74),neutralWarm,0.42,15)

root:SetAttribute("NightVisibilityVersion","3.9.1")
Workspace:SetAttribute("ACC_TRACK01_NIGHT_VISIBILITY_READY",true)
Workspace:SetAttribute("ACC_TRACK01_VERSION","3.9.1")
print("[TRACK 01] night visibility balance ready v3.9.1")
