extends "res://Game/Modes/GameMode.gd"

var flag_end: Node2D
var flag_start: Node2D

# start is called when all peers are ready and the game is about to start.
# @impure
remote func start(map_path: String, peers: Dictionary):
	.start(map_path, peers)
	flag_end = map_scene.find_node("FlagEnd")
	flag_start = map_scene.find_node("FlagStart")
	if get_tree().is_network_server():
		for other_peer_id in peers:
			rpc("spawn_peer", peers[other_peer_id])
			spawn_peer(peers[other_peer_id])

# spawn_peer is called when game needs to spawn a peer (first time).
# @impure
remote func spawn_peer(peer: Dictionary):
	.spawn_peer(peer)
	var player_scene = load(Game.Players.get_player(peer.player_id).scene_path).instance()
	player_scene.position = flag_start.position
	player_scene.set_name(str(peer.id))
	player_scene.set_network_master(peer.id)
	add_child(player_scene)

# destroy_peer is called when game needs to destroy a disconnected peer.
# @impure
remote func destroy_peer(peer_id: int):
	.destroy_peer(peer_id)
	var player_scene = get_node(str(peer_id))
	remove_child(player_scene)
	player_scene.queue_free()