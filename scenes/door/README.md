# Door repairs

Stand grounded inside the door interaction zone and press E. A repair freezes the player for `Door.repair_duration` (default one second), then consumes one plank and restores `hp_per_plank` (10 HP), capped at maximum health. No repair starts when the door is full or destroyed, the player is climbing/repairing, or no plank is available.

Player exposes `repair_animation` (default `repair`) and `repair_animation_reference_duration` (default one second). Add that animation to the player's AnimationPlayer; its playback speed adjusts to repair duration. Until then, the player uses RESET while stationary. Rung/dash input cannot interrupt repair. Pause freezes its progress; game over or a removed door cancels without spending a plank. Completion rechecks resource availability and that the player is still in range.

Doors have 90 base HP and 135 with Door+. Enemy damage is applied throughout repair, so repairs cannot revive a broken door.

The door AnimationPlayer contains a one-second `repair` animation: Hammer appears at three positions (upper left, middle right, lower left) and swings around its handle at each spot. Playback scales with repair_duration. The hammer is hidden at idle, completion and cancellation; gameplay pause also pauses its animation. Edit the position/rotation tracks in the door scene to tune the strikes.
