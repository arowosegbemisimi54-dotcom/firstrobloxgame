local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local shared=game:GetService("ReplicatedStorage"):WaitForChild("GameShared")
local Timeline=require(shared.DinerTimeline)
local Outfit=require(shared.WesternOutfit)
local Art=require(script.Parent.DinerArt)
local Cast=require(script.Parent.DinerCast)
local Motion=require(script.Parent.CharacterMotion)
local Lighting=game:GetService("Lighting")
local Broadcast=require(script.Parent.DinerBroadcast)
local Exterior=require(script.Parent.DinerExterior)
local Escape=require(script.Parent.DinerEscape)
local Diner={}

function Diner.create(profile)
	local model=Instance.new("Model")
	model.Name="ShirtsAndSkins_DinerOpening"
	local origin=Vector3.new(0,14000,0)
	local actors={}
	Art.build(model,origin)
	local exterior=Exterior.build(model,origin)
	local broadcast=Broadcast.create(model,origin,Timeline.dialogue)
	local lightingSnapshot
	local effectSnapshot={}
	local blank=Instance.new("HumanoidDescription")
	local template
	local preparedEscape
	local function cleanup()
		if preparedEscape then preparedEscape.destroy(); preparedEscape=nil end
		if template then template:Destroy(); template=nil end
		if lightingSnapshot then
			for key,value in lightingSnapshot do Lighting[key]=value end
			for effect,enabled in effectSnapshot do if effect.Parent then effect.Enabled=enabled end end
			lightingSnapshot=nil
		end
		broadcast.destroy()
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
		local props=hand and Art.held(rig,hand,role) or {}
		props=props or {}
		table.insert(actors,{rig=rig,base=base,joints=joints,role=role,index=index,face=face,props=props,r6=rig:FindFirstChild("Torso")~=nil})
	end
	local coffeeStream=Instance.new("Part"); coffeeStream.Name="Coffee pour stream"; coffeeStream.Size=Vector3.new(.035,.035,.2); coffeeStream.Color=Color3.fromRGB(79,44,24); coffeeStream.Anchored=true; coffeeStream.CanCollide=false; coffeeStream.CanTouch=false; coffeeStream.CanQuery=false; coffeeStream.Transparency=1; coffeeStream.Parent=model
	local setJoint=Motion.joint
	return {
		prepare=function()
			local ok,err=xpcall(function()
				template=Players:CreateHumanoidModelFromDescriptionAsync(blank,Enum.HumanoidRigType.R15)
				local character=Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
				local hero
				if character:FindFirstChild("UpperTorso") then
					local previous=character.Archivable; character.Archivable=true
					hero=character:Clone(); character.Archivable=previous
				else
					-- Studio/account avatars can still spawn as R6. Convert the
					-- appearance explicitly instead of copying that rig into the story.
					local humanoid=assert(character:FindFirstChildOfClass("Humanoid"),"Player avatar has no Humanoid")
					local description=humanoid:GetAppliedDescription()
					local converted,result=pcall(function()
						return Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15)
					end)
					description:Destroy()
					if not converted then error(result) end
					hero=result
				end
				assert(hero and hero:FindFirstChild("UpperTorso"),"Could not create R15 story avatar")
				Outfit.apply(hero,profile)
				actor("Main character",hero,Vector3.new(-31,2.65,-10.5),math.pi,"eat",1)
				for i,z in {-26.5,-19.5} do
					local npc=template:Clone()
					local name,face=Cast.dress(npc,i)
					actor(name,npc,Vector3.new(-31,2.65,z),i==1 and math.pi or 0,"eat",i+1,face)
				end
				for i,role in {"waitress","chef"} do
					local npc=template:Clone()
					local name,face=Cast.dress(npc,i+2)
					local position=i==1 and Vector3.new(19.6,3,4) or Vector3.new(25,3,-9)
					actor(name,npc,position,i==1 and math.pi/2 or 0,role,i+3,face)
				end
				for _,spec in {{5,"reader",Vector3.new(-31,2.65,5.5),math.pi},{6,"bar",Vector3.new(10,3.25,4),-math.pi/2}} do
					local npc=template:Clone(); local name,face=Cast.dress(npc,spec[1])
					actor(name,npc,spec[3],spec[4],spec[2],spec[1]+1,face)
				end
				preparedEscape=Escape.prepare({model=model,origin=origin,exterior=exterior,actors=actors,rigTemplate=template})
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
			local subtitle=ui.make("TextLabel",{Name="Blox News subtitles",Position=UDim2.fromScale(.1,.72),Size=UDim2.fromScale(.8,.14),BackgroundColor3=Color3.fromRGB(12,16,22),BackgroundTransparency=.18,TextColor3=Color3.fromRGB(245,236,213),TextSize=20,TextWrapped=true,Font=Enum.Font.SpecialElite,Text="",Visible=false},hud)
			local controlScale=ui.make("UIScale",{},controls)
			local function resize() controlScale.Scale=math.min(root.AbsoluteSize.X/480,1) end
			local resizeConnection=root:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize); resize()
			local connection
			local stopEscape
			local function finish()
				if finished then return end
				finished=true; Timeline.skip(timeline)
				if connection then connection:Disconnect() end
				resizeConnection:Disconnect(); hud:Destroy(); if stopEscape then stopEscape(); stopEscape=nil end; cleanup(); onFinish()
			end
			local function view(pos,target) return CFrame.lookAt(origin+pos,origin+target) end
			local radioWide=view(Vector3.new(7,5.8,0),Vector3.new(16,4.3,-6))
			local radioClose=view(Vector3.new(9.5,4.9,-3),Vector3.new(14,4.45,-6))
			local shots={
				{view(Vector3.new(-4,8,31),Vector3.new(0,5,-10)),view(Vector3.new(-7,7,16),Vector3.new(1,5,-10)),64},
				{view(Vector3.new(-20,6,-1),Vector3.new(-31,3.8,-10.5)),view(Vector3.new(-27,5.2,-5.7),Vector3.new(-31,3.8,-10.5)),52},
				{radioWide,radioClose,48},
				{view(Vector3.new(-21,5.7,-23),Vector3.new(-31,3.4,-23)),view(Vector3.new(-22,5.5,-23),Vector3.new(-31,3.4,-23)),56},
				{view(Vector3.new(7,5.5,8),Vector3.new(22,4.3,-3)),view(Vector3.new(9,5.3,6),Vector3.new(23,4.2,-5)),58},
				{view(Vector3.new(-26,5,-5),Vector3.new(-31,3.8,-10.5)),view(Vector3.new(-27,5.2,-5.7),Vector3.new(-31,3.8,-10.5)),52},
				{radioWide,radioClose,48},
			}
			connection=RunService.RenderStepped:Connect(function(dt)
				elapsed+=dt
				Timeline.advance(timeline,dt)
				if timeline.done then
					connection:Disconnect(); resizeConnection:Disconnect(); hud:Destroy()
					stopEscape=Escape.start({prepared=preparedEscape,model=model,origin=origin,exterior=exterior,actors=actors,root=root,ui=ui,reducedMotion=reducedMotion,setJoint=setJoint,onFinish=finish})
					return
				end
				local shot=shots[timeline.shot]
				local t=math.clamp(timeline.elapsed/Timeline.duration(timeline),0,1)
				local from,to,fov=shot[1],shot[2],shot[3]

				local blend=t*t*(3-2*t)
				broadcast.update(timeline.shot,timeline.elapsed,reducedMotion())
				subtitle.Text=Timeline.dialogue[timeline.shot] or ""; subtitle.Visible=subtitle.Text~=""
				local camera=workspace.CurrentCamera
				if camera then

					camera.CameraType=Enum.CameraType.Scriptable; camera.FieldOfView=fov
					camera.CFrame=reducedMotion() and to or from:Lerp(to,blend)
				end
				for _,person in actors do
					local reacting=timeline.shot>=3
					local reaction=Motion.action(person,elapsed,person.role,reacting)
					if person.face then person.face(elapsed,not reacting and person.role=="eat",reacting) end
					local phase=elapsed*1.6+person.index
					local breath=math.sin(phase)*.025
					if person.role=="eat" or person.role=="reader" or person.role=="bar" then
						setJoint(person,"LeftHip",CFrame.Angles(math.pi/2,0,0)); setJoint(person,"RightHip",CFrame.Angles(math.pi/2,0,0))
						setJoint(person,"LeftKnee",CFrame.Angles(-math.pi/2,0,0)); setJoint(person,"RightKnee",CFrame.Angles(-math.pi/2,0,0))
						local bite=(1-reaction)*(math.sin(phase)+1)/2
						setJoint(person,"RightShoulder",CFrame.Angles(reacting and .45 or (person.r6 and (1.0+bite*.65) or (.5+bite*.55)),0,-.1)); setJoint(person,"RightElbow",CFrame.Angles(.4+bite*1.2,0,0))
						setJoint(person,"Neck",CFrame.Angles(-.02*reaction-bite*.15,reaction*(person.index==3 and -.85 or .85)+(1-reaction)*math.sin(phase*.3)*.12,0))
						person.rig:PivotTo(person.base*CFrame.new(0,breath,0)*(person.role=="bar" and CFrame.Angles(0,reaction*1.4,0) or CFrame.new()))
						if person.props.pageHinge then
							local turn=reacting and 0 or math.max(0,math.sin(elapsed*.8))*math.pi*.8
							person.props.pageHinge.C0=CFrame.new(0,person.props.grip+.25,-.53)*CFrame.Angles(0,turn,0)*CFrame.new(.4,0,0)
						end
					elseif person.role=="waitress" then
						person.rig:PivotTo(person.base*CFrame.new(0,breath,0))
						setJoint(person,"RightShoulder",CFrame.Angles(1.1,0,-.22)); setJoint(person,"LeftShoulder",CFrame.Angles(.2,0,.08)); setJoint(person,"RightElbow",CFrame.Angles(.32,0,0)); setJoint(person,"RightWrist",CFrame.Angles(.12,0,0))
						setJoint(person,"Neck",CFrame.Angles(.12-.10*reaction,-.65*reaction,0))
						coffeeStream.Transparency=reacting and 1 or .18
						if person.props.spout then
							local start=person.props.spout.CFrame.Position; local target=origin+Vector3.new(17.6,3.98,5.4)
							coffeeStream.Size=Vector3.new(.035,.035,math.max(.05,(target-start).Magnitude)); coffeeStream.CFrame=CFrame.lookAt((start+target)/2,target)
						end
					else
						person.rig:PivotTo(person.base*CFrame.new(math.sin(elapsed*.5)*.4,breath,0))
						setJoint(person,"RightShoulder",CFrame.Angles(.8+math.sin(phase*2-.3)*.16,math.sin(phase*2)*.25,-.06)); setJoint(person,"RightElbow",CFrame.Angles(.7+math.sin(phase*2)*.34,0,0))
						setJoint(person,"LeftShoulder",CFrame.Angles(.85+math.sin(phase*2)*.22,0,.06)); setJoint(person,"Neck",CFrame.Angles(-.18,math.sin(phase)*.1,0))
						if person.props.pan then
							local toss=math.max(0,math.sin(elapsed*2.4))
							person.props.patty.CFrame=person.props.pan.CFrame*CFrame.new(.16+toss*.6,0,0)*CFrame.Angles(0,0,toss*math.pi)
						end
					end
					Motion.flush(person)
				end
			end)
			return finish
		end,
		destroy=cleanup,
	}
end
return Diner
