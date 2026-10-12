class_name PumpkinExplosion
extends Area2D

@export var damage: int = 1

@onready var anim: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	Music.play_effect(&"explosion", global_position)
	anim.animation_finished.connect(_on_animation_finished)
	anim.play("explode")

	await get_tree().physics_frame

	for body in get_overlapping_bodies():
		if body is Enemy:
			body.take_damage(damage)


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "explode":
		queue_free()
