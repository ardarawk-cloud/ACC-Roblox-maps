-- [A4/05-07] SHOW-OFF LIGHTING PASS
-- Bright club visibility for outfit/social play while preserving neon identity.

local function criticalSurface(name,position,size,color,brightness,range)
    local fixture=finish(A4,name,size,CFrame.new(position),P.white,Enum.Material.SmoothPlastic,0,false)
    local light=Instance.new("SurfaceLight")
    light.Name="BBYA Club Fill Light"
    light.Face=Enum.NormalId.Bottom
    light.Angle=120
    light.Color=color
    light.Brightness=brightness
    light.Range=range
    light.Shadows=false
    light:SetAttribute("BBYACriticalFillLight",true)
    light.Parent=fixture
    fixture:SetAttribute("BBYACriticalFillFixture",true)
    return fixture
end

-- Eight broad ceiling fills keep faces/outfits readable across the full dance floor.
local ceilingY=15.35
for _,spec in ipairs({
    {-30,-42,Color3.fromRGB(255,238,246)}, {0,-42,Color3.fromRGB(228,242,255)}, {30,-42,Color3.fromRGB(255,232,246)},
    {-30,-6,Color3.fromRGB(235,245,255)}, {0,-6,Color3.fromRGB(255,239,226)}, {30,-6,Color3.fromRGB(255,235,247)},
    {-24,34,Color3.fromRGB(235,246,255)}, {24,34,Color3.fromRGB(255,236,246)},
}) do
    criticalSurface("SHOWOFF CEILING FILL "..spec[1].." "..spec[2],Vector3.new(spec[1],ceilingY,spec[2]),Vector3.new(13,.22,7),spec[3],1.45,23)
end

-- Front social/camera zone gets softer neutral fill for outfit photos.
for _,x in ipairs({-32,0,32}) do
    criticalSurface("FRONT SOCIAL FILL "..x,Vector3.new(x,14.7,63),Vector3.new(14,.2,6),Color3.fromRGB(248,242,255),1.2,20)
end

-- Stage key lights ensure DJ/crowd remain visible even when party lighting changes.
for _,x in ipairs({-22,22}) do
    local p=finish(A4,"STAGE KEY FIXTURE "..x,Vector3.new(1.2,1.2,1.2),CFrame.new(x,14,-50),P.graphite,Enum.Material.Metal,0,false)
    local l=Instance.new("PointLight")
    l.Name="BBYA Club Fill Light"
    l.Color=Color3.fromRGB(255,236,229)
    l.Brightness=1.35
    l.Range=22
    l.Shadows=false
    l:SetAttribute("BBYACriticalFillLight",true)
    l.Parent=p
end

workspace:SetAttribute("BBYAA4ShowOffLighting","1.0")
workspace:SetAttribute("BBYAClubLightingMood","BRIGHT_NEON_SOCIAL")
