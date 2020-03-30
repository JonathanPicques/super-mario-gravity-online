extends Node2D



func _on_Area2D_body_entered(body):
	$Bubble.visible = true
	print("Player entered!")


func _on_Area2D_body_exited(body):
	$Bubble.visible = false
	print("Player exited!")
