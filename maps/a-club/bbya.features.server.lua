-- BBYA Social Hub v1.8 supporter hall + functional feature stations
local Players=game:GetService("Players")
local Debris=game:GetService("Debris")
local DataStoreService=game:GetService("DataStoreService")

local old=workspace:FindFirstChild("BBYA Feature Stations")
if old then old:Destroy() end
local root=Instance.new("Folder");root.Name="BBYA Feature Stations";root.Parent=workspace
local supporterStore=DataStoreService:GetOrderedDataStore("BBYA_TopSupporters_v1")

local function part(name,size,cf,color,material,transparency)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Transparency=transparency or 0;p.Parent=root;return p
end
local function prompt(p,action,obj)
 local x=Instance.new("ProximityPrompt");x.ActionText=action;x.ObjectText=obj;x.HoldDuration=.15;x.MaxActivationDistance=10;x.RequiresLineOfSight=false;x.Parent=p;return x
end
local function label(p,msg,color)
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=24;g.Parent=p
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Size=UDim2.fromScale(1,1);t.Text=msg;t.TextColor3=color or Color3.new(1,1,1);t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.TextWrapped=true;t.Parent=g
 local limit=Instance.new("UITextSizeConstraint");limit.MinTextSize=10;limit.MaxTextSize=28;limit.Parent=t
 return t
end
local function weldAdornment(char,name,shape,size,offset,color)
 local head=char and char:FindFirstChild("Head");if not head then return end
 local prior=char:FindFirstChild(name);if prior then prior:Destroy() end
 local a=Instance.new("Part");a.Name=name;a.Shape=shape or Enum.PartType.Block;a.Size=size;a.Color=color;a.Material=Enum.Material.Neon;a.CanCollide=false;a.Massless=true;a.CFrame=head.CFrame*offset;a.Parent=char
 local w=Instance.new("WeldConstraint");w.Part0=head;w.Part1=a;w.Parent=a
end

-- SALON KIT
local salon=part("BBYA Salon Counter",Vector3.new(15,3.5,5),CFrame.new(69,2.75,18),Color3.fromRGB(34,20,48),Enum.Material.Marble)
local salonSign=part("BBYA Salon Sign",Vector3.new(13,2,.35),CFrame.new(69,5.8,15.4),Color3.fromRGB(20,8,30),Enum.Material.SmoothPlastic)
label(salonSign,"BBYA SALON",Color3.fromRGB(255,100,220))
local looks={{"NEON HALO",function(c)weldAdornment(c,"BBYA Salon Look",Enum.PartType.Cylinder,Vector3.new(.35,4.2,4.2),CFrame.new(0,1.9,0)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(255,70,210))end},{"CYAN CROWN",function(c)weldAdornment(c,"BBYA Salon Look",Enum.PartType.Block,Vector3.new(2.8,.45,2.8),CFrame.new(0,1.55,0),Color3.fromRGB(55,210,255))end},{"GOLD ICON",function(c)weldAdornment(c,"BBYA Salon Look",Enum.PartType.Ball,Vector3.new(.65,.65,.65),CFrame.new(0,1.75,0),Color3.fromRGB(255,205,80))end}}
local styleIndex={}
prompt(salon,"STYLE ME","Salon Kit").Triggered:Connect(function(plr)local c=plr.Character;if not c then return end;local i=(styleIndex[plr.UserId]or 0)%#looks+1;styleIndex[plr.UserId]=i;looks[i][2](c);plr:SetAttribute("BBYASalonLook",looks[i][1])end)
local resetPad=part("Salon Reset",Vector3.new(4,.3,4),CFrame.new(78,1,18),Color3.fromRGB(90,45,110),Enum.Material.Neon,.2)
prompt(resetPad,"RESET","Salon Look").Triggered:Connect(function(plr)local c=plr.Character;local a=c and c:FindFirstChild("BBYA Salon Look");if a then a:Destroy()end;plr:SetAttribute("BBYASalonLook","")end)

-- SUPPORTER HALL
local board=part("Top Supporters Board",Vector3.new(28,14,.7),CFrame.new(-73,8,28)*CFrame.Angles(0,math.rad(-90),0),Color3.fromRGB(14,10,22),Enum.Material.SmoothPlastic)
local sg=Instance.new("SurfaceGui");sg.Face=Enum.NormalId.Front;sg.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;sg.PixelsPerStud=28;sg.Parent=board
local title=Instance.new("TextLabel");title.BackgroundTransparency=1;title.Size=UDim2.new(1,-20,0,48);title.Position=UDim2.fromOffset(10,8);title.Text="BBYA TOP SUPPORTERS";title.TextColor3=Color3.fromRGB(255,215,90);title.Font=Enum.Font.GothamBlack;title.TextSize=25;title.Parent=sg
local rows=Instance.new("TextLabel");rows.BackgroundTransparency=1;rows.Size=UDim2.new(.46,-10,1,-68);rows.Position=UDim2.fromOffset(10,58);rows.Text="Waiting for supporters...";rows.TextColor3=Color3.fromRGB(245,235,255);rows.TextXAlignment=Enum.TextXAlignment.Left;rows.TextYAlignment=Enum.TextYAlignment.Top;rows.Font=Enum.Font.GothamBold;rows.TextSize=20;rows.TextWrapped=true;rows.Parent=sg
local podium=Instance.new("Frame");podium.BackgroundTransparency=1;podium.Size=UDim2.new(.52,-10,1,-68);podium.Position=UDim2.new(.48,0,0,58);podium.Parent=sg
local slots={}
for i=1,3 do local slot=Instance.new("Frame");slot.Name="Top"..i;slot.Size=UDim2.new(1,0,.31,0);slot.Position=UDim2.new(0,0,(i-1)*.34,0);slot.BackgroundColor3=Color3.fromRGB(28,20,38);slot.BackgroundTransparency=.12;slot.Parent=podium;Instance.new("UICorner",slot).CornerRadius=UDim.new(0,10);local img=Instance.new("ImageLabel");img.Name="Avatar";img.Size=UDim2.fromOffset(72,72);img.Position=UDim2.fromOffset(8,6);img.BackgroundColor3=Color3.fromRGB(40,30,52);img.Parent=slot;Instance.new("UICorner",img).CornerRadius=UDim.new(1,0);local txt=Instance.new("TextLabel");txt.Name="Info";txt.BackgroundTransparency=1;txt.Size=UDim2.new(1,-92,1,-8);txt.Position=UDim2.fromOffset(88,4);txt.Text="#"..i.." —";txt.TextColor3=i==1 and Color3.fromRGB(255,220,90)or i==2 and Color3.fromRGB(210,220,240)or Color3.fromRGB(220,150,95);txt.Font=Enum.Font.GothamBold;txt.TextSize=18;txt.TextWrapped=true;txt.TextXAlignment=Enum.TextXAlignment.Left;txt.Parent=slot;slots[i]={img=img,txt=txt} end
local function refreshSupporters()
 local ok,pages=pcall(function()return supporterStore:GetSortedAsync(false,10)end);if not ok then rows.Text="Top Supporters\nLoading data...";return end
 local data=pages:GetCurrentPage();local lines={}
 for i=1,math.min(10,#data)do local entry=data[i];local uid=tonumber(string.match(tostring(entry.key),"(%d+)$"))or tonumber(entry.key);local name="User "..tostring(uid);if uid then pcall(function()name=Players:GetNameFromUserIdAsync(uid)end)end;table.insert(lines,string.format("%d. %s  •  R$%d",i,name,entry.value or 0));if i<=3 then slots[i].txt.Text=string.format("#%d\n%s\nR$%d",i,name,entry.value or 0);if uid then local okThumb,url=pcall(function()return Players:GetUserThumbnailAsync(uid,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)end);if okThumb then slots[i].img.Image=url end end end end
 rows.Text=#lines>0 and table.concat(lines,"\n")or"Waiting for supporters...";for i=#data+1,3 do if slots[i]then slots[i].txt.Text="#"..i.."\n—\nR$0";slots[i].img.Image=""end end
end
local lastTotals={}
local function hookPlayer(plr)lastTotals[plr.UserId]=plr:GetAttribute("TotalDonated")or 0;plr:GetAttributeChangedSignal("TotalDonated"):Connect(function()local now=plr:GetAttribute("TotalDonated")or 0;if now~=lastTotals[plr.UserId]then lastTotals[plr.UserId]=now;pcall(function()supporterStore:SetAsync("u"..plr.UserId,now)end);task.defer(refreshSupporters)end end)end
Players.PlayerAdded:Connect(hookPlayer);for _,p in ipairs(Players:GetPlayers())do hookPlayer(p)end
task.spawn(function()task.wait(3);refreshSupporters();while root.Parent do task.wait(60);refreshSupporters()end end)

local donateWall=part("Donate Text Wall",Vector3.new(16,6,.6),CFrame.new(-73,5,48)*CFrame.Angles(0,math.rad(-90),0),Color3.fromRGB(18,12,26),Enum.Material.SmoothPlastic)
local donateText=label(donateWall,"LIVE SUPPORT\nWaiting for donation...",Color3.fromRGB(255,130,220))
local function hookDonate(plr)local before=plr:GetAttribute("TotalDonated")or 0;plr:GetAttributeChangedSignal("TotalDonated"):Connect(function()local now=plr:GetAttribute("TotalDonated")or 0;if now>before then donateText.Text=string.format("THANK YOU %s!\n+R$%d • TOTAL R$%d",plr.DisplayName,now-before,now)end;before=now end)end
for _,p in ipairs(Players:GetPlayers())do hookDonate(p)end;Players.PlayerAdded:Connect(hookDonate)

-- DUO PHOTO: seats must face the backdrop/camera composition, not away from it.
local duoWall=part("Duo Photo Wall",Vector3.new(15,8,.7),CFrame.new(69,5,-31),Color3.fromRGB(45,14,55),Enum.Material.SmoothPlastic)
label(duoWall,"DUO PHOTO ♥",Color3.fromRGB(255,100,220))
local duoStage=part("Duo Photo Stage",Vector3.new(11,.35,5.5),CFrame.new(69,.85,-35.5),Color3.fromRGB(35,20,45),Enum.Material.Marble)
for _,x in ipairs({-2.7,2.7})do
 local s=Instance.new("Seat");s.Name="Duo Photo Seat";s.Size=Vector3.new(2.8,1,2.8)
 -- 180-degree yaw fixes Roblox Seat occupant facing direction.
 s.CFrame=CFrame.new(69+x,1.65,-35.2)*CFrame.Angles(0,math.rad(180),0)
 s.Anchored=true;s.Color=Color3.fromRGB(80,45,95);s.Material=Enum.Material.Fabric;s.Parent=root
end
local marker=part("Duo Camera Marker",Vector3.new(4,.12,2),CFrame.new(69,.7,-43),Color3.fromRGB(255,70,210),Enum.Material.Neon,.45,false)
label(marker,"PHOTO",Color3.new(1,1,1))

local pool=workspace:FindFirstChild("Rooftop Pool")
if pool then local splashPad=part("Pool Splash Pad",Vector3.new(6,.3,6),pool.CFrame*CFrame.new(0,pool.Size.Y/2+.4,0),Color3.fromRGB(50,190,255),Enum.Material.Glass,.55);local splashPrompt=prompt(splashPad,"SPLASH","Pool Party");splashPrompt.Triggered:Connect(function()splashPrompt.Enabled=false;for i=1,20 do local d=Instance.new("Part");d.Shape=Enum.PartType.Ball;d.Size=Vector3.new(.35,.35,.35);d.Material=Enum.Material.Neon;d.Color=Color3.fromRGB(80,210,255);d.CanCollide=false;d.CFrame=splashPad.CFrame*CFrame.new(math.random(-3,3),2,math.random(-3,3));d.Parent=workspace;d.AssemblyLinearVelocity=Vector3.new(math.random(-9,9),math.random(10,20),math.random(-9,9));Debris:AddItem(d,2)end;task.delay(2,function()if splashPrompt.Parent then splashPrompt.Enabled=true end end)end)end
print("[BBYA] feature stations loaded: Duo Photo seat facing corrected 180 degrees")