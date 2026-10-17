local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local shared=game:GetService("ReplicatedStorage"):WaitForChild("GameShared")
local Catalog=require(shared.CharacterCatalog)
local Outfit=require(shared.WesternOutfit)
local Motion=require(script.Parent.PageMotion)
local Wardrobe={}

function Wardrobe.mount(parent,ui,remote,onBack,onProfile,isReducedMotion)
	local page=ui.make("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,ZIndex=5},parent)
	ui.navButton(page,"← Back",UDim2.fromOffset(24,12),UDim2.fromOffset(170,48),function() page.Visible=false; onBack() end)
	local heading=ui.text(page,"YOUR IDENTITY",UDim2.fromOffset(24,74),UDim2.fromOffset(580,42),30)
	local viewport=ui.make("ViewportFrame",{Position=UDim2.fromOffset(20,132),Size=UDim2.fromOffset(430,395),BackgroundTransparency=1,Ambient=Color3.fromRGB(172,158,139),LightColor=Color3.fromRGB(255,229,193),LightDirection=Vector3.new(-1,-1,-2),Active=true},page)
	local world=ui.make("WorldModel",{},viewport)
	local camera=ui.make("Camera",{FieldOfView=35,CFrame=CFrame.lookAt(Vector3.new(0,1.3,-13),Vector3.new(0,0,0))},viewport)
	viewport.CurrentCamera=camera
	local hint=ui.text(page,"Drag to rotate · 360°",UDim2.fromOffset(34,534),UDim2.fromOffset(400,30),15)
	local left=ui.button(page,"↶",UDim2.fromOffset(30,480),UDim2.fromOffset(55,48),function() end)
	local right=ui.button(page,"↷",UDim2.fromOffset(380,480),UDim2.fromOffset(55,48),function() end)
	local tabs=ui.make("ScrollingFrame",{Position=UDim2.fromOffset(485,143),Size=UDim2.fromOffset(490,55),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,AutomaticCanvasSize=Enum.AutomaticSize.X,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.X},page)
	ui.make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,8)},tabs)
	local cards=ui.make("ScrollingFrame",{Position=UDim2.fromOffset(485,218),Size=UDim2.fromOffset(490,260),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},page)
	local status=ui.text(page,"",UDim2.fromOffset(485,492),UDim2.fromOffset(490,65),16)
	local profile,template,preview=nil,nil,nil
	local selectedTab="Top"
	local angle=0
	local time=0
	local idleJoints={}
	local pending=false
	local lastSelection=-math.huge
	local loading=false
	local destroyed=false
	local dragInput,lastX=nil,nil
	local renderCards,refreshPreview
	local connections={}
	local function connect(signal,callback) local c=signal:Connect(callback); table.insert(connections,c); return c end
	local function freeze(model)
		for _,desc in model:GetDescendants() do
			if desc:IsA("BasePart") then desc.CanCollide=false
			elseif desc:IsA("Script") or desc:IsA("LocalScript") then desc:Destroy() end
		end
		local root=model:FindFirstChild("HumanoidRootPart")
		if root then root.Anchored=true; model.PrimaryPart=root end
		local humanoid=model:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None end
	end
	local function outfitCopy(slot,id)
		local copy={gender=profile.gender,outfit=table.clone(profile.outfit)}
		if slot then copy.outfit[slot]=id end
		return copy
	end
	local function puff()
		-- ViewportFrames do not render ParticleEmitters. Short-lived translucent
		-- spheres give a true 3D puff inside the same preview world.
		for i=1,7 do
			local cloud=ui.make("Part",{Shape=Enum.PartType.Ball,Size=Vector3.new(.6,.6,.6),CFrame=CFrame.new(math.cos(i)*.9,-.1,math.sin(i)*.9),Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,CastShadow=false,Color=Color3.fromRGB(188,174,146),Transparency=.35},world)
			local animation=TweenService:Create(cloud,TweenInfo.new(.32),{Size=Vector3.new(1.6,1.6,1.6),Transparency=1,Position=cloud.Position+Vector3.new(math.cos(i)*.5,.6,math.sin(i)*.5)})
			animation:Play(); task.delay(.35,function() cloud:Destroy() end)
		end
	end
	refreshPreview=function()
		if preview then preview:Destroy() end
		if not template or not profile then return end
		preview=template:Clone(); freeze(preview); preview.Parent=world
		Outfit.apply(preview,profile)
		idleJoints={}
		for _,joint in preview:GetDescendants() do
			if joint:IsA("Motor6D") and (joint.Name=="LeftShoulder" or joint.Name=="RightShoulder" or joint.Name=="Left Shoulder" or joint.Name=="Right Shoulder") then table.insert(idleJoints,{joint=joint,base=joint.C0}) end
		end
		preview:PivotTo(CFrame.Angles(0,angle,0))
	end
	local function equip(slot,id)
		if pending or os.clock()-lastSelection<Catalog.SelectionCooldown then return end
		local valid,message=Catalog.canEquip(profile.outfit,slot,id)
		if not valid then status.Text=message; return end
		pending=true; lastSelection=os.clock()
		local ok,result=pcall(function() return remote:InvokeServer("equip",{slot=slot,id=id}) end)
		pending=false
		if destroyed then return end
		if not ok or not result.ok then status.Text=ok and result.message or "Could not change clothing. Please try again."; return end
		profile=result.profile; onProfile(profile)
		refreshPreview(); renderCards(); puff()
	end
	local function itemModel(slot,item)
		if slot=="Critter" and item.id=="dog" then return Outfit.dog() end
		local model=template:Clone(); freeze(model)
		Outfit.apply(model,outfitCopy(slot,item.id))
		model:PivotTo(CFrame.new())
		return model
	end
	renderCards=function()
		cards:ClearAllChildren()
		ui.make("UIGridLayout",{CellSize=UDim2.fromOffset(136,154),CellPadding=UDim2.fromOffset(14,14),SortOrder=Enum.SortOrder.LayoutOrder},cards)
		if not template then return end
		status.Text=selectedTab=="Critter" and "Dogs unlock as you advance through Story Mode." or "Select an item to wear it."
		local visibleItems={}
		for _,item in Catalog.Items[selectedTab] do
			if selectedTab~="Costume" or not item.locked then table.insert(visibleItems,item) end
		end
		for index,item in visibleItems do
			local slot=selectedTab
			local card=ui.make("TextButton",{Text="",Size=UDim2.fromOffset(136,154),BackgroundColor3=Color3.fromRGB(38,34,27),BackgroundTransparency=.2,BorderSizePixel=0,LayoutOrder=index,Selectable=true},cards)
			ui.make("UICorner",{CornerRadius=UDim.new(0,4)},card)
			ui.make("UIStroke",{Color=Color3.fromRGB(222,161,80),Thickness=profile.outfit[slot]==item.id and 2 or 1,Transparency=profile.outfit[slot]==item.id and 0 or .75},card)
			local picture=ui.make("ViewportFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Ambient=Color3.fromRGB(200,190,173),LightColor=Color3.fromRGB(255,231,195)},card)
			local itemWorld=ui.make("WorldModel",{},picture)
			local model=itemModel(slot,item); model.Parent=itemWorld
			local target,eye=Vector3.new(),Vector3.new(0,.7,-12)
			if slot=="Hat" then target=Vector3.new(0,2,0); eye=Vector3.new(0,2,-6)
			elseif slot=="Top" then target=Vector3.new(0,.6,0); eye=Vector3.new(0,.6,-7)
			elseif slot=="Bottom" then target=Vector3.new(0,-1.4,0); eye=Vector3.new(0,-1.4,-7)
			elseif slot=="Shoes" then target=Vector3.new(0,-2.7,0); eye=Vector3.new(0,-1.7,-5)
			elseif slot=="Critter" and item.id=="dog" then target=Vector3.new(0,1,0); eye=Vector3.new(3,2,-6) end
			picture.CurrentCamera=ui.make("Camera",{FieldOfView=35,CFrame=CFrame.lookAt(eye,target)},picture)
			if item.id=="none" then
				ui.text(card,"∅",UDim2.fromOffset(6,4),UDim2.fromOffset(36,36),25)
			end
			if item.locked then ui.text(card,"LOCKED",UDim2.new(0,8,1,-28),UDim2.new(1,-16,0,24),13) end
			card.MouseEnter:Connect(function() status.Text=item.name end)
			card.SelectionGained:Connect(function() status.Text=item.name end)
			card.Activated:Connect(function() ui.click(); equip(slot,item.id) end)
		end
	end
	for _,tab in Catalog.Tabs do
		local b=ui.navButton(tabs,tab,UDim2.new(),UDim2.fromOffset(tab=="Costume" and 110 or 90,48),function()
			selectedTab=tab; renderCards(); Motion.enter(cards,1,isReducedMotion())
			for _,child in tabs:GetChildren() do if child:IsA("TextButton") then child.TextColor3=child.Text==tab and Color3.fromRGB(222,161,80) or Color3.fromRGB(232,211,175) end end
		end)
		b.TextSize=17
	end
	connect(viewport.InputBegan,function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragInput=input; lastX=input.Position.X end
	end)
	connect(UserInputService.InputChanged,function(input)
		if not page.Visible or not dragInput then return end
		if input==dragInput or (dragInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement) then
			angle+=(input.Position.X-lastX)*.012; lastX=input.Position.X
		end
	end)
	connect(UserInputService.InputEnded,function(input) if input==dragInput then dragInput=nil end end)
	left.Activated:Connect(function() angle-=math.pi/4 end)
	right.Activated:Connect(function() angle+=math.pi/4 end)
	connect(RunService.RenderStepped,function(dt)
		if not page.Visible or not preview then return end
		time+=dt
		local bob=isReducedMotion() and 0 or math.sin(time*1.7)*.035
		preview:PivotTo(CFrame.new(0,bob,0)*CFrame.Angles(0,angle,0))
		for _,data in idleJoints do
			data.joint.C0=data.base*CFrame.Angles(0,0,isReducedMotion() and 0 or math.sin(time*1.7)*.025)
		end
	end)
	local function resize()
		local narrow=parent.AbsoluteSize.X<parent.AbsoluteSize.Y
		viewport.Position=UDim2.fromOffset(20,132)
		viewport.Size=UDim2.fromOffset(narrow and 245 or 430,narrow and 420 or 395)
		tabs.Position=UDim2.fromOffset(narrow and 280 or 485,143)
		tabs.Size=UDim2.fromOffset(narrow and 295 or 490,55)
		cards.Position=UDim2.fromOffset(narrow and 280 or 485,218)
		cards.Size=UDim2.fromOffset(narrow and 295 or 490,narrow and 360 or 260)
		status.Position=UDim2.fromOffset(narrow and 280 or 485,narrow and 590 or 492)
		status.Size=UDim2.fromOffset(narrow and 295 or 490,75)
		hint.Position=UDim2.fromOffset(24,narrow and 590 or 534)
		hint.Size=UDim2.fromOffset(narrow and 240 or 400,45)
		left.Position=UDim2.fromOffset(25,narrow and 535 or 480)
		right.Position=UDim2.fromOffset(narrow and 205 or 380,narrow and 535 or 480)
		Motion.reset(cards)
	end
	connect(parent:GetPropertyChangedSignal("AbsoluteSize"),resize); resize()
	return {
		open=function(value)
			profile=value; Motion.enter(page,1,isReducedMotion())
			heading.Text=value.name
			if template then refreshPreview(); renderCards(); return end
			if loading then return end
			loading=true; status.Text="Loading your character…"
			task.spawn(function()
				local character=Players.LocalPlayer.Character
				local ok,rig=pcall(function()
					if character and character:FindFirstChildOfClass("Humanoid") then
						local archivable=character.Archivable; character.Archivable=true
						local clone=character:Clone(); character.Archivable=archivable
						return clone
					end
					return Players:CreateHumanoidModelFromDescriptionAsync(Instance.new("HumanoidDescription"),Enum.HumanoidRigType.R6)
				end)
				loading=false
				if destroyed then if ok and rig then rig:Destroy() end; return end
				if not ok or not rig then status.Text="Preview could not load. Go Back and try again."; return end
				template=rig; freeze(template); refreshPreview(); renderCards()
			end)
		end,
		close=function() page.Visible=false end,
		destroy=function()
			destroyed=true
			for _,c in connections do c:Disconnect() end
			if template then template:Destroy() end
			page:Destroy()
		end,
	}
end
return Wardrobe
