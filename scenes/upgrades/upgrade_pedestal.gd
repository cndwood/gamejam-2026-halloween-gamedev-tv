class_name UpgradePedestal
extends Node2D

enum Upgrade { DASH, PLANK_SPEED, CANNON_SPEED, CANNON_DAMAGE, DOOR_HEALTH, PUMPKIN_SPEED }
@export var upgrade: Upgrade = Upgrade.DASH
@export var hover_height: float = 3.0
@export var hover_speed: float = 2.5
@export_range(8, 48, 8) var label_font_size: int = 24

@onready var icon: Sprite2D = $UpgradeIcon
@onready var label_anchor: Marker2D = $LabelAnchor
@onready var label: Label = $LabelLayer/Label
@onready var trigger: InteractTrigger = $InteractTrigger
var hover_origin: Vector2
var elapsed: float = 0.0

func _ready() -> void:
	label.add_theme_font_size_override("font_size", label_font_size)
	hover_origin = icon.position
	RenderingServer.frame_pre_draw.connect(update_label_position)
	Game.upgrade_changed.connect(_on_upgrade_changed)
	Game.crystals_changed.connect(_on_crystals_changed)
	Game.upgrades_reset.connect(update_label)
	update_label()
	update_label_position()

func _process(delta: float) -> void:
	update_label_position()
	elapsed += delta
	icon.position = hover_origin + Vector2(0, sin(elapsed * hover_speed) * hover_height)
	if Input.is_action_just_pressed("interact") and trigger.interactable:
		purchase()

func purchase() -> bool:
	if not Game.buy_upgrade(Game.UPGRADE_IDS[upgrade]):
		return false
	Music.play_effect(&"pumpkin_ready", global_position)
	return true

func update_label() -> void:
	var owned := Game.has_upgrade(Game.UPGRADE_IDS[upgrade])
	label.text = "%s\n%s" % [Game.UPGRADE_LABELS[upgrade], "Owned" if owned else "E: %d" % Game.UPGRADE_COSTS[upgrade]]
	label.modulate = Color.WHITE
	icon.modulate.a = 0.35 if owned else 1.0

func _on_upgrade_changed(_upgrade: StringName) -> void:
	update_label()

func _on_crystals_changed(_current: int, _maximum: int) -> void:
	update_label()

func update_label_position() -> void:
	# Project the world anchor into the viewport, then draw with UI-sized pixels.
	var screen_position := label_anchor.get_global_transform_with_canvas().origin
	label.position = (screen_position - Vector2(label.size.x * 0.5, label.size.y)).round()
	label.visible = is_visible_in_tree()
