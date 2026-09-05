-- BBYA SOCIAL HUB — DONOR CROWN AUTHORITY v1
-- Permanent Supporter entitlement at cumulative Support >= 1,000 R$.
-- Current Top 3 rank crown: #1 Gold, #2 Silver, #3 Bronze using the existing real-contribution OrderedDataStore.
-- Crowns are procedural 3D Accessories (no emoji / 2D icon / invented external mesh asset).
-- A Top 3 player temporarily shows the rank crown instead of stacking two crowns; permanent Supporter ownership is never revoked.

local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")

local SUPPORT_THRESHOLD=1000
local QUALIFIER_MIN=1001
local SUPPORTER_STORE=DataStoreService:GetDataStore("BBYA_CROWN_SUPPORTER_V1")
local RANK_STORE=DataStoreService:GetOrderedDataStore("BBYA_TOP_DONATOR_V1")

local supporterOwned={}
local currentRankByUserId={}
local refreshToken=0

local COLORS={
 SUPPORTER=Color3.fromRGB(235,184,74),
 [1]=Color3.fromRGB(239,190,92),
 [2]=Color3.fromRGB(203,208,218),
 [3]=Color3.fromRGB(203,133,85),
}

local function numeric(v)return math.max(0,math.floor(tonumber(v) or 0)) end
local function key(uid)return "u_"..tostring(uid) end
local function clearCrowns(character)
 if not character then return end
 for _,name in ipairs({"BBYASupporterCrown3D","BBYATopDonorCrown3D"}) do
  local old=character:FindFirstChild(name);if old then old:Destroy() end
 end
end
local function weld(part,handle)
 local w=Instance.new("WeldConstraint");w.Part0=handle;w.Part1=part;w.Parent=part
end
local function component(parent,handle,className,name,size,cf,color,material)
 local p=Instance.new(className);p.Name=name;p.Size=size;p.CFrame=handle.CFrame*cf;p.Color=color;p.Material=material or Enum.Material.Metal
 p.Anchored=false;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true;p.CastShadow=true;p.Parent=parent;weld(p,handle);return p
end
local function buildCrown(name,color,rankStyle)
 local acc=Instance.new("Accessory");acc.Name=name;acc:SetAttribute("BBYACrown3D",true);acc:SetAttribute("ExternalMeshAssetUsed",false)
 local handle=Instance.new("Part");handle.Name="Handle";handle.Size=Vector3.new(.2,.2,.2);handle.Transparency=1;handle.CanCollide=false;handle.CanTouch=false;handle.CanQuery=false;handle.Massless=true;handle.Parent=acc
 local attach=Instance.new("Attachment");attach.Name="HatAttachment";attach.Position=Vector3.new(0,.58,0);attach.Parent=handle
 local radius=rankStyle and .72 or .64
 local y=rankStyle and .13 or .08
 for i=1,8 do
  local a=math.rad((i-1)*45)
  local x,z=math.cos(a)*radius,math.sin(a)*radius
  local cf=CFrame.new(x,y,z)*CFrame.Angles(0,-a,0)
  component(acc,handle,"Part","Band"..i,Vector3.new(.50,.18,.14),cf,color,Enum.Material.Metal)
 end
 local spikeCount=rankStyle and 8 or 6
 for i=1,spikeCount do
  local a=math.rad((i-1)*(360/spikeCount))
  local x,z=math.cos(a)*radius,math.sin(a)*radius
  local h=rankStyle and ((i%2==1) and .78 or .58) or .42
  local cf=CFrame.new(x,y+.14+h*.5,z)*CFrame.Angles(0,-a,math.rad(180))
  component(acc,handle,"WedgePart","Spike"..i,Vector3.new(.28,h,.18),cf,color,Enum.Material.Metal)
 end
 if rankStyle then
  local gemColor=rankStyle==1 and Color3.fromRGB(255,70,100) or (rankStyle==2 and Color3.fromRGB(73,207,235) or Color3.fromRGB(247,55,158))
  for i=1,4 do
   local a=math.rad((i-1)*90);local x,z=math.cos(a)*(radius+.02),math.sin(a)*(radius+.02)
   local gem=component(acc,handle,"Part","Gem"..i,Vector3.new(.14,.14,.10),CFrame.new(x,y+.02,z),gemColor,Enum.Material.Neon);gem.Shape=Enum.PartType.Ball
  end
 end
 return acc
end
local function addAccessory(player,kind,rank)
 local ch=player.Character;local hum=ch and ch:FindFirstChildOfClass("Humanoid");if not ch or not hum or hum.Health<=0 then return end
 clearCrowns(ch)
 if kind=="rank" then
  local color=COLORS[rank];if not color then return end
  local acc=buildCrown("BBYATopDonorCrown3D",color,rank);acc:SetAttribute("Rank",rank);acc:SetAttribute("RankColor",rank==1 and "GOLD" or rank==2 and "SILVER" or "BRONZE")
  local ok=pcall(function()hum:AddAccessory(acc)end);if not ok then acc:Destroy() end
 elseif kind=="supporter" then
  local acc=buildCrown("BBYASupporterCrown3D",COLORS.SUPPORTER,false);acc:SetAttribute("Milestone","SUPPORT_1000_PERMANENT")
  local ok=pcall(function()hum:AddAccessory(acc)end);if not ok then acc:Destroy() end
 end
end
local function applyPlayer(player)
 local rank=currentRankByUserId[player.UserId]
 player:SetAttribute("BBYATopDonorRank",rank)
 player:SetAttribute("BBYASupporterCrownOwned",supporterOwned[player.UserId]==true)
 if rank then addAccessory(player,"rank",rank)
 elseif supporterOwned[player.UserId] then addAccessory(player,"supporter")
 else clearCrowns(player.Character) end
end
local function persistSupporter(uid)
 supporterOwned[uid]=true
 task.spawn(function()pcall(function()SUPPORTER_STORE:SetAsync(key(uid),true)end)end)
 local p=Players:GetPlayerByUserId(uid);if p then applyPlayer(p) end
end
local function evaluateMilestone(player)
 if not player or supporterOwned[player.UserId] then return end
 local support=numeric(player:GetAttribute("BBYASupportRobuxTotal"))
 if support>=SUPPORT_THRESHOLD then persistSupporter(player.UserId) end
end
local function loadSupporter(player)
 local owned=false
 local ok,v=pcall(function()return SUPPORTER_STORE:GetAsync(key(player.UserId))end);if ok and v==true then owned=true end
 supporterOwned[player.UserId]=owned
 evaluateMilestone(player);applyPlayer(player)
end
local function refreshRanks()
 refreshToken+=1;local token=refreshToken
 task.spawn(function()
  local ok,pages=pcall(function()return RANK_STORE:GetSortedAsync(false,20)end);if not ok or not pages or token~=refreshToken then return end
  local nextRanks={};local rank=0
  for _,entry in ipairs(pages:GetCurrentPage()) do
   local uid=tonumber(entry.key);local total=numeric(entry.value)
   if uid and total>=QUALIFIER_MIN then rank+=1;nextRanks[uid]=rank;if rank>=3 then break end end
  end
  if token~=refreshToken then return end
  currentRankByUserId=nextRanks
  for _,p in ipairs(Players:GetPlayers()) do applyPlayer(p) end
 end)
end
local function wire(player)
 task.spawn(loadSupporter,player)
 player:GetAttributeChangedSignal("BBYASupportRobuxTotal"):Connect(function()evaluateMilestone(player);task.delay(.8,refreshRanks)end)
 player:GetAttributeChangedSignal("BBYASultanContributionRobux"):Connect(function()task.delay(.8,refreshRanks)end)
 player.CharacterAdded:Connect(function()task.delay(1,function()if player.Parent then applyPlayer(player)end end)end)
end
for _,p in ipairs(Players:GetPlayers()) do wire(p) end
Players.PlayerAdded:Connect(wire)
Players.PlayerRemoving:Connect(function(p)supporterOwned[p.UserId]=nil end)
task.delay(2,refreshRanks)
task.spawn(function()while task.wait(30) do refreshRanks() end end)

print("[BBYA] Donor Crown authority v1 online: permanent Supporter >=1000 + Top3 Gold/Silver/Bronze 3D accessories")
