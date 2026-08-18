-- BBYA V6 — A4 CLUB SHOW-LIGHT RIG
-- Dynamic accent layer only. Critical outfit/show-off fill lighting stays separate and always readable.

local rig=Instance.new("Folder")
rig.Name="A4 SHOW LIGHT RIG"
rig:SetAttribute("BBYAZoneCode","A4")
rig:SetAttribute("BBYAComponentCode","07")
rig.Parent=A4

local showColors={P.pink,P.cyan,P.violet,P.white}
local heads={
    {-34,15.8,78,18},{-17,15.8,78,10},{0,15.8,78,0},{17,15.8,78,-10},{34,15.8,78,-18},
    {-34,15.8,110,-18},{-17,15.8,110,-10},{0,15.8,110,0},{17,15.8,110,10},{34,15.8,110,18},
}

for i,h in ipairs(heads) do
    local cf=CFrame.new(h[1],h[2],h[3])*CFrame.Angles(math.rad(-18),math.rad(h[4]),0)
    local housing=part(rig,"A4 SHOW HEAD "..i,Vector3.new(2.2,1.1,2.5),cf,P.black,Enum.Material.Metal,0,false,"07")
    housing.CanQuery=false
    local lens=part(rig,"A4 SHOW LENS "..i,Vector3.new(1.25,.25,1.25),cf*CFrame.new(0,-.52,-.3),showColors[(i-1)%#showColors+1],Enum.Material.Neon,0,false,"07")
    lens.CanQuery=false
    lens:SetAttribute("BBYAShowLightLens",true)
    lens:SetAttribute("BBYAShowLightIndex",i)
    local spot=Instance.new("SpotLight")
    spot.Name="A4 SHOW SPOT "..i
    spot.Face=Enum.NormalId.Bottom
    spot.Angle=62
    spot.Range=38
    spot.Brightness=1.1
    spot.Shadows=false
    spot.Color=lens.Color
    spot.Parent=lens
    lens:SetAttribute("BBYADecorativeLight",true)
end

-- Stage wash: brighter but still accent-only; no strobing blackouts.
for i,x in ipairs({-24,-8,8,24}) do
    local anchor=part(rig,"A4 STAGE WASH "..i,Vector3.new(1.2,.4,1.2),CFrame.new(x,14.8,120),showColors[(i-1)%#showColors+1],Enum.Material.Neon,0,false,"07")
    anchor.CanQuery=false
    anchor:SetAttribute("BBYAShowLightLens",true)
    anchor:SetAttribute("BBYAShowLightIndex",10+i)
    anchor:SetAttribute("BBYADecorativeLight",true)
    local spot=Instance.new("SpotLight")
    spot.Name="A4 STAGE WASH LIGHT "..i
    spot.Face=Enum.NormalId.Bottom
    spot.Angle=78
    spot.Range=30
    spot.Brightness=1.25
    spot.Color=anchor.Color
    spot.Shadows=false
    spot.Parent=anchor
end

workspace:SetAttribute("BBYAV6ClubShowRig","BRIGHT_ACCENT_ONLY")
