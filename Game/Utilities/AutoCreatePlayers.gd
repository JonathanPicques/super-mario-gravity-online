extends Node

export var spawn_players_flag := true
export var spawn_players_node_format := "Player%dPosition"

# @impure
func _ready():
	yield(get_tree(), "idle_frame")
	# Spawn players
	for player in MultiplayerManager.get_players():
		on_player_added(player)
		on_player_set_skin(player, player.skin_id)
		on_player_set_ready(player, player.ready)
	# Connect listeners
	MultiplayerManager.connect("player_added", self, "on_player_added")
	MultiplayerManager.connect("player_removed", self, "on_player_removed")
	MultiplayerManager.connect("player_set_skin", self, "on_player_set_skin")
	MultiplayerManager.connect("player_set_ready", self, "on_player_set_ready")
	MultiplayerManager.connect("player_set_peer_id", self, "on_player_set_peer_id")

# on_player_added is called when a player joins.
# @signal
# @impure
func on_player_added(player: Dictionary):
	var player_node := MultiplayerManager.spawn_player_node(player)
	set_player_node_position(player, player_node)

# on_player_removed is called when a player leaves.
# @signal
# @impure
func on_player_removed(player: Dictionary):
	var player_node = MultiplayerManager.get_player_node(player.id)
	if player_node:
		player_node.queue_free()

# on_player_set_skin is called when a player changes its skin.
# @signal
# @impure
func on_player_set_skin(player: Dictionary, skin_id: int):
	var player_node = MultiplayerManager.get_player_node(player.id)
	if player_node:
		SkinManager.replace_skin(player_node.PlayerSprite, skin_id)

# on_player_set_skin is called when a player changes its ready state.
# @signal
# @impure
func on_player_set_ready(player: Dictionary, ready: bool):
	var player_node = MultiplayerManager.get_player_node(player.id)
	var is_lead = MultiplayerManager.get_lead_player().id == player.id
	if player_node:
		player_node.set_dialog(player_node.DialogType.ready if ready else player_node.DialogType.none, is_lead and ready)

# on_player_set_peer_id is called when a players sets its peer and local id.
# @signal
# @impure
func on_player_set_peer_id(player: Dictionary, peer_id: int, local_id: int):
	# TODO: clean up this mess
	# This is used to migrate a local player to a network player
	for i in range(0, Game.map_node.PlayerSlot.get_child_count()):
		var player_node: PlayerNode = Game.map_node.PlayerSlot.get_child(i)
		if player_node is PlayerNode and player_node.player.id == player.id:
			# patch the player node name for rpc to work
			player_node.name = MultiplayerManager.get_player_node_name(player.id)
			# enable process to send state
			player_node.set_process(true)
			# enable network master for rpc to work
			player_node.set_network_master(peer_id)

# @impure
func set_player_node_position(player: Dictionary, player_node: PlayerNode):
	if spawn_players_flag:
		player_node.position = Game.map_node.FlagStart.position
	else:
		var node := get_parent().get_node(spawn_players_node_format % (player.id + 1))
		if node:
			player_node.position = node.position
