-- BBYA MUSIC UI TEST — CLUB GEAR v4 VERIFIED EQUIP
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- One server authority for on-demand Party Stuff. No preload.

local Players=game:GetService("Players")
local Debris=game:GetService("Debris")
local TweenService=game:GetService("TweenService")
local Workspace=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local COLORS={Color3.fromRGB(0,205,235),Color3.fromRGB(255,42,157),Color3.fromRGB(255,211,55),Color3.fromRGB(255,255,255)}
local GEAR_NAMES={["Money Gun"]=true,["Glowstick"]=true,["Party Sparkler"]=true}

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes"; remotes.Parent=ReplicatedStorage
local gearRemote=remotes:FindFirstChild("ClubGear") or Instance.new("RemoteEvent")
gearRemote.Name="ClubGear"; gearRemote.Parent=remotes

local function clearGear(container)
 if not container then return end
 for _,child in ipairs(container:GetChildren()) do if child:IsA("Tool") and GEAR_NAMES[child.Name] then child:Destroy() end end
end
local function baseTool(name,size,color,material)
 local tool=Instance.new("Tool"); tool.Name=name; tool.RequiresHandle=true; tool.CanBeDropped=false; tool.ManualActivationOnly=false; tool.ToolTip="BBYA cosmetic club prop"
 local h=Instance.new("Part"); h.Name="Handle"; h.Size=size; h.Color=color; h.Material=material; h.CanCollide=false; h.CanTouch=false; h.CanQuery=false
 h.Massless=true; h.TopSurface=Enum.SurfaceType.Smooth; h.BottomSurface=Enum.SurfaceType.Smooth; h.Parent=tool
 return tool,h
end
local function makeMoneyGun()
 local tool,h=baseTool("Money Gun",Vector3.new(.55,.8,1.7),Color3.fromRGB(32,34,39),Enum.Material.Metal)
 local light=Instance.new("PointLight"); light.Color=Color3.fromRGB(66,230,124); light.Brightness=.35; light.Range=5; light.Parent=h
 local busy=false
 tool.Activated:Connect(function()
  if busy or not h.Parent then return end; busy=true
  local origin=h.CFrame*CFrame.new(0,0,-1.1)
  for i=1,7 do task.delay((i-1)*.055,function()
   if not h.Parent then return end
   local note=Instance.new("Part"); note.Name="BBYAMoneyFx"; note.Size=Vector3.new(.78,.035,.42); note.Color=Color3.fromRGB(91,203,109)
   note.Material=Enum.Material.SmoothPlastic; note.Anchored=true; note.CanCollide=false; note.CanTouch=false; note.CanQuery=false; note.CastShadow=false
   note.CFrame=origin*CFrame.Angles(math.rad(math.random(-12,12)),math.rad(math.random(-9,9)),math.rad(math.random(-25,25))); note.Parent=Workspace
   local target=note.CFrame*CFrame.new(0,math.random(-1,3)*.25,-math.random(12,18))*CFrame.Angles(0,0,math.rad(math.random(-160,160)))
   TweenService:Create(note,TweenInfo.new(.65,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CFrame=target,Transparency=.15}):Play(); Debris:AddItem(note,.8)
  end) end
  task.delay(.55,function() busy=false end)
 end)
 return tool
end
local function makeGlowstick()
 local tool,h=baseTool("Glowstick",Vector3.new(.28,2.4,.28),COLORS[1],Enum.Material.Neon)
 local light=Instance.new("PointLight"); light.Color=COLORS[1]; light.Brightness=1.15; light.Range=12; light.Shadows=false; light.Parent=h
 local idx=1; tool.Activated:Connect(function() idx=(idx%#COLORS)+1; h.Color=COLORS[idx]; light.Color=COLORS[idx] end)
 return tool
end
local function makeSparkler()
 local tool,h=baseTool("Party Sparkler",Vector3.new(.22,2.1,.22),Color3.fromRGB(80,80,84),Enum.Material.Metal)
 local att=Instance.new("Attachment"); att.Position=Vector3.new(0,1.08,0); att.Parent=h
 local emitter=Instance.new("ParticleEmitter"); emitter.Enabled=false; emitter.Rate=42; emitter.Lifetime=NumberRange.new(.35,.7); emitter.Speed=NumberRange.new(2.5,5)
 emitter.SpreadAngle=Vector2.new(180,180); emitter.LightEmission=.9; emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.16),NumberSequenceKeypoint.new(1,0)})
 emitter.Color=ColorSequence.new(Color3.fromRGB(255,232,160),Color3.fromRGB(255,255,255)); emitter.Parent=att
 local light=Instance.new("PointLight"); light.Enabled=false; light.Color=Color3.fromRGB(255,224,155); light.Brightness=1.4; light.Range=10; light.Parent=h
 local on=false; tool.Activated:Connect(function() on=not on; emitter.Enabled=on; light.Enabled=on end)
 return tool
end
local function makeGear(name)
 if name=="Money Gun" then return makeMoneyGun() elseif name=="Glowstick" then return makeGlowstick() elseif name=="Party Sparkler" then return makeSparkler() end
end
local function putAway(player)
 clearGear(player:FindFirstChildOfClass("Backpack")); clearGear(player.Character)
end
local function result(player,ok,name,message)
 gearRemote:FireClient(player,"result",{ok=ok,name=name,message=message})
end
local function equipGear(player,name)
 if not GEAR_NAMES[name] then result(player,false,name,"UNKNOWN PARTY GEAR"); return end
 local char=player.Character
 local hum=char and char:FindFirstChildOfClass("Humanoid")
 local backpack=player:FindFirstChildOfClass("Backpack") or player:WaitForChild("Backpack",3)
 if not char or not hum or not backpack or hum.Health<=0 then result(player,false,name,"CHARACTER NOT READY"); return end
 putAway(player)
 local tool=makeGear(name); if not tool then result(player,false,name,"GEAR BUILD FAILED"); return end
 tool.Parent=backpack
 hum:EquipTool(tool)
 task.delay(.08,function()
  if not tool.Parent then result(player,false,name,"GEAR LOST"); return end
  if tool.Parent~=char then tool.Parent=char; task.wait() end
  local ok=(tool.Parent==char)
  player:SetAttribute("BBYAPartyGear",ok and name or "")
  result(player,ok,name,ok and ("EQUIPPED • "..string.upper(name)) or "EQUIP FAILED")
 end)
end

gearRemote.OnServerEvent:Connect(function(player,action,name)
 if action=="equip" then equipGear(player,tostring(name or ""))
 elseif action=="putAway" or action=="refresh" then putAway(player); player:SetAttribute("BBYAPartyGear",""); result(player,true,"","PARTY GEAR PUT AWAY") end
end)
local function bindPlayer(player)
 player.CharacterAdded:Connect(function() task.defer(function() putAway(player); player:SetAttribute("BBYAPartyGear","") end) end)
 task.defer(function() putAway(player) end)
end
Players.PlayerAdded:Connect(bindPlayer)
for _,p in ipairs(Players:GetPlayers()) do bindPlayer(p) end
print("[BBYA TEST] Club Gear v4 online: verified server equip + client acknowledgement")
