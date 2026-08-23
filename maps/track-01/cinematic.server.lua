local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")

-- TRACK 01 v2.9 cinematic interior correction.
-- Purpose: reduce the over-red/over-yellow wash visible on mobile, add readable neutral fill,
-- and give the carriage interior more physical material depth without obstructing the aisle.
local deadline=os.clock()+45
repeat task.wait(0.15) until Workspace:GetAttribute("ACC_TRACK01_AISLE_CLEAR") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
local train=world and world:FindFirstChild("TrainCars")
local dynamic=root:FindFirstChild("DynamicLights")
if not (world and train) then return end

local old=world:FindFirstChild("TRACK01_Cinematic_v29")
if old then old:Destroy() end
local cinematic=Instance.new("Folder")
cinematic.Name="TRACK01_Cinematic_v29"
cinematic.Parent=world

local finishes=Instance.new("Folder")
finishes.Name="InteriorFinishLayers"
finishes.Parent=cinematic
local fills=Instance.new("Folder")
fills.Name="CinematicFillLighting"
fills.Parent=cinematic

local C={
    black=Color3.fromRGB(18,19,19),
    charcoal=Color3.fromRGB(30,31,31),
    steel=Color3.fromRGB(82,84,82),
    steel2=Color3.fromRGB(115,114,108),
    red=Color3.fromRGB(103,29,32),
    redMuted=Color3.fromRGB(156,43,38),
    redDark=Color3.fromRGB(56,18,21),
    cream=Color3.fromRGB(184,170,143),
    warm=Color3.fromRGB(232,218,197),
    neutral=Color3.fromRGB(214,217,211),
    amber=Color3.fromRGB(211,150,84),
    glass=Color3.fromRGB(38,49,52),
}

local function cf(x,y,z,rx,ry,rz)
    return CFrame.new(x,y,z)*CFrame.Angles(math.rad(rx or 0),math.rad(ry or 0),math.rad(rz or 0))
end

local function part(parent,name,size,frame,color,material,transparency)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=frame
    p.Color=color
    p.Material=material or Enum.Material.Metal
    p.Transparency=transparency or 0
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=false
    p.CastShadow=false
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent
    return p
end

local function addFill(parent,name,pos,color,brightness,range)
    local fixture=part(parent,name,Vector3.new(2.6,0.16,1.0),CFrame.new(pos),Color3.fromRGB(72,73,70),Enum.Material.Metal,0)
    local lens=part(parent,name.."Lens",Vector3.new(2.15,0.08,0.72),CFrame.new(pos-Vector3.new(0,0.12,0)),color,Enum.Material.Glass,0.08)
    local light=Instance.new("PointLight")
    light.Name="CinematicFill"
    light.Color=color
    light.Brightness=brightness
    light.Range=range
    light.Shadows=false
    light.Parent=lens
    return fixture
end

-- Global grade: keep the venue dark, but remove the red/orange clipping visible on mobile.
Lighting.Brightness=1.62
Lighting.ExposureCompensation=0.03
Lighting.Ambient=Color3.fromRGB(44,43,42)
Lighting.OutdoorAmbient=Color3.fromRGB(54,53,52)
Lighting.EnvironmentDiffuseScale=0.34
Lighting.EnvironmentSpecularScale=0.42
Lighting.ShadowSoftness=0.35

local cc=Lighting:FindFirstChild("TRACK01_CinematicGrade")
if cc then cc:Destroy() end
cc=Instance.new("ColorCorrectionEffect")
cc.Name="TRACK01_CinematicGrade"
cc.Brightness=0.01
cc.Contrast=0.07
cc.Saturation=-0.10
cc.TintColor=Color3.fromRGB(244,238,229)
cc.Parent=Lighting

local bloom=Lighting:FindFirstChild("TRACK01_ControlledBloom")
if bloom then bloom:Destroy() end
bloom=Instance.new("BloomEffect")
bloom.Name="TRACK01_ControlledBloom"
bloom.Intensity=0.13
bloom.Size=18
bloom.Threshold=1.55
bloom.Parent=Lighting

local function muteNeonPart(p)
    local c=p.Color
    if c.R>c.G*1.35 and c.R>c.B*1.35 then
        p.Color=C.redMuted
        p.Transparency=math.max(p.Transparency,0.12)
    elseif c.R>0.65 and c.G>0.38 and c.B<0.42 then
        p.Color=C.amber
        p.Transparency=math.max(p.Transparency,0.12)
    elseif c.R>0.75 and c.G>0.72 and c.B>0.62 then
        p.Color=C.warm
        p.Transparency=math.max(p.Transparency,0.06)
    end
end

local function tuneLight(l,z)
    if l:GetAttribute("ACC_v29_tuned") then return end
    l:SetAttribute("ACC_v29_tuned",true)
    local base=l.Brightness
    l:SetAttribute("ACC_v29_base",base)
    local scale=0.72
    if z and z>74 then scale=0.56 elseif z and z>21 then scale=0.62 end
    l.Brightness=math.max(0.12,base*scale)
    l.Range=math.max(6,l.Range*0.88)
    l.Shadows=false
    local c=l.Color
    if c.R>c.G*1.35 and c.R>c.B*1.35 then
        l.Color=C.redMuted
    elseif c.R>0.65 and c.G>0.38 and c.B<0.42 then
        l.Color=C.amber
    elseif c.R>0.75 and c.G>0.72 and c.B>0.62 then
        l.Color=C.warm
    end
end

-- Tone down existing emissive pieces inside the cars.
for _,obj in ipairs(train:GetDescendants()) do
    if obj:IsA("BasePart") and obj.Material==Enum.Material.Neon then
        muteNeonPart(obj)
    elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
        local parent=obj.Parent
        local z=(parent and parent:IsA("BasePart")) and parent.Position.Z or nil
        tuneLight(obj,z)
    end
end
if dynamic then
    for _,obj in ipairs(dynamic:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Material==Enum.Material.Neon then
            muteNeonPart(obj)
        elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            local parent=obj.Parent
            local z=(parent and parent:IsA("BasePart")) and parent.Position.Z or nil
            tuneLight(obj,z)
        end
    end
end

-- Add real-carriage visual depth along the side walls. Everything is shallow and non-collidable.
local cars={
    {z=-58,accent=C.cream,fill=C.warm},
    {z=-5,accent=C.steel2,fill=C.warm},
    {z=48,accent=C.redMuted,fill=C.neutral},
    {z=101,accent=C.redMuted,fill=C.neutral},
}
for idx,spec in ipairs(cars) do
    local z=spec.z
    -- Dark lower-wall dado panels prevent the long red benches/walls reading as one flat block.
    for _,x in ipairs({14.46,29.54}) do
        part(finishes,"DadoShadow",Vector3.new(0.12,2.55,43.0),cf(x,6.55,z),C.redDark,Enum.Material.Metal,0.04)
        part(finishes,"DadoCap",Vector3.new(0.18,0.16,43.0),cf(x,7.88,z),spec.accent,Enum.Material.Metal,0.12)
        -- Narrow window-base rail: visual depth only, flush to side wall.
        part(finishes,"WindowBaseTrim",Vector3.new(0.15,0.28,42.5),cf(x,9.08,z),C.steel,Enum.Material.Metal,0.04)
    end

    -- Ceiling cable trays follow the train, not the aisle width.
    for _,x in ipairs({17.1,26.9}) do
        part(finishes,"CeilingCableTray",Vector3.new(0.44,0.24,40.0),cf(x,14.92,z),C.charcoal,Enum.Material.Metal,0)
        for dz=-16,16,8 do
            part(finishes,"TrayBracket",Vector3.new(1.0,0.14,0.18),cf(x,14.78,z+dz),C.steel,Enum.Material.Metal,0.08)
        end
    end

    -- Controlled neutral/warm pools: enough to read faces/furniture without flattening the club mood.
    local brightness=(idx<=2) and 0.34 or 0.25
    local range=(idx<=2) and 9 or 8
    for dz=-16,16,8 do
        addFill(fills,"AisleFill",Vector3.new(22,14.65,z+dz),spec.fill,brightness,range)
    end

    -- Floor edge markers are tiny and run parallel to movement, never across it.
    for _,x in ipairs({17.2,26.8}) do
        part(finishes,"FloorEdgeMarker",Vector3.new(0.09,0.05,38.0),cf(x,4.79,z),idx>=3 and C.redMuted or C.cream,Enum.Material.SmoothPlastic,0.32)
    end
end

-- END OF LINE should read as a control-room club, not a red flood.
for _,obj in ipairs(world:GetDescendants()) do
    if obj:IsA("BasePart") and obj.Position.Z>76 and obj.Position.Z<126 then
        if obj.Name=="HeroRedL" or obj.Name=="HeroRedR" or obj.Name=="DJDeskTrim" then
            obj.Color=C.redMuted
            obj.Transparency=math.max(obj.Transparency,0.18)
        end
    end
end

-- Small indirect glow behind the DJ console gives depth without blasting the entire carriage red.
local djBack=part(fills,"DJBackGlow",Vector3.new(10.8,0.10,0.18),cf(22,10.85,119.0),C.redMuted,Enum.Material.Neon,0.28)
local djLight=Instance.new("SurfaceLight")
djLight.Name="DJBackFill"
djLight.Face=Enum.NormalId.Back
djLight.Color=C.redMuted
djLight.Brightness=0.18
djLight.Range=5
djLight.Angle=100
djLight.Shadows=false
djLight.Parent=djBack

root:SetAttribute("CinematicVersion","2.9.0")
Workspace:SetAttribute("ACC_TRACK01_CINEMATIC_READY",true)
Workspace:SetAttribute("ACC_TRACK01_VERSION","2.9.0")
print("[TRACK 01] cinematic interior correction ready v2.9.0")
