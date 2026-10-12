extends Area2D

@export var damage = 1


func _on_area_entered(area: Area2D) -> void:
	var door = area as Door
	if door:
		door.take_damage(damage)
