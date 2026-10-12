class_name MiddleResourcesFrame
extends TextureRect

@onready var pumpkin_label: Label = %PumpkinLabel
@onready var planks_label: Label = %PlankLabel
@onready var gems_label: Label = %GemsLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.crystals_changed.connect(gems_changed)
	Game.planks_changed.connect(planks_changed)
	Game.pumpkins_changed.connect(pumpkins_changed)


func pumpkins_changed(current, _max):
	pumpkin_label.text = "x%02d" % current


func planks_changed(current, _max):
	planks_label.text = "x%02d" % current


func gems_changed(current, _max):
	gems_label.text = "x%02d" % current
