-- BBYA SOCIAL HUB — ACTUAL NOW PLAYING TITLE v1
-- Always show the audio title that is truly audible in the player's current venue.
-- Recovery/fallback titles override stale playlist state so bad tracks can be identified by name.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local gui=pg:WaitForChild("BBYAClubUI",30)
if not gui then return end
local panel=gui:WaitForChild("HubPanel",30)
if not panel then return end
local playerCard=panel:FindFirstChild("PlayerCard",true)
if not playerCard then return end

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local stateRemote=remotes:WaitForChild("State",30)
local funkotRemote=remotes:WaitForChild("FunkotMusic",30)

local nowTitle
for _,d in ipairs(playerCard:GetChildren()) do
 if d:IsA("TextLabel") and d.TextSize>=13 and string.upper(d.Text or "")~="NOW PLAYING" then
  nowTitle=d;break
 end
end
if not nowTitle then return end

local sourceBadge=playerCard:FindFirstChild("ActualSourceBadgeV1") or Instance.new("TextLabel")
sourceBadge.Name="ActualSourceBadgeV1"
sourceBadge.BackgroundTransparency=1
sourceBadge.Text=""
sourceBadge.TextColor3=Color3.fromRGB(151,155,168)
sourceBadge.Font=Enum.Font.GothamBold
sourceBadge.TextSize=8
sourceBadge.TextXAlignment=Enum.TextXAlignment.Left
sourceBadge.ZIndex=130
sourceBadge.Parent=playerCard

local cached={
 MAIN={title="",playing=false},
 UNDERGROUND={title="",playing=false},
 FUNKOT={title="",playing=false},
}

local function venue()
 local v=tostring(player:GetAttribute("BBYAAudioVenue") or "NONE")
 if v=="BASEMENT" then v="UNDERGROUND" end
 return v
end

stateRemote.OnClientEvent:Connect(function(kind,data)
 if kind~="music" or type(data)~="table" then return end
 local v=tostring(data.venue or "MAIN")
 if v=="BASEMENT" then v="UNDERGROUND" else v="MAIN" end
 cached[v].title=tostring(data.title or "")
 cached[v].playing=data.playing==true
end)

funkotRemote.OnClientEvent:Connect(function(kind,data)
 if kind~="state" or type(data)~="table" then return end
 cached.FUNKOT.title=tostring(data.title or "")
 cached.FUNKOT.playing=data.playing==true
end)

local function groupFor(v)
 if v=="MAIN" then return SoundService:FindFirstChild("BBYAClubMaster") end
 if v=="UNDERGROUND" then return SoundService:FindFirstChild("BBYABasementMaster") end
 if v=="FUNKOT" then return SoundService:FindFirstChild("BBYAFunkotMaster") end
 if v=="SKATEPARK" then return SoundService:FindFirstChild("BBYASkateparkMaster") end
 if v=="ROOFTOP" then return SoundService:FindFirstChild("BBYARooftopMaster") end
end

local function actual(v)
 local g=groupFor(v)
 if v=="MAIN" or v=="UNDERGROUND" then
  if g and g:GetAttribute("RecoveryActive")==true then
   local title=tostring(g:GetAttribute("RecoveryTrack") or "")
   local id=tostring(g:GetAttribute("RecoveryTrackId") or "")
   if title~="" then return title,"RECOVERY"..(id~="" and " • ID "..id or "") end
  end
  local c=cached[v]
  if c and c.title~="" then return c.title,"PLAYLIST" end
 elseif v=="FUNKOT" then
  local title=g and tostring(g:GetAttribute("CurrentTitle") or "") or ""
  if title=="" then title=cached.FUNKOT.title end
  if title~="" then return title,"PLAYLIST" end
 elseif v=="SKATEPARK" or v=="ROOFTOP" then
  local title=g and tostring(g:GetAttribute("CurrentTitle") or "") or ""
  if title~="" then return title,"PLAYLIST" end
  return "No track loaded","LOCAL CHANNEL"
 end
 return "No local music","SILENT ZONE"
end

local function sync()
 local v=venue()
 local title,source=actual(v)
 nowTitle.Text=title
 sourceBadge.Text=source
 sourceBadge.Position=UDim2.fromOffset(14,73)
 sourceBadge.Size=UDim2.new(1,-220,0,15)
 local home=panel:FindFirstChild("BBYAHomeV6",true)
 local song=home and home:FindFirstChild("Song",true)
 if song and song:IsA("TextLabel") then song.Text="NOW PLAYING  "..title end
end

player:GetAttributeChangedSignal("BBYAAudioVenue"):Connect(function()task.defer(sync)end)
for _,name in ipairs({"BBYAClubMaster","BBYABasementMaster","BBYAFunkotMaster","BBYASkateparkMaster","BBYARooftopMaster"}) do
 local g=SoundService:FindFirstChild(name)
 if g then
  for _,attr in ipairs({"RecoveryActive","RecoveryTrack","RecoveryTrackId","CurrentTitle"}) do
   g:GetAttributeChangedSignal(attr):Connect(function()task.defer(sync)end)
  end
 end
end
SoundService.ChildAdded:Connect(function()task.defer(sync)end)

task.spawn(function()
 while task.wait(.25) do sync() end
end)

task.defer(sync)
print("[BBYA] Actual now-playing title v1: audible track name + recovery source visible")
