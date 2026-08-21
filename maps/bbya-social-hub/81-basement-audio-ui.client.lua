-- BBYA SOCIAL HUB — BASEMENT AUDIO/UI PROFILE v3
-- Gives the underground room its own panel identity and local acoustic processing.

local Players=game:GetService("Players")
local SoundService=game:GetService("SoundService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local underground=false

local function musicGroup()
 return SoundService:FindFirstChild("BBYAClubMaster")
end

local function applyAudio(on)
 local group=musicGroup()
 if not group or not group:IsA("SoundGroup") then return end
 local eq=group:FindFirstChild("ClubEQ")
 if eq and eq:IsA("EqualizerSoundEffect") then
  if on then
   eq.LowGain=2.35;eq.MidGain=-1.15;eq.HighGain=-3.2
  else
   eq.LowGain=1.15;eq.MidGain=-.15;eq.HighGain=.45
  end
 end
 local room=group:FindFirstChild("BasementRoom")
 if not room then room=Instance.new("ReverbSoundEffect");room.Name="BasementRoom";room.Parent=group end
 if room:IsA("ReverbSoundEffect") then
  room.DecayTime=1.25;room.Density=.82;room.Diffusion=.88;room.DryLevel=-1.5;room.WetLevel=-10
  room.Enabled=on
 end
 group.Volume=on and .94 or 1
end

local function patchPanel(on)
 local gui=pg:FindFirstChild("BBYAClubUI")
 if not gui then return end
 local dock=gui:FindFirstChild("TopDock")
 if dock then
  for _,obj in ipairs(dock:GetChildren()) do
   if obj:IsA("TextButton") then
    local up=string.upper(obj.Text or "")
    if up:find("MUSIC",1,true) or up=="UNDERGROUND" then
     obj.Text=on and "UNDERGROUND" or "♫  MUSIC"
     obj.BackgroundColor3=on and Color3.fromRGB(22,48,74) or Color3.fromRGB(15,14,19)
    end
   end
  end
 end
 local panel=gui:FindFirstChild("HubPanel")
 if panel then
  panel.BackgroundColor3=on and Color3.fromRGB(7,12,18) or Color3.fromRGB(9,9,12)
  for _,obj in ipairs(panel:GetDescendants()) do
   if obj:IsA("TextLabel") then
    local txt=string.upper(obj.Text or "")
    if txt=="MUSIC SYSTEM" or txt=="UNDERGROUND MUSIC" then
     obj.Text=on and "UNDERGROUND MUSIC" or "MUSIC SYSTEM"
     obj.TextColor3=on and Color3.fromRGB(245,245,238) or Color3.fromRGB(244,243,247)
    elseif txt:find("SYNCED CLUB FEED",1,true) or txt:find("BASS%-FOCUSED") then
     obj.Text=on and "Bass-focused basement feed • acoustic room profile" or "Synced club feed • request queue • local zone balance"
    end
   elseif obj:IsA("UIStroke") and obj.Parent==panel then
    obj.Color=on and Color3.fromRGB(0,144,255) or Color3.fromRGB(247,55,158)
   end
  end
 end
end

local function currentUnderground()
 local ch=player.Character
 local root=ch and ch:FindFirstChild("HumanoidRootPart")
 return root and root.Position.Y<-4.5 or false
end

local function apply(on)
 underground=on
 applyAudio(on)
 patchPanel(on)
end

player.CharacterAdded:Connect(function()
 task.wait(1);apply(currentUnderground())
end)
pg.ChildAdded:Connect(function()task.delay(.3,function()patchPanel(underground)end)end)

task.spawn(function()
 while task.wait(.45) do
  local now=currentUnderground()
  if now~=underground then apply(now) end
 end
end)

print("[BBYA] Basement local audio/UI profile v3 online")
