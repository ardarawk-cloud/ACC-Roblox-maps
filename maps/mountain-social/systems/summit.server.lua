local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local STORE=DataStoreService:GetDataStore("ACC_MountainSummits_v1")
local ROOT=workspace:WaitForChild("ACC_MountainSocial",15)
local function ensure(player)local stats=player:FindFirstChild("leaderstats")or Instance.new("Folder");stats.Name="leaderstats";stats.Parent=player;local s=stats:FindFirstChild("Summits")or Instance.new("IntValue");s.Name="Summits";s.Parent=stats;local d=stats:FindFirstChild("Discoveries")or Instance.new("IntValue");d.Name="Discoveries";d.Parent=stats;return s end
local function title(n)if n>=100 then return"Legend of the Peak"elseif n>=50 then return"Cloud Walker"elseif n>=20 then return"Ridge Master"elseif n>=10 then return"Summit Seeker"elseif n>=3 then return"Trail Regular"elseif n>=1 then return"First Summit"else return"New Hiker"end end
local function init(p)local s=ensure(p);local ok,data=pcall(function()return STORE:GetAsync("u_"..p.UserId)end);if ok and type(data)=="table"then s.Value=tonumber(data.summits)or 0 end;p:SetAttribute("MountainTitle",title(s.Value));p:SetAttribute("ACC_SummitAwardedSession",false);s.Changed:Connect(function(v)p:SetAttribute("MountainTitle",title(v))end)end
Players.PlayerAdded:Connect(init);for _,p in ipairs(Players:GetPlayers())do task.spawn(init,p)end
if not ROOT then return end
local summit=ROOT:FindFirstChild("ACC_SummitMonument",true)
if summit and summit:IsA("BasePart")then summit.Touched:Connect(function(hit)local char=hit:FindFirstAncestorOfClass("Model");local p=char and Players:GetPlayerFromCharacter(char);if not p or p:GetAttribute("ACC_SummitAwardedSession")then return end;local cp=p:GetAttribute("MountainCheckpoint")or 0;if cp<12 then return end;p:SetAttribute("ACC_SummitAwardedSession",true);p:SetAttribute("ACC_SummitReached",true);local s=ensure(p);s.Value+=1;p:SetAttribute("LastSummitAt",os.time());task.spawn(function()pcall(function()STORE:SetAsync("u_"..p.UserId,{summits=s.Value})end)end)end)end
workspace:SetAttribute("ACC_SummitSystem","v1.9")