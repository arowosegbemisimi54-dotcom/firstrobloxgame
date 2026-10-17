-- The supplied opening only: no invented dialogue or subsequent mission.
local Timeline={durations={2.5,3.0,4.0}}
function Timeline.new() return {shot=1,elapsed=0,done=false} end
function Timeline.next(state)
	if state.done then return end
	state.shot+=1; state.elapsed=0
	if state.shot>#Timeline.durations then state.done=true end
end
function Timeline.skip(state) state.done=true end
function Timeline.advance(state,dt)
	if state.done then return end
	state.elapsed+=math.max(0,dt)
	while not state.done and state.elapsed>=Timeline.durations[state.shot] do
		local remainder=state.elapsed-Timeline.durations[state.shot]
		Timeline.next(state); state.elapsed=remainder
	end
end
return Timeline
