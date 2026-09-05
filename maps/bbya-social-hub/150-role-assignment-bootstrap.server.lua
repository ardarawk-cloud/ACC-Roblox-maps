-- BBYA SOCIAL HUB — REQUESTED ROLE ASSIGNMENT BOOTSTRAP v1
-- Resolves exact Roblox usernames at runtime before persisting managed roles. No guessed/hard-coded UserIds.
-- Ongoing role behavior remains owned by 92-player-progression.server.lua.

local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local ROLE_STORE=DataStoreService:GetDataStore("BBYA_MANAGED_ROLES_V1")
local REQUESTS={
 {username="Arda_moron123",role="MEDIA"},
 {username="Talonthedevil",role="LEAD"},
 {username="Ridhoomaukamu",role="DJ"},
}
local VALID={MEDIA=true,LEAD=true,DJ=true}
local STATUS_PREFIX="BBYARoleBootstrap_"

local function exactResolve(username)
 for attempt=1,3 do
  local ok,uid=pcall(function()return Players:GetUserIdFromNameAsync(username)end)
  if ok and tonumber(uid) and uid>0 then
   local okName,resolved=pcall(function()return Players:GetNameFromUserIdAsync(uid)end)
   if okName and string.lower(tostring(resolved))==string.lower(username) then
    return uid,resolved
   end
  end
  task.wait(attempt*.8)
 end
 return nil,nil
end

local function applyOnline(uid,role)
 local player=Players:GetPlayerByUserId(uid)
 if not player then return end
 player:SetAttribute("BBYAManagedRole",role)
 player:SetAttribute("BBYARoleBootstrapApplied",true)
end

local function persist(username,role)
 if not VALID[role] then return false,"INVALID_ROLE" end
 local uid,resolved=exactResolve(username)
 if not uid then
  ReplicatedStorage:SetAttribute(STATUS_PREFIX..username,"RESOLVE_FAILED")
  warn("[BBYA Roles] exact username resolution failed",username)
  return false,"RESOLVE_FAILED"
 end
 local ok,err=pcall(function()
  ROLE_STORE:UpdateAsync("u_"..tostring(uid),function()return role end)
 end)
 if not ok then
  ReplicatedStorage:SetAttribute(STATUS_PREFIX..username,"STORE_FAILED")
  warn("[BBYA Roles] persistence failed",username,uid,err)
  return false,"STORE_FAILED"
 end
 ReplicatedStorage:SetAttribute(STATUS_PREFIX..username,"RESOLVED_"..tostring(uid).."_"..role)
 applyOnline(uid,role)
 print("[BBYA Roles] assigned",resolved,uid,role)
 return true
end

task.spawn(function()
 local pass=0
 for _,req in ipairs(REQUESTS) do if persist(req.username,req.role) then pass+=1 end end
 ReplicatedStorage:SetAttribute("BBYARoleBootstrapResolvedCount",pass)
 ReplicatedStorage:SetAttribute("BBYARoleBootstrapComplete",pass==#REQUESTS)
end)

Players.PlayerAdded:Connect(function(player)
 for _,req in ipairs(REQUESTS) do
  if string.lower(player.Name)==string.lower(req.username) then
   task.defer(function()
    local uid=select(1,exactResolve(req.username))
    if uid==player.UserId then
     local ok,stored=pcall(function()return ROLE_STORE:GetAsync("u_"..tostring(uid))end)
     if ok and stored==req.role then applyOnline(uid,req.role) end
    end
   end)
   break
  end
 end
end)

print("[BBYA] role assignment bootstrap v1 online: exact username resolver / no guessed UserIds")