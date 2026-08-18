-- BBYA V5.2 INSPECTION POLISH
-- Keep zone diagnostics in the HUD; remove oversized world inspection boards.

for _,obj in ipairs(root:GetDescendants()) do
    if obj:IsA("BasePart") and string.find(obj.Name, "INSPECTION TAG", 1, true) then
        obj:Destroy()
    end
end

workspace:SetAttribute("BBYAV5WorldInspectionTags", "HUD_ONLY")
