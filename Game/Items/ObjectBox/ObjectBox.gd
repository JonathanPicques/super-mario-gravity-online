extends Node2D

func _on_Area2D_body_entered(body):
	body.get_object()
	queue_free()
