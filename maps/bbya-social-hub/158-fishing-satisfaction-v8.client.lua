-- BBYA SOCIAL HUB — FISHING SATISFACTION v8 CLIENT
-- Compact catch trophy reveal driven by existing Progression V4 events.
-- Does not own CAST/STRIKE/REEL, fishing visibility, chance, economy, or progression math.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local fishingGui=playerGui:WaitForChild("BBYAFishingUI",35)
if not fishingGui then return end

local v4=ReplicatedStorage:WaitForChild("BBYAFishingV4",35)
local stateRemote=v4 and v4:WaitForChild("State",10)
if not stateRemote then return end

local old=fishingGui:FindFirstChild("CatchTrophyRevealV8")
if old then old:Destroy() end

local rarityColors={
    COMMON=Color3.fromRGB(196,202,207),
    UNCOMMON=Color3.fromRGB(96,213,131),
    RARE=Color3.fromRGB(74,161,242),
    EPIC=Color3.fromRGB(177,102,236),
    LEGENDARY=Color3.fromRGB(246,188,72),
    MYTHIC=Color3.fromRGB(244,99,173),
}

local card=Instance.new("Frame")
card.Name="CatchTrophyRevealV8"
card.AnchorPoint=Vector2.new(.5,0)
card.Position=UDim2.new(.5,0,.18,0)
card.Size=UDim2.fromOffset(340,72)
card.BackgroundColor3=Color3.fromRGB(13,16,20)
card.BackgroundTransparency=1
card.BorderSizePixel=0
card.Visible=false
card.ZIndex=96
card.Parent=fishingGui

local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(0,12)
corner.Parent=card

local stroke=Instance.new("UIStroke")
stroke.Thickness=1.4
stroke.Transparency=1
stroke.Parent=card

local scale=Instance.new("UIScale")
scale.Scale=.92
scale.Parent=card

local tag=Instance.new("TextLabel")
tag.BackgroundTransparency=1
tag.Position=UDim2.fromOffset(14,7)
tag.Size=UDim2.new(1,-28,0,15)
tag.Font=Enum.Font.GothamBlack
tag.TextSize=9
tag.TextXAlignment=Enum.TextXAlignment.Left
tag.TextColor3=Color3.fromRGB(235,190,82)
tag.TextTransparency=1
tag.ZIndex=97
tag.Parent=card

local title=Instance.new("TextLabel")
title.BackgroundTransparency=1
title.Position=UDim2.fromOffset(14,22)
title.Size=UDim2.new(1,-28,0,25)
title.Font=Enum.Font.GothamBlack
title.TextSize=17
title.TextXAlignment=Enum.TextXAlignment.Left
title.TextColor3=Color3.fromRGB(246,247,248)
title.TextTransparency=1
title.TextTruncate=Enum.TextTruncate.AtEnd
title.ZIndex=97
title.Parent=card

local detail=Instance.new("TextLabel")
detail.BackgroundTransparency=1
detail.Position=UDim2.fromOffset(14,48)
detail.Size=UDim2.new(1,-28,0,16)
detail.Font=Enum.Font.GothamBold
detail.TextSize=10
detail.TextXAlignment=Enum.TextXAlignment.Left
detail.TextColor3=Color3.fromRGB(167,174,183)
detail.TextTransparency=1
detail.TextTruncate=Enum.TextTruncate.AtEnd
detail.ZIndex=97
detail.Parent=card

local serial=0
local function reveal(payload)
    if type(payload)~="table" then return end
    serial+=1
    local mine=serial

    local rarity=tostring(payload.rarity or "COMMON")
    local color=rarityColors[rarity] or Color3.fromRGB(235,190,82)
    local variant=tostring(payload.variant or payload.fish or "Fish")
    local mutation=tostring(payload.mutation or "NORMAL")
    local sizeGrade=tostring(payload.size or "")
    local weight=tonumber(payload.weight) or 0
    local xp=tonumber(payload.xp) or 0

    local headline=rarity
    if payload.newSpecies then headline="NEW SPECIES"
    elseif payload.newVariant then headline="NEW VARIANT"
    elseif payload.newMutation then headline="NEW MUTATION"
    elseif sizeGrade=="TITAN" then headline="TITAN CATCH"
    elseif sizeGrade=="GIANT" then headline="GIANT CATCH"
    elseif rarity=="MYTHIC" then headline="MYTHIC TROPHY"
    elseif rarity=="LEGENDARY" then headline="LEGENDARY TROPHY"
    end

    local bits={}
    if sizeGrade~="" and sizeGrade~="NORMAL" then table.insert(bits,sizeGrade) end
    if mutation~="" and mutation~="NORMAL" then table.insert(bits,mutation) end
    table.insert(bits,string.format("%.2f kg",weight))
    if xp>0 then table.insert(bits,"+"..math.floor(xp).." XP") end

    tag.Text=headline
    tag.TextColor3=color
    title.Text=variant
    detail.Text=table.concat(bits,"  •  ")
    stroke.Color=color

    card.Visible=true
    card.BackgroundTransparency=1
    stroke.Transparency=1
    tag.TextTransparency=1
    title.TextTransparency=1
    detail.TextTransparency=1
    scale.Scale=.92

    TweenService:Create(card,TweenInfo.new(.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=.08}):Play()
    TweenService:Create(stroke,TweenInfo.new(.18),{Transparency=.22}):Play()
    TweenService:Create(scale,TweenInfo.new(.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
    TweenService:Create(tag,TweenInfo.new(.16),{TextTransparency=0}):Play()
    TweenService:Create(title,TweenInfo.new(.16),{TextTransparency=0}):Play()
    TweenService:Create(detail,TweenInfo.new(.16),{TextTransparency=0}):Play()

    local hold=(rarity=="MYTHIC" or payload.newSpecies or payload.newVariant) and 3.7 or 2.8
    task.delay(hold,function()
        if mine~=serial or not card.Parent then return end
        TweenService:Create(card,TweenInfo.new(.20),{BackgroundTransparency=1}):Play()
        TweenService:Create(stroke,TweenInfo.new(.18),{Transparency=1}):Play()
        TweenService:Create(tag,TweenInfo.new(.16),{TextTransparency=1}):Play()
        TweenService:Create(title,TweenInfo.new(.16),{TextTransparency=1}):Play()
        TweenService:Create(detail,TweenInfo.new(.16),{TextTransparency=1}):Play()
        TweenService:Create(scale,TweenInfo.new(.20,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Scale=.96}):Play()
        task.delay(.22,function()
            if mine==serial and card.Parent then card.Visible=false end
        end)
    end)
end

stateRemote.OnClientEvent:Connect(function(kind,payload)
    if kind=="CatchEnhanced" then reveal(payload) end
end)

card:SetAttribute("CatchPresentationV8",true)
card:SetAttribute("CompactMobileRevealV8",true)
print("[BBYA] Fishing Satisfaction v8 client online: compact progression-aware trophy reveal")
