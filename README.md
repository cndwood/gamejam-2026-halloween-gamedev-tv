# Uninvited

The skeletons weren't invited. Keep them outside.

**Uninvited** is a pixel-art Halloween defense game. Race between two doors, keep pumpkin cannons loaded, turn crystals into supplies, and repair the house as increasingly dangerous waves arrive. Survive as many waves as you can; if either door breaks, the run ends.

Play with a keyboard and mouse. On your first **Start**, a three-page tutorial explains the controls and supply loop while gameplay is paused. **Try Again** starts a fresh run without repeating it. **How to play** is available from the title, pause, and game-over menus.

## How to play

1. **Defend both doors.** Cannons aim and fire automatically. Watch their ammo bars and the doors' health bars.
2. **Gather crystals.** Defeated skeletons drop crystals. Collectors pull them in and slide them down; press E at a collector to pick them up.
3. **Make supplies.** Press E at a machine's crystal input to deposit up to three crystals. Each crystal produces two pumpkins in four seconds, or three planks in six seconds. Press E at the output to collect the finished supplies.
4. **Reload.** Stand by a cannon's ammo box and press E. A half-second throw consumes one pumpkin and adds five shots. There must be room for all five shots.
5. **Repair.** Stand grounded near a damaged door and press E. After one second, one plank restores 10 HP, up to the door's maximum. Repairing and reloading lock movement; Escape pauses their timers. There is no manual cancellation key.
6. **Upgrade.** Spend crystals at the basement pedestals. Each upgrade can be bought once and applies to all matching machines or doors for the current run.

Doors start with **90 HP**. Cannons start loaded with **20 shots** each. The ladder alternates between floors and starts upstairs, so its first use goes down; catching it partway through a jump shortens the remaining climb. The held item shows the last resource picked up, with wood shown during repairs.

Waves use random entrances, batch sizes, spawn gaps, and movement speeds. They grow in size and strength, with shorter recovery breaks. Game over shows the wave reached and waves cleared. New runs reset resources, upgrades, doors, and wave counts.

## Controls

| Input | Action |
| --- | --- |
| A / D or Left / Right | Move |
| Space | Jump |
| S or Down | Drop through one-way floors |
| E | Pick up, deposit, reload, repair, use the ladder, or buy an upgrade |
| Shift | Dash after buying Dash; uses movement or facing direction |
| Escape | Pause / resume; return from Options |
| Mouse | Select menu buttons and adjust sound settings |
| Tab or Up / Down | Select menu controls |
| Enter / Space | Activate the selected menu button |
| Left / Right on a slider | Adjust volume |

## Upgrades

| Label | Crystal cost | Effect |
| --- | --- | --- |
| Dash | 6 | Unlock Shift dash |
| Saw+ | 8 | Plank production: 6 → 4.5 seconds |
| Rapid | 10 | Cannon firing interval: 1.5 → 1.125 seconds |
| Blast+ | 14 | Cannon damage: 1 → 2 |
| Door+ | 10 | Both doors: 90 → 135 maximum HP; adds 45 current HP |
| Grow+ | 8 | Pumpkin production: 4 → 3 seconds |

## Sound and menus

Options provides Master, Music, Sound Effects, and mute controls. Defaults are **100% Master, 30% Music, 15% SFX**. Settings save locally when browser storage is available. Music begins after Start and loops. Gameplay sounds fade with distance from the player, becoming silent at 140 world pixels.

## Credits

### Music — Kevin MacLeod

**"Monster Promenade" — Kevin MacLeod (incompetech.com)**. Used as the looping background track, unmodified.

Source: [Monster Promenade on Incompetech](https://incompetech.com/music/royalty-free/index.html?isrc=USUAN1100478). Licensed under [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).

### Sound effects — Cyberwave Orchestra

[**Fantasy Spawn Sound Effects** by **Cyberwave Orchestra**](https://cyberwave-orchestra.itch.io/fantasy-spawn-sound-effects).

The skeleton death effect uses **"Spawn - Crumble"**, edited to use the segment
from **0.4 to 1.0 seconds** of the original recording. Used as a skeleton death
sound in Uninvited.

Creator: [Cyberwave Orchestra](https://cyberwave-orchestra.itch.io/).
Sound effects retain their creator's licensing terms; they are separate from the
Creative Commons music credits above.



### Sound effects — NIIIEMAND and Kenney (CC0)

| Creator / pack | Original clip | Used for |
| --- | --- | --- |
| [NIIIEMAND — Explosion SFX](https://niiiemand.itch.io/niiiemands-explosion-sfx) | `explosion-01` | Pumpkin explosion |
| NIIIEMAND — Explosion SFX | `explosion-09` | Cannon firing |
| [Kenney — Interface Sounds](https://kenney.nl/assets/interface-sounds) | `click_001` | Pumpkin-machine interactions and cannon reloads |
| Kenney — Interface Sounds | `confirmation_001` | Pumpkin production completion and upgrade purchases |
| Kenney — Interface Sounds | `pluck_001` | Plank production completion |
| [Kenney — Impact Sounds](https://kenney.nl/assets/impact-sounds) | `impactWood_medium_001` | Plank-machine interactions, door hits and repairs |
| Kenney — Impact Sounds | `impactGlass_light_000` | Crystal-collector interactions |
| Kenney — Impact Sounds | `footstep_wood_000` | Ladder climbing steps |
| [Kenney — Music Jingles](https://kenney.nl/assets/music-jingles) | `jingles_PIZZI07` | Game-over cue |

These recordings are licensed under [Creative Commons Zero (CC0)](https://creativecommons.org/publicdomain/zero/1.0/).
Selected recordings are unmodified; filenames were changed for the game. Kenney's included license notices are retained in `resources/audio/sounds`.

## Font credits

[**Quaver** by **Nathan Scott / Caffinate**](https://caffinate.itch.io/quaver), used for the game's UI. Copyright © 2021 Nathan Scott. The creator's current page lists CC0; the bundled font's metadata names [CC BY 3.0 Australia](https://creativecommons.org/licenses/by/3.0/au/). Attribution is included for this copy. Font file unmodified.

## Engine

Built with [Godot Engine](https://godotengine.org/). Its MIT license and contributor notices are included in [Godot-License.txt](docs/Godot-License.txt), with bundled component notices in [Engine-Third-Party-Licenses.txt](docs/Engine-Third-Party-Licenses.txt). Audio licenses apply to the credited recordings; they do not license the game's source code or original artwork.

## Development and Web upload

Open `project.godot` in **Godot 4.7.2** and run the project. The main scene remains `scenes/game.tscn`. Artwork sources are retained; temporary audio packs and unused music candidates have been archived outside the project. Only the selected background track and effects remain in the game audio folders.

A single-threaded **Web** preset and [export helper](tools/export_web.py) are included. Install matching export templates, then run:

```sh
python3 tools/export_web.py --godot /path/to/Godot
```

This creates `build/uninvited-web.zip`, with `index.html` at the root and README/credit notices alongside the game files. It does not upload or publish anything. See [release instructions](docs/RELEASE.md) for local HTTP preview, itch.io setup, and browser checks. Matching export templates are installed. Web startup has been tested in Chrome over local HTTP; complete the release checklist before publishing.
