local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local ROOT_NAME="ACC_MountainSocial"
local DATASTORE=DataStoreService:GetDataStore("ACC_MountainSocial_v1")
local function root()return workspace:FindFirstChild(ROOT_NAME)end
local function folder()local r=root();return r and r:FindFirstChild("Checkpoints")end
local function number(part)return tonumber(part:GetAttribute("CheckpointIndex")) or tonumber(part:GetAttribute("CheckpointNumber")) or tonumber(string.match(part.Name,"%d+"))end
local function setCheckpoint(player,cp)player:SetAttribute("MountainCheckpoint",cp);player:SetAttribute("ACC_Checkpoint",cp)end
local function save(player,cp)setCheckpoint(player,cp);task.spawn(function()pcall(function()DATASTORE:SetAsync("u_"..player.UserId,{checkpoint=cp})end)end)end
local function teleport(player)local cp=player:GetAttribute("MountainCheckpoint")or 0;if cp<=0 then return end;local f=folder();if not f then return end;for _,p in ipairs(f:GetChildren())do if number(p)==cp then local c=player.Character;local hrp=c and c:FindFirstChild("HumanoidRootPart");if hrp then hrp.CFrame=p.CFrame+Vector3.new(0,6,0)end;return end end end
local function wire(p)if not p:IsA("BasePart")or p:GetAttribute("ACC_Wired")then return end;p:SetAttribute("ACC_Wired",true);p.Touched:Connect(function(hit)local char=hit:FindFirstAncestorOfClass("Model");local player=char and Players:GetPlayerFromCharacter(char);if not player then return end;local n=number(p);if not n then return end;local cur=player:GetAttribute("MountainCheckpoint")or 0;if n>cur then save(player,n)end end)end
local function init(player)setCheckpoint(player,0);local ok,data=pcall(function()return DATASTORE:GetAsync("u_"..player.UserId)end);if ok and type(data)=="table"and tonumber(data.checkpoint)then setCheckpoint(player,math.clamp(tonumber(data.checkpoint),0,12))end;player.CharacterAdded:Connect(function()task.wait(1);teleport(player)end);if player.Character then task.defer(function()task.wait(1);teleport(player)end)end end
Players.PlayerAdded:Connect(init);for _,p in ipairs(Players:GetPlayers())do task.spawn(init,p)end
local f=folder();if f then for _,p in ipairs(f:GetChildren())do wire(p)end;f.ChildAdded:Connect(wire)end
workspace:SetAttribute("ACC_CheckpointSystem","v1.9")