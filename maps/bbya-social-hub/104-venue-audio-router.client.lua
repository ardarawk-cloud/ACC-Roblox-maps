-- BBYA SOCIAL HUB — STRICT VENUE AUDIO ROUTER v6
-- Each music channel is audible only inside its own physical venue.
-- v6 adds fail-closed startup/neutral-zone volume enforcement so first join cannot leak venue music.
-- Main Club includes the former studio lounge + shared restroom with room-aware attenuation.
-- VIP is a separate channel. Compact Music v7 can mute locally through BBYAMusicMuted.

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

local MAIN_TRIM={
 CORE=0,
 FORMER_STUDIO_LOUNGE=-3.0,
 RESTROOM=-7.0,
}

local cache={}
local gates={}
local muteButton

local function ensureGate(key,g)
 local gate=g:FindFirstChild("BBYAVenueGateV6") or g:FindFirstChild("BBYAVenueGateV5") or g:FindFirstChild("BBYAVenueGateV4") or g:FindFirstChild("BBYAVenueGateV3") or g:FindFirstChild("BBYAVenueGateV2")
 if gate and not gate:IsA("EqualizerSoundEffect") then gate:Destroy();gate=nil end
 if not gate then
  gate=Instance.new("EqualizerSoundEffect")
  gate.Name="BBYAVenueGateV6"
  gate.Parent=g
 else
  gate.Name="BBYAVenueGateV6"
 end
 gate.Enabled=true
 gates[key]=gate
 return gate
end

local function resolveGroups()
 for key,spec in pairs(GROUPS) do
  local g=SoundService:FindFirstChild(spec.name)
  if g and g:IsA("SoundGroup") then
   cache[key]=g
   ensureGate(key,g)
  end
 end
end

local function resolveMuteButton()
 if muteButton and muteButton.Parent then return muteButton end
 local gui=pg:FindFirstChild("BBYAClubUI")
 if not gui then return nil end
 for _,d in ipairs(gui:GetDescendants()) do
  if d:IsA("TextButton") then
   local up=string.upper(d.Text or "")
   if up=="MUTE LOCAL" or up=="UNMUTE LOCAL" then
    muteButton=d
    return d
   end
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
 -- Existing Main Club room / dance floor / bar.
 if inBox(p,-61,61,-4,18,0,70) then return "CORE" end

 -- MainClubFinalAuthorityV2 / PureClubFrontExtension occupies roughly
 -- X -51.5..-26.5, Z -35.5..6.5. Keep a small safety margin around it.
 if inBox(p,-53,-25.5,-4,18,-36.5,7) then return "FORMER_STUDIO_LOUNGE" end

 -- SharedRestroomV1 v2 architecture: X 35.2..50.8, Z -30.8..-9.2.
 -- Slight margin keeps audio continuous through the doorway and deepest stalls.
 if inBox(p,34.5,51.5,-4,18,-32.5,-8.4) then return "RESTROOM" end

 return nil
end

local function venueAtPosition(p)
 if p.Y<-4.5 then return "UNDERGROUND",nil end
 if p.Y>=40 and p.Y<=60 and math.abs(p.X)<=62 and p.Z>=-48 and p.Z<=48 then return "ROOFTOP",nil end
 if p.Y>=20 and p.Y<40 and math.abs(p.X)<=58 and p.Z>=-46 and p.Z<=46 then return "VIP",nil end
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

local function setGate(gate,open,gainDb)
 local gain=open and (gainDb or 0) or -80
 if gate.LowGain~=gain then gate.LowGain=gain end
 if gate.MidGain~=gain then gate.MidGain=gain end
 if gate.HighGain~=gain then gate.HighGain=gain end
end

local function forceNeutralVolumes()
 local currentVenue=currentPlayerAudioContext()
 if currentVenue~="NONE" then return end
 resolveGroups()
 for _,g in pairs(cache) do
  if g and g.Parent and g.Volume~=0 then g.Volume=0 end
 end
 player:SetAttribute("BBYAAudioFailClosed",true)
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
   -- Hard fail-closed for startup, spawn, Mall, and every other neutral area.
   -- This also defeats legacy RenderStepped mixers that still classify large +Z areas as MAIN.
   if currentVenue=="NONE" and g.Volume~=0 then g.Volume=0 end
   g:SetAttribute("BBYALocalAudible",open)
   g:SetAttribute("BBYAAudioRouterVenue",currentVenue)
   g:SetAttribute("BBYAActiveTrimDb",open and trim or -80)
  end
 end
 player:SetAttribute("BBYAAudioVenue",currentVenue)
 player:SetAttribute("BBYAAudioRoom",currentRoom or "NONE")
 player:SetAttribute("BBYAMainTrimDb",currentVenue=="MAIN" and mainTrim or -80)
 player:SetAttribute("BBYAAudioFailClosed",currentVenue=="NONE")
end

local function bindMute()
 local b=resolveMuteButton()
 if b and not b:GetAttribute("BBYAAudioMuteGuardV6") then
  b:SetAttribute("BBYAAudioMuteGuardV6",true)
  b:GetPropertyChangedSignal("Text"):Connect(function()task.defer(enforce)end)
 end
end

SoundService.ChildAdded:Connect(function(child)
 if child:IsA("SoundGroup") then task.defer(function()forceNeutralVolumes();enforce()end) end
end)
pg.ChildAdded:Connect(function()task.defer(function()bindMute();forceNeutralVolumes();enforce()end)end)
player.CharacterAdded:Connect(function()
 task.defer(function()forceNeutralVolumes();enforce()end)
 task.delay(.35,enforce)
end)
player:GetAttributeChangedSignal("BBYAMusicMuted"):Connect(function()task.defer(enforce)end)

-- Heartbeat runs after RenderStepped. Keep the neutral-zone volume guard every frame so
-- older client mixers cannot reopen MAIN between slower router passes during first join.
local acc=0
RunService.Heartbeat:Connect(function(dt)
 forceNeutralVolumes()
 acc+=dt
 if acc<.10 then return end
 acc=0
 bindMute()
 enforce()
end)

task.defer(function()bindMute();forceNeutralVolumes();enforce()end)
print("[BBYA] Strict venue audio router v6: fail-closed startup/spawn/Mall; six-venue isolation preserved")
