extends Control

const Minifrog := preload("res://Game/Modes/Race/Minifrog/MiniFrog.tscn")

onready var MiniMap: TextureRect = $MiniMap
onready var MiniTween: Tween = $MiniMap/MiniTween
onready var MiniMapLeft: Node2D = $MiniMap/MiniMapLeft
onready var MiniMapRight: Node2D = $MiniMap/MiniMapRight
onready var MiniMapTimer: Timer = $MiniMap/MiniMapTimer
onready var PowerContainer: Control = $PowerHUD/PowerContainer

export var ui_player_id := 0 # player id for whom this UI belongs

var ui_player: Dictionary
var ui_player_node: PlayerNode

# @impure
func _ready():
	# Assign player
	var player = MultiplayerManager.get_player(ui_player_id)
	if player:
		ui_player = player
	# Spawn minifrogs
	for player in MultiplayerManager.get_players():
		on_player_added(player)
		on_player_set_skin(player, player.skin_id)
	# Connect listeners
	MultiplayerManager.connect("player_added", self, "on_player_added")
	MultiplayerManager.connect("player_removed", self, "on_player_removed")
	MultiplayerManager.connect("player_set_skin", self, "on_player_set_skin")
	MultiplayerManager.connect("player_node_spawned", self, "on_player_node_spawned")
	MultiplayerManager.connect("player_node_replaced", self, "on_player_node_replaced")
	# Show/hide minimap
	$MiniMap.visible = SettingsManager.values["minimap"]

# @impure
func _process(delta: float):
	if ui_player and Game.game_mode_node.started:
		$Ranking.text = "#%d" % (ui_player.rank + 1)
		display_power_hud()

# @impure
func display_power_hud():
	if ui_player_node and ui_player_node.power_node:
		var texture_rect = ui_player_node.power_hud_node
		if PowerContainer.get_child_count() == 0:
			PowerContainer.add_child(texture_rect)
	elif PowerContainer.get_child_count() == 1:
		PowerContainer.remove_child(PowerContainer.get_child(0))

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

# on_player_added is called when a player leaves by pressing cancel.
# @signal
# @impure
func on_player_removed(player: Dictionary):
	# clear player
	if player.id == ui_player_id:
		ui_player_node = null
	# add ui in minimap
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

# on_player_node_spawned is called when a player spawned its node.
# @signal
# @impure
func on_player_node_spawned(player: Dictionary, player_node: PlayerNode):
	if player.id == ui_player_id:
		ui_player_node = player_node

# on_player_node_replaced is called when a player changes its node (frog to prince, ...)
# @signal
# @impure
func on_player_node_replaced(player: Dictionary, new_player_node: PlayerNode, old_player_node: PlayerNode):
	if player.id == ui_player_id:
		ui_player_node = new_player_node
