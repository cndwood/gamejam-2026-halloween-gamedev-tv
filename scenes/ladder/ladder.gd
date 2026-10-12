class_name Ladder
extends Node2D

enum FloorState { UPSTAIRS, DOWNSTAIRS }

# Time for a full marker-to-marker traversal, before player upgrades.
@export_range(0.05, 10.0, 0.05) var climb_duration: float = 2.0
@export var floor_state: FloorState = FloorState.UPSTAIRS

@onready var interact_trigger: InteractTrigger = $InteractTrigger
@onready var top_exit: Marker2D = $TopExit
@onready var bottom_exit: Marker2D = $BottomExit

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		use_ladder()

func use_ladder() -> bool:
	if not interact_trigger.interactable:
		return false
	for body in interact_trigger.get_overlapping_bodies():
		if body is Player:
			return climb_player(body)
	return false

func climb_player(player: Player) -> bool:
	if player.is_climbing:
		return false
	var destination := bottom_exit if floor_state == FloorState.UPSTAIRS else top_exit
	var full_distance := absf(top_exit.global_position.y - bottom_exit.global_position.y)
	var remaining_distance := absf(player.global_position.y - destination.global_position.y)
	var duration := climb_duration * remaining_distance / maxf(full_distance, 1.0)
	if not player.start_climb(destination.global_position, duration, climb_duration):
		return false
	player.climb_finished.connect(_on_climb_finished, CONNECT_ONE_SHOT)
	return true

func _on_climb_finished(destination: Vector2) -> void:
	floor_state = FloorState.UPSTAIRS if destination.is_equal_approx(top_exit.global_position) else FloorState.DOWNSTAIRS
