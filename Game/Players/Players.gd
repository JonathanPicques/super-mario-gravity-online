extends Object

var Players = [
	{
		name = "Mario",
		scene = "res://Game/Players/Mario/Mario.tscn",
		preview = "res://Game/Players/Mario/Textures/Stand/stand_01.png",
	},
	{
		name = "Luigi",
		scene = "res://Game/Players/Luigi/Luigi.tscn",
		preview = "res://Game/Players/Luigi/Textures/Stand/stand_01.png",
	}
]

# get_player returns the player at the given index.
# @pure
func get_player(index: int):
	return Players[index]

# get_next_player_index returns the next player index.
# @pure
func get_next_player_index(index: int):
	return (index + 1) % Players.size()

# get_prev_player_index returns the previous player index.
# @pure
func get_prev_player_index(index: int):
	return (index - 1) % Players.size()