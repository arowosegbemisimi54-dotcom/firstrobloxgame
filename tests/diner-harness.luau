local Timeline=(function()
-- INSERT_TIMELINE
end)()
local checks=0
local function check(ok,label) assert(ok,label); checks+=1; print("PASS: "..label) end
local scene=Timeline.new()
Timeline.advance(scene,2.49)
check(scene.shot==1 and not scene.done,"diner glide lasts 2.5 seconds")
Timeline.advance(scene,.02)
check(scene.shot==2,"glide advances to character focus")
Timeline.next(scene)
check(scene.shot==3 and scene.elapsed==0,"next shot skips only current segment")
while not scene.done do Timeline.next(scene) end
check(scene.done,"skipping last shot finishes opening")
local skipped=Timeline.new(); Timeline.skip(skipped); Timeline.advance(skipped,100)
check(skipped.done and skipped.shot==1,"skip whole opening ends immediately")
local normal=Timeline.new(); Timeline.advance(normal,70.5)
check(normal.done,"normal playback reaches end of supplied scene")
local stalled=Timeline.new(); Timeline.advance(stalled,100)
check(stalled.done,"long frame advances safely across multiple shots")
local negative=Timeline.new(); Timeline.advance(negative,-1)
check(negative.elapsed==0,"negative deltas cannot rewind timeline")
Timeline.recording.assetId="12345"
local recorded=Timeline.new(); Timeline.advance(recorded,5.5)
check(recorded.shot==3 and math.abs(Timeline.duration(recorded)-7.1)<.001,"recorded report uses measured first sentence duration")
Timeline.advance(recorded,7.1)
check(recorded.shot==4 and math.abs(Timeline.recordingTime(4,0)-7.1)<.001,"next camera cut shares the continuous recording cursor")
Timeline.advance(recorded,42.866938-7.1+.001)
check(recorded.shot==7 and not recorded.done,"emergency static begins only after the complete supplied MP3")
Timeline.advance(recorded,3)
check(recorded.done,"recorded report completes the opening without an extra silent report segment")
Timeline.recording.assetId=""
print(string.format("%d diner timeline checks passed",checks))
