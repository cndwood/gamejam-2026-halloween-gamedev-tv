# Uninvited audio and menus

The project still starts `scenes/game.tscn`. Its `GameMenu` displays the title
screen and pauses gameplay until Start and the first-session tutorial are completed. Restart starts a new run
immediately; Main Menu reloads the game into the title screen.

## Assigning audio

Open `music.tscn` and select its root Music node. Assign your music file to
`background_music`. Music starts when Start is pressed, persists across scene
reloads, and repeats when the track finishes. Monster Promenade is assigned as the permanent background track.

The inherited effect scenes below already have streams assigned. Select their
root AudioStreamPlayer to replace the Stream:

| Scene | Trigger |
| --- | --- |
| `explosion_sound.tscn` | Pumpkin explosion |
| `door_hit_sound.tscn` | Door loses HP |
| `repair_sound.tscn` | Door gains HP from a plank |
| `skeleton_death_sound.tscn` | Skeleton dies (trimmed crumble clip in resources/audio/sounds already assigned) |
| `interact_sound.tscn` | Pumpkin-machine deposit/pickup or completed cannon reload |
| `cannon_sound.tscn` | Cannon fires |
| `planks_interact_sound.tscn` | Plank machine deposit or pickup |
| `crystal_interact_sound.tscn` | Crystal collector pickup |

Use non-looping clips for these effects so they free themselves after playback.
The shared `one_shot.tscn` is reusable for additional sounds. Instances are attached
to the Music singleton, so the effect survives destruction of its source and
can overlap other effects. Effects finish even when the game-over screen pauses
gameplay. Empty stream slots safely produce no sound or extra instances.

Master, Music, and SFX buses are in `default_bus_layout.tres`. Options changes
apply immediately and save to `user://audio_settings.cfg`. Defaults are Master
100%, Music 30%, SFX 15%, unmuted. Browser storage must be available for settings
to persist across visits.

## Menu controls and graphics

Escape pauses/resumes gameplay or returns from Options. Mouse clicks, Tab,
Up/Down, and Enter/Space operate buttons. Left/Right adjusts a focused volume
slider. Options is available from the title, pause, and game-over screens.

The menus already work with placeholder controls. Optional artwork: a title logo
reading "Uninvited", a title background, scalable panel art, and button states
(normal, hover, pressed, keyboard focus). Options also needs slider track/grabber
and mute-toggle artwork if you want a custom theme. Keep text separate from button
textures. All menu controls are in `scenes/ui/game_menu.tscn`.

## Web export

`export_presets.cfg` includes a single-threaded Web preset targeting
`build/web/index.html`. Web builds use the Compatibility renderer and hide Quit.
Desktop rendering remains Mobile. Start provides the user interaction needed to
allow browser audio playback; music is not autoplayed before that interaction.

Install matching Godot 4.7.2 export templates in the editor, export using Web,
and serve the resulting folder through an HTTP server or upload it to your game
host. Preserve all exported filenames and companion files. The current controls
assume a keyboard for gameplay; touch-only movement buttons are not implemented.

## Audio library and credits

The shipped background track is `resources/audio/music/Monster Promenade.mp3`. Unused music and downloaded sound packs were archived outside the project during release cleanup.

The trimmed skeleton death effect is at
`resources/audio/sounds/Spawn - Crumble_trimmed.wav`. The original untrimmed clip
was removed. Public-facing attribution and the itch.io page draft are in the root
`README.md`, including the source link for Cyberwave Orchestra's Fantasy Spawn
Sound Effects.

## Distance attenuation

All gameplay effects, including machine interactions, cannon reloads and repairs, use the source's world position. Their volume falls linearly from full effect volume at the player to silence at 140 world pixels. Volume updates during playback as the player moves. Player registers in the `audio_listener` group. Each one-shot exposes `max_distance` for future tuning.

Distance always uses the player node, never the camera. `Music.play_effect` requires a world position for every effect; background music keeps its configured bus volume. Selected clips live in `resources/audio/sounds`; original downloaded packs and previews are archived outside the project.

## Climbing and production

`climb_sound.tscn` plays a wooden footstep at climb start and once per `Player.climb_sound_spacing` (default 12 world pixels), so faster climbing automatically increases the cadence. Sounds stop being emitted at climb completion.

`pumpkin_ready_sound.tscn` and `planks_ready_sound.tscn` play once per successfully produced batch, at the machine's world position. Empty or capacity-blocked machines emit no completion sound. All three use the same player-distance attenuation and SFX bus as other effects.

Game over fades the background behind the menu to solid black over one second, including while gameplay is paused. The cue uses Kenney Music Jingles `jingles_PIZZI07` (1.324-second descending pizzicato phrase) with no random pitch variation, emitted at the player's world position and routed through SFX.
