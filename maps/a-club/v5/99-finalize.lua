-- BBYA V5.2 MODULAR ARCHITECTURE FINALIZE
-- No geometry here. Runtime status + zone count only.
local zoneCount = #zoneIndex:GetChildren()
workspace:SetAttribute("BBYAV5Layout","5.2-modular-greybox")
workspace:SetAttribute("BBYAV5Decor",false)
workspace:SetAttribute("BBYAV5Levels","0/18/36")
workspace:SetAttribute("BBYAV5MainCorridorWidth",14)
workspace:SetAttribute("BBYAV5ZoneCount",zoneCount)
workspace:SetAttribute("BBYAV5InspectionReady",true)
print(string.format("[BBYA] V5.2 modular architecture loaded — %d coded zones, decor OFF",zoneCount))
