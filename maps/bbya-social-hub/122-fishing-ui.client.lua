-- BBYA SOCIAL HUB — PREMIUM FISHING UI v1
-- Deliberately compact: one primary CAST/STRIKE/HOLD REEL action, thin fight bars,
-- small BAG / ROD / SHOP buttons, and one centered sheet at a time.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("BBYAFishingRemotes", 30)
if not remotes then return end
local actionRemote = remotes:WaitForChild("Action")
local stateRemote = remotes:WaitForChild("State")

local old = playerGui:FindFirstChild("BBYAFishingUI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "BBYAFishingUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 38
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Enabled = false
gui.Parent = playerGui

local C = {
 bg = Color3.fromRGB(14,17,21),
 panel = Color3.fromRGB(24,28,34),
 panel2 = Color3.fromRGB(31,36,43),
 text = Color3.fromRGB(242,243,244),
 muted = Color3.fromRGB(166,172,179),
 gold = Color3.fromRGB(235,184,80),
 cyan = Color3.fromRGB(69,208,221),
 green = Color3.fromRGB(83,209,133),
 red = Color3.fromRGB(231,80,87),
 orange = Color3.fromRGB(242,149,69),
}

local function corner(parent, radius)
 local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,radius or 10);c.Parent=parent;return c
end
local function stroke(parent, color, transparency, thickness)
 local s=Instance.new("UIStroke");s.Color=color or C.panel2;s.Transparency=transparency or .25;s.Thickness=thickness or 1;s.Parent=parent;return s
end
local function text(parent, value, size, font, color)
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Text=value or "";t.TextSize=size or 14;t.Font=font or Enum.Font.Gotham;t.TextColor3=color or C.text;t.TextWrapped=true;t.Parent=parent;return t
end
local function button(parent, value)
 local b=Instance.new("TextButton");b.AutoButtonColor=true;b.Text=value;b.TextColor3=C.text;b.Font=Enum.Font.GothamBold;b.TextSize=13;b.BackgroundColor3=C.panel2;b.BorderSizePixel=0;b.Parent=parent;corner(b,10);stroke(b,Color3.fromRGB(72,78,86),.35,1);return b
end

-- Root HUD stays low and narrow so the lake remains the visual focus.
local hud = Instance.new("Frame")
hud.Name="HUD";hud.AnchorPoint=Vector2.new(.5,1);hud.Position=UDim2.new(.5,0,1,-18);hud.Size=UDim2.fromOffset(330,116);hud.BackgroundTransparency=1;hud.Parent=gui

local hint = text(hud,"BBYA LAKESIDE",12,Enum.Font.GothamBold,C.muted)
hint.AnchorPoint=Vector2.new(.5,0);hint.Position=UDim2.new(.5,0,0,0);hint.Size=UDim2.new(1,0,0,18);hint.TextXAlignment=Enum.TextXAlignment.Center

local action = button(hud,"CAST")
action.Name="Action";action.AnchorPoint=Vector2.new(.5,0);action.Position=UDim2.new(.5,0,0,20);action.Size=UDim2.fromOffset(164,50);action.TextSize=18;action.BackgroundColor3=C.gold;action.TextColor3=C.bg
stroke(action,Color3.fromRGB(255,211,126),.05,1.3)

local nav = Instance.new("Frame")
nav.AnchorPoint=Vector2.new(.5,0);nav.Position=UDim2.new(.5,0,0,78);nav.Size=UDim2.fromOffset(246,34);nav.BackgroundTransparency=1;nav.Parent=hud
local navLayout=Instance.new("UIListLayout");navLayout.FillDirection=Enum.FillDirection.Horizontal;navLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center;navLayout.VerticalAlignment=Enum.VerticalAlignment.Center;navLayout.Padding=UDim.new(0,7);navLayout.Parent=nav
local bagButton=button(nav,"BAG");bagButton.Size=UDim2.fromOffset(74,32)
local rodButton=button(nav,"ROD");rodButton.Size=UDim2.fromOffset(74,32)
local shopButton=button(nav,"SHOP");shopButton.Size=UDim2.fromOffset(74,32)

-- Two thin bars appear only during the fight. No oversized minigame panel.
local fight = Instance.new("Frame")
fight.Name="Fight";fight.AnchorPoint=Vector2.new(.5,1);fight.Position=UDim2.new(.5,0,1,-140);fight.Size=UDim2.fromOffset(286,62);fight.BackgroundColor3=C.bg;fight.BackgroundTransparency=.08;fight.BorderSizePixel=0;fight.Visible=false;fight.Parent=gui;corner(fight,12);stroke(fight,Color3.fromRGB(79,85,93),.28,1)
local fightTitle=text(fight,"HOLD REEL • lepas kalau tension tinggi",11,Enum.Font.GothamBold,C.text);fightTitle.Position=UDim2.fromOffset(12,7);fightTitle.Size=UDim2.new(1,-24,0,17);fightTitle.TextXAlignment=Enum.TextXAlignment.Left
local progressBg=Instance.new("Frame");progressBg.Position=UDim2.fromOffset(12,29);progressBg.Size=UDim2.new(1,-24,0,8);progressBg.BackgroundColor3=C.panel2;progressBg.BorderSizePixel=0;progressBg.Parent=fight;corner(progressBg,4)
local progressFill=Instance.new("Frame");progressFill.Size=UDim2.fromScale(0,1);progressFill.BackgroundColor3=C.green;progressFill.BorderSizePixel=0;progressFill.Parent=progressBg;corner(progressFill,4)
local tensionBg=Instance.new("Frame");tensionBg.Position=UDim2.fromOffset(12,43);tensionBg.Size=UDim2.new(1,-24,0,7);tensionBg.BackgroundColor3=C.panel2;tensionBg.BorderSizePixel=0;tensionBg.Parent=fight;corner(tensionBg,4)
local tensionFill=Instance.new("Frame");tensionFill.Size=UDim2.fromScale(.2,1);tensionFill.BackgroundColor3=C.orange;tensionFill.BorderSizePixel=0;tensionFill.Parent=tensionBg;corner(tensionFill,4)

-- Catch card appears briefly, then gets out of the way.
local catchCard=Instance.new("Frame")
catchCard.AnchorPoint=Vector2.new(.5,.5);catchCard.Position=UDim2.new(.5,0,.37,0);catchCard.Size=UDim2.fromOffset(300,116);catchCard.BackgroundColor3=C.bg;catchCard.BackgroundTransparency=.04;catchCard.BorderSizePixel=0;catchCard.Visible=false;catchCard.Parent=gui;corner(catchCard,14);stroke(catchCard,C.gold,.18,1.4)
local catchRarity=text(catchCard,"RARE",11,Enum.Font.GothamBlack,C.gold);catchRarity.Position=UDim2.fromOffset(16,12);catchRarity.Size=UDim2.new(1,-32,0,16);catchRarity.TextXAlignment=Enum.TextXAlignment.Left
local catchName=text(catchCard,"Royal Koi",21,Enum.Font.GothamBlack,C.text);catchName.Position=UDim2.fromOffset(16,31);catchName.Size=UDim2.new(1,-32,0,31);catchName.TextXAlignment=Enum.TextXAlignment.Left
local catchDetail=text(catchCard,"2.80 kg  •  +105 Lake Tokens",13,Enum.Font.GothamBold,C.muted);catchDetail.Position=UDim2.fromOffset(16,70);catchDetail.Size=UDim2.new(1,-32,0,24);catchDetail.TextXAlignment=Enum.TextXAlignment.Left

local toast=Instance.new("TextLabel")
toast.AnchorPoint=Vector2.new(.5,0);toast.Position=UDim2.new(.5,0,.13,0);toast.Size=UDim2.fromOffset(310,38);toast.BackgroundColor3=C.bg;toast.BackgroundTransparency=.08;toast.TextColor3=C.text;toast.TextSize=13;toast.Font=Enum.Font.GothamBold;toast.BorderSizePixel=0;toast.Visible=false;toast.Parent=gui;corner(toast,11);stroke(toast,Color3.fromRGB(80,86,94),.30,1)

-- A single reusable center sheet. BAG / ROD / SHOP never stack panels.
local shade=Instance.new("TextButton")
shade.Text="";shade.AutoButtonColor=false;shade.BackgroundColor3=Color3.new(0,0,0);shade.BackgroundTransparency=.55;shade.Size=UDim2.fromScale(1,1);shade.Visible=false;shade.ZIndex=50;shade.Parent=gui
local sheet=Instance.new("Frame")
sheet.AnchorPoint=Vector2.new(.5,.5);sheet.Position=UDim2.fromScale(.5,.52);sheet.Size=UDim2.fromOffset(370,360);sheet.BackgroundColor3=C.bg;sheet.BorderSizePixel=0;sheet.Visible=false;sheet.ZIndex=51;sheet.Parent=gui;corner(sheet,16);stroke(sheet,Color3.fromRGB(77,83,91),.20,1.2)
local sheetTitle=text(sheet,"BAG",19,Enum.Font.GothamBlack,C.text);sheetTitle.Position=UDim2.fromOffset(18,14);sheetTitle.Size=UDim2.new(1,-72,0,28);sheetTitle.ZIndex=52;sheetTitle.TextXAlignment=Enum.TextXAlignment.Left
local close=button(sheet,"×");close.AnchorPoint=Vector2.new(1,0);close.Position=UDim2.new(1,-12,0,10);close.Size=UDim2.fromOffset(38,34);close.TextSize=22;close.ZIndex=52
local sheetBody=Instance.new("Frame");sheetBody.Position=UDim2.fromOffset(14,54);sheetBody.Size=UDim2.new(1,-28,1,-68);sheetBody.BackgroundTransparency=1;sheetBody.ZIndex=52;sheetBody.Parent=sheet

local currentState="IDLE"
local snapshot={tokens=0,total=0,best=0,equipped="Graphite Core",skins={}}
local reeling=false
local recent={}
local toastSerial=0
local catchSerial=0

local rarityColors={COMMON=Color3.fromRGB(196,202,207),UNCOMMON=Color3.fromRGB(96,213,131),RARE=Color3.fromRGB(74,161,242),EPIC=Color3.fromRGB(177,102,236),LEGENDARY=Color3.fromRGB(246,188,72),MYTHIC=Color3.fromRGB(244,99,173)}

local function showToast(value)
 toastSerial+=1;local serial=toastSerial
 toast.Text=value or "";toast.TextTransparency=0;toast.BackgroundTransparency=.08;toast.Visible=true
 task.delay(2.2,function()
  if serial~=toastSerial or not toast.Parent then return end
  local tween=TweenService:Create(toast,TweenInfo.new(.22),{TextTransparency=1,BackgroundTransparency=1});tween:Play();tween.Completed:Wait()
  if serial==toastSerial then toast.Visible=false;toast.TextTransparency=0;toast.BackgroundTransparency=.08 end
 end)
end

local function closeSheet()
 shade.Visible=false;sheet.Visible=false
end
shade.Activated:Connect(closeSheet);close.Activated:Connect(closeSheet)

local function clearBody()
 for _,c in ipairs(sheetBody:GetChildren()) do c:Destroy() end
end

local function statRow(label,value,y)
 local row=Instance.new("Frame");row.Position=UDim2.fromOffset(0,y);row.Size=UDim2.new(1,0,0,50);row.BackgroundColor3=C.panel;row.BorderSizePixel=0;row.ZIndex=53;row.Parent=sheetBody;corner(row,10)
 local l=text(row,label,12,Enum.Font.GothamBold,C.muted);l.Position=UDim2.fromOffset(14,7);l.Size=UDim2.new(.6,-14,0,17);l.ZIndex=54;l.TextXAlignment=Enum.TextXAlignment.Left
 local v=text(row,value,17,Enum.Font.GothamBlack,C.text);v.Position=UDim2.fromOffset(14,24);v.Size=UDim2.new(1,-28,0,20);v.ZIndex=54;v.TextXAlignment=Enum.TextXAlignment.Left
end

local function openBag()
 clearBody();sheetTitle.Text="BAG";shade.Visible=true;sheet.Visible=true
 statRow("LAKE TOKENS",tostring(snapshot.tokens or 0),0)
 statRow("TOTAL CATCH",tostring(snapshot.total or 0),58)
 statRow("PERSONAL BEST",string.format("%.2f kg",tonumber(snapshot.best) or 0),116)
 local h=text(sheetBody,"RECENT",11,Enum.Font.GothamBlack,C.muted);h.Position=UDim2.fromOffset(3,178);h.Size=UDim2.new(1,-6,0,18);h.ZIndex=53;h.TextXAlignment=Enum.TextXAlignment.Left
 local y=200
 if #recent==0 then
  local e=text(sheetBody,"Belum ada tangkapan sesi ini.",12,Enum.Font.Gotham,C.muted);e.Position=UDim2.fromOffset(3,y);e.Size=UDim2.new(1,-6,0,30);e.ZIndex=53;e.TextXAlignment=Enum.TextXAlignment.Left
 else
  for i=1,math.min(3,#recent) do
   local r=recent[i];local line=text(sheetBody,string.format("%s  •  %.2f kg",r.name,r.weight),12,Enum.Font.GothamBold,rarityColors[r.rarity] or C.text);line.Position=UDim2.fromOffset(3,y);line.Size=UDim2.new(1,-6,0,24);line.ZIndex=53;line.TextXAlignment=Enum.TextXAlignment.Left;y+=25
  end
 end
end

local function makeScroll()
 local sc=Instance.new("ScrollingFrame");sc.Size=UDim2.fromScale(1,1);sc.BackgroundTransparency=1;sc.BorderSizePixel=0;sc.ScrollBarThickness=3;sc.ScrollBarImageColor3=C.muted;sc.AutomaticCanvasSize=Enum.AutomaticSize.Y;sc.CanvasSize=UDim2.fromOffset(0,0);sc.ZIndex=53;sc.Parent=sheetBody
 local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,7);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=sc
 return sc
end

local function skinRow(parent,s,mode)
 local row=Instance.new("Frame");row.Size=UDim2.new(1,-5,0,58);row.BackgroundColor3=C.panel;row.BorderSizePixel=0;row.ZIndex=54;row.Parent=parent;corner(row,10)
 local dot=Instance.new("Frame");dot.Position=UDim2.fromOffset(12,16);dot.Size=UDim2.fromOffset(8,26);dot.BackgroundColor3=rarityColors[s.rarity] or C.muted;dot.BorderSizePixel=0;dot.ZIndex=55;dot.Parent=row;corner(dot,4)
 local n=text(row,s.name,13,Enum.Font.GothamBlack,C.text);n.Position=UDim2.fromOffset(30,8);n.Size=UDim2.new(.58,-30,0,20);n.ZIndex=55;n.TextXAlignment=Enum.TextXAlignment.Left
 local r=text(row,s.rarity,10,Enum.Font.GothamBold,rarityColors[s.rarity] or C.muted);r.Position=UDim2.fromOffset(30,29);r.Size=UDim2.new(.58,-30,0,18);r.ZIndex=55;r.TextXAlignment=Enum.TextXAlignment.Left
 local b=button(row,"");b.AnchorPoint=Vector2.new(1,.5);b.Position=UDim2.new(1,-9,.5,0);b.Size=UDim2.fromOffset(125,38);b.ZIndex=55
 if mode=="ROD" then
  if s.equipped then b.Text="EQUIPPED";b.BackgroundColor3=C.green;b.TextColor3=C.bg;b.Active=false
  elseif s.unlocked then b.Text="EQUIP";b.BackgroundColor3=C.gold;b.TextColor3=C.bg
  else b.Text="LOCKED";b.TextColor3=C.muted;b.Active=false end
  if s.unlocked and not s.equipped then b.Activated:Connect(function() actionRemote:FireServer("EquipSkin",s.name) end) end
 else
  if s.unlocked then b.Text=s.equipped and "OWNED ✓" or "OWNED";b.BackgroundColor3=C.panel2;b.TextColor3=C.green
  else b.Text=(s.price==0 and "FREE" or tostring(s.price).." TOKENS");b.TextSize=11;b.BackgroundColor3=C.gold;b.TextColor3=C.bg
   b.Activated:Connect(function() actionRemote:FireServer("BuySkin",s.name) end)
  end
  local req=text(row,(s.required or 0)>0 and (""..s.required.." catches") or "starter",9,Enum.Font.Gotham,C.muted);req.AnchorPoint=Vector2.new(1,0);req.Position=UDim2.new(1,-142,0,36);req.Size=UDim2.fromOffset(90,14);req.TextXAlignment=Enum.TextXAlignment.Right;req.ZIndex=55
 end
end

local function openRod()
 clearBody();sheetTitle.Text="ROD SKINS";shade.Visible=true;sheet.Visible=true
 local sc=makeScroll()
 local any=false
 for _,s in ipairs(snapshot.skins or {}) do if s.unlocked then skinRow(sc,s,"ROD");any=true end end
 if not any then showToast("Ambil pancing dulu di BBYA ANGLER.") end
end

local function openShop()
 clearBody();sheetTitle.Text="SKIN SHOP";shade.Visible=true;sheet.Visible=true
 local sc=makeScroll()
 for _,s in ipairs(snapshot.skins or {}) do skinRow(sc,s,"SHOP") end
end

bagButton.Activated:Connect(function() actionRemote:FireServer("Snapshot");openBag() end)
rodButton.Activated:Connect(function() actionRemote:FireServer("Snapshot");openRod() end)
shopButton.Activated:Connect(function() actionRemote:FireServer("Snapshot");openShop() end)

local function setAction(label,bg,fg,active)
 action.Text=label;action.BackgroundColor3=bg;action.TextColor3=fg or C.bg;action.Active=active~=false;action.AutoButtonColor=active~=false
end

local function setState(name)
 currentState=name
 fight.Visible=(name=="FIGHT")
 if name=="IDLE" then setAction("CAST",C.gold,C.bg,true);hint.Text="BBYA LAKESIDE"
 elseif name=="WAITING" then setAction("WAIT...",C.panel2,C.muted,false);hint.Text="Tunggu strike"
 elseif name=="BITE" then setAction("STRIKE!",C.orange,C.bg,true);hint.Text="IKAN MAKAN!"
 elseif name=="FIGHT" then setAction("HOLD REEL",C.cyan,C.bg,true);hint.Text="Jaga tension" end
end
setState("IDLE")

action.Activated:Connect(function()
 if currentState=="IDLE" then actionRemote:FireServer("Cast")
 elseif currentState=="BITE" then actionRemote:FireServer("Hook") end
end)

local function beginReel(input)
 if currentState~="FIGHT" or reeling then return end
 if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
 reeling=true;actionRemote:FireServer("Reel",true);action.Text="REELING...";action.BackgroundColor3=C.green
end
local function endReel(input)
 if not reeling then return end
 if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
 reeling=false;actionRemote:FireServer("Reel",false)
 if currentState=="FIGHT" then action.Text="HOLD REEL";action.BackgroundColor3=C.cyan end
end
action.InputBegan:Connect(beginReel)
action.InputEnded:Connect(endReel)
UserInputService.InputEnded:Connect(function(input) if reeling then endReel(input) end end)

local function refreshOpenSheet()
 if not sheet.Visible then return end
 if sheetTitle.Text=="BAG" then openBag()
 elseif sheetTitle.Text=="ROD SKINS" then openRod()
 elseif sheetTitle.Text=="SKIN SHOP" then openShop() end
end

stateRemote.OnClientEvent:Connect(function(kind,payload)
 payload=type(payload)=="table" and payload or {}
 if kind=="Snapshot" then
  snapshot=payload
  refreshOpenSheet()
 elseif kind=="Waiting" then setState("WAITING")
 elseif kind=="Bite" then setState("BITE")
 elseif kind=="Fight" then
  setState("FIGHT");progressFill.Size=UDim2.fromScale(payload.progress or 0,1);tensionFill.Size=UDim2.fromScale(payload.tension or .2,1)
  fightTitle.Text=(payload.rarity or "FISH").." • HOLD REEL • lepas saat tension tinggi"
 elseif kind=="FightTick" then
  local p=math.clamp(tonumber(payload.progress) or 0,0,1);local t=math.clamp(tonumber(payload.tension) or 0,0,1)
  progressFill.Size=UDim2.fromScale(p,1);tensionFill.Size=UDim2.fromScale(t,1)
  tensionFill.BackgroundColor3=t>.78 and C.red or (t>.55 and C.orange or C.cyan)
 elseif kind=="Catch" then
  reeling=false;setState("IDLE")
  snapshot.tokens=payload.tokens or snapshot.tokens;snapshot.total=payload.total or snapshot.total;snapshot.best=payload.best or snapshot.best
  table.insert(recent,1,{name=payload.name or "Fish",rarity=payload.rarity or "COMMON",weight=payload.weight or 0});while #recent>5 do table.remove(recent) end
  catchSerial+=1;local serial=catchSerial
  catchRarity.Text=payload.rarity or "CATCH";catchRarity.TextColor3=rarityColors[payload.rarity] or C.gold
  catchName.Text=payload.name or "Fish"
  catchDetail.Text=string.format("%.2f kg  •  +%d Lake Tokens",tonumber(payload.weight) or 0,tonumber(payload.reward) or 0)
  catchCard.Visible=true;catchCard.BackgroundTransparency=.04
  task.delay(3.2,function() if serial==catchSerial and catchCard.Parent then catchCard.Visible=false end end)
 elseif kind=="Escaped" then
  reeling=false;setState("IDLE");showToast(payload.text or "Ikan lepas.")
 elseif kind=="Idle" then reeling=false;setState("IDLE")
 elseif kind=="Toast" then showToast(payload.text or "") end
end)

-- Enable only around the lakeside district; no permanent club-screen clutter.
local LAKE_CENTER=Vector3.new(0,0,790)
local ENABLE_RADIUS=232
local accum=0
RunService.RenderStepped:Connect(function(dt)
 accum+=dt;if accum<.25 then return end;accum=0
 local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 local near=false
 if hrp then
  local dx=hrp.Position.X-LAKE_CENTER.X;local dz=hrp.Position.Z-LAKE_CENTER.Z
  near=(dx*dx+dz*dz)<=ENABLE_RADIUS*ENABLE_RADIUS
 end
 if gui.Enabled~=near then gui.Enabled=near;if not near then closeSheet() end end
end)

-- Mobile-safe scale: keep controls compact on small screens, never giant.
local camera=workspace.CurrentCamera
local function applyScale()
 local viewport=camera and camera.ViewportSize or Vector2.new(1280,720)
 local scale=1
 if viewport.X<520 then scale=.86 elseif viewport.X<760 then scale=.93 end
 local oldScale=hud:FindFirstChildOfClass("UIScale") or Instance.new("UIScale");oldScale.Scale=scale;oldScale.Parent=hud
 local fightScale=fight:FindFirstChildOfClass("UIScale") or Instance.new("UIScale");fightScale.Scale=scale;fightScale.Parent=fight
 local sheetScale=sheet:FindFirstChildOfClass("UIScale") or Instance.new("UIScale");sheetScale.Scale=math.min(1,viewport.X/410);sheetScale.Parent=sheet
end
applyScale()
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale) end

actionRemote:FireServer("Snapshot")
print("[BBYA] Fishing UI v1 online: compact CAST/REEL + BAG/ROD/SHOP")
