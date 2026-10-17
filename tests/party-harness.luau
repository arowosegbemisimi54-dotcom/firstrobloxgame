-- The Python runner inserts the actual server and shared modules into this harness.
-- Minimal service doubles test authority and invitation transitions without Studio.
local now = 0
local os = {clock=function() return now end}
local function signal()
	local s={}
	function s:Connect(fn) self.callback=fn end
	return s
end
local users={}
for id=1,4 do users[id]={UserId=id,DisplayName="Player"..id} end
local Players={PlayerAdded=signal(),PlayerRemoving=signal()}
function Players:GetPlayers()
	local result={}; for _,p in users do table.insert(result,p) end; return result
end
function Players:GetPlayerByUserId(id) return users[id] end
local Remote={OnServerEvent=signal(),messages={},states={},invites={}}
function Remote:FireClient(p,kind,value)
	if kind=="party" then self.states[p.UserId]=value
	elseif kind=="message" then self.messages[p.UserId]=value
	elseif kind=="invitation" then self.invites[p.UserId]=value end
end
local Instance={new=function(kind) if kind=="RemoteEvent" then return Remote else return {} end end}
local Config={OnlinePlaceId=0,StoryPlaceId=0,InviteLifetime=30}
local Rules=(function()
-- INSERT_RULES
end)()
local Shared={Config="config",PartyRules="rules"}
local function require(key) return key=="config" and Config or Rules end
local Teleport={TeleportInitFailed=signal(),calls=0}
function Teleport:TeleportAsync() self.calls+=1 end
local services={Players=Players,ReplicatedStorage={GameShared=Shared},TeleportService=Teleport}
local game={GetService=function(_,name) return services[name] end}
local function boot()
-- INSERT_SERVER
end
boot()
local checks=0
local function check(condition,label)
	assert(condition,label); checks+=1; print("PASS: "..label)
end
local function send(id,action,value)
	now+=.3; Remote.OnServerEvent.callback(users[id],action,value)
end
send(1,"sync")
check(Remote.states[1].capacity==1,"new player starts solo")
send(1,"capacity",3)
check(Remote.states[1].capacity==1,"invalid capacity rejected")
send(1,"invite",2)
check(Remote.invites[2]==nil,"solo party cannot invite beyond capacity")
send(1,"capacity",2); send(1,"invite",2); send(2,"accept")
check(#Remote.states[1].members==2 and Remote.states[2].leader==1,"invited player joins duo")
send(2,"capacity",4)
check(Remote.states[1].capacity==2,"nonleader cannot change capacity")
send(1,"invite",3)
check(Remote.invites[3]==nil,"full duo cannot invite a third member")
send(1,"capacity",1)
check(Remote.states[1].capacity==2,"cannot shrink below current member count")
send(1,"capacity",4); send(1,"invite",3)
now+=31; send(3,"accept")
check(Remote.states[3].leader==3,"expired invitation cannot join")
send(3,"accept")
check(Remote.states[3].leader==3,"uninvited acceptance cannot join")
send(1,"invite",3); send(3,"decline"); send(3,"accept")
check(Remote.states[3].leader==3,"declined invitation cannot be reused")
send(1,"invite",3); send(3,"accept"); send(1,"leave")
check(Remote.states[2].leader==2 and #Remote.states[2].members==2,"leader leave promotes remaining member")
check(Remote.states[1].leader==1 and #Remote.states[1].members==1,"leaving player receives separate solo party")
send(2,"start"); send(4,"online")
check(Teleport.calls==0,"unconfigured destinations do not teleport")
check(string.find(Remote.messages[2],"development")~=nil,"story launch explains unavailable mission")
Config.StoryPlaceId=123
send(3,"start")
check(Teleport.calls==0,"nonleader cannot launch crew")
send(2,"start")
check(Teleport.calls==1,"configured story destination invokes server teleport")
local departing=users[2]; users[2]=nil; Players.PlayerRemoving.callback(departing)
check(Remote.states[3].leader==3,"disconnected leader transfers leadership")
print(string.format("%d party checks passed",checks))
