-- [SYS-LIGHTS] AUTOMATIC CLUB LIGHTING / CROWD RESPONSE
local Lighting=game:GetService("Lighting")
local mapRoot=workspace:FindFirstChild("BBYA V5.2 MODULAR GREYBOX")
local a4=mapRoot and mapRoot:FindFirstChild("[A4] MAIN CLUB / DANCE HALL")
local clubLights={}
if a4 then for _,d in ipairs(a4:GetDescendants()) do if d:IsA("PointLight") and d.Name=="BBYA Decorative Light" then table.insert(clubLights,d) end end end
local function apply()
 local intensity=workspace:GetAttribute("BBYACrowdIntensity") or 0;local party=workspace:GetAttribute("BBYAPartyMode")==true
 local base=.28+intensity*.07+(party and .12 or 0)
 for _,l in ipairs(clubLights) do if l.Parent then l.Brightness=math.min(base,.65);l.Range=math.min(9+intensity*1.5,14) end end
 Lighting.ClockTime=party and 22.8 or 21.35
 local bloom=Lighting:FindFirstChild("BBYA V5 Bloom");if bloom then bloom.Intensity=party and .55 or .45 end
end
workspace:GetAttributeChangedSignal("BBYACrowdIntensity"):Connect(apply)
workspace:GetAttributeChangedSignal("BBYAPartyMode"):Connect(apply)
apply()
workspace:SetAttribute("BBYASystemLights","5.0")
