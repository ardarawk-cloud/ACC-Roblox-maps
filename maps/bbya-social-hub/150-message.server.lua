-- BBYA SOCIAL HUB — MESSAGE + MONETIZATION AUTHORITY v8 CLEAN REBUILD
-- New authority after MESSAGE QC fail #3. Exact verified Developer Product IDs preserved.
-- One queue, one filter path, one ProcessReceipt owner. Support products remain supported here.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")
local TextService=game:GetService("TextService")
local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30);if not root then return end
local old=root:FindFirstChild("DJWallMessageSystem");if old then old:Destroy()end
local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes");if not remotes then remotes=Instance.new("Folder");remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage end
local messageRemote=remotes:FindFirstChild("DJWall");if messageRemote and not messageRemote:IsA("RemoteEvent")then messageRemote:Destroy();messageRemote=nil end;if not messageRemote then messageRemote=Instance.new("RemoteEvent");messageRemote.Name="DJWall";messageRemote.Parent=remotes end
local stateRemote=remotes:FindFirstChild("State");if not stateRemote then stateRemote=Instance.new("RemoteEvent");stateRemote.Name="State";stateRemote.Parent=remotes end
local moneyRemote=remotes:FindFirstChild("Monetization");if not moneyRemote then moneyRemote=Instance.new("RemoteEvent");moneyRemote.Name="Monetization";moneyRemote.Parent=remotes end

local MESSAGE_IDS={[2]=3709047092,[5]=3711399029,[10]=3711399032,[25]=3711399033,[50]=3711399036,[100]=3711399038,[250]=3711399041,[500]=3711399044,[1000]=3711399047}
local SUPPORT_IDS={[10]=3709047095,[25]=3709047097,[50]=3709047101,[100]=3709047104,[250]=3709047106,[500]=3709047107,[1000]=3709047109,[2000]=3709048779}
local MESSAGE_AMOUNTS={2,5,10,25,50,100,250,500,1000}
local SUPPORT_AMOUNTS={10,25,50,100,250,500,1000,2000}
local MESSAGE_BY_PRODUCT,SUPPORT_BY_PRODUCT={},{};for a,id in pairs(MESSAGE_IDS)do MESSAGE_BY_PRODUCT[id]=a end;for a,id in pairs(SUPPORT_IDS)do SUPPORT_BY_PRODUCT[id]=a end
root:SetAttribute("BBYAMonetizationAuthority","MESSAGE_V8_CLEAN_REBUILD");root:SetAttribute("BBYAVerifiedProductIdsAuthoritative",true)

-- Keep the same physical wall contract used by render/mount helpers.
local model=Instance.new("Model");model.Name="DJWallMessageSystem";model:SetAttribute("Pass","MESSAGE_V8_CLEAN_REBUILD");model.Parent=root
local function part(n,size,cf,color,mat,tr)local p=Instance.new("Part");p.Name=n;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=mat or Enum.Material.Metal;p.Transparency=tr or 0;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=true;p.CastShadow=false;p.Parent=model;return p end
local black=Color3.fromRGB(5,5,8);local pink=Color3.fromRGB(255,38,155);local cyan=Color3.fromRGB(0,210,238);local white=Color3.fromRGB(244,242,247);local gold=Color3.fromRGB(238,190,94);local muted=Color3.fromRGB(164,157,171)
local wallCF=CFrame.new(3,10,46.34);part("WallRecess",Vector3.new(58.5,14.1,.32),wallCF*CFrame.new(0,0,.15),Color3.fromRGB(4,4,6),Enum.Material.Metal,0);local screen=part("PrestigeLED",Vector3.new(56.8,12.6,.12),wallCF*CFrame.new(0,0,-.10),Color3.fromRGB(7,6,10),Enum.Material.Glass,.02);part("TopTrim",Vector3.new(56.9,.10,.10),wallCF*CFrame.new(0,6.34,-.18),pink,Enum.Material.Neon,0);part("BottomTrim",Vector3.new(56.9,.08,.10),wallCF*CFrame.new(0,-6.34,-.18),cyan,Enum.Material.Neon,0)
local sg=Instance.new("SurfaceGui");sg.Name="DJWallUI";sg.Face=Enum.NormalId.Front;sg.PixelsPerStud=55;sg.Parent=screen;local bg=Instance.new("Frame");bg.Size=UDim2.fromScale(1,1);bg.BackgroundColor3=black;bg.BorderSizePixel=0;bg.Parent=sg
local function lab(p,t,pos,size,font,ts,col,align)local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=t;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 18;l.TextColor3=col or white;l.TextWrapped=true;l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.Parent=p;return l end
local idle=Instance.new("Frame");idle.Size=UDim2.fromScale(1,1);idle.BackgroundTransparency=1;idle.Parent=bg;lab(idle,"BBYA",UDim2.fromScale(.04,.05),UDim2.fromScale(.20,.10),Enum.Font.GothamBlack,42,white);lab(idle,"MESSAGE • LIVE VISUALS",UDim2.fromScale(.27,.33),UDim2.fromScale(.46,.10),Enum.Font.GothamBlack,42,pink,Enum.TextXAlignment.Center);lab(idle,"COMMUNITY • 24/7",UDim2.fromScale(.30,.46),UDim2.fromScale(.40,.06),Enum.Font.GothamBold,18,muted,Enum.TextXAlignment.Center)
local liveFrame=Instance.new("Frame");liveFrame.Size=UDim2.fromScale(1,1);liveFrame.BackgroundColor3=Color3.fromRGB(8,7,11);liveFrame.Visible=false;liveFrame.Parent=bg;local badge=lab(liveFrame,"BBYA LIVE MESSAGE",UDim2.fromScale(.06,.08),UDim2.fromScale(.88,.08),Enum.Font.GothamBlack,28,pink,Enum.TextXAlignment.Center);local msg=lab(liveFrame,"",UDim2.fromScale(.08,.25),UDim2.fromScale(.84,.38),Enum.Font.GothamBlack,48,white,Enum.TextXAlignment.Center);local from=lab(liveFrame,"",UDim2.fromScale(.10,.69),UDim2.fromScale(.80,.08),Enum.Font.GothamBold,22,gold,Enum.TextXAlignment.Center)
local prompt=Instance.new("ProximityPrompt");prompt.Name="CreatePrestigeMessage";prompt.ActionText="Create Message";prompt.ObjectText="BBYA MESSAGE";prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.HoldDuration=0;prompt.MaxActivationDistance=14;prompt.RequiresLineOfSight=false;prompt.Parent=screen

local MAX_CHARS=80;local COOLDOWN=8;local MAX_QUEUE=20;local DISPLAY_SECONDS=9
local CATEGORIES={BIRTHDAY="BIRTHDAY CELEBRATION",LOVE="LOVE MESSAGE",SHOUTOUT="SHOUTOUT",CUSTOM="LIVE MESSAGE"}
local queue,pending,lastSubmit={},{},{};local showing=false
local function admin(p)return p:GetAttribute("BBYAAdmin")==true or p:GetAttribute("BBYAOwner")==true or(game.CreatorType==Enum.CreatorType.User and p.UserId==game.CreatorId)end
local function config(p)local available={};for _,a in ipairs(MESSAGE_AMOUNTS)do available[a]=MESSAGE_IDS[a]~=nil end;return{tiers=MESSAGE_AMOUNTS,available=available,maxChars=MAX_CHARS,queue=#queue,admin=admin(p),cooldownSeconds=COOLDOWN,authority="MESSAGE_V8_CLEAN_REBUILD"}end
local function filter(p,raw)raw=tostring(raw or""):gsub("[%c\r\n]+"," "):gsub("%s+"," "):match("^%s*(.-)%s*$")or"";if #raw<2 then return nil,"Pesan terlalu pendek."end;if #raw>MAX_CHARS then raw=raw:sub(1,MAX_CHARS)end;local ok,out=pcall(function()return TextService:FilterStringAsync(raw,p.UserId):GetNonChatStringForBroadcastAsync()end);if not ok or not out or out==""then return nil,"Pesan tidak dapat difilter."end;return out end
local function enqueue(e)if #queue>=MAX_QUEUE then return false end;table.insert(queue,e);return true end
local function display(e)showing=true;idle.Visible=false;liveFrame.Visible=true;badge.Text="BBYA • "..(CATEGORIES[e.category]or CATEGORIES.CUSTOM);msg.Text=e.text;from.Text="FROM @"..e.from;task.wait(DISPLAY_SECONDS);liveFrame.Visible=false;idle.Visible=true;showing=false end
task.spawn(function()while task.wait(.1)do if not showing and #queue>0 then display(table.remove(queue,1))end end end)
prompt.Triggered:Connect(function(p)messageRemote:FireClient(p,"open",config(p))end)

messageRemote.OnServerEvent:Connect(function(p,action,data)
 if action=="config"then messageRemote:FireClient(p,"config",config(p));return end
 if action~="submit"or type(data)~="table"then return end
 local now=os.clock();local remain=COOLDOWN-(now-(lastSubmit[p.UserId]or 0));if remain>0 and not admin(p)then messageRemote:FireClient(p,"toast","Tunggu "..math.ceil(remain).." detik.");return end;if pending[p.UserId]then messageRemote:FireClient(p,"toast","Selesaikan purchase sebelumnya.");return end;if #queue>=MAX_QUEUE then messageRemote:FireClient(p,"toast","Antrean MESSAGE penuh.");return end
 messageRemote:FireClient(p,"processing",{message="Memeriksa pesan..."});local text,err=filter(p,data.text);if not text then messageRemote:FireClient(p,"toast",err);return end;local category=tostring(data.category or"CUSTOM"):upper();if not CATEGORIES[category]then category="CUSTOM"end;local amount=tonumber(data.amount)or 2;if not MESSAGE_IDS[amount]then messageRemote:FireClient(p,"toast","Tier MESSAGE tidak valid.");return end;lastSubmit[p.UserId]=now;local e={text=text,category=category,from=p.DisplayName,userId=p.UserId,amount=amount}
 if admin(p)then if enqueue(e)then messageRemote:FireClient(p,"queued",{position=#queue,amount=0,adminPreview=true})end;return end
 e.productId=MESSAGE_IDS[amount];pending[p.UserId]=e;messageRemote:FireClient(p,"purchase",{amount=amount,productId=e.productId});local ok=pcall(function()MarketplaceService:PromptProductPurchase(p,e.productId)end);if not ok then pending[p.UserId]=nil;messageRemote:FireClient(p,"toast","Purchase Roblox gagal dibuka.")end
end)

moneyRemote.OnServerEvent:Connect(function(p,action,value)if action~="promptSupport"then return end;local amount=tonumber(value);local id=amount and SUPPORT_IDS[amount];if not id then moneyRemote:FireClient(p,"status",{amount=amount,ok=false,message="Support belum tersedia."});return end;moneyRemote:FireClient(p,"promptSupportLocal",{amount=amount,productId=id})end)
MarketplaceService.ProcessReceipt=function(receipt)
 local product=tonumber(receipt.ProductId);local ma=MESSAGE_BY_PRODUCT[product];if ma then local e=pending[receipt.PlayerId];if e and e.productId==product then pending[receipt.PlayerId]=nil;if enqueue(e)then local p=Players:GetPlayerByUserId(receipt.PlayerId);if p then messageRemote:FireClient(p,"queued",{position=#queue,amount=ma})end end end;return Enum.ProductPurchaseDecision.PurchaseGranted end
 local sa=SUPPORT_BY_PRODUCT[product];if sa then local p=Players:GetPlayerByUserId(receipt.PlayerId);if p then local total=(tonumber(p:GetAttribute("BBYASupportRobuxTotal"))or 0)+sa;p:SetAttribute("BBYASupportRobuxTotal",total);stateRemote:FireAllClients("supportReceived",{displayName=p.DisplayName,userId=p.UserId,amount=sa,total=total})end;return Enum.ProductPurchaseDecision.PurchaseGranted end
 return Enum.ProductPurchaseDecision.NotProcessedYet
end
Players.PlayerRemoving:Connect(function(p)pending[p.UserId]=nil;lastSubmit[p.UserId]=nil end)
print("[BBYA] MESSAGE v8 clean rebuild online: 80 chars / fast queue / exact product IDs / one receipt authority")