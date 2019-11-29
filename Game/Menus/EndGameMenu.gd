extends Control

onready var Game = get_node("/root/Game")
onready var EndGameRow = preload("res://Game/Menus/EndGameRow.tscn")

onready var Title = $MarginContainer/VBoxContainer/TitleMargin/Title
onready var Leaderboard = $MarginContainer/VBoxContainer/ContentMargin/HBoxContainer/LeaderBoardPanel/MarginContainer/Leaderboard
onready var TryAgainButton = $MarginContainer/VBoxContainer/ContentMargin/HBoxContainer/Buttons/TryAgainButton

func _ready():
	TryAgainButton.grab_focus()
	# TODO: sort player by A*
	var position := 0
	var players = Game.GameMultiplayer.players
	var player_name = players[0].name if players[0].name else "Unnamed"
	Title.text = player_name + " WINS!"
	for player in Game.GameMultiplayer.players:
		var player_row = EndGameRow.instance()
		position += 1
		player_row.set_player_data(player.name, player.skin_id, position)
		Leaderboard.add_child(player_row)

func _on_TryAgainButton_pressed():
	print("TODO: reload game")

func _on_MapsButton_pressed():
	print("TODO: choose map")

func _on_CharactersButton_pressed():
	Game.GameMultiplayer.finish_playing()
	Game.goto_lobby_scene()

func _on_HomeButton_pressed():
	Game.GameMultiplayer.finish_playing()
	Game.goto_main_menu_scene()
