extends Node2D

func _on_Area2D_body_entered(body):
	if body is PlayerNode:
		body.apply_death(position + $DamageOrigin.position)

func get_map_data() -> Dictionary:
	return {
		"type": "Spikes",
		"position": [position.x, position.y],
		"scale": [scale.x, scale.y],
		"rotation": rotation_degrees
	}

func load_map_data(item_data):
	rotation_degrees = item_data["rotation"]
	position.x = item_data["position"][0]
	position.y = item_data["position"][1]
	scale.x = item_data["scale"][0]
	scale.y = item_data["scale"][1]

func quadtree_item_rect() -> Rect2:
	return Rect2(position, Vector2(16, 16))
