-- BBYA SOCIAL HUB — STRICT VENUE AUDIO ROUTER v10 SINGLE AUTHORITY
-- Local EQ-gate isolation only. Never mutates SoundId, Sound.Volume, SoundGroup.Volume or PlaybackSpeed.
-- Mall footprint includes connector/plaza so Mall audio + UI venue state activate before the main entrance.

local Players=game:GetService("Players")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local GROUPS={MAIN="BBYAClubMaster",UNDERGROUND="BBYABasementMaster",VIP="BBYAVIPMaster",FUNKOT="BBYAFunkotMaster",SKATEPARK="BBYASkateparkMaster",ROOFTOP="BBYARooftopMaster",MALL="BBYAMallMaster",NIGHT_MARKET="BBYANightMarketMaster"}
local MAIN_TRIM={CORE=0,FORMER_STUDIO_LOUNGE=-3,RESTROOM=-7}
local cache,gates={},{}
local directFunkot=setmetatable({}, {__mode="k"})
local function inBox(p,x0,x1,y0,y1,z0,z1)return p.X>=x0 and p.X<=x1 and p.Y>=y0 and p.Y<=y1 and p.Z>=z0 and p.Z<=z1 end
local function setGate(g,open,gain)local v=open and(gain or 0)or-80;if g.LowGain~=v then g.LowGain=v end;if g.MidGain~=v then g.MidGain=v end;if g.HighGain~=v then g.HighGain=v end end
local function gateFor(key,group)
 local g=group:FindFirstChild("BBYAVenueGateV10")
 for _,n in ipairs({"BBYAVenueGateV9","BBYAVenueGateV8","BBYAVenueGateV7"})do local old=group:FindFirstChild(n);if old and old~=g then old:Destroy()end end
 if g and not g:IsA("EqualizerSoundEffect")then g:Destroy();g=nil end
 if not g then g=Instance.new("EqualizerSoundEffect");g.Name="BBYAVenueGateV10";g.Parent=group end
 g.Enabled=true;gates[key]=g;group:SetAttribute("BBYAAudioIsolationAuthority","ROUTER_V10_EQ_ONLY");return g
end
local function resolve()for k,n in pairs(GROUPS)do local g=SoundService:FindFirstChild(n);if g and g:IsA("SoundGroup")then cache[k]=g;gateFor(k,g)else cache[k]=nil;gates[k]=nil end end end
local function mainRoom(p)if inBox(p,-61,61,-4,18,0,70)then return"CORE"end;if inBox(p,-53,-25.5,-4,18,-36.5,7)then return"FORMER_STUDIO_LOUNGE"end;if inBox(p,34.5,51.5,-4,18,-32.5,-8.4)then return"RESTROOM"end end
local function venueAt(p)
 if p.Y<-4.5 then return"UNDERGROUND"end
 if p.Y>=55 and p.Y<=80 and math.abs(p.X)<=62 and p.Z>=-48 and p.Z<=48 then return"ROOFTOP"end
 if p.Y>=20 and p.Y<55 and math.abs(p.X)<=58 and p.Z>=-46 and p.Z<=46 then return"VIP"end
 if p.Y>-4 and p.Y<34 and math.abs(p.X)<61 and p.Z>157 and p.Z<253 then return"FUNKOT"end
 if p.Y>-4 and p.Y<20 and math.abs(p.X)<=61 and p.Z>=72 and p.Z<=152 then return"SKATEPARK"end
 -- Mall geometry: connector begins ~Z250; front plaza/entrance ~Z280; shell extends to ~Z443.
 if inBox(p,-108,108,-6,75,248,455)then return"MALL"end
 if p.Y>-4 and p.Y<34 and p.X>=-118 and p.X<=118 and p.Z>=465 and p.Z<=685 then return"NIGHT_MARKET"end
 local r=mainRoom(p);if r then return"MAIN",r end
 return"NONE"
end
local function localMuted()
 if player:GetAttribute("BBYAMusicMuted")==true then return true end
 local ui=pg:FindFirstChild("BBYAClubUI");if not ui then return false end
 for _,d in ipairs(ui:GetDescendants())do if d:IsA("TextButton")and string.upper(d.Text or"")=="UNMUTE LOCAL"then return true end end
 return false
end
local function funkotSound(s)local sg=s and s:IsA("Sound")and s.SoundGroup;return s and s:IsA("Sound")and((sg and sg.Name=="BBYAFunkotMaster")or string.sub(s.Name,1,10)=="BBYAFunkot")end
local function directGate(s)local g=directFunkot[s];if g and g.Parent==s then return g end;g=s:FindFirstChild("BBYAFunkotHardGateV10");if not g then g=Instance.new("EqualizerSoundEffect");g.Name="BBYAFunkotHardGateV10";g.Parent=s end;g.Enabled=true;directFunkot[s]=g;return g end
local function enforce()
 resolve();local ch=player.Character;local hrp=ch and ch:FindFirstChild("HumanoidRootPart");local v,room="NONE",nil;if hrp then v,room=venueAt(hrp.Position)end;local muted=localMuted();local trim=(v=="MAIN"and room and MAIN_TRIM[room])or 0
 for k,g in pairs(cache)do if g and g.Parent then local open=not muted and v==k;local gain=(k=="MAIN"and open)and trim or 0;setGate(gates[k]or gateFor(k,g),open,gain);g:SetAttribute("BBYALocalAudible",open);g:SetAttribute("BBYAAudioRouterVenue",v);g:SetAttribute("BBYAActiveTrimDb",open and gain or-80)end end
 for _,d in ipairs(SoundService:GetDescendants())do if funkotSound(d)then local open=not muted and v=="FUNKOT";setGate(directGate(d),open,0);d:SetAttribute("BBYALocalAudible",open)end end
 player:SetAttribute("BBYAAudioVenue",v);player:SetAttribute("BBYAAudioRoom",room or"NONE");player:SetAttribute("BBYAMainTrimDb",v=="MAIN"and trim or-80);player:SetAttribute("BBYAAudioRouterAuthority","ROUTER_V10_EQ_ONLY")
end
SoundService.DescendantAdded:Connect(function()task.defer(enforce)end);SoundService.ChildRemoved:Connect(function()task.defer(enforce)end);player.CharacterAdded:Connect(function()task.defer(enforce);task.delay(.2,enforce)end);player:GetAttributeChangedSignal("BBYAMusicMuted"):Connect(enforce)
local acc=0;RunService.Heartbeat:Connect(function(dt)acc+=dt;if acc>=.06 then acc=0;enforce()end end);task.defer(enforce)
print("[BBYA] Venue router v10 online: EQ-only / Mall connector-to-shell coverage / single authority")