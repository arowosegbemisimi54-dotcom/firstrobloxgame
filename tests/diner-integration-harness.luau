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
local Vector2={new=function() return {} end}
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
local UDim2={new=function() return {} end,fromOffset=function() return {} end,fromScale=function() return {} end}
local Enum=setmetatable({},{__index=function(_,k) return setmetatable({},{__index=function(_,v) return k..v end}) end})
local nativeMath=math
local math=table.clone(math)
math.noise=function(x,y,z) return nativeMath.sin(x*7+y*3+z)*.3 end
local objects={}
local methods={}
local meta={}
function meta.__index(self,key) return methods[key] or self.values[key] end
function meta.__newindex(self,key,value)
	if key=="Parent" then
		local previous=self.values.Parent
		if previous then previous.children[self]=nil end
		if value then value.children[self]=true end
	end
	self.values[key]=value
end
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
local services={Players=Players,RunService={RenderStepped=render},ReplicatedStorage={WaitForChild=function() return {DinerTimeline="timeline",WesternOutfit="outfit"} end}}
local game={GetService=function(_,name) return services[name] end}
local workspace=Instance.new("Workspace")
workspace.CurrentCamera={}
local Timeline=(function()
-- INSERT_TIMELINE
end)()
local outfitApplied=0
local function require(key) if key=="timeline" then return Timeline end; return {apply=function() outfitApplied+=1 end} end
local Diner=(function()
-- INSERT_DINER
end)()
local checks=0
local function check(ok,label) assert(ok,label); checks+=1; print("PASS: "..label) end
local diner=Diner.create({name="Test"})
diner.prepare()
check(requestedRig=="HumanoidRigTypeR6","diner requests standard R6 NPCs")
local cast={}
for _,obj in objects do
 if obj.ClassName=="Model" and obj.Parent and obj.Parent.Name=="ShirtsAndSkins_DinerOpening" then table.insert(cast,obj) end
end
check(#cast==5,"diner has player, two other customers, waitress, chef")
check(outfitApplied==3,"player and two customers receive outfit geometry")
local callbacks={}
local ui={}
function ui.make(kind,properties,parent)
 local obj=Instance.new(kind); for key,value in properties do obj[key]=value end; obj.Parent=parent; return obj
end
function ui.navButton(_,name,_,_,callback) callbacks[name]=callback end
local root=Instance.new("Frame"); root.AbsoluteSize={X=1280,Y=720}
local finishes=0
local stop=diner.play(root,ui,function() finishes+=1 end,function() return false end)
local originalJoints={}
for _,person in cast do for _,joint in person:GetDescendants() do if joint.ClassName=="Motor6D" then originalJoints[joint]=joint.C0 end end end
for _=1,10 do render.callback(.1) end
check(workspace.CurrentCamera.CameraType=="CameraTypeScriptable","diner takes scripted camera control")
local posed=false
for _,person in cast do
 for _,joint in person:GetDescendants() do if joint.ClassName=="Motor6D" and joint.Name=="Right Shoulder" and joint.C0~=originalJoints[joint] then posed=true end end
end
check(posed,"R6 joint animation path runs without missing-joint errors")
callbacks["Next shot →"]()
callbacks["Skip opening"]()
stop()
check(finishes==1 and render.callback==nil,"skip cleans up once and disconnects camera animation")
for _,person in cast do assert(person.destroyed,"cast leaked after skip") end
check(true,"all diner actors destroyed after skip")
print(string.format("%d diner integration checks passed",checks))
