-- [SYS-LIGHTS] AUTOMATIC CLUB LIGHTING / CROWD RESPONSE
local Lighting=game:GetService("Lighting")
local mapRoot=workspace:FindFirstChild("BBYA V5.3 MASTER PLAN")
local a4=mapRoot and mapRoot:FindFirstChild("[A4] MAIN CLUB / DANCE HALL")
local clubLights={}
if a4 then for _,d in ipairs(a4:GetDescendants()) do if d:IsA("PointLight") and d.Name=="BBYA Decorative Light" then table.insert(clubLights,d) end end end
local function apply()
 local intensity=workspace:GetAttribute("BBYACrowdIntensity") or 0;local party=workspace:GetAttribute("BBYAPartyMode")==true
 -- Keep a bright social floor at all crowd levels; crowd/party adds energy instead of rescuing darkness.
 local base=.42+intensity*.08+(party and .10 or 0)
 for _,l in ipairs(clubLights) do if l.Parent then l.Brightness=math.min(base,.86);l.Range=math.min(12+intensity*1.7,17) end end
 Lighting.ClockTime=party and 22.2 or 21.05
 local bloom=Lighting:FindFirstChild("BBYA V5 Bloom");if bloom then bloom.Intensity=party and .46 or .36 end
end
workspace:GetAttributeChangedSignal("BBYACrowdIntensity"):Connect(apply)
workspace:GetAttributeChangedSignal("BBYAPartyMode"):Connect(apply)
apply()
workspace:SetAttribute("BBYASystemLights","5.2-BRIGHT-SOCIAL")
