extends "res://Game/Modes/GameMode.gd"

onready var StageClearSFX: AudioStream = preload("res://Game/Modes/Race/Sounds/smb_stage_clear.ogg")
onready var PositionLabel: Label = $CanvasLayerUI/PositionLabel

# flag end node
var flag_end: Node2D
# flag start node
var flag_start: Node2D

# _process updates the self peer position in HUD.
# @driven(lifecycle)
# @impure
func _process(delta):
	if Game.peer.position_index != -1:
		PositionLabel.text = str(Game.peer.position_index + 1)

# start is called when all peers are ready and the game is about to start.
# @impure
remote func start(map_path: String, peers: Dictionary):
	.start(map_path, peers)
	flag_end = map_scene.find_node("FlagEnd")
	flag_start = map_scene.find_node("FlagStart")
	map_end_position = flag_end.position
	if get_tree().is_network_server():
		for peer_id in peers:
			rpc("spawn_peer", peers[peer_id])
			spawn_peer(peers[peer_id])
		flag_end.connect_flag_overlap(self, "on_flag_end_overlap")

# spawn_peer is called when game needs to spawn a peer (first time).
# @impure
remote func spawn_peer(peer: Dictionary):
	.spawn_peer(peer)
	var player_scene = load(Game.Players[peer.player_id].scene_path).instance()
	player_scene.position = flag_start.position
	player_scene.set_name(str(peer.id))
	player_scene.set_network_master(peer.id)
	if Game.peer.id == peer.id:
		var player_camera_scene = Game.PlayerCamera.instance()
		player_camera_scene.tile_map = MapSlot.get_child(0).find_node("Map").get_path()
		player_scene.add_child(player_camera_scene)
	MapSlot.add_child(player_scene)
	print("spawn peer: ", peer, flag_start.position)

# destroy_peer is called when game needs to destroy a disconnected peer.
# @impure
remote func destroy_peer(peer_id: int):
	.destroy_peer(peer_id)
	var player_scene = MapSlot.get_node(str(peer_id))
	remove_child(player_scene)
	player_scene.queue_free()

# on_flag_end_overlap is called when a player reaches the goal flag.
# @driven(signal)
# @impure
master func on_flag_end_overlap(body: PhysicsBody2D):
	var winner_peer_id := int(body.name)
	Game.play_sound_effect(StageClearSFX, -5)
	print(Game.peers[winner_peer_id], " won")
	for loser_peer_id in Game.peers:
		if loser_peer_id !=  winner_peer_id:
			kill_peer(Game.peers[loser_peer_id])