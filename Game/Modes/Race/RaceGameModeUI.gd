extends Control

onready var Game = get_node("/root/Game")

export var player_id := 0

var player

func _ready():
	player = Game.GameMultiplayer.get_player(player_id)

func _process(delta: float):
	if player:
		$Ranking.text = String(player.rank + 1) + "st"
