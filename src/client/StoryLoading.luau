local RunService=game:GetService("RunService")
local Landscape=require(script.Parent.LoadingLandscape)
local Loading={}
function Loading.run(root,ui,jobs,reducedMotion)
	local screen=ui.make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(126,66,56),BorderSizePixel=0,ZIndex=40},root)
	ui.make("UIGradient",{Rotation=90,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(47,38,61)),ColorSequenceKeypoint.new(.55,Color3.fromRGB(201,114,69)),ColorSequenceKeypoint.new(1,Color3.fromRGB(232,177,104))})},screen)
	local sun=ui.make("Frame",{Position=UDim2.fromScale(.72,.48),Size=UDim2.fromOffset(64,64),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=Color3.fromRGB(247,197,120),BorderSizePixel=0},screen)
	ui.make("UICorner",{CornerRadius=UDim.new(1,0)},sun)
	local updateLandscape=Landscape.create(screen,ui)
	local shade=ui.make("Frame",{Name="Loading text shade",Position=UDim2.fromScale(0,.7),Size=UDim2.fromScale(1,.3),BackgroundColor3=Color3.fromRGB(20,17,15),BorderSizePixel=0,ZIndex=42},screen)
	ui.make("UIGradient",{Rotation=90,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,.15)})},shade)
	local text=ui.text(screen,"0%",UDim2.fromScale(.5,.83),UDim2.fromOffset(180,45),25)
	text.AnchorPoint=Vector2.new(.5,.5); text.TextXAlignment=Enum.TextXAlignment.Center; text.ZIndex=43
	updateLandscape(0,reducedMotion())
	local elapsed=0
	local connection=RunService.RenderStepped:Connect(function(dt)
		elapsed+=dt
		updateLandscape(elapsed,reducedMotion())
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
