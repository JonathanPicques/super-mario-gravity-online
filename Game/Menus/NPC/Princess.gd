extends Node2D

# @async
# @impure
# @signal
var _transformed_in_prince := false
func _on_Area2D_body_entered(player_node):
	if not _transformed_in_prince:
		_transformed_in_prince = true
		var new_player_node = yield(player_node.set_transformation(MultiplayerManager.PlayerTransformationType.Prince), "completed")
		new_player_node.has_trail = 0
		new_player_node.speed_multiplier = 1.0
