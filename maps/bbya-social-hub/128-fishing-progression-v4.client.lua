-- BBYA SOCIAL HUB — FISHING PROGRESSION v4 CLIENT
-- Keeps fishing UI simple: temporary cast meter, one INDEX button, one compact journal,
-- and a short enhanced-catch banner. Existing CAST/REEL/BAG/ROD/SHOP authority remains intact.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local fishingGui = playerGui:WaitForChild("BBYAFishingUI", 35)
if not fishingGui then return end

local v4Folder = ReplicatedStorage:WaitForChild("BBYAFishingV4", 35)
if not v4Folder then return end
local actionRemote = v4Folder:WaitForChild("Action")
local stateRemote = v4Folder:WaitForChild("State")

local hud = fishingGui:WaitForChild("HUD", 15)
local actionButton = fishingGui:FindFirstChild("Action", true)
if not hud or not actionButton or not actionButton:IsA("TextButton") then return end

local old = fishingGui:FindFirstChild("FishingProgressionV4UI")
if old then old:Destroy() end
local root = Instance.new("Frame")
root.Name = "FishingProgressionV4UI"
root.BackgroundTransparency = 1
root.Size = UDim2.fromScale(1,1)
root.ZIndex = 55
root.Parent = fishingGui

local C = {
    bg=Color3.fromRGB(14,17,21), panel=Color3.fromRGB(24,28,34), panel2=Color3.fromRGB(34,39,46),
    text=Color3.fromRGB(244,245,245), muted=Color3.fromRGB(163,170,178), gold=Color3.fromRGB(237,185,77),
    cyan=Color3.fromRGB(71,210,220), green=Color3.fromRGB(82,210,132), orange=Color3.fromRGB(241,151,69),
    pink=Color3.fromRGB(238,106,171), violet=Color3.fromRGB(150,101,227), red=Color3.fromRGB(230,78,86),
}
local rarityColors={COMMON=Color3.fromRGB(196,202,207),UNCOMMON=Color3.fromRGB(96,213,131),RARE=Color3.fromRGB(74,161,242),EPIC=Color3.fromRGB(177,102,236),LEGENDARY=Color3.fromRGB(246,188,72),MYTHIC=Color3.fromRGB(244,99,173)}
local mutationColors={NORMAL=C.muted,GOLDEN=C.gold,MOONLIT=Color3.fromRGB(155,194,255),LOTUS=C.pink,CRYSTAL=C.cyan,SHADOW=C.violet,AURORA=Color3.fromRGB(78,228,201),CELESTIAL=Color3.fromRGB(247,218,127),ABYSSAL=Color3.fromRGB(99,91,221)}

local function corner(parent,r)
    local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=parent;return c
end
local function stroke(parent,color,transparency,thickness)
    local s=Instance.new("UIStroke");s.Color=color or Color3.fromRGB(76,82,91);s.Transparency=transparency or .25;s.Thickness=thickness or 1;s.Parent=parent;return s
end
local function label(parent,value,size,font,color)
    local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Text=value or "";t.TextSize=size or 13;t.Font=font or Enum.Font.Gotham;t.TextColor3=color or C.text;t.TextWrapped=true;t.Parent=parent;return t
end
local function button(parent,value)
    local b=Instance.new("TextButton");b.Text=value;b.AutoButtonColor=true;b.TextColor3=C.text;b.TextSize=12;b.Font=Enum.Font.GothamBold;b.BackgroundColor3=C.panel2;b.BorderSizePixel=0;b.Parent=parent;corner(b,9);stroke(b,Color3.fromRGB(75,81,89),.32,1);return b
end

-- Find existing compact navigation by locating BAG; add only one matching INDEX button.
local bagButton
for _,d in ipairs(fishingGui:GetDescendants()) do
    if d:IsA("TextButton") and d.Text=="BAG" then bagButton=d;break end
end
local nav = bagButton and bagButton.Parent
local indexButton
if nav and nav:IsA("Frame") then
    indexButton=button(nav,"INDEX")
    indexButton.Name="FishingIndexV4"
    indexButton.Size=UDim2.fromOffset(74,32)
    nav.Size=UDim2.fromOffset(324,34)
end

-- Temporary charge-quality strip above the detached round action button.
local castMeter = Instance.new("Frame")
castMeter.Name="CastMeterV4"
castMeter.AnchorPoint=Vector2.new(.5,1)
castMeter.Size=UDim2.fromOffset(88,18)
castMeter.BackgroundTransparency=1
castMeter.Visible=false
castMeter.ZIndex=70
castMeter.Parent=root
local castText=label(castMeter,"HOLD",10,Enum.Font.GothamBlack,C.muted)
castText.Size=UDim2.new(1,0,0,10);castText.TextXAlignment=Enum.TextXAlignment.Center;castText.ZIndex=71
local meterBg=Instance.new("Frame");meterBg.Position=UDim2.fromOffset(0,12);meterBg.Size=UDim2.new(1,0,0,5);meterBg.BackgroundColor3=C.panel2;meterBg.BorderSizePixel=0;meterBg.ZIndex=71;meterBg.Parent=castMeter;corner(meterBg,3)
local meterFill=Instance.new("Frame");meterFill.Size=UDim2.fromScale(0,1);meterFill.BackgroundColor3=C.green;meterFill.BorderSizePixel=0;meterFill.ZIndex=72;meterFill.Parent=meterBg;corner(meterFill,3)
local perfectBand=Instance.new("Frame");perfectBand.Position=UDim2.fromScale(.62,0);perfectBand.Size=UDim2.fromScale(.24,1);perfectBand.BackgroundColor3=C.gold;perfectBand.BackgroundTransparency=.45;perfectBand.BorderSizePixel=0;perfectBand.ZIndex=73;perfectBand.Parent=meterBg

local chargeStart=nil
local charging=false
local sentRelease=false

local function currentActionIsCast()
    return fishingGui.Enabled and actionButton.Visible and string.upper(actionButton.Text)=="CAST"
end

local function layoutCastMeter()
    local abs=actionButton.AbsolutePosition
    local size=actionButton.AbsoluteSize
    castMeter.Position=UDim2.fromOffset(abs.X+size.X/2,abs.Y-5)
end

local function classifyCharge(seconds)
    local normalized=math.clamp(seconds/1.10,0,1.4)
    if normalized>=.62 and normalized<=.86 then return "PERFECT",normalized end
    if normalized>=.38 and normalized<=1.04 then return "GREAT",normalized end
    return "GOOD",normalized
end

local function beginCharge(input)
    if charging or not currentActionIsCast() then return end
    if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    charging=true;sentRelease=false;chargeStart=os.clock();castMeter.Visible=true;layoutCastMeter();castText.Text="HOLD";castText.TextColor3=C.muted
end

local function endCharge(input)
    if not charging or sentRelease then return end
    if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    sentRelease=true;charging=false
    local seconds=os.clock()-(chargeStart or os.clock())
    local quality,power=classifyCharge(seconds)
    local qc=quality=="PERFECT" and C.gold or (quality=="GREAT" and C.cyan or C.muted)
    castText.Text=quality;castText.TextColor3=qc;meterFill.BackgroundColor3=qc
    actionRemote:FireServer("CastQuality",{quality=quality,power=power})
    task.delay(.55,function() if not charging and castMeter.Parent then castMeter.Visible=false end end)
end

actionButton.InputBegan:Connect(beginCharge)
actionButton.InputEnded:Connect(endCharge)
UserInputService.InputEnded:Connect(function(input) if charging then endCharge(input) end end)

RunService.RenderStepped:Connect(function()
    if charging and chargeStart then
        layoutCastMeter()
        local normalized=math.clamp((os.clock()-chargeStart)/1.10,0,1.15)
        meterFill.Size=UDim2.fromScale(math.min(normalized,1),1)
        if normalized>=.62 and normalized<=.86 then meterFill.BackgroundColor3=C.gold;castText.Text="PERFECT ZONE"
        elseif normalized>=.38 and normalized<=1.04 then meterFill.BackgroundColor3=C.cyan;castText.Text="GREAT"
        else meterFill.BackgroundColor3=C.muted;castText.Text="HOLD" end
    end
end)

-- Compact enhanced catch banner: adds mutation/biome/progression without duplicating the base catch card.
local banner=Instance.new("Frame")
banner.AnchorPoint=Vector2.new(.5,0);banner.Position=UDim2.new(.5,0,.18,0);banner.Size=UDim2.fromOffset(344,72);banner.BackgroundColor3=C.bg;banner.BackgroundTransparency=.04;banner.BorderSizePixel=0;banner.Visible=false;banner.ZIndex=75;banner.Parent=root;corner(banner,13);local bannerStroke=stroke(banner,C.gold,.20,1.3)
local bannerTop=label(banner,"PERFECT • MOON COVE",10,Enum.Font.GothamBlack,C.muted);bannerTop.Position=UDim2.fromOffset(14,8);bannerTop.Size=UDim2.new(1,-28,0,15);bannerTop.TextXAlignment=Enum.TextXAlignment.Left;bannerTop.ZIndex=76
local bannerName=label(banner,"CELESTIAL ROYAL KOI",17,Enum.Font.GothamBlack,C.text);bannerName.Position=UDim2.fromOffset(14,25);bannerName.Size=UDim2.new(1,-28,0,23);bannerName.TextXAlignment=Enum.TextXAlignment.Left;bannerName.ZIndex=76
local bannerBottom=label(banner,"GIANT • +86 XP • INDEX 7/12",11,Enum.Font.GothamBold,C.muted);bannerBottom.Position=UDim2.fromOffset(14,50);bannerBottom.Size=UDim2.new(1,-28,0,16);bannerBottom.TextXAlignment=Enum.TextXAlignment.Left;bannerBottom.ZIndex=76
local bannerSerial=0

local function showBanner(data)
    bannerSerial+=1;local serial=bannerSerial
    bannerTop.Text=(data.quality or "GOOD").."  •  "..(data.biomeLabel or "LAKE").."  •  "..(data.event or "CALM WATERS")
    bannerName.Text=string.upper(data.variant or data.fish or "CATCH")
    local flags={}
    if data.size and data.size~="STANDARD" then table.insert(flags,data.size) end
    if data.secret then table.insert(flags,"SECRET DISCOVERY") elseif data.newVariant then table.insert(flags,"NEW VARIANT") elseif data.newSpecies then table.insert(flags,"NEW SPECIES") end
    table.insert(flags,"+"..tostring(data.xp or 0).." XP")
    table.insert(flags,"INDEX "..tostring(data.speciesCount or 0).."/"..tostring(data.speciesTotal or 12))
    bannerBottom.Text=table.concat(flags,"  •  ")
    local mc=mutationColors[data.mutation or "NORMAL"] or C.gold
    bannerStroke.Color=mc;bannerName.TextColor3=mc
    banner.Visible=true;banner.BackgroundTransparency=.04
    task.delay(data.secret and 4.2 or 3.0,function() if serial==bannerSerial and banner.Parent then banner.Visible=false end end)
end

-- One modal for Fish Index and progression. No tabs, no stacked windows.
local shade=Instance.new("TextButton")
shade.Name="JournalShadeV4";shade.Text="";shade.AutoButtonColor=false;shade.BackgroundColor3=Color3.new(0,0,0);shade.BackgroundTransparency=.55;shade.Size=UDim2.fromScale(1,1);shade.Visible=false;shade.ZIndex=80;shade.Parent=root
local journal=Instance.new("Frame")
journal.Name="JournalV4";journal.AnchorPoint=Vector2.new(.5,.5);journal.Position=UDim2.fromScale(.5,.50);journal.Size=UDim2.fromOffset(380,410);journal.BackgroundColor3=C.bg;journal.BorderSizePixel=0;journal.Visible=false;journal.ZIndex=81;journal.Parent=root;corner(journal,16);stroke(journal,Color3.fromRGB(77,84,92),.18,1.2)
local title=label(journal,"FISH INDEX",19,Enum.Font.GothamBlack,C.text);title.Position=UDim2.fromOffset(17,13);title.Size=UDim2.new(1,-70,0,27);title.TextXAlignment=Enum.TextXAlignment.Left;title.ZIndex=82
local close=button(journal,"×");close.AnchorPoint=Vector2.new(1,0);close.Position=UDim2.new(1,-11,0,10);close.Size=UDim2.fromOffset(38,34);close.TextSize=22;close.ZIndex=82
local summary=label(journal,"0/12 species",11,Enum.Font.GothamBold,C.muted);summary.Position=UDim2.fromOffset(18,40);summary.Size=UDim2.new(1,-36,0,18);summary.TextXAlignment=Enum.TextXAlignment.Left;summary.ZIndex=82
local eventLabel=label(journal,"CALM WATERS",10,Enum.Font.GothamBlack,C.gold);eventLabel.AnchorPoint=Vector2.new(1,0);eventLabel.Position=UDim2.new(1,-18,0,41);eventLabel.Size=UDim2.fromOffset(175,17);eventLabel.TextXAlignment=Enum.TextXAlignment.Right;eventLabel.ZIndex=82

local stats=Instance.new("Frame");stats.Position=UDim2.fromOffset(14,64);stats.Size=UDim2.new(1,-28,0,66);stats.BackgroundTransparency=1;stats.ZIndex=82;stats.Parent=journal
local statLayout=Instance.new("UIListLayout");statLayout.FillDirection=Enum.FillDirection.Horizontal;statLayout.Padding=UDim.new(0,7);statLayout.Parent=stats
local function statCard(name)
    local f=Instance.new("Frame");f.Size=UDim2.new(.25,-6,1,0);f.BackgroundColor3=C.panel;f.BorderSizePixel=0;f.ZIndex=83;f.Parent=stats;corner(f,9)
    local h=label(f,name,9,Enum.Font.GothamBold,C.muted);h.Position=UDim2.fromOffset(8,8);h.Size=UDim2.new(1,-16,0,14);h.TextXAlignment=Enum.TextXAlignment.Left;h.ZIndex=84
    local v=label(f,"0",16,Enum.Font.GothamBlack,C.text);v.Position=UDim2.fromOffset(8,27);v.Size=UDim2.new(1,-16,0,24);v.TextXAlignment=Enum.TextXAlignment.Left;v.ZIndex=84
    return v
end
local levelValue=statCard("LEVEL")
local xpValue=statCard("XP")
local variantsValue=statCard("VARIANTS")
local masteryValue=statCard("ROD MASTERY")

local scroll=Instance.new("ScrollingFrame");scroll.Position=UDim2.fromOffset(14,140);scroll.Size=UDim2.new(1,-28,1,-154);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=3;scroll.ScrollBarImageColor3=C.muted;scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.fromOffset(0,0);scroll.ZIndex=82;scroll.Parent=journal
local listLayout=Instance.new("UIListLayout");listLayout.Padding=UDim.new(0,6);listLayout.Parent=scroll

local snapshot=nil
local function clearSpecies()
    for _,c in ipairs(scroll:GetChildren()) do if c~=listLayout then c:Destroy() end end
end
local function renderJournal(data)
    snapshot=data or snapshot
    data=snapshot
    if not data then return end
    summary.Text=string.format("%d/%d species  •  %d mutations  •  %d secrets",data.speciesCount or 0,data.speciesTotal or 12,data.mutationCount or 0,data.secretCount or 0)
    eventLabel.Text=(data.event and data.event.label or "CALM WATERS")
    levelValue.Text=tostring(data.level or 1)
    xpValue.Text=tostring(data.xp or 0)
    variantsValue.Text=tostring(data.variantCount or 0)
    masteryValue.Text="Lv."..tostring(data.rodMastery or 1)
    title.Text="FISH INDEX • "..string.upper(data.title or "ANGLER")
    clearSpecies()
    for _,fish in ipairs(data.species or {}) do
        local row=Instance.new("Frame");row.Size=UDim2.new(1,-4,0,48);row.BackgroundColor3=C.panel;row.BorderSizePixel=0;row.ZIndex=83;row.Parent=scroll;corner(row,9)
        local dot=Instance.new("Frame");dot.Position=UDim2.fromOffset(10,12);dot.Size=UDim2.fromOffset(6,24);dot.BackgroundColor3=rarityColors[fish.rarity] or C.muted;dot.BorderSizePixel=0;dot.ZIndex=84;dot.Parent=row;corner(dot,3)
        local name=label(row,fish.discovered and fish.name or "???",12,Enum.Font.GothamBlack,fish.discovered and C.text or C.muted);name.Position=UDim2.fromOffset(26,6);name.Size=UDim2.new(.58,-26,0,18);name.TextXAlignment=Enum.TextXAlignment.Left;name.ZIndex=84
        local meta=label(row,fish.discovered and (fish.rarity.."  •  caught "..tostring(fish.count or 0)) or fish.rarity,9,Enum.Font.GothamBold,rarityColors[fish.rarity] or C.muted);meta.Position=UDim2.fromOffset(26,25);meta.Size=UDim2.new(.58,-26,0,15);meta.TextXAlignment=Enum.TextXAlignment.Left;meta.ZIndex=84
        local best=label(row,fish.discovered and string.format("%.2f kg",fish.best or 0) or "LOCKED",11,Enum.Font.GothamBlack,fish.discovered and C.gold or C.muted);best.AnchorPoint=Vector2.new(1,.5);best.Position=UDim2.new(1,-12,.5,0);best.Size=UDim2.fromOffset(105,18);best.TextXAlignment=Enum.TextXAlignment.Right;best.ZIndex=84
    end
end

local function openJournal()
    shade.Visible=true;journal.Visible=true
    actionRemote:FireServer("RequestJournal")
end
local function closeJournal()
    shade.Visible=false;journal.Visible=false
end
shade.Activated:Connect(closeJournal);close.Activated:Connect(closeJournal)
if indexButton then indexButton.Activated:Connect(openJournal) end

-- Scale journal cleanly on portrait/small devices.
local scale=Instance.new("UIScale");scale.Name="JournalScaleV4";scale.Parent=journal
local function applyScale()
    local camera=workspace.CurrentCamera
    local vp=camera and camera.ViewportSize or Vector2.new(1280,720)
    scale.Scale=math.min(1,math.max(.78,vp.X/420))
end
applyScale()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale) end

local function smallToast(textValue,color)
    local toast=label(root,textValue,11,Enum.Font.GothamBlack,C.text);toast.AnchorPoint=Vector2.new(.5,0);toast.Position=UDim2.new(.5,0,.11,0);toast.Size=UDim2.fromOffset(310,34);toast.BackgroundTransparency=.08;toast.BackgroundColor3=C.bg;toast.BorderSizePixel=0;toast.ZIndex=90;corner(toast,10);stroke(toast,color or C.gold,.22,1)
    task.delay(2.4,function() if toast.Parent then local tw=TweenService:Create(toast,TweenInfo.new(.2),{TextTransparency=1,BackgroundTransparency=1});tw:Play();tw.Completed:Wait();toast:Destroy() end end)
end

stateRemote.OnClientEvent:Connect(function(kind,data)
    data=type(data)=="table" and data or {}
    if kind=="Snapshot" or kind=="Journal" then
        snapshot=data
        if journal.Visible then renderJournal(data) end
    elseif kind=="CatchEnhanced" then
        showBanner(data)
        actionRemote:FireServer("RequestSnapshot")
    elseif kind=="CastQualityAck" then
        -- The charge label already shows quality; no extra popup needed.
    elseif kind=="AreaDiscovered" then
        smallToast("AREA DISCOVERED • "..tostring(data.biome or "LAKE").." • +"..tostring(data.xp or 0).." XP",C.cyan)
    elseif kind=="LakeEvent" then
        if fishingGui.Enabled then smallToast("LAKE EVENT • "..tostring(data.label or "CALM WATERS"),C.gold) end
    end
end)

-- If another panel opens, journal is never allowed to stack over it indefinitely.
RunService.RenderStepped:Connect(function()
    if not fishingGui.Enabled and journal.Visible then closeJournal() end
end)

actionRemote:FireServer("RequestSnapshot")
print("[BBYA] Fishing Progression v4 client online: cast quality + INDEX + compact progression reveal")
