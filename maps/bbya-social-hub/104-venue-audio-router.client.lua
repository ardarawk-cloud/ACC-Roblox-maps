-- BBYA SOCIAL HUB — STRICT VENUE AUDIO ROUTER v7
-- Each music channel is audible only inside its own physical venue.
-- v7 preserves v6 fail-closed neutral/startup behavior while restoring the
-- canonical Skatepark and Rooftop master volumes when their local gates open.
-- Funkot remains owned by its dedicated zone client and is intentionally untouched.
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

-- v6 could leave these two groups at zero after spawn/neutral because only the EQ
-- gate was reopened on venue entry. Restore only the two affected authorities.
local RESTORE_VOLUMES={
 SKATEPARK=1.0,
 ROOFTOP=.86,
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
 local gate=g:FindFirstChild("BBYAVenueGateV7") or g:FindFirstChild("BBYAVenueGateV6") or g:FindFirstChild("BBYAVenueGateV5") or g:FindFirstChild("BBYAVenueGateV4") or g:FindFirstChild("BBYAVenueGateV3") or g:FindFirstChild("BBYAVenueGateV2")
 if gate and not gate:IsA("EqualizerSoundEffect") then gate:Destroy();gate=nil end
 if not gate then
  gate=Instance.new("EqualizerSoundEffect")
  gate.Name="BBYAVenueGateV7"
  gate.Parent=g
 else
  gate.Name="BBYAVenueGateV7"
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
 if inBox(p,-61,61,-4,18,0,70) then return "CORE" end
 if inBox(p,-53,-25.5,-4,18,-36.5,7) then return "FORMER_STUDIO_LOUNGE" end
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

   -- Keep v6's hard fail-closed neutral behavior, but repair the missing return path:
   -- Skatepark/Rooftop regain their canonical local master volume when their own
   -- gate is open. Funkot is deliberately excluded because 92-funkot-zone owns it.
   if currentVenue=="NONE" then
    if g.Volume~=0 then g.Volume=0 end
   elseif open then
    local restore=RESTORE_VOLUMES[key]
    if restore and g.Volume~=restore then g.Volume=restore end
   end

   g:SetAttribute("BBYALocalAudible",open)
   g:SetAttribute("BBYAAudioRouterVenue",currentVenue)
   g:SetAttribute("BBYAActiveTrimDb",open and trim or -80)
   if RESTORE_VOLUMES[key] then
    g:SetAttribute("BBYAVolumeRestoreAuthority","ROUTER_V7")
   end
  end
 end
 player:SetAttribute("BBYAAudioVenue",currentVenue)
 player:SetAttribute("BBYAAudioRoom",currentRoom or "NONE")
 player:SetAttribute("BBYAMainTrimDb",currentVenue=="MAIN" and mainTrim or -80)
 player:SetAttribute("BBYAAudioFailClosed",currentVenue=="NONE")
end

local function bindMute()
 local b=resolveMuteButton()
 if b and not b:GetAttribute("BBYAAudioMuteGuardV7") then
  b:SetAttribute("BBYAAudioMuteGuardV7",true)
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
print("[BBYA] Strict venue audio router v7: neutral fail-closed preserved; Skatepark/Rooftop local master-volume restore active")
