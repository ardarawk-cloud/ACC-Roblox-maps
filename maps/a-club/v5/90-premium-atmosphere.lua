-- [BUILD-FINISH] PREMIUM ATMOSPHERE / GREYBOX RETIREMENT
-- Keeps coded zone metadata while hiding construction-only review markers.

for _,d in ipairs(root:GetDescendants()) do
 if d:IsA("BasePart") then
  local n=string.upper(d.Name)
  if n:find("PROGRAM") or n:find("INSPECTION TAG") or n:find(" LANDING") or n:find("APPROACH AXIS") then
   d.Transparency=1;d.CanCollide=false;d.CanTouch=false;d.CanQuery=false
  end
  if d:IsA("SpawnLocation") then d.Transparency=1;d.CanCollide=false end
 end
end

Lighting.ClockTime=21.35
Lighting.Brightness=2.1
Lighting.ExposureCompensation=.05
Lighting.Ambient=Color3.fromRGB(38,32,47)
Lighting.OutdoorAmbient=Color3.fromRGB(58,55,68)
Lighting.FogStart=900;Lighting.FogEnd=2600

for _,e in ipairs(Lighting:GetChildren()) do
 if e.Name=="BBYA V5 Bloom" or e.Name=="BBYA V5 Color" or e.Name=="BBYA V5 Atmosphere" then e:Destroy() end
end
local bloom=Instance.new("BloomEffect");bloom.Name="BBYA V5 Bloom";bloom.Intensity=.45;bloom.Size=28;bloom.Threshold=1.3;bloom.Parent=Lighting
local cc=Instance.new("ColorCorrectionEffect");cc.Name="BBYA V5 Color";cc.Brightness=-.01;cc.Contrast=.08;cc.Saturation=.02;cc.TintColor=Color3.fromRGB(244,236,255);cc.Parent=Lighting
local atm=Instance.new("Atmosphere");atm.Name="BBYA V5 Atmosphere";atm.Density=.18;atm.Offset=.05;atm.Color=Color3.fromRGB(150,142,175);atm.Decay=Color3.fromRGB(70,62,90);atm.Glare=.08;atm.Haze=1.1;atm.Parent=Lighting

workspace:SetAttribute("BBYAV5ArchitectureMode","FULL_PREMIUM")
workspace:SetAttribute("BBYAV5BuildStage","MASTER_PLAN_IMPLEMENTED")
workspace:SetAttribute("BBYAV5Atmosphere","CLUB_NEON_ROOF_WARM")
