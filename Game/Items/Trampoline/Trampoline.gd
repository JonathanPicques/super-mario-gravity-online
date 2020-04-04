extends Node2D

func _on_Area2D_body_entered(body):
	body.apply_expulse(Vector2(cos(rotation), sin(rotation)))
	$AnimationPlayer.play("Trampoline")

func get_map_data() -> Dictionary:
	return {
		"type": "Trampoline",
		"position": [position.x, position.y],
		"rotation": rotation_degrees
	}

func load_map_data(item_data):
	position.x = item_data["position"][0]
	position.y = item_data["position"][1]
	rotation_degrees = item_data["rotation"]

func quadtree_item_rect() -> Rect2:
	return Rect2(position, $Sprite.get_rect().size)
