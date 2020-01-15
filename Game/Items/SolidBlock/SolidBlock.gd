extends Node2D

func get_map_data() -> Dictionary:
	return {
		"type": "SolidBlock",
		"position": [position.x, position.y]
	}

func load_map_data(item_data):
	position.x = item_data["position"][0]
	position.y = item_data["position"][1]