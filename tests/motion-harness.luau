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
print(n..' motion checks passed')
