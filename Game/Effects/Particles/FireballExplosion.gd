extends Node2D

func _ready():
	$AnimatedSprite.play("default")

func _on_Timer_timeout():
	queue_free()
