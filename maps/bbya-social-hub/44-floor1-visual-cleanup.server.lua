-- BBYA SOCIAL HUB — FLOOR 1 VISUAL CLEANUP v2
-- Removes front-of-house ceiling fins that visually intrude into the dance floor,
-- keeps the raised tall-avatar entrance datum, and grounds Main Club overhead fixtures.
-- Scope is Main Club / Floor 1 only. Underground, audio, stage, DJ booth, VIP and Mall are untouched.

local Workspace = game:GetService("Workspace")
local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 20)
if not root then return end

local front = root:WaitForChild("Floor1FrontPremium", 20)
if not front then return end

local transition = front:WaitForChild("EntranceToClubTransition", 10)
if not transition then return end

local HEADROOM_DELTA = 8
local RAISED_TRANSITION_Y = 14.2 + HEADROOM_DELTA
local RAISED_DOWNLIGHT_Y = 13.98 + HEADROOM_DELTA

-- Remove the wood ceiling-fin treatment completely. The old final fin at Z=-5
-- sat inside the dance-floor boundary and read as a random wooden object in the club.
for _, obj in ipairs(transition:GetChildren()) do
    if obj.Name:match("^CeilingFin") or obj.Name:match("^FinLight") then
        obj:Destroy()
    end
end

local C = {
    black = Color3.fromRGB(10,10,13),
    metal = Color3.fromRGB(30,29,34),
    warm = Color3.fromRGB(255,198,142),
}

local function part(name,size,cf,color,material,parent)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=cf
    p.Color=color
    p.Material=material or Enum.Material.Metal
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=true
    p.CastShadow=true
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent or transition
    return p
end

-- Keep the transition treatment entirely south of the dance-floor boundary.
-- IMPORTANT: these panels used to remain at Y=14 after the +8 headroom pass, which
-- made them visibly float below the new entrance/ceiling line in daytime. Build them
-- directly on the raised datum instead.
for i,z in ipairs({-18.0,-15.2,-12.4}) do
    part("TransitionCeilingPanel"..i,Vector3.new(18.5,.24,1.15),CFrame.new(0,RAISED_TRANSITION_Y,z),C.metal,Enum.Material.Metal)
    local lamp=part("TransitionDownlight"..i,Vector3.new(.55,.18,.55),CFrame.new(0,RAISED_DOWNLIGHT_Y,z),C.black,Enum.Material.Metal)
    lamp.Shape=Enum.PartType.Cylinder
    lamp.CFrame=lamp.CFrame*CFrame.Angles(0,0,math.rad(90))
    local light=Instance.new("SpotLight")
    light.Face=Enum.NormalId.Bottom
    light.Color=C.warm
    light.Brightness=.7
    light.Range=15
    light.Angle=46
    light.Shadows=true
    light.Parent=lamp
end

-- Safety cleanup: no WoodPlanks material is allowed over the main dance rectangle.
for _, obj in ipairs(front:GetDescendants()) do
    if obj:IsA("BasePart") and obj.Material==Enum.Material.WoodPlanks then
        local pos=obj.Position
        if pos.X>-26 and pos.X<32 and pos.Z>-10 and pos.Z<32 then
            obj:Destroy()
        end
    end
end

local function setVerticalSpan(p,bottomY,topY)
    if not p or not p:IsA("BasePart") then return end
    local h=math.max(.08,topY-bottomY)
    p.Size=Vector3.new(p.Size.X,h,p.Size.Z)
    p.CFrame=CFrame.new(p.Position.X,(bottomY+topY)/2,p.Position.Z)*p.CFrame.Rotation
end

local function shiftOnce(p,delta,mark)
    if not p or not p:IsA("BasePart") or p:GetAttribute(mark) then return end
    p.CFrame=p.CFrame+Vector3.new(0,delta,0)
    p:SetAttribute(mark,true)
end

local function extendUpTo(p,topY,mark)
    if not p or not p:IsA("BasePart") or p:GetAttribute(mark) then return end
    local bottom=p.Position.Y-p.Size.Y/2
    setVerticalSpan(p,bottom,topY)
    p:SetAttribute(mark,true)
end

local function addDrop(folder,name,x,z,bottomY,topY,width)
    if topY<=bottomY+.04 then return end
    local h=topY-bottomY
    part(name,Vector3.new(width or .10,h,width or .10),CFrame.new(x,(bottomY+topY)/2,z),C.black,Enum.Material.Metal,folder)
end

-- Reconcile builders that spawn after the tall-avatar pass. This is intentionally
-- late and idempotent: it fixes only visual attachment/headroom, never venue systems.
local function groundRaisedMainClub()
    local realism=root:FindFirstChild("MainClubRealism")
    local premium=root:FindFirstChild("MainClubPremiumV4")
    local beauty=root:FindFirstChild("MainClubBeautyV5")
    if not realism or not premium or not beauty then return end

    local architecture=realism:FindFirstChild("Architecture")
    local ceiling=architecture and architecture:FindFirstChild("CeilingArchitecture")
    local shell=architecture and architecture:FindFirstChild("PremiumShell")
    local ceilingField=ceiling and ceiling:FindFirstChild("CeilingField")
    if not ceiling or not shell or not ceilingField or not ceilingField:IsA("BasePart") then return end

    local ceilingBottom=ceilingField.Position.Y-ceilingField.Size.Y/2

    -- The old front shell posts became giant black sticks after only their cores were
    -- stretched to the raised ceiling. They are the intrusive entrance pillars seen
    -- from the owner screenshot. Remove the front pair only; rear structural rhythm stays.
    for i=1,4 do
        local core=shell:FindFirstChild("ColumnCore"..i)
        if core and core:IsA("BasePart") and core.Position.Z<0 then
            local face=shell:FindFirstChild("ColumnFace"..i)
            local glow=shell:FindFirstChild("ColumnGlow"..i)
            if face then face:Destroy() end
            if glow then glow:Destroy() end
            core:Destroy()
        elseif core and core:IsA("BasePart") then
            -- Beauty v7 may reset the rear core size after the headroom script. Reconnect
            -- surviving rear columns to the raised ceiling without moving their feet.
            extendUpTo(core,ceilingBottom+.05,"BBYAVisualGroundedV2")
        end
    end

    -- Premium v4 + Beauty v7 still author their entrance canopy/soffit at the old low
    -- Y datum. Move only overhead reveal pieces and plaque to the same +8 headroom line.
    local reveal=premium:FindFirstChild("MainClubEntranceReveal",true)
    if reveal then
        for _,name in ipairs({"RevealCanopy","RevealCanopyLip","PortalLintel","PortalLintelReveal","MainClubPlaque"}) do
            shiftOnce(reveal:FindFirstChild(name),HEADROOM_DELTA,"BBYAEntranceRevealRaisedV2")
        end
        for _,side in ipairs({-1,1}) do
            extendUpTo(reveal:FindFirstChild("PortalPier_"..side),19.9,"BBYAEntranceRevealRaisedV2")
            extendUpTo(reveal:FindFirstChild("PortalFace_"..side),18.9,"BBYAEntranceRevealRaisedV2")
            extendUpTo(reveal:FindFirstChild("ChampagneInlay_"..side),18.4,"BBYAEntranceRevealRaisedV2")
        end
    end

    local facade=beauty:FindFirstChild("MobilePremiumFacadeV7",true)
    if facade then
        for _,name in ipairs({"FloatingSoffit","SoffitShadow","SoffitChampagneReveal"}) do
            shiftOnce(facade:FindFirstChild(name),HEADROOM_DELTA,"BBYAMobileSoffitRaisedV2")
        end
    end

    -- Rebuild only the invisible-looking attachment details. The lighting fixtures
    -- themselves keep their approved colors/positions; dark metal suspension points make
    -- them read as physically mounted instead of floating in daylight.
    local oldSupports=root:FindFirstChild("MainClubCeilingGroundingV2")
    if oldSupports then oldSupports:Destroy() end
    local supports=Instance.new("Model")
    supports.Name="MainClubCeilingGroundingV2"
    supports:SetAttribute("Scope","MAIN_CLUB_VISUAL_ONLY")
    supports:SetAttribute("CeilingBottomY",ceilingBottom)
    supports.Parent=root

    -- Beauty ceiling fills: two short hangers per fixture.
    for i=1,6 do
        local fixture=beauty:FindFirstChild("CeilingFillFixture_"..i,true)
        if fixture and fixture:IsA("BasePart") then
            local fixtureTop=fixture.Position.Y+fixture.Size.Y/2
            for _,dx in ipairs({-1.05,1.05}) do
                addDrop(supports,"CeilingFillDrop_"..i.."_"..tostring(dx),fixture.Position.X+dx,fixture.Position.Z,fixtureTop,ceilingBottom,.08)
            end
        end
    end

    -- Bar pendants: extend the existing stem all the way to the new ceiling underside.
    for i=1,3 do
        local stem=beauty:FindFirstChild("BarPendantStem_"..i,true)
        local shade=beauty:FindFirstChild("BarPendantShade_"..i,true)
        if stem and stem:IsA("BasePart") and shade and shade:IsA("BasePart") then
            local bottom=shade.Position.Y+shade.Size.Y/2
            setVerticalSpan(stem,bottom,ceilingBottom)
            stem:SetAttribute("BBYAPendantGroundedV2",true)
        end
    end

    -- Moving heads: each clamp gets a compact ceiling drop. Active head/lens tweens stay untouched.
    local rig=premium:FindFirstChild("DanceFloorMovingHeads",true)
    if rig then
        for i=1,8 do
            local moving=rig:FindFirstChild("MovingHead_"..i)
            local clamp=moving and moving:FindFirstChild("Clamp")
            if clamp and clamp:IsA("BasePart") then
                local clampTop=clamp.Position.Y+clamp.Size.Y/2
                addDrop(supports,"MovingHeadDrop_"..i,clamp.Position.X,clamp.Position.Z,clampTop,ceilingBottom,.10)
            end
        end
    end

    -- Acoustic rafts sit below the ceiling by design; add subtle twin suspension pins.
    for i=1,6 do
        local raft=ceiling:FindFirstChild("AcousticRaft"..i,true)
        if raft and raft:IsA("BasePart") then
            local raftTop=raft.Position.Y+raft.Size.Y/2
            for side=-1,1,2 do
                local anchor=raft.CFrame:PointToWorldSpace(Vector3.new(side*2.25,0,0))
                addDrop(supports,"RaftDrop_"..i.."_"..side,anchor.X,anchor.Z,raftTop,ceilingBottom,.07)
            end
        end
    end

    -- Main truss needs four obvious structural drops rather than appearing suspended in air.
    local truss=ceiling:FindFirstChild("MainTruss",true)
    if truss then
        for _,x in ipairs({-20,26}) do
            for _,z in ipairs({4,32}) do
                addDrop(supports,"TrussDrop_"..x.."_"..z,x,z,25.9,ceilingBottom,.12)
            end
        end
    end

    root:SetAttribute("BBYAMainClubFloatingGeometryFix","V2_GROUNDED")
    root:SetAttribute("BBYAMainClubFrontObstructionRemoved",true)
    root:SetAttribute("BBYAMainClubRaisedHeadroomPreserved",true)
end

for _,delaySeconds in ipairs({4,12,28}) do
    task.delay(delaySeconds,groundRaisedMainClub)
end

print("[BBYA] Floor 1 visual cleanup v2 loaded: raised transition + grounded Main Club ceiling; front obstruction removed")
