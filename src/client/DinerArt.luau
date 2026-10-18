-- Original roadside diner set dressing. All geometry is local to the opening.
local Paintings=require(script.Parent.DinerPaintings)
local Art={}
local C=Color3.fromRGB
local V=Vector3.new
local ivory=C(235,227,205)
local chrome=C(183,195,194)
local red=C(151,31,38)
local teal=C(58,111,104)
function Art.build(model,origin)
	local function part(name,size,pos,color,material,shape,rotation)
		local p=Instance.new("Part")
		p.Name,p.Size,p.Color=name,size,color
		p.Material=material or Enum.Material.SmoothPlastic
		p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery=true,false,false,false
		p.CFrame=CFrame.new(origin+pos)*(rotation or CFrame.new())
		if shape then p.Shape=shape end
		p.Parent=model
		return p
	end
	local function disk(name,pos,radius,height,color,material)
		return part(name,V(height,radius*2,radius*2),pos,color,material,Enum.PartType.Cylinder,CFrame.Angles(0,0,math.pi/2))
	end
	local function ring(name,center,radius,thickness,color,material,segments)
		for i=1,segments or 24 do
			local count=segments or 24
			local a=(i-.5)*math.pi*2/count
			part(name,V(thickness,thickness,2*radius*math.tan(math.pi/count)+.01),center+V(math.cos(a)*radius,0,math.sin(a)*radius),color,material,nil,CFrame.Angles(0,-a,0))
		end
	end
	local function sign(name,text,pos,size,bg,fg)
		local p=part(name,V(size.X,size.Y,.14),pos,bg)
		local gui=Instance.new("SurfaceGui"); gui.Face=Enum.NormalId.Back; gui.CanvasSize=Vector2.new(800,300); gui.LightInfluence=1; gui.Parent=p
		local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(.92,.86); label.Position=UDim2.fromScale(.04,.07); label.BackgroundTransparency=1; label.Text=text; label.Font=Enum.Font.SpecialElite; label.TextScaled=true; label.TextColor3=fg; label.Parent=gui
	end
	local function cup(x,y,z)
		disk("Coffee saucer",V(x,y,z),.43,.055,ivory)
		disk("Porcelain coffee mug",V(x,y+.26,z),.27,.48,ivory)
		disk("Fresh coffee",V(x,y+.505,z),.225,.012,C(48,26,16))
		ring("Mug lip",V(x,y+.51,z),.25,.035,ivory,nil,16)
		for i=1,12 do
			local a=(i-.5)*math.pi*2/12
			part("Curved mug handle",V(.08,.11,.08),V(x+.3+math.cos(a)*.16,y+.29+math.sin(a)*.18,z),ivory,nil,Enum.PartType.Ball)
		end
	end
	local function fork(x,y,z)
		part("Polished fork handle",V(.07,.035,.55),V(x,y,z+.19),chrome,Enum.Material.Metal)
		part("Fork shoulder",V(.22,.035,.15),V(x,y+.015,z-.13),chrome,Enum.Material.Metal)
		for i=1,4 do part("Fork tine",V(.027,.035,.23),V(x-.1+i*.04,y+.025,z-.29),chrome,Enum.Material.Metal) end
	end
	local function meal(x,z,kind)
		local y=2.98
		disk("Porcelain dinner plate",V(x,y,z),1.0,.07,ivory)
		ring("Raised porcelain rim",V(x,y+.05,z),.94,.085,ivory)
		ring("Teal plate pinstripe",V(x,y+.082,z),.87,.018,teal)
		if kind=="burger" then
			disk("Toasted brioche base",V(x-.28,y+.16,z),.39,.16,C(188,112,43))
			disk("Grilled beef patty",V(x-.28,y+.28,z),.41,.14,C(65,34,21))
			part("Cheddar slice",V(.78,.045,.72),V(x-.28,y+.37,z),C(240,172,36),nil,nil,CFrame.Angles(0,.23,0))
			for i=1,5 do local a=i*1.256; part("Ruffled lettuce",V(.43,.075,.30),V(x-.28+math.cos(a)*.22,y+.42,z+math.sin(a)*.22),C(83,128,36),nil,Enum.PartType.Ball,CFrame.Angles(0,a,.15)) end
			disk("Tomato slice",V(x-.28,y+.47,z),.34,.055,C(176,43,31))
			part("Rounded brioche crown",V(.85,.38,.82),V(x-.28,y+.62,z),C(216,149,65),nil,Enum.PartType.Ball)
			for i=1,9 do local a=i*2.4; part("Sesame seed",V(.025,.018,.055),V(x-.28+math.cos(a)*.26,y+.79-(i%3)*.012,z+math.sin(a)*.22),C(245,219,158),nil,nil,CFrame.Angles(0,a,0)) end
			for i=1,8 do part("Golden shoestring fry",V(.085,.09,.45+(i%3)*.06),V(x+.4+(i%3)*.09,y+.12+math.floor(i/3)*.07,z-.2+(i%4)*.12),C(225-i*3,171-i*2,67),nil,nil,CFrame.Angles(0,(i-4)*.18,.04)) end
		else
			part("Seared steak",V(.85,.19,.57),V(x-.2,y+.16,z),C(105,49,29),nil,Enum.PartType.Ball,CFrame.Angles(0,.2,0))
			for i=1,4 do part("Steak grill mark",V(.025,.012,.4),V(x-.49+i*.14,y+.25,z),C(49,28,20),nil,nil,CFrame.Angles(0,-.3,0)) end
			for i=1,5 do part("Roasted potato",V(.24,.21,.25),V(x+.35+(i%2)*.16,y+.16,z-.4+i*.14),C(210,158,77),nil,Enum.PartType.Ball) end
			for i=1,3 do part("Green bean",V(.06,.06,.52),V(x-.25+i*.11,y+.11,z+.5),C(69,116,45),nil,nil,CFrame.Angles(0,i*.12,0)) end
		end
		part("Folded linen napkin",V(.45,.035,1.05),V(x-1.3,y-.02,z),C(228,211,180),Enum.Material.Fabric)
		fork(x-1.3,y+.03,z)
		part("Knife handle",V(.10,.055,.42),V(x+1.2,y,z+.3),C(61,43,33))
		part("Knife blade",V(.13,.025,.52),V(x+1.2,y+.02,z-.15),chrome,Enum.Material.Metal)
		cup(x+.75,y-.015,z+1.25)
	end
	-- A 76 × 72 dining room with booths perpendicular to the window wall.
	part("Diner foundation",V(76,1,72),V(0,-.6,0),C(81,79,72),Enum.Material.Concrete)
	for x=-36,36,4 do for z=-34,34,4 do
		local tile=part("Ivory and charcoal checker tile",V(3.98,.07,3.98),V(x,-.05,z),((x+36)/4+(z+34)/4)%2==0 and ivory or C(37,43,43),Enum.Material.Marble)
		tile.Reflectance=.06
	end end
	part("Back teal wall",V(76,14.5,.5),V(0,6.75,-36),teal,Enum.Material.Plaster)
	part("Right plaster wall",V(.5,14.5,72),V(38,6.75,0),ivory,Enum.Material.Plaster)
	part("Booth window base wall",V(.5,3.8,72),V(-38,1.9,0),teal)
	part("Booth window upper wall",V(.5,6.3,72),V(-38,11.35,0),ivory,Enum.Material.Plaster)
	for _,z in {-31,-15,1,17,33} do part("Booth window wall pier",V(.5,14.5,8),V(-38,7.25,z),ivory,Enum.Material.Plaster) end
	for _,z in {-34.5,34.5} do part("Booth wall end",V(.5,14.5,3),V(-38,6.75,z),ivory,Enum.Material.Plaster) end
	-- Solid front wall with one entrance, rather than a second wall of glazing.
	part("Entrance plaster header",V(6,6.5,.5),V(0,11.25,36),ivory,Enum.Material.Plaster)
	for _,x in {-20.5,20.5} do
		part("Front plaster wall",V(35,14.5,.5),V(x,7.25,36),ivory,Enum.Material.Plaster)
		part("Front walnut wainscot",V(35,2.7,.12),V(x,1.35,35.68),C(105,77,50),Enum.Material.WoodPlanks)
		part("Front chair rail",V(35,.13,.2),V(x,2.75,35.6),chrome,Enum.Material.Metal)
	end
	part("Ceiling",V(76,.25,72),V(0,14.5,0),C(217,220,205))
	for x=-36,36,4 do part("Pressed ceiling seam",V(.04,.04,72),V(x,14.34,0),chrome,Enum.Material.Metal) end
	for z=-36,36,4 do part("Pressed ceiling seam",V(76,.04,.04),V(0,14.34,z),chrome,Enum.Material.Metal) end
	for _,x in {-37.65,37.65} do
		for _,y in {.2,2.5,13.3} do part("Chrome wall moulding",V(.09,.06,72),V(x,y,0),chrome,Enum.Material.Metal) end
	end
	local function daylight(window,face)
		window.Transparency=.88; window.CastShadow=false
		local light=Instance.new("SurfaceLight"); light.Name="Noon window fill"; light.Face=face; light.Color=C(239,247,255); light.Brightness=1.2; light.Range=44; light.Angle=110; light.Shadows=true; light.Parent=window
	end
	for _,z in {-23,-7,9,25} do
		local window=part("Booth side window",V(.1,4.4,8),V(-38,6,z),C(210,231,235),Enum.Material.Glass)
		daylight(window,Enum.NormalId.Right)
		for _,dz in {-4,0,4} do part("Side window mullion",V(.25,4.4,.12),V(-37.9,6,z+dz),chrome,Enum.Material.Metal) end
		for _,y in {3.8,8.2} do part("Side window horizontal frame",V(.25,.12,8),V(-37.9,y,z),chrome,Enum.Material.Metal) end
		part("Booth window sill",V(.85,.15,8.5),V(-37.6,3.75,z),ivory)
		part("Simple window pelmet",V(.55,.35,8.5),V(-37.65,8.4,z),C(105,77,50),Enum.Material.Wood)
	end
	part("Exterior sand",V(500,1,500),V(0,-.7,0),C(193,164,117),Enum.Material.Sand)
	-- The exterior module supplies the parking court and highway.
	
	sign("Original diner marquee","SUNSET\nDINER",V(-27,10,-35.6),Vector2.new(13,3.2),red,ivory)
	sign("Kitchen sign","FRESH COFFEE  •  ALL DAY",V(16,10,-35.6),Vector2.new(12,1.2),teal,ivory)
	for index,art in Paintings do
		local x=-14+(index-1)*13
		part("Walnut painting frame",V(10.6,7,.24),V(x,7,-35.6),C(71,43,28),Enum.Material.Wood)
		part("Painting linen mat",V(10.1,6.5,.13),V(x,7,-35.43),ivory,Enum.Material.Fabric)
		local canvas=part("Original landscape painting",V(9.6,6,.08),V(x,7,-35.32),ivory,Enum.Material.Fabric)
		local gui=Instance.new("SurfaceGui"); gui.Name="Painted landscape"; gui.Face=Enum.NormalId.Back; gui.CanvasSize=Vector2.new(96,60); gui.LightInfluence=.6; gui.Parent=canvas
		for _,patch in art.patches do
			local stroke=Instance.new("Frame"); stroke.BorderSizePixel=0; stroke.Position=UDim2.fromOffset(patch[1],patch[2]); stroke.Size=UDim2.fromOffset(patch[3],patch[4]); stroke.BackgroundColor3=art.palette[patch[5]]; stroke.Parent=gui
		end
	end
	local function condiments(x,z,y)
		part("Condiment caddy",V(1.5,.1,.85),V(x,y,z),chrome,Enum.Material.Metal)
		for i=1,2 do
			local bx=x-.65+i*.35
			disk(i==1 and "Ketchup bottle" or "Mustard bottle",V(bx,y+.29,z),.13,.5,i==1 and C(176,39,27) or C(220,172,42))
			disk("Bottle nozzle",V(bx,y+.61,z),.045,.15,ivory)
		end
		for _,dx in {.28,.58} do
			disk(dx==.28 and "Salt shaker" or "Pepper shaker",V(x+dx,y+.19,z),.10,.28,dx==.28 and ivory or C(93,71,49))
			disk("Shaker perforated cap",V(x+dx,y+.35,z),.105,.055,chrome,Enum.Material.Metal)
		end
		part("Napkin dispenser",V(.5,.65,.4),V(x,y+.36,z+.55),chrome,Enum.Material.Metal)
		part("Paper napkins",V(.4,.12,.32),V(x,y+.71,z+.55),ivory)
	end
	for index,z in {-23,-7,9,25} do
		local x=-31
		for _,side in {-1,1} do
			part("Booth chrome plinth",V(9,.18,2.6),V(x,.65,z+side*3.5),chrome,Enum.Material.Metal)
			part("Facing booth vinyl seat",V(8.8,1,2.4),V(x,1.1,z+side*3.5),red,Enum.Material.Leather)
			part("Facing booth backrest",V(8.8,3.6,.65),V(x,2.6,z+side*4.5),red,Enum.Material.Leather)
			for n=-4,4 do
				part("Upholstered backrest channel",V(.86,2.7,.7),V(x+n*.94,2.8,z+side*4.33),C(164,39,44),Enum.Material.Leather,Enum.PartType.Ball)
				part("Seat stitched piping",V(.025,.025,2.3),V(x+n*.94,1.607,z+side*3.5),C(200,82,74))
			end
			part("Backrest chrome top rail",V(8.9,.08,.72),V(x,4.45,z+side*4.5),chrome,Enum.Material.Metal)
		end
		part("Chrome table edge",V(8.1,.22,4.7),V(x,2.76,z),chrome,Enum.Material.Metal)
		part("Ivory laminate tabletop",V(8,.12,4.6),V(x,2.88,z),ivory,Enum.Material.Marble)
		disk("Table pedestal foot",V(x,.09,z),1.2,.17,chrome,Enum.Material.Metal)
		disk("Table chrome pedestal",V(x,1.4,z),.16,2.7,chrome,Enum.Material.Metal)
		if index==2 then meal(x,z-.65,"steak") end
		condiments(x-2.6,z+.6,3)
		sign("Table menu","TODAY\nSTEAK & EGGS\nCOFFEE",V(x+2.8,3.5,z+.8),Vector2.new(.85,1),teal,ivory)
	end
	part("Service counter base",V(5,3.1,48),V(15,1.5,0),teal)
	for z=-23,23,.65 do part("Counter ribbed steel",V(.04,2,.06),V(12.47,1.5,z),chrome,Enum.Material.Metal) end
	part("Counter chrome edge",V(6.15,.3,49.15),V(15,3.2,0),chrome,Enum.Material.Metal)
	part("Counter laminate",V(6,.12,49),V(15,3.39,0),ivory,Enum.Material.Marble)
	for z=-20,20,8 do
		disk("Stool foot",V(10,.12,z),.72,.18,chrome,Enum.Material.Metal)
		disk("Stool chrome stem",V(10,1.15,z),.15,2,chrome,Enum.Material.Metal)
		ring("Stool foot ring",V(10,.8,z),.55,.055,chrome,Enum.Material.Metal,16)
		disk("Stool chrome rim",V(10,2.12,z),.94,.16,chrome,Enum.Material.Metal)
		disk("Red vinyl stool",V(10,2.27,z),.9,.22,red,Enum.Material.Leather)
		part("Counter chair back",V(.2,1.1,1.8),V(9.15,3,z),red,Enum.Material.Leather)
		cup(14,3.47,z)
	end
	for _,z in {-16,0,16} do condiments(16,z,3.5) end
	part("Kitchen partition",V(.4,1.2,27),V(20,.6,-4),ivory)
	part("Stainless range",V(6,3,4),V(25,1.5,-13),chrome,Enum.Material.Metal)
	for _,x in {23.8,26.2} do
		disk("Cast iron burner",V(x,3.04,-13),.7,.08,C(32,34,33),Enum.Material.Metal)
		disk("Skillet",V(x,3.2,-13),.58,.18,C(44,46,44),Enum.Material.Metal)
		ring("Skillet rim",V(x,3.29,-13),.55,.07,C(58,59,55),Enum.Material.Metal,16)
		part("Skillet handle",V(.15,.1,.8),V(x,3.2,-12.2),C(41,40,37),Enum.Material.Metal)
		part("Frying egg white",V(.65,.05,.46),V(x,3.3,-13),ivory,nil,Enum.PartType.Ball)
		part("Egg yolk",V(.23,.09,.23),V(x,3.34,-13),C(242,178,35),nil,Enum.PartType.Ball)
	end
	part("Kitchen prep table",V(6,.2,3),V(25,2.9,-4),chrome,Enum.Material.Metal)
	for _,x in {22.4,27.6} do for _,z in {-5,-3} do part("Prep table leg",V(.15,2.8,.15),V(x,1.4,z),chrome,Enum.Material.Metal) end end
	part("Cutting board",V(2,.12,1.2),V(25,3.08,-4),C(148,107,62),Enum.Material.Wood)
	part("Kitchen pass sill",V(.6,.2,16),V(21.5,3.3,-11),chrome,Enum.Material.Metal)
	part("Kitchen window header",V(.6,1.3,17),V(21.5,8,-11),ivory)
	for _,z in {-19.5,-2.5} do part("Kitchen window jamb",V(.6,5,.5),V(21.5,5.5,z),ivory) end
	disk("Shared fries platter",V(-31,3.01,-23),.85,.07,ivory)
	for i=1,18 do part("Shared table fries",V(.09,.1,.65),V(-31+(i%5)*.15-.3,3.1+math.floor(i/5)*.08,-23+(i%3)*.16-.2),C(223,171,72),nil,nil,CFrame.Angles(0,i*.5,0)) end
	disk("Reader pancake plate",V(-31,3.01,8.35),.9,.07,ivory)
	for i=1,3 do disk("Golden pancake",V(-31,3.08+i*.11,8.35),.6,.1,C(201+i*7,140+i*5,64)) end
	part("Pancake butter",V(.25,.08,.22),V(-31,3.47,8.35),C(243,213,123))
	cup(17.6,3.47,5.4)
	-- Compact service lane and a defined galley replace the empty back-counter floor.
	part("Kitchen tiled rear wall",V(.4,14.5,72),V(30,6.75,0),C(218,218,199),Enum.Material.Brick)
	part("Service wall lower panel",V(.4,3.1,72),V(21.5,1.55,0),ivory)
	part("Service wall upper panel",V(.4,7.2,72),V(21.5,10.9,0),ivory,Enum.Material.Plaster)
	for _,section in {{-27.75,16.5},{.25,5.5},{25.5,21}} do
		part("Kitchen pass wall pier",V(.4,4.3,section[2]),V(21.5,5.2,section[1]),ivory,Enum.Material.Plaster)
	end
	part("Second service hatch sill",V(.8,.16,12),V(21.3,3.3,9),chrome,Enum.Material.Metal)
	for z=-33,33,3 do
		part("Kitchen wall red trim",V(.06,.12,2.9),V(21.25,8.9,z),red)
		part("Kitchen wall checker accent",V(.06,.65,.65),V(21.22,8.4,z),C(42,45,43),nil,nil,CFrame.Angles(math.pi/4,0,0))
	end
	part("Stainless extractor hood",V(6.8,1.2,5),V(25,7,-13),chrome,Enum.Material.Metal)
	part("Extractor duct",V(2.6,6.2,2.6),V(26,10.6,-13),chrome,Enum.Material.Metal)
	for x=22.2,27.8,.4 do part("Hood grease filter",V(.2,.08,3.8),V(x,6.35,-13),C(69,75,72),Enum.Material.Metal) end
	part("Flat top grill cabinet",V(6,3,3),V(26,1.5,-20),chrome,Enum.Material.Metal)
	part("Seasoned flat top grill",V(5.8,.12,2.8),V(26,3.08,-20),C(49,47,41),Enum.Material.Metal)
	for x=24,28,1 do local knob=part("Grill control knob",V(.14,.22,.22),V(22.94,2.5,-21+(x-24)*.5),C(39,38,34)); knob.Shape=Enum.PartType.Ball end
	part("Galley lower cabinets",V(3,3,17),V(28.2,1.5,8),chrome,Enum.Material.Metal)
	part("Stainless prep worktop",V(3.2,.14,17.2),V(28.2,3.08,8),chrome,Enum.Material.Metal)
	for z=1,15,2 do
		part("Galley cabinet front",V(.08,2.7,1.85),V(26.66,1.5,z),C(153,164,162),Enum.Material.Metal)
		part("Cabinet pull",V(.12,.12,.6),V(26.57,2.5,z),chrome,Enum.Material.Metal)
	end
	for _,z in {7,10} do
		part("Sink dark basin",V(2.4,.05,2.2),V(28.2,3.17,z),C(67,83,84),Enum.Material.Metal)
		for _,dx in {-1.25,1.25} do part("Sink raised rim",V(.10,.1,2.4),V(28.2+dx,3.21,z),chrome,Enum.Material.Metal) end
		part("Sink faucet upright",V(.12,.9,.12),V(29.3,3.65,z),chrome,Enum.Material.Metal)
		part("Sink faucet spout",V(.8,.12,.12),V(28.95,4.08,z),chrome,Enum.Material.Metal)
	end
	for _,z in {3,13} do
		part("Kitchen wall shelf",V(2.2,.12,5),V(28.8,5.5,z),chrome,Enum.Material.Metal)
		for i=1,6 do disk("Stacked kitchen plate",V(28.4,5.57+i*.065,z),.65,.055,ivory) end
		for i=1,3 do local bowl=part("Prep ingredient bowl",V(.65,.3,.65),V(28.3,3.35,z-1+i*.65),ivory,nil,Enum.PartType.Ball) end
	end
	part("Upright refrigerator",V(4,7.2,4.8),V(27,3.6,22),chrome,Enum.Material.Metal)
	for _,z in {20.8,23.2} do
		part("Refrigerator door",V(.09,6.8,2.25),V(24.94,3.6,z),C(186,195,189),Enum.Material.Metal)
		part("Refrigerator handle",V(.16,1.5,.16),V(24.8,3.8,z+.65),C(66,70,67),Enum.Material.Metal)
	end
	-- Equipment on the service side gives the waitress a believable work station.
	part("Coffee station cabinet",V(1.9,3.1,5),V(20.35,1.55,20),teal)
	part("Coffee station counter",V(2,.14,5.2),V(20.35,3.2,20),chrome,Enum.Material.Metal)
	for _,z in {19,21} do
		disk("Coffee urn",V(20.3,4.3,z),.52,1.7,chrome,Enum.Material.Metal)
		disk("Coffee urn lid",V(20.3,5.2,z),.56,.12,C(48,47,40))
		part("Coffee urn tap",V(.4,.12,.13),V(19.7,3.85,z),C(43,42,37))
	end
	part("Cash register body",V(1.7,.8,1.5),V(14.5,3.9,15),C(70,77,72),Enum.Material.Metal)
	part("Register keypad",V(.08,.5,1),V(13.6,4.1,15),C(35,39,35))
	part("Register receipt",V(.08,.4,.45),V(14,4.5,15.4),ivory)
	for i=1,5 do disk("Service cup stack",V(20,3.4+i*.15,17.9),.25,.2,ivory) end
	for _,z in {-28,27} do
		local board=part("Kitchen chalk specials board",V(.15,2.4,4.5),V(21.2,10.5,z),C(33,47,40))
		local gui=Instance.new("SurfaceGui"); gui.Face=Enum.NormalId.Left; gui.CanvasSize=Vector2.new(500,260); gui.Parent=board
		local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1; label.Text=z<0 and "TODAY'S SPECIALS\nPancakes • Fresh coffee\nHomestyle breakfast" or "FROM THE GRILL\nBurgers • Fries\nHouse pie"; label.TextScaled=true; label.TextColor3=ivory; label.Font=Enum.Font.SpecialElite; label.Parent=gui
	end
	for _,x in {-30,-12,14} do for _,z in {-23,-7,9,25} do
		disk("Pendant ceiling rose",V(x,14.2,z),.35,.15,chrome,Enum.Material.Metal)
		disk("Hanging lamp stem",V(x,12.5,z),.045,3.2,C(55,53,46),Enum.Material.Metal)
		disk("Pendant brass cap",V(x,10.85,z),.38,.16,C(163,135,78),Enum.Material.Metal)
		local globe=part("Hanging opal globe",V(1.55,1.65,1.55),V(x,10.15,z),C(255,242,215),Enum.Material.Neon,Enum.PartType.Ball)
		local light=Instance.new("PointLight"); light.Color=C(255,233,206); light.Brightness=.65; light.Range=23; light.Parent=globe
	end end
	for _,x in {-7,27} do
		part("Ceiling vent frame",V(4,.09,2),V(x,14.3,3),chrome,Enum.Material.Metal)
		for i=1,12 do part("Vent louvre",V(.16,.07,1.75),V(x-1.9+i*.29,14.24,3),C(55,64,63),Enum.Material.Metal) end
	end
end

-- Detailed hand props remain welded to the R6 arm during the authored poses.
function Art.held(rig,arm,role)
	local function p(name,size,offset,color,shape,rotation)
		local part=Instance.new("Part"); part.Name=name; part.Size=size; part.Material=Enum.Material.Metal; part.Color=color or chrome
		part.CanCollide,part.CanTouch,part.CanQuery,part.Massless=false,false,false,true
		part.CFrame=arm.CFrame*CFrame.new(offset)*(rotation or CFrame.new()); if shape then part.Shape=shape end; part.Parent=rig
		local weld=Instance.new("WeldConstraint"); weld.Part0,weld.Part1,weld.Parent=arm,part,part
		return part
	end
	local grip=-arm.Size.Y*.43
	if role=="waitress" then
		local pot=p("Coffee pot",V(.7,.7,.8),V(0,grip,-.45),C(91,58,31),Enum.PartType.Ball)
		p("Coffee pot lid",V(.75,.12,.8),V(0,grip+.35,-.45),chrome)
		local spout=p("Coffee pot spout",V(.18,.14,.38),V(0,grip+.1,-.98),chrome)
		for i=1,8 do local a=i*math.pi/4; p("Coffee pot handle",V(.1,.1,.1),V(.2+math.cos(a)*.35,grip+math.sin(a)*.3,-.25),chrome,Enum.PartType.Ball) end
		return {pot=pot,spout=spout}
	elseif role=="bar" then
		p("Customer coffee mug",V(.55,.5,.55),V(0,grip,-.25),ivory)
		p("Customer coffee",V(.43,.02,.43),V(0,grip+.26,-.25),C(48,26,16))
	elseif role=="reader" then
		local paper=p("Folded diner newspaper",V(1.6,1.05,.035),V(0,grip+.25,-.5),C(213,205,181))
		local page=p("Turning newspaper page",V(.8,1.05,.035),V(.4,grip+.25,-.53),C(225,216,191))
		for _,sheet in {paper,page} do
			local gui=Instance.new("SurfaceGui"); gui.Face=Enum.NormalId.Front; gui.CanvasSize=Vector2.new(300,240); gui.Parent=sheet
			local text=Instance.new("TextLabel"); text.Size=UDim2.fromScale(1,1); text.BackgroundTransparency=1; text.Text="THE DAILY BLOX\n--------------------\nLOCAL NEWS   |   ROUTE 4\nMarkets • Travel • Weather"; text.TextColor3=C(53,51,45); text.TextScaled=true; text.Font=Enum.Font.SpecialElite; text.TextWrapped=true; text.Parent=gui
		end
		local oldWeld=page:FindFirstChildOfClass("WeldConstraint"); oldWeld:Destroy()
		local hinge=Instance.new("Weld"); hinge.Part0=arm; hinge.Part1=page; hinge.C0=CFrame.new(.4,grip+.25,-.53); hinge.Parent=page
		return {pageHinge=hinge,grip=grip}
	else
		p("Utensil handle",V(.07,.08,.55),V(0,grip,-.28))
		if role=="chef" then
			p("Spatula blade",V(.42,.035,.46),V(0,grip,-.77))
			for i=1,3 do p("Spatula slot",V(.035,.038,.24),V(-.16+i*.08,grip,-.77),C(54,57,55)) end
			arm=rig:FindFirstChild("LeftHand") or rig:FindFirstChild("Left Arm") or arm
			local pan=p("Chef frying pan",V(.13,1.3,1.3),V(0,grip,-.75),C(37,39,38),Enum.PartType.Cylinder,CFrame.Angles(0,0,math.pi/2))
			p("Chef pan handle",V(.13,.09,.6),V(0,grip,-.15),C(52,48,42))
			local patty=Instance.new("Part"); patty.Name="Flipping burger"; patty.Size=V(.10,.8,.8); patty.Shape=Enum.PartType.Cylinder; patty.Color=C(91,48,29); patty.Anchored=true; patty.CanCollide=false; patty.CanTouch=false; patty.CanQuery=false; patty.CFrame=pan.CFrame; patty.Parent=rig
			return {pan=pan,patty=patty}
		else
			p("Fork shoulder",V(.22,.035,.12),V(0,grip,-.59))
			for i=1,4 do p("Held fork tine",V(.025,.035,.24),V(-.1+i*.04,grip,-.76)) end
		end
	end
end
return Art
