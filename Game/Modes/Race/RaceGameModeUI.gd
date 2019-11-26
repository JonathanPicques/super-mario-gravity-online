extends Control

onready var Game = get_node("/root/Game")

export var player_id := 0

var player
var player_node

func _ready():
	player = Game.GameMultiplayer.get_player(player_id)

func _process(delta: float):
	if player:
		$Ranking.text = String(player.rank + 1) + "st"
		player_node = Game.GameMultiplayer.get_player_node(player.id) # TODO: find a better way to assign only once
		if player_node.current_object:
			var current = player_node.current_object
			$ObjectBox/MarginContainer/ObjectSkin.texture = player_node.current_object.get_node("Sprite").texture
		else:
			$ObjectBox/MarginContainer/ObjectSkin.texture = null
