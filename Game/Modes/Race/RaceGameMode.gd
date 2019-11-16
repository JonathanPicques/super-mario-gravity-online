extends "res://Game/Modes/GameMode.gd"

# map scene
var map_scene: Navigation2D

# _ready is called when this node is ready
# @driven(lifecycle)
# @impure
func _ready():
	map_scene = load(options.map).instance()
	MapSlot.add_child(map_scene)

# start is called when the game mode starts.
# @override
# @impure
func start():
	# cache start and end position
	var flag_end: Vector2 = map_scene.find_node("FlagEnd").position
	var flag_start: Vector2 = map_scene.find_node("FlagStart").position
	# create all peers
	var peers = Game.get_all_peers()
	for peer_id in peers:
		var peer: Dictionary = peers[peer_id]
		# create player scene
		var player_scene: Node2D = load(Game.players[peer.player_id].scene_path).instance()
		player_scene.name = str(peer.id)
		player_scene.position = flag_start
		player_scene.set_network_master(peer.id)
		# attach camera to our peer
		if peer.id == Game.self_peer.id:
			var player_camera_scene = Game.PlayerCamera.instance()
			player_camera_scene.tile_map = map_scene.get_node("Map").get_path()
			player_camera_scene.set_network_master(peer.id)
			player_scene.add_child(player_camera_scene)
		# add the player to the map
		MapSlot.add_child(player_scene)
