# Cannon refilling

Press E inside the ammo-box interaction zone with at least one pumpkin and room for five bullets. The player remains stationary for refill_duration (default 0.5 seconds), throwing a visual pumpkin along an arc into RefillPoint. It rotates exactly twice in the direction of travel. At arrival, one pumpkin is consumed and five bullets are added; the interaction cue and progress bar update then.

Move RefillPoint in the cannon scene to align with your box opening. refill_arc_height controls the arc (default 18 pixels). The throw uses the player's held pumpkin texture and has no gameplay collision or explosion. The cannon can keep firing during refill. Climbing, dashing, repairing and duplicate refills are blocked during the throw. Pause freezes it; game over cancels without spending a pumpkin. The held item is hidden during the throw and restored afterward.
