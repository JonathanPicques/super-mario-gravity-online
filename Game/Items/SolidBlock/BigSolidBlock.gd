extends Node2D

func get_map_data() -> Dictionary:
	return {
		"type": "BigSolidBlock",
		"x": position.x,
		"y": position.y
	}
