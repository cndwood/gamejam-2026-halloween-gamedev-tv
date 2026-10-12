class_name WaveSpawner
extends Node2D

signal wave_started(wave_number: int)
signal wave_finished(wave_number: int)
signal spawning_started
signal spawning_stopped
signal enemy_count_changed(alive: int)

@export_range(1, 100, 1) var enemies_per_wave: int = 18
@export_range(1, 20, 1) var min_batch_size: int = 3
@export_range(1, 20, 1) var max_batch_size: int = 5
@export var min_spawn_interval: float = 0.3
@export var max_spawn_interval: float = 0.75
@export var min_batch_interval: float = 0.9
@export var max_batch_interval: float = 1.9
@export var first_spawn_delay: float = 1.4
@export var time_between_waves: float = 8.0
@export_range(0, 20, 1) var enemies_added_per_wave: int = 5
@export_range(16, 200, 1) var max_wave_enemies: int = 100
@export var minimum_wave_break: float = 3.0
@export var break_reduction_per_wave: float = 0.5
@export var auto_start: bool = true
@export var auto_continue_waves: bool = true

var current_wave: int = 0
var enemies_spawned_this_wave: int = 0
var enemies_alive: int = 0
var spawning: bool = false
var wave_active: bool = false
var spawn_timer: float = 0.0
var wave_timer: float = 0.0
var batch_remaining: int = 0
var batch_spawner: Spawner
var spawn_points: Array[Spawner] = []
var active_enemies: Dictionary = {}
var rng := RandomNumberGenerator.new()

func _enter_tree() -> void:
	add_to_group("wave_spawner")

func _ready() -> void:
	rng.randomize()
	for child in get_children():
		if child is Spawner and child.enemy_scene != null:
			spawn_points.append(child)
	Game.game_over.connect(stop_spawning)
	if auto_start:
		start_spawning()

func _process(delta: float) -> void:
	if not spawning:
		return
	if wave_active:
		process_wave(delta)
	elif auto_continue_waves:
		wave_timer -= delta
		if wave_timer <= 0.0:
			start_next_wave()

func start_spawning() -> void:
	if spawning or Game.is_game_over:
		return
	if spawn_points.is_empty():
		push_warning("WaveSpawner needs child Spawner nodes with enemy scenes.")
		return
	spawning = true
	spawning_started.emit()
	start_next_wave()

func stop_spawning() -> void:
	if not spawning:
		return
	spawning = false
	wave_active = false
	spawning_stopped.emit()

func start_next_wave() -> void:
	if not spawning or wave_active or enemies_alive > 0:
		return
	current_wave += 1
	Game.current_wave = current_wave
	enemies_spawned_this_wave = 0
	batch_remaining = 0
	spawn_timer = maxf(first_spawn_delay, 0.0)
	wave_active = true
	wave_started.emit(current_wave)
	enemy_count_changed.emit(enemies_alive)

func process_wave(delta: float) -> void:
	if enemies_spawned_this_wave >= get_wave_enemy_count():
		if enemies_alive == 0:
			finish_wave()
		return
	spawn_timer -= delta
	if spawn_timer > 0.0:
		return
	if batch_remaining == 0:
		begin_batch()
	var enemy := batch_spawner.spawn_enemy(get_enemy_stats())
	if enemy == null:
		push_warning("Wave spawn failed; stopping the wave.")
		stop_spawning()
		return
	active_enemies[enemy] = true
	enemy.died.connect(_on_enemy_removed)
	enemy.tree_exiting.connect(_on_enemy_removed.bind(enemy))
	enemies_alive += 1
	enemies_spawned_this_wave += 1
	batch_remaining -= 1
	enemy_count_changed.emit(enemies_alive)
	if batch_remaining > 0:
		spawn_timer = random_interval(min_spawn_interval, max_spawn_interval)
	else:
		spawn_timer = random_interval(min_batch_interval, max_batch_interval)

func begin_batch() -> void:
	batch_spawner = spawn_points[rng.randi_range(0, spawn_points.size() - 1)]
	var minimum := maxi(1, mini(min_batch_size, max_batch_size))
	var maximum := maxi(minimum, mini(8, maxi(min_batch_size, max_batch_size) + int((current_wave - 1) / 3.0)))
	batch_remaining = mini(rng.randi_range(minimum, maximum), get_wave_enemy_count() - enemies_spawned_this_wave)

func random_interval(minimum: float, maximum: float) -> float:
	var pace := maxf(0.5, pow(0.96, maxi(current_wave - 1, 0)))
	return rng.randf_range(maxf(0.12, minf(minimum, maximum) * pace), maxf(0.12, maxf(minimum, maximum) * pace))

func _on_enemy_removed(enemy: Enemy) -> void:
	# Death and subsequent removal count only once; external removals count too.
	if not active_enemies.has(enemy):
		return
	active_enemies.erase(enemy)
	enemies_alive = active_enemies.size()
	enemy_count_changed.emit(enemies_alive)

func finish_wave() -> void:
	if not wave_active:
		return
	Game.waves_cleared = maxi(Game.waves_cleared, current_wave)
	wave_active = false
	wave_timer = get_wave_break()
	wave_finished.emit(current_wave)
	if not auto_continue_waves:
		stop_spawning()

func get_wave_enemy_count() -> int:
	return mini(maxi(enemies_per_wave, max_wave_enemies), enemies_per_wave + maxi(0, current_wave - 1) * enemies_added_per_wave)

func get_wave_break() -> float:
	return maxf(minimum_wave_break, time_between_waves - maxi(0, current_wave - 1) * break_reduction_per_wave)

func get_enemy_stats() -> Dictionary:
	var level := maxi(0, current_wave - 1)
	return {
		"max_hp": mini(10, 3 + int(level / 3.0)),
		"move_speed": minf(110.0, 65.0 + level * 4.0) * rng.randf_range(0.9, 1.1),
		"attack_cooldown": maxf(0.8, 1.3 - level * 0.04),
		"attack_damage": mini(6, 2 + int(level / 3.0)),
	}
