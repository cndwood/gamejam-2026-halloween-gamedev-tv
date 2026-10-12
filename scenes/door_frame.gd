extends TextureRect

@export var type: Door.DoorType = Door.DoorType.LEFT
@onready var door_label: Label = %DoorLabel
@onready var texture_progress_bar: TextureProgressBar = %TextureProgressBar
@onready var door_health_label: Label = %DoorHealthLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if type == Door.DoorType.LEFT:
		door_label.text = "LEFT DOOR"
		Game.left_door_changed.connect(on_door_changed)
	else:
		door_label.text = "RIGHT DOOR"
		Game.right_door_changed.connect(on_door_changed)

func on_door_changed(current: int, max_hp: int):
	texture_progress_bar.value = float(current) / float(max_hp)
	door_health_label.text = "%d/%d" % [current, max_hp]
