extends Node2D

func _on_Area2D_body_entered(body):
	print(round(global_rotation_degrees))
	$AnimationPlayer.play("Trampoline")
	if round(global_rotation_degrees) == 0:
		body.expulse_direction = Vector2.UP
	elif round(global_rotation_degrees) == 90:
		body.expulse_direction = Vector2.RIGHT
	elif round(global_rotation_degrees) == -180:
		body.expulse_direction = Vector2.DOWN
	elif round(global_rotation_degrees) == -90:
		body.expulse_direction = Vector2.LEFT
	body.set_state(body.PlayerState.expulse)
