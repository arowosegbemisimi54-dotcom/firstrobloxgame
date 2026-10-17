# Shirts and Skins

An original cinematic Roblox crime-adventure project by **MHIDE**. This build implements character creation, the opening, the Story Mode menu, and a starter wardrobe. The supplied diner opening is playable as a cinematic; later missions and combat are not implemented yet.

## Run in Roblox Studio

1. In GitHub Desktop, select `firstrobloxgame`, click **Fetch origin**, then **Pull origin**.
2. If Rojo is already serving this repository, it watches the updated files automatically. Otherwise open PowerShell in the repository folder and run (adjust the executable path if needed):
   ```powershell
   & "$env:USERPROFILE\Downloads\rojo-7.7.1-windows-x86_64\rojo.exe" serve
   ```
3. In Studio, set **Avatar Settings → Avatar Type** to **R6** and save it. Open the saved game and connect **Plugins → Rojo** to `localhost:34872`. Review the initial sync. The project maps only `GameServer`, `GameShared`, and `GameClient`; it does not map your Workspace, terrain, or saved lighting.
4. Click **Play**, not Run. Local scripts and the interface need a player. Stop and restart Play after script changes to avoid duplicate menus from live editing.
5. Choose a character name, Boy/Girl, and personality. Then the black opening shows **Story Mode**, followed by **Online**, with clicks. Choose Story Mode for the sunset loading screen, then the existing five-second counter-clockwise desert camera orbit. Select **Play → Begin Story** for the diner opening; use **Next shot** or **Skip opening** at any time.
6. Test before publishing. GitHub pulls and Rojo syncs do not publish a live Roblox game.

Keep PowerShell open during sync. Edit synced scripts in the repository, not inside Studio; Rojo can overwrite Studio edits to mapped objects. The root configuration uses UTF-8 without a BOM.

## Included

- Character creation: 2–24 character name (duplicates allowed except reserved Mhide), Boy/Girl, and Friendly/Serious/Mysterious/Funny personality. Names are filtered on the server.
- Side-by-side, staggered opening choices on black, one second after character creation finishes.
- Client-only desert set: one camper, extended awning, tent, table, rounded cacti, continuous triangulated sandstone ridges, sand drifts, and smoke. Its distant position keeps it separate from the Studio map.
- A weathered highway, abandoned LAST STOP gas station with boarded windows and old pumps, roadside signs, and sagging utility lines.
- Slow tumbleweeds enter at randomized 2–4 second intervals (normal effects), using a reusable pool of four. Low effects allows only one active weed, so appearances may be farther apart; reduced motion freezes rolling. Updates pause on the black mode-selection screen.
- Sunset lighting, slow camera orbit, cinematic bars, typewriter lettering, and a prominent Play link with smaller text-only menu links beneath it without list numbers. Each link opens a separate page over the existing scenery. Rendering uses ordinary parts and no external model assets.
- Play: Solo, Duo, or Squad (up to four); roster and leader-controlled capacity.
- Invite: same-server party invitations with accept/decline, expiry, capacity checks, and leader transfer. Roblox friend invitations use the platform prompt when available; joining via a friend invitation does not automatically put someone in a party.
- Settings: menu sound, reduced camera/profile motion, and low effects. These settings last for the current session.
- A direct **Back** button returns to the black Story Mode / Online screen. Options also includes a return control.
- Animated circular Roblox avatar portrait; **Be Inspired** is directly underneath **Developed by MHIDE**.
- Separate wardrobe page: live, gently animated character on the left; visual 3D item cards on the right; drag/arrow controls for 360° rotation; short smoke puff on successful selection; 0.5-second cooldown enforced on both client and server.
- Original procedural western starter outfits with different boy/girl shirt colors and denim details, brown boots, and an optional cowboy hat. The same geometry is applied to the actual avatar and previews.
- Costume, Top, Bottom, Hat, Shoes, and Critter tabs. Starter garments and hat/no-hat are selectable. The bird costume has been removed. Locked costumes are hidden; the dog remains a locked story reward preview. Personality is retained in character data but not shown in the wardrobe.
- Quick setup/page slide transitions with a soft movement sound; validation messages replace permanent setup side notes.
- Sunset loading screen: 0–100% reflects completed scene-preparation jobs, with a rotating tumbleweed widget.
- Local R6 diner opening: the player and two other customers, waitress, chef, meal props, eating/working motion, 2.5-second camera glide, and two closer shots. Next-shot and whole-opening skip controls restore the desert menu and clean up the diner.
- Mouse, touch, and selectable gamepad buttons; adaptive portrait layout.

## Deliberately unfinished

**Online** explains that the mode is coming later. **Begin Story** plays the diner opening locally when StoryPlaceId is zero; the crew leader triggers it for party members, each seeing their own avatar at the booth. The scene ends back at the menu because no later plot has been supplied. The shop has its own placeholder page; purchases and story reward unlocks are not implemented. Character details and clothing are retained in this server session and reapplied on respawn; they are not saved across rejoining or teleports yet. Personality is stored for future gameplay but has no story effects yet. Vehicles, weapons, dogs, heists, dialogue choices, and gameplay animation are future milestones.

When actual destinations exist, set `OnlinePlaceId` and `StoryPlaceId` in `src/shared/Config.luau` to published **place IDs** within this experience. Keep them at `0` until then. The server uses a reserved server for a story party. Teleports must be tested in the published Roblox client, not Studio. Do not point a destination back to this menu place, which would loop the player back to the opening.

Names are checked through Roblox TextService. A filtering outage in a published game blocks creation and offers retry. If filtering is unavailable in Studio, a safe **Studio Explorer** placeholder lets the rest of the flow be tested; the UI explains this. No unfiltered name is published. R6 is the intended character rig; final fit, idle animation, clothing appearance, and item-card framing need Studio validation.

The character name **Mhide** is reserved server-side, ignoring letter case and whitespace. For a user-owned experience, the owner is permitted automatically. For a group-owned experience (or a different developer account), set the numeric `DeveloperUserId` in `src/shared/Config.luau`; leaving it at zero on a group-owned experience denies the reserved name to everyone.

## Files

- `src/client/Main.client.luau`: opening, camera, UI, input, and menu interactions.
- `src/client/DesertScene.luau`: camper, vegetation, and temporary lighting.
- `src/client/DesertDetails.luau`: triangulated mountains, road, gas station, and pooled tumbleweed animation.
- `src/server/PartyService.server.luau`: authoritative party management and destination travel.
- `src/client/StoryLoading.luau`: sunset loading and preparation progress.
- `src/client/PageMotion.luau`: cancelable page transitions.
- `src/client/DinerOpening.luau`: local diner, R6 cast, motion, camera shots, and cleanup.
- `src/shared/DinerTimeline.luau`: camera shot durations and skip rules.
- `src/client/CharacterFlow.luau`: name, character, and personality steps.
- `src/client/Wardrobe.luau`: visual wardrobe, rotation, smoke puff, and item cards.
- `src/server/CharacterService.server.luau`: name filtering, authoritative session profile, and clothing validation.
- `src/shared/CharacterCatalog.luau`: available items, locked items, and selection rules.
- `src/shared/WesternOutfit.luau`: shared outfit geometry used by avatars and previews.
- `src/shared/Config.luau`: timing, sound, and future destination IDs.
- `src/shared/PartyRules.luau`: invitation and capacity rules.

The menu currently holds the player's camera and movement until travel. This is intentional for the menu/cinematic place; free-roaming missions are not implemented yet. Roblox's system menu remains available.

## Validation

Command-line checks:

```sh
rojo build default.project.json -o /tmp/shirts-and-skins.rbxlx
python3 tests/run.py /path/to/luau
```

Character tests exercise the actual server source with service doubles: name validation/filter failure, duplicate names, identity choices, locked items, forged requests, isolated inventories, cooldown, and developer-name reservation. Diner timeline tests cover the 2.5-second glide, per-shot skipping, whole-scene skipping, and completion. A service-double integration test exercises diner construction, five-actor cast, R6 joint changes, and skip cleanup. These checks do not replace Studio animation or visual inspection. The party tests run the actual server source with service doubles. The scenery tests run the detail module with lightweight geometry doubles and check a two-minute spawn simulation, object budgets, reduced-motion behavior, hidden-screen pauses, and cleanup. These do not validate rendered appearance. They cover capacity, leadership, invitations, expiry, disconnects, and destination gating; they do not replace Roblox engine testing. Compile scripts using `luau-compile` if installed. Plain `luau-analyze` needs Roblox type definitions to understand engine globals.

Required Studio acceptance checks:

- Play: test each character-creation step, Back navigation, duplicate names in two clients, and invalid-name responses. Verify the black opening, click timing, five-second orbit, menu fade, van framing, and readable text.
- Exercise every menu button; confirm unavailable features show explanations rather than errors.
- Test desktop, portrait/landscape device emulation, and gamepad navigation. Check the Output window for errors.
- Use Studio's multi-client server test with 2–4 players. Set Duo/Squad, invite, accept, decline, leave, disconnect the leader, and try joining a full party.
- Toggle sound, reduced motion, and low effects. Watch tumbleweeds for at least 30 seconds and verify sparse, slow motion.
- Use **Back** and re-enter Story Mode repeatedly: the opening must be black, each intro must last five seconds, and scenery must not duplicate.
- Check the station and mountain silhouettes during the orbit; verify the stacked credits and unnumbered text-only links at desktop and mobile sizes.
- Open each menu link: only its page should appear, with the same scenery behind it. Back must restore the home menu.
- Open the profile: inspect both starter outfit variants, hat/no-hat, accurate item cards, 360° drag and arrow rotation, brief smoke puff, half-second cooldown, and empty costume inventory and locked-dog feedback. Reset the character and confirm the session outfit is reapplied.
- Set R6, verify starter clothing and preview rotation, and start the diner. Inspect the player plus two customers, two workers, seated leg poses, eating/working gestures, meal framing, and camera movement. Try next-shot, whole-opening skip, repeated replays, and natural completion; camera and menu must recover each time.
- Check progress reaches 100%, slides do not drift after resizing, setup help text is absent, and only the permitted account can create Mhide (including mixed-case/spaced attempts).
- Check performance on an actual lower-powered device. Rendering quality and sound behavior have not been verified in this cloud workspace, which cannot run Roblox Studio.
