extends Node2D

func _on_Area2D_body_entered(body):
	Game.call_deferred("goto_end_game_room_menu_scene")
