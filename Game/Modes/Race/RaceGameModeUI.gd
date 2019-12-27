extends Control

const Minifrog := preload("res://Game/Modes/Race/Minifrog/MiniFrog.tscn")

onready var MiniMap: TextureRect = $MiniMap
onready var MiniTween: Tween = $MiniMap/MiniTween
onready var MiniMapLeft: Node2D = $MiniMap/MiniMapLeft
onready var MiniMapRight: Node2D = $MiniMap/MiniMapRight
onready var MiniMapTimer: Timer = $MiniMap/MiniMapTimer

onready var PowerContainer = $PowerHUD/PowerContainer

var ui_player # player for whom this UI belongs
var ui_player_node
export var ui_player_id := 0

# @impure
func _ready():
	ui_player = MultiplayerManager.get_player(ui_player_id)
	# Spawn minifrogs
	for player in MultiplayerManager.get_players():
		on_player_added(player)
		on_player_set_skin(player, player.skin_id)
	# Connect listeners
	MultiplayerManager.connect("player_added", self, "on_player_added")
	MultiplayerManager.connect("player_removed", self, "on_player_removed")
	MultiplayerManager.connect("player_set_skin", self, "on_player_set_skin")
	# Show/hide minimap
	$MiniMap.visible = SettingsManager.values["minimap"]

# @impure
func _process(delta: float):
	if ui_player:
		$Ranking.text = "#%d" % (ui_player.rank + 1)
		ui_player_node = MultiplayerManager.get_player_node(ui_player.id) # TODO: find a better way to assign only once
		display_power_hud()

func display_power_hud():
	# if ui_player_node and ui_player_node.current_object_index != null:
		# var texture_rect = PowersManager.Powers[ui_player_node.current_object_index]["hud"].instance()
		# if PowerContainer.get_child_count() == 0:
			# PowerContainer.add_child(texture_rect)
	# else:
		# if PowerContainer.get_child_count() == 1:
			# PowerContainer.remove_child(PowerContainer.get_child(0))
	pass

# @impure
# @signal
func on_minimap_timer_timeout():
	if Game.game_mode_node.flag_distance == 0:
		return
	for player in MultiplayerManager.get_players():
		if player.rank_distance > 0:
			var mini_frog_node: Sprite = MiniMap.get_node(MultiplayerManager.get_player_node_name(player.id))
			if mini_frog_node:
				var left := MiniMapLeft.global_position.x
				var right := MiniMapRight.global_position.x
				var distance: float = clamp(lerp(right, left, player.rank_distance / Game.game_mode_node.flag_distance), left, right)
				MiniTween.interpolate_property(mini_frog_node, "global_position:x", null, distance, MiniMapTimer.wait_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
				MiniTween.start()

# on_player_added is called when a player joins by pressing accept.
# @signal
# @impure
func on_player_added(player: Dictionary):
	var mini_frog_node := Minifrog.instance()
	mini_frog_node.name = MultiplayerManager.get_player_node_name(player.id)
	mini_frog_node.position = MiniMapLeft.position
	MiniMap.add_child(mini_frog_node)

# on_player_added is called when a player leaves be pressing cancel.
# @signal
# @impure
func on_player_removed(player: Dictionary):
	var mini_frog_node: Sprite = MiniMap.get_node(MultiplayerManager.get_player_node_name(player.id))
	if mini_frog_node:
		MiniMap.remove_child(mini_frog_node)
		mini_frog_node.queue_free()

# on_player_set_skin is called when a player changes its skin.
# @signal
# @impure
func on_player_set_skin(player: Dictionary, skin_id: int):
	var mini_frog_node: Sprite = MiniMap.get_node(MultiplayerManager.get_player_node_name(player.id))
	if mini_frog_node:
		SkinManager.replace_skin(mini_frog_node, skin_id)
