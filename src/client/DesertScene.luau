local Lighting = game:GetService("Lighting")
local Scene = {}

function Scene.create()
	local model = Instance.new("Model")
	model.Name = "ShirtsAndSkins_MenuScene"
	local origin = Vector3.new(0, 12000, 0)
	local sand = Color3.fromRGB(177, 127, 77)
	local dark = Color3.fromRGB(44, 42, 37)
	local function part(name, size, position, color, material, rotation)
		local p = Instance.new("Part")
		p.Name, p.Size = name, size
		p.CFrame = CFrame.new(origin + position) * (rotation or CFrame.identity)
		p.Color, p.Material = color, material or Enum.Material.SmoothPlastic
		p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
		p.CastShadow = true
		p.Parent = model
		return p
	end
	part("Desert", Vector3.new(1800, 4, 1800), Vector3.new(0, -3, 0), sand, Enum.Material.Sand)
	local random = Random.new(817)
	for i = 1, 24 do
		local angle = i * math.pi * 2 / 24
		local radius = random:NextNumber(230, 390)
		local mesa = part("Distant mesa", Vector3.new(random:NextNumber(55, 110), random:NextNumber(25, 55), random:NextNumber(50, 100)), Vector3.new(math.cos(angle)*radius, 4, math.sin(angle)*radius), Color3.fromRGB(137, 86, 60), Enum.Material.Sandstone)
		mesa.Orientation = Vector3.new(0, random:NextNumber(0, 180), random:NextNumber(-9, 9))
	end
	for i = 1, 22 do
		local x, z = random:NextNumber(-150, 150), random:NextNumber(-150, 150)
		if Vector2.new(x, z).Magnitude > 30 then
			local height = random:NextNumber(5, 10)
			local green = Color3.fromRGB(77, 93, 62)
			part("Cactus trunk", Vector3.new(1.4, height, 1.4), Vector3.new(x, height/2-1, z), green)
			part("Cactus arm", Vector3.new(3.5, 1.1, 1.1), Vector3.new(x+1, height*.5, z), green)
			part("Cactus tip", Vector3.new(1.1, 2.8, 1.1), Vector3.new(x+2.2, height*.5+1, z), green)
		end
	end
	for _ = 1, 32 do
		local p = Vector3.new(random:NextNumber(-100,100), -.2, random:NextNumber(-100,100))
		local stone = part("Desert stone", Vector3.new(2,1,1.4)*random:NextNumber(.4,1.6), p, Color3.fromRGB(123,100,78), Enum.Material.Rock)
		stone.Orientation = Vector3.new(0,random:NextNumber(0,180),12)
	end
	-- A single original camper, with an extended side awning and pitched canvas tent.
	part("Camper chassis",Vector3.new(9,1,21),Vector3.new(0,2,0),dark,Enum.Material.Metal)
	part("Camper body",Vector3.new(9,7,20),Vector3.new(0,6,0),Color3.fromRGB(219,204,169))
	part("Camper roof",Vector3.new(9.5,.5,20.5),Vector3.new(0,9.7,0),Color3.fromRGB(231,219,187))
	for _,x in {-4.56,4.56} do
		part("Ochre stripe",Vector3.new(.12,.8,19),Vector3.new(x,4.8,0),Color3.fromRGB(145,90,45))
		for _,z in {-5,1,6} do
			part("Side window",Vector3.new(.15,2.5,3.2),Vector3.new(x,7,z),Color3.fromRGB(43,62,64),Enum.Material.Glass)
		end
		for _,z in {-6.5,6.5} do
			local wheel = part("Tire",Vector3.new(1.2,3.6,3.6),Vector3.new(x,2,z),dark,Enum.Material.Rubber)
			wheel.Shape = Enum.PartType.Cylinder
			local hub = part("Wheel hub",Vector3.new(1.3,1.8,1.8),Vector3.new(x,2,z),Color3.fromRGB(133,130,119),Enum.Material.Metal)
			hub.Shape = Enum.PartType.Cylinder
		end
	end
	part("Windshield",Vector3.new(7.6,3,.15),Vector3.new(0,7.1,-10.1),Color3.fromRGB(42,62,65),Enum.Material.Glass)
	for _,x in {-3.2,3.2} do
		part("Headlamp",Vector3.new(1.2,.7,.2),Vector3.new(x,4,-10.2),Color3.fromRGB(243,214,157),Enum.Material.Neon)
	end
	part("Door",Vector3.new(.18,5,2.4),Vector3.new(4.6,5.5,-6.5),Color3.fromRGB(172,158,129))
	part("Awning",Vector3.new(11,.25,13),Vector3.new(10,8,1),Color3.fromRGB(183,157,102),Enum.Material.Fabric,CFrame.Angles(0,0,math.rad(-5)))
	for _,z in {-5,7} do
		part("Awning pole",Vector3.new(.18,8,.18),Vector3.new(15,3,z),dark,Enum.Material.Metal)
	end
	for _,side in {-1,1} do
		part("Tent canvas",Vector3.new(5.7,.2,9),Vector3.new(25+side*2,1.4,8),Color3.fromRGB(142,113,68),Enum.Material.Fabric,CFrame.Angles(0,0,math.rad(side*-45)))
	end
	part("Camp table",Vector3.new(4,.3,2.5),Vector3.new(10,2.5,1),Color3.fromRGB(110,78,48),Enum.Material.Wood)
	for _,x in {8.5,11.5} do
		part("Table leg",Vector3.new(.2,3,.2),Vector3.new(x,1,1),dark)
	end
	local vent = part("Roof vent",Vector3.new(1.4,.8,1.4),Vector3.new(0,10,-2),dark,Enum.Material.Metal)
	local smoke = Instance.new("Smoke")
	smoke.Name, smoke.Color, smoke.Opacity, smoke.RiseVelocity, smoke.Size = "Camp smoke", Color3.fromRGB(149,139,126), .16, 3, 4
	smoke.Parent = vent
	model.Parent = workspace
	local previous = {}
	for _, key in {"ClockTime","Brightness","Ambient","OutdoorAmbient","FogStart","FogEnd","FogColor"} do previous[key] = Lighting[key] end
	Lighting.ClockTime, Lighting.Brightness = 17.7, 2
	Lighting.Ambient, Lighting.OutdoorAmbient = Color3.fromRGB(109,83,72), Color3.fromRGB(151,115,86)
	Lighting.FogStart, Lighting.FogEnd, Lighting.FogColor = 120, 850, Color3.fromRGB(205,153,113)
	local grade = Instance.new("ColorCorrectionEffect")
	grade.Name, grade.TintColor, grade.Contrast, grade.Saturation = "MenuSunset", Color3.fromRGB(255,224,190), .13, -.15
	grade.Parent = Lighting
	return {
		focus = origin + Vector3.new(2,5,0),
		setLowEffects = function(enabled) smoke.Enabled = not enabled; grade.Enabled = not enabled end,
		destroy = function()
			model:Destroy(); grade:Destroy()
			for key,value in previous do Lighting[key] = value end
		end,
	}
end
return Scene
