extends Node2D

# signal called when the game mode ends with a winner.
# @param(int[player_count]) kills - indexed by player index
# @param(int[player_count]) deaths - indexed by player index
# @param(int[player_count]) scores - indexed by player index, higher score is the winner
signal mode_ended

# _init is called when instancing a game mode.
# @impure
func _init(new_map: String, new_options = {}):
	pass

# start is called when all players are ready and the game is about to start.
# @impure
func start(player_count: int):
	pass

# spawn_player is called when game needs to spawn a player (first time).
# @impure
func spawn_player(index: int, player: Object, player_scene: Node2D):
	pass

# kill_player is called when game needs to kill a player.
# @impure
func kill_player(index: int, player: Object, player_scene: Node2D):
	pass

# respawn_player is called when game needs to respawn a player (often after kill/fall/death).
# @impure
func respawn_player(index: int, player: Object, player_scene: Node2D, last_safe_pos: Vector2):
	pass