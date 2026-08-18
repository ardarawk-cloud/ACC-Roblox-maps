-- [SYS-SUPPORT] IN-WORLD TOP SUPPORTERS BOARD
local rootMap=workspace:FindFirstChild("BBYA V5.3 MASTER PLAN")
local a3=rootMap and rootMap:FindFirstChild("[A3] LOBBY / ORIENTATION")
if a3 then
 local boardPart=Instance.new("Part");boardPart.Name="A3 | TOP SUPPORTERS BOARD";boardPart.Size=Vector3.new(.35,9,22);boardPart.CFrame=CFrame.new(-59.65,7,106);boardPart.Anchored=true;boardPart.CanCollide=false;boardPart.CanTouch=false;boardPart.Material=Enum.Material.SmoothPlastic;boardPart.Color=Color3.fromRGB(12,12,18);boardPart:SetAttribute("BBYAZoneCode","A3");boardPart:SetAttribute("BBYAZoneName","LOBBY / ORIENTATION");boardPart.Parent=a3
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Right;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=24;g.LightInfluence=0;g.Parent=boardPart
 local title=Instance.new("TextLabel");title.BackgroundTransparency=1;title.Size=UDim2.new(1,-16,0,52);title.Position=UDim2.fromOffset(8,8);title.Font=Enum.Font.GothamBlack;title.TextScaled=true;title.TextColor3=Color3.fromRGB(255,55,198);title.Text="TOP SUPPORTERS";title.Parent=g
 local body=Instance.new("TextLabel");body.BackgroundTransparency=1;body.Size=UDim2.new(1,-20,1,-72);body.Position=UDim2.fromOffset(10,64);body.Font=Enum.Font.GothamBold;body.TextSize=22;body.TextWrapped=true;body.TextYAlignment=Enum.TextYAlignment.Top;body.TextColor3=Color3.fromRGB(245,243,250);body.Text="BE THE FIRST TO SUPPORT BBYA";body.Parent=g
 local function refresh()
  local ok,pages=pcall(function() return supporterStore:GetSortedAsync(false,5) end);if not ok then body.Text="TOP SUPPORTERS\nDATA TEMPORARILY UNAVAILABLE";return end
  local rows=pages:GetCurrentPage();if #rows==0 then body.Text="BE THE FIRST TO SUPPORT BBYA";return end
  local lines={};for i,item in ipairs(rows) do local uid=tonumber(tostring(item.key):match("u(%d+)"));local name="USER";if uid then pcall(function() name=Players:GetNameFromUserIdAsync(uid) end) end;table.insert(lines,string.format("#%d  %s   R$%d",i,string.upper(name),tonumber(item.value) or 0)) end;body.Text=table.concat(lines,"\n\n")
 end
 task.spawn(function() while task.wait(1) do refresh();task.wait(119) end end)
 workspace:GetAttributeChangedSignal("BBYALastSupportTotal"):Connect(function() task.defer(refresh) end)
end
workspace:SetAttribute("BBYASystemSupportBoard","5.1")
