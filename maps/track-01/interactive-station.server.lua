local Workspace=game:GetService("Workspace")
local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")

-- TRACK 01 v3.2 interactive-station pass.
-- Session-only interactions: ticket, check-in, boarding gate, lockers,
-- restricted-door feedback and live departure board. No audio assets.
local deadline=os.clock()+60
repeat task.wait(0.15) until Workspace:GetAttribute("ACC_TRACK01_RESTRICTED_READY") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
local props=world and world:FindFirstChild("Props")
local operations=world and world:FindFirstChild("TRACK01_Operations_v27")
if not (world and props) then return end

local old=world:FindFirstChild("TRACK01_InteractiveStation_v32")
if old then old:Destroy() end
local interactive=Instance.new("Folder")
interactive.Name="TRACK01_InteractiveStation_v32"
interactive.Parent=world

local C={
    black=Color3.fromRGB(15,16,16),
    charcoal=Color3.fromRGB(30,31,31),
    steel=Color3.fromRGB(88,90,88),
    cream=Color3.fromRGB(202,185,148),
    amber=Color3.fromRGB(230,151,68),
    red=Color3.fromRGB(164,38,35),
    green=Color3.fromRGB(70,128,82),
    warm=Color3.fromRGB(236,214,183),
}

local function cf(x,y,z,rx,ry,rz)
    return CFrame.new(x,y,z)*CFrame.Angles(math.rad(rx or 0),math.rad(ry or 0),math.rad(rz or 0))
end

local function part(parent,name,size,frame,color,material,transparency,collide)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=frame
    p.Color=color or C.steel
    p.Material=material or Enum.Material.Metal
    p.Anchored=true
    p.CanCollide=collide==true
    p.CanTouch=false
    p.CanQuery=false
    p.Transparency=transparency or 0
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent
    return p
end

local function surfaceText(target,face,text,textColor,bgColor,font)
    local gui=Instance.new("SurfaceGui")
    gui.Name="InteractiveSignage"
    gui.Face=face
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=46
    gui.LightInfluence=0.15
    gui.Parent=target
    local label=Instance.new("TextLabel")
    label.Name="StatusText"
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundColor3=bgColor or C.black
    label.BackgroundTransparency=0.05
    label.BorderSizePixel=0
    label.Text=text
    label.TextColor3=textColor or C.cream
    label.TextScaled=true
    label.TextWrapped=true
    label.Font=font or Enum.Font.RobotoMono
    label.Parent=gui
    return label
end

local function prompt(parent,action,objectText,hold)
    local p=Instance.new("ProximityPrompt")
    p.Name="TRACK01Prompt"
    p.ActionText=action
    p.ObjectText=objectText
    p.HoldDuration=hold or 0.25
    p.MaxActivationDistance=9
    p.RequiresLineOfSight=false
    p.KeyboardKeyCode=Enum.KeyCode.E
    p.GamepadKeyCode=Enum.KeyCode.ButtonX
    p.Parent=parent
    return p
end

local function flash(partObj,label,text,color,seconds,defaultText,defaultColor)
    partObj.Color=color
    label.Text=text
    label.TextColor3=color
    task.delay(seconds or 1.6,function()
        if partObj.Parent and label.Parent then
            partObj.Color=defaultColor or C.black
            label.Text=defaultText
            label.TextColor3=C.cream
        end
    end)
end

for _,plr in ipairs(Players:GetPlayers()) do
    if plr:GetAttribute("TRACK01_TICKET") == nil then plr:SetAttribute("TRACK01_TICKET",false) end
    if plr:GetAttribute("TRACK01_CHECKED_IN") == nil then plr:SetAttribute("TRACK01_CHECKED_IN",false) end
    if plr:GetAttribute("TRACK01_BOARDED") == nil then plr:SetAttribute("TRACK01_BOARDED",false) end
end
Players.PlayerAdded:Connect(function(plr)
    plr:SetAttribute("TRACK01_TICKET",false)
    plr:SetAttribute("TRACK01_CHECKED_IN",false)
    plr:SetAttribute("TRACK01_BOARDED",false)
end)

-- Ticket machine sits off the main path near the old ticketing queue.
local ticket=part(interactive,"NightTicketMachine",Vector3.new(4.2,6.4,2.4),cf(-19,3.8,-118),C.charcoal,Enum.Material.Metal,0,true)
part(interactive,"TicketMachineTop",Vector3.new(4.5,0.35,2.7),cf(-19,7.15,-118),C.steel,Enum.Material.Metal,0,false)
local ticketScreen=part(interactive,"TicketScreen",Vector3.new(3.4,2.2,0.18),cf(-19,5.0,-116.72),C.black,Enum.Material.Glass,0,false)
local ticketLabel=surfaceText(ticketScreen,Enum.NormalId.Front,"TRACK 01\nNIGHT TICKET",C.amber,C.black,Enum.Font.GothamBold)
local ticketPrompt=prompt(ticket,"CLAIM TICKET","TRACK 01 • NIGHT SERVICE",0.35)
ticketPrompt.Triggered:Connect(function(plr)
    if plr:GetAttribute("TRACK01_TICKET") then
        flash(ticketScreen,ticketLabel,"TICKET ALREADY ISSUED",C.amber,1.4,"TRACK 01\nNIGHT TICKET",C.black)
        return
    end
    plr:SetAttribute("TRACK01_TICKET",true)
    flash(ticketScreen,ticketLabel,"TICKET ISSUED\n→ CHECK-IN",C.green,2.0,"TRACK 01\nNIGHT TICKET",C.black)
end)

-- Check-in terminal reuses the existing security language but stays outside the aisle.
local checkTerminal=part(interactive,"CheckInTerminal",Vector3.new(2.8,4.4,2.0),cf(-26.5,3.1,-92.8),C.charcoal,Enum.Material.Metal,0,true)
local checkScreen=part(interactive,"CheckInScreen",Vector3.new(2.2,1.45,0.16),cf(-26.5,4.3,-91.72),C.black,Enum.Material.Glass,0,false)
local checkLabel=surfaceText(checkScreen,Enum.NormalId.Front,"CHECK-IN\nREADY",C.cream,C.black,Enum.Font.GothamBold)
local checkPrompt=prompt(checkTerminal,"CHECK IN","SECURITY • TRACK 01",0.30)
checkPrompt.Triggered:Connect(function(plr)
    if not plr:GetAttribute("TRACK01_TICKET") then
        flash(checkScreen,checkLabel,"NO TICKET\nRETURN TO TICKETING",C.red,2.0,"CHECK-IN\nREADY",C.black)
        return
    end
    plr:SetAttribute("TRACK01_CHECKED_IN",true)
    flash(checkScreen,checkLabel,"ACCESS VERIFIED\nPLATFORM 01 →",C.green,2.0,"CHECK-IN\nREADY",C.black)
end)

-- Boarding gate is visual/non-colliding. It animates only after valid check-in,
-- so no player can ever get physically trapped by it.
local gateFolder=Instance.new("Folder")
gateFolder.Name="InteractiveBoardingGate"
gateFolder.Parent=interactive
local gatePostL=part(gateFolder,"GatePostL",Vector3.new(0.8,6.0,0.8),cf(-11.0,4.0,-69.3),C.charcoal,Enum.Material.Metal,0,true)
local gatePostR=part(gateFolder,"GatePostR",Vector3.new(0.8,6.0,0.8),cf(5.0,4.0,-69.3),C.charcoal,Enum.Material.Metal,0,true)
local armL=part(gateFolder,"GateArmL",Vector3.new(7.2,0.32,0.32),cf(-7.0,4.5,-69.3),C.cream,Enum.Material.Metal,0,false)
local armR=part(gateFolder,"GateArmR",Vector3.new(7.2,0.32,0.32),cf(1.0,4.5,-69.3),C.cream,Enum.Material.Metal,0,false)
local closedL,closedR=armL.CFrame,armR.CFrame
local gateConsole=part(gateFolder,"GateConsole",Vector3.new(2.1,3.4,1.8),cf(-12.0,2.8,-67.8),C.charcoal,Enum.Material.Metal,0,true)
local gateScreen=part(gateFolder,"GateStatus",Vector3.new(1.7,1.0,0.14),cf(-12.0,3.45,-66.84),C.black,Enum.Material.Glass,0,false)
local gateLabel=surfaceText(gateScreen,Enum.NormalId.Front,"SCAN",C.amber,C.black,Enum.Font.GothamBold)
local gatePrompt=prompt(gateConsole,"SCAN TICKET","PLATFORM 01 GATE",0.25)
local gateBusy=false
local function openGate()
    if gateBusy then return end
    gateBusy=true
    local t=TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
    TweenService:Create(armL,t,{CFrame=closedL*CFrame.Angles(0,0,math.rad(68))}):Play()
    TweenService:Create(armR,t,{CFrame=closedR*CFrame.Angles(0,0,math.rad(-68))}):Play()
    task.delay(3.5,function()
        if armL.Parent and armR.Parent then
            TweenService:Create(armL,t,{CFrame=closedL}):Play()
            TweenService:Create(armR,t,{CFrame=closedR}):Play()
        end
        task.delay(0.5,function() gateBusy=false end)
    end)
end
gatePrompt.Triggered:Connect(function(plr)
    if not plr:GetAttribute("TRACK01_CHECKED_IN") then
        flash(gateScreen,gateLabel,"DENIED",C.red,1.5,"SCAN",C.black)
        return
    end
    plr:SetAttribute("TRACK01_BOARDED",true)
    flash(gateScreen,gateLabel,"GO",C.green,1.8,"SCAN",C.black)
    openGate()
end)

-- Make the existing locker bank usable. Doors slide sideways and remain non-collidable.
if operations then
    local lockerBank=operations:FindFirstChild("LockerBank")
    if lockerBank then
        local doors={}
        for _,obj in ipairs(lockerBank:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name=="LockerDoor" then table.insert(doors,obj) end
        end
        table.sort(doors,function(a,b)
            if math.abs(a.Position.Y-b.Position.Y)>0.1 then return a.Position.Y<b.Position.Y end
            return a.Position.Z<b.Position.Z
        end)
        for i,door in ipairs(doors) do
            door.CanCollide=false
            door.CanTouch=false
            door.CanQuery=false
            local closed=door.CFrame
            local direction=(i%2==0) and 1 or -1
            local openCf=closed*CFrame.new(0,0,2.3*direction)
            local lp=prompt(door,"OPEN / CLOSE",string.format("LOCKER %02d",i),0.20)
            local moving=false
            local isOpen=false
            lp.Triggered:Connect(function()
                if moving then return end
                moving=true
                isOpen=not isOpen
                TweenService:Create(door,TweenInfo.new(0.32,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CFrame=isOpen and openCf or closed}):Play()
                task.delay(0.36,function() moving=false end)
            end)
        end
    end

    -- Existing service doors stay locked but now give clear interactive feedback.
    local facilities=operations:FindFirstChild("Facilities")
    if facilities then
        for _,door in ipairs(facilities:GetDescendants()) do
            if door:IsA("BasePart") and door.Name=="FacilityDoor" then
                local original=door.Color
                local rp=prompt(door,"LOCKED","STAFF / RESTRICTED",0.15)
                local busy=false
                rp.Triggered:Connect(function()
                    if busy then return end
                    busy=true
                    door.Color=C.red
                    task.delay(0.65,function()
                        if door.Parent then door.Color=original end
                        busy=false
                    end)
                end)
            end
        end
    end
end

-- Live departure board cycles venue information at a slow cadence.
local board=props:FindFirstChild("DepartureBoard")
if board then
    local label=board:FindFirstChildWhichIsA("TextLabel",true)
    if label then
        local pages={
            "TRACK 01  •  PLATFORM 01\nBOARDING NOW\nCAR 01  SOCIAL\nCAR 02  BAR\nCAR 03  DANCE\nCAR 04  END OF LINE",
            "NIGHT SERVICE\n22:00  BOARDING\n23:00  LOCAL EXPRESS\n00:30  UNDERGROUND\n02:00  HEADLINER\n04:00  LAST TRAIN",
            "NO DESTINATION\nJUST THE NIGHT\n\nTICKET → CHECK-IN → PLATFORM 01\nRESTRICTED AREAS REMAIN CLOSED",
        }
        task.spawn(function()
            local index=1
            while label.Parent and board.Parent do
                label.Text=pages[index]
                index=(index%#pages)+1
                task.wait(14)
            end
        end)
    end
end

root:SetAttribute("InteractiveVersion","3.2.0")
Workspace:SetAttribute("ACC_TRACK01_INTERACTIVE_READY",true)
Workspace:SetAttribute("ACC_TRACK01_VERSION","3.2.0")
print("[TRACK 01] interactive station ready v3.2.0")
