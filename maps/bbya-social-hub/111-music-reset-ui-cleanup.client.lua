-- BBYA SOCIAL HUB — MUSIC RESET UI CLEANUP v1
-- Final cleanup authority for the owner-requested empty catalog state.
-- Removes stale legacy playlist rows/header, hides unusable transport controls,
-- keeps the admin EDIT toggle visible but outside the music panel, and applies
-- restrained transparency so gameplay/avatar remain visible behind hub panels.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local gui=pg:WaitForChild("BBYAClubUI",30)
if not gui then return end
local panel=gui:WaitForChild("HubPanel",30)
if not panel then return end

local function catalogResetActive()
 return ReplicatedStorage:GetAttribute("BBYAMusicCatalogReset")==true
end

local VENUE_NAME={
 MAIN="CLUB",UNDERGROUND="UNDERGROUND",VIP="VIP",FUNKOT="FUNKOT",
 SKATEPARK="SKATEPARK",ROOFTOP="ROOFTOP",NONE="MUSIC",
}

local function currentVenue()
 return tostring(player:GetAttribute("BBYAAudioVenue") or "NONE")
end

local function findCore()
 local playerCard=panel:FindFirstChild("PlayerCard",true)
 local libraryCard=panel:FindFirstChild("LibraryCard",true)
 return playerCard,libraryCard
end

local function hideTransport(root)
 if not root then return end
 for _,d in ipairs(root:GetDescendants()) do
  if d:IsA("TextButton") then
   local up=string.upper((d.Text or ""):gsub("^%s+"," "):gsub("%s+$",""))
   if up=="NEXT" or up=="PREV" or up=="PREVIOUS" or up=="PAUSE" or up=="RESUME" then
    d.Visible=false
    d.Active=false
    d.AutoButtonColor=false
   end
  end
 end
end

local function cleanLibrary(libraryCard)
 if not libraryCard then return end
 local empty=libraryCard:FindFirstChild("MusicCatalogEmptyV1")
 if not empty then return end
 -- The reset card is the single source of truth while all venue catalogs are empty.
 for _,child in ipairs(libraryCard:GetChildren()) do
  if child~=empty and not child:IsA("UICorner") and not child:IsA("UIStroke") then
   if child:IsA("GuiObject") then child.Visible=false end
  end
 end
 for _,d in ipairs(libraryCard:GetDescendants()) do
  if not d:IsDescendantOf(empty) and d:IsA("GuiObject") and d~=empty then
   d.Visible=false
  end
 end
 empty.Visible=true
 empty.Position=UDim2.fromOffset(12,12)
 empty.Size=UDim2.new(1,-24,1,-24)
 empty.ZIndex=180
 for _,d in ipairs(empty:GetDescendants()) do
  if d:IsA("GuiObject") then d.ZIndex=math.max(d.ZIndex,181) end
 end
end

local function cleanPlayerCard(playerCard)
 if not playerCard then return end
 hideTransport(playerCard)
 local venue=VENUE_NAME[currentVenue()] or currentVenue()
 for _,d in ipairs(playerCard:GetDescendants()) do
  if d:IsA("TextLabel") then
   local up=string.upper(d.Text or "")
   if up:find("PROGRESSIVE",1,true) or up:find("BREAKBEAT",1,true) or up:find("INDO",1,true) or up:find("FUNKOT_ONLY",1,true) then
    d.Text=venue.." • 0 TRACKS"
   end
  end
 end
end

local function applyTransparency()
 -- Hub panel only: retain text/button readability while allowing the avatar/world through.
 for _,d in ipairs(panel:GetDescendants()) do
  if d:IsA("Frame") then
   if d.BackgroundTransparency<.28 then d.BackgroundTransparency=.28 end
  elseif d:IsA("ScrollingFrame") then
   if d.BackgroundTransparency<.32 then d.BackgroundTransparency=.32 end
  elseif d:IsA("TextButton") then
   if d.BackgroundTransparency<.16 then d.BackgroundTransparency=.16 end
  end
 end
 if panel:IsA("Frame") and panel.BackgroundTransparency<.24 then panel.BackgroundTransparency=.24 end
end

local function placeEditorToggle()
 local editor=pg:FindFirstChild("BBYAEditorUI")
 local b=editor and editor:FindFirstChild("EditorToggle",true)
 if not b or not b:IsA("GuiObject") then return end
 b.AnchorPoint=Vector2.new(0,1)
 b.Position=UDim2.new(0,16,1,-16)
 b.Size=UDim2.fromOffset(60,38)
 b.ZIndex=900
end

local function enforce()
 if not catalogResetActive() then return end
 local playerCard,libraryCard=findCore()
 cleanLibrary(libraryCard)
 cleanPlayerCard(playerCard)
 applyTransparency()
 placeEditorToggle()
 panel:SetAttribute("BBYAMusicResetUIClean",true)
 panel:SetAttribute("BBYALegacyPlaylistHidden",true)
end

panel.DescendantAdded:Connect(function()task.defer(enforce)end)
pg.ChildAdded:Connect(function()task.defer(enforce)end)
player:GetAttributeChangedSignal("BBYAAudioVenue"):Connect(function()task.defer(enforce)end)
ReplicatedStorage:GetAttributeChangedSignal("BBYAMusicCatalogReset"):Connect(function()task.defer(enforce)end)

local acc=0
RunService.Heartbeat:Connect(function(dt)
 acc+=dt
 if acc<.15 then return end
 acc=0
 enforce()
end)

task.delay(1,enforce)
print("[BBYA] Music Reset UI Cleanup v1: legacy playlist ghosts removed / transport hidden / editor moved / hub translucent")
