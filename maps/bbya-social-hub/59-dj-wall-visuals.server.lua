-- BBYA SOCIAL HUB — DJ WALL SERVER FALLBACK v2
-- Static fallback only. Real music-reactive rendering is client-owned by 62-dj-wall-render.client.lua.
-- Message mode remains owned by 50-dj-wall-message.server.lua.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",20)
if not root then return end
local system=root:WaitForChild("DJWallMessageSystem",20)
if not system then return end
local screen=system:FindFirstChild("PrestigeLED",true)
if not screen then return end
local gui=screen:FindFirstChild("DJWallUI")
if not gui then return end
local bg=gui:FindFirstChildWhichIsA("Frame")
if not bg then return end
local idle=bg:FindFirstChild("IdleVisuals")
if not idle then return end

local old=idle:FindFirstChild("BBYARandomVisuals")
if old then old:Destroy() end
local previous=idle:FindFirstChild("BBYAServerFallback")
if previous then previous:Destroy() end

local C={
 black=Color3.fromRGB(4,4,8),pink=Color3.fromRGB(255,38,155),cyan=Color3.fromRGB(0,210,238),
 white=Color3.fromRGB(245,243,248),muted=Color3.fromRGB(115,108,128),
}
local fallback=Instance.new("Frame")
fallback.Name="BBYAServerFallback"
fallback.Size=UDim2.fromScale(1,1)
fallback.BackgroundColor3=C.black
fallback.BorderSizePixel=0
fallback.ZIndex=20
fallback.Parent=idle
local grad=Instance.new("UIGradient")
grad.Color=ColorSequence.new({
 ColorSequenceKeypoint.new(0,Color3.fromRGB(37,5,31)),
 ColorSequenceKeypoint.new(.52,Color3.fromRGB(5,5,10)),
 ColorSequenceKeypoint.new(1,Color3.fromRGB(3,31,37)),
})
grad.Rotation=8
grad.Parent=fallback

local function label(text,pos,size,font,color,z)
 local l=Instance.new("TextLabel")
 l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.GothamBold
 l.TextColor3=color or C.white;l.TextScaled=true;l.TextWrapped=true;l.ZIndex=z or 23;l.Parent=fallback
 return l
end

label("BBYA",UDim2.fromScale(.18,.22),UDim2.fromScale(.64,.34),Enum.Font.GothamBlack,C.white,24)
label("SOCIAL HUB  //  LIVE",UDim2.fromScale(.28,.58),UDim2.fromScale(.44,.07),Enum.Font.GothamBold,C.pink,24)
label("AUDIO REACTIVE VISUALS",UDim2.fromScale(.31,.69),UDim2.fromScale(.38,.05),Enum.Font.GothamMedium,C.cyan,24)
label("MUSIC • PEOPLE • NIGHT",UDim2.fromScale(.32,.77),UDim2.fromScale(.36,.045),Enum.Font.GothamMedium,C.muted,24)

fallback:SetAttribute("BBYAFallbackOnly",true)
fallback:SetAttribute("BBYAFakeSpectrumRemoved",true)
print("[BBYA] DJ wall server fallback v2 online: static fallback only / client owns audio reaction")