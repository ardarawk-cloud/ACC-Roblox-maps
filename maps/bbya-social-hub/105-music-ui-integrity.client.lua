-- BBYA SOCIAL HUB — MUSIC UI INTEGRITY v1
-- Final correctness guard for Music UI v6:
-- 1) only the active venue playlist is visible,
-- 2) PREVIOUS means the actually previous played track (not index-1 in a shuffled playlist),
-- 3) future Skatepark/Rooftop zones never accidentally control/request Main Club music.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local gui=pg:WaitForChild("BBYAClubUI",30)
if not gui then return end
local panel=gui:WaitForChild("HubPanel",30)
if not panel then return end
local library=panel:FindFirstChild("LibraryCard",true)
local playerCard=panel:FindFirstChild("PlayerCard",true)
if not library or not playerCard then return end

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local musicRemote=remotes:WaitForChild("Music",30)
local stateRemote=remotes:WaitForChild("State",30)
local funkotRemote=remotes:WaitForChild("FunkotMusic",30)

local function isAdmin()
 return player:GetAttribute("BBYAAdmin")==true or (game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId)
end
local function venue()
 local v=tostring(player:GetAttribute("BBYAAudioVenue") or "NONE")
 if v=="BASEMENT" then return "UNDERGROUND" end
 return v
end
local function supported(v)return v=="MAIN" or v=="UNDERGROUND" or v=="FUNKOT" end

local history={MAIN={},UNDERGROUND={},FUNKOT={}}
local current={MAIN=0,UNDERGROUND=0,FUNKOT=0}
local function note(v,index)
 index=tonumber(index) or 0
 if not history[v] or index<=0 then return end
 local old=current[v]
 if old>0 and old~=index then
  local h=history[v]
  if h[#h]~=old then table.insert(h,old) end
  while #h>12 do table.remove(h,1) end
 end
 current[v]=index
end
stateRemote.OnClientEvent:Connect(function(kind,data)
 if kind=="music" and type(data)=="table" then
  local v=tostring(data.venue or "MAIN");if v=="BASEMENT" then v="UNDERGROUND" else v="MAIN" end
  note(v,data.index)
 end
end)
funkotRemote.OnClientEvent:Connect(function(kind,data)if kind=="state" and type(data)=="table" then note("FUNKOT",data.index) end end)

local oldPrev=playerCard:FindFirstChild("AdminPreviousV6")
local nextButton=playerCard:FindFirstChild("AdminNextV6")
local prev=Instance.new("TextButton")
prev.Name="AdminPreviousHistoryV6";prev.Text="PREV";prev.BackgroundColor3=Color3.fromRGB(32,33,42);prev.BorderSizePixel=0
prev.TextColor3=Color3.fromRGB(246,246,249);prev.Font=Enum.Font.GothamBold;prev.TextSize=9;prev.ZIndex=110;prev.Parent=playerCard
local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,8);c.Parent=prev
local s=Instance.new("UIStroke");s.Color=Color3.fromRGB(39,196,225);s.Transparency=.55;s.Parent=prev
if oldPrev then oldPrev.Visible=false end

local empty=library:FindFirstChild("NoLocalChannelV6") or Instance.new("TextLabel")
empty.Name="NoLocalChannelV6";empty.AnchorPoint=Vector2.new(.5,.5);empty.Position=UDim2.fromScale(.5,.56);empty.Size=UDim2.new(1,-32,0,70)
empty.BackgroundTransparency=1;empty.TextColor3=Color3.fromRGB(151,155,168);empty.Font=Enum.Font.GothamMedium;empty.TextSize=11;empty.TextWrapped=true;empty.TextXAlignment=Enum.TextXAlignment.Center;empty.ZIndex=120;empty.Parent=library

local function syncPlaylist()
 local v=venue()
 for _,d in ipairs(library:GetDescendants()) do
  if d:IsA("ScrollingFrame") then
   local funk=d.Name=="FunkotPlaylistV4"
   local show=(v=="FUNKOT" and funk) or ((v=="MAIN" or v=="UNDERGROUND") and not funk)
   d.Visible=show;d.Active=show;d.ScrollingEnabled=show
   if show then d.Position=UDim2.fromOffset(12,38);d.Size=UDim2.new(1,-24,1,-46) end
  elseif d:IsA("TextButton") and string.upper(d.Text or "")=="REQUEST" then
   d.Visible=supported(v);d.Active=supported(v)
  end
 end
 if v=="SKATEPARK" then empty.Text="SKATEPARK AUDIO • INDEPENDENT CHANNEL READY\nPlaylist will be separate from every other venue."
 elseif v=="ROOFTOP" then empty.Text="ROOFTOP AUDIO • INDEPENDENT CHANNEL READY\nPlaylist will be separate from every other venue."
 elseif v=="NONE" then empty.Text="NO LOCAL MUSIC ZONE\nVenue music is intentionally isolated."
 else empty.Text="" end
 empty.Visible=not supported(v)
end

local function syncTransport()
 local v=venue();local allow=isAdmin() and supported(v)
 if oldPrev then oldPrev.Visible=false end
 prev.Visible=allow and #(history[v] or {})>0
 if nextButton then nextButton.Visible=allow end
 if oldPrev then prev.Position=oldPrev.Position;prev.Size=oldPrev.Size
 else prev.Position=UDim2.new(1,-112,1,-34);prev.Size=UDim2.fromOffset(48,26) end
 if nextButton and prev.Size.X.Offset==0 then prev.Size=nextButton.Size end
end

prev.Activated:Connect(function()
 if not isAdmin() then return end
 local v=venue();local h=history[v];if not h or #h==0 then return end
 local index=table.remove(h)
 if v=="FUNKOT" then funkotRemote:FireServer("play",index) else musicRemote:FireServer("play",index) end
 task.defer(syncTransport)
end)

player:GetAttributeChangedSignal("BBYAAudioVenue"):Connect(function()task.defer(syncPlaylist);task.defer(syncTransport)end)
player:GetAttributeChangedSignal("BBYAAdmin"):Connect(function()task.defer(syncTransport)end)
library.DescendantAdded:Connect(function()task.defer(syncPlaylist)end)
if oldPrev then
 oldPrev:GetPropertyChangedSignal("Position"):Connect(function()task.defer(syncTransport)end)
 oldPrev:GetPropertyChangedSignal("Size"):Connect(function()task.defer(syncTransport)end)
 oldPrev:GetPropertyChangedSignal("Visible"):Connect(function()if oldPrev.Visible then oldPrev.Visible=false end end)
end
if nextButton then nextButton:GetPropertyChangedSignal("Visible"):Connect(function()task.defer(syncTransport)end) end

task.spawn(function()
 while task.wait(.35) do syncPlaylist();syncTransport() end
end)

task.defer(function()syncPlaylist();syncTransport()end)
print("[BBYA] Music UI integrity: active playlist only / true history PREV / future venue isolation")
