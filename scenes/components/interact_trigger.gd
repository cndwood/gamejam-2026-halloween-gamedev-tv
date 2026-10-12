class_name InteractTrigger
extends Area2D

var interactable = false

func _on_body_entered(body: Node2D) -> void:
	if body as Player:
		interactable = true


func _on_body_exited(body: Node2D) -> void:
	if body as Player:
		interactable = false
