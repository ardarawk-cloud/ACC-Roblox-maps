-- BBYA SOCIAL HUB — LEGACY AUDIO ROUTE COMPATIBILITY v8
-- Player-facing music UI ownership is retired from this legacy script.
-- The existing MAIN / UNDERGROUND / FUNKOT SoundGroup routing behavior is preserved
-- unchanged in purpose so the Premium Music Suite migration does not alter audio behavior.

local Players=game:GetService("Players")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local function rootPosition()
 local ch=player.Character
 local root=ch and ch:FindFirstChild("HumanoidRootPart")
 return root and root.Position or nil
end

local muteButton=nil
local function isLocallyMuted()
 if not muteButton or not muteButton.Parent then
  muteButton=nil
  local gui=pg:FindFirstChild("BBYAClubUI")
  if gui then
   for _,d in ipairs(gui:GetDescendants()) do
    if d:IsA("TextButton") and ((d.Text or "")=="MUTE LOCAL" or (d.Text or "")=="UNMUTE LOCAL") then
     muteButton=d
     break
    end
   end
  end
 end
 return muteButton and muteButton.Text=="UNMUTE LOCAL" or false
end

local function mainTarget(p)
 if p.Y>40 then return .34,"ROOFTOP" end
 if p.Y>18 then return .48,"VIP" end
 if p.Z<-45 then return .10,"ARRIVAL" end
 if p.Z<-18 then return .20,"FRONT HALL" end
 if p.Z<0 then return .36,"TRANSITION" end
 if math.abs(p.X)>28 then return .62,"BAR / VIP LOUNGE" end
 if p.Z>27 then return .92,"DJ / STAGE" end
 return .84,"MAIN CLUB"
end

local function routeTargets()
 local p=rootPosition()
 if not p then return .20,0,0,"MAIN" end
 if p.Y<-4.5 then return 0,.94,0,"UNDERGROUND" end
 if p.Y>-4 and p.Y<34 and math.abs(p.X)<61 and p.Z>157 and p.Z<253 then return 0,0,.96,"FUNKOT" end
 local m=mainTarget(p)
 return m,0,0,"MAIN"
end

local lastVenue=""
RunService.Heartbeat:Connect(function()
 local main,under,funkot,venue=routeTargets()
 if isLocallyMuted() then main,under,funkot=0,0,0 end
 local mg=SoundService:FindFirstChild("BBYAClubMaster")
 local ug=SoundService:FindFirstChild("BBYABasementMaster")
 local fg=SoundService:FindFirstChild("BBYAFunkotMaster")
 if mg and mg:IsA("SoundGroup") then mg.Volume=main end
 if ug and ug:IsA("SoundGroup") then ug.Volume=under end
 if fg and fg:IsA("SoundGroup") then fg.Volume=funkot end
 if venue~=lastVenue then
  lastVenue=venue
  if mg then mg:SetAttribute("ClientRouteV8",venue) end
  if ug then ug:SetAttribute("ClientRouteV8",venue) end
  if fg then fg:SetAttribute("ClientRouteV8",venue) end
 end
end)

player:SetAttribute("BBYALegacyMusicUIRetired",true)
print("[BBYA] Legacy audio route compatibility v8 online: UI writes retired / existing venue gain route preserved")
