extends Node2D

func _on_Area2D_body_entered(body):
	if body.is_in_group("PlayerNode"):
		body.apply_death(position + $DamageOrigin.position)

func get_map_data() -> Dictionary:
	return {
		"type": "Spike",
		"position": [position.x, position.y],
		"rotation": rotation_degrees
	}

func load_map_data(item_data):
	position.x = item_data["position"][0]
	position.y = item_data["position"][1]
	rotation = item_data["rotation"]

func quadtree_item_rect():
	return Rect2(position, $Sprite.get_rect().size)
