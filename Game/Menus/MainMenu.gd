extends Control

signal settings
signal new_game
signal join_game
signal create_map

func _ready():
	$MarginContainer/HBoxContainer/Buttons/NewGameButton.grab_focus()

func on_settings_button_pressed():
	emit_signal("settings")

func on_new_game_button_pressed():
	emit_signal("new_game")

func on_join_game_button_pressed():
	emit_signal("join_game")

func on_create_map_button_pressed():
	emit_signal("create_map")
