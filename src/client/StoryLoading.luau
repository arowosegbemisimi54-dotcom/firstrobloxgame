local RunService=game:GetService("RunService")
local Loading={}
function Loading.run(root,ui,jobs,reducedMotion)
	local screen=ui.make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(126,66,56),BorderSizePixel=0,ZIndex=40},root)
	ui.make("UIGradient",{Rotation=90,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(47,38,61)),ColorSequenceKeypoint.new(.55,Color3.fromRGB(201,114,69)),ColorSequenceKeypoint.new(1,Color3.fromRGB(232,177,104))})},screen)
	local sun=ui.make("Frame",{Position=UDim2.fromScale(.72,.48),Size=UDim2.fromOffset(140,140),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=Color3.fromRGB(247,197,120),BorderSizePixel=0},screen)
	ui.make("UICorner",{CornerRadius=UDim.new(1,0)},sun)
	for i=1,9 do
		local dune=ui.make("Frame",{Size=UDim2.fromScale(.28,.22),Position=UDim2.fromScale((i-2)*.15,.66+math.sin(i)*.025),Rotation=math.sin(i)*8,BackgroundColor3=Color3.fromRGB(77+i*2,54+i,42),BorderSizePixel=0},screen)
		ui.make("UICorner",{CornerRadius=UDim.new(.5,0)},dune)
	end
	ui.make("Frame",{Position=UDim2.fromScale(0,.76),Size=UDim2.fromScale(1,.24),BackgroundColor3=Color3.fromRGB(61,44,35),BorderSizePixel=0},screen)
	local text=ui.text(screen,"0%",UDim2.fromScale(.5,.83),UDim2.fromOffset(180,45),25)
	text.AnchorPoint=Vector2.new(.5,.5); text.TextXAlignment=Enum.TextXAlignment.Center
	local wheel=ui.make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.73),Size=UDim2.fromOffset(46,46),BackgroundTransparency=1},screen)
	for i=1,7 do
		local twig=ui.make("Frame",{Position=UDim2.fromScale(.5,.5),AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(42-i,17+i),Rotation=i*29,BackgroundTransparency=1},wheel)
		ui.make("UICorner",{CornerRadius=UDim.new(1,0)},twig)
		ui.make("UIStroke",{Color=Color3.fromRGB(192,152,92),Thickness=1,Transparency=.12},twig)
	end
	local elapsed=0
	local connection=RunService.RenderStepped:Connect(function(dt)
		elapsed+=dt
		if not reducedMotion() then wheel.Rotation=elapsed*65; wheel.Position=UDim2.fromScale(.5+math.sin(elapsed*.7)*.025,.73) end
	end)
	local result
	local ok,err=xpcall(function()
		RunService.RenderStepped:Wait() -- Make 0% visible before preparing anything.
		for index,job in jobs do
			result=job(result)
			text.Text=string.format("%d%%",math.floor(index/#jobs*100))
			RunService.RenderStepped:Wait()
		end
		task.wait(.18) -- Present completed progress before revealing the scene.
	end,debug.traceback)
	connection:Disconnect(); screen:Destroy()
	if not ok then return false,err end
	return true,result
end
return Loading
