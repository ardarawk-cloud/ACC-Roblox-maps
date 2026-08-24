-- BBYA SOCIAL HUB — MALL NATIVE ROBUX COMMERCE v1
-- Turns selected Mall tenants into native Roblox catalog storefronts.
-- Checkout is ALWAYS handled by Roblox MarketplaceService on the client.
-- No BBYA coins, fake currency, manual Robux transfer or off-platform payment.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",90)
if not root then return end
local mall=root:WaitForChild("BBYAMall",120)
if not mall then return end

-- Wait until base tenant shells are created.
mall:WaitForChild("Tenant_luma",60)
mall:WaitForChild("Tenant_stride",60)
task.wait(1)

local old=mall:FindFirstChild("MallRobuxCommerceV1")
if old then old:Destroy() end
local runtime=Instance.new("Model")
runtime.Name="MallRobuxCommerceV1"
runtime:SetAttribute("Pass","MALL_NATIVE_ROBUX_COMMERCE_V1")
runtime:SetAttribute("NativeRobloxCheckout",true)
runtime:SetAttribute("CustomCurrency",false)
runtime:SetAttribute("CatalogMarketplace",true)
runtime:SetAttribute("OffPlatformPayment",false)
runtime.Parent=mall

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes"
remotes.Parent=ReplicatedStorage
local remote=remotes:FindFirstChild("MallRobuxCommerce") or Instance.new("RemoteEvent")
remote.Name="MallRobuxCommerce"
remote.Parent=remotes

local STORES={
 {tenant="Tenant_luma",key="FASHION",title="LUMA FASHION",subtitle="ROBUX FASHION MARKET",accent=Color3.fromRGB(235,56,147)},
 {tenant="Tenant_stride",key="SHOES",title="STRIDE SNEAKERS",subtitle="ROBUX SHOE MARKET",accent=Color3.fromRGB(229,125,62)},
 {tenant="Tenant_muse",key="BEAUTY",title="MUSE BEAUTY",subtitle="ROBUX BEAUTY MARKET",accent=Color3.fromRGB(137,82,220)},
 {tenant="Tenant_north",key="STREET",title="NORTH LABEL",subtitle="ROBUX STREET MARKET",accent=Color3.fromRGB(62,116,217)},
}

local function addBadge(parent,textValue,accent)
 local badge=Instance.new("BillboardGui")
 badge.Name="NativeRobuxBadge"
 badge.Size=UDim2.fromOffset(210,44)
 badge.StudsOffset=Vector3.new(0,5.7,0)
 badge.AlwaysOnTop=false
 badge.MaxDistance=65
 badge.LightInfluence=.15
 badge.Parent=parent

 local frame=Instance.new("Frame")
 frame.Size=UDim2.fromScale(1,1)
 frame.BackgroundColor3=Color3.fromRGB(12,13,16)
 frame.BackgroundTransparency=.08
 frame.BorderSizePixel=0
 frame.Parent=badge
 local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,10);corner.Parent=frame
 local stroke=Instance.new("UIStroke");stroke.Color=accent;stroke.Thickness=1;stroke.Transparency=.25;stroke.Parent=frame

 local label=Instance.new("TextLabel")
 label.Size=UDim2.fromScale(1,1)
 label.BackgroundTransparency=1
 label.Text="R$  "..textValue
 label.TextColor3=Color3.fromRGB(245,243,239)
 label.Font=Enum.Font.GothamBold
 label.TextSize=15
 label.Parent=frame
end

local activated=0
for _,store in ipairs(STORES) do
 local unit=mall:FindFirstChild(store.tenant)
 if unit and unit:IsA("Model") then
  unit:SetAttribute("NativeRobuxShop",true)
  unit:SetAttribute("CommerceCategory",store.key)
  unit:SetAttribute("Checkout","ROBLOX_MARKETPLACE")

  local door=unit:FindFirstChild("StoreDoor") or unit:FindFirstChild("Interact") or unit:FindFirstChildWhichIsA("BasePart")
  if door and door:IsA("BasePart") then
   -- Remove only a prior instance created by this system.
   local prior=door:FindFirstChild("NativeRobuxShopPrompt")
   if prior then prior:Destroy() end

   local prompt=Instance.new("ProximityPrompt")
   prompt.Name="NativeRobuxShopPrompt"
   prompt.ActionText="SHOP WITH ROBUX"
   prompt.ObjectText=store.title
   prompt.KeyboardKeyCode=Enum.KeyCode.E
   prompt.GamepadKeyCode=Enum.KeyCode.ButtonX
   prompt.MaxActivationDistance=12
   prompt.HoldDuration=.05
   prompt.RequiresLineOfSight=false
   prompt.Parent=door

   addBadge(door,store.subtitle,store.accent)

   prompt.Triggered:Connect(function(player)
    remote:FireClient(player,"open",{
     key=store.key,
     title=store.title,
     subtitle=store.subtitle,
    })
   end)
   activated+=1
  end
 end
end

runtime:SetAttribute("ActiveStores",activated)
print(string.format("[BBYA] Mall Native Robux Commerce v1 online: %d catalog shops use Roblox-native checkout; no custom currency",activated))
