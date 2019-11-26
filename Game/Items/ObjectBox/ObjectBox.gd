extends Node2D

func _on_Area2D_body_entered(body):
	if body.current_object == null:
		body.get_object()
		queue_free()
