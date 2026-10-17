local Motion=require(script.Parent.PageMotion)
local Flow={}
function Flow.start(root,ui,remote,onComplete)
	local page=ui.make("CanvasGroup",{Size=UDim2.fromOffset(600,400),Position=UDim2.fromScale(.5,.5),AnchorPoint=Vector2.new(.5,.5),BackgroundTransparency=1},root)
	local scale=ui.make("UIScale",{},page)
	local function resize() scale.Scale=math.min(root.AbsoluteSize.X/660,root.AbsoluteSize.Y/460,1) end
	local connection=root:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize); resize()
	local draft={name="",gender="Boy",personality="Friendly"}
	local step,busy=1,false
	local draw
	local function go(nextStep)
		if busy then return end
		busy=true
		local direction=nextStep>step and 1 or -1
		Motion.swap(page,function() step=nextStep; draw() end,direction,function() busy=false end)
	end
	local function finish()
		if busy then return end
		busy=true
		local ok,result=pcall(function() return remote:InvokeServer("create",draft) end)
		busy=false
		if not page.Parent then return end
		if not ok or not result.ok then ui.notify(ok and result.message or "Could not create your character. Please try again."); return end
		connection:Disconnect(); page:Destroy(); onComplete(result.profile)
		if result.notice then ui.notify(result.notice) end
	end
	draw=function()
		for _,child in page:GetChildren() do if child~=scale then child:Destroy() end end
		ui.text(page,"YOUR STORY STARTS HERE",UDim2.fromOffset(20,15),UDim2.fromOffset(560,28),16)
		ui.text(page,({"Choose your name","Boy or girl?","Choose a personality"})[step],UDim2.fromOffset(20,65),UDim2.fromOffset(560,55),30)
		if step==1 then
			local entry=ui.make("TextBox",{Position=UDim2.fromOffset(20,145),Size=UDim2.fromOffset(560,55),Text=draft.name,PlaceholderText="Your character's name",ClearTextOnFocus=false,BackgroundTransparency=1,Font=Enum.Font.SpecialElite,TextColor3=Color3.fromRGB(232,211,175),PlaceholderColor3=Color3.fromRGB(137,129,113),TextSize=25,TextXAlignment=Enum.TextXAlignment.Left},page)
			ui.make("Frame",{Position=UDim2.fromOffset(20,203),Size=UDim2.fromOffset(560,1),BorderSizePixel=0,BackgroundColor3=Color3.fromRGB(125,110,83)},page)
			ui.navButton(page,"Next →",UDim2.fromOffset(405,330),UDim2.fromOffset(175,48),function()
				local clean=entry.Text:match("^%s*(.-)%s*$")
				local length=utf8.len(clean)
				if not length or clean:find("%c") then ui.notify("This name is unavailable."); return end
				if length<2 then ui.notify("This name is too short."); return end
				if length>24 then ui.notify("This name is too long."); return end
				draft.name=clean; go(2)
			end)
		elseif step==2 then
			for i,label in {"Boy","Girl"} do
				ui.button(page,(draft.gender==label and "● " or "○ ")..label,UDim2.fromOffset(20+(i-1)*280,155),UDim2.fromOffset(250,55),function() if not busy then draft.gender=label; draw() end end)
			end
			ui.navButton(page,"Next →",UDim2.fromOffset(405,330),UDim2.fromOffset(175,48),function() go(3) end)
		else
			for i,label in {"Friendly","Serious","Mysterious","Funny"} do
				local row=math.floor((i-1)/2); local col=(i-1)%2
				ui.button(page,(draft.personality==label and "● " or "○ ")..label,UDim2.fromOffset(20+col*280,140+row*65),UDim2.fromOffset(270,55),function() if not busy then draft.personality=label; draw() end end)
			end
			ui.navButton(page,"Continue →",UDim2.fromOffset(360,330),UDim2.fromOffset(220,48),finish)
		end
		if step>1 then ui.navButton(page,"← Back",UDim2.fromOffset(20,330),UDim2.fromOffset(180,48),function() go(step-1) end) end
	end
	draw()
	return function() connection:Disconnect(); page:Destroy() end
end
return Flow
