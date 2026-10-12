class_name Enemy
extends CharacterBody2D

signal died(enemy: Enemy)

@onready var trigger_zone: Area2D = %TriggerZone
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite
@onready var pivot: Node2D = $Pivot
@onready var hp_progress: TextureProgressBar = $HPProgress

@export var max_hp: int = 3
@export var attack_cooldown: float = 1.4
@export var attack_damage: int = 1
@export var move_speed: float = 62.0

# Optional drop
@export var drop_scene: PackedScene
@export_range(0.0, 1.0) var drop_chance: float = 1.0
@export var min_drop_amount: int = 1
@export var max_drop_amount: int = 2

var hp: int
var target: Node2D = null
var attack_timer: float = 0.0
var in_trigger := false
var dead := false



func _ready() -> void:
	$Pivot/Attack.damage = attack_damage
	hp = max_hp
	update_hp_ui()

	var left = get_tree().get_first_node_in_group("left_door") as Node2D
	var right = get_tree().get_first_node_in_group("right_door") as Node2D

	if left and right:
		if left.global_position.distance_to(global_position) < right.global_position.distance_to(global_position):
			target = left
		else:
			target = right


func _physics_process(delta: float) -> void:
	if dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	attack_timer -= delta

	if in_trigger:
		velocity.x = 0.0

		if attack_timer <= 0.0:
			attack()
			attack_timer = attack_cooldown
	else:
		var x_distance := target.global_position.x - global_position.x
		var direction = sign(x_distance)

		velocity.x = direction * move_speed

	move_and_slide()

	if velocity.x < 0:
		pivot.scale.x = -1
		sprite.flip_h = true
	elif velocity.x > 0:
		pivot.scale.x = 1
		sprite.flip_h = false

	if anim.current_animation == "attack" and anim.is_playing():
		return

	if abs(get_real_velocity().x) > 0.1:
		anim.play("walk")
	else:
		anim.play("idle")


func attack() -> void:
	anim.play("attack")


func take_damage(amount: int) -> void:
	if dead:
		return

	hp = clampi(hp - amount, 0, max_hp)
	update_hp_ui()

	if hp <= 0:
		die()


func die() -> void:
	if dead:
		return

	dead = true
	Music.play_effect(&"skeleton_death", global_position)
	hp = 0
	update_hp_ui()
	velocity = Vector2.ZERO

	spawn_drop()

	died.emit(self)

	anim.play("die")
	await anim.animation_finished

	queue_free()


func update_hp_ui() -> void:
	hp_progress.max_value = max_hp
	hp_progress.value = hp


func spawn_drop() -> void:
	if drop_scene == null:
		return

	if randf() > drop_chance:
		return

	var amount := randi_range(min_drop_amount, max_drop_amount)

	for i in amount:
		var drop := drop_scene.instantiate()

		get_tree().current_scene.add_child(drop)

		drop.global_position = global_position + Vector2(
			randf_range(-8.0, 8.0),
			randf_range(-4.0, 0.0)
		)


func _on_trigger_zone_area_entered(_area: Area2D) -> void:
	in_trigger = true


func _on_trigger_zone_area_exited(_area: Area2D) -> void:
	in_trigger = false
