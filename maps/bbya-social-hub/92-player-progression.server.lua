-- BBYA SOCIAL HUB — PLAYER PROGRESSION + IDENTITY v4
-- Persistent social level + owner/admin identity + persistent owner/admin-managed friend roles.
local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local levelStore=DataStoreService:GetDataStore("BBYA_SOCIAL_LEVEL_V1")
local roleStore=DataStoreService:GetDataStore("BBYA_MANAGED_ROLES_V1")
local OWNER_USERNAME="nadmo97"
local ADMIN_USERNAMES={
 ["styxraasoraaa"]=true,
}
local VALID_ROLES={VIP=true,CREW=true,ADMIN=true,NONE=true}
local LEVEL_MINUTES=10
local sessionMinutes={}
local loadedMinutes={}
local loadedRoles={}

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local roleSnapshot=remotes:FindFirstChild("RolePanelSnapshot") or Instance.new("RemoteFunction")
roleSnapshot.Name="RolePanelSnapshot";roleSnapshot.Parent=remotes
local roleAction=remotes:FindFirstChild("RolePanelAction") or Instance.new("RemoteFunction")
roleAction.Name="RolePanelAction";roleAction.Parent=remotes

local COLORS={
 Newbie=Color3.fromRGB(245,245,247),Regular=Color3.fromRGB(247,55,158),Socialite=Color3.fromRGB(59,157,255),
 Aristokrat=Color3.fromRGB(73,214,129),Monarch=Color3.fromRGB(235,184,74),GreatMonarch=Color3.fromRGB(255,205,82),
 Owner=Color3.fromRGB(255,113,196),Admin=Color3.fromRGB(73,207,235),Crew=Color3.fromRGB(103,230,174),VIP=Color3.fromRGB(235,184,74),
}

local function rankFor(level)
 if level>=50 then return "GREAT MONARCH",COLORS.GreatMonarch,true end
 if level>=40 then return "MONARCH",COLORS.Monarch,false end
 if level>=30 then return "ARISTOKRAT",COLORS.Aristokrat,false end
 if level>=20 then return "SOCIALITE",COLORS.Socialite,false end
 if level>=10 then return "REGULAR",COLORS.Regular,false end
 return "NEWBIE",COLORS.Newbie,false
end
local function usernameKey(player)return player and string.lower(player.Name) or "" end
local function isOwner(player)return usernameKey(player)==OWNER_USERNAME end
local function managedRole(player)
 local r=player and player:GetAttribute("BBYAManagedRole")
 return type(r)=="string" and r or nil
end
local function isAdmin(player)
 return player and (ADMIN_USERNAMES[usernameKey(player)]==true or managedRole(player)=="ADMIN")
end
local function canManageRoles(player)
 if not player then return false end
 if isOwner(player) or isAdmin(player) then return true end
 return game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId
end
local function levelFromMinutes(minutes)return math.max(1,math.floor(math.max(0,minutes)/LEVEL_MINUTES)+1) end

local function clearTag(character)
 local head=character and character:FindFirstChild("Head")
 local old=head and head:FindFirstChild("BBYAIdentityTag")
 if old then old:Destroy() end
end

local function makeTag(player)
 local character=player.Character
 local head=character and character:FindFirstChild("Head")
 if not head then return end
 clearTag(character)
 local level=player:GetAttribute("BBYALevel") or 1
 local rank,color,crown=rankFor(level)
 local owner=isOwner(player)
 local admin=isAdmin(player)
 local role=managedRole(player)
 if owner then rank="OWNER";color=COLORS.Owner;crown=true
 elseif admin then rank="ADMIN";color=COLORS.Admin;crown=false
 elseif role=="CREW" then rank="CREW";color=COLORS.Crew;crown=false
 elseif role=="VIP" then rank="VIP";color=COLORS.VIP;crown=false end

 local gui=Instance.new("BillboardGui")
 gui.Name="BBYAIdentityTag";gui.Adornee=head;gui.Size=UDim2.fromOffset(220,54);gui.StudsOffset=Vector3.new(0,2.75,0)
 gui.AlwaysOnTop=true;gui.MaxDistance=72;gui.LightInfluence=0;gui.Parent=head
 local holder=Instance.new("Frame");holder.Size=UDim2.fromScale(1,1);holder.BackgroundTransparency=1;holder.Parent=gui
 if crown then
  local c=Instance.new("TextLabel");c.Name="Crown";c.BackgroundTransparency=1;c.Position=UDim2.fromOffset(0,-4);c.Size=UDim2.new(1,0,0,20)
  c.Text="♕";c.TextColor3=Color3.fromRGB(255,190,225);c.TextStrokeTransparency=.35;c.Font=Enum.Font.GothamBlack;c.TextSize=18;c.Parent=holder
 end
 local name=Instance.new("TextLabel");name.BackgroundTransparency=1;name.Position=UDim2.fromOffset(0,crown and 13 or 5);name.Size=UDim2.new(1,0,0,18)
 name.Text=player.DisplayName;name.TextColor3=Color3.fromRGB(248,248,250);name.TextStrokeTransparency=.45;name.Font=Enum.Font.GothamSemibold;name.TextSize=13;name.Parent=holder
 local title=Instance.new("TextLabel");title.BackgroundTransparency=1;title.Position=UDim2.fromOffset(0,crown and 30 or 22);title.Size=UDim2.new(1,0,0,16)
 if owner then title.Text="OWNER" elseif admin then title.Text="ADMIN" elseif role=="CREW" or role=="VIP" then title.Text=role else title.Text=string.format("LV %d • %s",level,rank) end
 title.TextColor3=color;title.TextStrokeTransparency=.45;title.Font=Enum.Font.GothamBold;title.TextSize=11;title.Parent=holder
end

local function clearManagedAccess(player)
 player:SetAttribute("BBYAVIPBypass",false)
 player:SetAttribute("BBYARooftopBypass",false)
 player:SetAttribute("BBYASecretRoomBypass",false)
 player:SetAttribute("BBYATravelBypass",false)
 if not isOwner(player) and ADMIN_USERNAMES[usernameKey(player)]~=true then
  player:SetAttribute("BBYAAdmin",false);player:SetAttribute("BBYAStaff",false)
 end
end
local function grantFullAccess(player)
 player:SetAttribute("BBYAVIPBypass",true);player:SetAttribute("BBYARooftopBypass",true)
 player:SetAttribute("BBYASecretRoomBypass",true);player:SetAttribute("BBYATravelBypass",true)
end
local function applyManagedAccess(player)
 if isOwner(player) then
  player:SetAttribute("BBYAAdmin",true);player:SetAttribute("BBYAOwner",true);player:SetAttribute("BBYACoOwner",true);player:SetAttribute("BBYAQueen",true)
  grantFullAccess(player);return
 end
 local staticAdmin=ADMIN_USERNAMES[usernameKey(player)]==true
 local role=managedRole(player)
 clearManagedAccess(player)
 if staticAdmin or role=="ADMIN" then
  player:SetAttribute("BBYAAdmin",true);player:SetAttribute("BBYAStaff",true);grantFullAccess(player)
 elseif role=="CREW" then
  player:SetAttribute("BBYAStaff",true);player:SetAttribute("BBYAVIPBypass",true);player:SetAttribute("BBYARooftopBypass",true);player:SetAttribute("BBYASecretRoomBypass",true)
 elseif role=="VIP" then
  player:SetAttribute("BBYAVIPBypass",true)
 end
end

local function applyIdentity(player)
 local total=(loadedMinutes[player.UserId] or 0)+(sessionMinutes[player.UserId] or 0)
 local level=levelFromMinutes(total);player:SetAttribute("BBYALevel",level);player:SetAttribute("BBYARank",select(1,rankFor(level)))
 applyManagedAccess(player);makeTag(player)
end

local function roleKey(uid)return "u_"..tostring(uid) end
local function loadRole(player)
 local role=nil
 local ok,data=pcall(function()return roleStore:GetAsync(roleKey(player.UserId))end)
 if ok and type(data)=="string" and VALID_ROLES[data] and data~="NONE" then role=data end
 loadedRoles[player.UserId]=role
 player:SetAttribute("BBYAManagedRole",role)
end
local function persistRole(uid,role)
 return pcall(function()
  if role==nil or role=="NONE" then roleStore:RemoveAsync(roleKey(uid)) else roleStore:SetAsync(roleKey(uid),role) end
 end)
end

local function loadPlayer(player)
 local value=0
 local ok,data=pcall(function()return levelStore:GetAsync("u_"..player.UserId)end)
 if ok and type(data)=="number" then value=math.max(0,math.floor(data)) end
 loadedMinutes[player.UserId]=value;sessionMinutes[player.UserId]=0
 loadRole(player);applyIdentity(player)
 player:GetAttributeChangedSignal("BBYAManagedRole"):Connect(function()task.defer(function()applyIdentity(player)end)end)
 player.CharacterAdded:Connect(function(char)char:WaitForChild("Head",10);task.wait(.4);applyIdentity(player)end)
end
local function savePlayer(player)
 local uid=player.UserId;local total=(loadedMinutes[uid] or 0)+(sessionMinutes[uid] or 0)
 pcall(function()levelStore:SetAsync("u_"..uid,total)end);loadedMinutes[uid]=total;sessionMinutes[uid]=0
end

local function effectiveRole(player)
 if isOwner(player) then return "OWNER" end
 if isAdmin(player) then return "ADMIN" end
 local role=managedRole(player)
 if role=="CREW" or role=="VIP" then return role end
 return "VISITOR"
end
local function buildSnapshot(operator)
 if not canManageRoles(operator) then return {authorized=false} end
 local list={}
 for _,p in ipairs(Players:GetPlayers()) do
  table.insert(list,{userId=p.UserId,username=p.Name,displayName=p.DisplayName,role=effectiveRole(p),locked=isOwner(p)})
 end
 table.sort(list,function(a,b)if a.locked~=b.locked then return a.locked end return string.lower(a.displayName)<string.lower(b.displayName) end)
 return {authorized=true,operator=effectiveRole(operator),players=list}
end
roleSnapshot.OnServerInvoke=function(player)return buildSnapshot(player)end
roleAction.OnServerInvoke=function(operator,targetUserId,role)
 if not canManageRoles(operator) then return {ok=false,message="No permission."} end
 role=string.upper(tostring(role or ""));if not VALID_ROLES[role] then return {ok=false,message="Invalid role."} end
 targetUserId=tonumber(targetUserId);local target=targetUserId and Players:GetPlayerByUserId(targetUserId)
 if not target then return {ok=false,message="Player is no longer online.",snapshot=buildSnapshot(operator)} end
 if isOwner(target) then return {ok=false,message="OWNER role is locked.",snapshot=buildSnapshot(operator)} end
 local stored=(role=="NONE") and nil or role
 local ok=persistRole(target.UserId,stored)
 loadedRoles[target.UserId]=stored;target:SetAttribute("BBYAManagedRole",stored);applyIdentity(target)
 return {ok=true,persisted=ok,message=ok and (target.DisplayName.." → "..(stored or "VISITOR")) or (target.DisplayName.." updated for this server; DataStore retry needed."),snapshot=buildSnapshot(operator)}
end

for _,p in ipairs(Players:GetPlayers()) do task.spawn(loadPlayer,p) end
Players.PlayerAdded:Connect(loadPlayer)
Players.PlayerRemoving:Connect(function(p)savePlayer(p);loadedMinutes[p.UserId]=nil;sessionMinutes[p.UserId]=nil;loadedRoles[p.UserId]=nil end)
task.spawn(function()
 while task.wait(60) do
  for _,p in ipairs(Players:GetPlayers()) do
   sessionMinutes[p.UserId]=(sessionMinutes[p.UserId] or 0)+1;applyIdentity(p)
   if sessionMinutes[p.UserId]%5==0 then task.spawn(savePlayer,p) end
  end
 end
end)
game:BindToClose(function()for _,p in ipairs(Players:GetPlayers()) do savePlayer(p) end end)
print("[BBYA] Player progression v4 online: persistent VIP/CREW/ADMIN role authority + OWNER lock + role panel remotes")
