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
local function rotate(r,v) return Vector.new(r[1]*v.X+r[2]*v.Y+r[3]*v.Z,r[4]*v.X+r[5]*v.Y+r[6]*v.Z,r[7]*v.X+r[8]*v.Y+r[9]*v.Z) end
local function cf(x,y,z) return setmetatable({Position=type(x)=="table" and x or Vector.new(x or 0,y or 0,z or 0),r={1,0,0,0,1,0,0,0,1}},transform) end
function transform.__mul(a,b)
 local r={}
 for y=0,2 do for x=0,2 do r[y*3+x+1]=0; for k=0,2 do r[y*3+x+1]+=a.r[y*3+k+1]*b.r[k*3+x+1] end end end
 local result=cf(a.Position+rotate(a.r,b.Position)); result.r=r; result.left=a; result.right=b; return result
end
function transform:Inverse()
 local r={self.r[1],self.r[4],self.r[7],self.r[2],self.r[5],self.r[8],self.r[3],self.r[6],self.r[9]}
 local result=cf(rotate(r,-self.Position)); result.r=r; return result
end
function transform:ToObjectSpace(other) return self:Inverse()*other end
transform.LookVector=Vector.new(0,0,-1)
function transform:VectorToWorldSpace(v) return rotate(self.r,v) end
function transform:Lerp(other) return other end
transform.Rotation=cf()
local CFrame={new=cf,lookAt=cf,fromMatrix=cf}
function CFrame.Angles(x,y,z)
 local cx,sx,cy,sy,cz,sz=math.cos(x),math.sin(x),math.cos(y),math.sin(y),math.cos(z),math.sin(z)
 local t=cf(); t.angles={x,y,z}; t.r={cy*cz,-cy*sz,sy,cx*sz+sx*sy*cz,cx*cz-sx*sy*sz,-sx*cy,sx*sz-cx*sy*cz,sx*cz+cx*sy*sz,cx*cy}; return t
end
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
local warnings={}
local function warn(message) table.insert(warnings,message) end
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
 local humanoid=Instance.new("Humanoid"); humanoid.RequiresNeck=true; humanoid.BreakJointsOnDeath=true; humanoid.EvaluateStateMachine=true; humanoid.Health=100; humanoid.Parent=model
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
local services={ContentProvider={PreloadAsync=function(_,items) for _,item in items do item.IsLoaded=true; item.TimeLength=42.866938 end end},ContextActionService=actionService,UserInputService=inputService,Lighting=lighting,Players=Players,RunService={RenderStepped=render},ReplicatedStorage={WaitForChild=function() return {DinerTimeline="timeline",WesternOutfit="outfit",EscapeRules="escapeRules",WarehouseRules="warehouseRules"} end}}
local game={GetService=function(_,name) return services[name] end}
local workspace=Instance.new("Workspace")
workspace.CurrentCamera={CFrame=cf(),FieldOfView=65}
local Timeline=(function()
-- INSERT_TIMELINE
end)()
local Paintings=(function()
-- INSERT_PAINTINGS
end)()
local script={Parent={PeriodPatrol="patrol",WarehouseSet="warehouseSet",WarehouseChapter="warehouseChapter",GetawayVan="van",VanMirrors="mirrors",EscapeLandscape="escapeLandscape",CharacterMotion="motion",DinerEscape="escape",EscapeAudio="escapeAudio",EscapeProps="escapeProps",DinerExterior="exterior",VintageCars="cars",DinerAudio="audio",DinerBroadcast="broadcast",DinerArt="art",DinerCast="cast",LoadingLandscape="landscape",DinerPaintings="paintings"}}
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
modules.warehouseSet=(function()
-- INSERT_WAREHOUSE_SET
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
modules.patrol=(function()
-- INSERT_PATROL
end)()
modules.escapeProps=(function()
-- INSERT_ESCAPE_PROPS
end)()
modules.motion=(function()
-- INSERT_MOTION
end)()
modules.warehouseRules=(function()
-- INSERT_WAREHOUSE_RULES
end)()
modules.warehouseChapter=(function()
-- INSERT_WAREHOUSE_CHAPTER
end)()
modules.escape=(function()
-- INSERT_ESCAPE
end)()
local Diner=(function()
-- INSERT_DINER
end)()
local checks=0
local function check(ok,label) assert(ok,label); checks+=1; print("PASS: "..label) end
local sceneProps,sceneOrigin
local originalPropsBuild=modules.escapeProps.build
modules.escapeProps.build=function(ctx)
 sceneOrigin=ctx.origin; sceneProps=originalPropsBuild(ctx); return sceneProps
end
local diner=Diner.create({name="Test",gender="Boy",outfit={Hat="cowboy"}})
diner.prepare()
check(requestedRig=="HumanoidRigTypeR15","diner requests R15 NPCs")
local cast={}
for _,obj in objects do
 if obj.ClassName=="Model" and obj.Parent and obj.Parent.Name=="ShirtsAndSkins_DinerOpening" and obj:FindFirstChildOfClass("Humanoid") then table.insert(cast,obj) end
end
check(#cast==7,"diner has player, shared-table pair, reader, bar customer and two workers")
local protected=0
for _,obj in cast[1].Parent:GetDescendants() do
 if obj:IsA("Humanoid") then
  assert(obj.RequiresNeck==false and obj.BreakJointsOnDeath==false and obj.EvaluateStateMachine==false,"scene Humanoid can destroy its animation joints before playback")
  protected+=1
 end
end
check(protected==13,"player, diner cast, gang and officers protect their skeletons before playback begins")
local liveHuman=player.Character:FindFirstChildOfClass("Humanoid")
check(liveHuman.RequiresNeck and liveHuman.BreakJointsOnDeath and liveHuman.EvaluateStateMachine,"scene animation setup leaves the live player's Humanoid physics and death behavior intact")
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
check(parts-exteriorParts-escapeParts<2400 and exteriorParts-landscapeParts<2400 and landscapeParts<1700 and escapeParts<800,string.format("geometry budgets: interior %d/2400, roadside %d/2400, landscape %d/1700, cast and props %d/800",parts-exteriorParts-escapeParts,exteriorParts-landscapeParts,landscapeParts,escapeParts))
check(counts["Continuous steel roof"]==13 and counts["Stitched leather seat cushion"]==2 and counts["Turning steering wheel"]==1,"van has a closed roof, cabin seats and steering assembly")
check(counts["Stash house sign"]==1 and counts["Stave water tank"]==1 and counts["Turning wind pump"]==1,"stash house includes barn signage, water tower and wind pump")
check(counts["Matte black getaway panel van"]==1 and counts["Diner glass entrance"]==1 and counts["Weathered parking court"]==1,"exterior includes getaway van, opening entrance and parking court")
check(counts["Facing booth vinyl seat"]==8 and counts["Ivory laminate tabletop"]==4,"four booth tables each have two facing seats")
check(counts["Walnut diner radio"]==1 and not counts["CRT glass screen"],"broadcast uses one countertop radio and no television")
check(counts["Upright refrigerator"]==1 and counts["Sink dark basin"]==2 and counts["Stainless extractor hood"]==1,"compact kitchen includes fridge, sinks and extraction")
check(counts["Sculpted nose"]==12 and counts["Visible teeth"]==12,"diner, crew and officers have visible three-dimensional facial features")
check(counts["Booth side window"]==4 and not counts["Clear noon window"],"glazing is limited to booth windows and the existing glass entrance")
check(counts["Painted landscape"]==2 and counts["Hanging opal globe"]==12,"original paintings and suspended lights are present")
check(counts["Ketchup bottle"]==7 and counts["Salt shaker"]==7,"all booth tables and counter stations have full condiment sets")
local function bounds(cf,size)
 local minX,minZ,maxX,maxZ=math.huge,math.huge,-math.huge,-math.huge
 for _,x in {-1,1} do for _,y in {-1,1} do for _,z in {-1,1} do
  local at=(cf*CFrame.new(x*size.X/2,y*size.Y/2,z*size.Z/2)).Position
  minX=math.min(minX,at.X); maxX=math.max(maxX,at.X); minZ=math.min(minZ,at.Z); maxZ=math.max(maxZ,at.Z)
 end end end
 return {minX,minZ,maxX,maxZ}
end
local terrainCount=0
for _,obj in objects do
 if obj.Name=="Layered desert dune" or obj.Name=="Weathered sandstone shoulder" then
  terrainCount+=1
  local b=bounds(obj.CFrame,obj.Size)
  -- Actual transformed geometry, independently of the generator's exclusion helper.
  for _,area in {{-225,-98,140,235},{-270,112,1250,166},{860,150,985,235}} do
   assert(b[3]<=area[1] or b[1]>=area[3] or b[4]<=area[2] or b[2]>=area[4],"landform overlaps a playable lot, arrival lane or road")
  end
 end
end
check(terrainCount>10,"distant scenery remains while rotated dune and rock bounds clear all playable yards and roads")
local parkedBounds={}
for i,unit in sceneProps.police do
 local parked=modules.escapeRules.policeArrival(i,20)
 local parkedCF=CFrame.new(parked.x,.7,parked.z)*CFrame.Angles(0,parked.yaw,0)
 local outer={math.huge,math.huge,-math.huge,-math.huge}
 for _,part in unit.model:GetDescendants() do if part:IsA("BasePart") then
  local localCF=CFrame.new(sceneOrigin):ToObjectSpace(part.CFrame)
  local b=bounds(parkedCF*localCF,part.Size)
  outer={math.min(outer[1],b[1]),math.min(outer[2],b[2]),math.max(outer[3],b[3]),math.max(outer[4],b[4])}
  if (part.Transparency or 0)<.5 then
   for _,height in {2.5,3.8} do
    local probe=(localCF:Inverse()*CFrame.new(-.82,height,-.15)).Position
    assert(math.abs(probe.X)>part.Size.X/2 or math.abs(probe.Y)>part.Size.Y/2 or math.abs(probe.Z)>part.Size.Z/2,"solid body fills patrol driver cabin")
   end
  end
 end end
 parkedBounds[i]=outer
 local outside=(parkedCF*unit.driverExit).Position
 local start=modules.escapeRules.officerApproach(i,0)
 assert(math.abs(outside.X-start.x)<.001 and math.abs(outside.Z-start.z)<.001,"officer teleports between door exit and foot approach")
end
check(parkedBounds[2][3]+1<parkedBounds[1][1],"longer period sedans stop with bumper clearance and leave real space for their drivers")
check(sceneProps.steam.Enabled==false,"truck steam stays off during the diner opening and payment")
local callbacks={}
local ui={}
function ui.make(kind,properties,parent)
 local obj=Instance.new(kind); for key,value in properties do obj[key]=value end; obj.Parent=parent
 if kind=="TextButton" then obj.Activated={Connect=function(_,callback)
  callbacks[obj.Text]=callback; return {Disconnect=function() if callbacks[obj.Text]==callback then callbacks[obj.Text]=nil end end}
 end} end
 return obj
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
local arrivalTime
local arrival=modules.escapeRules.policeArrival
modules.escapeRules.policeArrival=function(i,t) if i==1 then arrivalTime=t end; return arrival(i,t) end
local posedOfficers={}
local originalPatrolPose=modules.motion.pose
modules.motion.pose=function(person,origin,pos,angle,dt,seated,...)
 if person.style=="officer" then posedOfficers[person]={pos=pos,seated=seated} end
 return originalPatrolPose(person,origin,pos,angle,dt,seated,...)
end
local patrolObserved,brakesObserved,exitObserved,runningObserved=false,false,false,false
local steeringObserved=false
local arrivalFovs={}
local function frames(n) for _=1,n do
 assert(render.callback,"chapter lost its frame update"); arrivalTime=nil; render.callback(.05)
 if arrivalTime then
  patrolObserved=true; arrivalFovs[workspace.CurrentCamera.FieldOfView]=true
  for i,unit in sceneProps.police do
   local route=arrival(i,arrivalTime)
   local actor=sceneProps.officers[i]; local posed=assert(posedOfficers[actor],"patrol driver has no pose")
   if not route.stopped then assert(posed.seated,"officer runs beside moving cruiser") end
   local later=arrival(i,arrivalTime+.001)
   local turn=(later.yaw-route.yaw+math.pi)%(2*math.pi)-math.pi
   if math.abs(turn)>.0001 and route.steer~=0 then
    for _,wheel in unit.wheels do if wheel.front then
     local axle=unit.model:GetPivot():ToObjectSpace(wheel.part.CFrame):VectorToWorldSpace(Vector.new(1,0,0))
     assert(math.atan2(-axle.Z,axle.X)*turn>0,"front wheels steer against the cruiser's actual turn")
    end end
    steeringObserved=true
   end
   if route.braking then
    brakesObserved=true
    for _,lamp in unit.brakes do assert(lamp.Material==Enum.Material.Neon,"brake lamp is not timed with deceleration") end
   end
   if arrivalTime>route.duration+.7 then
    local doorLocal=unit.model:GetPivot():ToObjectSpace(unit.door:GetPivot())
    local edge=(doorLocal*CFrame.new(0,0,2.5)).Position
    assert(edge.X<unit.doorOffset.Position.X-1,"driver door swings into the cabin")
    exitObserved=true
   end
   if arrivalTime>route.duration+1.15 and (actor.motionSpeed or 0)>5 then
    local knee=actor.joints.LeftKnee.joint.C0
    if math.abs(knee.r[8])>.4 then runningObserved=true end
   end
  end
 end
end end
local function press(name,down) actions["HighwayFour_"..name](name,down and Enum.UserInputState.Begin or Enum.UserInputState.End,{Position=Vector.new(0,0,0)}) end
press("Interact",true); frames(42)
local paid=false
for _,obj in objects do if obj.Name=="Payment hundred dollar bill" and obj.Transparency==0 then paid=true end end
check(paid,"payment action places the bill before enabling walking")
press("Left",true); frames(32); press("Left",false)
press("Forward",true); frames(86); press("Forward",false)
local cinemaSeconds=0; for _,shot in modules.escapeRules.shots do cinemaSeconds+=shot.duration end
frames(math.ceil(cinemaSeconds/.05)+20)
modules.escapeRules.policeArrival=arrival; modules.motion.pose=originalPatrolPose
local shots=0; for _ in arrivalFovs do shots+=1 end
check(patrolObserved and steeringObserved and brakesObserved and exitObserved and runningObserved and shots>=4,"police sequence stages camera changes, aligned steering, seated driving, braking, outward doors and R15 running")
check(sceneProps.steam.Enabled,"radiator steam starts after the damaged pickup arrives")
local driving=false
for _,obj in objects do if obj.Name=="Interaction hint" and obj.Text and obj.Text:find("SAFEHOUSE") then driving=true end end
check(driving,"pay, walk through exit and complete all cinematic beats into driving")
local beforeLook=workspace.CurrentCamera.CFrame
inputService.InputBegan.callback({UserInputType=Enum.UserInputType.MouseButton2},false)
inputService.InputChanged.callback({UserInputType=Enum.UserInputType.MouseMovement,Delta={X=100,Y=20},Position={X=900,Y=300,Z=0}},false)
frames(1)
check(workspace.CurrentCamera.CFrame~=beforeLook,"driving camera responds to mouse orbit")
press("View",true); frames(3)
local visibleHands=false
for _,obj in objects do if not obj.destroyed and obj.Name=="Main character" then
 visibleHands=obj.Head.LocalTransparencyModifier==1 and obj.LeftHand.LocalTransparencyModifier==0 and obj.RightHand.LocalTransparencyModifier==0
end end
check(visibleHands,"first-person camera hides the head while retaining the player's hands")
local mirrorsVisible=0
for _,obj in objects do if obj.ClassName=="ViewportFrame" and obj.Visible and obj.Parent and obj.Parent.Name=="Live rear-view mirror" then mirrorsVisible+=1 end end
check(mirrorsVisible==2,"cabin view activates both rearward patrol displays")
local cameraRotation=workspace.CurrentCamera.CFrame.right.angles
check(cameraRotation[1]==0 and cameraRotation[3]==0,"reduced-motion mode suppresses cabin pitch and roll")
press("Lights",true)
local darkHeadlamps=0
for _,obj in objects do if not obj.destroyed and obj.ClassName=="SpotLight" and obj.Parent and obj.Parent.Name=="Warm headlamp lens" and obj.Enabled==false then darkHeadlamps+=1 end end
check(darkHeadlamps==2,"headlight control switches off both van beams")
press("Lights",true)
press("Wipers",true); frames(3)
local movingWipers=0
for _,obj in objects do if not obj.destroyed and obj.Name=="Working windshield wiper" and math.abs(obj:GetPivot().right.angles[3]+.65)>.1 then movingWipers+=1 end end
check(movingWipers==2,"wiper control animates both blades")
press("Wipers",false); press("Wipers",true); frames(20)
local parkedWipers=0
for _,obj in objects do if not obj.destroyed and obj.Name=="Working windshield wiper" and math.abs(obj:GetPivot().right.angles[3]+.65)<.00001 then parkedWipers+=1 end end
check(parkedWipers==2,"switching wipers off mid-sweep returns both blades to their parked position")
press("View",true)
press("Forward",true); frames(240); press("Forward",false)
local lost=false
for _,obj in objects do if obj.Name=="Mission objective" and obj.Text and obj.Text:find("Patrol lost") then lost=true end end
check(lost,"driving away at speed loses the pursuing patrol")
-- Put the current car at the warehouse entrance, then exercise actual chapter
-- input, camera handoff, prop animation and retry through the render callback.
local originalMission=modules.escapeRules.mission
local depotCar,arrivalFrames
arrivalFrames=0
modules.escapeRules.mission=function(_,car)
 depotCar=car; car.x=920; car.z=163; car.yaw=math.pi; car.speed=0; car.steer=0
 arrivalFrames+=1
 return arrivalFrames>=2 and "safe" or nil
end
frames(2); modules.escapeRules.mission=originalMission
local heroPosition
local originalPose=modules.motion.pose
modules.motion.pose=function(person,origin,pos,...)
 if person.rig.Name=="Main character" then heroPosition=pos end
 return originalPose(person,origin,pos,...)
end
frames(66)
local function walkTo(x,z)
 local reached=false
 for _=1,300 do
  assert(heroPosition,"warehouse did not pose the player")
  local dx,dz=x-heroPosition.X,z-heroPosition.Z
  if math.sqrt(dx*dx+dz*dz)<.65 then reached=true; break end
  -- Arrival sets the freely rotatable on-foot camera to face +Z.
  press("Left",dx>.25); press("Right",dx<-.25)
  press("Forward",dz>.25); press("Reverse",dz<-.25)
  frames(1)
 end
 for _,name in {"Left","Right","Forward","Reverse"} do press(name,false) end
 assert(reached,string.format("blocked warehouse route to %.1f,%.1f from %.1f,%.1f",x,z,heroPosition.X,heroPosition.Z))
end
walkTo(925,177); walkTo(910,179); press("Interact",true); frames(28)
local opened=0
for _,obj in objects do if not obj.destroyed and obj.Name=="Sliding loading door" and obj.pivots then opened+=1 end end
check(opened==2,"warehouse latch animates both physical loading doors")
walkTo(925,177); walkTo(925,167); press("Interact",true); frames(22)
press("Forward",true)
for _=1,200 do if depotCar.z>=198 then break end; frames(1) end
press("Forward",false); press("Brake",true); frames(24); press("Brake",false)
check(modules.warehouseRules.parked(depotCar),"player can drive from the driveway through the bay and brake in the marked parking zone")
press("Interact",true); frames(22)
frames(1420)
check(callbacks["Retry warehouse checkpoint"]~=nil,"exposed warehouse produces its own retry action")
callbacks["Retry warehouse checkpoint"](); frames(2)
check(depotCar.z==202 and depotCar.speed==0,"warehouse retry resumes beside the parked van without replaying the diner")
for _=1,2 do
 walkTo(925,194); walkTo(922,194); press("Interact",true); frames(18)
 walkTo(930,194); walkTo(932,207); press("Interact",true); frames(18)
end
frames(40) -- second crew member finishes the staged carry
local secured=0
for _,obj in objects do if not obj.destroyed and obj.Name:find("Secured canvas bag ") and obj.Transparency==0 then secured+=1 end end
check(secured==4,"two player deliveries and two crew deliveries place all four physical duffels on the pallet")
walkTo(930,216); walkTo(911,216); walkTo(911,186); press("Interact",true); frames(32)
walkTo(930,186); press("Interact",true); press("View",true); frames(164)
local complete=false
for _,obj in objects do if not obj.destroyed and obj.Text and obj.Text:find("CASH SECURED") then complete=true end end
check(complete,"full warehouse gameplay and final patrol shots complete the chapter")
check(inputService.MouseBehavior=="Default" and inputService.MouseIconEnabled,"finishing in first person releases the mouse for result buttons")
modules.motion.pose=originalPose
stopNatural(); stopNatural()
local mirrorsClean=true
for _,obj in objects do if obj.Name=="Live rear-view mirror" and not obj.destroyed then mirrorsClean=false end end
check(mirrorsClean,"chapter teardown destroys both rear-view scenes")
check(finishes==2 and render.callback==nil and next(actions)==nil,"chapter teardown disconnects camera and every control binding once")
check(lighting.ClockTime==17.7 and grade.Enabled==true and inputService.MouseBehavior=="Default","chapter teardown restores menu lighting and mouse behavior")
-- Supplied narration must remain one continuous performance across camera cuts.
Timeline.recording.assetId="123456"
local testRadio=Instance.new("Part"); testRadio.Parent=workspace
local recorded=modules.audio.create(workspace,testRadio,Timeline.dialogue)
local report
for _,obj in objects do if obj.Name=="Recorded Blox News report" and not obj.destroyed then report=obj end end
report.IsLoaded=false
recorded.update(3,0)
check(not report.IsPlaying,"recording waits for loading without starting a substitute robot narrator")
report.IsLoaded=true
recorded.update(3,2)
check(report.TimePosition==2,"late audio loading joins the current report position")
check(report and report.IsPlaying and report.SoundId=="rbxassetid://123456","configured Roblox recording replaces the report narrator")
report.TimePosition=7.1; recorded.update(4,0)
check(report.plays==1 and report.IsPlaying,"camera cuts do not restart or pause the recorded report")
report.TimePosition=8; recorded.update(5,1)
check(math.abs(report.TimePosition-21.6)<.001,"recording catches up to the same scene clock after a long frame")
recorded.update(7,0)
check(not report.IsPlaying,"emergency static stops recorded narration")
recorded.destroy(); check(report.destroyed,"recorded narration is destroyed with the scene")
local originalPreload=services.ContentProvider.PreloadAsync
services.ContentProvider.PreloadAsync=function() error("Audio permission denied") end
local missing=modules.audio.create(workspace,testRadio,Timeline.dialogue)
missing.update(3,2); missing.update(7,0); missing.destroy()
check(#warnings==1,"an inaccessible recording warns without blocking scene progression or cleanup")
services.ContentProvider.PreloadAsync=originalPreload
Timeline.recording.assetId=""
testRadio:Destroy()
print(string.format("%d diner integration checks passed",checks))
