extends Control

onready var Game = get_node("/root/Game")
onready var MapSlot: Node2D = $MapSlot

# options available in _ready
export var options = {}

# start is called when the game mode starts.
# @abstract
func start():
	pass
