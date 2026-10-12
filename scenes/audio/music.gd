extends Node

const EFFECTS = {
	&"game_over": preload("res://scenes/audio/game_over_sound.tscn"),
	&"climb": preload("res://scenes/audio/climb_sound.tscn"),
	&"pumpkin_ready": preload("res://scenes/audio/pumpkin_ready_sound.tscn"),
	&"planks_ready": preload("res://scenes/audio/planks_ready_sound.tscn"),
	&"skeleton_death": preload("res://scenes/audio/skeleton_death_sound.tscn"),
	&"explosion": preload("res://scenes/audio/explosion_sound.tscn"),
	&"door_hit": preload("res://scenes/audio/door_hit_sound.tscn"),
	&"interact": preload("res://scenes/audio/interact_sound.tscn"),
	&"planks_interact": preload("res://scenes/audio/planks_interact_sound.tscn"),
	&"crystal_interact": preload("res://scenes/audio/crystal_interact_sound.tscn"),
	&"cannon": preload("res://scenes/audio/cannon_sound.tscn"),
	&"repair": preload("res://scenes/audio/repair_sound.tscn"),
}

@export var background_music: AudioStream
@onready var player: AudioStreamPlayer = $BackgroundMusic

var settings_path: String = "user://audio_settings.cfg"
var volumes: Dictionary = {&"Master": 1.0, &"Music": 0.3, &"SFX": 0.15}
var muted: bool = false
var music_requested: bool = false

func _ready() -> void:
	for bus_name in [&"Music", &"SFX"]:
		if AudioServer.get_bus_index(bus_name) < 0:
			AudioServer.add_bus()
			var index := AudioServer.bus_count - 1
			AudioServer.set_bus_name(index, bus_name)
			AudioServer.set_bus_send(index, &"Master")
	player.bus = &"Music"
	player.finished.connect(_on_music_finished)
	load_settings()

func start_background_music() -> void:
	music_requested = true
	if background_music == null or player.playing:
		return
	player.stream = background_music
	player.play()

func _on_music_finished() -> void:
	if music_requested:
		start_background_music()

func play_effect(effect: StringName, source_position: Vector2) -> void:
	var prefab: PackedScene = EFFECTS.get(effect)
	if prefab == null:
		return
	var sound := prefab.instantiate() as AudioStreamPlayer
	if sound.stream == null:
		sound.free()
		return
	sound.positional = true
	sound.source_position = source_position
	add_child(sound)

func set_volume(bus_name: StringName, value: float) -> void:
	if not volumes.has(bus_name):
		return
	volumes[bus_name] = clampf(value, 0.0, 1.0)
	apply_settings()
	save_settings()

func set_muted(value: bool) -> void:
	muted = value
	apply_settings()
	save_settings()

func apply_settings() -> void:
	for bus_name in volumes:
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(bus_name), volumes[bus_name])
	AudioServer.set_bus_mute(AudioServer.get_bus_index(&"Master"), muted)

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(settings_path) == OK:
		for bus_name in volumes:
			volumes[bus_name] = clampf(float(config.get_value("volume", bus_name, volumes[bus_name])), 0.0, 1.0)
		muted = bool(config.get_value("volume", "muted", false))
	apply_settings()

func save_settings() -> void:
	var config := ConfigFile.new()
	for bus_name in volumes:
		config.set_value("volume", bus_name, volumes[bus_name])
	config.set_value("volume", "muted", muted)
	var error := config.save(settings_path)
	if error != OK:
		push_warning("Could not save sound settings: %s" % error)
