-- [BUILD-FINISH] PREMIUM ATMOSPHERE / GREYBOX RETIREMENT
-- Keeps coded zone metadata while hiding construction-only review markers.

local draftLabelNames={
 ["EXTERIOR BBYA IDENTITY"]=true,["MAIN CLUB DOOR LABEL"]=true,["STAGE LABEL"]=true,
 ["BAR LOBBY DOOR"]=true,["CHILL LOBBY DOOR"]=true,["WEST STAIR LABEL"]=true,["EAST STAIR LABEL"]=true,
 ["LIFT GROUND LABEL"]=true,["QUEEN PRIVATE LABEL"]=true,
}
for _,d in ipairs(root:GetDescendants()) do
 if d:IsA("BasePart") then
  local n=string.upper(d.Name)
  local short=n:match("^[A-Z0-9]+ %| (.+)$") or n
  if draftLabelNames[short] then d:Destroy()
  elseif n:find("PROGRAM") or n:find("INSPECTION TAG") or n:find(" LANDING") or n:find("APPROACH AXIS") then
   d.Transparency=1;d.CanCollide=false;d.CanTouch=false;d.CanQuery=false
  elseif d:IsA("SpawnLocation") then d.Transparency=1;d.CanCollide=false end
 end
end

-- Premium night remains dark enough for neon, but player/outfit readability is intentionally higher.
Lighting.ClockTime=21.05
Lighting.Brightness=2.45
Lighting.ExposureCompensation=.14
Lighting.Ambient=Color3.fromRGB(52,45,61)
Lighting.OutdoorAmbient=Color3.fromRGB(67,63,74)
Lighting.FogStart=1050;Lighting.FogEnd=2850
for _,e in ipairs(Lighting:GetChildren()) do if e.Name=="BBYA V5 Bloom" or e.Name=="BBYA V5 Color" or e.Name=="BBYA V5 Atmosphere" then e:Destroy() end end
local bloom=Instance.new("BloomEffect");bloom.Name="BBYA V5 Bloom";bloom.Intensity=.36;bloom.Size=24;bloom.Threshold=1.38;bloom.Parent=Lighting
local cc=Instance.new("ColorCorrectionEffect");cc.Name="BBYA V5 Color";cc.Brightness=.03;cc.Contrast=.04;cc.Saturation=.04;cc.TintColor=Color3.fromRGB(248,241,255);cc.Parent=Lighting
local atm=Instance.new("Atmosphere");atm.Name="BBYA V5 Atmosphere";atm.Density=.14;atm.Offset=.04;atm.Color=Color3.fromRGB(158,150,180);atm.Decay=Color3.fromRGB(76,68,94);atm.Glare=.06;atm.Haze=.75;atm.Parent=Lighting
workspace:SetAttribute("BBYAV5ArchitectureMode","FULL_PREMIUM")
workspace:SetAttribute("BBYAV5BuildStage","MASTER_PLAN_IMPLEMENTED")
workspace:SetAttribute("BBYAV5Atmosphere","CLUB_BRIGHT_NEON_ROOF_WARM")
