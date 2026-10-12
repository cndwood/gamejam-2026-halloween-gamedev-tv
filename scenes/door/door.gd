class_name Door
extends Area2D

enum DoorType {
	LEFT,
	RIGHT
}

@export var type: DoorType = DoorType.LEFT
@export var max_hp = 90
@export var hp_per_plank: int = 10
@export_range(0.1, 5.0, 0.1) var repair_duration: float = 1.0

@onready var hammer: Sprite2D = $Hammer
@onready var repair_anim: AnimationPlayer = $AnimationPlayer

@onready var interact_trigger: InteractTrigger = $InteractTrigger
@onready var hp_progress: TextureProgressBar = $HPProgress

var base_max_hp: int
var current_hp = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hammer.hide()
	Game.game_over.connect(stop_repair_animation)
	base_max_hp = max_hp
	max_hp = base_max_hp + (45 if Game.has_upgrade(&"door_health") else 0)
	Game.upgrade_changed.connect(_on_upgrade_changed)
	current_hp = max_hp
	update_hp_ui()
	Game.door_damage(type, current_hp, max_hp)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and interact_trigger.interactable:
		for body in interact_trigger.get_overlapping_bodies():
			if body is Player:
				begin_repair(body)
				return

func begin_repair(player: Player) -> bool:
	if Game.planks <= 0 or current_hp <= 0 or current_hp >= max_hp or Game.is_game_over:
		return false
	if not player.start_repair(self, repair_duration):
		return false
	repair_anim.play(&"repair", -1.0, 1.0 / maxf(repair_duration, 0.05))
	return true

func complete_repair(player: Player) -> bool:
	if player.repair_door != self or not interact_trigger.get_overlapping_bodies().has(player):
		return false
	if Game.planks <= 0 or current_hp <= 0 or current_hp >= max_hp or Game.is_game_over:
		return false
	Game.add_planks(-1)
	heal(hp_per_plank)
	return true

func take_damage(amount):
	var previous_hp = current_hp
	current_hp -= amount
	current_hp = clamp(current_hp, 0, max_hp)
	if current_hp < previous_hp:
		Music.play_effect(&"door_hit", global_position)
	elif current_hp > previous_hp:
		Music.play_effect(&"repair", global_position)
	update_hp_ui()

	Game.door_damage(type, current_hp, max_hp)

	if current_hp <= 0:
		Game.died()

func heal(amount):
	take_damage(-amount)

func update_hp_ui() -> void:
	hp_progress.max_value = max_hp
	hp_progress.value = current_hp

func _on_upgrade_changed(upgrade: StringName) -> void:
	if upgrade != &"door_health":
		return
	var upgraded_max := base_max_hp + 45
	current_hp += upgraded_max - max_hp
	max_hp = upgraded_max
	update_hp_ui()
	Game.door_damage(type, current_hp, max_hp)

func stop_repair_animation() -> void:
	repair_anim.stop()
	hammer.hide()
	hammer.rotation = 0.0
