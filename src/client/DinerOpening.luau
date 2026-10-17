local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local shared=game:GetService("ReplicatedStorage"):WaitForChild("GameShared")
local Timeline=require(shared.DinerTimeline)
local Outfit=require(shared.WesternOutfit)
local Diner={}

function Diner.create(profile)
	local model=Instance.new("Model")
	model.Name="ShirtsAndSkins_DinerOpening"
	local origin=Vector3.new(0,14000,0)
	local actors={}
	local function part(name,size,pos,color,material)
		local p=Instance.new("Part")
		p.Name,p.Size,p.CFrame=name,size,CFrame.new(origin+pos)
		p.Color,p.Material=color,material or Enum.Material.SmoothPlastic
		p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery=true,false,false,false
		p.Parent=model
		return p
	end
	local cream=Color3.fromRGB(208,191,157)
	local red=Color3.fromRGB(121,49,39)
	local metal=Color3.fromRGB(144,146,139)
	part("Diner foundation",Vector3.new(58,1,40),Vector3.new(0,-.6,0),Color3.fromRGB(85,76,62),Enum.Material.Concrete)
	for x=-26,26,4 do
		for z=-18,18,4 do
			part("Checker floor",Vector3.new(3.98,.08,3.98),Vector3.new(x,-.05,z),((x+z)/4)%2==0 and Color3.fromRGB(191,182,154) or Color3.fromRGB(66,65,57))
		end
	end
	part("Back wall",Vector3.new(58,12,.5),Vector3.new(0,5.5,-20),cream,Enum.Material.Plaster)
	part("Front wall base",Vector3.new(58,2,.5),Vector3.new(0,.8,20),red)
	part("Left wall",Vector3.new(.5,12,40),Vector3.new(-29,5.5,0),cream,Enum.Material.Plaster)
	part("Right wall",Vector3.new(.5,12,40),Vector3.new(29,5.5,0),cream,Enum.Material.Plaster)
	part("Ceiling",Vector3.new(58,.3,40),Vector3.new(0,11.5,0),Color3.fromRGB(184,166,136))
	for x=-24,24,12 do
		local window=part("Front sunset window",Vector3.new(10,6,.15),Vector3.new(x,5.2,20),Color3.fromRGB(202,154,101),Enum.Material.Glass)
		window.Transparency=.42
		for _,dx in {-5,0,5} do part("Window mullion",Vector3.new(.15,6,.3),Vector3.new(x+dx,5.2,20),metal,Enum.Material.Metal) end
	end
	local sign=part("Diner sign",Vector3.new(12,2,.15),Vector3.new(-18,8,-19.6),red)
	local surface=Instance.new("SurfaceGui"); surface.Face=Enum.NormalId.Back; surface.CanvasSize=Vector2.new(600,120); surface.Parent=sign
	local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1; label.Text="SUNSET DINER"; label.Font=Enum.Font.SpecialElite; label.TextSize=55; label.TextColor3=cream; label.Parent=surface
	local function meal(x,z)
		local plate=part("Ceramic plate",Vector3.new(.09,1.75,1.75),Vector3.new(x,2.98,z),cream)
		plate.Shape=Enum.PartType.Cylinder; plate.CFrame*=CFrame.Angles(0,0,math.pi/2)
		local food=part("Toast and meal",Vector3.new(.8,.15,.65),Vector3.new(x,3.1,z),Color3.fromRGB(163,102,47))
		food.CFrame*=CFrame.Angles(0,.25,0)
		part("Coffee cup",Vector3.new(.55,.65,.55),Vector3.new(x,3.2,z+1.2),cream)
		local coffee=part("Coffee",Vector3.new(.03,.4,.4),Vector3.new(x,3.54,z+1.2),Color3.fromRGB(57,35,21))
		coffee.Shape=Enum.PartType.Cylinder; coffee.CFrame*=CFrame.Angles(0,0,math.pi/2)
	end
	for _,z in {-13,-2,10} do
		part("Booth bench",Vector3.new(3,1,7),Vector3.new(-23,1.1,z),red,Enum.Material.Leather)
		part("Booth backrest",Vector3.new(.65,3.5,7),Vector3.new(-24.5,2.6,z),red,Enum.Material.Leather)
		part("Booth table",Vector3.new(5,.25,7),Vector3.new(-18.5,2.8,z),cream)
		part("Table pedestal",Vector3.new(.5,2.8,.5),Vector3.new(-18.5,1.3,z),metal,Enum.Material.Metal)
		meal(-19.5,z)
	end
	part("Long service counter",Vector3.new(5,3.1,28),Vector3.new(9,1.5,0),red)
	part("Counter top",Vector3.new(6,.25,29),Vector3.new(9,3.2,0),cream)
	for z=-12,12,6 do
		part("Stool stem",Vector3.new(.35,2,.35),Vector3.new(4,1,z),metal,Enum.Material.Metal)
		local seat=part("Stool cushion",Vector3.new(.3,2,2),Vector3.new(4,2.1,z),red,Enum.Material.Leather)
		seat.Shape=Enum.PartType.Cylinder; seat.CFrame*=CFrame.Angles(0,0,math.pi/2)
	end
	part("Kitchen partition",Vector3.new(.4,1.2,27),Vector3.new(20,.6,-4),cream)
	part("Kitchen stove",Vector3.new(6,3,4),Vector3.new(25,1.5,-13),metal,Enum.Material.Metal)
	for _,x in {23.8,26.2} do
		local burner=part("Stove burner",Vector3.new(.08,1.4,1.4),Vector3.new(x,3.06,-13),Color3.fromRGB(42,40,36),Enum.Material.Metal)
		burner.Shape=Enum.PartType.Cylinder; burner.CFrame*=CFrame.Angles(0,0,math.pi/2)
	end
	part("Kitchen prep shelf",Vector3.new(6,2.8,3),Vector3.new(25,1.4,-4),cream)
	for _,pos in {Vector3.new(-17,10,-8),Vector3.new(-17,10,8),Vector3.new(8,10,0),Vector3.new(25,10,-10)} do
		local fixture=part("Warm pendant",Vector3.new(2,.3,2),pos,cream,Enum.Material.Neon)
		local light=Instance.new("PointLight"); light.Color=Color3.fromRGB(255,209,145); light.Brightness=1.3; light.Range=25; light.Shadows=false; light.Parent=fixture
	end
	local blank=Instance.new("HumanoidDescription")
	local template
	local function cleanup()
		if template then template:Destroy(); template=nil end
		model:Destroy()
	end
	local function prepare(modelToPrepare)
		for _,desc in modelToPrepare:GetDescendants() do
			if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("Animator") then desc:Destroy()
			elseif desc:IsA("BasePart") then desc.CanCollide=false; desc.CanTouch=false; desc.CanQuery=false end
		end
		local root=modelToPrepare:FindFirstChild("HumanoidRootPart")
		assert(root,"Diner character has no root part")
		modelToPrepare.PrimaryPart=root; root.Anchored=true
		local humanoid=modelToPrepare:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None end
	end
	local function actor(name,rig,position,yaw,role,index)
		prepare(rig); rig.Name=name; rig.Parent=model
		local base=CFrame.new(origin+position)*CFrame.Angles(0,yaw,0)
		rig:PivotTo(base)
		local joints={}
		for _,joint in rig:GetDescendants() do
			if joint:IsA("Motor6D") then joints[joint.Name]={joint=joint,base=joint.C0} end
		end
		local hand=rig:FindFirstChild("RightHand") or rig:FindFirstChild("Right Arm")
		if hand then
			local prop=Instance.new("Part")
			prop.Name=role=="eat" and "Eating utensil" or (role=="chef" and "Cooking spatula" or "Serving tray")
			prop.Size=role=="waitress" and Vector3.new(1.5,.08,1) or Vector3.new(.1,.75,.1)
			prop.Material,prop.Color=Enum.Material.Metal,metal
			prop.CanCollide,prop.CanTouch,prop.CanQuery,prop.Massless=false,false,false,true
			prop.CFrame=hand.CFrame*CFrame.new(0,-.35,-.1)
			prop.Parent=rig
			local weld=Instance.new("WeldConstraint"); weld.Part0,weld.Part1,weld.Parent=hand,prop,prop
		end
		table.insert(actors,{rig=rig,base=base,joints=joints,role=role,index=index,r6=rig:FindFirstChild("Torso")~=nil})
	end
	local function setJoint(actor,name,rotation)
		local aliases={LeftShoulder="Left Shoulder",RightShoulder="Right Shoulder",LeftHip="Left Hip",RightHip="Right Hip"}
		local data=actor.joints[name] or actor.joints[aliases[name]]
		if data then data.joint.C0=CFrame.new(data.base.Position)*rotation*data.base.Rotation end
	end
	return {
		prepare=function()
			local ok,err=xpcall(function()
				template=Players:CreateHumanoidModelFromDescriptionAsync(blank,Enum.HumanoidRigType.R6)
				local character=Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
				local previous=character.Archivable; character.Archivable=true
				local hero=character:Clone(); character.Archivable=previous
				assert(hero,"Could not copy player avatar")
				Outfit.apply(hero,profile)
				actor("Main character",hero,Vector3.new(-23,3.1,-2),-math.pi/2,"eat",1)
				for i,z in {-13,10} do
					local npc=template:Clone()
					Outfit.apply(npc,{gender=i==1 and "Boy" or "Girl",outfit={Hat=i==1 and "cowboy" or "none",Costume="none"}})
					actor("Diner customer "..i,npc,Vector3.new(-23,3.1,z),-math.pi/2,"eat",i+1)
				end
				for i,role in {"waitress","chef"} do
					local npc=template:Clone()
					for _,body in npc:GetChildren() do
						if body:IsA("BasePart") and body.Name~="Head" and body.Name~="HumanoidRootPart" and not body.Name:find("Hand") then
						if body.Name:find("Leg") or body.Name:find("Foot") then body.Color=Color3.fromRGB(50,46,42)
						else body.Color=i==1 and Color3.fromRGB(114,145,129) or cream end
					end
					end
					local position=i==1 and Vector3.new(14,3,-6) or Vector3.new(25,3,-9)
					actor(role,npc,position,i==1 and math.pi/2 or 0,role,i+3)
				end
				template:Destroy(); template=nil
				model.Parent=workspace
			end,debug.traceback)
			blank:Destroy()
			if not ok then cleanup(); error(err) end
		end,
		play=function(root,ui,onFinish,reducedMotion)
			local timeline=Timeline.new()
			local elapsed=0
			local finished=false
			local hud=ui.make("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=25},root)
			for _,y in {0,1} do ui.make("Frame",{Size=UDim2.new(1,0,.07,0),Position=UDim2.fromScale(0,y),AnchorPoint=Vector2.new(0,y),BackgroundColor3=Color3.new(),BorderSizePixel=0},hud) end
			local controls=ui.make("Frame",{Position=UDim2.fromScale(.5,.89),AnchorPoint=Vector2.new(.5,0),Size=UDim2.fromOffset(440,44),BackgroundTransparency=1},hud)
			local controlScale=ui.make("UIScale",{},controls)
			local function resize() controlScale.Scale=math.min(root.AbsoluteSize.X/480,1) end
			local resizeConnection=root:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize); resize()
			local connection
			local function finish()
				if finished then return end
				finished=true; Timeline.skip(timeline)
				if connection then connection:Disconnect() end
				resizeConnection:Disconnect(); hud:Destroy(); cleanup(); onFinish()
			end
			ui.navButton(controls,"Next shot →",UDim2.fromOffset(0,0),UDim2.fromOffset(210,44),function() Timeline.next(timeline); if timeline.done then finish() end end)
			ui.navButton(controls,"Skip opening",UDim2.fromOffset(230,0),UDim2.fromOffset(210,44),finish)
			local function view(pos,target) return CFrame.lookAt(origin+pos,origin+target) end
			local shots={
				{view(Vector3.new(17,7,16),Vector3.new(-6,3,-3)),view(Vector3.new(-7,5,5),Vector3.new(-22,3.5,-2))},
				{view(Vector3.new(-7,5,5),Vector3.new(-22,3.5,-2)),view(Vector3.new(-17,4.8,1.5),Vector3.new(-22.2,3.9,-2))},
				{view(Vector3.new(-17,4.8,1.5),Vector3.new(-22.2,3.9,-2)),view(Vector3.new(-17.2,4.2,.8),Vector3.new(-21,3.3,-2))},
			}
			connection=RunService.RenderStepped:Connect(function(dt)
				elapsed+=dt
				Timeline.advance(timeline,dt)
				if timeline.done then finish(); return end
				local t=math.clamp(timeline.elapsed/Timeline.durations[timeline.shot],0,1)
				local blend=timeline.shot==1 and t or t*t*(3-2*t)
				local shot=shots[timeline.shot]
				local camera=workspace.CurrentCamera
				if camera then camera.CameraType=Enum.CameraType.Scriptable; camera.FieldOfView=52; camera.CFrame=reducedMotion() and shot[2] or shot[1]:Lerp(shot[2],blend) end
				for _,person in actors do
					local phase=elapsed*1.6+person.index
					local breath=math.sin(phase)*.025
					if person.role=="eat" then
						setJoint(person,"LeftHip",CFrame.Angles(math.pi/2,0,0)); setJoint(person,"RightHip",CFrame.Angles(math.pi/2,0,0))
						setJoint(person,"LeftKnee",CFrame.Angles(math.pi/2,0,0)); setJoint(person,"RightKnee",CFrame.Angles(math.pi/2,0,0))
						local bite=(math.sin(phase)+1)/2
						setJoint(person,"RightShoulder",CFrame.Angles(person.r6 and (1.0+bite*.65) or (.5+bite*.55),0,-.1)); setJoint(person,"RightElbow",CFrame.Angles(-.4-bite*1.2,0,0))
						setJoint(person,"Neck",CFrame.Angles(-bite*.12,math.sin(phase*.3)*.06,0))
						person.rig:PivotTo(person.base*CFrame.new(0,breath,0))
					elseif person.role=="waitress" then
						local walk=math.sin(elapsed*.55)*4
						person.rig:PivotTo(person.base*CFrame.new(walk,math.abs(math.sin(phase*2))*.035,0))
						setJoint(person,"LeftHip",CFrame.Angles(math.sin(phase*2)*.25,0,0)); setJoint(person,"RightHip",CFrame.Angles(-math.sin(phase*2)*.25,0,0))
						setJoint(person,"RightShoulder",CFrame.Angles(.7,0,0)); setJoint(person,"RightElbow",CFrame.Angles(-.8+math.sin(phase)*.15,0,0))
					else
						person.rig:PivotTo(person.base*CFrame.new(math.sin(elapsed*.5)*.4,breath,0))
						setJoint(person,"RightShoulder",CFrame.Angles(.8,math.sin(phase*2)*.2,0)); setJoint(person,"RightElbow",CFrame.Angles(-.7+math.sin(phase*2)*.2,0,0))
						setJoint(person,"LeftShoulder",CFrame.Angles(.6,0,0)); setJoint(person,"Neck",CFrame.Angles(-.18,math.sin(phase)*.1,0))
					end
				end
			end)
			return finish
		end,
		destroy=cleanup,
	}
end
return Diner
