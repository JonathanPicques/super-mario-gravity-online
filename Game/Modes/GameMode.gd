extends Control

# get a reference to the game
onready var Game = get_node("/root/Game")
# node to load the map in
onready var MapSlot: Node2D = $MapSlot

# options available in _ready
export var options = {}

# start is called when the game mode starts.
# @abstract
func start():
	pass