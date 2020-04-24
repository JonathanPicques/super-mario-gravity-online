extends Node2D
class_name DoorNode

onready var Target = $Target

export var door_to_node_path: NodePath

var door_to_node = null
var door_pivot_offset := 6

# @impure
func _ready():
	if door_to_node_path:
		door_to_node = get_node(door_to_node_path)

func get_map_data() -> Dictionary:
	return {
		"type": "Door",
		"name": name,
		"position": [position.x, position.y],
		"door_to": door_to_node_path.get_name(door_to_node_path.get_name_count() - 1)
	}

func load_map_data(item_data):
	position.x = item_data["position"][0]
	position.y = item_data["position"][1]
	door_to_node_path = NodePath(String(get_parent().get_path()) + "/" + item_data["door_to"])
	door_to_node = get_parent().get_node(door_to_node_path)

func quadtree_item_rect() -> Rect2:
	return Rect2(position, Vector2(32, 64))
