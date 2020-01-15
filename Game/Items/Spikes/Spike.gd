extends Node2D

func _on_Area2D_body_entered(body):
	if body.is_in_group("PlayerNode"):
		body.apply_death(position + $DamageOrigin.position)

func get_map_data() -> Dictionary:
	return {
		"type": "Spike",
		"x": position.x,
		"y": position.y,
		"rotation": rotation_degrees
	}
