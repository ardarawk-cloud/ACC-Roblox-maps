-- BBYA SOCIAL HUB — FUNKOT CLUB AUDIO ZONE v1
local Players=game:GetService("Players")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local inside=false
local mainGroup,underGroup,funkotGroup

local function groups()
 mainGroup=SoundService:FindFirstChild("BBYAClubMaster") or mainGroup
 underGroup=SoundService:FindFirstChild("BBYABasementMaster") or underGroup
 funkotGroup=SoundService:FindFirstChild("BBYAFunkotMaster") or funkotGroup
end
local function inFunkot()
 local ch=player.Character
 local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 if not hrp then return false end
 local p=hrp.Position
 return p.Y>-4 and p.Y<34 and math.abs(p.X)<61 and p.Z>157 and p.Z<253
end
local guarding=false
local function enforce()
 if guarding then return end
 guarding=true
 groups();inside=inFunkot()
 if funkotGroup then funkotGroup.Volume=inside and .96 or 0 end
 if inside then
  if mainGroup then mainGroup.Volume=0 end
  if underGroup then underGroup.Volume=0 end
 end
 guarding=false
end

task.spawn(function()
 while task.wait(.15) do enforce() end
end)
SoundService.ChildAdded:Connect(function()task.defer(enforce)end)
RunService.Heartbeat:Connect(function()if inside then enforce()end end)

print("[BBYA] Funkot audio zone v1 online: isolated rear club feed")
