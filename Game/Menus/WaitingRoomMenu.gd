extends Control

onready var Game = get_node("/root/Game")

func _ready():
	match Game.GameMultiplayer.is_matchmaking_available():
		_: pass
	Game.GameMultiplayer.connect("matchmaking_online", self, "on_matchmaking_online")
	Game.GameMultiplayer.connect("matchmaking_offline", self, "on_matchmaking_offline")
	# start matchmaking
	Game.GameMultiplayer.start_matchmaker()

func on_matchmaking_online():
	pass

func on_matchmaking_offline():
	pass
