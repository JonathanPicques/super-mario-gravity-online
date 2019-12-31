extends Node
class_name PowerNode

var on := false
var power_id: int
var player_node: PlayerNode
var power_hud_node: Node

# @abstract
func start_power():
	pass

# @abstract
func process_power(delta: float) -> bool:
	return false

# @abstract
func finish_power():
	pass

# @impure
func set_hud_progress(progress: float):
	var texture_rect: Control = power_hud_node.get_node("PowerProgressTextureRect")
	if texture_rect:
		texture_rect.rect_scale.x = progress
