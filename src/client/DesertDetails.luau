-- Local scenery: no uploaded assets or changes to the place's Terrain.
local Details = {}

function Details.build(part, model, origin, random)
	local sand = Color3.fromRGB(185,140,91)
	local rust = Color3.fromRGB(126,66,43)
	local dark = Color3.fromRGB(49,47,42)
	local function cylinder(name, from, to, width, color, parent)
		local p = part(name,Vector3.new((to-from).Magnitude,width,width),(from+to)/2,color,Enum.Material.Wood)
		p.Shape = Enum.PartType.Cylinder
		p.CFrame = CFrame.lookAt(origin+(from+to)/2,origin+to)*CFrame.Angles(0,math.pi/2,0)
		p.CastShadow=false
		if parent then p.Parent=parent end
		return p
	end
	local function triangle(a,b,c,color)
		local ab,ac,bc=b-a,c-a,c-b
		if ab:Dot(ab)>ac:Dot(ac) and ab:Dot(ab)>bc:Dot(bc) then a,c=c,a
		elseif ac:Dot(ac)>bc:Dot(bc) then a,b=b,a end
		ab,ac,bc=b-a,c-a,c-b
		if ac:Cross(ab).Magnitude < .001 then return end
		local right=ac:Cross(ab).Unit
		local back=bc.Unit
		local up=back:Cross(right).Unit
		local height=math.abs(ab:Dot(up))
		for _,data in {{(a+b)/2,right,back,math.abs(ab:Dot(back))},{(a+c)/2,-right,-back,math.abs(ac:Dot(back))}} do
			local wedge=Instance.new("WedgePart")
			wedge.Name="Eroded sandstone slope"
			wedge.Size=Vector3.new(.08,height,math.max(.05,data[4]))
			wedge.CFrame=CFrame.fromMatrix(origin+data[1],data[2],up,data[3])
			wedge.Material,wedge.Color=Enum.Material.Sandstone,color
			wedge.Anchored,wedge.CanCollide,wedge.CanTouch,wedge.CanQuery=true,false,false,false
			wedge.CastShadow=false
			wedge.Parent=model
		end
	end
	-- A continuous, irregular mountain belt. Shared vertices avoid gaps between slopes.
	local sections=56
	local rings={}
	for ring=1,4 do
		rings[ring]={}
		for i=0,sections-1 do
			local angle=i*math.pi*2/sections
			local n=math.noise(math.cos(angle)*3.7,math.sin(angle)*3.7,9)
			local radius=({240,350,490,650})[ring]+n*45
			local ridge=math.max(0,math.sin(angle*3+.9)*.5+.5)
			local height=({-3,42,65,-8})[ring]
			if ring==2 or ring==3 then
				height=height+ridge*55+math.noise(math.cos(angle)*8,math.sin(angle)*8,ring)*45
			end
			rings[ring][i+1]=Vector3.new(math.cos(angle)*radius,height,math.sin(angle)*radius)
		end
	end
	for ring=1,3 do
		for i=1,sections do
			local nextIndex=i%sections+1
			local a,b,c,d=rings[ring][i],rings[ring][nextIndex],rings[ring+1][i],rings[ring+1][nextIndex]
			local color=Color3.fromRGB(151+ring*5,104+ring*4,72+ring*3):Lerp(sand,random:NextNumber(.05,.22))
			triangle(a,b,c,color); triangle(b,d,c,color)
		end
	end
	-- Broad sand drifts and rounded boulders soften the transition into the mountains.
	for i=1,18 do
		local angle=i*math.pi*2/18
		local dune=part("Wind-shaped sand drift",Vector3.new(random:NextNumber(65,105),random:NextNumber(10,20),random:NextNumber(45,85)),Vector3.new(math.cos(angle)*185,-5,math.sin(angle)*185),sand,Enum.Material.Sand)
		dune.Shape=Enum.PartType.Ball
		dune.Orientation=Vector3.new(0,random:NextNumber(0,180),0)
		dune.CastShadow=false
	end
	-- The highway and station remain behind the single camper in the initial shot.
	part("Windblown road shoulder",Vector3.new(1700,.12,29),Vector3.new(0,-.91,88),Color3.fromRGB(153,124,86),Enum.Material.Sand)
	part("Abandoned highway",Vector3.new(1700,.14,21),Vector3.new(0,-.8,88),Color3.fromRGB(71,67,59),Enum.Material.Asphalt)
	for x=-780,780,26 do
		part("Faded road center line",Vector3.new(10,.025,.22),Vector3.new(x,-.715,88),Color3.fromRGB(164,137,82))
	end
	for _,z in {78.5,97.5} do
		part("Worn edge stripe",Vector3.new(1700,.025,.14),Vector3.new(0,-.715,z),Color3.fromRGB(164,153,129))
	end
	for _=1,16 do
		local patch=part("Sand across asphalt",Vector3.new(random:NextNumber(4,12),.03,random:NextNumber(1,4)),Vector3.new(random:NextNumber(-220,220),-.69,random:NextNumber(78,98)),sand,Enum.Material.Sand,CFrame.Angles(0,random:NextNumber(-.6,.6),0))
		patch.Transparency=.18
	end
	local station=Vector3.new(-100,0,132)
	local function stationPart(name,size,offset,color,material,rotation)
		return part(name,size,station+offset,color,material,rotation)
	end
	stationPart("Cracked station apron",Vector3.new(58,.2,44),Vector3.new(0,-.85,-9),Color3.fromRGB(137,123,102),Enum.Material.Concrete)
	stationPart("Abandoned station walls",Vector3.new(34,9,14),Vector3.new(0,3.6,8),Color3.fromRGB(184,167,133),Enum.Material.Plaster)
	stationPart("Rust roof fascia",Vector3.new(36,1.3,16),Vector3.new(0,8.1,8),rust,Enum.Material.CorrodedMetal)
	for x=-16,16,2 do
		stationPart("Corrugated roof seam",Vector3.new(.15,.16,15),Vector3.new(x,8.82,8),dark,Enum.Material.Metal)
	end
	for _,x in {-10,10} do
		stationPart("Dark shop window",Vector3.new(9,4,.15),Vector3.new(x,4, .91),Color3.fromRGB(34,45,43),Enum.Material.Glass)
		for _,tilt in {-12,18} do
			stationPart("Boarded window",Vector3.new(10,.65,.3),Vector3.new(x,4+tilt*.06,.7),Color3.fromRGB(112,87,58),Enum.Material.Wood,CFrame.Angles(0,0,math.rad(tilt)))
		end
	end
	stationPart("Locked station door",Vector3.new(3.5,6.7,.2),Vector3.new(0,2.7,.8),Color3.fromRGB(72,82,73),Enum.Material.Wood)
	stationPart("Canopy",Vector3.new(42,.65,17),Vector3.new(0,10,-15),Color3.fromRGB(175,151,107),Enum.Material.CorrodedMetal,CFrame.Angles(0,0,math.rad(-1)))
	stationPart("Canopy rust edge",Vector3.new(42,.85,.3),Vector3.new(0,9.8,-23.5),rust,Enum.Material.CorrodedMetal)
	for _,x in {-18,18} do
		stationPart("Canopy support",Vector3.new(.45,10,.45),Vector3.new(x,4.2,-19),rust,Enum.Material.CorrodedMetal)
	end
	for _,x in {-10,10} do
		stationPart("Pump island",Vector3.new(5,.3,5),Vector3.new(x,-.6,-14),Color3.fromRGB(121,112,95),Enum.Material.Concrete)
		stationPart("Old fuel pump base",Vector3.new(2.4,2.5,2),Vector3.new(x,.8,-14),rust,Enum.Material.CorrodedMetal)
		stationPart("Old fuel pump head",Vector3.new(2.8,2.3,2.2),Vector3.new(x,3,-14),Color3.fromRGB(201,186,150),Enum.Material.Metal)
		stationPart("Dead pump display",Vector3.new(1.8,.8,.08),Vector3.new(x,3.2,-15.15),dark)
		local points={Vector3.new(x+1.5,3,-14),Vector3.new(x+2.3,2.2,-14),Vector3.new(x+2.4,.3,-14),Vector3.new(x+1.6,1.1,-14)}
		for j=1,#points-1 do cylinder("Hanging pump hose",station+points[j],station+points[j+1],.14,dark) end
	end
	stationPart("Roadside sign post",Vector3.new(.7,19,.7),Vector3.new(36,8.5,-22),rust,Enum.Material.CorrodedMetal)
	local sign=stationPart("Sunbleached station sign",Vector3.new(13,6,.45),Vector3.new(36,16,-22),Color3.fromRGB(190,170,124),Enum.Material.CorrodedMetal,CFrame.Angles(0,0,math.rad(-7)))
	for _,face in {Enum.NormalId.Front,Enum.NormalId.Back} do
		local surface=Instance.new("SurfaceGui")
		surface.Face,surface.CanvasSize,surface.Parent=face,Vector2.new(520,240),sign
		local label=Instance.new("TextLabel")
		label.Size,label.BackgroundTransparency=UDim2.fromScale(1,1),1
		label.Text,label.Font,label.TextSize="LAST STOP\nG A S",Enum.Font.SpecialElite,65
		label.TextColor3=Color3.fromRGB(88,52,35)
		label.Parent=surface
	end
	for x=-200,230,85 do
		local p=Vector3.new(x,0,110)
		cylinder("Old utility pole",p+Vector3.new(0,-1,0),p+Vector3.new(0,20,0),.65,Color3.fromRGB(99,74,49))
		cylinder("Utility cross arm",p+Vector3.new(0,18,-3),p+Vector3.new(0,18,3),.3,Color3.fromRGB(99,74,49))
		if x<225 then
			local last=p+Vector3.new(0,19,0)
			for step=1,6 do
				local t=step/6
				local nextPoint=p+Vector3.new(t*85,19-math.sin(t*math.pi)*2,0)
				cylinder("Sagging utility line",last,nextPoint,.055,dark); last=nextPoint
			end
		end
	end
	-- Reuse four small branch cages. Spawn cadence is 2–4 seconds, lifespan 8 seconds.
	local weeds={}
	for index=1,4 do
		local weed=Instance.new("Model")
		weed.Name="Rolling tumbleweed"
		local radius=random:NextNumber(.8,1.25)
		for ring=1,3 do
			local tilt=CFrame.Angles(ring*.9,ring*1.7,ring*.4)
			local previous
			for step=0,8 do
				local theta=step/8*math.pi*2
				local point=tilt:VectorToWorldSpace(Vector3.new(math.cos(theta)*radius,math.sin(theta)*radius,math.sin(theta*3)*.2))
				if previous then cylinder("Dry tumbleweed branch",previous,point,.07,Color3.fromRGB(122,95,57),weed) end
				previous=point
			end
		end
		weed.WorldPivot=CFrame.new(origin)
		weeds[index]={model=weed,radius=radius,age=8}
	end
	local clock,deadline,accumulator=0,2.5,0
	local lowEffects=false
	local function parkAll()
		for _,weed in weeds do weed.model.Parent=nil; weed.age=8 end
	end
	return {
		update=function(dt,visible,motionAllowed)
			if not visible or not motionAllowed then return end
			accumulator+=dt
			if accumulator<1/30 then return end
			local elapsed=accumulator; accumulator=0; clock+=elapsed
			if clock>=deadline then
				deadline=clock+random:NextNumber(2,4)
				local active=0
				for _,weed in weeds do if weed.age<8 then active+=1 end end
				if not lowEffects or active<1 then
					for _,weed in weeds do
						if weed.age>=8 then
							weed.age=0; weed.start=Vector3.new(random:NextNumber(-65,50),weed.radius-.9,random:NextNumber(43,67))
							weed.model:PivotTo(CFrame.new(origin+weed.start))
							weed.model.Parent=model
							break
						end
					end
				end
			end
			for _,weed in weeds do
				if weed.age<8 then
					weed.age+=elapsed
					if weed.age>=8 then weed.model.Parent=nil
					else
						local distance=weed.age*2.8
						local position=weed.start+Vector3.new(distance,math.abs(math.sin(weed.age*3))*.09,0)
						weed.model:PivotTo(CFrame.new(origin+position)*CFrame.Angles(0,0,-distance/weed.radius))
						local fade=math.clamp(math.max(1-weed.age/.8,(weed.age-6.5)/1.5),0,1)
						for _,branch in weed.model:GetChildren() do branch.Transparency=fade end
					end
				end
			end
		end,
		setLowEffects=function(enabled) lowEffects=enabled; parkAll() end,
		destroy=function() for _,weed in weeds do weed.model:Destroy() end end,
	}
end
return Details
