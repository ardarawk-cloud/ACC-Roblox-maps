-- BECAK E-BIKE client HUD v1.1
-- Mobile-safe legacy HUD: keeps status/mission away from the left-side driver phone and prevents stale toast fades.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("BecakEBikeRemotes")
local stateEvent = remotes:WaitForChild("State")
local toastEvent = remotes:WaitForChild("Toast")

local gui=Instance.new("ScreenGui")
gui.Name="BecakEBikeHUD" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.Parent=player:WaitForChild("PlayerGui")

local function rounded(frame,r)
    local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 12) c.Parent=frame
end
local function text(parent,name,pos,size,value,fontSize)
    local t=Instance.new("TextLabel") t.Name=name t.Position=pos t.Size=size t.BackgroundTransparency=1
    t.Text=value t.TextColor3=Color3.new(1,1,1) t.Font=Enum.Font.GothamBold t.TextSize=fontSize or 16
    t.TextXAlignment=Enum.TextXAlignment.Left t.Parent=parent return t
end

local top=Instance.new("Frame")
top.AnchorPoint=Vector2.new(1,0)
top.BackgroundColor3=Color3.fromRGB(15,20,24) top.BackgroundTransparency=0.12 top.Parent=gui rounded(top,14)
local money=text(top,"Money",UDim2.new(0.04,0,0.08,0),UDim2.new(0.38,0,0.38,0),"Rp 25.000",18)
local lvl=text(top,"Level",UDim2.new(0.46,0,0.08,0),UDim2.new(0.2,0,0.38,0),"LV 1",18)
local rep=text(top,"Rep",UDim2.new(0.69,0,0.08,0),UDim2.new(0.27,0,0.38,0),"★ 5.0",18)
local bat=text(top,"Battery",UDim2.new(0.04,0,0.52,0),UDim2.new(0.45,0,0.36,0),"BAT 100%",15)
local trips=text(top,"Trips",UDim2.new(0.52,0,0.52,0),UDim2.new(0.44,0,0.36,0),"TRIP 0",15)

local mission=Instance.new("Frame")
mission.AnchorPoint=Vector2.new(1,0)
mission.BackgroundColor3=Color3.fromRGB(20,28,33) mission.BackgroundTransparency=0.12 mission.Parent=gui rounded(mission,12)
local missionText=text(mission,"Mission",UDim2.new(0.04,0,0,0),UDim2.new(0.92,0,1,0),"Cari penumpang di pinggir jalan",15)
missionText.TextWrapped=true

local help=Instance.new("Frame")
help.AnchorPoint=Vector2.new(0.5,1) help.BackgroundColor3=Color3.fromRGB(15,20,24) help.BackgroundTransparency=0.18 help.Parent=gui rounded(help,12)
local ht=text(help,"Help",UDim2.new(0.03,0,0,0),UDim2.new(0.94,0,1,0),"Duduk di kursi pengemudi • gunakan kontrol kendaraan Roblox • dekati NPC untuk Pick Up",13)
ht.TextWrapped=true ht.TextXAlignment=Enum.TextXAlignment.Center

local toast=Instance.new("TextLabel")
toast.AnchorPoint=Vector2.new(0.5,0.5) toast.BackgroundColor3=Color3.fromRGB(16,22,26) toast.BackgroundTransparency=1 toast.TextTransparency=1 toast.TextColor3=Color3.new(1,1,1)
toast.Font=Enum.Font.GothamBold toast.TextSize=17 toast.TextWrapped=true toast.Parent=gui rounded(toast,14)

local camera=Workspace.CurrentCamera
local viewportConn
local toastSerial=0

local function readInset()
    local ok,topLeft,bottomRight=pcall(function() return GuiService:GetGuiInset() end)
    if ok and typeof(topLeft)=="Vector2" and typeof(bottomRight)=="Vector2" then return topLeft,bottomRight end
    return Vector2.zero,Vector2.zero
end

local function applyLayout()
    camera=Workspace.CurrentCamera or camera
    local viewport=camera and camera.ViewportSize or Vector2.new(800,600)
    local insetTop,insetBottom=readInset()
    local touch=UserInputService.TouchEnabled
    local portrait=viewport.Y>viewport.X
    local compact=touch and not portrait and viewport.Y<=520
    local right=math.max(10,math.floor(insetBottom.X+12))
    local topY=math.max(10,math.floor(insetTop.Y+10))
    local usableW=math.max(260,viewport.X-insetTop.X-insetBottom.X)
    local statusW
    if portrait then statusW=math.clamp(math.floor(usableW*.50),168,260)
    elseif compact then statusW=math.clamp(math.floor(usableW*.36),250,360)
    else statusW=math.clamp(math.floor(usableW*.42),300,440) end
    local statusH=compact and 64 or 76
    top.Position=UDim2.new(1,-right,0,topY)
    top.Size=UDim2.fromOffset(statusW,statusH)
    mission.Position=UDim2.new(1,-right,0,topY+statusH+8)
    mission.Size=UDim2.fromOffset(statusW,compact and 46 or 54)

    local small=portrait or compact
    money.TextSize=small and 14 or 18
    lvl.TextSize=small and 14 or 18
    rep.TextSize=small and 14 or 18
    bat.TextSize=small and 12 or 15
    trips.TextSize=small and 12 or 15
    missionText.TextSize=small and 13 or 15

    -- Native mobile vehicle controls already explain steering. Hiding the legacy help strip avoids thumb-zone obstruction.
    help.Visible=not touch
    help.Position=UDim2.new(0.5,0,1,-math.max(12,insetBottom.Y+12))
    help.Size=UDim2.new(0,math.min(620,math.floor(usableW*.75)),0,44)

    toast.Position=UDim2.new(0.5,0,0.45,0)
    toast.Size=UDim2.new(0,math.min(compact and 430 or 520,math.max(240,usableW-28)),0,compact and 54 or 64)
    toast.TextSize=compact and 14 or 17
end

local function bindCamera()
    if viewportConn then viewportConn:Disconnect();viewportConn=nil end
    camera=Workspace.CurrentCamera
    if camera then viewportConn=camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyLayout) end
    applyLayout()
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
bindCamera()

local function rupiah(n)
    local s=tostring(math.floor(tonumber(n) or 0))
    local out=""
    while #s>3 do out="."..s:sub(-3)..out s=s:sub(1,-4) end
    return "Rp "..s..out
end

stateEvent.OnClientEvent:Connect(function(s)
    money.Text=rupiah(s.coins)
    lvl.Text="LV "..tostring(s.level or 1)
    rep.Text=string.format("★ %.1f",s.reputation or 5)
    local max=math.max(1,s.batteryMax or 100)
    bat.Text=string.format("BAT %d%%",math.floor(((s.battery or 0)/max)*100))
    trips.Text="TRIP "..tostring(s.trips or 0)
    missionText.Text=s.trip and ("Antar penumpang ke: "..s.trip) or "Cari penumpang di pinggir jalan"
end)

toastEvent.OnClientEvent:Connect(function(msg)
    toastSerial+=1
    local serial=toastSerial
    toast.Text=tostring(msg) toast.BackgroundTransparency=0.08 toast.TextTransparency=0
    task.delay(3.5,function()
        if serial~=toastSerial or not toast.Parent then return end
        TweenService:Create(toast,TweenInfo.new(0.5),{BackgroundTransparency=1,TextTransparency=1}):Play()
    end)
end)

Workspace:SetAttribute("ACC_BecakLegacyHUDMobileUX","v1.1")
Workspace:SetAttribute("BecakLegacyHUDSide","RIGHT")
Workspace:SetAttribute("BecakLegacyHUDPhoneSeparation","ON")
Workspace:SetAttribute("BecakLegacyHUDCoreGuiAware","ON")
Workspace:SetAttribute("BecakLegacyHUDTouchHelpHidden","ON")
Workspace:SetAttribute("BecakToastStaleFadeGuard","ON")
Workspace:SetAttribute("BecakLegacyHUDCameraConnectionGuard","ON")
