-- Original roadside diner set dressing. All geometry is local to the opening.
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
	part("Diner foundation",V(58,1,40),V(0,-.6,0),C(81,79,72),Enum.Material.Concrete)
	for x=-27,27,3 do for z=-18.5,17.5,3 do
		local tile=part("Ivory and charcoal checker tile",V(2.98,.07,2.98),V(x,-.05,z),((x+27)/3+(z+18.5)/3)%2==0 and ivory or C(37,43,43),Enum.Material.Marble)
		tile.Reflectance=.08
	end end
	part("Back teal wall",V(58,12,.5),V(0,5.5,-20),teal,Enum.Material.Plaster)
	part("Left plaster wall",V(.5,12,40),V(-29,5.5,0),ivory,Enum.Material.Plaster)
	part("Right plaster wall",V(.5,12,40),V(29,5.5,0),ivory,Enum.Material.Plaster)
	part("Window sill wall",V(58,2,.5),V(0,.8,20),teal)
	part("Ceiling",V(58,.25,40),V(0,11.7,0),C(217,220,205))
	for x=-28,28,4 do part("Pressed ceiling seam",V(.04,.04,40),V(x,11.54,0),chrome,Enum.Material.Metal) end
	for z=-20,20,4 do part("Pressed ceiling seam",V(58,.04,.04),V(0,11.54,z),chrome,Enum.Material.Metal) end
	for _,x in {-28.65,28.65} do
		part("Red wall dado",V(.08,2.4,40),V(x,1.2,0),red)
		for _,y in {.2,2.5,9.9,10.1} do part("Chrome wall moulding",V(.09,.06,40),V(x,y,0),chrome,Enum.Material.Metal) end
	end
	for _,y in {2.5,9.9} do part("Back chrome moulding",V(58,.06,.09),V(0,y,-19.65),chrome,Enum.Material.Metal) end
	for x=-24,24,12 do
		local window=part("Clear noon window",V(10,8,.1),V(x,6,20),C(210,231,235),Enum.Material.Glass)
		window.Transparency=.88; window.CastShadow=false
		for _,dx in {-5,0,5} do part("Brushed window mullion",V(.12,8,.25),V(x+dx,6,19.9),chrome,Enum.Material.Metal) end
		for _,y in {2,6,10} do part("Window horizontal frame",V(10,.12,.25),V(x,y,19.9),chrome,Enum.Material.Metal) end
		local daylight=Instance.new("SurfaceLight"); daylight.Name="Noon window fill"; daylight.Face=Enum.NormalId.Front; daylight.Color=C(239,247,255); daylight.Brightness=1.1; daylight.Range=38; daylight.Angle=110; daylight.Shadows=true; daylight.Parent=window
		part("Window sill",V(10.5,.15,.8),V(x,1.95,19.7),ivory)
	end
	-- Exterior seen through the glass: sunlit roadside, not a black void.
	part("Exterior sand",V(420,1,240),V(0,-.7,130),C(193,164,117),Enum.Material.Sand)
	part("Road outside diner",V(420,.1,22),V(0,-.12,59),C(81,81,76),Enum.Material.Asphalt)
	for x=-190,190,18 do part("Road center dash",V(8,.02,.2),V(x,-.05,59),C(224,193,101)) end
	sign("Original diner marquee","SUNSET\nDINER",V(-18,8,-19.6),Vector2.new(13,3.2),red,ivory)
	sign("Kitchen sign","FRESH COFFEE  •  ALL DAY",V(10,8,-19.6),Vector2.new(12,1.2),teal,ivory)
	for i,text in {"ROUTE 18\nTAKE THE LONG WAY","HOUSE PIE\nBAKED DAILY","GOOD FOOD\nSINCE 1958"} do
		local x=-7+(i-1)*10
		part("Poster chrome frame",V(4.3,3.7,.16),V(x,5.7,-19.6),chrome,Enum.Material.Metal)
		sign("Original roadside print",text,V(x,5.7,-19.45),Vector2.new(4,3.4),i==2 and red or C(39,70,69),ivory)
	end
	for _,z in {-13,-2,10} do
		part("Booth chrome plinth",V(3.25,.18,7.3),V(-23,.65,z),chrome,Enum.Material.Metal)
		part("Booth vinyl seat",V(3,1,7),V(-23,1.1,z),red,Enum.Material.Leather)
		part("Booth backrest",V(.65,3.6,7),V(-24.5,2.6,z),red,Enum.Material.Leather)
		for n=-3,3 do
			part("Upholstered backrest channel",V(.7,2.7,.86),V(-24.33,2.8,z+n*.94),C(164,39,44),Enum.Material.Leather,Enum.PartType.Ball)
			part("Seat stitched piping",V(2.9,.025,.025),V(-23,1.607,z+n*.94),C(200,82,74))
		end
		part("Backrest chrome top rail",V(.72,.08,7.1),V(-24.5,4.45,z),chrome,Enum.Material.Metal)
		part("Chrome table edge",V(6.1,.22,7.1),V(-18.5,2.76,z),chrome,Enum.Material.Metal)
		part("Ivory laminate tabletop",V(6,.12,7),V(-18.5,2.88,z),ivory,Enum.Material.Marble)
		disk("Table pedestal foot",V(-18.5,.09,z),1.2,.17,chrome,Enum.Material.Metal)
		disk("Table chrome pedestal",V(-18.5,1.4,z),.16,2.7,chrome,Enum.Material.Metal)
		meal(-20,z,z==10 and "burger" or "steak")
		part("Condiment caddy",V(.9,.12,.65),V(-17,3,z+2.5),chrome,Enum.Material.Metal)
		for i=1,2 do
			disk("Condiment bottle",V(-17.3+i*.3,3.25,z+2.5),.11,.45,i==1 and C(176,39,27) or C(220,172,42))
			disk("Bottle nozzle",V(-17.3+i*.3,3.53,z+2.5),.04,.13,ivory)
		end
		sign("Table menu","TODAY\nSTEAK & EGGS\nCOFFEE",V(-17,3.5,z-2.6),Vector2.new(.85,1),teal,ivory)
	end
	part("Service counter base",V(5,3.1,28),V(9,1.5,0),teal)
	for z=-13,13,.65 do part("Counter ribbed steel",V(.04,2,.06),V(6.47,1.5,z),chrome,Enum.Material.Metal) end
	part("Counter chrome edge",V(6.15,.3,29.15),V(9,3.2,0),chrome,Enum.Material.Metal)
	part("Counter laminate",V(6,.12,29),V(9,3.39,0),ivory,Enum.Material.Marble)
	for z=-12,12,6 do
		disk("Stool foot",V(4,.12,z),.72,.18,chrome,Enum.Material.Metal)
		disk("Stool chrome stem",V(4,1.15,z),.15,2,chrome,Enum.Material.Metal)
		ring("Stool foot ring",V(4,.8,z),.55,.055,chrome,Enum.Material.Metal,16)
		disk("Stool chrome rim",V(4,2.12,z),.94,.16,chrome,Enum.Material.Metal)
		disk("Red vinyl stool",V(4,2.27,z),.9,.22,red,Enum.Material.Leather)
		cup(8,3.47,z)
	end
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
	for _,pos in {V(-17,11,-8),V(-17,11,8),V(8,11,0),V(25,11,-10)} do
		disk("Ceiling lamp chrome ring",pos,.9,.14,chrome,Enum.Material.Metal)
		local fixture=disk("Opal ceiling diffuser",pos-V(0,.1,0),.8,.18,C(255,239,210),Enum.Material.Neon)
		local light=Instance.new("PointLight"); light.Color=C(255,233,199); light.Brightness=.65; light.Range=22; light.Parent=fixture
	end
	for _,x in {-7,17} do
		part("Ceiling vent frame",V(4,.09,2),V(x,11.5,3),chrome,Enum.Material.Metal)
		for i=1,12 do part("Vent louvre",V(.16,.07,1.75),V(x-1.9+i*.29,11.44,3),C(55,64,63),Enum.Material.Metal) end
	end
end

-- Detailed hand props remain welded to the R6 arm during the authored poses.
function Art.held(rig,arm,role)
	local function p(name,size,offset,color,shape,rotation)
		local part=Instance.new("Part"); part.Name=name; part.Size=size; part.Material=Enum.Material.Metal; part.Color=color or chrome
		part.CanCollide,part.CanTouch,part.CanQuery,part.Massless=false,false,false,true
		part.CFrame=arm.CFrame*CFrame.new(offset)*(rotation or CFrame.new()); if shape then part.Shape=shape end; part.Parent=rig
		local weld=Instance.new("WeldConstraint"); weld.Part0,weld.Part1,weld.Parent=arm,part,part
	end
	local grip=-arm.Size.Y*.43
	if role=="waitress" then
		p("Oval service tray",V(1.8,.08,1.3),V(0,grip,-.65),chrome,Enum.PartType.Ball)
		p("Tray porcelain cup",V(.46,.42,.42),V(.2,grip+.24,-.8),ivory,Enum.PartType.Cylinder,CFrame.Angles(0,0,math.pi/2))
		p("Tray coffee surface",V(.02,.35,.35),V(.2,grip+.48,-.8),C(48,26,16),Enum.PartType.Cylinder,CFrame.Angles(0,0,math.pi/2))
		for i=1,10 do
			local a=i*math.pi/5
			p("Tray mug handle",V(.065,.08,.065),V(.45+math.cos(a)*.12,grip+.26+math.sin(a)*.15,-.8),ivory,Enum.PartType.Ball)
		end
	else
		p("Utensil handle",V(.07,.08,.55),V(0,grip,-.28))
		if role=="chef" then
			p("Spatula blade",V(.42,.035,.46),V(0,grip,-.77))
			for i=1,3 do p("Spatula slot",V(.035,.038,.24),V(-.16+i*.08,grip,-.77),C(54,57,55)) end
		else
			p("Fork shoulder",V(.22,.035,.12),V(0,grip,-.59))
			for i=1,4 do p("Held fork tine",V(.025,.035,.24),V(-.1+i*.04,grip,-.76)) end
		end
	end
end
return Art
