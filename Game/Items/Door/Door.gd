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
	var node_name = get_node(door_to_node_path).name
	return {
		"type": "Door",
		"position": [position.x, position.y],
		"name": name,
		"door_to": get_node(door_to_node_path).name
	}

func load_map_data(item_data):
	position.x = item_data["position"][0]
	position.y = item_data["position"][1]
	var door_to_name = item_data["door_to"]
	if door_to_name:
		door_to_node_path = NodePath(String(get_parent().get_path()) + "/" + door_to_name)
		print("DOOR_PATH = ", door_to_node_path)
		door_to_node = get_parent().get_node(door_to_node_path)
		print("DOOR_NODE = ", door_to_node)

func quadtree_item_rect() -> Rect2:
	return Rect2(position, Vector2(32, 48))
