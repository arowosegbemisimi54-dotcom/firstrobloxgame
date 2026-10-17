local TweenService=game:GetService("TweenService")
local Motion={}
local origins=setmetatable({},{__mode="k"})
local running=setmetatable({},{__mode="k"})
function Motion.reset(page)
	if running[page] then running[page]:Cancel(); running[page]=nil end
	origins[page]=page.Position
end
function Motion.enter(page,direction,reduced)
	local origin=origins[page] or page.Position
	origins[page]=origin
	if running[page] then running[page]:Cancel() end
	page.Visible=true
	page.Position=origin
	if reduced then return end
	page.Position=origin+UDim2.fromOffset((direction or 1)*36,0)
	local animation=TweenService:Create(page,TweenInfo.new(.24,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=origin})
	running[page]=animation
	animation:Play()
end
function Motion.swap(page,redraw,direction,finished)
	local origin=origins[page] or page.Position
	origins[page]=origin
	if running[page] then running[page]:Cancel() end
	local out=TweenService:Create(page,TweenInfo.new(.12,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=origin+UDim2.fromOffset(-direction*28,0),GroupTransparency=1})
	running[page]=out
	out:Play()
	out.Completed:Once(function(state)
		if state~=Enum.PlaybackState.Completed or not page.Parent then if finished then finished() end; return end
		redraw()
		page.Position=origin+UDim2.fromOffset(direction*36,0)
		local incoming=TweenService:Create(page,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=origin,GroupTransparency=0})
		running[page]=incoming; incoming:Play()
		incoming.Completed:Once(function() if finished then finished() end end)
	end)
end
return Motion
