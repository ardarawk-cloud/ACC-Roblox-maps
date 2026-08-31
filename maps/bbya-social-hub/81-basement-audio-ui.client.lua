-- BBYA SOCIAL HUB — LEGACY AUDIO ROUTE COMPATIBILITY v9 + MUSIC SUITE SAFETY
-- Legacy panel styling is retired. Router v9 is the sole client-side venue isolation authority.
-- This compatibility script MUST NOT write SoundGroup.Volume or Sound.Volume.

local Players=game:GetService("Players")
local SoundService=game:GetService("SoundService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

-- Compatibility telemetry only: mirror Router v9's resolved venue onto the legacy
-- route attributes without owning gain, mute state, playlists, or transport.
local lastVenue=""
local function mirrorRouterVenue()
 local venue=player:GetAttribute("BBYAAudioVenue") or "NONE"
 if venue==lastVenue then return end
 lastVenue=venue
 for _,name in ipairs({"BBYAClubMaster","BBYABasementMaster","BBYAFunkotMaster"}) do
  local g=SoundService:FindFirstChild(name)
  if g and g:IsA("SoundGroup") then
   g:SetAttribute("ClientRouteV8",venue)
   g:SetAttribute("BBYALegacyVolumeWriterDisabled",true)
  end
 end
 player:SetAttribute("BBYALegacyVolumeWriterDisabled",true)
end

player:GetAttributeChangedSignal("BBYAAudioVenue"):Connect(function()
 task.defer(mirrorRouterVenue)
end)
SoundService.ChildAdded:Connect(function(child)
 if child:IsA("SoundGroup") then task.defer(mirrorRouterVenue) end
end)
task.defer(mirrorRouterVenue)

-- MUSIC SUITE SAFETY ----------------------------------------------------------
-- This section does not touch audio. It only prevents old/new music panels from overlapping.
local boundButtons=setmetatable({},{__mode="k"})
local boundClose=setmetatable({},{__mode="k"})
local boundHub=setmetatable({},{__mode="k"})

local function suiteSafety()
 local suite=pg:FindFirstChild("BBYAMusicSuiteV1")
 local clubUI=pg:FindFirstChild("BBYAClubUI")
 if not suite or not clubUI then return end
 local hub=clubUI:FindFirstChild("HubPanel")

 local compact=clubUI:FindFirstChild("BBYACompactMusicLayerV7")
 if compact then compact:Destroy() end
 local livePill=suite:FindFirstChild("LivePillV3",true)
 if livePill then livePill:Destroy() end

 local close=suite:FindFirstChild("Close",true)
 if close and close:IsA("GuiButton") and not boundClose[close] then
  boundClose[close]=true
  close.Activated:Connect(function()
   task.defer(function()
    suite.Enabled=false
    -- Full-close contract: do not resurrect the retired HubPanel/music shell.
    if hub then hub.Visible=false end
   end)
  end
 end

 if hub and not boundHub[hub] then
  boundHub[hub]=true
  hub:GetPropertyChangedSignal("Visible"):Connect(function()
   if hub.Visible and suite.Enabled then suite.Enabled=false end
  end)
 end

 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 local drawer=menu and menu:FindFirstChild("FeatureDrawer")
 if drawer then
  for _,slot in ipairs(drawer:GetDescendants()) do
   if slot:IsA("GuiObject") and slot.Name:match("^Slot_") and slot.Name~="Slot_MUSIC" then
    for _,b in ipairs(slot:GetChildren()) do
     if b:IsA("TextButton") and not boundButtons[b] then
      boundButtons[b]=true
      b.Activated:Connect(function()
       task.defer(function()if suite.Enabled then suite.Enabled=false end end)
      end)
     end
    end
   end
  end
 end
end

pg.ChildAdded:Connect(function()task.defer(suiteSafety)end)
for i=0,12 do task.delay(i*.35,suiteSafety) end
player:SetAttribute("BBYALegacyMusicUIRetired",true)
player:SetAttribute("BBYAMusicSuiteMainSafety","V1")

print("[BBYA] Legacy route compatibility v9 + Music Suite safety online: Router v9 owns isolation / legacy volume writer disabled")
