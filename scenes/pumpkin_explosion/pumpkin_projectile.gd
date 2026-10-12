class_name PumpkinProjectile
extends Area2D

@export var damage: int = 1
@export var explosion_scene: PackedScene
@export_range(1, 5) var spin_turns: int = 1

@onready var sprite: Sprite2D = $Sprite2D

var velocity: Vector2
var exploded := false
var planned_flight_time: float = 0.7
var flight_elapsed: float = 0.0


func _physics_process(delta: float) -> void:
	if exploded:
		return

	velocity.y += gravity * delta
	global_position += velocity * delta

	flight_elapsed = minf(flight_elapsed + delta, maxf(planned_flight_time, 0.01))
	var progress := flight_elapsed / maxf(planned_flight_time, 0.01)
	var spin_direction := -1.0 if velocity.x < 0.0 else 1.0
	sprite.rotation = spin_direction * TAU * spin_turns * progress
	if progress >= 1.0:
		sprite.rotation = 0.0


func _on_body_entered(_body: Node2D) -> void:
	if not exploded:
		exploded = true
		sprite.rotation = 0.0
		call_deferred("explode")


func explode() -> void:
	var explosion := explosion_scene.instantiate() as PumpkinExplosion
	explosion.damage = damage
	var world := get_tree().current_scene as Node2D
	# _ready() starts audio, so establish the world position before adding it.
	explosion.transform = world.global_transform.affine_inverse() * global_transform
	world.add_child(explosion)
	explosion.global_rotation = 0.0

	queue_free()
