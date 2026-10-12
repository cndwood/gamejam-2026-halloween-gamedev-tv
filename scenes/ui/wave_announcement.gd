extends CanvasLayer

@export_range(0.05, 1.0, 0.05) var pop_duration: float = 0.25
@export_range(0.1, 5.0, 0.1) var hold_duration: float = 1.1
@export_range(0.05, 2.0, 0.05) var fade_duration: float = 0.35

@onready var label: Label = $Screen/WaveText
var last_announced_wave: int = 0
var animation: Tween

func _ready() -> void:
	label.hide()
	Game.game_over.connect(clear_announcement)
	# Wave controller starts in _ready; bind after the game scene is ready.
	call_deferred("connect_spawners")

func connect_spawners() -> void:
	for spawner in get_tree().get_nodes_in_group("wave_spawner"):
		spawner.wave_started.connect(announce_wave)
		if spawner.wave_active:
			announce_wave(spawner.current_wave)

func announce_wave(wave_number: int) -> void:
	# Ignore repeated signals for a wave already displayed.
	if wave_number <= last_announced_wave or Game.is_game_over:
		return
	last_announced_wave = wave_number
	if animation != null:
		animation.kill()
	label.text = "WAVE %d" % wave_number
	label.pivot_offset = label.size * 0.5
	label.scale = Vector2(0.35, 0.35)
	label.modulate.a = 1.0
	label.show()
	animation = create_tween()
	animation.tween_property(label, "scale", Vector2.ONE, pop_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	animation.tween_interval(hold_duration)
	animation.tween_property(label, "modulate:a", 0.0, fade_duration)
	animation.tween_callback(label.hide)

func clear_announcement() -> void:
	if animation != null:
		animation.kill()
	label.hide()
