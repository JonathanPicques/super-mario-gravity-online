extends Control

onready var Game = get_node("/root/Game")
onready var row_scene = preload("res://Game/Menus/EndGameRow.tscn")

func _ready():
	$MarginContainer/VBoxContainer/ContentMargin/HBoxContainer/Buttons/TryAgainButton.grab_focus()
	# TODO: sort player by A*
	var position := 0
	var players = Game.GameMultiplayer.players
	var player_name = players[0].name if players[0].name else "Unamed"
	$MarginContainer/VBoxContainer/TitleMargin/Title.text = player_name + " WINS!"
	for player in Game.GameMultiplayer.players:
		var player_row = row_scene.instance()
		print("Player = ", player)
		player_row.set_player_data(player.name, player.skin_id, position)
		print("After set ", player)
		position += 1
		var leaderboard_node = $MarginContainer/VBoxContainer/ContentMargin/HBoxContainer/LeaderBoardPanel/MarginContainer/Leaderboard
		leaderboard_node.add_child(player_row)

func _on_TryAgainButton_pressed():
	print("TODO: reload game")


func _on_MapsButton_pressed():
	print("TODO: choose map")


func _on_CharactersButton_pressed():
	Game.goto_characters_menu_scene()


func _on_HomeButton_pressed():
	Game.goto_main_menu_scene()
