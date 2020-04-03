extends Node2D

func _on_Timer_timeout():
	$AnimatedSprite.play("open")
	$Door/CollisionShape2D.position.y = 62

func get_map_data() -> Dictionary:
	return {
		"type": "StartCage",
		"position": [position.x, position.y]
	}

func load_map_data(item_data: Dictionary):
	position.x = item_data["position"][0]
	position.y = item_data["position"][1]

func quadtree_item_rect():
	return Rect2(position, Vector2(96, 144))
