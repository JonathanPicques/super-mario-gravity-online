extends Object

var Players = [
	{
		name = "Mario",
		scene_path = "res://Game/Players/Mario/Mario.tscn",
		preview_path = "res://Game/Players/Mario/Textures/Stand/stand_01.png",
	},
	{
		name = "Luigi",
		scene_path = "res://Game/Players/Luigi/Luigi.tscn",
		preview_path = "res://Game/Players/Luigi/Textures/Stand/stand_01.png",
	}
]

# get_player returns the player for the given id.
# @pure
func get_player(id: int):
	return Players[id]

# get_next_player_index returns the next player id.
# @pure
func get_next_player_index(id: int):
	return (id + 1) % Players.size()

# get_prev_player_index returns the previous player id.
# @pure
func get_prev_player_index(id: int):
	return (id - 1) % Players.size()