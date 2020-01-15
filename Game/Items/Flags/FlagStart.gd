extends Node2D

func get_map_data() -> Dictionary:
	return {
		"type": "FlagStart",
		"x": position.x,
		"y": position.y
	}
