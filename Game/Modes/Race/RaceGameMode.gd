extends "res://Game/Modes/GameMode.gd"
class_name RaceGameModeNode

var flag_end_pos := Vector2()
var flag_distance := 0
var flag_start_pos := Vector2()

# _ready is called when this node is ready
# @impure
func _ready():
	map_node = load(options.map).instance()
	MapSlot.add_child(map_node)
	flag_end_pos = map_node.FlagEnd.position
	flag_distance = 0.0
	flag_start_pos = map_node.FlagStart.position
	call_deferred("compute_flag_distance")

# start is called when the game mode starts.
# @override
# @impure
func start():
	# setup split screen
	setup_split_screen()
	# create all players
	GameMultiplayer.spawn_player_nodes(map_node.PlayerSlot)
	# position players close to the flag
	for player in GameMultiplayer.get_players():
		var player_node: Node2D = GameMultiplayer.get_player_node(player.id)
		player_node.position = flag_start_pos
		player_node.position.x += max(player.peer_id - 1, 0) * 16 + player.local_id * 4
		add_player_screen_camera(player.id, player_node.get_path())
	# connect multiplayer signals
	GameMultiplayer.connect("player_removed", self, "on_player_removed")
	# compute player ranking locally
	$RankUpdateTimer.connect("timeout", self, "compute_player_ranking")
	$RankUpdateTimer.start()

# compute_flag_distance computes the distance between the start and end flag.
# @impure
func compute_flag_distance():
	var navigation_path := map_node.get_simple_path(Vector2(flag_start_pos.x, flag_start_pos.y - 10), Vector2(flag_end_pos.x, flag_end_pos.y - 10))
	var navigation_size := navigation_path.size()
	for i in range(0, navigation_size):
			var next := i + 1
			if next < navigation_size:
				flag_distance += navigation_path[i].distance_to(navigation_path[next])

# compute_player_ranking computes the distance from the goal and assign the players ranks.
# @impure
func compute_player_ranking():
	var sorted_players := []
	# compute distance from player node to the goal
	for player in GameMultiplayer.get_players():
		var player_node = GameMultiplayer.get_player_node(player.id)
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
		var player = GameMultiplayer.get_player(sorted_players[i].id)
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
	var player_node = GameMultiplayer.get_player_node(player.id)
	if player_node:
		player_node.queue_free()
		remove_player_screen_camera(player.id)
