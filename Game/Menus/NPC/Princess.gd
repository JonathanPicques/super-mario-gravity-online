extends Node2D

# @async
# @impure
# @signal
var _transformed_in_prince := false
func _on_Area2D_body_entered(player_node):
	if not _transformed_in_prince:
		_transformed_in_prince = true
		player_node.kiss_the_princess = true
