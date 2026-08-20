-- ACC Mountain Master v3.0 — dynamic mountain weather
local Lighting=game:GetService("Lighting")
local Workspace=game:GetService("Workspace")
local Terrain=Workspace.Terrain
local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere",Lighting)
local clouds=Terrain:FindFirstChildOfClass("Clouds") or Instance.new("Clouds",Terrain)
local presets={
 CLEAR={density=.28,cover=.32,haze=1.2,glare=.18,brightness=2.15,wind=12},
 FOG={density=.48,cover=.68,haze=3.2,glare=.03,brightness=1.65,wind=8},
 RAIN={density=.58,cover=.82,haze=2.5,glare=.02,brightness=1.45,wind=24},
 STORM={density=.72,cover=.95,haze=3.1,glare=0,brightness=1.05,wind=46},
 BLIZZARD={density=.82,cover=.92,haze=4.2,glare=.02,brightness=1.35,wind=62}
}
local sequence={"CLEAR","FOG","RAIN","CLEAR","STORM","CLEAR","BLIZZARD"}
local function apply(name)
 local p=presets[name] or presets.CLEAR
 Workspace:SetAttribute("ACC_WeatherState",name); Workspace:SetAttribute("ACC_WindPower",p.wind); Workspace.GlobalWind=Vector3.new(p.wind,0,p.wind*.35)
 clouds.Density=p.density; clouds.Cover=p.cover; clouds.Color=name=="STORM" and Color3.fromRGB(122,128,136) or name=="BLIZZARD" and Color3.fromRGB(214,221,229) or Color3.fromRGB(235,239,242)
 atmosphere.Density=math.min(.65,.18+p.haze*.055); atmosphere.Haze=p.haze; atmosphere.Glare=p.glare
 Lighting.Brightness=p.brightness; Lighting.EnvironmentDiffuseScale=name=="CLEAR" and .55 or .35; Lighting.EnvironmentSpecularScale=name=="CLEAR" and .65 or .4
end
apply("CLEAR")
task.spawn(function() local index=1 while true do task.wait(math.random(135,230)); index=index%#sequence+1; apply(sequence[index]) end end)
task.spawn(function() while true do task.wait(2); Lighting.ClockTime=(Lighting.ClockTime+(24/(48*60))*2)%24; Workspace:SetAttribute("ACC_TimeOfDay",Lighting.ClockTime) end end)
Workspace:SetAttribute("ACC_MountainWeather","v3.0")
print("[ACC] Mountain v3 weather/day-night ready")
