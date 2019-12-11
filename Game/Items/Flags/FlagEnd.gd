extends Node2D

var used := false

func _on_Area2D_body_entered(body):
	if not used:
		used = true
		Game.call_deferred("goto_end_game_room_menu_scene")
