extends Node2D

onready var Game = get_node("/root/Game")

func _on_Area2D_body_entered(body):
	get_parent().open_popup()
