extends Node2D

func _on_Area2D_body_entered(body):
	body.apply_expulse(Vector2(cos(rotation), sin(rotation)))
	$AnimationPlayer.play("Trampoline")

func get_map_data() -> Dictionary:
	return {
		"type": "Trampoline",
		"x": position.x,
		"y": position.y,
		"rotation": rotation_degrees
	}
