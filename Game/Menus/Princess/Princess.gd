extends Node2D

# @impure
# @signal
var _transformed_in_prince := false
func _on_Area2D_body_entered(body):
	if not _transformed_in_prince:
		_transformed_in_prince = true
		# TODO: save winner in multiplayer
		print(MultiplayerManager.get_players(MultiplayerManager.SortPlayerMethods.ranked))
		print(MultiplayerManager.get_players(MultiplayerManager.SortPlayerMethods.ranked)[0].id)
		var player_node = MultiplayerManager.get_player_node(MultiplayerManager.get_players(MultiplayerManager.SortPlayerMethods.ranked)[0].id)
		player_node.set_class(MultiplayerManager.PlayerClass.Prince)
