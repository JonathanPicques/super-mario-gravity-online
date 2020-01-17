extends "res://Game/Modes/GameMode.gd"
class_name RaceGameModeNode

var flag_end_pos := Vector2()
var flag_distance := 0
var flag_start_pos := Vector2()

# @async
# @impure
func init():
	if options.has("map"):
		# load map node from godot path
		map_node = load(options.map).instance()
		# add map to game mode tree
		MapSlot.add_child(map_node)
		# wait for map to be ready
		yield(get_tree(), "idle_frame")
	elif options.has("map_path"):
		# load map node from file
		map_node = load("res://Game/Maps/Map.tscn").instance()
		# add map to game mode tree
		MapSlot.add_child(map_node)
		# wait for map to be ready
		yield(get_tree(), "idle_frame")
		# load map from file
		load_map(options.map_path)
	else:
		print("game mode init has no map")
		assert(false)
	# assign flag positions
	flag_end_pos = map_node.FlagEnd.position
	flag_distance = 0.0
	flag_start_pos = map_node.FlagStart.position
	# compute flag start to flag end distance
	compute_flag_distance()

# start is called when the game mode starts.
# @override
# @impure
func start():
	# setup split screen
	setup_split_screen()
	# create all players
	MultiplayerManager.spawn_player_nodes(map_node.PlayerSlot)
	# position players close to the flag
	for player in MultiplayerManager.get_players():
		var player_node: Node2D = MultiplayerManager.get_player_node(player.id)
		player_node.position = flag_start_pos
		player_node.position.x += max(player.peer_id - 1, 0) * 16 + player.local_id * 4
		add_player_screen_camera(player.id, player_node.get_path())
	# connect multiplayer signals
	MultiplayerManager.connect("player_removed", self, "on_player_removed")
	# compute player ranking locally
	$RankUpdateTimer.connect("timeout", self, "compute_players_ranking")
	$RankUpdateTimer.start()
	# game mode started
	.start()

# end_race is called when a player reaches the end flag and wins the game.
# @impure
func end_race(winner_player_id: int):
	# stop computing player ranks
	$RankUpdateTimer.stop()
	# compute player ranks immediately.
	compute_players_ranking()
	# goto end game scene.
	Game.goto_end_game_menu_scene()

# load_map loads a map given a map path.
# @impure
func load_map(map_path: String):
	var file := File.new()
	var open_result := file.open(map_path, File.READ)
	if open_result != OK:
		print("failed to load map %s" % map_path)
		return
	load_map_data(parse_json(file.get_line()))
	file.close()

# load_map loads a map given a map_data dictionary.
# @impure
func load_map_data(map_data: Dictionary):
	map_node.FlagEnd.position.x = map_data["flag_end"]["position"][0]
	map_node.FlagEnd.position.y = map_data["flag_end"]["position"][1]
	map_node.FlagStart.position.x = map_data["flag_start"]["position"][0]
	map_node.FlagStart.position.y = map_data["flag_start"]["position"][1]
	for tile in map_data["map"]:
		pass
		# map_node.Map.set_cell(tile[0], tile[1])
	for item_data in map_data["item_slot"]:
		MapManager.create_item(item_data["type"]).load_map_data(item_data)


# compute_flag_distance computes the distance between the start and end flag.
# @impure
func compute_flag_distance():
	var navigation_path := map_node.get_simple_path(Vector2(flag_start_pos.x, flag_start_pos.y - 10), Vector2(flag_end_pos.x, flag_end_pos.y - 10))
	var navigation_size := navigation_path.size()
	for i in range(0, navigation_size):
			var next := i + 1
			if next < navigation_size:
				flag_distance += navigation_path[i].distance_to(navigation_path[next])

# compute_players_ranking computes the distance from each player to the goal and assignes their ranks.
# @impure
func compute_players_ranking():
	var sorted_players := []
	# compute distance from player node to the goal
	for player in MultiplayerManager.get_players():
		var player_node = MultiplayerManager.get_player_node(player.id)
		if player_node:
			var distance := 0.0
			var navigation_path := map_node.get_simple_path(player_node.position, flag_end_pos)
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
		var player = MultiplayerManager.get_player(sorted_players[i].id)
		player.rank = i
		player.rank_distance = sorted_players[i].distance
		# print("player %d is #%d with a distance from flag of %d" % [player.id, (player.rank + 1), player.rank_distance])
		pass

# peer_position_sort is called as a sort comparator for sorting players by position.
# @pure
func player_sort_by_distance(player_a: Dictionary, player_b: Dictionary):
	return player_a.distance < player_b.distance 

# on_player_removed is called when a player is removed (usually disconnected from network.)
# @impure
# @signal
func on_player_removed(player: Dictionary):
	# remove player nodes and cameras associated to the removed player
	var player_node = MultiplayerManager.get_player_node(player.id)
	if player_node:
		player_node.queue_free()
		remove_player_screen_camera(player.id)
