extends Node2D

# @impure
# @signal
var _transformed_in_prince := false
func _on_Area2D_body_entered(body):
	if not _transformed_in_prince:
		_transformed_in_prince = true
		var player_node = MultiplayerManager.get_player_node(MultiplayerManager.get_players(MultiplayerManager.SortPlayerMethods.ranked)[0].id)
		var new_player_node = player_node.set_class(MultiplayerManager.PlayerClass.Prince)
		new_player_node.set_deferred("has_trail", false)
		new_player_node.set_deferred("has_lifetime", false)
		new_player_node.set_deferred("speed_multiplier", 1.0)
