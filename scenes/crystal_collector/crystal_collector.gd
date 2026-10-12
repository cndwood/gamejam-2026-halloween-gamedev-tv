class_name CrystalCollector
extends Area2D

@onready var collection_point: Marker2D = $CollectionPoint
@onready var collection_point_2: Marker2D = $CollectionPoint2
@onready var progress: TextureProgressBar = $TextureProgressBar
@onready var interact_trigger: InteractTrigger = $InteractTrigger

var max_capacity = 20
var collected_crystals = 0
@export_range(0.1, 10.0, 0.1) var min_duration: float = 2.0
@export_range(0.1, 10.0, 0.1) var max_duration: float = 4.0
@export_range(0.1, 0.9, 0.05) var flight_time_fraction: float = 0.6

func _on_area_entered(area: Area2D) -> void:
	var crystal: Crystal = area as Crystal
	if crystal and not crystal.collected:
		crystal.collected = true
		collect(crystal)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and interact_trigger.interactable:
		var added = interact_crystals()
		Game.add_crystals(added)

func collect(crystal: Crystal):
	var duration = randf_range(minf(min_duration, max_duration), maxf(min_duration, max_duration))
	var flight_duration = duration * flight_time_fraction
	var slide_duration = duration - flight_duration
	# Match the collector's layers even when its parent has a custom draw order.
	crystal.z_as_relative = false
	crystal.z_index = get_effective_z_index() + 1
	var tween = create_tween()
	tween.tween_property(crystal, "global_position", collection_point.global_position, flight_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(crystal, "global_position", collection_point_2.global_position, slide_duration).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	if not is_instance_valid(crystal):
		return
	collected_crystals = clampi(collected_crystals + crystal.value, 0, max_capacity)
	crystal.queue_free()
	update_ui()

func get_effective_z_index() -> int:
	var result := z_index
	var item := self as CanvasItem
	while item.z_as_relative:
		item = item.get_parent() as CanvasItem
		if item == null:
			break
		result += item.z_index
	return result

func update_ui():
	progress.value = float(collected_crystals) / float(max_capacity)

func interact_crystals():
	var take_crystals = collected_crystals
	if take_crystals > 0:
		Music.play_effect(&"crystal_interact", global_position)
	collected_crystals = 0
	update_ui()
	return take_crystals
