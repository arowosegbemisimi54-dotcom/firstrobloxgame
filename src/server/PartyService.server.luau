local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Config = require(ReplicatedStorage.GameShared.Config)
local Rules = require(ReplicatedStorage.GameShared.PartyRules)
local remote = Instance.new("RemoteEvent")
remote.Name, remote.Parent = "MenuAction", ReplicatedStorage.GameShared
local parties, membership, invitations, lastRequest = {}, {}, {}, {}
local function tell(player, message) remote:FireClient(player, "message", message) end
local function snapshot(player)
	local party = parties[membership[player.UserId]]
	if not party then return end
	local members = {}
	for _,id in party.members do
		local member = Players:GetPlayerByUserId(id)
		if member then table.insert(members, {id=id, name=member.DisplayName}) end
	end
	remote:FireClient(player, "party", {leader=party.leader, capacity=party.capacity, members=members, busy=party.busy or false})
end
local function broadcast()
	for _,player in Players:GetPlayers() do snapshot(player) end
end
local function solo(player)
	local id = player.UserId
	membership[id] = id
	parties[id] = {leader=id, capacity=1, members={id}}
end
local function leave(player, reconnect)
	local id = player.UserId
	local party = parties[membership[id]]
	if party then
		local index = table.find(party.members,id)
		if index then table.remove(party.members,index) end
		if party.leader == id then
			parties[id] = nil
			if #party.members > 0 then
				party.leader = party.members[1]
				parties[party.leader] = party
				for _,memberId in party.members do membership[memberId] = party.leader end
			end
		end
	end
	membership[id], invitations[id] = nil, nil
	if reconnect then solo(player) end
end
local function travel(player, placeId, members, reserved)
	if placeId <= 0 then
		tell(player, reserved and "The story opening is ready. The first playable mission is still in development." or "Online is coming later. Story Mode is available now.")
		return
	end
	local options = Instance.new("TeleportOptions")
	options.ShouldReserveServer = reserved
	local ok = pcall(function() TeleportService:TeleportAsync(placeId,members,options) end)
	if not ok then tell(player,"Travel failed. Please try again in the published game.") end
end
Players.PlayerAdded:Connect(solo)
for _,player in Players:GetPlayers() do solo(player) end
Players.PlayerRemoving:Connect(function(player)
	leave(player,false); lastRequest[player.UserId] = nil
	broadcast()
end)
remote.OnServerEvent:Connect(function(player, action, value)
	if type(action) ~= "string" then return end
	local now = os.clock()
	if now - (lastRequest[player.UserId] or -1) < .2 then return end
	lastRequest[player.UserId] = now
	local party = parties[membership[player.UserId]]
	if not party then return end
	if action == "sync" then snapshot(player); return end
	if action == "online" then travel(player,Config.OnlinePlaceId,{player},false); return end
	if action == "leave" then leave(player,true)
	elseif action == "capacity" then
		if party.leader ~= player.UserId or not Rules.validCapacity(value) then return end
		if #party.members > value then tell(player,"Your party has too many members for that size."); return end
		party.capacity = value
	elseif action == "invite" then
		if party.leader ~= player.UserId or type(value) ~= "number" or value == player.UserId then return end
		local target = Players:GetPlayerByUserId(value)
		if not target or #party.members >= party.capacity then tell(player,"Choose Duo or Squad and leave a free slot first."); return end
		local targetParty = parties[membership[value]]
		if not targetParty or #targetParty.members > 1 then tell(player,"That player is already in a party."); return end
		invitations[value] = {leader=party.leader, party=party, expires=now+Config.InviteLifetime}
		remote:FireClient(target,"invitation",{leader=party.leader,name=player.DisplayName})
		tell(player,"Invitation sent to "..target.DisplayName..".")
	elseif action == "accept" then
		local invitation = invitations[player.UserId]
		if not invitation then tell(player,"That invitation has expired."); return end
		local destination = parties[invitation.leader]
		if not destination or destination ~= invitation.party or #party.members > 1 or not Rules.canJoin(#destination.members,destination.capacity,invitation.expires,now) then
			invitations[player.UserId] = nil; tell(player,"The party is full or the invitation has expired."); return
		end
		leave(player,false)
		membership[player.UserId] = destination.leader
		table.insert(destination.members,player.UserId)
	elseif action == "decline" then invitations[player.UserId] = nil
	elseif action == "start" then
		if party.leader ~= player.UserId then tell(player,"Only the party leader can start."); return end
		local members = {}
		for _,id in party.members do
			local member = Players:GetPlayerByUserId(id)
			if member then table.insert(members,member) end
		end
		if Config.StoryPlaceId>0 then
			travel(player,Config.StoryPlaceId,members,true)
		else
			if now-(party.lastOpening or -math.huge)<2 then return end
			party.lastOpening=now
			for _,member in members do remote:FireClient(member,"storyOpening") end
		end
	end
	broadcast()
end)
TeleportService.TeleportInitFailed:Connect(function(player) tell(player,"Travel could not complete. Please try again.") end)
