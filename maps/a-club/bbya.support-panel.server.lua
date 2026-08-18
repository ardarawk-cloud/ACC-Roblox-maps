-- BBYA Top Supporter panel data service v1.0
local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local remotes=ReplicatedStorage:FindFirstChild("BBYA_Remotes") or Instance.new("Folder")
remotes.Name="BBYA_Remotes";remotes.Parent=ReplicatedStorage
local rf=remotes:FindFirstChild("GetSupporterData") or Instance.new("RemoteFunction")
rf.Name="GetSupporterData";rf.Parent=remotes

local store=DataStoreService:GetOrderedDataStore("BBYA_TopSupporters_v1")
local cache={time=0,data={}}
local busy=false

local function getRank(player)
 local level=player:GetAttribute("BBYALevel") or 1
 local donated=player:GetAttribute("TotalDonated") or 0
 if level>=25 and donated>=1000 then return "ROYAL ELITE" end
 if level>=15 and donated>=500 then return "NIGHT ARISTOCRAT" end
 if level>=8 and donated>=100 then return "ARISTOCRAT" end
 if level>=20 then return "NIGHT ICON" end
 if level>=8 then return "SOCIALITE" end
 if level>=3 then return "REGULAR" end
 return "NEWBIE"
end

local function refresh()
 if os.clock()-cache.time<30 then return cache.data end
 if busy then return cache.data end
 busy=true
 local out={}
 local ok,pages=pcall(function()return store:GetSortedAsync(false,10)end)
 if ok then
  for rank,entry in ipairs(pages:GetCurrentPage()) do
   local uid=tonumber(string.match(tostring(entry.key),"(%d+)$")) or tonumber(entry.key)
   local name="User "..tostring(uid or "?")
   if uid then pcall(function()name=Players:GetNameFromUserIdAsync(uid)end) end
   table.insert(out,{rank=rank,userId=uid or 0,name=name,amount=entry.value or 0})
  end
  cache={time=os.clock(),data=out}
 end
 busy=false
 return cache.data
end

rf.OnServerInvoke=function(player)
 local rows=refresh()
 return {
  rows=rows,
  self={
   rankTitle=getRank(player),
   level=player:GetAttribute("BBYALevel") or 1,
   donated=player:GetAttribute("TotalDonated") or 0,
  }
 }
end

print("[BBYA] Top Supporter data service loaded")