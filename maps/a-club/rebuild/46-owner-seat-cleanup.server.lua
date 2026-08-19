-- BBYA SOCIAL HUB — OWNER HARD CLEANUP
-- Owner request: no lingering CLUB directional signs, no loose ground-floor seats,
-- and no brown wood tables/shelves/counters in the photographed ground-floor area.
-- Preserve VIP partition/door, rooftop access, MENU, Support, Hybrid Auto DJ and street frontage.

local removedSeats=0
local removedSigns=0
local removedBrownFurniture=0

local groundSeatPrefixes={
    "ARRIVAL SEAT",
    "ATRIUM SOFA",
    "CLUB WATCH SOFA",
    "VIP EAST SOFA",
    "VIP WEST SOFA",
    "VIP QUEEN SOFA",
}

local clubSignNames={
    ["ROUTE CLUB"]=true,
    ["CLUB ENTRY WAYFIND"]=true,
    ["CLUB SIGN"]=true,
}

-- Brown ground-floor furniture shown by owner. Rooftop wood is intentionally untouched.
local brownGroundNames={
    ["WELCOME BAR BODY"]=true,
    ["WELCOME BAR TOP"]=true,
    ["WELCOME BAR PINK"]=true,
    ["VIP BAR BODY"]=true,
    ["VIP BAR TOP"]=true,
    ["VIP BAR ACCENT"]=true,
    ["VIP BACKBAR"]=true,
    ["VIP BACKBAR SHELF 4"]=true,
    ["VIP BACKBAR SHELF 7"]=true,
    ["VIP BACKBAR SHELF 10"]=true,
}

local function startsWithAny(name,prefixes)
    for _,prefix in ipairs(prefixes) do
        if string.sub(name,1,#prefix)==prefix then
            return true
        end
    end
    return false
end

local kill={}
for _,obj in ipairs(workspace:GetDescendants()) do
    local name=obj.Name
    if startsWithAny(name,groundSeatPrefixes) then
        table.insert(kill,{obj=obj,kind="seat"})
    elseif clubSignNames[name] then
        table.insert(kill,{obj=obj,kind="sign"})
    elseif brownGroundNames[name] then
        table.insert(kill,{obj=obj,kind="brown"})
    elseif obj:IsA("TextLabel") then
        local text=string.upper(obj.Text or "")
        if text=="CLUB  ←" or text=="CLUB ←" or text=="CLUB / DANCE" then
            local carrier=obj:FindFirstAncestorWhichIsA("BasePart")
            if carrier then
                table.insert(kill,{obj=carrier,kind="sign"})
            end
        end
    end
end

local destroyed={}
for _,row in ipairs(kill) do
    local obj=row.obj
    if obj and obj.Parent and not destroyed[obj] then
        destroyed[obj]=true
        obj:Destroy()
        if row.kind=="seat" then
            removedSeats+=1
        elseif row.kind=="sign" then
            removedSigns+=1
        elseif row.kind=="brown" then
            removedBrownFurniture+=1
        end
    end
end

local seatRemnants=0
local signRemnants=0
local brownRemnants=0
for _,obj in ipairs(workspace:GetDescendants()) do
    if startsWithAny(obj.Name,groundSeatPrefixes) then seatRemnants+=1 end
    if clubSignNames[obj.Name] then signRemnants+=1 end
    if brownGroundNames[obj.Name] then brownRemnants+=1 end
    if obj:IsA("TextLabel") then
        local text=string.upper(obj.Text or "")
        if text=="CLUB  ←" or text=="CLUB ←" or text=="CLUB / DANCE" then signRemnants+=1 end
    end
end

workspace:SetAttribute("BBYAGroundFloorSeatingCleared",seatRemnants==0)
workspace:SetAttribute("BBYAGroundFloorSeatsRemoved",removedSeats)
workspace:SetAttribute("BBYAGroundFloorSeatRemnants",seatRemnants)
workspace:SetAttribute("BBYAClubDirectionalSignsCleared",signRemnants==0)
workspace:SetAttribute("BBYAClubDirectionalSignsRemoved",removedSigns)
workspace:SetAttribute("BBYAClubDirectionalSignRemnants",signRemnants)
workspace:SetAttribute("BBYABrownGroundFurnitureCleared",brownRemnants==0)
workspace:SetAttribute("BBYABrownGroundFurnitureRemoved",removedBrownFurniture)
workspace:SetAttribute("BBYABrownGroundFurnitureRemnants",brownRemnants)
workspace:SetAttribute("BBYAOwnerHardCleanup","NO_CLUB_SIGN_NO_GROUND_SEATS_NO_BROWN_GROUND_FURNITURE")
