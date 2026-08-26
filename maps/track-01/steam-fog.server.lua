local Workspace=game:GetService("Workspace")

-- TRACK 01 v3.4 steam/fog/wet-rail atmosphere pass.
-- Uses only built-in Roblox particle textures; no uploaded audio/images/assets.
local deadline=os.clock()+55
repeat task.wait(0.15) until Workspace:GetAttribute("ACC_TRACK01_SIGNAL_NIGHT_READY") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
if not world then return end

local old=world:FindFirstChild("TRACK01_SteamFog_v34")
if old then old:Destroy() end
local folder=Instance.new("Folder")
folder.Name="TRACK01_SteamFog_v34"
folder.Parent=world
local railFX=Instance.new("Folder"); railFX.Name="RailSteam"; railFX.Parent=folder
local mistFX=Instance.new("Folder"); mistFX.Name="LowMist"; mistFX.Parent=folder
local wetFX=Instance.new("Folder"); wetFX.Name="WetSurfaceAccents"; wetFX.Parent=folder
local practical=Instance.new("Folder"); practical.Name="NightPracticalLights"; practical.Parent=folder

local C={
    black=Color3.fromRGB(17,18,18),
    steel=Color3.fromRGB(70,72,71),
    rust=Color3.fromRGB(71,42,34),
    wet=Color3.fromRGB(34,42,44),
    warm=Color3.fromRGB(231,211,185),
    amber=Color3.fromRGB(214,145,70),
}

local function cf(x,y,z,rx,ry,rz)
    return CFrame.new(x,y,z)*CFrame.Angles(math.rad(rx or 0),math.rad(ry or 0),math.rad(rz or 0))
end

local function part(parent,name,size,frame,color,material,transparency,shape)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=frame
    p.Color=color or C.steel
    p.Material=material or Enum.Material.Metal
    p.Transparency=transparency or 0
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=false
    p.CastShadow=false
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    if shape then p.Shape=shape end
    p.Parent=parent
    return p
end

local function steamEmitter(parent,name,x,y,z,rate,size0,size1,rise)
    local emitterPart=part(parent,name,Vector3.new(0.5,0.15,0.5),cf(x,y,z),C.black,Enum.Material.SmoothPlastic,1)
    local e=Instance.new("ParticleEmitter")
    e.Name="SteamEmitter"
    e.Texture="rbxasset://textures/particles/smoke_main.dds"
    e.Color=ColorSequence.new(Color3.fromRGB(174,181,183),Color3.fromRGB(112,118,120))
    e.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,0.62),
        NumberSequenceKeypoint.new(0.35,0.48),
        NumberSequenceKeypoint.new(1,1),
    })
    e.Size=NumberSequence.new({
        NumberSequenceKeypoint.new(0,size0),
        NumberSequenceKeypoint.new(1,size1),
    })
    e.Lifetime=NumberRange.new(2.8,5.2)
    e.Rate=rate
    e.Speed=NumberRange.new(rise*0.55,rise)
    e.Rotation=NumberRange.new(0,360)
    e.RotSpeed=NumberRange.new(-12,12)
    e.SpreadAngle=Vector2.new(14,14)
    e.Drag=2
    e.LightInfluence=0.72
    e.LightEmission=0.02
    e.LockedToPart=false
    e.Parent=emitterPart
    return e
end

local function mistEmitter(parent,name,x,y,z,sx,sz)
    local emitterPart=part(parent,name,Vector3.new(sx,0.10,sz),cf(x,y,z),C.black,Enum.Material.SmoothPlastic,1)
    local e=Instance.new("ParticleEmitter")
    e.Name="MistEmitter"
    e.Texture="rbxasset://textures/particles/smoke_main.dds"
    e.Color=ColorSequence.new(Color3.fromRGB(118,126,128),Color3.fromRGB(78,84,86))
    e.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,0.86),
        NumberSequenceKeypoint.new(0.45,0.76),
        NumberSequenceKeypoint.new(1,1),
    })
    e.Size=NumberSequence.new({
        NumberSequenceKeypoint.new(0,6),
        NumberSequenceKeypoint.new(1,13),
    })
    e.Lifetime=NumberRange.new(5.5,8.5)
    e.Rate=1.4
    e.Speed=NumberRange.new(0.16,0.42)
    e.Acceleration=Vector3.new(0,0.05,0)
    e.SpreadAngle=Vector2.new(38,18)
    e.Drag=4
    e.LightInfluence=0.90
    e.Parent=emitterPart
    return e
end

-- Sparse rail steam: strongest near mechanical/END OF LINE areas, never a full fog wall.
for _,spec in ipairs({
    {18.3,1.0,-37,2.1,1.0,4.2,1.4},
    {26.4,1.0,18,1.8,0.9,3.8,1.2},
    {18.0,1.0,72,2.2,1.0,4.6,1.5},
    {26.2,1.0,118,2.5,1.1,5.0,1.6},
    {21.8,1.0,132,2.8,1.2,5.5,1.8},
}) do
    steamEmitter(railFX,"RailSteamVent",spec[1],spec[2],spec[3],spec[4],spec[5],spec[6],spec[7])
end

-- Low ambient mist only in large outdoor zones.
mistEmitter(mistFX,"PlatformLowMist",2.5,3.0,28,7,42)
mistEmitter(mistFX,"PlatformSouthMist",1.5,3.0,108,7,28)
mistEmitter(mistFX,"YardLowMist",-50,0.9,68,24,28)
mistEmitter(mistFX,"EndOfLineMist",22,1.0,136,15,9)

-- Wet surface accents add reflection cues without replacing the whole floor material.
for _,spec in ipairs({
    {-3.0,2.80,-35,8,14,-5},
    {3.0,2.80,23,6,11,4},
    {-2.5,2.80,82,9,13,7},
    {-48,0.44,52,14,9,-8},
    {-60,0.44,92,11,7,5},
}) do
    local x,y,z,sx,sz,ry=table.unpack(spec)
    part(wetFX,"WetRailPuddle",Vector3.new(sx,0.035,sz),cf(x,y,z,0,ry,0),C.wet,Enum.Material.Glass,0.57)
end

-- Small industrial practicals with rare, slow flicker; not club-strobe behavior.
local flickerLights={}
for _,spec in ipairs({
    {-7.4,10.6,-42},{-7.4,10.6,18},{-7.4,10.6,78},
    {-42,9.0,46},{-58,9.0,96},
}) do
    local x,y,z=spec[1],spec[2],spec[3]
    local cage=part(practical,"CageLamp",Vector3.new(1.35,0.55,1.35),cf(x,y,z),C.rust,Enum.Material.CorrodedMetal,0)
    local bulb=part(practical,"CageBulb",Vector3.new(0.62,0.24,0.62),cf(x,y-0.38,z),C.warm,Enum.Material.Neon,0.12)
    local l=Instance.new("PointLight")
    l.Name="AtmospherePractical"
    l.Color=C.warm
    l.Brightness=0.34
    l.Range=8
    l.Shadows=false
    l.Parent=bulb
    table.insert(flickerLights,{bulb=bulb,light=l})
    cage:SetAttribute("PracticalFixture",true)
end

task.spawn(function()
    local rng=Random.new(3401)
    while folder.Parent do
        task.wait(rng:NextNumber(4.5,9.5))
        local item=flickerLights[rng:NextInteger(1,#flickerLights)]
        if item and item.bulb.Parent then
            local baseBrightness=item.light.Brightness
            item.light.Brightness=0.05
            item.bulb.Transparency=0.48
            task.wait(rng:NextNumber(0.07,0.16))
            item.light.Brightness=baseBrightness
            item.bulb.Transparency=0.12
            if rng:NextNumber()<0.28 then
                task.wait(0.09)
                item.light.Brightness=0.12
                task.wait(0.08)
                item.light.Brightness=baseBrightness
            end
        end
    end
end)

root:SetAttribute("SteamFogVersion","3.4.0")
root:SetAttribute("SteamVentCount",5)
root:SetAttribute("LowMistZoneCount",4)
Workspace:SetAttribute("ACC_TRACK01_STEAM_FOG_READY",true)
Workspace:SetAttribute("ACC_TRACK01_VERSION","3.4.0")
print("[TRACK 01] steam/fog/wet-rail atmosphere ready v3.4.0")
