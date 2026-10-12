extends AudioStreamPlayer

@export_range(0.0, 0.5, 0.01) var pitch_variation: float = 0.05
@export_range(1.0, 1000.0, 1.0) var max_distance: float = 140.0

var positional: bool = false
var source_position: Vector2
var base_volume_db: float

func _ready() -> void:
	if stream == null:
		queue_free()
		return
	pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
	base_volume_db = volume_db
	set_process(positional)
	if positional:
		update_distance_volume()
	finished.connect(queue_free)
	play()

func _process(_delta: float) -> void:
	update_distance_volume()

func distance_gain(listener_position: Vector2) -> float:
	return clampf(1.0 - source_position.distance_to(listener_position) / max_distance, 0.0, 1.0)

func update_distance_volume() -> void:
	var listener := get_tree().get_first_node_in_group("audio_listener") as Node2D
	var gain := distance_gain(listener.global_position) if listener != null else 0.0
	volume_db = base_volume_db + linear_to_db(maxf(gain, 0.00001))
	# An exact zero ensures combat sounds are silent at and beyond the limit.
	if gain == 0.0:
		volume_linear = 0.0
