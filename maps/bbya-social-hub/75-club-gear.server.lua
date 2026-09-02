-- BBYA MUSIC UI TEST — CLUB GEAR v7 DIRECT CHARACTER PROPS
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- ONE server authority for Party Stuff.
-- No Tool, no Backpack, no Humanoid:EquipTool. Props are welded directly to the right hand.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local GEAR_NAMES={["Money Gun"]=true,["Glowstick"]=true,["Party Sparkler"]=true}
local PROP_NAME="BBYAPartyProp"

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes"; remotes.Parent=ReplicatedStorage
local gearRemote=remotes:FindFirstChild("ClubGear") or Instance.new("RemoteEvent")
gearRemote.Name="ClubGear"; gearRemote.Parent=remotes

local function result(player,ok,name,message)
 gearRemote:FireClient(player,"result",{ok=ok,name=name,message=message})
end

local function rightHand(char)
 if not char then return nil end
 return char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm") or char:FindFirstChild("RightLowerArm")
end

local function clearOldTools(player)
 local backpack=player and player:FindFirstChildOfClass("Backpack")
 for _,container in ipairs({backpack,player and player.Character}) do
  if container then
   for _,child in ipairs(container:GetChildren()) do
    if child:IsA("Tool") and GEAR_NAMES[child.Name] then child:Destroy() end
   end
  end
 end
end

local function clearProp(player)
 clearOldTools(player)
 local char=player and player.Character
 if not char then return end
 local prop=char:FindFirstChild(PROP_NAME)
 if prop then prop:Destroy() end
 for _,handName in ipairs({"RightHand","Right Arm","RightLowerArm"}) do
  local hand=char:FindFirstChild(handName)
  if hand then
   local grip=hand:FindFirstChild("BBYAPartyPropGrip")
   if grip then grip:Destroy() end
  end
 end
end

local function makePart(name,size,color,material,parent)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=size
 p.Color=color
 p.Material=material
 p.Anchored=false
 p.CanCollide=false
 p.CanTouch=false
 p.CanQuery=false
 p.Massless=true
 p.CastShadow=false
 p.TopSurface=Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent
 return p
end

local function weld(root,part,c0)
 part.CFrame=root.CFrame*c0
 local w=Instance.new("WeldConstraint")
 w.Part0=root; w.Part1=part; w.Parent=root
end

local function buildMoneyGun(model)
 local handle=makePart("Handle",Vector3.new(.48,.75,1.55),Color3.fromRGB(35,37,42),Enum.Material.Metal,model)
 local barrel=makePart("Barrel",Vector3.new(.36,.36,.8),Color3.fromRGB(55,58,64),Enum.Material.Metal,model)
 weld(handle,barrel,CFrame.new(0,.05,-1.02))
 local grip=makePart("Grip",Vector3.new(.28,.72,.34),Color3.fromRGB(24,25,29),Enum.Material.Metal,model)
 weld(handle,grip,CFrame.new(0,-.65,.28)*CFrame.Angles(math.rad(-12),0,0))
 local light=Instance.new("PointLight")
 light.Color=Color3.fromRGB(66,230,124); light.Brightness=.5; light.Range=5; light.Parent=barrel
 return handle,CFrame.new(.03,-.22,-.58)*CFrame.Angles(math.rad(-82),0,0)
end

local function buildGlowstick(model)
 local handle=makePart("Handle",Vector3.new(.28,2.65,.28),Color3.fromRGB(0,205,235),Enum.Material.Neon,model)
 local cap1=makePart("CapTop",Vector3.new(.34,.18,.34),Color3.fromRGB(25,27,33),Enum.Material.Metal,model)
 local cap2=makePart("CapBottom",Vector3.new(.34,.18,.34),Color3.fromRGB(25,27,33),Enum.Material.Metal,model)
 weld(handle,cap1,CFrame.new(0,1.41,0)); weld(handle,cap2,CFrame.new(0,-1.41,0))
 local light=Instance.new("PointLight")
 light.Color=handle.Color; light.Brightness=1.2; light.Range=12; light.Shadows=false; light.Parent=handle
 return handle,CFrame.new(.05,-1.08,-.06)*CFrame.Angles(0,0,math.rad(8))
end

local function buildSparkler(model)
 local handle=makePart("Handle",Vector3.new(.16,2.35,.16),Color3.fromRGB(95,95,100),Enum.Material.Metal,model)
 local tip=makePart("SparkTip",Vector3.new(.22,.24,.22),Color3.fromRGB(255,221,130),Enum.Material.Neon,model)
 weld(handle,tip,CFrame.new(0,1.3,0))
 local att=Instance.new("Attachment"); att.Parent=tip
 local emitter=Instance.new("ParticleEmitter")
 emitter.Enabled=true; emitter.Rate=38; emitter.Lifetime=NumberRange.new(.28,.58); emitter.Speed=NumberRange.new(2.2,4.2)
 emitter.SpreadAngle=Vector2.new(180,180); emitter.LightEmission=1
 emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.14),NumberSequenceKeypoint.new(1,0)})
 emitter.Color=ColorSequence.new(Color3.fromRGB(255,228,150),Color3.fromRGB(255,255,255)); emitter.Parent=att
 local light=Instance.new("PointLight"); light.Color=Color3.fromRGB(255,224,155); light.Brightness=1.3; light.Range=9; light.Parent=tip
 return handle,CFrame.new(.04,-1.02,-.03)
end

local function buildProp(name)
 local model=Instance.new("Model")
 model.Name=PROP_NAME
 model:SetAttribute("BBYAPartyGear",name)
 local handle,offset
 if name=="Money Gun" then handle,offset=buildMoneyGun(model)
 elseif name=="Glowstick" then handle,offset=buildGlowstick(model)
 elseif name=="Party Sparkler" then handle,offset=buildSparkler(model) end
 if not handle then model:Destroy(); return nil end
 model.PrimaryPart=handle
 return model,handle,offset
end

local function equipProp(player,name)
 if not GEAR_NAMES[name] then result(player,false,name,"UNKNOWN PARTY GEAR"); return end
 local char=player.Character
 local hum=char and char:FindFirstChildOfClass("Humanoid")
 local hand=rightHand(char)
 if not char or not hum or hum.Health<=0 or not hand or not hand:IsA("BasePart") then
  result(player,false,name,"CHARACTER HAND NOT READY"); return
 end

 clearProp(player)
 local model,handle,offset=buildProp(name)
 if not model or not handle then result(player,false,name,"PROP BUILD FAILED"); return end
 model.Parent=char
 handle.CFrame=hand.CFrame*offset

 local grip=Instance.new("Motor6D")
 grip.Name="BBYAPartyPropGrip"
 grip.Part0=hand
 grip.Part1=handle
 grip.C0=offset
 grip.C1=CFrame.new()
 grip.Parent=hand

 local ok=(model.Parent==char and grip.Part0==hand and grip.Part1==handle)
 if not ok then model:Destroy() end
 player:SetAttribute("BBYAPartyGear",ok and name or "")
 result(player,ok,name,ok and ("EQUIPPED • "..string.upper(name)) or "PROP GRIP FAILED")
end

gearRemote.OnServerEvent:Connect(function(player,action,name)
 if action=="equip" then
  equipProp(player,tostring(name or ""))
 elseif action=="putAway" or action=="refresh" then
  clearProp(player)
  player:SetAttribute("BBYAPartyGear","")
  result(player,true,"","PARTY GEAR PUT AWAY")
 end
end)

local function bindPlayer(player)
 player.CharacterAdded:Connect(function()
  task.defer(function()
   clearProp(player)
   player:SetAttribute("BBYAPartyGear","")
  end)
 end)
 task.defer(function() clearProp(player) end)
end
Players.PlayerAdded:Connect(bindPlayer)
for _,p in ipairs(Players:GetPlayers()) do bindPlayer(p) end

print("[BBYA TEST] Club Gear v7 online: direct welded character props, no Tools")
