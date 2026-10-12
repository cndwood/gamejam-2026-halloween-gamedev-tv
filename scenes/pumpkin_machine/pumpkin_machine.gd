class_name PumpkinMachine
extends Node2D

@onready var pumpkin_progress: TextureProgressBar = $PumpkinProgress
@onready var crystal_progress: TextureProgressBar = $CrystalProgress
@onready var timer: Timer = $Timer
@onready var pumpkin_interact: InteractTrigger = $PumpkinInteract
@onready var crystal_interact: InteractTrigger = $CrystalInteract

@export var max_pumpkins = 10
@export var max_crystals = 10
@export var time_to_pumpkin = 4.0
@export_range(1, 10) var pumpkins_per_crystal: int = 2

var current_pumpkins = 0
var current_crystals = 0

func _ready() -> void:
	timer.wait_time = time_to_pumpkin * Game.production_time_multiplier(&"pumpkin_speed")
	Game.upgrade_changed.connect(_on_upgrade_changed)
	timer.one_shot = true
	timer.timeout.connect(timeout)
	update_ui()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if pumpkin_interact.interactable:
			var added = interact_pumpkins()
			Game.add_pumpkins(added)
		elif crystal_interact.interactable:
			var deducted = interact_crystals(Game.crystals)
			Game.add_crystals(-deducted)

func interact_pumpkins():
	var take_pumpkins = current_pumpkins
	if take_pumpkins > 0:
		Music.play_effect(&"interact", global_position)
	current_pumpkins = 0
	update_production()
	update_ui()
	return take_pumpkins

func interact_crystals(player_crystal_amount):
	var diff_to_max = max_crystals - current_crystals
	var amount_to_take = clampi(mini(player_crystal_amount, diff_to_max), 0, 3)
	current_crystals += amount_to_take
	if amount_to_take > 0:
		Music.play_effect(&"interact", global_position)
	update_production()
	update_ui()
	return amount_to_take

func timeout():
	if current_crystals > 0 and max_pumpkins - current_pumpkins >= pumpkins_per_crystal:
		current_crystals -= 1
		current_pumpkins += pumpkins_per_crystal
		Music.play_effect(&"pumpkin_ready", global_position)
	update_ui()
	update_production()

func update_production() -> void:
	if current_crystals <= 0 or max_pumpkins - current_pumpkins < pumpkins_per_crystal:
		timer.stop()
	elif timer.is_stopped():
		timer.start()

func update_ui():
	pumpkin_progress.value = float(current_pumpkins) / max_pumpkins
	crystal_progress.value = float(current_crystals) / max_crystals

func _on_upgrade_changed(upgrade: StringName) -> void:
	if upgrade != &"pumpkin_speed":
		return
	var remaining_fraction := timer.time_left / timer.wait_time
	var was_running := not timer.is_stopped()
	timer.wait_time = time_to_pumpkin * Game.production_time_multiplier(&"pumpkin_speed")
	if was_running:
		timer.start(maxf(0.001, timer.wait_time * remaining_fraction))
		# Timer.start(time) changes wait_time; restore the full batch duration.
		timer.wait_time = time_to_pumpkin * Game.production_time_multiplier(&"pumpkin_speed")
