local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local Workspace=game:GetService("Workspace")

local player=Players.LocalPlayer
if not player then return end
local playerGui=player:WaitForChild("PlayerGui",20)
if not playerGui then return end

local gui=Instance.new("ScreenGui")
gui.Name="TRACK01_SocialUI"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=68
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.Parent=playerGui

local activeFrame
local photoRestoreToken=0

local function toast(kind,text)
    if activeFrame then activeFrame:Destroy() end
    local frame=Instance.new("Frame")
    activeFrame=frame
    frame.Name="SocialToast"
    frame.AnchorPoint=Vector2.new(0.5,1)
    frame.Position=UDim2.fromScale(0.5,0.90)
    frame.Size=UDim2.fromScale(0.56,0.075)
    frame.BackgroundColor3=Color3.fromRGB(14,15,15)
    frame.BackgroundTransparency=0.12
    frame.BorderSizePixel=0
    frame.Parent=gui

    local size=Instance.new("UISizeConstraint")
    size.MinSize=Vector2.new(250,58)
    size.MaxSize=Vector2.new(650,78)
    size.Parent=frame
    local corner=Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,5)
    corner.Parent=frame
    local stroke=Instance.new("UIStroke")
    stroke.Color=(kind=="DANCE") and Color3.fromRGB(150,49,43) or Color3.fromRGB(119,88,55)
    stroke.Thickness=1
    stroke.Transparency=0.25
    stroke.Parent=frame

    local kicker=Instance.new("TextLabel")
    kicker.BackgroundTransparency=1
    kicker.Position=UDim2.fromScale(0.035,0.08)
    kicker.Size=UDim2.fromScale(0.93,0.30)
    kicker.Font=Enum.Font.RobotoMono
    kicker.Text="TRACK 01 • "..kind
    kicker.TextColor3=Color3.fromRGB(211,179,127)
    kicker.TextSize=12
    kicker.TextXAlignment=Enum.TextXAlignment.Left
    kicker.Parent=frame

    local body=Instance.new("TextLabel")
    body.BackgroundTransparency=1
    body.Position=UDim2.fromScale(0.035,0.39)
    body.Size=UDim2.fromScale(0.93,0.47)
    body.Font=Enum.Font.GothamMedium
    body.Text=text
    body.TextColor3=Color3.fromRGB(236,227,210)
    body.TextScaled=true
    body.TextWrapped=true
    body.TextXAlignment=Enum.TextXAlignment.Left
    body.Parent=frame
    local t=Instance.new("UITextSizeConstraint")
    t.MinTextSize=11
    t.MaxTextSize=17
    t.Parent=body

    task.delay(4.2,function()
        if not frame.Parent then return end
        TweenService:Create(frame,TweenInfo.new(0.45),{BackgroundTransparency=1}):Play()
        TweenService:Create(kicker,TweenInfo.new(0.45),{TextTransparency=1}):Play()
        TweenService:Create(body,TweenInfo.new(0.45),{TextTransparency=1}):Play()
        TweenService:Create(stroke,TweenInfo.new(0.45),{Transparency=1}):Play()
        task.wait(0.5)
        if frame.Parent then frame:Destroy() end
        if activeFrame==frame then activeFrame=nil end
    end)
end

local function photoMode(text)
    photoRestoreToken+=1
    local token=photoRestoreToken
    toast("PHOTO MODE",text.." • FRAME YOUR SHOT")
    local camera=Workspace.CurrentCamera
    if not camera then return end
    local original=camera.FieldOfView
    TweenService:Create(camera,TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{FieldOfView=65}):Play()
    task.delay(6,function()
        if token~=photoRestoreToken then return end
        if camera and camera.Parent then
            TweenService:Create(camera,TweenInfo.new(0.45),{FieldOfView=original}):Play()
        end
    end)
end

local lastToken=player:GetAttribute("TRACK01_SOCIAL_TOKEN") or 0
player:GetAttributeChangedSignal("TRACK01_SOCIAL_TOKEN"):Connect(function()
    local token=player:GetAttribute("TRACK01_SOCIAL_TOKEN") or 0
    if token==lastToken then return end
    lastToken=token
    local kind=player:GetAttribute("TRACK01_SOCIAL_KIND") or "SOCIAL"
    local text=player:GetAttribute("TRACK01_SOCIAL_TEXT") or "TRACK 01"
    if kind=="PHOTO" then
        photoMode(text)
    else
        toast(kind,text)
    end
end)

print("[TRACK 01] social interaction client ready v3.8.0")
