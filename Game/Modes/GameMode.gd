extends Control

onready var Game = get_node("/root/Game")
onready var MapSlot: Node2D = $MapSlot
onready var GameModePositionTimer: Timer = $PositionTimer

var options: Dictionary
var map_scene: Navigation2D
var goal_position: Vector2

func _ready():
	# start timer for updating ranking on each timer tick.
	if get_tree().is_network_server():
		GameModePositionTimer.start()

# set_options is called when starting this game mode.
# @impure
func set_options(options: Dictionary):
	self.options = options

# net_compute_peer_ranking is called by the server for computing peers ranking (distance from the goal: 1st, 2nd, ...)
# @impure
master func net_compute_peer_ranking():
	var peers = Game.get_all_peers()
	var sorted_peers := []
	# compute distance from peer player scene to the goal
	for peer_id in peers:
		var player_scene := MapSlot.get_node(str(peer_id))
		if player_scene != null:
			var distance := 0
			var navigation_path := map_scene.get_simple_path(player_scene.position, goal_position)
			var navigation_size := navigation_path.size()
			for i in range(0, navigation_size):
				var next := i + 1
				if next < navigation_size:
					distance += navigation_path[i].distance_to(navigation_path[next])
			sorted_peers.push_back({id = peer_id, distance = distance})
	# sort peers by distance from the goal
	sorted_peers.sort_custom(self, "peer_position_sort")
	# rpc call on_net_computed_peer_positions to update all peer positions
	on_net_computed_peer_ranking(sorted_peers)
	rpc("on_net_computed_peer_ranking", sorted_peers)

# on_net_computed_peer_ranking is called by the server when peer ranking is updated (distance from the goal: 1st, 2nd, ...)
# @impure
remote func on_net_computed_peer_ranking(sorted_peers: Array):
	# checksum
	if not Game.is_rpc_sender_server():
		return print("on_net_computed_peer_ranking(): warning sender is not server")
	# save ranking
	for i in range(0, len(sorted_peers)):
		var peer: Dictionary = sorted_peers[i]
		if peer.id == Game.self_peer.id:
			Game.self_peer.player_ranking = i
		else:
			Game.other_peers[peer.id].player_ranking = i
	print("on_net_computed_peer_ranking: sorted_peers(", sorted_peers, ")")

# peer_position_sort is called as a sort comparator for sorting peers by position.
# @pure
func peer_position_sort(peer_a: Dictionary, peer_b: Dictionary):
	return peer_a.distance < peer_b.distance