-- BBYA PASAR MALAM v344 — operator booth control binding
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local market=root:WaitForChild("BBYANightMarket",30)
if not market then return end
local premium=market:WaitForChild("PremiumNightMarketV3",30)
if not premium then return end
task.wait(.6)

local function hideControl(control)
 if not control then return end
 if control:IsA("BasePart") then control.Transparency=1;control.CanCollide=false;control.CanTouch=false end
end
local function bind(oldControlName,boothName)
 local control=market:FindFirstChild(oldControlName)
 local booth=premium:FindFirstChild(boothName,true)
 local counter=booth and booth:FindFirstChild("Counter")
 local oldPrompt=control and control:FindFirstChildOfClass("ProximityPrompt")
 if oldPrompt and counter then oldPrompt.Parent=counter end
 hideControl(control)
end

bind("CarouselControl","CarouselOperator")
bind("KoraControl","KoraOperator")

-- Premium Ferris has its own upright-gondola motion and its own operator prompt.
local oldFerrisControl=market:FindFirstChild("FerrisControl")
if oldFerrisControl then
 local p=oldFerrisControl:FindFirstChildOfClass("ProximityPrompt")
 if p then p.Enabled=false end
 hideControl(oldFerrisControl)
end
local oldFerris=market:FindFirstChild("PlayableFerrisWheel")
if oldFerris then
 for _,d in ipairs(oldFerris:GetDescendants()) do
  if d:IsA("ProximityPrompt") then d.Enabled=false end
 end
end

market:SetAttribute("OperatorBoothControlsBound",true)
print("[BBYA] Pasar Malam v344 operator controls bound to premium booths")
