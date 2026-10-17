-- Pure rules shared with the command-line tests; authority stays on the server.
local Rules = {}
function Rules.validCapacity(value)
	return value == 1 or value == 2 or value == 4
end
function Rules.canJoin(count, capacity, expires, now)
	return count < capacity and now < expires
end
return Rules
