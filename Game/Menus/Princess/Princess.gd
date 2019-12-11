extends Node2D

# @impure
# @signal
func _on_Area2D_body_entered(body):
	Game.map_node.open_popup()
