extends Node2D

func _on_Area2D_body_entered(body):
	body.expulse_direction = Vector2(cos(rotation), sin(rotation))
	body.set_state(body.PlayerState.expulse)
	$AnimationPlayer.play("Trampoline")
