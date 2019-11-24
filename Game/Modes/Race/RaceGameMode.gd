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
	var flag_end_pos: Vector2 = map_scene.find_node("FlagEnd").position
	var flag_start_pos: Vector2 = map_scene.find_node("FlagStart").position
	# create all players
	for player in Game.GameMultiplayer.players:
		# create player node
		var player_node: Node2D = load(Game.skins[player.skin_id].node_path).instance()
		player_node.name = Game.GameMultiplayer.get_player_node_name(player.id)
		player_node.player = player
		player_node.position = flag_start_pos
		player_node.set_network_master(player.peer_id)
		# debug: offset players by peer_id and peer_player_id
		player_node.position.x += player.peer_id * 32 + player.peer_player_id * 8
		# add the player to the map
		MapSlot.add_child(player_node)
		# add the player camera
		add_player_screen_camera(player.id, player_node.get_path())
	# connect multiplayer signals
	Game.GameMultiplayer.connect("player_removed", self, "on_player_removed")
	# compute player ranking locally
	$RankUpdateTimer.connect("timeout", self, "compute_player_ranking", [flag_end_pos])
	$RankUpdateTimer.start()

# compute_player_ranking computes the distance from the goal and assign the players ranks.
# @impure
func compute_player_ranking(goal_position: Vector2):
	var sorted_players := []
	# compute distance from player node to the goal
	for player in Game.GameMultiplayer.players:
		var player_node = Game.GameMultiplayer.get_player_node(player.id)
		if player_node != null:
			var distance := 0.0
			var navigation_path := map_scene.get_simple_path(player_node.position, goal_position)
			var navigation_size := navigation_path.size()
			for i in range(0, navigation_size):
				var next := i + 1
				if next < navigation_size:
					distance += navigation_path[i].distance_to(navigation_path[next])
			sorted_players.push_back({id = player.id, distance = distance})
	# sort peers by distance from the goal
	sorted_players.sort_custom(self, "player_sort_by_distance")
	# assign player ranking
	for i in range(0, sorted_players.size()):
		var player = Game.GameMultiplayer.get_player(sorted_players[i].id)
		player.rank = i
		player.rank_distance = sorted_players[i].distance
		# print("player %d is #%d with a distance from flag of %d" % [player.id, (player.rank + 1), player.rank_distance])
		pass

# peer_position_sort is called as a sort comparator for sorting players by position.
# @pure
func player_sort_by_distance(player_a: Dictionary, player_b: Dictionary):
	return player_a.distance < player_b.distance 

# on_player_removed is called when a player is removed (usually disconnected from network.)
# driven(signal)
# @impure
func on_player_removed(player: Dictionary):
	# remove player nodes and cameras associated to the removed player
	var player_node = Game.GameMultiplayer.get_player_node(player.id)
	if player_node:
		player_node.queue_free()
		remove_player_screen_camera(player.id)
