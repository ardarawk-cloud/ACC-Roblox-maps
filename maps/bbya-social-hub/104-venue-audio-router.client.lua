-- BBYA SOCIAL HUB — STRICT VENUE AUDIO ROUTER v9.1
-- Deterministic local venue isolation using EQ gates only.
-- V9.1 changes only VIP/Rooftop coordinate bounds for the tall-avatar vertical stack.
-- IMPORTANT: this router never mutates SoundGroup.Volume or Sound.Volume.

local Players=game:GetService("Players")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local GROUPS={
 MAIN={name="BBYAClubMaster"},
 UNDERGROUND={name="BBYABasementMaster"},
 VIP={name="BBYAVIPMaster"},
 FUNKOT={name="BBYAFunkotMaster"},
 SKATEPARK={name="BBYASkateparkMaster"},
 ROOFTOP={name="BBYARooftopMaster"},
}

local MAIN_TRIM={CORE=0,FORMER_STUDIO_LOUNGE=-3.0,RESTROOM=-7.0}
local cache={}
local gates={}
local directFunkotGates=setmetatable({}, {__mode="k"})
local muteButton

local function setGate(gate,open,gainDb)
 local gain=open and (gainDb or 0) or -80
 if gate.LowGain~=gain then gate.LowGain=gain end
 if gate.MidGain~=gain then gate.MidGain=gain end
 if gate.HighGain~=gain then gate.HighGain=gain end
end

local function ensureGate(key,g)
 local gate=g:FindFirstChild("BBYAVenueGateV9") or g:FindFirstChild("BBYAVenueGateV8") or g:FindFirstChild("BBYAVenueGateV7") or g:FindFirstChild("BBYAVenueGateV6") or g:FindFirstChild("BBYAVenueGateV5") or g:FindFirstChild("BBYAVenueGateV4") or g:FindFirstChild("BBYAVenueGateV3") or g:FindFirstChild("BBYAVenueGateV2")
 if gate and not gate:IsA("EqualizerSoundEffect") then gate:Destroy();gate=nil end
 if not gate then gate=Instance.new("EqualizerSoundEffect");gate.Parent=g end
 gate.Name="BBYAVenueGateV9"
 gate.Enabled=true
 gates[key]=gate
 g:SetAttribute("BBYAAudioIsolationAuthority","ROUTER_V9_EQ_ONLY")
 return gate
end

local function resolveGroups()
 for key,spec in pairs(GROUPS) do
  local g=SoundService:FindFirstChild(spec.name)
  if g and g:IsA("SoundGroup") then cache[key]=g;ensureGate(key,g) else cache[key]=nil;gates[key]=nil end
 end
end

local function resolveMuteButton()
 if muteButton and muteButton.Parent then return muteButton end
 local gui=pg:FindFirstChild("BBYAClubUI")
 if not gui then return nil end
 for _,d in ipairs(gui:GetDescendants()) do
  if d:IsA("TextButton") then
   local up=string.upper(d.Text or "")
   if up=="MUTE LOCAL" or up=="UNMUTE LOCAL" then muteButton=d;return d end
  end
 end
end

local function locallyMuted()
 if player:GetAttribute("BBYAMusicMuted")==true then return true end
 local b=resolveMuteButton()
 return b and string.upper(b.Text or "")=="UNMUTE LOCAL" or false
end

local function inBox(p,x0,x1,y0,y1,z0,z1)
 return p.X>=x0 and p.X<=x1 and p.Y>=y0 and p.Y<=y1 and p.Z>=z0 and p.Z<=z1
end

local function mainRoomAtPosition(p)
 if inBox(p,-61,61,-4,18,0,70) then return "CORE" end
 if inBox(p,-53,-25.5,-4,18,-36.5,7) then return "FORMER_STUDIO_LOUNGE" end
 if inBox(p,34.5,51.5,-4,18,-32.5,-8.4) then return "RESTROOM" end
 return nil
end

local function venueAtPosition(p)
 if p.Y<-4.5 then return "UNDERGROUND",nil end
 if p.Y>=55 and p.Y<=80 and math.abs(p.X)<=62 and p.Z>=-48 and p.Z<=48 then return "ROOFTOP",nil end
 if p.Y>=20 and p.Y<55 and math.abs(p.X)<=58 and p.Z>=-46 and p.Z<=46 then return "VIP",nil end
 if p.Y>-4 and p.Y<34 and math.abs(p.X)<61 and p.Z>157 and p.Z<253 then return "FUNKOT",nil end
 if p.Y>-4 and p.Y<20 and math.abs(p.X)<=61 and p.Z>=72 and p.Z<=152 then return "SKATEPARK",nil end
 local mainRoom=mainRoomAtPosition(p)
 if mainRoom then return "MAIN",mainRoom end
 return "NONE",nil
end

local function currentPlayerAudioContext()
 local ch=player.Character
 local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 if not hrp then return "NONE",nil,0 end
 local venue,room=venueAtPosition(hrp.Position)
 local trim=(venue=="MAIN" and room and MAIN_TRIM[room]) or 0
 return venue,room,trim
end

local function isFunkotSound(s)
 if not (s and s:IsA("Sound")) then return false end
 local sg=s.SoundGroup
 if sg and sg.Name=="BBYAFunkotMaster" then return true end
 return string.sub(s.Name,1,10)=="BBYAFunkot"
end

local function ensureDirectFunkotGate(sound)
 local gate=directFunkotGates[sound]
 if gate and gate.Parent==sound then return gate end
 gate=sound:FindFirstChild("BBYAFunkotHardGateV9")
 if gate and not gate:IsA("EqualizerSoundEffect") then gate:Destroy();gate=nil end
 if not gate then gate=Instance.new("EqualizerSoundEffect");gate.Name="BBYAFunkotHardGateV9";gate.Parent=sound end
 gate.Enabled=true
 directFunkotGates[sound]=gate
 sound:SetAttribute("BBYAFunkotLeakGuard","HARD_GATE_V9")
 return gate
end

local function enforceDirectFunkot(open)
 local count=0
 for _,d in ipairs(SoundService:GetDescendants()) do
  if d:IsA("Sound") and isFunkotSound(d) then
   local gate=ensureDirectFunkotGate(d)
   setGate(gate,open,0)
   d:SetAttribute("BBYALocalAudible",open)
   d:SetAttribute("BBYAFunkotHardGateOpen",open)
   count+=1
  end
 end
 player:SetAttribute("BBYAFunkotDirectGateCount",count)
 player:SetAttribute("BBYAFunkotHardLeakGuard",true)
end

local function enforce()
 resolveGroups()
 local currentVenue,currentRoom,mainTrim=currentPlayerAudioContext()
 local muted=locallyMuted()
 for key,g in pairs(cache) do
  if g and g.Parent then
   local open=(not muted and currentVenue==key)
   local trim=(key=="MAIN" and open) and mainTrim or 0
   local gate=gates[key] or ensureGate(key,g)
   setGate(gate,open,trim)
   g:SetAttribute("BBYALocalAudible",open)
   g:SetAttribute("BBYAAudioRouterVenue",currentVenue)
   g:SetAttribute("BBYAActiveTrimDb",open and trim or -80)
   g:SetAttribute("BBYAAudioIsolationAuthority","ROUTER_V9_EQ_ONLY")
  end
 end
 enforceDirectFunkot(not muted and currentVenue=="FUNKOT")
 player:SetAttribute("BBYAAudioVenue",currentVenue)
 player:SetAttribute("BBYAAudioRoom",currentRoom or "NONE")
 player:SetAttribute("BBYAMainTrimDb",currentVenue=="MAIN" and mainTrim or -80)
 player:SetAttribute("BBYAAudioFailClosed",currentVenue=="NONE")
 player:SetAttribute("BBYAAudioRouterAuthority","ROUTER_V9_EQ_ONLY")
end

local function bindMute()
 local b=resolveMuteButton()
 if b and not b:GetAttribute("BBYAAudioMuteGuardV9") then
  b:SetAttribute("BBYAAudioMuteGuardV9",true)
  b:GetPropertyChangedSignal("Text"):Connect(function()task.defer(enforce)end)
 end
end

SoundService.ChildAdded:Connect(function(child)
 if child:IsA("SoundGroup") then task.defer(enforce) end
end)
SoundService.DescendantAdded:Connect(function(child)
 if child:IsA("Sound") and isFunkotSound(child) then setGate(ensureDirectFunkotGate(child),false,0) end
 task.defer(enforce)
end)
SoundService.ChildRemoved:Connect(function(child)
 if child:IsA("SoundGroup") then task.defer(enforce) end
end)
pg.ChildAdded:Connect(function()task.defer(function()bindMute();enforce()end)end)
player.CharacterAdded:Connect(function()
 task.defer(enforce)
 task.delay(.10,enforce)
 task.delay(.35,enforce)
end)
player:GetAttributeChangedSignal("BBYAMusicMuted"):Connect(function()task.defer(enforce)end)

local acc=0
RunService.Heartbeat:Connect(function(dt)
 acc+=dt
 if acc<.05 then return end
 acc=0
 bindMute()
 enforce()
end)

task.defer(function()bindMute();enforce()end)
print("[BBYA] Strict venue audio router v9.1: EQ-only isolation preserved / tall-stack Y bounds aligned")