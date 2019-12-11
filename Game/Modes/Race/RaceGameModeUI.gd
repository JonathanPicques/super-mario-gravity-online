extends Control

onready var MiniMap: TextureRect = $MiniMap
onready var MiniFrog: Sprite = $MiniMap/MiniFrog
onready var MiniTween: Tween = $MiniMap/MiniTween
onready var MiniMapLeft: Node2D = $MiniMap/MiniMapLeft
onready var MiniMapRight: Node2D = $MiniMap/MiniMapRight
onready var MiniMapTimer: Timer = $MiniMap/MiniMapTimer
onready var ObjectSkin: TextureRect = $ObjectBox/MarginContainer/ObjectSkin

export var player_id := 0

var player
var player_node

# @impure
func _ready():
	player = GameMultiplayer.get_player(player_id)

# @impure
func _process(delta: float):
	if player:
		$Ranking.text = "#%d" % (player.rank + 1)
		player_node = GameMultiplayer.get_player_node(player.id) # TODO: find a better way to assign only once
		if player_node and player_node.current_object:
			var object_sprite = player_node.current_object.get_node("Sprite")
			ObjectSkin.texture = object_sprite.texture
			if player_node.current_object.get("color") != null:
				GameConst.replace_skin(ObjectSkin, player_node.current_object.color)
	else:
		ObjectSkin.texture = null

# @impure
func on_minimaptimer_timeout():
	if player and player_node and player.rank_distance > 0 and Game.game_mode_node.flag_distance > 0:
		var left := MiniMapLeft.global_position.x
		var right := MiniMapRight.global_position.x
		var distance: float = clamp(lerp(right, left, player.rank_distance / Game.game_mode_node.flag_distance), left, right)
		MiniTween.remove_all()
		MiniTween.interpolate_property(MiniFrog, "global_position:x", null, distance, MiniMapTimer.wait_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
		MiniTween.start()
