extends Control

onready var Game = get_node("/root/Game")

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Game.goto_main_menu_scene()
