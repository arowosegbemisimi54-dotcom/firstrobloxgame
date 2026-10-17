local now=0
local os={clock=function() return now end}
local function signal() return {Connect=function(self,fn) self.callback=fn end} end
local users={}
for i=1,4 do users[i]={UserId=i,Parent=true,CharacterAppearanceLoaded=signal(),CharacterAdded=signal()} end
local Players={PlayerAdded=signal(),PlayerRemoving=signal(),GetPlayers=function() return users end}
local filterFails=false
local inStudio=false
local TextService={FilterStringAsync=function(_,name)
	if filterFails then error("Filtering unavailable") end
	return {GetNonChatStringForBroadcastAsync=function() return name=="blocked" and "#######" or name end}
end}
local remote={}
local Instance={new=function() return remote end}
local Catalog=(function()
-- INSERT_CATALOG
end)()
local services={RunService={IsStudio=function() return inStudio end},Players=Players,TextService=TextService,ReplicatedStorage={GameShared={CharacterCatalog="catalog",WesternOutfit="outfit"}}}
local game={GetService=function(_,key) return services[key] end}
local function require(key) return key=="catalog" and Catalog or {apply=function() end} end
local function boot()
-- INSERT_CHARACTER_SERVER
end
boot()
local checks=0
local function check(ok,label) assert(ok,label); checks+=1; print("PASS: "..label) end
local function send(user,action,data,delay)
	now+=delay or .6
	return remote.OnServerInvoke(users[user],action,data)
end
check(not send(1,"equip",{slot="Hat",id="none"}).ok,"clothing changes require character creation")
check(not send(1,"create",{name="A",gender="Boy",personality="Friendly"}).ok,"short names rejected")
check(not send(1,"create",{name="Sam",gender="Other",personality="Friendly"}).ok,"invalid character choice rejected")
check(not send(1,"create",{name="Sam",gender="Boy",personality="Forged"}).ok,"unknown personality rejected")
check(not send(1,"create",{name="blocked",gender="Boy",personality="Friendly"}).ok,"filtered names rejected")
filterFails=true
check(not send(1,"create",{name="Sam",gender="Boy",personality="Friendly"}).ok,"filter outage never publishes unfiltered names")
inStudio=true
local studio=send(3,"create",{name="unfiltered",gender="Boy",personality="Funny"})
check(studio.ok and studio.profile.name=="Studio Explorer" and studio.notice~=nil,"Studio filter outage uses safe placeholder with notice")
inStudio=false
filterFails=false
local first=send(1,"create",{name="  Sam  ",gender="Boy",personality="Friendly"})
check(first.ok and first.profile.name=="Sam","valid character creation trims and filters name")
local second=send(2,"create",{name="Sam",gender="Girl",personality="Mysterious"})
check(second.ok and second.profile.name==first.profile.name,"duplicate character names allowed")
check(second.profile.gender=="Girl" and second.profile.personality=="Mysterious","gender and personality retained")
local before=table.clone(first.profile.outfit)
check(not send(1,"equip",{slot="Critter",id="dog"}).ok,"locked dog rejected by server")
check(not send(1,"equip",{slot="Costume",id="desert_bird"}).ok,"locked costume rejected by server")
check(not send(1,"equip",{slot="Hat",id="admin_hat"}).ok,"forged item rejected")
local changed=send(1,"equip",{slot="Hat",id="none"})
check(changed.ok and changed.profile.outfit.Hat=="none","optional hat can be removed")
check(changed.profile.outfit.Top==before.Top and changed.profile.outfit.Bottom==before.Bottom,"hat change preserves other clothing")
check(not send(1,"equip",{slot="Hat",id="cowboy"},.1).ok,"rapid selections rejected server-side")
check(send(1,"equip",{slot="Hat",id="cowboy"},.5).ok,"selection permitted after half a second")
local other=send(2,"get")
check(other.profile.outfit.Hat=="cowboy","player inventories are independent")
check(not Catalog.validateIdentity("Sam\nSmith","Boy","Funny"),"control characters in names rejected")
check(not Catalog.validateIdentity(string.rep("x",25),"Boy","Funny"),"overlong names rejected")
check(not Catalog.validateIdentity("\255","Boy","Funny"),"invalid UTF-8 rejected")
local costume=Catalog.defaultOutfit(); costume.Costume="desert_bird"
check(not Catalog.canEquip(costume,"Hat","cowboy"),"costume prevents individual item changes")
check(Catalog.canEquip(costume,"Costume","none"),"costume can be removed to restore clothing")
Players.PlayerRemoving.callback(users[1])
check(send(1,"get").profile==nil,"disconnected session profile is cleaned up")
print(string.format("%d character checks passed",checks))
