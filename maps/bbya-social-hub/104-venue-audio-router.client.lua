-- BBYA SOCIAL HUB — STRICT VENUE AUDIO ROUTER v9.4
-- Deterministic local venue isolation using EQ gates only.
-- Mall gate now opens from the connector/entrance (Z278) through the full Mall footprint.
-- This router never mutates SoundGroup.Volume, Sound.Volume or SoundId.

local Players=game:GetService("Players")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local GROUPS={MAIN={name="BBYAClubMaster"},UNDERGROUND={name="BBYABasementMaster"},VIP={name="BBYAVIPMaster"},FUNKOT={name="BBYAFunkotMaster"},SKATEPARK={name="BBYASkateparkMaster"},ROOFTOP={name="BBYARooftopMaster"},MALL={name="BBYAMallMaster"},NIGHT_MARKET={name="BBYANightMarketMaster"}}
local MAIN_TRIM={CORE=0,FORMER_STUDIO_LOUNGE=-3.0,RESTROOM=-7.0}
local cache,gates={},{};local directFunkotGates=setmetatable({}, {__mode="k"});local muteButton
local function setGate(gate,open,gainDb)local gain=open and(gainDb or 0)or-80;if gate.LowGain~=gain then gate.LowGain=gain end;if gate.MidGain~=gain then gate.MidGain=gain end;if gate.HighGain~=gain then gate.HighGain=gain end end
local function ensureGate(key,g)local gate=g:FindFirstChild("BBYAVenueGateV9")or g:FindFirstChild("BBYAVenueGateV8")or g:FindFirstChild("BBYAVenueGateV7");if gate and not gate:IsA("EqualizerSoundEffect")then gate:Destroy();gate=nil end;if not gate then gate=Instance.new("EqualizerSoundEffect");gate.Parent=g end;gate.Name="BBYAVenueGateV9";gate.Enabled=true;gates[key]=gate;g:SetAttribute("BBYAAudioIsolationAuthority","ROUTER_V9_4_EQ_ONLY");return gate end
local function resolveGroups()for key,spec in pairs(GROUPS)do local g=SoundService:FindFirstChild(spec.name);if g and g:IsA("SoundGroup")then cache[key]=g;ensureGate(key,g)else cache[key]=nil;gates[key]=nil end end end
local function resolveMuteButton()if muteButton and muteButton.Parent then return muteButton end;local ui=pg:FindFirstChild("BBYAClubUI");if not ui then return nil end;for _,d in ipairs(ui:GetDescendants())do if d:IsA("TextButton")then local up=string.upper(d.Text or"");if up=="MUTE LOCAL"or up=="UNMUTE LOCAL"then muteButton=d;return d end end end end
local function locallyMuted()if player:GetAttribute("BBYAMusicMuted")==true then return true end;local b=resolveMuteButton();return b and string.upper(b.Text or"")=="UNMUTE LOCAL"or false end
local function inBox(p,x0,x1,y0,y1,z0,z1)return p.X>=x0 and p.X<=x1 and p.Y>=y0 and p.Y<=y1 and p.Z>=z0 and p.Z<=z1 end
local function mainRoomAtPosition(p)if inBox(p,-61,61,-4,18,0,70)then return"CORE"end;if inBox(p,-53,-25.5,-4,18,-36.5,7)then return"FORMER_STUDIO_LOUNGE"end;if inBox(p,34.5,51.5,-4,18,-32.5,-8.4)then return"RESTROOM"end end
local function venueAtPosition(p)
 if p.Y<-4.5 then return"UNDERGROUND",nil end
 if p.Y>=55 and p.Y<=80 and math.abs(p.X)<=62 and p.Z>=-48 and p.Z<=48 then return"ROOFTOP",nil end
 if p.Y>=20 and p.Y<55 and math.abs(p.X)<=58 and p.Z>=-46 and p.Z<=46 then return"VIP",nil end
 if p.Y>-4 and p.Y<34 and math.abs(p.X)<61 and p.Z>157 and p.Z<253 then return"FUNKOT",nil end
 if p.Y>-4 and p.Y<20 and math.abs(p.X)<=61 and p.Z>=72 and p.Z<=152 then return"SKATEPARK",nil end
 if p.Y>=-4 and p.Y<=70 and p.X>=-96 and p.X<=96 and p.Z>=278 and p.Z<=443 then return"MALL",nil end
 if p.Y>-4 and p.Y<34 and p.X>=-118 and p.X<=118 and p.Z>=465 and p.Z<=685 then return"NIGHT_MARKET",nil end
 local room=mainRoomAtPosition(p);if room then return"MAIN",room end;return"NONE",nil
end
local function context()local ch=player.Character;local hrp=ch and ch:FindFirstChild("HumanoidRootPart");if not hrp then return"NONE",nil,0 end;local venue,room=venueAtPosition(hrp.Position);local trim=(venue=="MAIN"and room and MAIN_TRIM[room])or 0;return venue,room,trim end
local function isFunkotSound(s)if not(s and s:IsA("Sound"))then return false end;local sg=s.SoundGroup;return(sg and sg.Name=="BBYAFunkotMaster")or string.sub(s.Name,1,10)=="BBYAFunkot"end
local function ensureDirectFunkotGate(sound)local gate=directFunkotGates[sound];if gate and gate.Parent==sound then return gate end;gate=sound:FindFirstChild("BBYAFunkotHardGateV9");if gate and not gate:IsA("EqualizerSoundEffect")then gate:Destroy();gate=nil end;if not gate then gate=Instance.new("EqualizerSoundEffect");gate.Name="BBYAFunkotHardGateV9";gate.Parent=sound end;gate.Enabled=true;directFunkotGates[sound]=gate;return gate end
local function enforceDirectFunkot(open)for _,d in ipairs(SoundService:GetDescendants())do if d:IsA("Sound")and isFunkotSound(d)then setGate(ensureDirectFunkotGate(d),open,0);d:SetAttribute("BBYALocalAudible",open)end end end
local function enforce()
 resolveGroups();local currentVenue,currentRoom,mainTrim=context();local muted=locallyMuted()
 for key,g in pairs(cache)do if g and g.Parent then local open=not muted and currentVenue==key;local trim=(key=="MAIN"and open)and mainTrim or 0;local gate=gates[key]or ensureGate(key,g);setGate(gate,open,trim);g:SetAttribute("BBYALocalAudible",open);g:SetAttribute("BBYAAudioRouterVenue",currentVenue);g:SetAttribute("BBYAActiveTrimDb",open and trim or-80)end end
 enforceDirectFunkot(not muted and currentVenue=="FUNKOT");player:SetAttribute("BBYAAudioVenue",currentVenue);player:SetAttribute("BBYAAudioRoom",currentRoom or"NONE");player:SetAttribute("BBYAMainTrimDb",currentVenue=="MAIN"and mainTrim or-80);player:SetAttribute("BBYAAudioRouterAuthority","ROUTER_V9_4_EQ_ONLY")
end
SoundService.ChildAdded:Connect(function()task.defer(enforce)end);SoundService.DescendantAdded:Connect(function(child)if child:IsA("Sound")and isFunkotSound(child)then setGate(ensureDirectFunkotGate(child),false,0)end;task.defer(enforce)end);SoundService.ChildRemoved:Connect(function()task.defer(enforce)end);pg.ChildAdded:Connect(function()task.defer(enforce)end);player.CharacterAdded:Connect(function()task.defer(enforce);task.delay(.15,enforce);task.delay(.4,enforce)end);player:GetAttributeChangedSignal("BBYAMusicMuted"):Connect(function()task.defer(enforce)end)
local acc=0;RunService.Heartbeat:Connect(function(dt)acc+=dt;if acc<.05 then return end;acc=0;enforce()end);task.defer(enforce)
print("[BBYA] Strict venue audio router v9.4: Mall audible from connector Z278 through Mall Z443; other venue bounds preserved")