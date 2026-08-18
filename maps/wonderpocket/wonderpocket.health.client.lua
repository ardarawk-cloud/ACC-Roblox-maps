local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("WP_ClosedTestHealth")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "WP_ClosedTestHealth"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local button = Instance.new("TextButton")
button.AnchorPoint = Vector2.new(1,0)
button.Position = UDim2.new(1,-10,0,72)
button.Size = UDim2.fromOffset(74,34)
button.BackgroundColor3 = Color3.fromRGB(35,45,80)
button.TextColor3 = Color3.new(1,1,1)
button.Text = "TEST"
button.Font = Enum.Font.GothamBold
button.TextSize = 13
button.Parent = gui
Instance.new("UICorner",button).CornerRadius = UDim.new(0,10)

local panel = Instance.new("TextLabel")
panel.AnchorPoint = Vector2.new(1,0)
panel.Position = UDim2.new(1,-10,0,112)
panel.Size = UDim2.new(1,-20,1,-128)
panel.BackgroundColor3 = Color3.fromRGB(20,25,45)
panel.BackgroundTransparency = .08
panel.TextColor3 = Color3.fromRGB(235,242,255)
panel.TextXAlignment = Enum.TextXAlignment.Left
panel.TextYAlignment = Enum.TextYAlignment.Top
panel.Font = Enum.Font.Code
panel.TextSize = 12
panel.TextWrapped = true
panel.Visible = false
panel.Parent = gui
local limit=Instance.new("UISizeConstraint")
limit.MaxSize=Vector2.new(350,460)
limit.MinSize=Vector2.new(285,340)
limit.Parent=panel
Instance.new("UICorner",panel).CornerRadius = UDim.new(0,12)

local function yes(v) return v and "OK" or "WAIT" end
local function fail(v) return v and "FAIL" or "OK" end
local function bit(v) return v and "Y" or "-" end

local function refresh()
    local remotes=ReplicatedStorage:FindFirstChild("WONDERPOCKET_Remotes")
    local plotId=tonumber(player:GetAttribute("WP_PlotIndex")) or 0
    local tutorialStep=tonumber(player:GetAttribute("WP_TutorialStep")) or 0
    local tutorialStepId=tostring(player:GetAttribute("WP_TutorialStepId") or "-")
    local coins=tonumber(player:GetAttribute("Coins")) or 0
    local stars=tonumber(player:GetAttribute("Stars")) or 0
    local seeds=tonumber(player:GetAttribute("CarrotSeed")) or 0
    local txnSeq=tonumber(player:GetAttribute("WP_EconTxnSeq")) or 0
    local lastAction=tostring(player:GetAttribute("WP_LastEconomyAction") or "-")
    local lastItem=tostring(player:GetAttribute("WP_LastEconomyItem") or "-")
    local lastDelta=tonumber(player:GetAttribute("WP_LastEconomyDeltaCoins")) or 0
    local deadline=tonumber(player:GetAttribute("WP_AdventureDeadline")) or 0
    local secondsLeft=deadline>0 and math.max(0,deadline-os.time()) or 0
    local readOnly=player:GetAttribute("WP_DataReadOnly")==true
    local saveFreeze=player:GetAttribute("WP_SaveHealthReadOnly")==true
    local saveFailure=tostring(player:GetAttribute("WP_SaveHealthFailure") or "-")
    local mainFail=player:GetAttribute("WP_DataLoadFailed")==true
    local invFail=player:GetAttribute("WP_InventoryLoadFailed")==true
    local furnFail=player:GetAttribute("WP_FurnitureLoadFailed")==true
    local gardenFail=player:GetAttribute("WP_GardenLoadFailed")==true
    local dexFail=player:GetAttribute("WP_DexLoadFailed")==true
    local dataSafe=not (readOnly or saveFreeze or mainFail or invFail or furnFail or gardenFail or dexFail)

    local started=player:GetAttribute("WP_TutorialStarted")==true
    local metWondi=player:GetAttribute("WP_Tutorial_MetWondi")==true
    local planted=(tonumber(player:GetAttribute("WP_PlantedCount")) or 0)>=1
    local purchased=(tonumber(player:GetAttribute("WP_PurchasedFurnitureCount")) or 0)>=1
    local placed=(tonumber(player:GetAttribute("WP_PlacedCount")) or 0)>=1
    local harvested=(tonumber(player:GetAttribute("WP_HarvestCount")) or 0)>=1
    local treasure=(tonumber(player:GetAttribute("WP_TreasureProgress")) or 0)>=1 or player:GetAttribute("WP_TreasureIslandComplete")==true
    local complete=player:GetAttribute("WP_OnboardingComplete")==true

    local dexFound=0
    for _,attr in ipairs({
        "WP_DEX_Wondies_Bubbi","WP_DEX_Wondies_Flamo","WP_DEX_Wondies_Mossy","WP_DEX_Wondies_Lumi","WP_DEX_Wondies_Zappy","WP_DEX_Wondies_Puffy",
        "WP_DEX_Plants_Carrot","WP_DEX_Plants_Strawberry","WP_DEX_Plants_Sunflower",
        "WP_DEX_Furniture_CloudBed","WP_DEX_Furniture_StarLamp","WP_DEX_Furniture_RainbowSofa","WP_DEX_Furniture_BunnyChair","WP_DEX_Furniture_ToyChest","WP_DEX_Furniture_MiniAquarium",
        "WP_DEX_Badges_TreasureIsland",
        "WP_DEX_Biomes_MeadowPocket","WP_DEX_Biomes_BeachIsland","WP_DEX_Biomes_SnowWorld","WP_DEX_Biomes_CandyWorld","WP_DEX_Biomes_SpaceWorld",
    }) do if player:GetAttribute(attr)==true then dexFound+=1 end end

    panel.Text=string.format(
        " WONDERPOCKET v1.3 CLOSED TEST\n\n DATA SAFETY: %s\n Read Only: %s  Save Freeze: %s\n Freeze Cause: %s\n Load Fail M/I/F/G/D: %s/%s/%s/%s/%s\n\n Data Load: %s\n Player Save: %s\n Inventory: %s / Save %s\n Furniture: %s / Save %s\n Garden: %s / Save %s\n WonderDex: %s / Save %s (%s/21)\n Remotes: %s\n Plot/Home: %s / %s\n\n JOURNEY S:%s B:%s P:%s Buy:%s Pl:%s H:%s T:%s C:%s\n Step: %s (%s)\n\n Economy: %sC / %sS / %s seeds\n Txn #%s: %s %s (%+dC)\n Harvests: %s\n Starter Quest: %s\n Adventure: %s (%ss)\n Players: %s / Peak %s",
        dataSafe and "OK" or "READ-ONLY",
        readOnly and "YES" or "NO",
        saveFreeze and "YES" or "NO",
        saveFailure,
        fail(mainFail),fail(invFail),fail(furnFail),fail(gardenFail),fail(dexFail),
        yes(player:GetAttribute("WP_DataLoaded")==true),
        yes(player:GetAttribute("WP_DataSaveHealthy")~=false),
        yes(player:GetAttribute("WP_InventoryLoaded")==true),yes(player:GetAttribute("WP_InventorySaveHealthy")~=false),
        yes(player:GetAttribute("WP_FurnitureLoaded")==true),yes(player:GetAttribute("WP_FurnitureSaveHealthy")~=false),
        yes(player:GetAttribute("WP_GardenReady")==true),yes(player:GetAttribute("WP_GardenSaveHealthy")~=false),
        yes(player:GetAttribute("WP_DexLoaded")==true),yes(player:GetAttribute("WP_DexSaveHealthy")~=false),tostring(dexFound),
        yes(remotes~=nil),
        plotId>0 and tostring(plotId) or "WAIT",yes(player:GetAttribute("WP_HomeReady")==true),
        bit(started),bit(metWondi),bit(planted),bit(purchased),bit(placed),bit(harvested),bit(treasure),bit(complete),
        tostring(tutorialStep),tutorialStepId,
        tostring(coins),tostring(stars),tostring(seeds),
        tostring(txnSeq),lastAction,lastItem,lastDelta,
        tostring(tonumber(player:GetAttribute("WP_HarvestCount")) or 0),
        tostring(player:GetAttribute("WP_Quest_Starter") or "-"),
        tostring(player:GetAttribute("WP_ActiveAdventure") or "-"),tostring(secondsLeft),
        tostring(workspace:GetAttribute("WP_CurrentPlayers") or 0),
        tostring(workspace:GetAttribute("WP_PeakPlayers") or 0)
    )
end

button.Activated:Connect(function()
    panel.Visible=not panel.Visible
    if panel.Visible then refresh() end
end)

task.spawn(function()
    while task.wait(2) do if panel.Visible then refresh() end end
end)

print("[WONDERPOCKET] v1.3 closed-test health + first-journey checklist ready")
