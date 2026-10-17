-- Service doubles exercise allocation, cadence, visibility, and cleanup.
-- They do not simulate rendering or Roblox physics.
local Vector={}
local VectorMeta={}
function Vector.new(x,y,z) return setmetatable({X=x,Y=y,Z=z},VectorMeta) end
function VectorMeta.__add(a,b) return Vector.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
function VectorMeta.__sub(a,b) return Vector.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
function VectorMeta.__unm(a) return Vector.new(-a.X,-a.Y,-a.Z) end
function VectorMeta.__div(a,b) return Vector.new(a.X/b,a.Y/b,a.Z/b) end
function Vector:Lerp(b,t) return self+(b-self)*t end
function VectorMeta.__mul(a,b) return Vector.new(a.X*b,a.Y*b,a.Z*b) end
function Vector:Dot(b) return self.X*b.X+self.Y*b.Y+self.Z*b.Z end
function Vector:Cross(b) return Vector.new(self.Y*b.Z-self.Z*b.Y,self.Z*b.X-self.X*b.Z,self.X*b.Y-self.Y*b.X) end
function VectorMeta.__index(a,key)
	if key=="Magnitude" then return math.sqrt(a:Dot(a)) end
	if key=="Unit" then return a/a.Magnitude end
	return Vector[key]
end
local Vector3=Vector
local Vector2={new=function(x,y) return {X=x,Y=y} end}
local transform={}
transform.__index=transform
function transform.__mul(a,b) return setmetatable({Position=a.Position,left=a,right=b},transform) end
function transform:ToObjectSpace(other) return other end
transform.LookVector=Vector.new(0,0,-1)
function transform:VectorToWorldSpace(v) return v end
local function cf(position) return setmetatable({Position=type(position)=="table" and position or Vector.new(0,0,0)},transform) end
function transform:Lerp(other) return other end
transform.Rotation=cf()
local CFrame={new=cf,Angles=cf,lookAt=cf,fromMatrix=cf}
local color={Lerp=function(self) return self end}
local Color3={new=function() return color end,fromRGB=function() return color end}
local UDim={new=function(scale,offset) return {Scale=scale,Offset=offset} end}
local UDim2={new=function(xs,xo,ys,yo) return {X=UDim.new(xs,xo),Y=UDim.new(ys,yo)} end,fromOffset=function(x,y) return {X=UDim.new(0,x),Y=UDim.new(0,y)} end,fromScale=function(x,y) return {X=UDim.new(x,0),Y=UDim.new(y,0)} end}
local NumberRange={new=function(...) return {...} end}
local NumberSequence={new=function(...) return {...} end}
local NumberSequenceKeypoint={new=function(...) return {...} end}
local ColorSequence=NumberSequence
local ColorSequenceKeypoint=NumberSequenceKeypoint
local task={wait=function() end,spawn=function(callback) callback() end}
local Enum=setmetatable({},{__index=function(_,k) return setmetatable({},{__index=function(_,v) return k..v end}) end})
local nativeMath=math
local math=table.clone(math)
math.noise=function(x,y,z) return nativeMath.sin(x*7+y*3+z)*.3 end
local objects={}
local methods={}
local meta={}
function meta.__index(self,key)
 if methods[key] or self.values[key]~=nil then return methods[key] or self.values[key] end
 for child in self.children do if child.Name==key then return child end end
end
function meta.__newindex(self,key,value)
	if key=="Parent" then
		local previous=self.values.Parent
		if previous then previous.children[self]=nil end
		if value then value.children[self]=true end
	end
	self.values[key]=value
end
function methods:Emit(count) self.emitted=(self.emitted or 0)+count end
function methods:GetPivot() return self.lastPivot or self.WorldPivot or cf() end
function methods:Play() self.IsPlaying=true; self.plays=(self.plays or 0)+1 end
function methods:Pause() self.IsPlaying=false end
function methods:Stop() self.IsPlaying=false end
function methods:LoadAsync() self.IsLoaded=true; self.TimeLength=15 end
function methods:SetDistanceAttenuation() end
function methods:GetChildren() local list={}; for child in self.children do table.insert(list,child) end; return list end
function methods:PivotTo(value) self.pivots=(self.pivots or 0)+1; self.lastPivot=value end
function methods:Destroy()
	for _,child in self:GetChildren() do child:Destroy() end
	self.Parent=nil; self.destroyed=true
end
local Instance={new=function(kind)
	local obj=setmetatable({values={ClassName=kind,Name=kind},children={}},meta)
	table.insert(objects,obj); return obj
end}
local seed=817
local random={}
function random:NextNumber(a,b)
	seed=(seed*48271)%2147483647
	return a+(b-a)*seed/2147483647
end

function methods:IsA(kind) return self.ClassName==kind or (kind=="BasePart" and self.ClassName=="Part") end
function methods:GetDescendants()
 local list={}
 for _,child in self:GetChildren() do table.insert(list,child); for _,nested in child:GetDescendants() do table.insert(list,nested) end end
 return list
end
function methods:IsDescendantOf(other) local p=self.Parent; while p do if p==other then return true end; p=p.Parent end; return false end
function methods:FindFirstChild(name)
 for _,child in self:GetChildren() do if child.Name==name then return child end end
end
function methods:FindFirstChildOfClass(kind)
 for _,child in self:GetChildren() do if child.ClassName==kind then return child end end
end
function methods:Clone()
 local copy=Instance.new(self.ClassName)
 for key,value in self.values do if key~="Parent" then copy[key]=value end end
 for _,child in self:GetChildren() do local clone=child:Clone(); clone.Parent=copy end
 return copy
end
local function signal()
 local s={}
 function s:Connect(callback)
  self.callback=callback
  local c={}; function c:Disconnect() if s.callback==callback then s.callback=nil end end
  return c
 end
 return s
end
function methods:GetPropertyChangedSignal() return signal() end
local function rig(kind)
 local model=Instance.new("Model")
 local names=kind=="R6" and {"HumanoidRootPart","Torso","Head","Left Arm","Right Arm","Left Leg","Right Leg"} or {"HumanoidRootPart","UpperTorso","LowerTorso","Head","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}
 for _,name in names do
  local p=Instance.new("Part"); p.Name=name; p.CFrame=cf(); p.Size=Vector.new(1,2,1); p.Color=color; p.Parent=model
 end
 local humanoid=Instance.new("Humanoid"); humanoid.Parent=model
 for _,name in {"Neck","Waist","LeftShoulder","RightShoulder","LeftElbow","RightElbow","LeftHip","RightHip","LeftKnee","RightKnee","LeftAnkle","RightAnkle"} do
  local joint=Instance.new("Motor6D"); joint.Name=name; joint.C0=cf(); joint.Parent=model
 end
 return model
end
local player={Character=rig()}
local requestedRig
local Players={LocalPlayer=player,CreateHumanoidModelFromDescriptionAsync=function(_,_,kind) requestedRig=kind; return rig() end}
local render=signal()
function render:Wait() if self.callback then self.callback(.016) end end
local lighting=Instance.new("Lighting")
lighting.ClockTime=17.7; lighting.Brightness=2; lighting.GeographicLatitude=41; lighting.FogStart=120; lighting.FogEnd=850; lighting.GlobalShadows=false; lighting.ExposureCompensation=.1
lighting.Ambient=color; lighting.OutdoorAmbient=color; lighting.ColorShift_Top=color; lighting.ColorShift_Bottom=color
local grade=Instance.new("ColorCorrectionEffect"); grade.Name="MenuSunset"; grade.Enabled=true; grade.Parent=lighting
local actions={}
local actionService={}
function actionService:BindActionAtPriority(name,callback) actions[name]=callback end
function actionService:UnbindAction(name) actions[name]=nil end
function actionService:SetTitle() end
function actionService:SetPosition() end
local inputService={InputBegan=signal(),InputEnded=signal(),InputChanged=signal(),MouseBehavior="Default",MouseIconEnabled=true}
local services={ContextActionService=actionService,UserInputService=inputService,Lighting=lighting,Players=Players,RunService={RenderStepped=render},ReplicatedStorage={WaitForChild=function() return {DinerTimeline="timeline",WesternOutfit="outfit",EscapeRules="escapeRules"} end}}
local game={GetService=function(_,name) return services[name] end}
local workspace=Instance.new("Workspace")
workspace.CurrentCamera={CFrame=cf(),FieldOfView=65}
local Timeline=(function()
-- INSERT_TIMELINE
end)()
local Paintings=(function()
-- INSERT_PAINTINGS
end)()
local script={Parent={GetawayVan="van",VanMirrors="mirrors",EscapeLandscape="escapeLandscape",CharacterMotion="motion",DinerEscape="escape",EscapeAudio="escapeAudio",EscapeProps="escapeProps",DinerExterior="exterior",VintageCars="cars",DinerAudio="audio",DinerBroadcast="broadcast",DinerArt="art",DinerCast="cast",LoadingLandscape="landscape",DinerPaintings="paintings"}}
local modules={timeline=Timeline,paintings=Paintings}
local function require(key) return assert(modules[key],"Missing module "..tostring(key)) end
local Art=(function()
-- INSERT_ART
end)()
local Cast=(function()
-- INSERT_CAST
end)()
local Outfit=(function()
-- INSERT_OUTFIT
end)()
modules.outfit=Outfit; modules.art=Art; modules.cast=Cast
local Landscape=(function()
-- INSERT_LANDSCAPE
end)()
modules.landscape=Landscape
local Loading=(function()
-- INSERT_LOADING
end)()
modules.audio=(function()
-- INSERT_AUDIO
end)()
modules.broadcast=(function()
-- INSERT_BROADCAST
end)()
modules.cars=(function()
-- INSERT_CARS
end)()
modules.van=(function()
-- INSERT_VAN
end)()
modules.escapeLandscape=(function()
-- INSERT_ESCAPE_LANDSCAPE
end)()
modules.mirrors=(function()
-- INSERT_MIRRORS
end)()
modules.exterior=(function()
-- INSERT_EXTERIOR
end)()
modules.escapeRules=(function()
-- INSERT_ESCAPE_RULES
end)()
modules.escapeAudio=(function()
-- INSERT_ESCAPE_AUDIO
end)()
modules.escapeProps=(function()
-- INSERT_ESCAPE_PROPS
end)()
modules.motion=(function()
-- INSERT_MOTION
end)()
modules.escape=(function()
-- INSERT_ESCAPE
end)()
modules.motion=(function()
-- INSERT_MOTION
end)()
local Diner=(function()
-- INSERT_DINER
end)()
local checks=0
local function check(ok,label) assert(ok,label); checks+=1; print("PASS: "..label) end
local diner=Diner.create({name="Test",gender="Boy",outfit={Hat="cowboy"}})
diner.prepare()
check(requestedRig=="HumanoidRigTypeR15","diner requests R15 NPCs")
local cast={}
for _,obj in objects do
 if obj.ClassName=="Model" and obj.Parent and obj.Parent.Name=="ShirtsAndSkins_DinerOpening" and obj:FindFirstChildOfClass("Humanoid") then table.insert(cast,obj) end
end
check(#cast==7,"diner has player, shared-table pair, reader, bar customer and two workers")
local faceCount=0
local mouths={}
local eyes={}
for _,person in cast do
 for _,obj in person:GetDescendants() do
  if obj.Name=="Animated character face" then faceCount+=1 end
  if obj.Name=="Animated mouth" then mouths[obj]=obj.Size.Y end
  if obj.Name=="Eye white" then eyes[obj]=obj.Size.Y end
 end
end
check(faceCount==6,"all six original NPCs have locally authored animated faces")
local small=rig(); small.Head.Size=Vector.new(1,1,1)
local large=rig(); large.Head.Size=Vector.new(2,1.5,1.4)
modules.cast.dress(small,2); modules.cast.dress(large,2)
local hairSmall,hairLarge
for _,p in small:GetDescendants() do if p.Name=="Fitted hair crown" then hairSmall=p end end
for _,p in large:GetDescendants() do if p.Name=="Fitted hair crown" then hairLarge=p end end
check(hairSmall and hairLarge and math.abs(hairLarge.Size.X/hairSmall.Size.X-2)<.0001 and math.abs(hairLarge.Size.Y/hairSmall.Size.Y-1.5)<.0001 and math.abs(hairLarge.Size.Z/hairSmall.Size.Z-1.4)<.0001,"NPC hair fits each head's width, height and depth independently")
small:Destroy(); large:Destroy()

local parts=0
local counts={}
for _,obj in objects do
 if obj:IsA("BasePart") and not obj.destroyed then parts+=1 end
 if obj.Name and not obj.destroyed then counts[obj.Name]=(counts[obj.Name] or 0)+1 end
end
local exteriorParts=0
local escapeParts=0
local landscapeParts=0
for _,obj in objects do if obj.Name=="Highway Four landscape and timber stash house" then for _,child in obj:GetDescendants() do if child:IsA("BasePart") then landscapeParts+=1 end end end end
for _,obj in objects do if obj.Name=="Highway Four escape cast and props" then for _,child in obj:GetDescendants() do if child:IsA("BasePart") then escapeParts+=1 end end end end
for _,obj in objects do if obj.Name=="Sunset Diner roadside block" then for _,child in obj:GetDescendants() do if child:IsA("BasePart") then exteriorParts+=1 end end end end
check(parts-exteriorParts-escapeParts<2400 and exteriorParts-landscapeParts<2400 and landscapeParts<1700 and escapeParts<800,"interior and roadside block stay within separate geometry budgets")
check(counts["Continuous steel roof"]==13 and counts["Stitched leather seat cushion"]==2 and counts["Turning steering wheel"]==1,"van has a closed roof, cabin seats and steering assembly")
check(counts["Stash house sign"]==1 and counts["Stave water tank"]==1 and counts["Turning wind pump"]==1,"stash house includes barn signage, water tower and wind pump")
check(counts["Matte black getaway panel van"]==1 and counts["Diner glass entrance"]==1 and counts["Weathered parking court"]==1,"exterior includes getaway van, opening entrance and parking court")
check(counts["Facing booth vinyl seat"]==8 and counts["Ivory laminate tabletop"]==4,"four booth tables each have two facing seats")
check(counts["Walnut diner radio"]==1 and not counts["CRT glass screen"],"broadcast uses one countertop radio and no television")
check(counts["Upright refrigerator"]==1 and counts["Sink dark basin"]==2 and counts["Stainless extractor hood"]==1,"compact kitchen includes fridge, sinks and extraction")
check(counts["Sculpted nose"]==12 and counts["Visible teeth"]==12,"diner, crew and officers have visible three-dimensional facial features")
check(counts["Booth side window"]==4,"each booth bay has a side window")
check(counts["Painted landscape"]==2 and counts["Hanging opal globe"]==12,"original paintings and suspended lights are present")
check(counts["Ketchup bottle"]==7 and counts["Salt shaker"]==7,"all booth tables and counter stations have full condiment sets")
local callbacks={}
local ui={}
function ui.make(kind,properties,parent)
 local obj=Instance.new(kind); for key,value in properties do obj[key]=value end; obj.Parent=parent; return obj
end
function ui.text(parent,text,pos,size) return ui.make("TextLabel",{Text=text,Position=pos,Size=size},parent) end
function ui.navButton(_,name,_,_,callback) callbacks[name]=callback end
local root=Instance.new("Frame"); root.AbsoluteSize={X=1280,Y=720}
local finishes=0
local stop=diner.play(root,ui,function() finishes+=1 end,function() return false end)
check(lighting.ClockTime==12 and grade.Enabled==false,"cutscene uses noon lighting without the sunset grade")
local originalJoints={}
for _,person in cast do for _,joint in person:GetDescendants() do if joint.ClassName=="Motor6D" then originalJoints[joint]=joint.C0 end end end
local blinked=false
local chewed=false
for _=1,50 do
 render.callback(.08)
 for eye in eyes do if eye.Size.Y==.025 then blinked=true end end
 for mouth,initial in mouths do if mouth.Size.Y~=initial then chewed=true end end
end
check(blinked and chewed,"NPCs blink and animate their mouths during the opening")
check(workspace.CurrentCamera.CameraType=="CameraTypeScriptable","diner takes scripted camera control")
local posed=false
for _,person in cast do
 for _,joint in person:GetDescendants() do if joint.ClassName=="Motor6D" and joint.Name=="RightShoulder" and joint.C0~=originalJoints[joint] then posed=true end end
end
check(posed,"R15 joint animation path runs without missing-joint errors")
render.callback(1.7)
local pausedPour=false
local voicesPlaying=0
local stingers=0
for _,obj in objects do
 if obj.Name=="Coffee pour stream" and obj.Transparency==1 then pausedPour=true end
 if obj.ClassName=="AudioTextToSpeech" and obj.IsPlaying then voicesPlaying+=1 end
 if obj.Name=="News stinger" and (obj.plays or 0)>0 then stingers+=1 end
end
check(pausedPour and voicesPlaying==1 and stingers==2,"news entrance pauses pouring and starts one shared narration source with the radio stinger")
render.callback(2)
local quietChatter,staticPlaying=false,false
for _,obj in objects do
 if obj.ClassName=="AudioTextToSpeech" and obj.IsPlaying and obj.Volume and obj.Volume<.03 then quietChatter=true end
 if obj.Name=="Light radio static" and obj.IsPlaying then staticPlaying=true end
end
check(quietChatter and staticPlaying,"light static and ducked background chatter continue under the radio report")
local officerVoice,leaderVoice,policeFilter
for _,obj in objects do
 if obj.ClassName=="AudioTextToSpeech" and obj.Name=="police" then officerVoice=obj.VoiceId end
 if obj.ClassName=="AudioTextToSpeech" and obj.Name=="unload" then leaderVoice=obj.VoiceId end
 if obj.ClassName=="AudioEqualizer" then policeFilter=true end
end
check(officerVoice~=leaderVoice and policeFilter,"dispatcher has a distinct voice and a radio channel filter")
check(not callbacks["Next shot →"] and not callbacks["Skip opening"],"story opening has no skip controls")
stop(); stop()
check(finishes==1 and render.callback==nil,"external stop cleans up once and disconnects camera animation")
for _,person in cast do assert(person.destroyed,"cast leaked after stopping") end
check(true,"all diner actors destroyed after stopping")
for _,obj in objects do if obj.ClassName=="AudioTextToSpeech" then assert(not obj.IsPlaying and obj.destroyed,"narration leaked after stopping") end end
check(true,"stopping destroys narration")
check(lighting.ClockTime==17.7 and lighting.GeographicLatitude==41 and lighting.FogEnd==850 and lighting.GlobalShadows==false and grade.Enabled==true,"stopping restores all overridden menu lighting including disabled booleans")
local wardrobeRig=rig()
Outfit.apply(wardrobeRig,{gender="Girl",outfit={Hat="cowboy"}})
local originalWardrobe=wardrobeRig:FindFirstChild("WesternWardrobe")
local hasHat=false
for _,p in originalWardrobe:GetDescendants() do if p.Name=="Shaped cowboy brim" then hasHat=true end end
check(hasHat,"R15 starter wardrobe includes fitted cowboy hat")
Outfit.apply(wardrobeRig,{gender="Girl",outfit={Hat="none"}})
local hats=0
for _,p in wardrobeRig:GetDescendants() do if p.Name=="Shaped cowboy brim" then hats+=1 end end
check(originalWardrobe.destroyed and hats==0,"changing hat choice replaces outfit without leaving old accessories")
local ok,result=Loading.run(root,ui,{function() return 1 end,function(previous) return previous+1 end},function() return false end)
check(ok and result==2 and render.callback==nil,"perspective loader preserves job sequencing and disconnects after completion")
local okFailure=Loading.run(root,ui,{function() error("asset failed") end},function() return true end)
check(not okFailure and render.callback==nil,"loader failure cleans up in reduced motion mode")
for _,obj in objects do if obj.ClassName=="ViewportFrame" then assert(obj.destroyed,"loading viewport leaked") end end
check(true,"loading geometry is destroyed after success and failure")
-- Reproduce the reported failure: the account character has no R6 Torso.
local sourceTorso=player.Character:FindFirstChild("UpperTorso")
sourceTorso.Name="Torso"
local descriptionReads=0
player.Character:FindFirstChildOfClass("Humanoid").GetAppliedDescription=function()
 descriptionReads+=1; return Instance.new("HumanoidDescription")
end
local natural=Diner.create({gender="Boy",outfit={Hat="none"}}); natural.prepare()
check(descriptionReads==1 and sourceTorso.Name=="Torso","R6 source avatar is converted for the story without changing the live avatar")
local r15Crew=0
for _,obj in objects do
 if not obj.destroyed and obj.ClassName=="Model" and (obj.Name:find("Masked crew ") or obj.Name:find("Highway patrol officer ")) then
  assert(obj:FindFirstChild("UpperTorso") and obj:FindFirstChild("LeftHand"),"escape actor inherited non-R15 rig")
  r15Crew+=1
 end
end
check(r15Crew==6,"all four crew and both officers use independent R15 templates with an R6 player")
local stopNatural=natural.play(root,ui,function() finishes+=1 end,function() return true end)
render.callback(100)
check(finishes==1 and actions.HighwayFour_Interact~=nil,"radio completion hands off into playable chapter without returning to menu")
local function frames(n) for _=1,n do assert(render.callback,"chapter lost its frame update"); render.callback(.05) end end
local function press(name,down) actions["HighwayFour_"..name](name,down and Enum.UserInputState.Begin or Enum.UserInputState.End,{Position=Vector.new(0,0,0)}) end
press("Interact",true); frames(42)
local paid=false
for _,obj in objects do if obj.Name=="Payment hundred dollar bill" and obj.Transparency==0 then paid=true end end
check(paid,"payment action places the bill before enabling walking")
press("Left",true); frames(32); press("Left",false)
press("Forward",true); frames(86); press("Forward",false)
frames(870)
local driving=false
for _,obj in objects do if obj.Name=="Interaction hint" and obj.Text and obj.Text:find("SAFEHOUSE") then driving=true end end
check(driving,"pay, walk through exit and complete all cinematic beats into driving")
local beforeLook=workspace.CurrentCamera.CFrame
inputService.InputBegan.callback({UserInputType=Enum.UserInputType.MouseButton2},false)
inputService.InputChanged.callback({UserInputType=Enum.UserInputType.MouseMovement,Delta={X=100,Y=20},Position={X=900,Y=300,Z=0}},false)
frames(1)
check(workspace.CurrentCamera.CFrame~=beforeLook,"driving camera responds to mouse orbit")
press("View",true); frames(3)
local mirrorsVisible=0
for _,obj in objects do if obj.ClassName=="ViewportFrame" and obj.Visible and obj.Parent and obj.Parent.Name=="Live rear-view mirror" then mirrorsVisible+=1 end end
check(mirrorsVisible==2,"cabin view activates both rearward patrol displays")
press("View",true)
press("Forward",true); frames(240); press("Forward",false)
local lost=false
for _,obj in objects do if obj.Name=="Mission objective" and obj.Text and obj.Text:find("Patrol lost") then lost=true end end
check(lost,"driving away at speed loses the pursuing patrol")
stopNatural(); stopNatural()
local mirrorsClean=true
for _,obj in objects do if obj.Name=="Live rear-view mirror" and not obj.destroyed then mirrorsClean=false end end
check(mirrorsClean,"chapter teardown destroys both rear-view scenes")
check(finishes==2 and render.callback==nil and next(actions)==nil,"chapter teardown disconnects camera and every control binding once")
check(lighting.ClockTime==17.7 and grade.Enabled==true and inputService.MouseBehavior=="Default","chapter teardown restores menu lighting and mouse behavior")
print(string.format("%d diner integration checks passed",checks))
