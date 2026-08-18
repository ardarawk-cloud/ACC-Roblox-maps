-- [D6] PREMIUM PHOTO / VIEW DECK
-- Photo set sits to the west half; central/right side remains a through-view path.

finish(D6,"VIEW DECK FINISH",Vector3.new(46,.14,16),CFrame.new(0,36.74,108),Color3.fromRGB(89,82,78),Enum.Material.WoodPlanks,0,false)

-- West-biased photo portal keeps the center circulation spine usable.
finish(D6,"PHOTO BACKDROP",Vector3.new(18,9,.5),CFrame.new(-13,41.4,115.4),P.black,Enum.Material.Slate,0,false)
glow(D6,"PHOTO FRAME TOP",Vector3.new(17,.3,.25),CFrame.new(-13,45.6,115.1),P.pink,.3,8)
glow(D6,"PHOTO FRAME LEFT",Vector3.new(.3,8,.25),CFrame.new(-21.4,41.5,115.1),P.pink,.2,6)
glow(D6,"PHOTO FRAME RIGHT",Vector3.new(.3,8,.25),CFrame.new(-4.6,41.5,115.1),P.cyan,.2,6)
zoneSign(D6,"PHOTO BRAND","BBYA\nSOCIAL HUB",CFrame.new(-13,41.6,114.85),Vector3.new(15,5,.2),P.pink,Enum.NormalId.Front)
finish(D6,"PHOTO STANDING MARK",Vector3.new(6,.12,6),CFrame.new(-13,36.95,106),Color3.fromRGB(62,55,60),Enum.Material.Marble,0,false)
glow(D6,"PHOTO MARK RING A",Vector3.new(6,.12,.15),CFrame.new(-13,37.05,103),P.pink,.12,4)
glow(D6,"PHOTO MARK RING B",Vector3.new(6,.12,.15),CFrame.new(-13,37.05,109),P.cyan,.12,4)

-- Right side is a simple city-view social bench.
sofa(D6,"VIEW BENCH",Vector3.new(14,37.45,108),11,180,P.cream)
glassRail(D6,"VIEW FRONT GLASS",Vector3.new(0,40.2,117),Vector3.new(46,3.6,.35))
zoneSign(D6,"VIEW DECK SIGN","CITY / NIGHT VIEW",CFrame.new(14,43,115),Vector3.new(15,2.2,.2),P.white,Enum.NormalId.Front)
