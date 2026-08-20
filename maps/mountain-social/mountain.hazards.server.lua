-- ACC Mountain Master v3.0 — environmental hazard runtime
local Players=game:GetService("Players")
local Debris=game:GetService("Debris")
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("ACC_MountainSocial",20); if not root then return end
local decor=root:FindFirstChild("Decor") or root
local hazardFolder=root:FindFirstChild("Hazards"); if hazardFolder then hazardFolder:Destroy() end
hazardFolder=Instance.new("Folder"); hazardFolder.Name="Hazards"; hazardFolder.Parent=root
local function zone(name,pos,size,kind)
 local p=Instance.new("Part"); p.Name=name; p.Anchored=true; p.CanCollide=false; p.CanTouch=true; p.CanQuery=false; p.Transparency=1; p.Size=size; p.CFrame=CFrame.new(pos); p:SetAttribute("HazardType",kind); p.Parent=hazardFolder; return p
end
local zones={{zone("Rockfall_TebingAngin",Vector3.new(-118,315,34),Vector3.new(125,80,100),"ROCKFALL"),"ROCKFALL"},{zone("Wind_Ridge",Vector3.new(190,530,-440),Vector3.new(170,95,170),"HIGH_WIND"),"HIGH_WIND"},{zone("DeathZone",Vector3.new(70,585,-565),Vector3.new(260,135,260),"DEATH_ZONE"),"DEATH_ZONE"}}
local lastHit={}
local function playerFromPart(hit) local char=hit and hit:FindFirstAncestorOfClass("Model"); if not char then return nil end; return Players:GetPlayerFromCharacter(char),char end
for _,entry in ipairs(zones) do
 local trigger,kind=entry[1],entry[2]
 trigger.Touched:Connect(function(hit)
  local player,char=playerFromPart(hit); if not player or not char then return end
  local key=tostring(player.UserId)..kind; if lastHit[key] and os.clock()-lastHit[key]<3 then return end; lastHit[key]=os.clock()
  local hum=char:FindFirstChildOfClass("Humanoid"); local hrp=char:FindFirstChild("HumanoidRootPart"); if not hum or not hrp then return end
  if kind=="ROCKFALL" then hum:TakeDamage(5)
  elseif kind=="HIGH_WIND" then local wind=Workspace:GetAttribute("ACC_WindPower") or 25; hrp.AssemblyLinearVelocity += Vector3.new(math.clamp(wind*.32,5,20),2,math.clamp(wind*.12,2,10))
  elseif kind=="DEATH_ZONE" then player:SetAttribute("Temperature",math.max(0,(player:GetAttribute("Temperature") or 100)-4)); player:SetAttribute("Oxygen",math.max(0,(player:GetAttribute("Oxygen") or 100)-3)) end
 end)
end
local function spawnRock()
 local rock=Instance.new("Part"); rock.Name="FallingRock"; rock.Shape=Enum.PartType.Ball; rock.Size=Vector3.new(math.random(5,9),math.random(5,9),math.random(5,9)); rock.Material=Enum.Material.Rock; rock.Color=Color3.fromRGB(79,78,75); rock.Position=Vector3.new(-118+math.random(-45,45),365+math.random(0,25),34+math.random(-35,35)); rock.Anchored=false; rock.Parent=decor; Debris:AddItem(rock,12)
end
task.spawn(function() while true do task.wait(math.random(28,55)); if Workspace:GetAttribute("ACC_WeatherState")~="CLEAR" or math.random()<.55 then for _=1,math.random(2,4) do spawnRock(); task.wait(.35) end end end end)
Workspace:SetAttribute("ACC_MountainHazards","v3.0")
print("[ACC] Mountain v3 environmental hazards ready")
