-- BBYA SOCIAL HUB — STRICT VENUE AUDIO ROUTER v3
-- Each music channel is audible only inside its own physical venue.
-- VIP is now a separate channel instead of inheriting Main Club audio.

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

local cache={}
local gates={}
local muteButton

local function ensureGate(key,g)
 local gate=g:FindFirstChild("BBYAVenueGateV3") or g:FindFirstChild("BBYAVenueGateV2")
 if gate and not gate:IsA("EqualizerSoundEffect") then gate:Destroy();gate=nil end
 if not gate then gate=Instance.new("EqualizerSoundEffect");gate.Name="BBYAVenueGateV3";gate.Parent=g else gate.Name="BBYAVenueGateV3" end
 gate.Enabled=true;gates[key]=gate;return gate
end
local function resolveGroups()
 for key,spec in pairs(GROUPS) do
  local g=SoundService:FindFirstChild(spec.name)
  if g and g:IsA("SoundGroup") then cache[key]=g;ensureGate(key,g) end
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
 local b=resolveMuteButton()
 return b and string.upper(b.Text or "")=="UNMUTE LOCAL" or false
end

local function venueAtPosition(p)
 if p.Y<-4.5 then return "UNDERGROUND" end
 if p.Y>=40 and p.Y<=60 and math.abs(p.X)<=62 and p.Z>=-48 and p.Z<=48 then return "ROOFTOP" end
 if p.Y>=20 and p.Y<40 and math.abs(p.X)<=58 and p.Z>=-46 and p.Z<=46 then return "VIP" end
 if p.Y>-4 and p.Y<34 and math.abs(p.X)<61 and p.Z>157 and p.Z<253 then return "FUNKOT" end
 if p.Y>-4 and p.Y<20 and math.abs(p.X)<=61 and p.Z>=72 and p.Z<=152 then return "SKATEPARK" end
 if p.Y>-4 and p.Y<18 and math.abs(p.X)<=61 and p.Z>=0 and p.Z<70 then return "MAIN" end
 return "NONE"
end
local function currentPlayerVenue()
 local ch=player.Character;local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 if not hrp then return "NONE" end
 return venueAtPosition(hrp.Position)
end

local function setGate(gate,open)
 local gain=open and 0 or -80
 if gate.LowGain~=gain then gate.LowGain=gain end
 if gate.MidGain~=gain then gate.MidGain=gain end
 if gate.HighGain~=gain then gate.HighGain=gain end
end
local function enforce()
 resolveGroups()
 local currentVenue=currentPlayerVenue()
 local muted=locallyMuted()
 for key,g in pairs(cache) do
  if g and g.Parent then
   local open=(not muted and currentVenue==key)
   local gate=gates[key] or ensureGate(key,g)
   setGate(gate,open)
   g:SetAttribute("BBYALocalAudible",open)
   g:SetAttribute("BBYAAudioRouterVenue",currentVenue)
  end
 end
 player:SetAttribute("BBYAAudioVenue",currentVenue)
end

local function bindMute()
 local b=resolveMuteButton()
 if b and not b:GetAttribute("BBYAAudioMuteGuardV3") then
  b:SetAttribute("BBYAAudioMuteGuardV3",true)
  b:GetPropertyChangedSignal("Text"):Connect(function()task.defer(enforce)end)
 end
end
SoundService.ChildAdded:Connect(function(child)if child:IsA("SoundGroup") then task.defer(enforce)end end)
pg.ChildAdded:Connect(function()task.defer(function()bindMute();enforce()end)end)
player.CharacterAdded:Connect(function()task.delay(.35,enforce)end)

local acc=0
RunService.Heartbeat:Connect(function(dt)
 acc+=dt;if acc<.10 then return end;acc=0
 bindMute();enforce()
end)

task.defer(function()bindMute();enforce()end)
print("[BBYA] Strict venue audio router v3: MAIN / UNDERGROUND / VIP / FUNKOT / SKATEPARK / ROOFTOP isolated")
