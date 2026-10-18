# October 18 reference review

All four user-provided files were downloaded from the shared Drive folder after
network access became available. The three videos remain outside the repository;
no video footage, music, models, textures or animation assets were copied.

Reviewed full-length contact sheets at two-second intervals, then selected
steering, running/turning and first-person sequences at quarter-second intervals.
These are observations of supplied video frames, not measurements of the other
games' source code or physical simulation.

| File | Duration | Observations used |
| --- | --- | --- |
| Download (2) (1) (1).mp4 | 50.20 s | Cabin view shows the steering wheel, hands, dashboard and windshield; during 25–31 s turns, wheel movement precedes/reverses with the turn and the cabin view tilts with the vehicle. |
| SECRET POLICE HEIST In Mad City CH1! - CeeJay (1080p) (1) (1) (1).mp4 | 20.69 s | During 5–10 s, a third-person running avatar alternates its legs and arm swing while turning; 12–14 s shows a nearby interaction prompt and progress feedback. |
| Download (1) (1) (1) (1).mp4 | 23.17 s | During 3–7 s, first-person hands/actions remain visible in the lower frame; sight lines, movement and action feedback remain readable. This is a combat reference; no new combat chapter or weapon system was added to the diner escape. |

Changes applied to the existing chapter:

- Smoothed steering rack input and return-to-center; a speed-sensitive road-wheel
  angle drives heading through wheelbase/turn radius instead of instant yaw.
- Dashboard steering wheel, front wheels and driver arm poses follow the same
  steering state; wheels roll backward when reversing.
- Modest acceleration pitch, cornering roll and road motion in cabin view;
  reduced-motion mode suppresses these camera effects.
- Headlight and wiper switches work with keyboard (L/B), gamepad (D-pad left/right),
  touch action buttons and mouse clicks on the physical dashboard in cabin view.
  Wipers finish their current sweep and park when switched off.
- R15 movement blends into and out of strides and smooths direction changes.
- Original user-supplied narration is stored with measured camera/caption timings.
  A Roblox upload and experience-permitted asset ID are still required to activate it.

Studio verification remains necessary for final hand-to-wheel alignment, camera
comfort, dashboard click targeting, hair/wardrobe rendering and audio permissions.
Automated tests cover mechanics and lifecycle behavior; they do not render Roblox.


## Additional animation and story references

The supplied animation tutorial **Tips On Exaggerating movement in Roblox
Animations** (34.73 s) was reviewed as a full contact sheet and transcribed.
Its useful distinction is a visibly wider leg swing, quicker recovery, and more
forward torso bend. These principles are now expressed through connected R15
hips/knees/ankles, counter-rotating waist/shoulders and role-specific arm poses.
No animation asset from the tutorial is used.

All five subsequently attached MP4s were inspected as full-length, two-second
contact sheets. Clip 3's 10–13 s run/turn sequence was also examined at four frames
per second. This is frame review, not a claim to have run those games.

| Attachment | Duration | Useful reference and resulting change |
| --- | --- | --- |
| 1 · v12044gd0000darl2hnog65r2vqec99g | 20.83 s | Furnished domestic spaces and practical lights: the depot now contains a workbench, hanging tools, oil tins, tires, lamps, floor guides and visible cargo. |
| 2 · v12044gd0000da385vfog65itmekevq0 | 19.67 s | Runaways driving/on-foot goals and pressure feedback: the chase has contact/interception status; arrival leads into contextual actions, cargo progress and a search timer. |
| 3 · v1c044g50000d9j3bgfog65p04d4uhsg | 38.87 s | Readable running silhouettes, corners, furnished routes and pursuit pressure: R15 sprint has stronger leg recovery/lean, carrying stabilizes an arm, and the warehouse has navigable clearances around the van and fixtures. |
| 4 · v09025g40000cmc6fv7og65jh8l15rug | 19.69 s | Repleh County police framing and roadside depth: getaway turns use tangent curves; patrols cross the warehouse frontage facing their movement, with a separate exterior shot. |
| 5 · v14044g50000cu4br6vog65vshhtg3s0 | 48.40 s | The Mimic's staged wide/medium/close shots and gesturing cast: the warehouse adds an establishing move, character actions and a three-shot patrol/interior/cash conclusion. |

The revised mission is **No Loose Ends**: open the bay, park facing the rear wall,
move the money, close the doors and kill the lights. Crew members visibly carry
half the cargo. Missing the search deadline retries at the warehouse. The player
keeps camera control during interactive steps and gets keyboard, gamepad and touch
bindings. First-person views retain the body/hands while hiding attached headwear.
The references' models, footage, music, UI art and character animations are not
included in the repository.

## Diner and patrol arrival references

The two additional attachments were reviewed as full-duration contact sheets
(three-second spacing for the first clip, two-second spacing for the second).
They are presentation references; neither clip shows the requested period police
arrival. The supplied sedan photograph and written directions guide that scene.

| Attachment | Duration | Observations used |
| --- | --- | --- |
| 1 · v15044gf0000d9r63r7og65gom9t6rig | 70.33 s | Game recommendation montage with furnished rooms, contextual interaction, a checkpoint and readable character/vehicle framing. Keep the approach lane, drivers, door actions and destination readable in separate shots. |
| 2 · v14044g50000d95uianog65k0k4bkjp0 | 33.79 s | Stylized carnival trailer with practical lights and alternating close and wide compositions. Use deliberate framing changes and restrained lighting accents in the patrol sequence. |

Applied changes:

- Original late-1940s-inspired black patrol sedans replace the generic coupes.
  Rounded hood/fenders, split glass, chrome trim, thin whitewalls, manual window
  cranks, a dash radio and a single rotating red beacon follow the period brief.
  The cabins are open inside; both front doors are separate models. Markings are
  fictional NORTH COUNTY units 41 and 42.
- The 16-second arrival now has road tracking, a service-lane wide shot, braking
  and door coverage, an officer approach and a final truck inspection angle.
  The existing radio dispatch line remains intact. Front-wheel steering follows
  each turn, brake lamps and the configured skid cue follow deceleration, and
  the doors swing outward only after stopping. Drivers wear navy uniforms and
  peaked caps. Their R15 exit/run paths pass around the stopped sedans.
- A paved west service approach and larger stopping gap accommodate the longer
  cars. Terrain bounds exclude the whole diner lot, truck approach, patrol lanes,
  highway and depot. Distant dunes remain; no sand forms overlap the truck.
- Four smaller booth windows remain. The front has cream plaster, walnut lower
  panels and the existing glass entrance. The kitchen, booths, radio, paintings,
  condiments and hanging lights are retained. Radiator steam is lighter and
  starts after the pickup brakes rather than obscuring it throughout the scene.

No reference footage or soundtrack is shipped. Automated checks cover transformed
terrain bounds, cabin clearance, vehicle separation, steering direction, exit
continuity and the complete chapter. Rendered composition and final R15 clearance
still require the Studio checks in `highway-four-playtest.md`.
