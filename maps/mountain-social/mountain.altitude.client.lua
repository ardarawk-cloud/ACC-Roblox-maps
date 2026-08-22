-- ACC Mountain Social Adventure — Altitude Atmosphere v4.5
local Players=game:GetService("Players")
local Lighting=game:GetService("Lighting")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere",Lighting)
local cc=Lighting:FindFirstChild("ACC_AltitudeColor") or Instance.new("ColorCorrectionEffect");cc.Name="ACC_AltitudeColor";cc.Parent=Lighting
local blur=Lighting:FindFirstChild("ACC_AltitudeBlur") or Instance.new("BlurEffect");blur.Name="ACC_AltitudeBlur";blur.Parent=Lighting
local currentBand=""
local function bandFor(y)
 if y<350 then return "LOWLAND" end
 if y<430 then return "CLIFF" end
 if y<515 then return "FOG" end
 if y<590 then return "HIGHLAND" end
 if y<720 then return "RIDGE" end
 return "SUMMIT" end
local function apply(b)
 if b=="LOWLAND" then atmosphere.Density=.22;atmosphere.Haze=1.0;cc.Contrast=.05;cc.Saturation=-.02;blur.Size=0
 elseif b=="CLIFF" then atmosphere.Density=.27;atmosphere.Haze=1.25;cc.Contrast=.07;cc.Saturation=-.03;blur.Size=0
 elseif b=="FOG" then atmosphere.Density=.48;atmosphere.Haze=2.8;atmosphere.Glare=.05;cc.Contrast=.04;cc.Saturation=-.12;blur.Size=1
 elseif b=="HIGHLAND" then atmosphere.Density=.25;atmosphere.Haze=1.45;atmosphere.Glare=.08;cc.Contrast=.08;cc.Saturation=-.05;blur.Size=0
 elseif b=="RIDGE" then atmosphere.Density=.17;atmosphere.Haze=.85;atmosphere.Glare=.12;cc.Contrast=.1;cc.Saturation=-.035;blur.Size=0
 else atmosphere.Density=.12;atmosphere.Haze=.55;atmosphere.Glare=.16;cc.Contrast=.11;cc.Saturation=-.025;blur.Size=0 end
 workspace:SetAttribute("ACC_LocalAltitudeBand",b)
end
local elapsed=0
RunService.RenderStepped:Connect(function(dt)
 elapsed+=dt;if elapsed<.35 then return end;elapsed=0
 local c=player.Character;local hrp=c and c:FindFirstChild("HumanoidRootPart");if not hrp then return end
 local b=bandFor(hrp.Position.Y);if b~=currentBand then currentBand=b;apply(b) end
end)
workspace:SetAttribute("ACC_AltitudeAtmosphereClient","v4.5")