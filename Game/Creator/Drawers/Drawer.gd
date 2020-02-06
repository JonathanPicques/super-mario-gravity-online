extends Control
class_name DrawerNode

onready var creator: CreatorGameModeNode = Game.game_mode_node
var placeholder: Node2D = null

# @abstract
func has_item(mouse_position: Vector2) -> bool:
	return false

# @abstract
func create_item(mouse_position: Vector2) -> void:
	pass

# @abstract
func remove_item(mouse_position: Vector2) -> void:
	pass

# @abstract
func get_item_pivot() -> Vector2:
	return Vector2(0, 0)

# @abstract
func select_drawer():
	creator.CurrentItemSlot.add_child(placeholder)

# @abstract
func unselect_drawer():
	creator.CurrentItemSlot.remove_child(placeholder)
