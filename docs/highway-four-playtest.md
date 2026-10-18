# Highway Four chapter playtest

The radio opening now continues into the new chapter and has no skip controls,
as requested in Part 2. Existing menus, wardrobe selection and menu traffic are
unchanged. This remains the existing client-local story scene: party members
receive their own chapter, not a replicated shared driving session. No rewards
or persistent mission progress are granted by the local controller.

## Flow

1. Start Story / Play and let the radio opening finish.
2. Press E, controller X, or the mobile Pay button at the booth. Payment takes
   one second; the character then stands and moves into the aisle.
3. Walk down the aisle and through the glass front door. WASD/left stick moves;
   right mouse drag/right stick looks. V/right-stick click switches first-person
   and shoulder view. Touch players have directional buttons and drag-to-look.
4. The exterior sequence locks movement: damaged pickup arrival, panel van
   reveal, four masked crew, 1.5-second boarding, police, escape, banknote and
   title drop. Reduced Motion removes camera shake and speed-based FOV changes.
5. Drive west along Highway Four. WASD, left stick or RT accelerates; S reverses;
   Space/LT brakes. Right mouse drag, touch drag or the right stick rotates the camera; the mouse wheel zooms. V/right-stick click toggles the detailed cabin view with live patrol mirrors. Touch controls are provided. Gain 150 studs on the patrol
   for four seconds, then turn into OLD MOTOR DEPOT at the end of the route.
   Stop in its driveway to begin **No Loose Ends**. Being stopped near patrol
   for four seconds gives an interception screen with a retry action.
6. After the warehouse establishing shot, walk to the loading-bay latch and use
   E / controller X / the touch Use button. Open the doors, return to the van,
   drive inside the painted guides facing the back wall, brake and use E to park.
7. Carry two duffels from the rear cargo doors to the marked pallet. Two crew
   members carry the other bags; two guard the entrance. Shift / left-stick click
   / the touch Run button sprints while empty handed; carrying a bag slows you.
8. Once all four bags are inside, close the loading doors from the interior latch
   and operate the light switch. The search patrol returns after 70 seconds.
   Failure retries at the parked van, with fresh cargo and timer. Success plays
   three short patrol/interior/cash shots before the chapter-complete panel.

The opening retains noon lighting. The new exterior sequence shifts to sunset
following the Part 2 notes. The black panel van uses the supplied vintage van as
inspiration, replacing the generic secondary car mentioned in the screenshot.

## Audio and validation limits

EscapeAudio.assets exposes engine, siren, skid, bell, door, bass and wind slots.
Engine/siren/skid/wind are intentionally empty until permitted experience-owned
Roblox audio IDs are supplied. Bell/door/title have built-in placeholder cues.
Dialogue uses optional Roblox AudioTextToSpeech, preloaded during scene loading,
with captions always available. Platform TTS permissions and timing need Studio
validation; these are not recorded actor performances.

Automated checks cover chapter timing, payment gating, doorway/road boundaries,
mission completion/interception, R15 runtime paths and cleanup. Rojo builds and
Luau compilation are also checked. The headless service doubles cannot validate
rendered camera composition, accessory alignment, touch layout or sound mixing.
Playtest those in Studio on desktop and a mobile viewport before publishing.
The R15 gait advances with distance and flexes knees, ankles, elbows and waist.
Crew members have separate boarding paths, bags and seats. Officers use a running
pose followed by a two-handed aim. The vehicle has a continuous roof, cabin,
steering wheel, speedometer and animated wheels. Mirrors render a limited set of
road/patrol copies at 12 Hz; they are rear-view displays, not full-world reflections.
The route includes dunes, sandstone shoulders, sagging telegraph wires, cacti,
and a timber stash house with a porch, water tank and rotating wind pump.
These are authored primitive models and kinematic driving, not final imported
vehicle meshes or a full tire/suspension physics simulation.

## Audio revision

Dispatcher/crew/server use different platform TTS voices and delivery rates;
dispatch adds equalization/compression. Quiet diner chatter and low static remain
under the news and hush when the emergency signal begins. Original procedural
WAVs and their generator are in assets/audio; upload those to Roblox and configure
DinerAudio.assets to replace the platform fallbacks. TTS is still synthetic,
not an original actor performance. EscapeAudio.recordings supports later licensed
or original recordings. No audio from the reference videos is included.

## Reference access

Both TikTok URLs and the YouTube Short supplied on 2026-10-17 were blocked by the
execution environment's HTTP proxy (403). Their contents were not viewed. The
changes above use the user's written notes and supplied screenshots; video-specific
handling adjustments await accessible clips.


### NPC hair, R15 pose and patrol follow-up

- Scene characters now solve their R15 joint tree and attached garments after
  each rendered model move. This includes reversed accessory welds. Scene parts
  are anchored and joints disabled so physics does not overwrite the authored
  walk, run, seated and aiming poses. Live player rigs are not modified by this
  scene-only solver. A separate live R15 animation layer now handles grounded
  gait without anchoring the live avatar or overriding airborne/action tracks.
- Hair crown, temples, rear panel, bun and headwear fit each NPC head's dimensions.
- Patrol arrival follows two tangent quarter-circle turns with distance-based
  wheel rotation, front wheel steering and final braking. Drivers stay seated
  until stopping, open their doors, step out and approach on foot. Pursuit uses
  bounded steering and forward motion instead of direct diagonal translation.
- Studio checks still required: inspect all diner customers and workers from
  front/side/rear; observe crew and player knees/boots over several strides;
  watch both cruisers turn and stop, then both officers exit and approach. Check
  garments and facial features follow joints throughout, including at low FPS.
  Automated tests cover transforms and path continuity, not final visual quality.


### Supplied narration and driving references

Follow `assets/audio/README.md` to activate the supplied Robert MP3 with a Roblox
asset ID. Verify the report is continuous across all four camera/caption sections
and static begins only after it finishes. Test a missing/denied asset: captions
and gameplay must still proceed, with an Output warning.

In the driving section test L / D-pad left / Lights, and B / D-pad right / Wipers.
Click both dashboard switches in cabin view with the mouse. Turn wipers off
mid-sweep and confirm they finish the sweep and park. Test gradual steering and
return-to-center at low and high speeds, reverse wheel motion, cabin arm movement,
and reduced-motion camera behavior. See `docs/video-reference-review.md` for the
specific reviewed sequences and the boundaries of the changes.


### New warehouse and animation playtest

- Confirm normal walk and Shift sprint have different stride, knee lift and torso
  lean. Check idle, dine, alarm reaction, boarding, bag carry and placing poses.
- Check the wardrobe idle and live R15 avatar after respawning. Jump/fall, sit,
  equip a tool and play an Action-priority track; the live gait must yield.
- First-person mode should retain hands/body and hide the head and all attached
  face/hair/hat pieces. Toggle back and confirm every hidden part is restored.
- Orbit during driving and on foot with mouse, right stick and touch. Check barn
  camera clearance, the porch roof and the van cabin. Cinematic shots intentionally
  control framing; interactive sections allow camera rotation.
- Approach each warehouse target out of range and press E: no action should fire.
  Repeat E during opening, boarding or lifting: no duplicated actions or bags.
- Drive slowly through the open loading bay and try turning against its frame.
  The full van footprint is bounded. Braking and forward alignment are required
  before parking. Walk around the van, workbench, crates and cash pallet.
- Let the 70-second timer expire once; retry the warehouse. Verify fresh cargo,
  open doors, lights on, a new timer and the parked van. Then complete the mission.
- Repeat success and failure in first person and confirm result buttons have a
  usable mouse cursor. Exit the chapter and re-enter to check cleanup.

The depot uses the existing kinematic local chapter controller; it does not add
server-authoritative multiplayer missions or persistent checkpoints. The retry
checkpoint lasts for this chapter session. Geometry and controls still require
visual Studio and mobile-device validation. Engine/siren/skid recording slots
remain unconfigured; no reference-video soundtrack was imported.

### Period patrol and diner cleanup

- At the payment table, confirm there are four smaller windows beside the booth
  seats. The front wall should be solid cream plaster above walnut paneling,
  with only the existing glass entrance. Check the entrance still opens and
  the smaller windows show the side parking lot and nearby lodge.
- Walk outside and inspect the lot and rear alley: no dunes or sandstone should
  intersect the paving, pickup, van or arrival lanes. Distant landforms remain.
  The pickup's light gray radiator steam should start after braking and leave
  its body readable.
- Watch both black period sedans follow the west paved service approach. They
  should turn with their front wheels, brake to separated stops and retain their
  seated drivers until stopped. Look for one red rotating beacon per car, round
  headlights, chrome grilles, split windscreens and NORTH COUNTY lettering.
- In the closer arrival shots, inspect the officers' navy uniforms and peaked
  caps inside the open cabins. Doors must swing outward. Officers should duck
  through the opening, stand outside, then run along separate routes around the
  cars and stop to cover the abandoned truck. Check hats, knees, boots and door
  edges from the camera angles at both 30 and 60 FPS.
- The arrival lasts 16 seconds, with five compositions covering driving, braking,
  exiting, running and truck inspection. Confirm the dispatch captions remain
  legible and Reduced Motion removes shake. Skid/siren audio still requires
  configured assets; this change aligns the cue timing, not the recordings.
- Finish the chase and warehouse again. Confirm the same period cars appear in
  mirrors and the warehouse patrol, and returning to the menu removes the set.
