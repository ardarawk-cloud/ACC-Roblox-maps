-- BBYA SOCIAL HUB — STRICT VENUE AUDIO ROUTER v1
-- Each music channel is audible only inside its own physical venue.
-- MAIN / UNDERGROUND / FUNKOT are active now. SKATEPARK / ROOFTOP are pre-routed for future playlists.

local Players=game:GetService("Players")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local GROUPS={
 MAIN={name="BBYAClubMaster",volume=.92},
 UNDERGROUND={name="BBYABasementMaster",volume=.94},
 FUNKOT={name="BBYAFunkotMaster",volume=.96},
 SKATEPARK={name="BBYASkateparkMaster",volume=.92},
 ROOFTOP={name="BBYARooftopMaster",volume=.88},
}

local cache={}
local guarding=false
local muteButton

local function resolveGroups()
 for key,spec in pairs(GROUPS) do
  local g=SoundService:FindFirstChild(spec.name)
  if g and g:IsA("SoundGroup") then cache[key]=g end
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
 -- Underground has first priority because it overlaps X/Z with Main vertically.
 if p.Y<-4.5 then return "UNDERGROUND" end
 -- Rooftop resort: physical roof footprint from R_Rooftop.
 if p.Y>=40 and p.Y<=60 and math.abs(p.X)<=62 and p.Z>=-48 and p.Z<=48 then return "ROOFTOP" end
 -- Funkot rear club footprint.
 if p.Y>-4 and p.Y<34 and math.abs(p.X)<61 and p.Z>157 and p.Z<253 then return "FUNKOT" end
 -- Rear skatepark physical slab / fence footprint.
 if p.Y>-4 and p.Y<20 and math.abs(p.X)<=61 and p.Z>=72 and p.Z<=152 then return "SKATEPARK" end
 -- Main Club only. Arrival/front hall/VIP/mall/corridors are intentionally silent from club feeds.
 if p.Y>-4 and p.Y<18 and math.abs(p.X)<=61 and p.Z>=0 and p.Z<70 then return "MAIN" end
 return "NONE"
end

local currentVenue="NONE"
local function currentPlayerVenue()
 local ch=player.Character
 local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 if not hrp then return "NONE" end
 return venueAtPosition(hrp.Position)
end

local function enforce()
 if guarding then return end
 guarding=true
 resolveGroups()
 currentVenue=currentPlayerVenue()
 local muted=locallyMuted()
 for key,spec in pairs(GROUPS) do
  local g=cache[key]
  if g and g.Parent then
   local target=(not muted and currentVenue==key) and spec.volume or 0
   if math.abs(g.Volume-target)>.005 then g.Volume=target end
   g:SetAttribute("BBYALocalAudible",target>0)
   g:SetAttribute("BBYAAudioRouterVenue",currentVenue)
  end
 end
 player:SetAttribute("BBYAAudioVenue",currentVenue)
 guarding=false
end

local function guardGroup(g)
 if not g or g:GetAttribute("BBYAStrictAudioGuardV1") then return end
 g:SetAttribute("BBYAStrictAudioGuardV1",true)
 g:GetPropertyChangedSignal("Volume"):Connect(function()if not guarding then task.defer(enforce) end end)
end

local function bindAll()
 resolveGroups()
 for _,g in pairs(cache) do guardGroup(g) end
 local b=resolveMuteButton()
 if b and not b:GetAttribute("BBYAAudioMuteGuardV1") then
  b:SetAttribute("BBYAAudioMuteGuardV1",true)
  b:GetPropertyChangedSignal("Text"):Connect(function()task.defer(enforce)end)
 end
 enforce()
end

SoundService.ChildAdded:Connect(function(child)
 if child:IsA("SoundGroup") then task.defer(bindAll) end
end)
pg.ChildAdded:Connect(function()task.defer(bindAll)end)
player.CharacterAdded:Connect(function()task.delay(.4,enforce)end)

local acc=0
RunService.Heartbeat:Connect(function(dt)
 acc+=dt
 if acc<.10 then return end
 acc=0
 enforce()
end)

task.defer(bindAll)
print("[BBYA] Strict venue audio router v1: MAIN / UNDERGROUND / FUNKOT isolated; SKATEPARK / ROOFTOP ready")
