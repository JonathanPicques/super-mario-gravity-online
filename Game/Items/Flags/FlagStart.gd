extends Node2D

func get_map_data() -> Dictionary:
	return {
		"type": "FlagStart",
		"position": [position.x, position.y]
	}

func load_map_data(item_data):
	position.x = item_data["position"][0]
	position.y = item_data["position"][1]

func quadtree_item_rect() -> Rect2:
	return Rect2(position, $Sprite.get_rect().size)
