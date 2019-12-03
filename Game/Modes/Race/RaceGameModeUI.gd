extends Control

onready var ObjectSkin = $ObjectBox/MarginContainer/ObjectSkin

export var player_id := 0

var player
var player_node

func _ready():
	player = GameMultiplayer.get_player(player_id)

func _process(delta: float):
	if player:
		$Ranking.text = "#%d" % (player.rank + 1)
		player_node = GameMultiplayer.get_player_node(player.id) # TODO: find a better way to assign only once
		if player_node.current_object:
			var object_sprite = player_node.current_object.get_node("Sprite")
			ObjectSkin.texture = object_sprite.texture
			if player_node.current_object.get("color") != null:
				GameConst.replace_skin(ObjectSkin, player_node.current_object.color)
		else:
			ObjectSkin.texture = null
