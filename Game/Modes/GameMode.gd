extends Control

# mode_ended is emitted when the game mode ends with a winner.
# @param(int[peer_count]) kills - indexed by peer index
# @param(int[peer_count]) deaths - indexed by peer index
# @param(int[peer_count]) scores - indexed by peer index, higher score is the winner
signal mode_ended

# reference to Game.
onready var Game = get_node("/root/Game")

# reference to the loaded map.
var map_scene: Node2D

# start is called when all peers are ready and the game is about to start.
# @impure
remote func start(map_path: String, peers: Dictionary):
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != 1:
		return print("start(): warning sender is not server")
	map_scene = load(map_path).instance()
	add_child(map_scene)

# spawn_peer is called when game needs to spawn a peer (first time).
# @impure
remote func spawn_peer(peer: Dictionary):
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != 1:
		return print("spawn_peer(): warning sender is not server")

# kill_peer is called when game needs to kill a peer.
# @impure
remote func kill_peer(peer: Dictionary):
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != 1:
		return print("kill_peer(): warning sender is not server")

# respawn_peer is called when game needs to respawn a peer (often after kill/fall/death).
# @impure
remote func respawn_peer(peer: Dictionary, last_safe_pos: Vector2):
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != 1:
		return print("respawn_peer(): warning sender is not server")

# destroy_peer is called when game needs to destroy a disconnected peer.
# @impure
remote func destroy_peer(peer_id: int):
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != 1:
		return print("destroy_peer(): warning sender is not server")

# refresh_peer_position is called for refreshing peer position (1st, 2nd, 3rd, ...)
# @impure
master func refresh_peer_position(end_pos: Vector2):
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != 1:
		return print("refresh_peer_position(): warning sender is not server")
	for peer_id in Game.peers:
		var player_scene = get_node(str(peer_id))
		if player_scene != null:
			var navigation_path = map_scene.get_simple_path(player_scene.position, end_pos)
			var navigation_size = navigation_path.size()
			Game.peers[peer_id].position_length = 0
			for i in range(0, navigation_size):
				var next = i + 1
				if next < navigation_size:
					Game.peers[peer_id].position_length += navigation_path[i].distance_to(navigation_path[next])