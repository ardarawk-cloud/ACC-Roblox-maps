-- ACC Mountain Master v3.0 — altitude survival simulation
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Workspace=game:GetService("Workspace")
local function clamp(v) return math.clamp(v,0,100) end
local defaults={Stamina=100,Hydration=100,Hunger=100,Temperature=100,Oxygen=100}
local function setupPlayer(player)
 for name,value in pairs(defaults) do if player:GetAttribute(name)==nil then player:SetAttribute(name,value) end end
 player:SetAttribute("AltitudeZone","BASE"); player:SetAttribute("SurvivalReady",true)
end
for _,player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
Players.PlayerAdded:Connect(setupPlayer)
local function getZone(y) if y<220 then return "LOWER",0 elseif y<390 then return "MIST",1 elseif y<540 then return "ALPINE",2 else return "DEATH_ZONE",3 end end
local elapsed=0
RunService.Heartbeat:Connect(function(dt)
 elapsed+=dt; if elapsed<1 then return end; local step=elapsed; elapsed=0
 local weather=Workspace:GetAttribute("ACC_WeatherState") or "CLEAR"
 for _,player in ipairs(Players:GetPlayers()) do
  local char=player.Character; local root=char and char:FindFirstChild("HumanoidRootPart"); local hum=char and char:FindFirstChildOfClass("Humanoid")
  if root and hum and hum.Health>0 then
   local zone,severity=getZone(root.Position.Y); player:SetAttribute("AltitudeZone",zone); player:SetAttribute("Altitude",math.floor(root.Position.Y))
   local stamina=player:GetAttribute("Stamina") or 100; local hydration=player:GetAttribute("Hydration") or 100; local hunger=player:GetAttribute("Hunger") or 100; local temperature=player:GetAttribute("Temperature") or 100; local oxygen=player:GetAttribute("Oxygen") or 100
   local speed=root.AssemblyLinearVelocity.Magnitude
   if speed>12 then stamina-=(.8+severity*.3)*step else stamina+=(2.4-severity*.25)*step end
   hydration-=(.055+severity*.025)*step; hunger-=(.025+severity*.015)*step
   local cold=severity*.11; if weather=="RAIN" then cold+=.08 elseif weather=="STORM" then cold+=.16 elseif weather=="BLIZZARD" then cold+=.28 end
   if severity==0 and weather=="CLEAR" then temperature+=.18*step else temperature-=cold*step end
   if root.Position.Y>=520 then oxygen-=(.12+math.max(root.Position.Y-520,0)/1200)*step else oxygen+=.6*step end
   player:SetAttribute("Stamina",clamp(stamina)); player:SetAttribute("Hydration",clamp(hydration)); player:SetAttribute("Hunger",clamp(hunger)); player:SetAttribute("Temperature",clamp(temperature)); player:SetAttribute("Oxygen",clamp(oxygen))
   local danger=math.min(hydration,hunger,temperature,oxygen); if danger<=2 then hum:TakeDamage(4) end
   if stamina<=1 then hum.WalkSpeed=math.min(hum.WalkSpeed,10) elseif hum.WalkSpeed<16 then hum.WalkSpeed=16 end
  end
 end
end)
Workspace:SetAttribute("ACC_MountainSurvival","v3.0")
print("[ACC] Mountain v3 survival system ready")
