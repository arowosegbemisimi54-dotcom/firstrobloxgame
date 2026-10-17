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
local function cf() return setmetatable({},transform) end
local CFrame={new=cf,Angles=cf,lookAt=cf,fromMatrix=cf}
local color={Lerp=function(self) return self end}
local Color3={fromRGB=function() return color end}
local UDim2={fromScale=function() return {} end}
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
function methods:SetAttribute(key,value) self.values["attr_"..key]=value end
function methods:GetAttribute(key) return self.values["attr_"..key] end
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
local Traffic=(function()
-- INSERT_TRAFFIC
end)()
local script={Parent={DesertTraffic="traffic"}}
local function require(key) assert(key=="traffic"); return Traffic end
local Details=(function()
-- INSERT_DETAILS
end)()
local model=Instance.new("Model")
local function part(name,size,position,color,material)
	local p=Instance.new("Part")
	p.Name,p.Size,p.Position,p.Color,p.Material=name,size,position,color,material
	p.Parent=model
	return p
end
local details=Details.build(part,model,Vector.new(0,12000,0),random)
local initialCount=#objects
local weeds={}
for _,obj in objects do if obj.Name=="Rolling tumbleweed" then table.insert(weeds,obj) end end
local checks=0
local function check(ok,message) assert(ok,message); checks+=1; print("PASS: "..message) end
check(#weeds==4,"exactly four tumbleweeds allocated")
check(initialCount<1900,"scenery including pooled vehicles stays below 1900 objects")
local function activeCount()
	local count=0; for _,weed in weeds do if weed.Parent then count+=1 end end; return count
end
local cars,bikes={},{}
for _,obj in objects do
 if obj.Name=="Antique touring car" then table.insert(cars,obj) end
 if obj.Name=="Antique motorcycle with rider" then table.insert(bikes,obj) end
end
check(#cars==8 and #bikes==3,"bounded traffic pools contain antique cars and motorcycle riders")
local lastCarSpawn=nil
local carSpawns,bikeSpawns=0,0
local wasActive={}
local lastSpawn=nil
local previous={}
local spawns=0
for step=1,1200 do
	details.update(.1,true,true)
	for _,car in cars do
		if car.Parent and car:GetAttribute("DepartureTime")~=wasActive[car] then
			local time=step*.1
			if lastCarSpawn then assert(math.abs(time-lastCarSpawn-4)<.11,"car cadence drifted from four seconds") end
			lastCarSpawn=time; carSpawns+=1
		end
		wasActive[car]=car:GetAttribute("DepartureTime")
	end
	for _,bike in bikes do
		if bike.Parent and bike:GetAttribute("DepartureTime")~=wasActive[bike] then bikeSpawns+=1 end
		wasActive[bike]=bike:GetAttribute("DepartureTime")
	end
	assert(activeCount()<=4,"unbounded tumbleweed pool")
	for _,weed in weeds do
		if weed.Parent and not previous[weed] then
			local time=step*.1
			if lastSpawn then assert(time-lastSpawn>=1.99 and time-lastSpawn<=4.11,"spawn interval outside 2–4 seconds plus one update") end
			lastSpawn=time; spawns+=1
		end
		previous[weed]=weed.Parent~=nil
	end
end
check(spawns>30 and #objects==initialCount,"two minute simulation preserves cadence with no allocation growth")
check(carSpawns>=29 and bikeSpawns>=9,"cars depart every four seconds with motorcycle departures in rotation")
local function trafficPivots() local n=0; for _,vehicle in cars do n+=vehicle.pivots or 0 end; for _,vehicle in bikes do n+=vehicle.pivots or 0 end; return n end
local trafficBefore=trafficPivots()
local function pivots() local n=0; for _,weed in weeds do n+=weed.pivots or 0 end; return n end
local before=pivots()
for _=1,100 do details.update(.1,true,false) end
check(pivots()==before,"reduced motion freezes tumbleweeds")
for _=1,100 do details.update(.1,false,true) end
check(pivots()==before,"hidden mode screen pauses updates")
check(trafficPivots()==trafficBefore,"hidden or reduced motion freezes traffic without allocating replacements")
details.setLowEffects(true)
for _=1,300 do details.update(.1,true,true); assert(activeCount()<=1,"low effects exceeded one weed") end
check(true,"low effects limits the active pool to one")
details.destroy()
for _,weed in weeds do assert(weed.destroyed and not weed.Parent,"leaked parked weed") end
check(true,"cleanup destroys active and parked tumbleweeds")
for _,car in cars do assert(car.destroyed,"car leaked") end
for _,bike in bikes do assert(bike.destroyed,"motorcycle leaked") end
check(true,"cleanup destroys active and parked traffic")
print(string.format("%d scenery checks passed",checks))
