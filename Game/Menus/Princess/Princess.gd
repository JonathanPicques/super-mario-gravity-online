extends Node2D

# @impure
# @signal
func _on_Area2D_body_entered(body):
	# TODO: save winner in multiplayer
	print(MultiplayerManager.get_players(MultiplayerManager.SortPlayerMethods.ranked))
	print(MultiplayerManager.get_players(MultiplayerManager.SortPlayerMethods.ranked)[0].id)
	var player_node = MultiplayerManager.get_player_node(MultiplayerManager.get_players(MultiplayerManager.SortPlayerMethods.ranked)[0].id + 1)
	player_node.change_class(MultiplayerManager.PlayerClass.Frog)
	
	
