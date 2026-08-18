-- [SYS-VENUE] CROWD / PARTY STATE / SUPPORT STAGE FEEDBACK
local VenueRemote=sysRemote("VenueControl")
if workspace:GetAttribute("BBYAPartyMode")==nil then workspace:SetAttribute("BBYAPartyMode",false) end

VenueRemote.OnServerEvent:Connect(function(p,action,value)
 if p.UserId~=QUEEN_ID and p:GetAttribute("BBYARole")~="ADMIN" then return end
 action=string.upper(tostring(action or ""))
 if action=="PARTY" then workspace:SetAttribute("BBYAPartyMode",true);NoticeRemote:FireAllClients("BBYA PARTY MODE ON")
 elseif action=="NORMAL" then workspace:SetAttribute("BBYAPartyMode",false);NoticeRemote:FireAllClients("BBYA NIGHT MODE")
 elseif action=="ANNOUNCE" then local msg=string.sub(tostring(value or ""):gsub("[%c]"," "),1,100);if msg~="" then NoticeRemote:FireAllClients(msg) end end
end)

-- Count real players in A4 bounds; never fake NPC crowd numbers.
task.spawn(function()
 while task.wait(2) do
  local n=0
  for _,p in ipairs(Players:GetPlayers()) do
   local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
   if hrp then local q=hrp.Position;if math.abs(q.X)<=54 and q.Z>=-62 and q.Z<=84 and q.Y>=0 and q.Y<=18 then n+=1 end end
  end
  local intensity=n>=10 and 3 or (n>=5 and 2 or (n>=2 and 1 or 0))
  workspace:SetAttribute("BBYARealCrowdCount",n);workspace:SetAttribute("BBYACrowdIntensity",intensity)
 end
end)

-- Support message surface on the A4 LED wall.
task.spawn(function()
 local wall=workspace:FindFirstChild("A4 | MAIN LED WALL",true);if not wall then return end
 local old=wall:FindFirstChild("BBYA Support Overlay");if old then old:Destroy() end
 local g=Instance.new("SurfaceGui");g.Name="BBYA Support Overlay";g.Face=Enum.NormalId.Back;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=18;g.LightInfluence=0;g.Parent=wall
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Size=UDim2.new(1,-20,0,50);t.Position=UDim2.new(0,10,1,-56);t.Font=Enum.Font.GothamBold;t.TextScaled=true;t.TextColor3=Color3.fromRGB(255,194,72);t.Text="SUPPORT THE NIGHT • BBYA";t.Parent=g
 local function refresh()
  local name=workspace:GetAttribute("BBYALastSupporter");local amount=workspace:GetAttribute("BBYALastSupportAmount")
  if name and tonumber(amount) and amount>0 then t.Text=string.upper(tostring(name)).." • R$"..tostring(amount).." • THANK YOU" end
 end
 workspace:GetAttributeChangedSignal("BBYALastSupportAmount"):Connect(refresh);refresh()
end)
workspace:SetAttribute("BBYASystemVenue","5.0")
