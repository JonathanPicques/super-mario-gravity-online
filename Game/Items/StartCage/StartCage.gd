extends AnimatedSprite


func _on_Timer_timeout():
	play("open")
	$Door/CollisionShape2D.position.y = 62
