extends Node2D
class_name DoorNode

onready var Target = $Target

export var door_to_node_path: NodePath

var door_to_node = null

# @impure
func _ready():
	if door_to_node_path:
		door_to_node = get_node(door_to_node_path)
