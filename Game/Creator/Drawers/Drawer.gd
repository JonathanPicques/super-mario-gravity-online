extends Control
class_name DrawerNode

enum ActionType { fill, move, clear, change }

onready var creator: CreatorGameModeNode = Game.game_mode_node

# @abstract
func action(type: int, pos: Vector2, drawer_index: int) -> Dictionary:
	return {"undo": [], "redo": []}

# @abstract
func fill_cell(pos: Vector2) -> void:
	pass

# @abstract
func clear_cell(pos: Vector2) -> void:
	pass

# @abstract
func move_cell(from_pos: Vector2, dest_pos: Vector2) -> void:
	pass

# @abstract
func change_cell(pos: Vector2, variation: int) -> void:
	pass

# @abstract
func is_cell_free(pos: Vector2) -> bool:
	return false

# @abstract
func can_draw_cell(pos: Vector2) -> bool:
	return false
