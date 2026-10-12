class_name Player
extends CharacterBody2D

signal climb_finished(destination: Vector2)

@onready var held_crystal: Sprite2D = $AttachmentPoint/Crystal
@onready var held_pumpkin: Sprite2D = $AttachmentPoint/Pumpkin
@onready var held_wood: Sprite2D = $AttachmentPoint/Wood

@onready var attachment_point: Marker2D = $AttachmentPoint
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite

const SPEED = 300.0
const JUMP_VELOCITY = -450.0

@export var repair_animation: StringName = &"repair"
@export_range(0.05, 10.0, 0.05) var repair_animation_reference_duration: float = 1.0

var is_refilling: bool = false
var refill_cannon: PumpkinCannon
var refill_elapsed: float = 0.0
var active_refill_duration: float = 0.5

var is_repairing: bool = false
var repair_door: Door
var repair_elapsed: float = 0.0
var active_repair_duration: float = 1.0

@export_range(300.0, 1500.0, 10.0) var dash_speed: float = 750.0
@export_range(0.05, 0.5, 0.01) var dash_duration: float = 0.16
@export_range(0.1, 3.0, 0.05) var dash_cooldown: float = 0.65

var dash_remaining: float = 0.0
var dash_cooldown_remaining: float = 0.0
var dash_direction: float = 1.0

@export_range(0.1, 10.0, 0.1) var climb_speed_multiplier: float = 1.0
@export var climb_animation: StringName = &"climb"
@export_range(0.05, 10.0, 0.05) var climb_animation_reference_duration: float = 2.0

@export_range(4.0, 32.0, 1.0) var climb_sound_spacing: float = 12.0

var climb_sound_step: int = 0
var is_climbing: bool = false
var climb_start: Vector2
var climb_destination: Vector2
var climb_elapsed: float = 0.0
var active_climb_duration: float = 0.0


func _enter_tree() -> void:
	add_to_group("audio_listener")


func _ready() -> void:
	Game.game_over.connect(cancel_repair)
	Game.game_over.connect(cancel_refill)
	Game.crystals_changed.connect(_on_inventory_changed)
	Game.pumpkins_changed.connect(_on_inventory_changed)
	Game.planks_changed.connect(_on_inventory_changed)
	update_held_resource()


func start_climb(destination: Vector2, duration: float, full_duration: float = -1.0) -> bool:
	if is_climbing or is_repairing or is_refilling:
		return false
	is_climbing = true
	dash_remaining = 0.0
	attachment_point.hide()
	global_position.x = destination.x
	climb_start = global_position
	climb_destination = destination
	climb_elapsed = 0.0
	climb_sound_step = 0
	Music.play_effect(&"climb", global_position)
	active_climb_duration = maxf(duration / maxf(climb_speed_multiplier, 0.1), 0.05)
	velocity = Vector2.ZERO
	if anim.has_animation(climb_animation):
		var animation_duration := full_duration if full_duration > 0.0 else duration
		animation_duration = maxf(animation_duration / maxf(climb_speed_multiplier, 0.1), 0.05)
		anim.play(climb_animation, -1.0, climb_animation_reference_duration / animation_duration)
	else:
		anim.play("RESET")
	return true


func process_climb(delta: float) -> void:
	climb_elapsed = minf(climb_elapsed + delta, active_climb_duration)
	global_position = climb_start.lerp(climb_destination, climb_elapsed / active_climb_duration)
	velocity = Vector2.ZERO
	# Rung spacing makes the cadence follow climbing speed and future upgrades.
	var step := int(climb_start.distance_to(global_position) / maxf(climb_sound_spacing, 1.0))
	if step > climb_sound_step and climb_elapsed < active_climb_duration:
		Music.play_effect(&"climb", global_position)
	climb_sound_step = step
	if climb_elapsed >= active_climb_duration:
		is_climbing = false
		attachment_point.show()
		anim.play("RESET")
		climb_finished.emit(climb_destination)


func start_dash(direction: float) -> bool:
	if not Game.has_upgrade(&"dash") or is_climbing or is_repairing or is_refilling or dash_remaining > 0.0 or dash_cooldown_remaining > 0.0:
		return false
	dash_direction = signf(direction) if direction != 0.0 else (-1.0 if sprite.flip_h else 1.0)
	dash_remaining = dash_duration
	dash_cooldown_remaining = dash_cooldown
	return true


func _physics_process(delta: float) -> void:
	dash_cooldown_remaining = maxf(dash_cooldown_remaining - delta, 0.0)
	if is_refilling:
		process_refill(delta)
		return
	if is_repairing:
		process_repair(delta)
		return
	if is_climbing:
		process_climb(delta)
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("down"):
		set_collision_mask_value(5, false)
	else:
		set_collision_mask_value(5, true)

	if velocity.x < 0:
		sprite.flip_h = true
		attachment_point.position.x = -7
	elif velocity.x > 0:
		sprite.flip_h = false
		attachment_point.position.x = 7

	held_crystal.flip_h = sprite.flip_h
	held_pumpkin.flip_h = sprite.flip_h
	held_wood.flip_h = sprite.flip_h

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if Input.is_action_just_pressed("dash"):
		start_dash(direction)
	if dash_remaining > 0.0:
		velocity.x = dash_direction * dash_speed
		dash_remaining = maxf(dash_remaining - delta, 0.0)
	elif direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	if is_on_wall():
		velocity.x = 0
		dash_remaining = 0.0

	if abs(get_real_velocity().x) > 0.1:
		anim.play("walk")
	else:
		anim.play("RESET")

func start_repair(door: Door, duration: float) -> bool:
	if is_climbing or is_repairing or is_refilling or not is_on_floor() or Game.is_game_over:
		return false
	is_repairing = true
	update_held_resource()
	repair_door = door
	repair_elapsed = 0.0
	active_repair_duration = maxf(duration, 0.05)
	dash_remaining = 0.0
	velocity = Vector2.ZERO
	if anim.has_animation(repair_animation):
		anim.play(repair_animation, -1.0, repair_animation_reference_duration / active_repair_duration)
	else:
		anim.play("RESET")
	return true

func process_repair(delta: float) -> void:
	velocity = Vector2.ZERO
	if not is_instance_valid(repair_door) or Game.is_game_over:
		cancel_repair()
		return
	repair_elapsed += delta
	if repair_elapsed >= active_repair_duration:
		repair_door.complete_repair(self)
		cancel_repair()

func cancel_repair() -> void:
	if not is_repairing:
		return
	is_repairing = false
	if is_instance_valid(repair_door):
		repair_door.stop_repair_animation()
	repair_door = null
	update_held_resource()
	velocity = Vector2.ZERO
	anim.play("RESET")

func _on_inventory_changed(_current: int, _maximum: int) -> void:
	update_held_resource()

func update_held_resource() -> void:
	held_crystal.visible = not is_repairing and not is_refilling and Game.last_picked_resource == &"crystals" and Game.crystals > 0
	held_pumpkin.visible = not is_repairing and not is_refilling and Game.last_picked_resource == &"pumpkins" and Game.pumpkins > 0
	held_wood.visible = is_repairing or (not is_refilling and Game.last_picked_resource == &"planks" and Game.planks > 0)

func start_refill(cannon: PumpkinCannon, duration: float) -> bool:
	if is_climbing or is_repairing or is_refilling or Game.is_game_over:
		return false
	is_refilling = true
	refill_cannon = cannon
	refill_elapsed = 0.0
	active_refill_duration = maxf(duration, 0.05)
	dash_remaining = 0.0
	velocity = Vector2.ZERO
	anim.play("RESET")
	update_held_resource()
	return true

func process_refill(delta: float) -> void:
	velocity = Vector2.ZERO
	if not is_instance_valid(refill_cannon) or Game.is_game_over:
		cancel_refill()
		return
	refill_elapsed = minf(refill_elapsed + delta, active_refill_duration)
	refill_cannon.animate_refill(refill_elapsed / active_refill_duration)
	if refill_elapsed >= active_refill_duration:
		refill_cannon.complete_refill(self)
		cancel_refill()

func cancel_refill() -> void:
	if not is_refilling:
		return
	is_refilling = false
	if is_instance_valid(refill_cannon):
		refill_cannon.clear_refill()
	refill_cannon = null
	update_held_resource()
	velocity = Vector2.ZERO
	anim.play("RESET")
