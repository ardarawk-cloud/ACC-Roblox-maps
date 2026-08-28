local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")

local player=Players.LocalPlayer
if not player then return end
local playerGui=player:WaitForChild("PlayerGui",20)
if not playerGui then return end

local gui=Instance.new("ScreenGui")
gui.Name="TRACK01_FinalQCUI"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=66
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.Parent=playerGui

local active
local function routeToast(kicker,text,duration)
    if active then active:Destroy() end
    local frame=Instance.new("Frame")
    active=frame
    frame.Name="RouteToast"
    frame.AnchorPoint=Vector2.new(0.5,1)
    frame.Position=UDim2.fromScale(0.5,0.965)
    frame.Size=UDim2.fromScale(0.62,0.07)
    frame.BackgroundColor3=Color3.fromRGB(13,14,14)
    frame.BackgroundTransparency=0.13
    frame.BorderSizePixel=0
    frame.Parent=gui
    local size=Instance.new("UISizeConstraint")
    size.MinSize=Vector2.new(260,56)
    size.MaxSize=Vector2.new(700,76)
    size.Parent=frame
    local corner=Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,5)
    corner.Parent=frame
    local stroke=Instance.new("UIStroke")
    stroke.Color=Color3.fromRGB(118,86,53)
    stroke.Thickness=1
    stroke.Transparency=0.30
    stroke.Parent=frame

    local top=Instance.new("TextLabel")
    top.BackgroundTransparency=1
    top.Position=UDim2.fromScale(0.03,0.06)
    top.Size=UDim2.fromScale(0.94,0.28)
    top.Font=Enum.Font.RobotoMono
    top.Text=kicker
    top.TextColor3=Color3.fromRGB(211,179,127)
    top.TextSize=11
    top.TextXAlignment=Enum.TextXAlignment.Left
    top.Parent=frame

    local body=Instance.new("TextLabel")
    body.BackgroundTransparency=1
    body.Position=UDim2.fromScale(0.03,0.35)
    body.Size=UDim2.fromScale(0.94,0.50)
    body.Font=Enum.Font.GothamMedium
    body.Text=text
    body.TextColor3=Color3.fromRGB(235,226,208)
    body.TextScaled=true
    body.TextWrapped=true
    body.TextXAlignment=Enum.TextXAlignment.Left
    body.Parent=frame
    local t=Instance.new("UITextSizeConstraint")
    t.MinTextSize=10
    t.MaxTextSize=16
    t.Parent=body

    task.delay(duration or 4.5,function()
        if not frame.Parent then return end
        TweenService:Create(frame,TweenInfo.new(0.45),{BackgroundTransparency=1}):Play()
        TweenService:Create(top,TweenInfo.new(0.45),{TextTransparency=1}):Play()
        TweenService:Create(body,TweenInfo.new(0.45),{TextTransparency=1}):Play()
        TweenService:Create(stroke,TweenInfo.new(0.45),{Transparency=1}):Play()
        task.wait(0.5)
        if frame.Parent then frame:Destroy() end
        if active==frame then active=nil end
    end)
end

local lastRecovery=player:GetAttribute("TRACK01_RECOVERY_TOKEN") or 0
player:GetAttributeChangedSignal("TRACK01_RECOVERY_TOKEN"):Connect(function()
    local token=player:GetAttribute("TRACK01_RECOVERY_TOKEN") or 0
    if token==lastRecovery then return end
    lastRecovery=token
    routeToast("TRACK 01 • SAFETY RECOVERY","RETURNED TO STATION LOBBY • YOUR NIGHT TICKET IS PRESERVED",5.2)
end)

local lastTicket=player:GetAttribute("TRACK01_TICKET")==true
player:GetAttributeChangedSignal("TRACK01_TICKET"):Connect(function()
    local has=player:GetAttribute("TRACK01_TICKET")==true
    if has and not lastTicket then
        routeToast("NIGHT TICKET VALID","CHECK-IN → PLATFORM 01 → CAR 01–04",5.0)
    end
    lastTicket=has
end)

local lastCheck=player:GetAttribute("TRACK01_CHECKED_IN")==true
player:GetAttributeChangedSignal("TRACK01_CHECKED_IN"):Connect(function()
    local checked=player:GetAttribute("TRACK01_CHECKED_IN")==true
    if checked and not lastCheck then
        routeToast("CHECK-IN COMPLETE","PROCEED TO PLATFORM 01 • BOARDING OPEN",4.6)
    end
    lastCheck=checked
end)

local lastBoard=player:GetAttribute("TRACK01_BOARDED")==true
player:GetAttributeChangedSignal("TRACK01_BOARDED"):Connect(function()
    local boarded=player:GetAttribute("TRACK01_BOARDED")==true
    if boarded and not lastBoard then
        routeToast("BOARDING COMPLETE","CAR 01 SOCIAL • 02 BAR • 03 DANCE • 04 END OF LINE",5.0)
    end
    lastBoard=boarded
end)

print("[TRACK 01] final QC client ready v3.9.0")
