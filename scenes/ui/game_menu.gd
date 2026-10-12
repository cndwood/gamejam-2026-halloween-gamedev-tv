extends CanvasLayer

enum Menu { TITLE, PLAYING, PAUSE, GAME_OVER, OPTIONS, TUTORIAL }

const TUTORIAL_PAGES = [
	{
		"title": "KEEP THEM OUT",
		"text": "Protect both doors. If either breaks, the run ends.\n\nA/D or Left/Right: move   Space: jump\nS or Down: drop through floors   Escape: pause\n\nCannons fire automatically. Keep them loaded!\nStand by a cannon's ammo box and press E.\nOne pumpkin gives 5 shots after a 0.5-second throw.\n\nStand on the floor near a damaged door and press E.\nRepair takes 1 second and heals 10 HP per plank.\nMovement locks during throws and repairs.",
	},
	{
		"title": "KEEP SUPPLIES FLOWING",
		"text": "Skeletons drop crystals when defeated.\nCrystals fly into the collectors and slide down.\n\nGo to a collector below and press E to take them.\nBring crystals to the pumpkin or plank machine.\nPress E at its crystal input: deposit up to 3 at once.\n\nOne crystal makes 2 pumpkins or 3 planks.\nPress E at the output when supplies are ready.\n\nUse E at the ladder to switch floors.\nClimbing from partway up takes less time.",
	},
	{
		"title": "UPGRADE AND SURVIVE",
		"text": "Buy upgrades at the basement pedestals with E.\nThe number below the name is the crystal cost.\n\nDash: unlock Shift to dash.\nSaw+ / Grow+: shorten production time by 25%.\nRapid: shorten cannon firing intervals by 25%.\nBlast+: cannon damage increases from 1 to 2.\nDoor+: both doors gain 45 maximum and current HP.\n\nUpgrades last for this run. Save supplies for repairs!\nWaves grow stronger. Game over shows your score.\nTry Again resets the run and skips this tutorial.",
	},
]

var tutorial_page: int = 0
var tutorial_return: Menu = Menu.PLAYING

@onready var tutorial: VBoxContainer = $Screen/Center/Panel/Margin/Buttons/Tutorial
@onready var tutorial_text: Label = $Screen/Center/Panel/Margin/Buttons/Tutorial/Instructions
@onready var tutorial_page_label: Label = $Screen/Center/Panel/Margin/Buttons/Tutorial/Page
@onready var tutorial_previous: Button = $Screen/Center/Panel/Margin/Buttons/Tutorial/Previous
@onready var help_button: Button = $Screen/Center/Panel/Margin/Buttons/Help
@onready var tutorial_button: Button = $Screen/Center/Panel/Margin/Buttons/Tutorial/Continue
@onready var dim: ColorRect = $Screen/Dim
@onready var screen: Control = $Screen
@onready var title: Label = $Screen/Center/Panel/Margin/Buttons/Title
@onready var message: Label = $Screen/Center/Panel/Margin/Buttons/Message
@onready var start_button: Button = $Screen/Center/Panel/Margin/Buttons/Start
@onready var resume_button: Button = $Screen/Center/Panel/Margin/Buttons/Resume
@onready var restart_button: Button = $Screen/Center/Panel/Margin/Buttons/Restart
@onready var options_button: Button = $Screen/Center/Panel/Margin/Buttons/Options
@onready var main_menu_button: Button = $Screen/Center/Panel/Margin/Buttons/MainMenu
@onready var quit_button: Button = $Screen/Center/Panel/Margin/Buttons/Quit
@onready var settings: VBoxContainer = $Screen/Center/Panel/Margin/Buttons/Settings
@onready var master_slider: HSlider = $Screen/Center/Panel/Margin/Buttons/Settings/Master
@onready var music_slider: HSlider = $Screen/Center/Panel/Margin/Buttons/Settings/Music
@onready var sfx_slider: HSlider = $Screen/Center/Panel/Margin/Buttons/Settings/SFX
@onready var mute_button: CheckButton = $Screen/Center/Panel/Margin/Buttons/Settings/Mute
@onready var back_button: Button = $Screen/Center/Panel/Margin/Buttons/Settings/Back

var game_over_presented: bool = false
var game_over_fade: Tween

var mode: Menu = Menu.TITLE
var options_return: Menu = Menu.TITLE
var restarting: bool = false
var return_to_title: bool = false

func _ready() -> void:
	tutorial_button.pressed.connect(advance_tutorial)
	tutorial_previous.pressed.connect(previous_tutorial_page)
	help_button.pressed.connect(show_help)
	start_button.pressed.connect(start_game)
	resume_button.pressed.connect(resume_game)
	restart_button.pressed.connect(restart_game)
	options_button.pressed.connect(show_options)
	main_menu_button.pressed.connect(go_to_title)
	quit_button.pressed.connect(quit_game)
	back_button.pressed.connect(close_options)
	master_slider.value_changed.connect(func(value): Music.set_volume(&"Master", value / 100.0))
	music_slider.value_changed.connect(func(value): Music.set_volume(&"Music", value / 100.0))
	sfx_slider.value_changed.connect(func(value): Music.set_volume(&"SFX", value / 100.0))
	mute_button.toggled.connect(Music.set_muted)
	Game.game_over.connect(show_game_over)
	if Game.is_game_over:
		show_game_over()
	elif Game.run_started:
		show_menu(Menu.PLAYING)
	else:
		show_menu(Menu.TITLE)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		get_viewport().set_input_as_handled()
		if restarting:
			return
		match mode:
			Menu.OPTIONS:
				close_options()
			Menu.PLAYING:
				show_pause()
			Menu.PAUSE:
				resume_game()

func show_menu(next_mode: Menu) -> void:
	if not Game.is_game_over:
		if game_over_fade != null:
			game_over_fade.kill()
		dim.color = Color(0.02, 0.01, 0.04, 0.75)
	mode = next_mode
	screen.visible = mode != Menu.PLAYING
	get_tree().paused = mode != Menu.PLAYING
	start_button.visible = mode == Menu.TITLE
	resume_button.visible = mode == Menu.PAUSE
	restart_button.visible = mode == Menu.PAUSE or mode == Menu.GAME_OVER
	options_button.visible = mode == Menu.TITLE or mode == Menu.PAUSE or mode == Menu.GAME_OVER
	main_menu_button.visible = mode == Menu.PAUSE or mode == Menu.GAME_OVER
	quit_button.visible = mode != Menu.PLAYING and mode != Menu.OPTIONS and mode != Menu.TUTORIAL and not OS.has_feature("web")
	tutorial.visible = mode == Menu.TUTORIAL
	message.visible = mode != Menu.TUTORIAL
	help_button.visible = mode == Menu.TITLE or mode == Menu.PAUSE or mode == Menu.GAME_OVER
	settings.visible = mode == Menu.OPTIONS
	match mode:
		Menu.TUTORIAL:
			update_tutorial_page()
		Menu.TITLE:
			title.text = "Uninvited"
			message.text = "Keep the skeletons outside."
			start_button.grab_focus()
		Menu.PAUSE:
			title.text = "PAUSED"
			message.text = "Take a breath. The house can wait."
			restart_button.text = "Restart"
			resume_button.grab_focus()
		Menu.GAME_OVER:
			title.text = "GAME OVER"
			message.text = "Reached wave %d\nWaves cleared: %d" % [Game.current_wave, Game.waves_cleared]
			restart_button.text = "Try Again"
			restart_button.grab_focus()
		Menu.OPTIONS:
			title.text = "OPTIONS"
			message.text = "Sound settings"
			master_slider.set_value_no_signal(Music.volumes[&"Master"] * 100.0)
			music_slider.set_value_no_signal(Music.volumes[&"Music"] * 100.0)
			sfx_slider.set_value_no_signal(Music.volumes[&"SFX"] * 100.0)
			mute_button.set_pressed_no_signal(Music.muted)
			master_slider.grab_focus()
		Menu.PLAYING:
			start_button.release_focus()
			resume_button.release_focus()

func start_game() -> void:
	if mode != Menu.TITLE or restarting:
		return
	Music.start_background_music()
	if not Game.tutorial_seen:
		open_tutorial(Menu.PLAYING)
		return
	Game.run_started = true
	show_menu(Menu.PLAYING)

func finish_tutorial() -> void:
	if mode != Menu.TUTORIAL or restarting:
		return
	Game.tutorial_seen = true
	tutorial_button.release_focus()
	if tutorial_return == Menu.PLAYING:
		Game.run_started = true
	show_menu(tutorial_return)

func show_pause() -> void:
	if Game.is_game_over or not Game.run_started or restarting:
		return
	show_menu(Menu.PAUSE)

func resume_game() -> void:
	if Game.is_game_over or restarting or mode != Menu.PAUSE:
		return
	show_menu(Menu.PLAYING)

func show_game_over() -> void:
	show_menu(Menu.GAME_OVER)
	if game_over_presented:
		return
	game_over_presented = true
	dim.color = Color(0, 0, 0, 0)
	game_over_fade = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	game_over_fade.tween_property(dim, "color", Color.BLACK, 1.0)
	var listener := get_tree().get_first_node_in_group("audio_listener") as Node2D
	if listener != null:
		Music.play_effect(&"game_over", listener.global_position)

func show_options() -> void:
	if mode == Menu.PLAYING or mode == Menu.OPTIONS or mode == Menu.TUTORIAL or restarting:
		return
	options_return = mode
	show_menu(Menu.OPTIONS)

func close_options() -> void:
	if mode == Menu.OPTIONS:
		show_menu(options_return)
		options_button.grab_focus()

func restart_game() -> void:
	if restarting:
		return
	restarting = true
	restart_button.disabled = true
	call_deferred("reload_game")

func go_to_title() -> void:
	return_to_title = true
	restart_game()

func reload_game() -> void:
	Game.reset_run()
	Game.run_started = not return_to_title
	get_tree().paused = false
	var error := get_tree().reload_current_scene()
	if error != OK:
		restarting = false
		restart_button.disabled = false
		show_menu(Menu.TITLE)
		message.text = "Could not reload. Please try again."
		push_error("Failed to reload game scene: %s" % error)

func quit_game() -> void:
	if not OS.has_feature("web"):
		get_tree().quit()

func open_tutorial(return_menu: Menu) -> void:
	tutorial_page = 0
	tutorial_return = return_menu
	show_menu(Menu.TUTORIAL)

func show_help() -> void:
	if mode == Menu.TITLE or mode == Menu.PAUSE or mode == Menu.GAME_OVER:
		open_tutorial(mode)

func advance_tutorial() -> void:
	if mode != Menu.TUTORIAL:
		return
	if tutorial_page + 1 < TUTORIAL_PAGES.size():
		tutorial_page += 1
		update_tutorial_page()
	else:
		finish_tutorial()

func previous_tutorial_page() -> void:
	if mode == Menu.TUTORIAL and tutorial_page > 0:
		tutorial_page -= 1
		update_tutorial_page()

func update_tutorial_page() -> void:
	title.text = TUTORIAL_PAGES[tutorial_page].title
	tutorial_text.text = TUTORIAL_PAGES[tutorial_page].text
	tutorial_page_label.text = "%d / %d" % [tutorial_page + 1, TUTORIAL_PAGES.size()]
	tutorial_previous.disabled = tutorial_page == 0
	tutorial_button.text = "Next" if tutorial_page + 1 < TUTORIAL_PAGES.size() else ("Got it - start wave 1" if tutorial_return == Menu.PLAYING else "Got it")
	tutorial_button.grab_focus()
