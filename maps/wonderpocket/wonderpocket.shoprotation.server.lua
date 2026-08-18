local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:FindFirstChild("WonderPocket_Remotes") or Instance.new("Folder")
remotes.Name = "WonderPocket_Remotes"
remotes.Parent = ReplicatedStorage

local ShopRotation = remotes:FindFirstChild("ShopRotation") or Instance.new("RemoteFunction")
ShopRotation.Name = "ShopRotation"
ShopRotation.Parent = remotes

local catalog = {
    {id="CloudBed", name="Cloud Bed", price=325, rarity="Uncommon"},
    {id="StarLamp", name="Star Lamp", price=125, rarity="Common"},
    {id="RainbowSofa", name="Rainbow Sofa", price=450, rarity="Rare"},
    {id="BunnyChair", name="Bunny Chair", price=180, rarity="Common"},
    {id="ToyChest", name="Toy Chest", price=220, rarity="Common"},
    {id="MiniAquarium", name="Mini Aquarium", price=550, rarity="Rare"},
}

local function rotationForDay(day)
    local rng = Random.new(day * 7919 + 97)
    local pool = table.clone(catalog)
    for i = #pool, 2, -1 do
        local j = rng:NextInteger(1, i)
        pool[i], pool[j] = pool[j], pool[i]
    end
    local out = {}
    for i = 1, math.min(4, #pool) do
        table.insert(out, pool[i])
    end
    return out
end

ShopRotation.OnServerInvoke = function(player)
    local day = math.floor(os.time() / 86400)
    return {
        day = day,
        featured = rotationForDay(day),
        refreshSeconds = 86400 - (os.time() % 86400),
    }
end

print("[WONDERPOCKET] Deterministic daily shop rotation loaded")
