-- Numerical transforms: these tests check rendered part positions, not merely C0 writes.
local Vec={}; Vec.__index=function(v,k)
 if k=="Magnitude" then return math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z) end
 return Vec[k]
end
function Vec.__add(a,b) return setmetatable({X=a.X+b.X,Y=a.Y+b.Y,Z=a.Z+b.Z},Vec) end
function Vec.__sub(a,b) return setmetatable({X=a.X-b.X,Y=a.Y-b.Y,Z=a.Z-b.Z},Vec) end
local Vector3={new=function(x,y,z) return setmetatable({X=x,Y=y,Z=z},Vec) end}
local CF={}; CF.__index=CF
local function matrix(p,r) return setmetatable({Position=p,r=r},CF) end
local function rotate(r,p) return Vector3.new(r[1]*p.X+r[2]*p.Y+r[3]*p.Z,r[4]*p.X+r[5]*p.Y+r[6]*p.Z,r[7]*p.X+r[8]*p.Y+r[9]*p.Z) end
function CF.__mul(a,b)
 local r={}
 for y=0,2 do for x=0,2 do
  r[y*3+x+1]=0
  for k=0,2 do r[y*3+x+1]+=a.r[y*3+k+1]*b.r[k*3+x+1] end
 end end
 return matrix(a.Position+rotate(a.r,b.Position),r)
end
function CF:Inverse()
 local r={self.r[1],self.r[4],self.r[7],self.r[2],self.r[5],self.r[8],self.r[3],self.r[6],self.r[9]}
 return matrix(rotate(r,Vector3.new(-self.Position.X,-self.Position.Y,-self.Position.Z)),r)
end
function CF:ToObjectSpace(other) return self:Inverse()*other end
local CFrame={}
function CFrame.new(x,y,z) return matrix(type(x)=="table" and x or Vector3.new(x or 0,y or 0,z or 0),{1,0,0,0,1,0,0,0,1}) end
function CFrame.Angles(x,y,z)
 local cx,sx,cy,sy,cz,sz=math.cos(x),math.sin(x),math.cos(y),math.sin(y),math.cos(z),math.sin(z)
 return matrix(Vector3.new(0,0,0),{cy*cz,-cy*sz,sy,cx*sz+sx*sy*cz,cx*cz-sx*sy*sz,-sx*cy,sx*sz-cx*sy*cz,sx*cz+cx*sy*sz,cx*cy})
end
local Motion=(function()
-- INSERT_MOTION
end)()
local n=0
local function check(v,label) assert(v,label); n+=1; print('PASS: '..label) end
local stand=Motion.sample(0,0,false,'crew',0)
check(stand.LeftHip==0 and stand.RightHip==0 and stand.bob==0,'stationary characters do not cycle their feet')
local run=Motion.sample(1.7,18,false,'crew',0)
check(math.abs(run.LeftHip)>.7 and run.RightKnee< -1,'R15 running flexes hip and knee through a full stride')
check(run.LeftShoulder==.1 and run.RightElbow>1,'carrying crew stabilize the duffel arm while pumping the free arm')
local seated=Motion.sample(0,0,true,'crew',0)
check(seated.LeftHip>0 and seated.LeftKnee<0,'R15 seat pose folds knees beneath raised thighs')
local officer=Motion.sample(1,12,false,'officer',0)
check(officer.RightShoulder==1.3 and officer.LeftElbow==.9 and officer.LeftHip~=0,'officers move their legs while holding a two-handed aim')

local descendants={}
local function object(kind,name)
 local o={Name=name,Parent=true,kind=kind}
 function o:IsA(class) return self.kind==class end
 table.insert(descendants,o); return o
end
local root=object("BasePart","HumanoidRootPart"); root.CFrame=CFrame.new()
local upper=object("BasePart","LeftUpperLeg"); upper.CFrame=CFrame.new(0,-2,0)
local lower=object("BasePart","LeftLowerLeg"); lower.CFrame=CFrame.new(0,-4,0)
local boot=object("BasePart","Boot"); boot.CFrame=CFrame.new(0,-5,-.2)
local hip=object("Motor6D","LeftHip"); hip.Part0=root; hip.Part1=upper; hip.C0=CFrame.new(0,-1,0); hip.C1=CFrame.new(0,1,0); hip.Transform=CFrame.Angles(1,0,0)
local knee=object("Motor6D","LeftKnee"); knee.Part0=upper; knee.Part1=lower; knee.C0=CFrame.new(0,-1,0); knee.C1=CFrame.new(0,1,0)
local weld=object("WeldConstraint","BootWeld"); weld.Part0=lower; weld.Part1=boot
local accessory=object("BasePart","AccessoryHandle"); accessory.CFrame=CFrame.new(0,1,0)
local accessoryWeld=object("Weld","AccessoryWeld"); accessoryWeld.Part0=accessory; accessoryWeld.Part1=root; accessoryWeld.C0=CFrame.new(0,-1,0); accessoryWeld.C1=CFrame.new()
local rig={}
function rig:GetDescendants() local reverse={}; for i=#descendants,1,-1 do table.insert(reverse,descendants[i]) end; return reverse end
function rig:FindFirstChild(name) return name=="HumanoidRootPart" and root end
function rig:PivotTo(cf) root.CFrame=cf end
local person={rig=rig,joints={LeftHip={joint=hip,base=hip.C0},LeftKnee={joint=knee,base=knee.C0}}}
Motion.bind(person)
check(#person.poseLinks==4 and (person.poseLinks[1].a==root or person.poseLinks[1].b==root),"pose solver orders an unordered joint tree from the root")
check(root.Anchored and upper.Anchored and lower.Anchored and boot.Anchored and hip.Enabled==false,"scene pose owns anchored limbs without competing physics joints")
Motion.pose(person,Vector3.new(0,0,0),Vector3.new(0,3,0),0,.1,false,0); Motion.flush(person)
local initial=lower.CFrame.Position
Motion.pose(person,Vector3.new(0,0,0),Vector3.new(0,3,-1.2),0,.1,false,.1); Motion.flush(person)
local translated=initial+Vector3.new(0,0,-1.2)
check((lower.CFrame.Position-translated).Magnitude>.2,"walking visibly bends and moves the lower leg beyond root translation")
local expected=lower.CFrame*CFrame.new(0,-1,-.2)
check((boot.CFrame.Position-expected.Position).Magnitude<.00001,"welded boots follow the animated leg in the same render frame")
local once=boot.CFrame.Position; Motion.flush(person)
check((boot.CFrame.Position-once).Magnitude<.00001,"repeated pose solves do not accumulate offsets")
check((accessory.CFrame.Position-(root.CFrame*CFrame.new(0,1,0)).Position).Magnitude<.00001,"reverse accessory welds follow the rig rather than freezing in space")
local frame=0
for _=1,30 do
 frame+=1
 Motion.pose(person,Vector3.new(0,0,0),Vector3.new(frame*.2,3,-1.2),0,1/60,false,frame/60); Motion.flush(person)
end
check(math.abs(root.CFrame.r[3]+1)<.00001,"moving characters face their actual travel direction instead of sliding sideways")
print(n..' motion checks passed')
