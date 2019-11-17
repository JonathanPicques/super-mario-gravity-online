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
	# setup split screen
	setup_split_screen()
	# cache start and end position
	var flag_end: Vector2 = map_scene.find_node("FlagEnd").position
	var flag_start: Vector2 = map_scene.find_node("FlagStart").position
	# create all players
	for player in Game.GameMultiplayer.players:
		# create player node
		var player_node: Node2D = load(Game.skins[player.skin_id].node_path).instance()
		player_node.name = str(player.peer_id)
		player_node.position = flag_start
		player_node.player_id = player.id
		player_node.set_network_master(player.peer_id)
		print("peer id is ", player.peer_id)
		# add the player to the map
		MapSlot.add_child(player_node)
		# add the player camera
		add_player_screen_camera(player.id, player_node.get_path())
