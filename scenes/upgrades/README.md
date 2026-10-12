# Upgrade pedestals

Instance `upgrade_pedestal.tscn` and choose its `upgrade` enum in the Inspector. `Pedestal` uses pedestal.png and `UpgradeIcon` uses upgrade_script.png. Replace either Sprite2D texture to change the art. The icon floats around its authored position; `hover_height` and `hover_speed` are adjustable. Move LabelAnchor to set the text attachment point, and resize the InteractTrigger collision shape to fit your artwork. Labels render in a CanvasLayer at a fixed 24px font size, outside camera zoom; their screen positions are rounded to whole pixels. Change label_font_size in multiples of 8 for this pixel font. The prompt uses compact ASCII text (E: cost) to avoid missing glyphs and overlapping labels.

The included `upgrade_shop.tscn` contains all six types and is placed in the game's basement. Stand near one and press E. The label shows a short name and crystal cost, then Owned after purchase. Each type can be bought once per run. Costs and labels are defined in `scenes/globals/game.gd`.

| Upgrade | Label | Crystals | Effect |
| --- | --- | --- | --- |
| Dash | Dash | 6 | Unlocks Shift dash; locked by default |
| Plank speed | Saw+ | 8 | Production 6 → 4.5 seconds |
| Cannon speed | Rapid | 10 | Fire interval 1.5 → 1.125 seconds |
| Cannon damage | Blast+ | 14 | Explosion damage 1 → 2 |
| Door health | Door+ | 10 | Both doors 90 → 135 max HP; grants the added 45 current HP |
| Pumpkin speed | Grow+ | 8 | Production 4 → 3 seconds |

Effects apply globally to all relevant objects, including newly instantiated ones. In-progress production preserves its completion fraction when upgraded. Cannon damage is captured when a projectile is fired. New-run reset clears purchases; reloading the game restores base stats. A duplicate pedestal reflects ownership of the same upgrade and cannot charge twice. Purchase cues use source-to-player distance and the SFX setting.
