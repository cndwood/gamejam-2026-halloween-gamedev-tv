class_name PumpkinCannon
extends Node2D

@export var pumpkin_scene: PackedScene

@export_range(0.1, 3.0, 0.1) var refill_duration: float = 0.5
@export var refill_arc_height: float = 18.0

@export var attack_cooldown: float = 1.5
@export var cannon_range: float = 150.0
@export var flight_time: float = 0.7
@export var projectile_gravity: float = 900.0
@export var impact_offset: float = 16.0
@export_range(1, 99) var max_ammunition: int = 20

@onready var refill_point: Marker2D = $RefillPoint

@onready var muzzle: Marker2D = %Muzzle
@onready var progress: TextureProgressBar = $Progress
@onready var interact_trigger: InteractTrigger = $InteractTrigger

var refill_pumpkin: Sprite2D
var refill_start: Vector2
var refill_end: Vector2
var refill_rotation_direction: float = 1.0

var attack_timer: float = 0.0
var current_ammunition: int = 0
const BULLETS_PER_PUMPKIN: int = 5


func _ready() -> void:
	Game.upgrade_changed.connect(_on_upgrade_changed)
	Game.game_over.connect(clear_refill)
	current_ammunition = max_ammunition
	update_ui()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and interact_trigger.interactable:
		for body in interact_trigger.get_overlapping_bodies():
			if body is Player:
				begin_refill(body)
				return

func begin_refill(player: Player) -> bool:
	if Game.pumpkins <= 0 or max_ammunition - current_ammunition < BULLETS_PER_PUMPKIN or is_instance_valid(refill_pumpkin):
		return false
	if not player.start_refill(self, refill_duration):
		return false
	refill_start = player.held_pumpkin.global_position
	refill_end = refill_point.global_position
	refill_rotation_direction = -1.0 if refill_end.x < refill_start.x else 1.0
	refill_pumpkin = Sprite2D.new()
	refill_pumpkin.texture = player.held_pumpkin.texture
	refill_pumpkin.z_as_relative = false
	refill_pumpkin.z_index = player.z_index + 1
	add_child(refill_pumpkin)
	animate_refill(0.0)
	return true

func animate_refill(progress_value: float) -> void:
	if not is_instance_valid(refill_pumpkin):
		return
	var fraction := clampf(progress_value, 0.0, 1.0)
	refill_pumpkin.global_position = refill_start.lerp(refill_end, fraction) + Vector2(0, -sin(PI * fraction) * refill_arc_height)
	refill_pumpkin.global_rotation = refill_rotation_direction * TAU * 2.0 * fraction

func complete_refill(player: Player) -> bool:
	if Game.is_game_over or player.refill_cannon != self or not interact_trigger.get_overlapping_bodies().has(player):
		return false
	if Game.pumpkins <= 0 or max_ammunition - current_ammunition < BULLETS_PER_PUMPKIN:
		return false
	Game.add_pumpkins(-1)
	current_ammunition += BULLETS_PER_PUMPKIN
	Music.play_effect(&"interact", global_position)
	update_ui()
	return true

func clear_refill() -> void:
	if is_instance_valid(refill_pumpkin):
		refill_pumpkin.queue_free()
	refill_pumpkin = null

func _exit_tree() -> void:
	clear_refill()


func update_ui() -> void:
	progress.value = float(current_ammunition) / max_ammunition


func _physics_process(delta: float) -> void:
	attack_timer -= delta

	if attack_timer > 0.0 or current_ammunition <= 0:
		return

	var target := get_target()

	if target == null:
		return

	shoot(target)
	attack_timer = attack_cooldown * Game.production_time_multiplier(&"cannon_speed")


func get_target() -> Enemy:
	var enemies := get_tree().get_nodes_in_group("enemy")

	var closest: Enemy = null
	var closest_distance := INF

	for enemy in enemies:
		if enemy is not Enemy:
			continue
		if enemy.dead:
			continue

		var distance := global_position.distance_to(enemy.global_position)

		if distance > cannon_range:
			continue

		if distance < closest_distance:
			closest_distance = distance
			closest = enemy

	return closest


func shoot(target: Enemy) -> void:
	if current_ammunition <= 0 or pumpkin_scene == null:
		return

	var pumpkin := pumpkin_scene.instantiate() as PumpkinProjectile
	pumpkin.damage = 2 if Game.has_upgrade(&"cannon_damage") else 1

	get_tree().current_scene.add_child(pumpkin)

	pumpkin.global_position = muzzle.global_position
	pumpkin.gravity = projectile_gravity
	pumpkin.velocity = calculate_launch_velocity(target)
	pumpkin.planned_flight_time = flight_time
	current_ammunition -= 1
	Music.play_effect(&"cannon", global_position)
	update_ui()


@export var min_shot_distance: float = 8.0


func calculate_launch_velocity(target: Enemy) -> Vector2:
	var start := muzzle.global_position

	var target_x := target.global_position.x
	var target_velocity_x := target.get_real_velocity().x

	# Predict enemy position.
	var predicted_x := target_x + target_velocity_x * flight_time

	# Aim slightly ahead of moving enemy.
	if abs(target_velocity_x) > 0.1:
		predicted_x += sign(target_velocity_x) * impact_offset

	# Direction from cannon -> enemy.
	var direction = sign(target_x - start.x)

	# Enemy should normally never be exactly on the muzzle X,
	# but handle it safely.
	if direction == 0:
		direction = 1

	# Closest point we are allowed to shoot.
	var minimum_x = start.x + direction * min_shot_distance

	# Clamp landing point between muzzle and skeleton.
	if direction > 0:
		predicted_x = clamp(
			predicted_x,
			minimum_x,
			target_x
		)
	else:
		predicted_x = clamp(
			predicted_x,
			target_x,
			minimum_x
		)

	var landing_position := Vector2(
		predicted_x,
		target.global_position.y
	)

	var displacement := landing_position - start

	var velocity_x := displacement.x / flight_time

	var velocity_y := (
		displacement.y
		- 0.5 * projectile_gravity * flight_time * flight_time
	) / flight_time

	return Vector2(velocity_x, velocity_y)

func _on_upgrade_changed(upgrade: StringName) -> void:
	if upgrade == &"cannon_speed":
		attack_timer *= 0.75
