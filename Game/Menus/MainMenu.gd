extends Control

onready var Game = get_node("/root/Game")

func _ready():
	$MarginContainer/HBoxContainer/Buttons/NewGameButton.grab_focus()

func _on_NewGameButton_pressed():
	Game.goto_characters_menu_scene()

func _on_JoinGameButton_pressed():
	Game.goto_join_menu_scene()

func _on_SettingsButton_pressed():
	print("Open settings")


func _on_ExitButton_pressed():
	get_tree().quit()
