extends Control

onready var Game = get_node("/root/Game")
onready var MapSlot: Node2D = $MapSlot

signal item_color_switch_toggle

# options available in _ready
export var options = {}

# start is called when the game mode starts.
# @abstract
func start():
	pass

# toggle on on/off color switch for the given color
func item_color_switch_toggle(isOn: bool, color: int):
	emit_signal("item_color_switch_toggle", isOn, color)
