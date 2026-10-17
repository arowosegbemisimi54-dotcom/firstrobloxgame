-- Bounded local scenery traffic; one departure every four seconds.
local Cars=require(script.Parent.VintageCars)
local Traffic={}
function Traffic.build(part,parent,origin)
	local V=Vector3.new
	local C=Color3.fromRGB
	local gray=C(97,89,76)
	local roadZ=88
	for _,side in {-1,1} do
		local entrance=side*215
		for _,offset in {-20,20} do
			part("Tunnel stone pier",V(14,26,10),V(entrance,12,roadZ+offset),gray,Enum.Material.Rock)
		end
		part("Tunnel mountain lintel",V(18,18,52),V(entrance,30,roadZ),C(145,101,68),Enum.Material.Sandstone)
		-- A continuous vaulted interior conceals the end of the roadway.
		for i=0,12 do
			local a=i*math.pi/12
			local z=roadZ+math.cos(a)*15.7
			local y=3+math.sin(a)*15.7
			part("Tunnel arch masonry",V(16,3.3,4.5),V(entrance,y,z),C(122+i%3*7,113+i%3*6,95),Enum.Material.Concrete,CFrame.Angles(math.pi/2-a,0,0))
			part("Vaulted tunnel interior",V(640,1.5,4.5),V(side*535,y,z),C(60,57,51),Enum.Material.Concrete,CFrame.Angles(math.pi/2-a,0,0))
		end
		for _,offset in {-15,15} do part("Tunnel interior side wall",V(640,5,.8),V(side*535,1,roadZ+offset),C(60,57,51),Enum.Material.Concrete) end
		part("Tunnel dark vanishing point",V(.5,28,30),V(side*850,12,roadZ),C(12,12,12))
		for _,z in {roadZ-13,roadZ+13} do
			for i=1,4 do part("Tunnel reflective marker",V(.3,.65,.3),V(side*(210+i*5),1.8,z),C(238,191,84),Enum.Material.Neon) end
		end
	end
	local pool={}
	local colors={C(94,127,119),C(141,65,47),C(197,176,126),C(51,68,84)}
	local function vehicle(index,motorcycle)
		local variant=(index-1)%4+1
		local model=Instance.new("Model"); model.Name=motorcycle and "Antique motorcycle with rider" or "Antique touring car"
		local function p(name,size,at,color,shape,rotation)
			local obj=part(name,size,at,color,Enum.Material.SmoothPlastic,rotation)
			obj.Parent=model; if shape then obj.Shape=shape end
			return obj
		end
		local dark=C(30,29,27); local metal=C(169,166,149)
		local function wheel(x,z,radius)
			p("Traffic tire",V(.55,radius*2,radius*2),V(x,radius-.7,z),dark,Enum.PartType.Cylinder)
			p("Chrome wheel hub",V(.57,radius*1.1,radius*1.1),V(x,radius-.7,z),metal,Enum.PartType.Cylinder)
		end
		if motorcycle then
			wheel(0,-2.1,1); wheel(0,2,1)
			p("Motorcycle engine",V(.9,1.1,1.5),V(0,.7,.2),metal)
			p("Teardrop fuel tank",V(1.1,.8,1.6),V(0,1.5,-.7),colors[index%4+1],Enum.PartType.Ball)
			p("Leather saddle",V(1,.23,1.2),V(0,1.5,1),dark)
			p("Front fork",V(.14,2,.14),V(0,.8,-1.9),metal,nil,CFrame.Angles(-.22,0,0))
			p("Chrome handlebar",V(1.6,.13,.13),V(0,2,-1.5),metal)
			p("Round motorcycle headlamp",V(.6,.6,.15),V(0,1.7,-2),C(243,215,154),Enum.PartType.Ball)
			-- A posed six-part R6-proportioned background rider, seated at the controls.
			local rider=Instance.new("Model"); rider.Name="R6 background rider"; rider.Parent=model
			local function body(name,size,pos,color,rotation)
				local b=p(name,size,pos,color,nil,rotation); b.Parent=rider; return b
			end
			body("Torso",V(1.4,1.45,.7),V(0,2.45,.7),C(75,58,43),CFrame.Angles(-.18,0,0))
			local head=body("Head",V(.95,.95,.95),V(0,3.62,.42),C(191,145,108)); head.Shape=Enum.PartType.Ball
			p("Rider leather helmet",V(1.02,.58,1.02),V(0,3.97,.42),dark,Enum.PartType.Ball)
			p("Rider goggles",V(.8,.19,.12),V(0,3.69,-.06),metal)
			for _,side in {-1,1} do
				body(side<0 and "Left Arm" or "Right Arm",V(.43,1.6,.43),V(side*.78,2.35,-.6),C(75,58,43),CFrame.Angles(1,0,side*.1))
				body(side<0 and "Left Leg" or "Right Leg",V(.48,1.7,.48),V(side*.62,.95,.9),C(47,53,57),CFrame.Angles(.5,0,side*.15))
			end
		else
			Cars.build(p,wheel,variant)
			model:SetAttribute("VehicleDesign",Cars.names[variant])
		end
		model.WorldPivot=CFrame.new(origin)
		model.Parent=nil
		return {model=model,age=math.huge,motorcycle=motorcycle,variant=variant}
	end
	-- Separate pools allow a car at every four-second mark, with motorcycles
	-- interleaved two seconds after every third departure. No new instances are made while running.
	for i=1,8 do pool[i]=vehicle(i,false) end
	for i=9,11 do pool[i]=vehicle(i,true) end
	local clock,nextDeparture,departures,nextBike,bikeDepartures=0,4,0,14,0
	local lifetime=28
	local function launch(motorcycle,direction,age,variant)
		for _,entry in pool do
			if entry.motorcycle==motorcycle and entry.age>=lifetime and (motorcycle or entry.variant==variant) then
				entry.age=age; entry.direction=direction; entry.model.Parent=parent
				entry.model:SetAttribute("DepartureTime",clock-age); entry.model:SetAttribute("TravelDirection",direction)
				return
			end
		end
	end
	return {
		update=function(dt,visible,motionAllowed)
			if not visible or not motionAllowed then return end
			clock+=dt
			for _,entry in pool do if entry.age<lifetime then entry.age+=dt end end
			while clock>=nextDeparture do
				departures+=1
				local age=clock-nextDeparture
				if age<lifetime then
					local direction=departures%2==0 and -1 or 1
					launch(false,direction,age,(departures-1)%4+1)
				end
				nextDeparture+=4
			end
			while clock>=nextBike do
				bikeDepartures+=1
				if clock-nextBike<lifetime then launch(true,bikeDepartures%2==0 and 1 or -1,clock-nextBike) end
				nextBike+=12
			end
			for _,entry in pool do
				if entry.age>=lifetime then entry.model.Parent=nil
				else
					local x=entry.direction*(-245+entry.age*17.5)
					local z=roadZ+entry.direction*5+(entry.motorcycle and 2 or 0)
					entry.model:PivotTo(CFrame.new(origin+V(x,0,z))*CFrame.Angles(0,-entry.direction*math.pi/2,0))
				end
			end
		end,
		destroy=function() for _,entry in pool do entry.model:Destroy() end end,
	}
end
return Traffic
