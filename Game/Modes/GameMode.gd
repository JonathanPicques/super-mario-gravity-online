extends Control

# mode_ended is emitted when the game mode ends with a winner.
# @param(int[peer_count]) kills - indexed by peer index
# @param(int[peer_count]) deaths - indexed by peer index
# @param(int[peer_count]) scores - indexed by peer index, higher score is the winner
signal mode_ended

# create is called when instancing a game mode.
# @impure
remote func create(map_path: String):
	pass

# start is called when all peers are ready and the game is about to start.
# @impure
remote func start():
	pass

# spawn_peer is called when game needs to spawn a peer (first time).
# @impure
remote func spawn_peer(peer: Dictionary):
	pass

# kill_peer is called when game needs to kill a peer.
# @impure
remote func kill_peer(peer: Dictionary):
	pass

# respawn_peer is called when game needs to respawn a peer (often after kill/fall/death).
# @impure
remote func respawn_peer(peer: Dictionary, last_safe_pos: Vector2):
	pass