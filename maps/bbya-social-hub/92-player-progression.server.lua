-- BBYA SOCIAL HUB — PLAYER PROGRESSION + IDENTITY v5.2
-- Authority: persistent social level/XP, managed roles, custom cosmetic TITLE and overhead identity.
-- Official staff roles: OWNER / CO OWNER / ADMIN / MODERATOR / DJ / LEAD / MEDIA.
-- Revision v1.1 requested assignments are resolved through Roblox username authority before UserId persistence; no guessed IDs.
local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TextService=game:GetService("TextService")

local levelStore=DataStoreService:GetDataStore("BBYA_SOCIAL_LEVEL_V1")
local roleStore=DataStoreService:GetDataStore("BBYA_MANAGED_ROLES_V1")
local titleStore=DataStoreService:GetDataStore("BBYA_CUSTOM_TITLE_V1")
local OWNER_USERNAME="nadmo97"
local ADMIN_USERNAMES={
 ["styxraasoraaa"]=true,
}
local REQUESTED_ROLE_ASSIGNMENTS={
 ["arda_moron123"]={username="Arda_moron123",role="MEDIA"},
 ["talonthedevil"]={username="Talonthedevil",role="LEAD"},
 ["ridhoomaukamu"]={username="Ridhoomaukamu",role="DJ"},
}
local VALID_ROLES={VIP=true,CREW=true,COOWNER=true,ADMIN=true,MODERATOR=true,DJ=true,LEAD=true,MEDIA=true,NONE=true}
local LEVEL_MINUTES=10
local TITLE_MAX=16
local sessionMinutes={}
local loadedMinutes={}
local loadedRoles={}
local loadedTitles={}
local lastLevel={}
local requestedRoleByUserId={}

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local function remote(className,name)
 local r=remotes:FindFirstChild(name) or Instance.new(className)
 r.Name=name;r.Parent=remotes;return r
end
local roleSnapshot=remote("RemoteFunction","RolePanelSnapshot")
local roleAction=remote("RemoteFunction","RolePanelAction")
local titleSnapshot=remote("RemoteFunction","TitleSnapshot")
local titleAction=remote("RemoteFunction","TitleAction")
local levelUp=remote("RemoteEvent","LevelUp")

local COLORS={
 Newbie=Color3.fromRGB(245,245,247),Regular=Color3.fromRGB(247,55,158),Socialite=Color3.fromRGB(59,157,255),
 Aristokrat=Color3.fromRGB(73,214,129),Monarch=Color3.fromRGB(235,184,74),GreatMonarch=Color3.fromRGB(255,205,82),
 Owner=Color3.fromRGB(255,113,196),CoOwner=Color3.fromRGB(255,151,78),Admin=Color3.fromRGB(73,207,235),Moderator=Color3.fromRGB(116,222,173),
 Crew=Color3.fromRGB(103,230,174),VIP=Color3.fromRGB(235,184,74),DJ=Color3.fromRGB(174,104,255),Lead=Color3.fromRGB(255,98,87),Media=Color3.fromRGB(69,172,255),
}
local ROLE_COLORS={
 OWNER=COLORS.Owner,["CO OWNER"]=COLORS.CoOwner,ADMIN=COLORS.Admin,MODERATOR=COLORS.Moderator,
 CREW=COLORS.Crew,VIP=COLORS.VIP,DJ=COLORS.DJ,LEAD=COLORS.Lead,MEDIA=COLORS.Media,
}
local RESERVED_COLOR_HEX={}
local function colorHex(c)
 return string.format("#%02X%02X%02X",math.floor(c.R*255+.5),math.floor(c.G*255+.5),math.floor(c.B*255+.5))
end
for _,c in pairs(ROLE_COLORS) do RESERVED_COLOR_HEX[colorHex(c)]=true end
local RESERVED_TITLES={OWNER=true,COOWNER=true,ADMIN=true,MODERATOR=true,DJ=true,LEAD=true,MEDIA=true,VIP=true,CREW=true}

local function rankFor(level)
 if level>=50 then return "GREAT MONARCH",COLORS.GreatMonarch end
 if level>=40 then return "MONARCH",COLORS.Monarch end
 if level>=30 then return "ARISTOKRAT",COLORS.Aristokrat end
 if level>=20 then return "SOCIALITE",COLORS.Socialite end
 if level>=10 then return "REGULAR",COLORS.Regular end
 return "NEWBIE",COLORS.Newbie
end
local function usernameKey(player)return player and string.lower(player.Name) or "" end
local function isOwner(player)return usernameKey(player)==OWNER_USERNAME end
local function managedRole(player)
 local r=player and player:GetAttribute("BBYAManagedRole")
 return type(r)=="string" and r or nil
end
local function isCoOwner(player)return player and managedRole(player)=="COOWNER" end
local function isAdmin(player)
 return player and (ADMIN_USERNAMES[usernameKey(player)]==true or managedRole(player)=="ADMIN")
end
local function canManageRoles(player)
 if not player then return false end
 if isOwner(player) or isCoOwner(player) or isAdmin(player) then return true end
 return game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId
end
local function levelFromMinutes(minutes)return math.max(1,math.floor(math.max(0,minutes)/LEVEL_MINUTES)+1) end
local function roleKey(uid)return "u_"..tostring(uid) end
local function titleKey(uid)return "u_"..tostring(uid) end

local function exactResolveRequested(req)
 local ok,uid=pcall(function()return Players:GetUserIdFromNameAsync(req.username)end)
 if not ok or not tonumber(uid) or uid<=0 then return nil end
 local okName,resolved=pcall(function()return Players:GetNameFromUserIdAsync(uid)end)
 if not okName or string.lower(tostring(resolved))~=string.lower(req.username) then return nil end
 return uid,resolved
end
local function persistRequestedResolved(req,uid,resolved)
 requestedRoleByUserId[uid]=req.role
 local okRead,current=pcall(function()return roleStore:GetAsync(roleKey(uid))end)
 local okWrite=true
 if not okRead or current~=req.role then okWrite=pcall(function()roleStore:SetAsync(roleKey(uid),req.role)end) end
 ReplicatedStorage:SetAttribute("BBYARoleLock_"..req.username,okWrite and (tostring(uid)..":"..req.role) or "STORE_FAILED")
 if okWrite then print("[BBYA Roles] resolved + locked",resolved,uid,req.role) else warn("[BBYA Roles] persistence failed",req.username,uid,req.role) end
 return okWrite
end
local function bootstrapRequestedRoles()
 local resolvedCount=0
 for _,req in pairs(REQUESTED_ROLE_ASSIGNMENTS) do
  local uid,resolved=exactResolveRequested(req)
  if uid then persistRequestedResolved(req,uid,resolved);resolvedCount+=1 else ReplicatedStorage:SetAttribute("BBYARoleLock_"..req.username,"RESOLVE_FAILED");warn("[BBYA Roles] exact Roblox username resolution failed",req.username) end
 end
 ReplicatedStorage:SetAttribute("BBYARevisionRoleLocksResolved",resolvedCount)
 ReplicatedStorage:SetAttribute("BBYARevisionRoleLocksComplete",resolvedCount==3)
end
local function requestedRoleForPlayer(player)
 local locked=requestedRoleByUserId[player.UserId]
 if locked then return locked end
 local req=REQUESTED_ROLE_ASSIGNMENTS[usernameKey(player)]
 if not req then return nil end
 local okName,resolved=pcall(function()return Players:GetNameFromUserIdAsync(player.UserId)end)
 if not okName or string.lower(tostring(resolved))~=string.lower(req.username) then return nil end
 requestedRoleByUserId[player.UserId]=req.role
 return req.role
end

task.spawn(bootstrapRequestedRoles)

local function normalizeRoleLike(value)
 local s=string.upper(tostring(value or ""))
 s=s:gsub("0","O"):gsub("1","I"):gsub("3","E"):gsub("4","A"):gsub("5","S"):gsub("7","T")
 s=s:gsub("[^A-Z0-9]","")
 return s
end
local function reservedTitle(value)
 local n=normalizeRoleLike(value)
 if n=="" then return false end
 if RESERVED_TITLES[n] then return true end
 for word in pairs(RESERVED_TITLES) do
  if #word>2 and string.find(n,word,1,true) then return true end
 end
 if n:sub(1,2)=="DJ" then return true end
 return false
end
local function normalizeHex(value)
 local s=string.upper(tostring(value or "")):gsub("%s+","")
 if not s:match("^#%x%x%x%x%x%x$") then return nil end
 return s
end
local function hexColor(value)
 local h=normalizeHex(value)
 if not h then return nil end
 return Color3.fromRGB(tonumber(h:sub(2,3),16),tonumber(h:sub(4,5),16),tonumber(h:sub(6,7),16)),h
end
local function trim(value)
 local s=tostring(value or "")
 return (s:gsub("^%s+",""):gsub("%s+$",""))
end
local function validateAndFilterTitle(player,textValue,colorValue)
 local text=trim(textValue)
 local len=utf8.len(text)
 if not len or len<1 then return nil,"Title cannot be empty." end
 if len>TITLE_MAX then return nil,"Maximum 16 characters." end
 if reservedTitle(text) then return nil,"That title is reserved for an official BBYA role." end
 local _,hex=hexColor(colorValue)
 if not hex then return nil,"Invalid title color." end
 if RESERVED_COLOR_HEX[hex] then return nil,"That color is reserved for an official BBYA role." end
 local ok,filtered=pcall(function()
  local result=TextService:FilterStringAsync(text,player.UserId,Enum.TextFilterContext.PublicChat)
  return result:GetNonChatStringForBroadcastAsync()
 end)
 if not ok or type(filtered)~="string" or filtered=="" then return nil,"Roblox text filter rejected this title." end
 if reservedTitle(filtered) then return nil,"That title is reserved for an official BBYA role." end
 return {text=filtered,color=hex,equipped=false}
end

local function applyTitleAttributes(player)
 local data=loadedTitles[player.UserId]
 local equipped=type(data)=="table" and data.equipped==true and type(data.text)=="string" and data.text~=""
 player:SetAttribute("BBYACustomTitle",equipped and data.text or nil)
 player:SetAttribute("BBYACustomTitleColorHex",equipped and data.color or nil)
 player:SetAttribute("BBYACustomTitleEquipped",equipped)
end

local function clearTag(character)
 local head=character and character:FindFirstChild("Head")
 local old=head and head:FindFirstChild("BBYAIdentityTag")
 if old then old:Destroy() end
end
local function effectiveRole(player)
 if isOwner(player) then return "OWNER" end
 local role=managedRole(player)
 if role=="COOWNER" then return "CO OWNER" end
 if isAdmin(player) then return "ADMIN" end
 if role and VALID_ROLES[role] and role~="NONE" then return role end
 return "VISITOR"
end
local function makeTag(player)
 local character=player.Character
 local head=character and character:FindFirstChild("Head")
 if not head then return end
 clearTag(character)
 local level=player:GetAttribute("BBYALevel") or 1
 local rank,rankColor=rankFor(level)
 local role=effectiveRole(player)
 local official=role~="VISITOR"
 local lineText=official and role or string.format("LV %d • %s",level,rank)
 local lineColor=official and (ROLE_COLORS[role] or rankColor) or rankColor
 local custom=player:GetAttribute("BBYACustomTitle")
 local customColor=nil
 if custom then customColor=select(1,hexColor(player:GetAttribute("BBYACustomTitleColorHex"))) end

 local gui=Instance.new("BillboardGui")
 gui.Name="BBYAIdentityTag";gui.Adornee=head;gui.Size=UDim2.fromOffset(230,custom and 66 or 50);gui.StudsOffset=Vector3.new(0,2.75,0)
 gui.AlwaysOnTop=true;gui.MaxDistance=72;gui.LightInfluence=0;gui.Parent=head
 local holder=Instance.new("Frame");holder.Size=UDim2.fromScale(1,1);holder.BackgroundTransparency=1;holder.Parent=gui
 local name=Instance.new("TextLabel");name.BackgroundTransparency=1;name.Position=UDim2.fromOffset(0,3);name.Size=UDim2.new(1,0,0,18)
 name.Text=player.DisplayName;name.TextColor3=Color3.fromRGB(248,248,250);name.TextStrokeTransparency=.45;name.Font=Enum.Font.GothamSemibold;name.TextSize=13;name.Parent=holder
 local roleLine=Instance.new("TextLabel");roleLine.BackgroundTransparency=1;roleLine.Position=UDim2.fromOffset(0,21);roleLine.Size=UDim2.new(1,0,0,16)
 roleLine.Text=lineText;roleLine.TextColor3=lineColor;roleLine.TextStrokeTransparency=.45;roleLine.Font=Enum.Font.GothamBold;roleLine.TextSize=11;roleLine.Parent=holder
 if custom then
  local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=UDim2.fromOffset(0,37);t.Size=UDim2.new(1,0,0,16)
  t.Text=custom;t.TextColor3=customColor or COLORS.Newbie;t.TextStrokeTransparency=.45;t.Font=Enum.Font.GothamBold;t.TextSize=11;t.Parent=holder
 end
end

local function clearManagedAccess(player)
 player:SetAttribute("BBYAVIPBypass",false)
 player:SetAttribute("BBYARooftopBypass",false)
 player:SetAttribute("BBYASecretRoomBypass",false)
 player:SetAttribute("BBYATravelBypass",false)
 player:SetAttribute("BBYAHasDJRole",false)
 player:SetAttribute("BBYAHasLeadRole",false)
 player:SetAttribute("BBYAHasMediaRole",false)
 player:SetAttribute("BBYAModerator",false)
 if not isOwner(player) then player:SetAttribute("BBYACoOwner",false) end
 if not isOwner(player) and ADMIN_USERNAMES[usernameKey(player)]~=true then
  player:SetAttribute("BBYAAdmin",false);player:SetAttribute("BBYAStaff",false)
 end
end
local function grantFullAccess(player)
 player:SetAttribute("BBYAVIPBypass",true);player:SetAttribute("BBYARooftopBypass",true)
 player:SetAttribute("BBYASecretRoomBypass",true);player:SetAttribute("BBYATravelBypass",true)
end
local function applyManagedAccess(player)
 local role=managedRole(player)
 clearManagedAccess(player)
 player:SetAttribute("BBYAHasDJRole",role=="DJ")
 player:SetAttribute("BBYAHasLeadRole",role=="LEAD")
 player:SetAttribute("BBYAHasMediaRole",role=="MEDIA")
 if isOwner(player) then
  player:SetAttribute("BBYAAdmin",true);player:SetAttribute("BBYAOwner",true);player:SetAttribute("BBYACoOwner",true);player:SetAttribute("BBYAQueen",true)
  grantFullAccess(player)
 elseif role=="COOWNER" then
  player:SetAttribute("BBYACoOwner",true);player:SetAttribute("BBYAAdmin",true);player:SetAttribute("BBYAStaff",true);grantFullAccess(player)
 elseif ADMIN_USERNAMES[usernameKey(player)]==true or role=="ADMIN" then
  player:SetAttribute("BBYAAdmin",true);player:SetAttribute("BBYAStaff",true);grantFullAccess(player)
 elseif role=="MODERATOR" then
  player:SetAttribute("BBYAModerator",true);player:SetAttribute("BBYAStaff",true);player:SetAttribute("BBYAVIPBypass",true);player:SetAttribute("BBYARooftopBypass",true)
 elseif role=="CREW" then
  player:SetAttribute("BBYAStaff",true);player:SetAttribute("BBYAVIPBypass",true);player:SetAttribute("BBYARooftopBypass",true);player:SetAttribute("BBYASecretRoomBypass",true)
 elseif role=="VIP" then
  player:SetAttribute("BBYAVIPBypass",true)
 end
 player:SetAttribute("BBYAEffectiveRole",effectiveRole(player))
end
local function applyIdentity(player)
 local total=(loadedMinutes[player.UserId] or 0)+(sessionMinutes[player.UserId] or 0)
 local level=levelFromMinutes(total)
 player:SetAttribute("BBYALevel",level)
 player:SetAttribute("BBYARank",select(1,rankFor(level)))
 player:SetAttribute("BBYAPlayMinutes",total)
 player:SetAttribute("BBYAXP",total)
 player:SetAttribute("BBYALevelXP",total%LEVEL_MINUTES)
 player:SetAttribute("BBYALevelXPRequired",LEVEL_MINUTES)
 applyManagedAccess(player);applyTitleAttributes(player);makeTag(player)
 return level
end

local function loadRole(player)
 local role=nil
 local ok,data=pcall(function()return roleStore:GetAsync(roleKey(player.UserId))end)
 if ok and type(data)=="string" and VALID_ROLES[data] and data~="NONE" then role=data end
 local requested=requestedRoleForPlayer(player)
 if requested then
  role=requested
  if not ok or data~=requested then task.spawn(function()persistRequestedResolved(REQUESTED_ROLE_ASSIGNMENTS[usernameKey(player)],player.UserId,player.Name)end) end
 end
 loadedRoles[player.UserId]=role
 player:SetAttribute("BBYAManagedRole",role)
end
local function persistRole(uid,role)
 return pcall(function()
  if role==nil or role=="NONE" then roleStore:RemoveAsync(roleKey(uid)) else roleStore:SetAsync(roleKey(uid),role) end
 end)
end
local function loadTitle(player)
 local data=nil
 local ok,value=pcall(function()return titleStore:GetAsync(titleKey(player.UserId))end)
 if ok and type(value)=="table" and type(value.text)=="string" and normalizeHex(value.color) then
  data={text=value.text,color=normalizeHex(value.color),equipped=value.equipped==true}
 end
 loadedTitles[player.UserId]=data
 applyTitleAttributes(player)
end
local function persistTitle(uid,data)
 return pcall(function()
  if data==nil then titleStore:RemoveAsync(titleKey(uid)) else titleStore:SetAsync(titleKey(uid),data) end
 end)
end

local function loadPlayer(player)
 local value=0
 local ok,data=pcall(function()return levelStore:GetAsync("u_"..player.UserId)end)
 if ok and type(data)=="number" then value=math.max(0,math.floor(data)) end
 loadedMinutes[player.UserId]=value;sessionMinutes[player.UserId]=0
 loadRole(player);loadTitle(player)
 lastLevel[player.UserId]=applyIdentity(player)
 player:GetAttributeChangedSignal("BBYAManagedRole"):Connect(function()task.defer(function()applyIdentity(player)end)end)
 player.CharacterAdded:Connect(function(char)char:WaitForChild("Head",10);task.wait(.4);applyIdentity(player)end)
end
local function savePlayer(player)
 local uid=player.UserId;local total=(loadedMinutes[uid] or 0)+(sessionMinutes[uid] or 0)
 pcall(function()levelStore:SetAsync("u_"..uid,total)end);loadedMinutes[uid]=total;sessionMinutes[uid]=0
end

local function buildSnapshot(operator)
 if not canManageRoles(operator) then return {authorized=false} end
 local list={}
 for _,p in ipairs(Players:GetPlayers()) do
  table.insert(list,{userId=p.UserId,username=p.Name,displayName=p.DisplayName,role=effectiveRole(p),locked=isOwner(p) or requestedRoleForPlayer(p)~=nil})
 end
 table.sort(list,function(a,b)if a.locked~=b.locked then return a.locked end return string.lower(a.displayName)<string.lower(b.displayName) end)
 return {authorized=true,operator=effectiveRole(operator),players=list}
end
roleSnapshot.OnServerInvoke=function(player)return buildSnapshot(player)end
roleAction.OnServerInvoke=function(operator,targetUserId,role)
 if not canManageRoles(operator) then return {ok=false,message="No permission."} end
 role=string.upper(tostring(role or "")):gsub("%s+","")
 if not VALID_ROLES[role] then return {ok=false,message="Invalid role."} end
 targetUserId=tonumber(targetUserId);local target=targetUserId and Players:GetPlayerByUserId(targetUserId)
 if not target then return {ok=false,message="Player is no longer online.",snapshot=buildSnapshot(operator)} end
 if isOwner(target) then return {ok=false,message="OWNER role is locked.",snapshot=buildSnapshot(operator)} end
 local requested=requestedRoleForPlayer(target)
 if requested then return {ok=false,message=target.DisplayName.." role is locked to "..requested.." by revision authority.",snapshot=buildSnapshot(operator)} end
 local stored=(role=="NONE") and nil or role
 local ok=persistRole(target.UserId,stored)
 loadedRoles[target.UserId]=stored;target:SetAttribute("BBYAManagedRole",stored);applyIdentity(target)
 local displayRole=stored=="COOWNER" and "CO OWNER" or (stored or "VISITOR")
 return {ok=true,persisted=ok,message=ok and (target.DisplayName.." → "..displayRole) or (target.DisplayName.." updated for this server; DataStore retry needed."),snapshot=buildSnapshot(operator)}
end

titleSnapshot.OnServerInvoke=function(player)
 local data=loadedTitles[player.UserId]
 return {ok=true,maxLength=TITLE_MAX,title=data and data.text or "",color=data and data.color or "#F3F3F3",equipped=data and data.equipped==true or false}
end
titleAction.OnServerInvoke=function(player,action,payload)
 action=string.lower(tostring(action or ""));payload=type(payload)=="table" and payload or {}
 if action=="save" then
  local data,message=validateAndFilterTitle(player,payload.text,payload.color)
  if not data then return {ok=false,message=message} end
  local previous=loadedTitles[player.UserId]
  if previous and previous.equipped==true then data.equipped=true end
  loadedTitles[player.UserId]=data
  local ok=persistTitle(player.UserId,data);applyIdentity(player)
  return {ok=ok,message=ok and "TITLE saved." or "TITLE saved for this server; DataStore retry needed.",title=data.text,color=data.color,equipped=data.equipped}
 elseif action=="equip" then
  local data=loadedTitles[player.UserId]
  if not data then return {ok=false,message="Save a TITLE first."} end
  data.equipped=true
  local ok=persistTitle(player.UserId,data);applyIdentity(player)
  return {ok=ok,message=ok and "TITLE equipped." or "TITLE equipped for this server; DataStore retry needed.",title=data.text,color=data.color,equipped=true}
 elseif action=="remove" then
  loadedTitles[player.UserId]=nil
  local ok=persistTitle(player.UserId,nil);applyIdentity(player)
  return {ok=ok,message=ok and "TITLE removed." or "TITLE removed for this server; DataStore retry needed.",title="",color="#F3F3F3",equipped=false}
 end
 return {ok=false,message="Unknown TITLE action."}
end

for _,p in ipairs(Players:GetPlayers()) do task.spawn(loadPlayer,p) end
Players.PlayerAdded:Connect(loadPlayer)
Players.PlayerRemoving:Connect(function(p)
 savePlayer(p);loadedMinutes[p.UserId]=nil;sessionMinutes[p.UserId]=nil;loadedRoles[p.UserId]=nil;loadedTitles[p.UserId]=nil;lastLevel[p.UserId]=nil
end)
task.spawn(function()
 while task.wait(60) do
  for _,p in ipairs(Players:GetPlayers()) do
   local uid=p.UserId
   local before=lastLevel[uid] or levelFromMinutes((loadedMinutes[uid] or 0)+(sessionMinutes[uid] or 0))
   sessionMinutes[uid]=(sessionMinutes[uid] or 0)+1
   local after=applyIdentity(p)
   lastLevel[uid]=after
   if after>before then levelUp:FireClient(p,{level=after,rank=p:GetAttribute("BBYARank")}) end
   if sessionMinutes[uid]%5==0 then task.spawn(savePlayer,p) end
  end
 end
end)
game:BindToClose(function()for _,p in ipairs(Players:GetPlayers()) do savePlayer(p) end end)
print("[BBYA] Player progression v5.2 online: persistent level/XP + exact-resolved locked MEDIA/LEAD/DJ revision assignments + custom TITLE")