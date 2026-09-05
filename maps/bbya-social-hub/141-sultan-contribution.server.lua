-- BBYA SOCIAL HUB — CONTRIBUTION ADAPTER v2
-- 1) Bridges verified SULTAN CORE ownership into the existing Top 3 donor ledger.
-- 2) Receives Saweria alerts through a secure MessagingService topic.
-- No Saweria token / stream key / API secret is stored in this repository.
-- External publisher must publish sanitized donation payloads to BBYA_SAWERIA_DONATIONS_V1.

local Players=game:GetService("Players")
local MarketplaceService=game:GetService("MarketplaceService")
local MessagingService=game:GetService("MessagingService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local HttpService=game:GetService("HttpService")

local SULTAN_PASS_ID=1490269572
local SULTAN_PRICE=10000
local SAWERIA_TOPIC="BBYA_SAWERIA_DONATIONS_V1"
local MAX_ALERT_AMOUNT=1000000000
local seenDonationIds={}

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local sawAlert=remotes:FindFirstChild("SaweriaDonationAlert")
if sawAlert and not sawAlert:IsA("RemoteEvent") then sawAlert:Destroy();sawAlert=nil end
if not sawAlert then sawAlert=Instance.new("RemoteEvent");sawAlert.Name="SaweriaDonationAlert";sawAlert.Parent=remotes end

local function apply(player)
 if not player or not player.Parent then return end
 local ok,owned=pcall(function()
  return MarketplaceService:UserOwnsGamePassAsync(player.UserId,SULTAN_PASS_ID)
 end)
 if not player.Parent then return end
 player:SetAttribute("BBYASultanPassId",SULTAN_PASS_ID)
 player:SetAttribute("BBYASultanPassPrice",SULTAN_PRICE)
 player:SetAttribute("BBYASultanOwnershipVerified",ok==true)
 if ok and owned==true then
  player:SetAttribute("BBYASultanPassOwned",true)
  player:SetAttribute("BBYASultanContributionRobux",SULTAN_PRICE)
 else
  player:SetAttribute("BBYASultanPassOwned",false)
  player:SetAttribute("BBYASultanContributionRobux",0)
 end
end

local function verifyWithRetry(player)
 for attempt=1,3 do
  apply(player)
  if player:GetAttribute("BBYASultanOwnershipVerified")==true then return end
  task.wait(attempt)
 end
end

local function trimText(value,maxLen,fallback)
 local s=tostring(value or fallback or "")
 s=s:gsub("[%c]"," "):gsub("%s+"," "):gsub("^%s+",""):gsub("%s+$","")
 if s=="" then s=fallback or "" end
 if utf8.len(s) and utf8.len(s)>maxLen then
  local out="";local n=0
  for _,cp in utf8.codes(s) do if n>=maxLen then break end;n+=1;out=out..utf8.char(cp) end
  s=out
 end
 return s
end

local function decodePayload(raw)
 if type(raw)=="table" then return raw end
 if type(raw)~="string" or raw=="" then return nil end
 local ok,data=pcall(function()return HttpService:JSONDecode(raw)end)
 return ok and type(data)=="table" and data or nil
end

local function normalizeSaweria(raw)
 local data=decodePayload(raw)
 if not data then return nil end
 local amount=tonumber(data.amount or data.amount_raw or data.nominal)
 if not amount then return nil end
 amount=math.floor(amount)
 if amount<=0 or amount>MAX_ALERT_AMOUNT then return nil end
 local donationId=trimText(data.id or data.donationId or data.transactionId,80,"")
 local name=trimText(data.name or data.displayName or data.donator_name,36,"SAWERIA SUPPORTER")
 local message=trimText(data.message or data.note or data.donator_message,120,"")
 return {id=donationId,name=name,amount=amount,message=message,currency="IDR",source="SAWERIA"}
end

local function acceptSaweria(raw)
 local data=normalizeSaweria(raw)
 if not data then return end
 if data.id~="" then
  local now=os.clock();local previous=seenDonationIds[data.id]
  if previous and now-previous<600 then return end
  seenDonationIds[data.id]=now
 end
 sawAlert:FireAllClients(data)
 ReplicatedStorage:SetAttribute("BBYASaweriaLastAmount",data.amount)
 ReplicatedStorage:SetAttribute("BBYASaweriaLastName",data.name)
 ReplicatedStorage:SetAttribute("BBYASaweriaLastAlertAt",os.time())
end

for _,player in ipairs(Players:GetPlayers()) do task.spawn(verifyWithRetry,player) end
Players.PlayerAdded:Connect(function(player)task.spawn(verifyWithRetry,player)end)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player,passId,purchased)
 if tonumber(passId)~=SULTAN_PASS_ID or purchased~=true then return end
 task.delay(.5,function()if player and player.Parent then verifyWithRetry(player)end end)
end)

local ok,sub=pcall(function()
 return MessagingService:SubscribeAsync(SAWERIA_TOPIC,function(message)
  acceptSaweria(message and message.Data)
 end)
end)
if ok and sub then
 ReplicatedStorage:SetAttribute("BBYASaweriaBridgeState","SUBSCRIBED")
 ReplicatedStorage:SetAttribute("BBYASaweriaBridgeTopic",SAWERIA_TOPIC)
else
 ReplicatedStorage:SetAttribute("BBYASaweriaBridgeState","SUBSCRIBE_FAILED")
 warn("[BBYA] Saweria MessagingService bridge could not subscribe")
end

print("[BBYA] Contribution adapter v2 online: SULTAN ownership + secure Saweria MessagingService alert bridge / no secret in repo")