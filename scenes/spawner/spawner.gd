class_name Spawner
extends Node2D

@export var enemy_scene: PackedScene

# Spawn points only place enemies; their parent owns wave timing and counts.
func spawn_enemy(stats: Dictionary = {}) -> Enemy:
	if enemy_scene == null:
		return null
	var enemy := enemy_scene.instantiate() as Enemy
	for property in stats:
		enemy.set(property, stats[property])
	var world := get_tree().current_scene as Node2D
	enemy.transform = world.global_transform.affine_inverse() * global_transform
	world.add_child(enemy)
	return enemy
