-- Service doubles exercise allocation, cadence, visibility, and cleanup.
-- They do not simulate rendering or Roblox physics.
local Vector={}
local VectorMeta={}
function Vector.new(x,y,z) return setmetatable({X=x,Y=y,Z=z},VectorMeta) end
function VectorMeta.__add(a,b) return Vector.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
function VectorMeta.__sub(a,b) return Vector.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
function VectorMeta.__unm(a) return Vector.new(-a.X,-a.Y,-a.Z) end
function VectorMeta.__div(a,b) return Vector.new(a.X/b,a.Y/b,a.Z/b) end
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
function transform.__mul(a) return a end
function transform:VectorToWorldSpace(v) return v end
local function cf(position) return setmetatable({Position=type(position)=="table" and position or Vector.new(0,0,0)},transform) end
function transform:Lerp(other) return other end
transform.Rotation=cf()
local CFrame={new=cf,Angles=cf,lookAt=cf,fromMatrix=cf}
local color={Lerp=function(self) return self end}
local Color3={new=function() return color end,fromRGB=function() return color end}
local UDim={new=function(scale,offset) return {Scale=scale,Offset=offset} end}
local UDim2={new=function(xs,xo,ys,yo) return {X=UDim.new(xs,xo),Y=UDim.new(ys,yo)} end,fromOffset=function(x,y) return {X=UDim.new(0,x),Y=UDim.new(0,y)} end,fromScale=function(x,y) return {X=UDim.new(x,0),Y=UDim.new(y,0)} end}
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
	local obj=setmetatable({values={ClassName=kind},children={}},meta)
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
  local c={}; function c:Disconnect() s.callback=nil end
  return c
 end
 return s
end
function methods:GetPropertyChangedSignal() return signal() end
local function rig()
 local model=Instance.new("Model")
 for _,name in {"HumanoidRootPart","Torso","Head","Left Arm","Right Arm","Left Leg","Right Leg"} do
  local p=Instance.new("Part"); p.Name=name; p.CFrame=cf(); p.Size=Vector.new(1,2,1); p.Color=color; p.Parent=model
 end
 local humanoid=Instance.new("Humanoid"); humanoid.Parent=model
 for _,name in {"Neck","Left Shoulder","Right Shoulder","Left Hip","Right Hip"} do
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
local services={Lighting=lighting,Players=Players,RunService={RenderStepped=render},ReplicatedStorage={WaitForChild=function() return {DinerTimeline="timeline",WesternOutfit="outfit"} end}}
local game={GetService=function(_,name) return services[name] end}
local workspace=Instance.new("Workspace")
workspace.CurrentCamera={}
local Timeline=(function()
-- INSERT_TIMELINE
end)()
local Paintings=(function()
-- INSERT_PAINTINGS
end)()
local script={Parent={DinerAudio="audio",DinerBroadcast="broadcast",DinerArt="art",DinerCast="cast",LoadingLandscape="landscape",DinerPaintings="paintings"}}
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
local Diner=(function()
-- INSERT_DINER
end)()
local checks=0
local function check(ok,label) assert(ok,label); checks+=1; print("PASS: "..label) end
local diner=Diner.create({name="Test",gender="Boy",outfit={Hat="cowboy"}})
diner.prepare()
check(requestedRig=="HumanoidRigTypeR6","diner requests standard R6 NPCs")
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
local parts=0
local counts={}
for _,obj in objects do
 if obj:IsA("BasePart") then parts+=1 end
 if obj.Name then counts[obj.Name]=(counts[obj.Name] or 0)+1 end
end
check(parts<2400 and #objects<6200,"expanded diner stays within geometry and artwork allocation budgets")
check(counts["Facing booth vinyl seat"]==8 and counts["Ivory laminate tabletop"]==4,"four booth tables each have two facing seats")
check(counts["Walnut diner radio"]==1 and not counts["CRT glass screen"],"broadcast uses one countertop radio and no television")
check(counts["Upright refrigerator"]==1 and counts["Sink dark basin"]==2 and counts["Stainless extractor hood"]==1,"compact kitchen includes fridge, sinks and extraction")
check(counts["Sculpted nose"]==6 and counts["Visible teeth"]==6,"all NPCs have visible three-dimensional facial features")
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
 for _,joint in person:GetDescendants() do if joint.ClassName=="Motor6D" and joint.Name=="Right Shoulder" and joint.C0~=originalJoints[joint] then posed=true end end
end
check(posed,"R6 joint animation path runs without missing-joint errors")
callbacks["Next shot →"]()
render.callback(.2)
local pausedPour=false
local voicesPlaying=0
local stingers=0
for _,obj in objects do
 if obj.Name=="Coffee pour stream" and obj.Transparency==1 then pausedPour=true end
 if obj.ClassName=="AudioTextToSpeech" and obj.IsPlaying then voicesPlaying+=1 end
 if obj.Name=="News stinger" and (obj.plays or 0)>0 then stingers+=1 end
end
check(pausedPour and voicesPlaying==1 and stingers==2,"news entrance pauses pouring and starts one shared narration source with the radio stinger")
callbacks["Skip opening"]()
stop()
check(finishes==1 and render.callback==nil,"skip cleans up once and disconnects camera animation")
for _,person in cast do assert(person.destroyed,"cast leaked after skip") end
check(true,"all diner actors destroyed after skip")
for _,obj in objects do if obj.ClassName=="AudioTextToSpeech" then assert(not obj.IsPlaying and obj.destroyed,"narration leaked after skip") end end
check(true,"skip stops and destroys narration")
check(lighting.ClockTime==17.7 and lighting.GeographicLatitude==41 and lighting.FogEnd==850 and lighting.GlobalShadows==false and grade.Enabled==true,"skip restores all overridden menu lighting including disabled booleans")
local wardrobeRig=rig()
Outfit.apply(wardrobeRig,{gender="Girl",outfit={Hat="cowboy"}})
local originalWardrobe=wardrobeRig:FindFirstChild("WesternWardrobe")
local hasHat=false
for _,p in originalWardrobe:GetDescendants() do if p.Name=="Shaped cowboy brim" then hasHat=true end end
check(hasHat,"R6 starter wardrobe includes fitted cowboy hat")
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
local natural=Diner.create({gender="Boy",outfit={Hat="none"}}); natural.prepare()
natural.play(root,ui,function() finishes+=1 end,function() return true end)
render.callback(100)
check(finishes==2 and lighting.ClockTime==17.7 and grade.Enabled==true,"natural cutscene completion also restores menu lighting")
print(string.format("%d diner integration checks passed",checks))
