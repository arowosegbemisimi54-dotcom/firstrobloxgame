local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local shared=game:GetService("ReplicatedStorage"):WaitForChild("GameShared")
local Timeline=require(shared.DinerTimeline)
local Outfit=require(shared.WesternOutfit)
local Art=require(script.Parent.DinerArt)
local Cast=require(script.Parent.DinerCast)
local Lighting=game:GetService("Lighting")
local Diner={}

function Diner.create(profile)
	local model=Instance.new("Model")
	model.Name="ShirtsAndSkins_DinerOpening"
	local origin=Vector3.new(0,14000,0)
	local actors={}
	Art.build(model,origin)
	local lightingSnapshot
	local effectSnapshot={}
	local blank=Instance.new("HumanoidDescription")
	local template
	local function cleanup()
		if template then template:Destroy(); template=nil end
		if lightingSnapshot then
			for key,value in lightingSnapshot do Lighting[key]=value end
			for effect,enabled in effectSnapshot do if effect.Parent then effect.Enabled=enabled end end
			lightingSnapshot=nil
		end
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
	local function actor(name,rig,position,yaw,role,index,face)
		prepare(rig); rig.Name=name; rig.Parent=model
		local base=CFrame.new(origin+position)*CFrame.Angles(0,yaw,0)
		rig:PivotTo(base)
		local joints={}
		for _,joint in rig:GetDescendants() do
			if joint:IsA("Motor6D") then joints[joint.Name]={joint=joint,base=joint.C0} end
		end
		local hand=rig:FindFirstChild("RightHand") or rig:FindFirstChild("Right Arm")
		if hand then Art.held(rig,hand,role) end
		table.insert(actors,{rig=rig,base=base,joints=joints,role=role,index=index,face=face,r6=rig:FindFirstChild("Torso")~=nil})
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
				actor("Main character",hero,Vector3.new(-31,2.65,-10.5),math.pi,"eat",1)
				for i,z in {-26.5,5.5} do
					local npc=template:Clone()
					local name,face=Cast.dress(npc,i)
					actor(name,npc,Vector3.new(-31,2.65,z),math.pi,"eat",i+1,face)
				end
				for i,role in {"waitress","chef"} do
					local npc=template:Clone()
					local name,face=Cast.dress(npc,i+2)
					local position=i==1 and Vector3.new(20,3,-6) or Vector3.new(25,3,-9)
					actor(name,npc,position,i==1 and math.pi/2 or 0,role,i+3,face)
				end
				template:Destroy(); template=nil
				model.Parent=workspace
			end,debug.traceback)
			blank:Destroy()
			if not ok then cleanup(); error(err) end
		end,
		play=function(root,ui,onFinish,reducedMotion)
			lightingSnapshot={}
			local noon={ClockTime=12,GeographicLatitude=28,Brightness=2.3,Ambient=Color3.fromRGB(112,115,118),OutdoorAmbient=Color3.fromRGB(147,155,165),ColorShift_Top=Color3.new(),ColorShift_Bottom=Color3.new(),FogStart=500,FogEnd=100000,ExposureCompensation=0,GlobalShadows=true}
			for key,value in noon do lightingSnapshot[key]=Lighting[key]; Lighting[key]=value end
			for _,effect in Lighting:GetChildren() do
				if effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") then effectSnapshot[effect]=effect.Enabled; effect.Enabled=false end
			end
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
				{view(Vector3.new(-1,8,30),Vector3.new(-22,4,-10)),view(Vector3.new(-20,6,-1),Vector3.new(-31,3.8,-10.5))},
				{view(Vector3.new(-20,6,-1),Vector3.new(-31,3.8,-10.5)),view(Vector3.new(-27,5.2,-5.7),Vector3.new(-31,3.8,-10.5))},
				{view(Vector3.new(-27,5.2,-5.7),Vector3.new(-31,3.8,-10.5)),view(Vector3.new(-28,4.7,-5.2),Vector3.new(-31,3.25,-8.5))},
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
					if person.face then person.face(elapsed,person.role=="eat") end
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
