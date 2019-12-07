extends Node

export var spawn_players_flag := true
export var spawn_players_node_format := "Player%dPosition"

# @impure
func _ready():
	yield(get_tree(), "idle_frame")
	# Spawn players
	for player in GameMultiplayer.get_players():
		on_player_added(player)
		on_player_set_skin(player, player.skin_id)
		on_player_set_ready(player, player.ready)
	# Connect listeners
	GameMultiplayer.connect("player_added", self, "on_player_added")
	GameMultiplayer.connect("player_removed", self, "on_player_removed")
	GameMultiplayer.connect("player_set_skin", self, "on_player_set_skin")
	GameMultiplayer.connect("player_set_ready", self, "on_player_set_ready")

# on_player_added is called when a player joins by pressing accept.
# @signal
# @impure
func on_player_added(player: Dictionary):
	var player_node := GameMultiplayer.spawn_player_node(player, Game.map_node.PlayerSlot)
	set_player_node_position(player, player_node)

# on_player_added is called when a player leaves be pressing cancel.
# @signal
# @impure
func on_player_removed(player: Dictionary):
	var player_node = GameMultiplayer.get_player_node(player.id)
	if player_node:
		player_node.queue_free()

# on_player_set_skin is called when a player changes its skin.
# @signal
# @impure
func on_player_set_skin(player: Dictionary, skin_id: int):
	var player_node = GameMultiplayer.get_player_node(player.id)
	if player_node:
		GameConst.replace_skin(player_node.PlayerSprite, skin_id)

# on_player_set_skin is called when a player changes its ready state.
# @signal
# @impure
func on_player_set_ready(player: Dictionary, ready: bool):
	var player_node = GameMultiplayer.get_player_node(player.id)
	if player_node:
		player_node.set_dialog(player_node.DialogType.ready if ready else player_node.DialogType.none)

# @impure
func set_player_node_position(player: Dictionary, player_node: PlayerNode):
	if spawn_players_flag:
		player_node.position = Game.map_node.FlagStart.position
	else:
		var node := get_parent().get_node(spawn_players_node_format % (player.id + 1))
		if node:
			player_node.position = node.position
