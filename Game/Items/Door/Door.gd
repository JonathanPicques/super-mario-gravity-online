extends Node2D
class_name DoorNode

onready var Target = $Target

export var door_to_node_path: NodePath

var door_to_node = null

# @impure
func _ready():
	if door_to_node_path:
		door_to_node = get_node(door_to_node_path)

func get_map_data() -> Dictionary:
	return {
		"type": "Door",
		"position": [position.x, position.y],
		"door_to": "TODO"
	}

func load_map_data(item_data):
	position.x = item_data["position"][0]
	position.y = item_data["position"][1]

func quadtree_item_rect():
	return Rect2(position, Vector2(32, 48))
