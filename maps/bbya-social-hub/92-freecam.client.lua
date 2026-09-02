-- BBYA MUSIC UI TEST — DANCE CATALOG 212 OVERLAY v1
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- Reuses BBYASocialHangoutUI > DancePanel; does not create a second DANCE launcher.
-- Candidate IDs are permission-checked only at runtime. Failed assets are reported without crashing.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local DANCES={
 {"Dance",507771019,"CLUB"},
 {"Dance 2",507776043,"CLUB"},
 {"Dance 3 Classic",507777268,"CLUB"},
 {"Fashion",3333331310,"SOCIAL"},
 {"Baby Dance",4265725525,"CLUB"},
 {"Cha-Cha",6862001787,"CLUB"},
 {"Monkey",3333499508,"SOCIAL"},
 {"Shuffle",4349242221,"CLUB"},
 {"Top Rock",3361276673,"CLUB"},
 {"Around Town",3303391864,"SOCIAL"},
 {"Fancy Feet",3333432454,"CLUB"},
 {"Hype Dance",3695333486,"CLUB"},
 {"Bodybuilder",3333387824,"SOCIAL"},
 {"Idol",4101966434,"SOCIAL"},
 {"Curtsy",4555816777,"SOCIAL"},
 {"Happy",4841405708,"SOCIAL"},
 {"Quiet Waves",7465981288,"SOCIAL"},
 {"Floss Dance",5917459365,"CLUB"},
 {"Godlike",3337994105,"SOCIAL"},
 {"Hero Landing",5104344710,"SOCIAL"},
 {"High Wave",5915690960,"SOCIAL"},
 {"Celebrate",3338097973,"SOCIAL"},
 {"Haha",3337966527,"SOCIAL"},
 {"Lasso Turn - Tai Verdes",7942896991,"MUSIC"},
 {"Line Dance",4049037604,"CLUB"},
 {"Stadium",3338055167,"SOCIAL"},
 {"Side to Side",3333136415,"SOCIAL"},
 {"Old Town Road Dance - Lil Nas X",5937560570,"MUSIC"},
 {"Dolphin Dance",5918726674,"CLUB"},
 {"Samba",6869766175,"CLUB"},
 {"Break Dance",5915648917,"CLUB"},
 {"Hips Poppin' - Zara Larsson",6797888062,"MUSIC"},
 {"Wake Up Call - KSI",7199000883,"MUSIC"},
 {"Greatest",3338042785,"SOCIAL"},
 {"On The Outside - Twenty One Pilots",7422779536,"MUSIC"},
 {"Flowing Breeze",7465946930,"SOCIAL"},
 {"Twirl",3334968680,"CLUB"},
 {"Jumping Wave",4940564896,"SOCIAL"},
 {"HOLIDAY Dance - Lil Nas X",5937558680,"MUSIC"},
 {"Take Me Under - Zara Larsson",6797890377,"MUSIC"},
 {"Dancin' Shoes - Twenty One Pilots",7404878500,"MUSIC"},
 {"Fashionable",3333331310,"SOCIAL"},
 {"Fast Hands",4265701731,"SOCIAL"},
 {"Rodeo Dance - Lil Nas X",5918728267,"MUSIC"},
 {"It Ain't My Fault - Zara Larsson",6797891807,"MUSIC"},
 {"Rock On",5915714366,"CLUB"},
 {"Block Partier",6862022283,"SOCIAL"},
 {"Dorky Dance",4212455378,"CLUB"},
 {"AOK - Tai Verdes",7942885103,"MUSIC"},
 {"Cobra Arms - Tai Verdes",7942890105,"MUSIC"},
 {"Panini Dance - Lil Nas X",5915713518,"MUSIC"},
 {"Robot",3338025566,"SOCIAL"},
 {"Saturday Dance - Twenty One Pilots",7422807549,"MUSIC"},
 {"Keeping Time",4555808220,"SOCIAL"},
 {"Air Dance",4555782893,"CLUB"},
 {"Rock Guitar - Royal Blood",6532134724,"MUSIC"},
 {"Y",4349285876,"SOCIAL"},
 {"Swan Dance",7465997989,"CLUB"},
 {"Louder",3338083565,"SOCIAL"},
 {"Up and Down - Twenty One Pilots",7422797678,"MUSIC"},
 {"Swish",3361481910,"SOCIAL"},
 {"Drummer Moves - Twenty One Pilots",7422527690,"MUSIC"},
 {"Jacks",3338066331,"SOCIAL"},
 {"Cha-Cha 2",3695322025,"CLUB"},
 {"BURBERRY LOLA ATTITUDE - NIMBUS",10147821284,"SOCIAL"},
 {"BURBERRY LOLA ATTITUDE - GEM",10147815602,"SOCIAL"},
 {"BURBERRY LOLA ATTITUDE - HYDRO",10147823318,"SOCIAL"},
 {"BURBERRY LOLA ATTITUDE - BLOOM",10147817997,"SOCIAL"},
 {"Superhero Reveal",3695373233,"SOCIAL"},
 {"Air Guitar",3695300085,"SOCIAL"},
 {"Country Line Dance - Lil Nas X",5915712534,"MUSIC"},
 {"Hwaiting",9527885267,"SOCIAL"},
 {"Bunny Hop",4641985101,"CLUB"},
 {"Sandwich Dance",4406555273,"CLUB"},
 {"Hyperfast 5G Dance Move",9408617181,"CLUB"},
 {"Victory - 24kGoldn",9178377686,"SOCIAL"},
 {"Tantrum",5104341999,"SOCIAL"},
 {"Rock Star - Royal Blood",10714400171,"MUSIC"},
 {"Drum Solo - Royal Blood",6532839007,"MUSIC"},
 {"Drum Master - Royal Blood",6531483720,"MUSIC"},
 {"High Hands",9710985298,"SOCIAL"},
 {"Gashina - SUNMI",9527886709,"KPOP"},
 {"Chicken Dance",4841399916,"CLUB"},
 {"You Can't Sit With Us - SUNMI",9983520970,"KPOP"},
 {"Frosty Flair - Tommy Hilfiger",10214311282,"SOCIAL"},
 {"Floor Rock Freeze - Tommy Hilfiger",10214314957,"CLUB"},
 {"Boom Boom Clap - George Ezra",10370346995,"MUSIC"},
 {"Cartwheel - George Ezra",10370351535,"MUSIC"},
 {"Chill Vibes - George Ezra",10370353969,"MUSIC"},
 {"Sidekicks - George Ezra",10370362157,"MUSIC"},
 {"The Conductor - George Ezra",10370359115,"MUSIC"},
 {"Super Charge",10478338114,"SOCIAL"},
 {"Swag Walk",10478341260,"CLUB"},
 {"Uprise - Tommy Hilfiger",10275008655,"SOCIAL"},
 {"2 Baddies Dance Move - NCT 127",12259828678,"KPOP"},
 {"Kick It Dance Move - NCT 127",12259826609,"KPOP"},
 {"Sticker Dance Move - NCT 127",12259825026,"KPOP"},
 {"Elton John - Rock Out",11753474067,"MUSIC"},
 {"Elton John - Heart Skip",11309255148,"MUSIC"},
 {"Elton John - Still Standing",11444443576,"MUSIC"},
 {"Elton John - Elevate",11394033602,"MUSIC"},
 {"Elton John - Cat Man",11444441914,"MUSIC"},
 {"Elton John - Piano Jump",11453082181,"MUSIC"},
 {"TWICE Moonlight Sunrise",12714233242,"KPOP"},
 {"TWICE Set Me Free Dance 1",12714228341,"KPOP"},
 {"TWICE Set Me Free Dance 2",12714231087,"KPOP"},
 {"Ay-Yo Dance Move - NCT 127",12804157977,"KPOP"},
 {"TWICE The Feels",12874447851,"KPOP"},
 {"Rise Above - The Chainsmokers",12992262118,"MUSIC"},
 {"TWICE What Is Love",13327655243,"KPOP"},
 {"TWICE Fancy",13520524517,"KPOP"},
 {"TWICE Pop by Nayeon",13768941455,"KPOP"},
 {"Tommy - Archer",13823324057,"SOCIAL"},
 {"YUNGBLUD - HIGH KICK",14022936101,"MUSIC"},
 {"TWICE Like Ooh-Ahh",14123781004,"KPOP"},
 {"Baby Queen - Air Guitar & Knee Slide",14352335202,"MUSIC"},
 {"Baby Queen - Dramatic Bow",14352337694,"MUSIC"},
 {"Baby Queen - Bouncy Twirl",14352343065,"MUSIC"},
 {"Baby Queen - Strut",14352362059,"MUSIC"},
 {"BLACKPINK Pink Venom - Get em Get em Get em",14548619594,"KPOP"},
 {"BLACKPINK Pink Venom - I Bring the Pain Like",14548620495,"KPOP"},
 {"BLACKPINK Pink Venom - Straight to Ya Dome",14548621256,"KPOP"},
 {"TWICE LIKEY",14899979575,"KPOP"},
 {"TWICE Feel Special",14899980745,"KPOP"},
 {"BLACKPINK Shut Down - Part 1",14901306096,"KPOP"},
 {"BLACKPINK Shut Down - Part 2",14901308987,"KPOP"},
 {"Bone Chillin' Bop",15122972413,"SOCIAL"},
 {"Paris Hilton - Sliving For The Groove",15392759696,"MUSIC"},
 {"BLACKPINK JISOO Flower",15439354020,"KPOP"},
 {"BLACKPINK JENNIE You and Me",15439356296,"KPOP"},
 {"Rock n Roll",15505458452,"CLUB"},
 {"Air Guitar 2",15505454268,"SOCIAL"},
 {"Victory Dance",15505456446,"CLUB"},
 {"Flex Walk",15505459811,"SOCIAL"},
 {"Olivia Rodrigo Head Bop",15517864808,"MUSIC"},
 {"Olivia Rodrigo good 4 u",15517862739,"MUSIC"},
 {"Olivia Rodrigo Fall Back to Float",15549124879,"MUSIC"},
 {"Nicki Minaj That's That Super Bass",15571446961,"MUSIC"},
 {"Nicki Minaj Boom Boom Boom",15571448688,"MUSIC"},
 {"Nicki Minaj Anaconda",15571450952,"MUSIC"},
 {"Nicki Minaj Starships",15571453761,"MUSIC"},
 {"Yungblud Happier Jump",15609995579,"MUSIC"},
 {"Festive Dance",15679621440,"CLUB"},
 {"BLACKPINK LISA Money",15679623052,"KPOP"},
 {"BLACKPINK ROSÉ On The Ground",15679624464,"KPOP"},
 {"Imagine Dragons - Bones Dance",15689279687,"MUSIC"},
 {"GloRilla - Tomorrow Dance",15689278184,"MUSIC"},
 {"d4vd - Backflip",15693621070,"SOCIAL"},
 {"ericdoa - dance",15698402762,"CLUB"},
 {"Cuco - Levitate",15698404340,"SOCIAL"},
 {"Mean Girls Dance Break",15963314052,"CLUB"},
 {"Paris Hilton Sanasa",16126469463,"MUSIC"},
 {"BLACKPINK Ice Cream",16181797368,"KPOP"},
 {"BLACKPINK Kill This Love",16181798319,"KPOP"},
 {"TWICE I GOT YOU part 1",16215030041,"KPOP"},
 {"TWICE I GOT YOU part 2",16256203246,"KPOP"},
 {"Dave's Spin Move - Glass Animals",16272432203,"MUSIC"},
 {"Sol de Janeiro - Samba",16270690701,"CLUB"},
 {"Skadoosh - Kung Fu Panda 4",16371217304,"FUN"},
 {"Jawny - Stomp",16392075853,"SOCIAL"},
 {"Mae Stephens - Piano Hands",16553163212,"SOCIAL"},
 {"BLACKPINK Boombayah",16553164850,"KPOP"},
 {"BLACKPINK DDU-DU DDU-DU",16553170471,"KPOP"},
 {"HIPMOTION - Amaarae",16572740012,"MUSIC"},
 {"Mae Stephens - Arm Wave",16584481352,"SOCIAL"},
 {"BLACKPINK How You Like That",16874470507,"KPOP"},
 {"BLACKPINK - Lovesick Girls",16874472321,"KPOP"},
 {"Mini Kong",17000021306,"FUN"},
 {"HUGO Let's Drive!",17360699557,"SOCIAL"},
 {"Wisp - air guitar",17370775305,"SOCIAL"},
 {"Sturdy Dance - Ice Spice",17746180844,"MUSIC"},
 {"Shuffle 2",17748314784,"CLUB"},
 {"Rolling Stones Guitar Strum",18148804340,"SOCIAL"},
 {"Rock Out - Bebe Rexha",18225053113,"MUSIC"},
 {"SpongeBob Imagination",18443237526,"FUN"},
 {"SpongeBob Dance",18443245017,"FUN"},
 {"Team USA Breaking",18526288497,"CLUB"},
 {"Vroom Vroom",18526397037,"SOCIAL"},
 {"TMNT Dance",18665811005,"FUN"},
 {"BLACKPINK As If It's Your Last",18855536648,"KPOP"},
 {"BLACKPINK Don't Know What To Do",18855531354,"KPOP"},
 {"TWICE ABCD by Nayeon",18933706381,"KPOP"},
 {"Charli XCX - Apple Dance",18946844622,"MUSIC"},
 {"The Zabb",129470135909814,"SOCIAL"},
 {"Fashion Klossette - Runway My Way",80995190624232,"SOCIAL"},
 {"ALTÉGO - Couldn't Care Less",107875941017127,"SOCIAL"},
 {"Fashion Roadkill",136831243854748,"SOCIAL"},
 {"Skibidi Toilet - Titan Speakerman Laser Spin",134283166482394,"FUN"},
 {"Chappell Roan HOT TO GO!",85267023718407,"SOCIAL"},
 {"Secret Handshake Dance",71243990877913,"CLUB"},
 {"KATSEYE - Touch",135876612109535,"KPOP"},
 {"Fashion Spin",131669256082047,"CLUB"},
 {"TWICE Strategy",97311229290836,"KPOP"},
 {"DearALICE - Ariana",134318425949290,"KPOP"},
 {"The Weeknd Starboy Strut",71105746210464,"MUSIC"},
 {"The Weeknd Opening Night",133110725387025,"MUSIC"},
 {"Robot M3GAN",125803725853577,"FUN"},
 {"M3GAN's Dance",99649534578309,"FUN"},
 {"Rasputin - Boney M.",114872820353992,"MUSIC"},
 {"Thanos Happy Jump - Squid Game",97611664803614,"FUN"},
 {"Young-hee Head Spin - Squid Game",112011282168475,"FUN"},
 {"TWICE Takedown",140182843839424,"KPOP"},
 {"Stray Kids Walkin On Water",125064469983655,"KPOP"},
 {"TWICE Takedown Dance 2",127104635954695,"KPOP"},
 {"R6 Party Time",33796059,"CLUB"},
 {"R6 Dance",35654637,"CLUB"},
 {"R6 Charleston",429703734,"SOCIAL"},
 {"R6 Moon Dance",27789359,"CLUB"},
 {"R6 Spin Dance",429730430,"CLUB"},
 {"R6 Spin Dance 2",186934910,"CLUB"},
 {"R6 Jumping Jacks",429681631,"SOCIAL"},
 {"R6 Weird Sway",248336677,"SOCIAL"},
}

local CAT_ORDER={"ALL","CLUB","KPOP","MUSIC","FUN","SOCIAL"}
local CAT_COLOR={ALL=Color3.fromRGB(244,48,149),CLUB=Color3.fromRGB(244,48,149),KPOP=Color3.fromRGB(207,82,255),MUSIC=Color3.fromRGB(31,184,207),FUN=Color3.fromRGB(224,178,90),SOCIAL=Color3.fromRGB(120,136,166)}
local C={card=Color3.fromRGB(29,25,34),card2=Color3.fromRGB(39,34,45),white=Color3.fromRGB(246,244,248),muted=Color3.fromRGB(166,160,172),pink=Color3.fromRGB(244,48,149),cyan=Color3.fromRGB(31,184,207),red=Color3.fromRGB(217,72,93)}

local function corner(o,r)local x=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 9);x.Parent=o end
local function stroke(o,c,tr)local x=o:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke");x.Color=c or C.pink;x.Thickness=1;x.Transparency=tr or .55;x.Parent=o end
local function label(parent,name,value,pos,size,ts,color,font)local l=Instance.new("TextLabel");l.Name=name;l.BackgroundTransparency=1;l.Text=value;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 10;l.TextColor3=color or C.white;l.TextXAlignment=Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.TextTruncate=Enum.TextTruncate.AtEnd;l.ZIndex=52;l.Parent=parent;return l end
local function btn(parent,name,value)local b=Instance.new("TextButton");b.Name=name;b.BackgroundColor3=C.card;b.BackgroundTransparency=.12;b.BorderSizePixel=0;b.Text=value;b.TextColor3=C.white;b.Font=Enum.Font.GothamSemibold;b.TextSize=9;b.AutoButtonColor=true;b.ZIndex=54;b.Parent=parent;corner(b,8);stroke(b,C.pink,.72);return b end

local currentTrack
local selectedCategory="ALL"
local query=""
local statusLabel
local listFrame
local listLayout
local function humanoid()local ch=player.Character;return ch and ch:FindFirstChildOfClass("Humanoid")end
local function stopTrack()if currentTrack then pcall(function()currentTrack:Stop(.12)end);currentTrack=nil end;if statusLabel then statusLabel.Text="STOPPED";statusLabel.TextColor3=C.muted end end
local function play(item)
 local hum=humanoid();if not hum or hum.Health<=0 then return end;stopTrack()
 local animator=hum:FindFirstChildOfClass("Animator");if not animator then animator=Instance.new("Animator");animator.Parent=hum end
 local anim=Instance.new("Animation");anim.AnimationId="rbxassetid://"..tostring(item[2]);local ok,track=pcall(function()return animator:LoadAnimation(anim)end);anim:Destroy()
 if not ok or not track then if statusLabel then statusLabel.Text="UNAVAILABLE • "..item[1];statusLabel.TextColor3=C.red end;return end
 local played=pcall(function()track.Priority=Enum.AnimationPriority.Action;track.Looped=true;track:Play(.12)end)
 if not played then pcall(function()track:Destroy()end);if statusLabel then statusLabel.Text="BLOCKED / PERMISSION • "..item[1];statusLabel.TextColor3=C.red end;return end
 currentTrack=track;if statusLabel then statusLabel.Text="PLAYING • "..item[1];statusLabel.TextColor3=CAT_COLOR[item[3]] or C.cyan end
end
local function matches(item)if selectedCategory~="ALL" and item[3]~=selectedCategory then return false end;if query=="" then return true end;return string.find(string.lower(item[1]),query,1,true)~=nil end
local function clearRows()if not listFrame then return end;for _,d in ipairs(listFrame:GetChildren()) do if d:IsA("TextButton") then d:Destroy() end end end
local function render()
 if not listFrame then return end;clearRows();local shown=0
 for i,item in ipairs(DANCES) do if matches(item) then shown+=1;local b=btn(listFrame,"Dance_"..i,item[1]);b.LayoutOrder=shown;b.Size=UDim2.new(1,-4,0,38);b.TextXAlignment=Enum.TextXAlignment.Left;local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,10);pad.PaddingRight=UDim.new(0,8);pad.Parent=b;stroke(b,CAT_COLOR[item[3]] or C.pink,.62);b.Activated:Connect(function()play(item)end) end end
 if statusLabel then statusLabel.Text=string.format("%d / %d • %s",shown,#DANCES,selectedCategory);statusLabel.TextColor3=C.muted end
 task.defer(function()if listFrame and listLayout then listFrame.CanvasSize=UDim2.fromOffset(0,math.max(0,listLayout.AbsoluteContentSize.Y+8)) end end)
end

local function attach()
 local gui=pg:WaitForChild("BBYASocialHangoutUI",45);if not gui then warn("[BBYA TEST] Dance overlay: social UI missing");return end
 local panel=gui:WaitForChild("DancePanel",20);if not panel then warn("[BBYA TEST] Dance overlay: DancePanel missing");return end
 task.wait(.35)
 for _,d in ipairs(panel:GetChildren()) do if d:IsA("ScrollingFrame") then d:Destroy() end;if d:IsA("TextLabel") and d.Position.Y.Offset>=40 then d:Destroy() end;if d.Name=="BBYADanceCatalogV1" then d:Destroy() end end
 local root=Instance.new("Frame");root.Name="BBYADanceCatalogV1";root.BackgroundTransparency=1;root.Position=UDim2.fromOffset(14,48);root.Size=UDim2.new(1,-28,1,-60);root.ZIndex=50;root.Parent=panel
 local search=Instance.new("TextBox");search.Name="DanceSearch";search.PlaceholderText="Search 212 dances...";search.ClearTextOnFocus=false;search.Text="";search.Position=UDim2.fromOffset(0,0);search.Size=UDim2.new(1,-86,0,34);search.BackgroundColor3=C.card2;search.BackgroundTransparency=.08;search.BorderSizePixel=0;search.TextColor3=C.white;search.PlaceholderColor3=C.muted;search.Font=Enum.Font.GothamMedium;search.TextSize=10;search.TextXAlignment=Enum.TextXAlignment.Left;search.ZIndex=53;search.Parent=root;corner(search,9);stroke(search,C.pink,.62);local sp=Instance.new("UIPadding");sp.PaddingLeft=UDim.new(0,10);sp.PaddingRight=UDim.new(0,8);sp.Parent=search
 local stop=btn(root,"DanceStop","STOP");stop.Position=UDim2.new(1,-78,0,0);stop.Size=UDim2.fromOffset(78,34);stop.BackgroundColor3=Color3.fromRGB(72,31,39);stroke(stop,C.red,.45);stop.Activated:Connect(stopTrack)
 local cats=Instance.new("ScrollingFrame");cats.Name="DanceCategories";cats.Position=UDim2.fromOffset(0,40);cats.Size=UDim2.new(1,0,0,34);cats.BackgroundTransparency=1;cats.BorderSizePixel=0;cats.ScrollBarThickness=0;cats.CanvasSize=UDim2.new();cats.AutomaticCanvasSize=Enum.AutomaticSize.X;cats.ScrollingDirection=Enum.ScrollingDirection.X;cats.ZIndex=53;cats.Parent=root
 local catLayout=Instance.new("UIListLayout");catLayout.FillDirection=Enum.FillDirection.Horizontal;catLayout.Padding=UDim.new(0,6);catLayout.Parent=cats
 for _,cat in ipairs(CAT_ORDER) do local b=btn(cats,"Cat_"..cat,cat);b.Size=UDim2.fromOffset(cat=="SOCIAL" and 62 or 54,30);stroke(b,CAT_COLOR[cat],cat=="ALL" and .25 or .65);b.Activated:Connect(function()selectedCategory=cat;for _,x in ipairs(cats:GetChildren()) do if x:IsA("TextButton") then local xc=x.Name:gsub("^Cat_","");local s=x:FindFirstChildOfClass("UIStroke");if s then s.Transparency=(xc==selectedCategory) and .20 or .68 end end end;render()end) end
 statusLabel=label(root,"DanceStatus","212 CANDIDATES • TAP TO TEST",UDim2.fromOffset(0,78),UDim2.new(1,0,0,18),8,C.muted,Enum.Font.GothamMedium)
 listFrame=Instance.new("ScrollingFrame");listFrame.Name="DanceCatalogScroll";listFrame.Position=UDim2.fromOffset(0,100);listFrame.Size=UDim2.new(1,0,1,-100);listFrame.BackgroundTransparency=1;listFrame.BorderSizePixel=0;listFrame.ScrollBarThickness=3;listFrame.CanvasSize=UDim2.new();listFrame.AutomaticCanvasSize=Enum.AutomaticSize.None;listFrame.ZIndex=52;listFrame.Parent=root
 listLayout=Instance.new("UIListLayout");listLayout.Padding=UDim.new(0,6);listLayout.SortOrder=Enum.SortOrder.LayoutOrder;listLayout.Parent=listFrame;listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()if listFrame then listFrame.CanvasSize=UDim2.fromOffset(0,math.max(0,listLayout.AbsoluteContentSize.Y+8)) end end)
 search:GetPropertyChangedSignal("Text"):Connect(function()query=string.lower(search.Text or "");render()end)
 local function bindHum(hum)hum.Running:Connect(function(speed)if speed>.35 then stopTrack()end end);hum.Died:Connect(stopTrack)end
 local h=humanoid();if h then bindHum(h)end;player.CharacterAdded:Connect(function(ch)stopTrack();local hum=ch:WaitForChild("Humanoid",10);if hum then bindHum(hum)end end)
 panel:SetAttribute("BBYADanceCatalogAuthority","TEST_V1_212");panel:SetAttribute("BBYADanceCatalogCount",#DANCES);render();print("[BBYA TEST] Dance Catalog v1 attached: "..#DANCES.." candidates / existing DANCE launcher reused")
end

task.spawn(attach)
