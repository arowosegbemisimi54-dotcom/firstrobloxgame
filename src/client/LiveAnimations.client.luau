local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Live=require(script.Parent.LiveCharacterMotion)
local entries={}
local connections={}
local closed=false
local function remove(player)
 local entry=entries[player]
 if not entry then return end
 entries[player]=nil
 if entry.motion then entry.motion.destroy() end
 for _,connection in entry.connections do connection:Disconnect() end
end
local function add(player)
 if entries[player] then return end
 local entry={connections={}}
 entries[player]=entry
 local function characterAdded(character)
  if entry.motion then entry.motion.destroy(); entry.motion=nil end
  entry.character=character
  task.spawn(function()
   local humanoid=character:WaitForChild("Humanoid",10)
   local root=character:WaitForChild("HumanoidRootPart",10)
   local torso=character:WaitForChild("UpperTorso",10)
   if not humanoid or not root or not torso or closed or entries[player]~=entry or entry.character~=character then return end
   entry.motion=Live.attach(character)
  end)
 end
 table.insert(entry.connections,player.CharacterAdded:Connect(characterAdded))
 table.insert(entry.connections,player.CharacterRemoving:Connect(function(character)
  if entry.character~=character then return end
  entry.character=nil
  if entry.motion then entry.motion.destroy(); entry.motion=nil end
 end))
 if player.Character then characterAdded(player.Character) end
end
for _,player in Players:GetPlayers() do add(player) end
-- Restore the prior layer before Animator evaluates, then author the current
-- grounded pose after Animator and before Motor6D transforms are applied.
table.insert(connections,RunService.PreAnimation:Connect(function()
 for _,entry in entries do if entry.motion then entry.motion.reset() end end
end))
table.insert(connections,RunService.PreSimulation:Connect(function(dt)
 for _,entry in entries do if entry.motion then entry.motion.update(dt) end end
end))
table.insert(connections,Players.PlayerAdded:Connect(add))
table.insert(connections,Players.PlayerRemoving:Connect(remove))
script.Destroying:Connect(function()
 closed=true
 for _,connection in connections do connection:Disconnect() end
 for player in entries do remove(player) end
end)
