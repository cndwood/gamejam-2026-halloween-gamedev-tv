class_name PlanksMachine
extends Node2D

@onready var planks_progress: TextureProgressBar = $PlanksProgress
@onready var crystal_progress: TextureProgressBar = $CrystalProgress
@onready var timer: Timer = $Timer
@onready var planks_interact: InteractTrigger = $PlanksInteract
@onready var crystal_interact: InteractTrigger = $CrystalsInteract

@export var max_planks = 12
@export var max_crystals = 10
@export var time_to_plank = 6.0
@export_range(1, 12) var planks_per_crystal: int = 3

var current_planks = 0
var current_crystals = 0

func _ready() -> void:
	timer.wait_time = time_to_plank * Game.production_time_multiplier(&"plank_speed")
	Game.upgrade_changed.connect(_on_upgrade_changed)
	timer.one_shot = true
	timer.timeout.connect(timeout)
	update_ui()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if planks_interact.interactable:
			var added = interact_planks()
			Game.add_planks(added)
		elif crystal_interact.interactable:
			var deducted = interact_crystals(Game.crystals)
			Game.add_crystals(-deducted)

func interact_planks():
	var take_planks = current_planks
	if take_planks > 0:
		Music.play_effect(&"planks_interact", global_position)
	current_planks = 0
	update_production()
	update_ui()
	return take_planks

func interact_crystals(player_crystal_amount):
	var diff_to_max = max_crystals - current_crystals
	var amount_to_take = clampi(mini(player_crystal_amount, diff_to_max), 0, 3)
	current_crystals += amount_to_take
	if amount_to_take > 0:
		Music.play_effect(&"planks_interact", global_position)
	update_production()
	update_ui()
	return amount_to_take

func timeout():
	if current_crystals > 0 and max_planks - current_planks >= planks_per_crystal:
		current_crystals -= 1
		current_planks += planks_per_crystal
		Music.play_effect(&"planks_ready", global_position)
	update_ui()
	update_production()

func update_production() -> void:
	if current_crystals <= 0 or max_planks - current_planks < planks_per_crystal:
		timer.stop()
	elif timer.is_stopped():
		timer.start()

func update_ui():
	planks_progress.value = float(current_planks) / max_planks
	crystal_progress.value = float(current_crystals) / max_crystals

func _on_upgrade_changed(upgrade: StringName) -> void:
	if upgrade != &"plank_speed":
		return
	var remaining_fraction := timer.time_left / timer.wait_time
	var was_running := not timer.is_stopped()
	timer.wait_time = time_to_plank * Game.production_time_multiplier(&"plank_speed")
	if was_running:
		timer.start(maxf(0.001, timer.wait_time * remaining_fraction))
		# Timer.start(time) changes wait_time; restore the full batch duration.
		timer.wait_time = time_to_plank * Game.production_time_multiplier(&"plank_speed")
