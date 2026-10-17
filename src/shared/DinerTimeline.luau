-- One clock drives camera segments, broadcast graphics, captions and reactions.
local Timeline={durations={2.5,3,10,19,15,18,3}}
Timeline.dialogue={
 [3]="We interrupt your afternoon program for a Blox News Flash! I'm Bob Blockman reporting live from the Blox News Center.",
 [4]="A massive, high-stakes heist has just taken place at the Downtown First National Bank. Authorities confirm that a heavily armed crew has escaped with nearly four million dollars in cash, rare vault items, and untraceable bearer bonds!",
 [5]="Police Chief McBlock reports the vault was breached in under three minutes, making this the largest robbery in Robloxian history! The suspects were last seen fleeing west on Highway 4.",
 [6]="If you are currently near Highway 4 or local establishments, law enforcement urges you to lock your doors and stay inside. These suspects are considered armed, desperate, and extremely dangerous—",
}
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
