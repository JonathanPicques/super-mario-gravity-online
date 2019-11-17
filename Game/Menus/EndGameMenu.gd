extends Control

onready var Game = get_node("/root/Game")

func _ready():
	$MarginContainer/VBoxContainer/ContentMargin/HBoxContainer/Buttons/TryAgainButton.grab_focus()

func _on_TryAgainButton_pressed():
	print("TODO: reload game")


func _on_MapsButton_pressed():
	print("TODO: choose map")


func _on_CharactersButton_pressed():
	Game.goto_characters_menu_scene()


func _on_HomeButton_pressed():
	Game.goto_main_menu_scene()
