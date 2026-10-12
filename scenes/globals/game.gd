extends Node


signal crystals_changed(current: int, max: int)
signal pumpkins_changed(current: int, max: int)
signal planks_changed(current: int, max: int)
signal left_door_changed(current: int, max: int)
signal right_door_changed(current: int, max: int)
signal upgrade_changed(upgrade: StringName)
signal upgrades_reset
signal game_over

const UPGRADE_IDS = [&"dash", &"plank_speed", &"cannon_speed", &"cannon_damage", &"door_health", &"pumpkin_speed"]
const UPGRADE_LABELS = ["Dash", "Saw+", "Rapid", "Blast+", "Door+", "Grow+"]
const UPGRADE_COSTS = [6, 8, 10, 14, 10, 8]
var upgrades: Dictionary = {}

func has_upgrade(upgrade: StringName) -> bool:
	return upgrades.has(upgrade)

func buy_upgrade(upgrade: StringName) -> bool:
	var index := UPGRADE_IDS.find(upgrade)
	if index < 0 or has_upgrade(upgrade) or not run_started or is_game_over:
		return false
	var cost: int = UPGRADE_COSTS[index]
	if crystals < cost:
		return false
	upgrades[upgrade] = true
	add_crystals(-cost)
	upgrade_changed.emit(upgrade)
	return true

func production_time_multiplier(upgrade: StringName) -> float:
	return 0.75 if has_upgrade(upgrade) else 1.0

var max_crystals = 99
var max_pumpkins = 99
var max_planks = 99

var last_picked_resource: StringName = &""

var crystals: int = 0
var pumpkins: int = 0
var planks: int = 0
var is_game_over: bool = false
var current_wave: int = 0
var waves_cleared: int = 0
var run_started: bool = false
# Session state: keep this when resetting a run after death.
var tutorial_seen: bool = false

func died():
	if is_game_over:
		return
	is_game_over = true
	game_over.emit()

func reset_run() -> void:
	current_wave = 0
	waves_cleared = 0
	is_game_over = false
	run_started = false
	upgrades.clear()
	upgrades_reset.emit()
	last_picked_resource = &""
	crystals = 0
	pumpkins = 0
	planks = 0
	crystals_changed.emit(crystals, max_crystals)
	pumpkins_changed.emit(pumpkins, max_pumpkins)
	planks_changed.emit(planks, max_planks)

func door_damage(type, current, max_hp):
	if type == Door.DoorType.LEFT:
		left_door_changed.emit(current, max_hp)
	else:
		right_door_changed.emit(current, max_hp)

func add_crystals(amount):
	if amount == 0:
		return

	var previous := crystals
	crystals += amount
	crystals = clamp(crystals, 0, max_crystals)
	if crystals > previous:
		last_picked_resource = &"crystals"
	crystals_changed.emit(crystals, max_crystals)

func add_pumpkins(amount):
	if amount == 0:
		return

	var previous := pumpkins
	pumpkins += amount
	pumpkins = clamp(pumpkins, 0, max_pumpkins)
	if pumpkins > previous:
		last_picked_resource = &"pumpkins"
	pumpkins_changed.emit(pumpkins, max_pumpkins)

func add_planks(amount):
	if amount == 0:
		return

	var previous := planks
	planks += amount
	planks = clamp(planks, 0, max_planks)
	if planks > previous:
		last_picked_resource = &"planks"
	planks_changed.emit(planks, max_planks)
