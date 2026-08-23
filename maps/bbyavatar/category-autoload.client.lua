-- BBYAVATAR category-to-results bridge v1.
-- Removes an extra tap from discovery/showroom category entry points by seeding
-- the Marketplace search with the selected category and triggering it automatically.
-- State remains session-local; no search text or category preference is persisted.

local AUTO_CATEGORIES = {
    ["TRENDING"] = true,
    ["NEW DROPS"] = true,
    ["STREETWEAR"] = true,
    ["CYBER"] = true,
    ["LUXURY"] = true,
    ["CUTE"] = true,
    ["BALI"] = true,
    ["CREATORS"] = true,
    ["FEATURED"] = true,
}

local lastSeededCategory = nil

local function normalizedCategory(category)
    category = tostring(category or "FEATURED")
    if not AUTO_CATEGORIES[category] then return nil end
    if category == "FEATURED" then return "avatar" end
    if category == "NEW DROPS" then return "new avatar" end
    if category == "CREATORS" then return "ugc avatar" end
    if category == "TRENDING" then return "trending avatar" end
    return string.lower(category)
end

local function findSearchControls()
    local searchBox = nil
    local searchButton = nil
    for _, descendant in ipairs(content:GetDescendants()) do
        if descendant:IsA("TextBox") and not searchBox then
            local placeholder = tostring(descendant.PlaceholderText or "")
            if placeholder:find("Search hair", 1, true) then
                searchBox = descendant
            end
        elseif descendant:IsA("TextButton") and descendant.Text == "SEARCH" and not searchButton then
            searchButton = descendant
        end
        if searchBox and searchButton then break end
    end
    return searchBox, searchButton
end

local function seedCurrentCategoryAndSearch()
    local seed = normalizedCategory(activeCategory)
    if not seed then return end
    local searchBox, searchButton = findSearchControls()
    if not searchBox or not searchButton then return end

    -- Respect a query the player has already typed. We only replace blank text or
    -- the category seed created by this bridge on the immediately previous render.
    local current = tostring(searchBox.Text or "")
    local previousSeed = normalizedCategory(lastSeededCategory)
    if current ~= "" and current ~= previousSeed then return end

    searchBox.Text = seed
    lastSeededCategory = activeCategory
    task.defer(function()
        if searchButton.Parent and frame.Visible and activeTab == "SEARCH" then
            searchButton:Activate()
        end
    end)
end

-- Wrap the final SEARCH renderer after advanced filters have registered theirs.
local baseSearchRenderer = renderers.SEARCH
if typeof(baseSearchRenderer) == "function" then
    renderers.SEARCH = function()
        baseSearchRenderer()
        task.defer(seedCurrentCategoryAndSearch)
    end
end

-- Physical showroom category prompts previously opened DISCOVER first. Keep that
-- handler intact, then route recognized catalog zones directly into live results.
openEvent.OnClientEvent:Connect(function(selectedCategory)
    local category = tostring(selectedCategory or "FEATURED")
    if not AUTO_CATEGORIES[category] then return end
    task.defer(function()
        if frame.Visible and activeCategory == category then
            selectTab("SEARCH")
        end
    end)
end)

print("[BBYAVATAR] Category auto-search bridge ready")