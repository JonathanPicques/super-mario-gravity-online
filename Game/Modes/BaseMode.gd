extends Node2D

# signal called when the game mode ends with a winner
# @param(int[player_count]) kills - indexed by player index
# @param(int[player_count]) deaths - indexed by player index
# @param(int[player_count]) scores - indexed by player index, higher score is the winner
signal mode_ended

# _init is called when instancing a game mode.
# @param(string) map
# @param(object) options
# @impure
func _init(new_map, new_options = {}):
	pass

# start is called when all players are ready and the game is about to start.
# @param(int) player_count
# @impure
func start(player_count):
	pass

# spawn_player is called when game needs to spawn a player (first time).
# @param(int) index
# @param(object) player
# @param(Node2D) player_scene
# @impure
func spawn_player(index, player, player_scene):
	pass

# kill_player is called when game needs to kill a player.
# @param(int) index
# @param(object) player
# @param(Node2D) player_scene
# @impure
func kill_player(index, player, player_scene):
	pass

# respawn_player is called when game needs to respawn a player (often after kill/fall/death).
# @param(int) index
# @param(object) player
# @param(Node2D) player_scene
# @param(Vector2) last_safe_pos
# @impure
func respawn_player(index, player, player_scene, last_safe_pos):
	pass