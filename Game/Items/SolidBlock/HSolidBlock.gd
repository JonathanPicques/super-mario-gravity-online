extends Node2D

func get_map_data() -> Dictionary:
	return {
		"type": "HSolidBlock",
		"x": position.x,
		"y": position.y
	}
