local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TextService=game:GetService("TextService")
local RunService=game:GetService("RunService")
local Config=require(ReplicatedStorage.GameShared.Config)
local Catalog=require(ReplicatedStorage.GameShared.CharacterCatalog)
local Outfit=require(ReplicatedStorage.GameShared.WesternOutfit)
local remote=Instance.new("RemoteFunction")
remote.Name,remote.Parent="CharacterRequest",ReplicatedStorage.GameShared
local profiles,lastChange,busy={},{},{}
local function apply(player)
	local profile=profiles[player]
	local character=player.Character
	if profile and character then
		Outfit.apply(character,profile)
		local humanoid=character:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.DisplayName=profile.name end
	end
end
local function added(player)
	player.CharacterAppearanceLoaded:Connect(function() apply(player) end)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid",10)
		-- AppearanceLoaded handles normal Roblox avatars; this also supports test rigs.
		task.delay(2,function() if player.Character==character then apply(player) end end)
	end)
end
Players.PlayerAdded:Connect(added)
for _,player in Players:GetPlayers() do added(player) end
Players.PlayerRemoving:Connect(function(player) profiles[player]=nil; lastChange[player]=nil; busy[player]=nil end)
remote.OnServerInvoke=function(player,action,data)
	local notice
	if action=="get" then return {ok=true,profile=profiles[player]} end
	if busy[player] then return {ok=false,message="Please wait for your previous selection."} end
	local now=os.clock()
	if now-(lastChange[player] or -math.huge)<Catalog.SelectionCooldown then return {ok=false,message="Please wait half a second between selections."} end
	lastChange[player]=now
	if action=="create" then
		if profiles[player] then return {ok=true,profile=profiles[player]} end
		if type(data)~="table" then return {ok=false,message="Invalid character details."} end
		local valid,name=Catalog.validateIdentity(data.name,data.gender,data.personality)
		if not valid then return {ok=false,message=name} end
		local developerId=Config.DeveloperUserId
		if developerId==0 and game.CreatorType==Enum.CreatorType.User then developerId=game.CreatorId end
		if not Catalog.nameAllowed(name,player.UserId,developerId) then return {ok=false,message="This name is unavailable."} end
		busy[player]=true
		local ok,filtered=pcall(function()
			return TextService:FilterStringAsync(name,player.UserId):GetNonChatStringForBroadcastAsync()
		end)
		busy[player]=nil
		if not player.Parent then return {ok=false,message="Player left."} end
		if not ok then
			if not RunService:IsStudio() then return {ok=false,message="Could not check that name. Please try again."} end
			-- Studio filtering may be unavailable. Never use the unfiltered input.
			filtered="Studio Explorer"
			notice="Studio is using a placeholder name because filtering is unavailable. Test your chosen name in the published game."
		end
		if filtered:find("#") or not Catalog.nameAllowed(filtered,player.UserId,developerId) then return {ok=false,message="This name is unavailable."} end
		profiles[player]={name=filtered,gender=data.gender,personality=data.personality,outfit=Catalog.defaultOutfit()}
	elseif action=="equip" then
		local profile=profiles[player]
		if not profile or type(data)~="table" then return {ok=false,message="Create your character first."} end
		local valid,message=Catalog.canEquip(profile.outfit,data.slot,data.id)
		if not valid then return {ok=false,message=message} end
		profile.outfit[data.slot]=data.id
	else return {ok=false,message="Unknown character action."} end
	apply(player)
	return {ok=true,profile=profiles[player],notice=notice}
end
