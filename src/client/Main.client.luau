local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")
local SocialService = game:GetService("SocialService")
local GuiService = game:GetService("GuiService")
local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("GameShared")
local Config = require(shared:WaitForChild("Config"))
local DesertScene = require(script.Parent.DesertScene)
local remote = shared:WaitForChild("MenuAction")
local warm = Color3.fromRGB(232,211,175)
local muted = Color3.fromRGB(164,155,136)
local accent = Color3.fromRGB(222,161,80)
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset, gui.DisplayOrder = "ShirtsAndSkins", false, true, 100
local root = Instance.new("Frame")
root.Name, root.Size, root.BackgroundColor3, root.BorderSizePixel = "Canvas", UDim2.fromScale(1,1), Color3.new(0,0,0), 0
root.Parent = gui
gui.Parent = player:WaitForChild("PlayerGui")
local function make(kind, properties, parent)
	local instance = Instance.new(kind)
	for key,value in properties do instance[key] = value end
	instance.Parent = parent
	return instance
end
local function tween(instance, duration, properties)
	local animation = TweenService:Create(instance,TweenInfo.new(duration,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),properties)
	animation:Play()
	return animation
end
local function text(parent, content, position, size, fontSize, color)
	return make("TextLabel", {Text=content,Position=position,Size=size,BackgroundTransparency=1,TextColor3=color or warm,TextSize=fontSize,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},parent)
end
local sound = make("Sound",{SoundId=Config.ClickSound,Volume=.35},gui)
local soundEnabled, lowEffects, reducedMotion = true, false, false
local profilePulse
local function click() if soundEnabled then sound:Play() end end
local function button(parent, content, position, size, callback)
	local b = make("TextButton",{Text=content,Position=position,Size=size,BackgroundTransparency=1,TextColor3=warm,TextSize=20,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,Selectable=true},parent)
	local function focus() tween(b,.15,{TextColor3=accent}) end
	local function blur() tween(b,.15,{TextColor3=warm}) end
	b.MouseEnter:Connect(focus); b.SelectionGained:Connect(focus)
	b.MouseLeave:Connect(blur); b.SelectionLost:Connect(blur)
	b.Activated:Connect(function() click(); callback(b) end)
	return b
end
local toast = text(root,"",UDim2.fromScale(.5,.87),UDim2.fromScale(.82,.09),16,warm)
toast.AnchorPoint, toast.TextXAlignment, toast.ZIndex = Vector2.new(.5,0), Enum.TextXAlignment.Center, 20
local messageVersion = 0
local function notify(message)
	messageVersion += 1
	local version = messageVersion
	toast.Text, toast.TextTransparency = message, 0
	task.delay(6,function() if messageVersion == version then tween(toast,.4,{TextTransparency=1}) end end)
end
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local previousCore = {}
for _,kind in {Enum.CoreGuiType.Backpack,Enum.CoreGuiType.PlayerList,Enum.CoreGuiType.Chat,Enum.CoreGuiType.Health} do
	pcall(function() previousCore[kind] = StarterGui:GetCoreGuiEnabled(kind); StarterGui:SetCoreGuiEnabled(kind,false) end)
end
ContextActionService:BindActionAtPriority("MenuBlocksMovement",function() return Enum.ContextActionResult.Sink end,false,3000,Enum.PlayerActions.CharacterForward,Enum.PlayerActions.CharacterBackward,Enum.PlayerActions.CharacterLeft,Enum.PlayerActions.CharacterRight,Enum.PlayerActions.CharacterJump)
local camera = workspace.CurrentCamera
while not camera do workspace:GetPropertyChangedSignal("CurrentCamera"):Wait(); camera = workspace.CurrentCamera end
local originalCamera = {kind=camera.CameraType, cframe=camera.CFrame, fov=camera.FieldOfView}
local scene, angle, state = nil, 0, "opening"
local party = {leader=player.UserId,capacity=1,members={{id=player.UserId,name=player.DisplayName}}}
local renderConnection = RunService.RenderStepped:Connect(function(dt)
	local current = workspace.CurrentCamera
	if not current then return end
	current.CameraType = Enum.CameraType.Scriptable
	if scene then
		if not reducedMotion then angle -= math.min(dt,.1) * (state == "cinematic" and .055 or .012) end
		local focus = scene.focus
		local position = focus + Vector3.new(math.cos(angle)*106,37,math.sin(angle)*106)
		current.CFrame = CFrame.lookAt(position,focus)
		current.FieldOfView = 48
	end
end)
local function frame(parent, position, size)
	return make("Frame",{Position=position,Size=size,BackgroundTransparency=1},parent)
end
-- Scale a fixed design canvas to the viewport, preserving touch targets where space permits.
local menu = make("CanvasGroup",{Size=UDim2.fromOffset(1000,600),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),BackgroundTransparency=1,Visible=false,GroupTransparency=1},root)
local scale = make("UIScale",{},menu)
local function resize()
	local size = root.AbsoluteSize
	scale.Scale = math.min(size.X/1080,size.Y/660,1.4)
end
root:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize); resize()
local header = text(menu,"MHIDE  /  AN ORIGINAL EXPERIENCE",UDim2.fromOffset(24,12),UDim2.fromOffset(660,24),12,muted)
header.Font = Enum.Font.GothamBold
local titleLabel = text(menu,Config.Title,UDim2.fromOffset(24,49),UDim2.fromOffset(730,65),52,warm)
titleLabel.Font = Enum.Font.Oswald
text(menu,"EVERY CHOICE LEAVES A MARK.",UDim2.fromOffset(27,119),UDim2.fromOffset(550,30),13,accent)
make("Frame",{Position=UDim2.fromOffset(26,168),Size=UDim2.fromOffset(46,2),BorderSizePixel=0,BackgroundColor3=accent},menu)
local panel = make("Frame",{Position=UDim2.fromOffset(420,184),Size=UDim2.fromOffset(550,340),BackgroundColor3=Color3.fromRGB(23,23,21),BackgroundTransparency=.13,BorderSizePixel=0,Visible=false,Active=true,ZIndex=4},menu)
make("UICorner",{CornerRadius=UDim.new(0,8)},panel)
local panelBody = frame(panel,UDim2.fromOffset(24,56),UDim2.fromOffset(502,265))
local panelTitle = text(panel,"",UDim2.fromOffset(24,12),UDim2.fromOffset(440,34),22)
local activePanel, refreshPanel = nil, nil
local function closePanel() panel.Visible=false; activePanel=nil; refreshPanel=nil end
button(panel,"×",UDim2.fromOffset(498,6),UDim2.fromOffset(44,44),closePanel)
local function openPanel(name)
	panelBody:ClearAllChildren()
	panel.Visible, panelTitle.Text, activePanel = true, name, name
end
local showPlay, showInvite
local firstMenuButton
showPlay = function()
	openPanel("YOUR CREW")
	refreshPanel = showPlay
	text(panelBody,"CHOOSE YOUR PARTY SIZE",UDim2.fromOffset(0,0),UDim2.fromOffset(490,24),12,muted)
	for index,item in {{1,"SOLO"},{2,"DUO"},{4,"SQUAD · 4"}} do
		local b = button(panelBody,(party.capacity==item[1] and "● " or "○ ")..item[2],UDim2.fromOffset((index-1)*165,30),UDim2.fromOffset(164,44),function() remote:FireServer("capacity",item[1]) end)
		b.TextSize=17
	end
	local names={}
	for _,member in party.members do table.insert(names,member.name..(member.id==party.leader and " · LEADER" or "")) end
	text(panelBody,table.concat(names,"\n"),UDim2.fromOffset(0,83),UDim2.fromOffset(490,95),17)
	local start = button(panelBody,"BEGIN STORY  →",UDim2.fromOffset(0,183),UDim2.fromOffset(285,44),function() remote:FireServer("start") end)
	start.TextColor3=accent
	button(panelBody,"Leave crew",UDim2.fromOffset(320,183),UDim2.fromOffset(175,44),function() remote:FireServer("leave") end).TextSize=15
	text(panelBody,"Up to "..party.capacity.." players • First mission in development",UDim2.fromOffset(0,235),UDim2.fromOffset(495,25),13,muted)
end
showInvite = function()
	openPanel("INVITE YOUR CREW")
	refreshPanel = showInvite
	local list = make("ScrollingFrame",{Size=UDim2.new(1,0,1,-55),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},panelBody)
	make("UIListLayout",{Padding=UDim.new(0,4)},list)
	local count = 0
	for _,other in Players:GetPlayers() do
		if other ~= player then
			count += 1
			button(list,"+  "..other.DisplayName,UDim2.new(),UDim2.new(1,-8,0,44),function() remote:FireServer("invite",other.UserId) end).TextSize=17
		end
	end
	if count==0 then text(list,"No other players in this server yet.\nInvite a friend to join your game.",UDim2.new(),UDim2.new(1,-8,0,90),17,muted) end
	button(panelBody,"Invite Roblox friends  ↗",UDim2.new(0,0,1,-44),UDim2.new(1,0,0,44),function()
		local ok,allowed = pcall(function() return SocialService:CanSendGameInviteAsync(player) end)
		if not ok or not allowed then notify("Friend invitations are available in supported published-game sessions."); return end
		local prompted = pcall(function() SocialService:PromptGameInvite(player) end)
		if not prompted then notify("Could not open invitations. Try again in the published game.") end
	end).TextSize=17
end
local function showShop()
	openPanel("THE SUPPLY ROOM"); refreshPanel=nil
	text(panelBody,"GOOD GEAR HAS A STORY.",UDim2.new(),UDim2.fromOffset(490,40),20,accent)
	text(panelBody,"Mission rewards and the shop will appear here as they are developed.\n\nThere are no items or purchases available in this first build.",UDim2.fromOffset(0,50),UDim2.fromOffset(490,160),17,muted)
end
local function showSettings()
	openPanel("SETTINGS"); refreshPanel=showSettings
	button(panelBody,"Menu sound: "..(soundEnabled and "ON" or "OFF"),UDim2.fromOffset(0,0),UDim2.fromOffset(490,50),function() soundEnabled=not soundEnabled; showSettings() end)
	button(panelBody,"Reduced motion: "..(reducedMotion and "ON" or "OFF"),UDim2.fromOffset(0,60),UDim2.fromOffset(490,50),function() reducedMotion=not reducedMotion; if profilePulse then if reducedMotion then profilePulse:Pause() else profilePulse:Play() end end; showSettings() end)
	button(panelBody,"Low effects: "..(lowEffects and "ON" or "OFF"),UDim2.fromOffset(0,120),UDim2.fromOffset(490,50),function() lowEffects=not lowEffects; if scene then scene.setLowEffects(lowEffects) end; showSettings() end)
	text(panelBody,"Settings apply to this session. Low effects disables menu smoke and color grading.",UDim2.fromOffset(0,195),UDim2.fromOffset(490,60),14,muted)
end
local opening = frame(root,UDim2.fromScale(.5,.5),UDim2.fromOffset(600,100))
opening.AnchorPoint=Vector2.new(.5,.5)
local openingScale = make("UIScale",{},opening)
local function resizeOpening() openingScale.Scale=math.min(root.AbsoluteSize.X/660,1) end
root:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeOpening); resizeOpening()
local storyButton, onlineButton
local function returnToOpening()
	closePanel(); menu.Visible=false; opening.Visible=true; state="opening"
	root.BackgroundTransparency=0
	GuiService.SelectedObject=storyButton
end
local function showOptions()
	openPanel("OPTIONS"); refreshPanel=nil
	text(panelBody,"Select with mouse, touch, or gamepad A. Use the directional pad to navigate.\n\nInvite players in this server, then choose Solo, Duo, or a squad of up to four under Play.",UDim2.new(),UDim2.fromOffset(490,175),17,muted)
	button(panelBody,"←  Return to mode selection",UDim2.fromOffset(0,200),UDim2.fromOffset(490,44),returnToOpening).TextSize=17
end
for index,item in {{"Play",showPlay},{"Invite",showInvite},{"Shop",showShop},{"Settings",showSettings},{"Options",showOptions}} do
	local b = button(menu,item[1],UDim2.fromOffset(83,190+(index-1)*56),UDim2.fromOffset(280,48),item[2])
	b.TextSize=26
	if index == 1 then firstMenuButton=b end
	text(menu,string.format("0%d",index),UDim2.fromOffset(28,190+(index-1)*56),UDim2.fromOffset(40,48),12,muted)
end
local profile = make("ImageButton",{Position=UDim2.fromOffset(302,202),Size=UDim2.fromOffset(64,64),BackgroundColor3=Color3.fromRGB(43,40,32),BackgroundTransparency=.2,Image="",AutoButtonColor=false},menu)
make("UICorner",{CornerRadius=UDim.new(1,0)},profile)
local ring = make("UIStroke",{Color=accent,Thickness=1.4,Transparency=.2},profile)
local pulse = TweenService:Create(ring,TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Transparency=.75})
pulse:Play()
profilePulse=pulse
profile.Activated:Connect(function()
	click(); openPanel("YOUR IDENTITY"); refreshPanel=nil
	make("ImageLabel",{Image=profile.Image,BackgroundTransparency=1,Size=UDim2.fromOffset(90,90)},panelBody)
	text(panelBody,player.DisplayName,UDim2.fromOffset(110,10),UDim2.fromOffset(380,40),24)
	text(panelBody,"Your Roblox avatar is your starting look.\n\nUnlockable outfits and customization will be added with missions and the shop.",UDim2.fromOffset(0,110),UDim2.fromOffset(490,140),17,muted)
end)
task.spawn(function()
	local ok,url = pcall(function() return Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size180x180) end)
	if ok and profile.Parent then profile.Image=url end
end)
local credit = text(menu,"Developed by MHIDE",UDim2.fromOffset(28,552),UDim2.fromOffset(350,25),13,muted)
local inspiration = text(menu,"Be Inspired",UDim2.fromOffset(730,552),UDim2.fromOffset(240,25),14,warm)
inspiration.TextXAlignment=Enum.TextXAlignment.Right
local footer = text(menu,"STORY MODE  /  THE DESERT",UDim2.fromOffset(28,576),UDim2.fromOffset(430,20),10,muted)
resize = function()
	local size = root.AbsoluteSize
	local narrow = size.X < size.Y
	menu.Size = UDim2.fromOffset(narrow and 600 or 1000,narrow and 710 or 600)
	scale.Scale = math.min(size.X/(narrow and 640 or 1080),size.Y/(narrow and 750 or 660),1.4)
	panel.Position = UDim2.fromOffset(narrow and 25 or 420,184)
	titleLabel.Size = UDim2.fromOffset(narrow and 550 or 730,65)
	titleLabel.TextSize = narrow and 44 or 52
	credit.Position = UDim2.fromOffset(28,narrow and 640 or 552)
	inspiration.Position = UDim2.fromOffset(narrow and 330 or 730,narrow and 640 or 552)
	footer.Position = UDim2.fromOffset(28,narrow and 670 or 576)
end
-- The original signal calls its original function; connect the adaptive layout too.
root:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
resize()
-- A restrained left-side shade keeps text readable against the desert.
local shade = make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(),BorderSizePixel=0,Visible=false,ZIndex=0},root)
make("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.2),NumberSequenceKeypoint.new(.48,.6),NumberSequenceKeypoint.new(1,1)})},shade)
local bars = {}
for _,y in {0,1} do
	local bar = make("Frame",{Size=UDim2.new(1,0,0,.0),Position=UDim2.fromScale(0,y),AnchorPoint=Vector2.new(0,y),BackgroundColor3=Color3.new(),BorderSizePixel=0,ZIndex=2},root)
	table.insert(bars,bar)
end
local function startStory()
	if state~="opening" then return end
	state="cinematic"; opening.Visible=false
	if not scene then scene=DesertScene.create() end
	angle=math.rad(-38); scene.setLowEffects(lowEffects)
	root.BackgroundTransparency=1
	shade.Visible=true
	for _,bar in bars do tween(bar,.6,{Size=UDim2.new(1,0,.06,0)}) end
	task.delay(Config.OrbitIntroSeconds,function()
		if state~="cinematic" or not gui.Parent then return end
		state="menu"; menu.Visible=true; menu.GroupTransparency=1
		if GuiService:IsTenFootInterface() or game:GetService("UserInputService").GamepadEnabled then GuiService.SelectedObject=firstMenuButton end
		for _,bar in bars do tween(bar,.6,{Size=UDim2.new(1,0,.025,0)}) end
		tween(menu,.8,{GroupTransparency=0})
	end)
end
storyButton=button(opening,"STORY MODE",UDim2.fromOffset(20,30),UDim2.fromOffset(260,50),startStory)
onlineButton=button(opening,"ONLINE",UDim2.fromOffset(320,30),UDim2.fromOffset(260,50),function() remote:FireServer("online") end)
storyButton.TextXAlignment,onlineButton.TextXAlignment=Enum.TextXAlignment.Center,Enum.TextXAlignment.Center
storyButton.TextTransparency,onlineButton.TextTransparency=1,1
storyButton.Visible,onlineButton.Visible=false,false
local invitationFrame = make("Frame",{Size=UDim2.fromOffset(340,135),AnchorPoint=Vector2.new(.5,0),Position=UDim2.fromScale(.5,.07),BackgroundColor3=Color3.fromRGB(30,29,26),BorderSizePixel=0,Visible=false,ZIndex=30},root)
make("UICorner",{CornerRadius=UDim.new(0,8)},invitationFrame)
local inviteText=text(invitationFrame,"",UDim2.fromOffset(14,10),UDim2.fromOffset(312,60),16)
button(invitationFrame,"Accept",UDim2.fromOffset(20,80),UDim2.fromOffset(140,44),function() invitationFrame.Visible=false; remote:FireServer("accept") end)
button(invitationFrame,"Decline",UDim2.fromOffset(180,80),UDim2.fromOffset(140,44),function() invitationFrame.Visible=false; remote:FireServer("decline") end)
local inviteVersion=0
remote.OnClientEvent:Connect(function(action,value)
	if action=="message" then notify(value)
	elseif action=="party" then party=value; if refreshPanel and panel.Visible then refreshPanel() end
	elseif action=="invitation" then
		inviteVersion+=1
		local version=inviteVersion
		inviteText.Text=value.name.." invited you to their crew."
		invitationFrame.Visible=true
		task.delay(Config.InviteLifetime,function() if inviteVersion==version then invitationFrame.Visible=false end end)
	end
end)
Players.PlayerAdded:Connect(function() if activePanel=="INVITE YOUR CREW" then showInvite() end end)
Players.PlayerRemoving:Connect(function() task.defer(function() if activePanel=="INVITE YOUR CREW" then showInvite() end end) end)
remote:FireServer("sync")
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(Config.IntroDelay)
for _,b in {storyButton,onlineButton} do
	b.Visible=true
	local target=b.Position
	b.Position=target+UDim2.fromOffset(0,8)
	click(); tween(b,.35,{TextTransparency=0,Position=target})
	task.wait(Config.ChoiceStagger)
end
if game:GetService("UserInputService").GamepadEnabled and state == "opening" then GuiService.SelectedObject=storyButton end
script.Destroying:Connect(function()
	renderConnection:Disconnect(); pulse:Cancel()
	ContextActionService:UnbindAction("MenuBlocksMovement")
	if scene then scene.destroy() end
	local current=workspace.CurrentCamera
	if current then current.CameraType=originalCamera.kind; current.CFrame=originalCamera.cframe; current.FieldOfView=originalCamera.fov end
	for kind,enabled in previousCore do pcall(function() StarterGui:SetCoreGuiEnabled(kind,enabled) end) end
	gui:Destroy()
end)
