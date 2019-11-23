extends Control

onready var Game = get_node("/root/Game")

func _ready():
	match Game.GameMultiplayer.is_online():
		_: pass
	Game.GameMultiplayer.connect("online", self, "on_online")
	Game.GameMultiplayer.connect("offline", self, "on_offline")
	# start matchmaking
	Game.GameMultiplayer.matchmaking_start()

func on_online():
	pass

func on_offline():
	pass
