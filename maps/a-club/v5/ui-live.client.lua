-- [UI-LIVE] BBYA V5 UNIFIED LIVE PANELS
local MarketplaceService=game:GetService("MarketplaceService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local v5Remotes=ReplicatedStorage:WaitForChild("BBYA_V5_Remotes",20)
if not v5Remotes then return end
local DanceR=v5Remotes:WaitForChild("Dance");local SyncR=v5Remotes:WaitForChild("SyncDance");local FXR=v5Remotes:WaitForChild("FX")
local MusicR=v5Remotes:WaitForChild("MusicControl");local MusicS=v5Remotes:WaitForChild("MusicState");local NoticeR=v5Remotes:WaitForChild("Notice")
local LiftR=v5Remotes:WaitForChild("LiftTravel");local VenueR=v5Remotes:WaitForChild("VenueControl")
local boardFn=v5Remotes:FindFirstChild("SupportBoard")
local moneyCfg=ReplicatedStorage:WaitForChild("BBYA_V5_Monetization",20)

NoticeR.OnClientEvent:Connect(function(msg) notify(tostring(msg)) end)

local function liveSurface(panel)
 local f=Instance.new("Frame");f.Name="LiveSurface";f.BackgroundColor3=BG;f.BorderSizePixel=0;f.Position=UDim2.fromOffset(10,52);f.Size=UDim2.new(1,-20,1,-62);f.ZIndex=24;f.Parent=panel;corner(f,12);return f
end
local function section(parent,title,y,color)
 local t=text(parent,title,UDim2.new(1,-20,0,24),UDim2.fromOffset(10,y),13,color or WHITE,true);t.ZIndex=26;return t
end
local function smallButton(parent,value,pos,size,accent)
 local b=button(parent,value,accent);b.Position=pos;b.Size=size;b.ZIndex=27;return b
end

-- DANCE -------------------------------------------------------
local d=liveSurface(danceP);section(d,"QUICK DANCE",8,PINK)
local emotes={{"BBYA VIBES","dance"},{"NEON GROOVE","dance2"},{"MIDNIGHT FLOW","dance3"},{"WAVE","wave"},{"HYPE","cheer"},{"GOOD VIBES","laugh"}}
for i,item in ipairs(emotes) do
 local col=(i-1)%2;local row=math.floor((i-1)/2)
 local b=smallButton(d,item[1],UDim2.new(col*.5,10+col*4,0,40+row*48),UDim2.new(.5,-16,0,40),i<=3 and PINK or CYAN)
 b.Activated:Connect(function() DanceR:FireServer(item[2]) end)
end
local stop=smallButton(d,"STOP",UDim2.new(0,10,0,190),UDim2.new(.3,-4,0,40),WHITE);stop.Activated:Connect(function() DanceR:FireServer("stop") end)
local sync=smallButton(d,"SYNC NEAR",UDim2.new(.3,10,0,190),UDim2.new(.35,-4,0,40),CYAN)
sync.Activated:Connect(function()
 local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart");if not hrp then return end
 local best,dist;for _,p in ipairs(Players:GetPlayers()) do if p~=player then local r=p.Character and p.Character:FindFirstChild("HumanoidRootPart");if r then local m=(r.Position-hrp.Position).Magnitude;if m<=35 and (not dist or m<dist) then best,dist=p,m end end end end
 if best then SyncR:FireServer(best.UserId) else notify("No dancer nearby") end
end)
local conf=smallButton(d,"CONFETTI",UDim2.new(.65,10,0,190),UDim2.new(.35,-20,0,40),PINK);conf.Activated:Connect(function() FXR:FireServer("confetti") end)
local autoOn=false;local autoToken=0
local auto=smallButton(d,"AUTO OFF",UDim2.new(0,10,0,240),UDim2.new(1,-20,0,42),GOLD)
auto.Activated:Connect(function()
 autoOn=not autoOn;auto.Text=autoOn and "AUTO ON" or "AUTO OFF";autoToken+=1;local token=autoToken
 if autoOn then task.spawn(function() local seq={"dance","dance2","dance3"};local n=1;while autoOn and token==autoToken do DanceR:FireServer(seq[n]);n=n%#seq+1;task.wait(12) end end) end
end)

-- VIP ---------------------------------------------------------
local v=liveSurface(vipP);section(v,"VIP ACCESS",8,GOLD)
local vipStatus=text(v,"Checking VIP...",UDim2.new(1,-20,0,34),UDim2.fromOffset(10,42),16,WHITE,true);vipStatus.ZIndex=26
text(v,"VIP unlocks premium access when a real Game Pass is configured. BBYA Queen keeps all-access.",UDim2.new(1,-20,0,64),UDim2.fromOffset(10,80),11,MUTED,false).ZIndex=26
local vipBuy=smallButton(v,"VIP PASS • PENDING",UDim2.new(0,10,0,150),UDim2.new(1,-20,0,46),GOLD)
local vipId=moneyCfg and moneyCfg:FindFirstChild("VIPGamePassId")
local function refreshVIP()
 local owned=player:GetAttribute("IsVIP")==true or player:GetAttribute("BBYAAllAccess")==true
 vipStatus.Text=owned and "VIP ACTIVE" or ((vipId and vipId.Value>0) and "VIP AVAILABLE" or "VIP PREVIEW • PASS PENDING")
 vipBuy.Text=owned and "VIP ACTIVE" or ((vipId and vipId.Value>0) and "BUY VIP" or "VIP PASS • PENDING")
end
vipBuy.Activated:Connect(function() if player:GetAttribute("IsVIP")==true then return end;if vipId and vipId.Value>0 then MarketplaceService:PromptGamePassPurchase(player,vipId.Value) else notify("VIP Game Pass ID belum dipasang") end end)
player:GetAttributeChangedSignal("IsVIP"):Connect(refreshVIP);refreshVIP()

-- PHOTO -------------------------------------------------------
local ph=liveSurface(photoP);section(ph,"PHOTO / VIEW",8,CYAN)
text(ph,"Pose cepat + akses ke rooftop D6.",UDim2.new(1,-20,0,30),UDim2.fromOffset(10,38),11,MUTED,false).ZIndex=26
for i,item in ipairs({{"WAVE","wave"},{"POINT","point"},{"HYPE","cheer"}}) do
 local b=smallButton(ph,item[1],UDim2.new((i-1)/3,10,0,82),UDim2.new(1/3,-14,0,44),CYAN);b.Activated:Connect(function() DanceR:FireServer(item[2]) end)
end
local goPhoto=smallButton(ph,"GO D6 • PHOTO DECK",UDim2.new(0,10,0,142),UDim2.new(1,-20,0,44),PINK)
goPhoto.Activated:Connect(function() local r=ReplicatedStorage:FindFirstChild("BBYA_V5_InspectionNav");if r then r:FireServer("D6") end end)

-- MUSIC -------------------------------------------------------
local m=liveSurface(musicP);section(m,"HYBRID AUTO-DJ",8,PINK)
local now=text(m,"BBYA 24/7",UDim2.new(1,-20,0,48),UDim2.fromOffset(10,36),16,WHITE,true);now.ZIndex=26
local meta=text(m,"AUTO-DJ • ALL",UDim2.new(1,-20,0,26),UDim2.fromOffset(10,80),11,MUTED,false);meta.ZIndex=26
local play=smallButton(m,"PLAY",UDim2.new(0,10,0,116),UDim2.new(.25,-6,0,42),PINK);play.Activated:Connect(function() MusicR:FireServer("PLAY") end)
local pause=smallButton(m,"PAUSE",UDim2.new(.25,6,0,116),UDim2.new(.25,-6,0,42),WHITE);pause.Activated:Connect(function() MusicR:FireServer("PAUSE") end)
local nextB=smallButton(m,"NEXT",UDim2.new(.5,2,0,116),UDim2.new(.25,-6,0,42),CYAN);nextB.Activated:Connect(function() MusicR:FireServer("NEXT") end)
local vol=.58
local volB=smallButton(m,"VOL 58%",UDim2.new(.75,-2,0,116),UDim2.new(.25,-8,0,42),GOLD);volB.Activated:Connect(function() vol=vol>=.9 and .3 or vol+.1;MusicR:FireServer("VOLUME",vol);volB.Text="VOL "..math.floor(vol*100).."%" end)
for i,mode in ipairs({"ALL","INDO","INTL"}) do local b=smallButton(m,mode,UDim2.new((i-1)/3,10,0,174),UDim2.new(1/3,-14,0,40),i==2 and PINK or CYAN);b.Activated:Connect(function() MusicR:FireServer("MODE",mode) end) end
local subs={"BREAKBEAT","FUNKOT","INDO_BOUNCE","KOPLO","HOUSE","TECHNO","DNB"};local subIndex=1
local subB=smallButton(m,"SUB • BREAKBEAT",UDim2.new(0,10,0,230),UDim2.new(1,-20,0,42),PINK);subB.Activated:Connect(function() subIndex=subIndex%#subs+1;subB.Text="SUB • "..subs[subIndex];MusicR:FireServer("SUBGENRE",subs[subIndex]) end)
MusicS.OnClientEvent:Connect(function(s) now.Text=s.title or "BBYA 24/7";meta.Text=(s.dj or "AUTO-DJ").." • "..(s.sub or s.mode or "ALL");if s.volume then vol=s.volume;volB.Text="VOL "..math.floor(vol*100).."%" end end)

-- SAWER -------------------------------------------------------
local sw=liveSurface(sawerP);section(sw,"SAWER / SUPPORT",8,PINK)
local donated=text(sw,"TOTAL KAMU • R$"..tostring(player:GetAttribute("TotalDonated") or 0),UDim2.new(1,-20,0,34),UDim2.fromOffset(10,38),14,WHITE,true);donated.ZIndex=26
local amounts={5,10,50,100,500}
for i,amount in ipairs(amounts) do
 local idv=moneyCfg and moneyCfg:FindFirstChild("Support_"..amount);local col=(i-1)%3;local row=math.floor((i-1)/3)
 local b=smallButton(sw,"R$"..amount..((idv and idv.Value>0) and "" or "\nPENDING"),UDim2.new(col/3,10,0,82+row*58),UDim2.new(1/3,-14,0,50),PINK)
 b.Activated:Connect(function() if idv and idv.Value>0 then MarketplaceService:PromptProductPurchase(player,idv.Value) else notify("Developer Product R$"..amount.." belum dipasang") end end)
end
local board=text(sw,"TOP SUPPORTERS\nLoading...",UDim2.new(1,-20,0,100),UDim2.fromOffset(10,202),11,MUTED,false);board.ZIndex=26
local function loadBoard()
 donated.Text="TOTAL KAMU • R$"..tostring(player:GetAttribute("TotalDonated") or 0)
 if not boardFn then board.Text="TOP SUPPORTERS\nBelum tersedia";return end
 local ok,rows=pcall(function() return boardFn:InvokeServer() end);if not ok or #rows==0 then board.Text="TOP SUPPORTERS\nBelum ada data";return end
 local lines={"TOP SUPPORTERS"};for i,row in ipairs(rows) do table.insert(lines,string.format("#%d  %s  •  R$%d",i,row.name,row.total)) end;board.Text=table.concat(lines,"\n")
end
sawerP:GetPropertyChangedSignal("Visible"):Connect(function() if sawerP.Visible then task.spawn(loadBoard) end end);player:GetAttributeChangedSignal("TotalDonated"):Connect(loadBoard)

-- PROFILE -----------------------------------------------------
local pr=liveSurface(profileP);section(pr,"YOUR BBYA PROFILE",8,CYAN)
local avatar=Instance.new("ImageLabel");avatar.BackgroundColor3=CARD2;avatar.Position=UDim2.fromOffset(10,42);avatar.Size=UDim2.fromOffset(72,72);avatar.ZIndex=26;avatar.Parent=pr;corner(avatar,36)
task.spawn(function() local ok,img=pcall(function() return Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) end);if ok then avatar.Image=img end end)
local profileText=text(pr,"",UDim2.new(1,-104,0,90),UDim2.fromOffset(94,40),13,WHITE,true);profileText.ZIndex=26
local function refreshProfile()
 local level=player:GetAttribute("BBYALevel") or 1;local total=player:GetAttribute("TotalDonated") or 0;local role=player:GetAttribute("BBYARole") or "GUEST";profileText.Text=player.DisplayName.."\n"..role.."\nLEVEL "..level.."  •  SUPPORT R$"..total
end
for _,a in ipairs({"BBYALevel","TotalDonated","BBYARole"}) do player:GetAttributeChangedSignal(a):Connect(refreshProfile) end;refreshProfile()

-- SETTINGS ----------------------------------------------------
local st=liveSurface(settingsP);section(st,"UI / PERFORMANCE",8,GOLD)
local lowFX=false
local fxB=smallButton(st,"LOW FX • OFF",UDim2.new(0,10,0,48),UDim2.new(1,-20,0,44),CYAN)
local function applyFX()
 lowFX=not lowFX;fxB.Text=lowFX and "LOW FX • ON" or "LOW FX • OFF"
 for _,x in ipairs(workspace:GetDescendants()) do if x:IsA("PointLight") and x.Name=="BBYA Decorative Light" then x.Enabled=not lowFX end end
 local bloom=game:GetService("Lighting"):FindFirstChild("BBYA V5 Bloom");if bloom then bloom.Enabled=not lowFX end
end
fxB.Activated:Connect(applyFX)
local park=smallButton(st,"PARK ALL UI",UDim2.new(0,10,0,108),UDim2.new(1,-20,0,44),PINK);park.Activated:Connect(function() if collapse then collapse("TOP");collapse("LEFT");collapse("RIGHT") end;settingsP.Visible=false end)
if player.UserId==4271188557 then
 local party=smallButton(st,"QUEEN • PARTY MODE",UDim2.new(0,10,0,168),UDim2.new(1,-20,0,44),GOLD);local on=false;party.Activated:Connect(function() on=not on;VenueR:FireServer(on and "PARTY" or "NORMAL");party.Text=on and "QUEEN • NIGHT MODE" or "QUEEN • PARTY MODE" end)
end

player:SetAttribute("BBYAUILiveSystems","5.0")
