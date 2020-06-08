extends DrawerNode

export var value_type := "ColorSwitch"

func _ready():
	$Icon.texture = MapManager.get_item_thumbnail(value_type, 0)

# @override
func action(type: int, pos: Vector2, drawer_index: int):
	match type:
		ActionType.fill:
			return {
				"redo": [{"type": "fill_cell", "position": pos, "drawer_index": drawer_index}],
				"undo": [{"type": "clear_cell", "position": pos, "drawer_index": drawer_index}],
			}
		ActionType.clear:
			return {
				"redo": [{"type": "clear_cell", "position": pos, "drawer_index": drawer_index}],
				"undo": [{"type": "fill_cell", "position": pos, "drawer_index": drawer_index}],
			}
	return .action(type, pos, drawer_index)

# @override
func fill_cell(pos: Vector2):
	if value_type == "Door" and creator.filled:
		print("fill_cell: ", pos)
		creator.filled = false
	var map_item_node := MapManager.create_item_node(value_type)
	map_item_node.position.x = pos.x
	map_item_node.position.y = pos.y
	creator.Quadtree.add_map_item(map_item_node, value_type)
	Game.map_node.ObjectSlot.add_child(map_item_node)

# @override
func clear_cell(pos: Vector2):
	var item = creator.Quadtree.erase_item(pos)
	if value_type == "Door"  and creator.cleared:
		print("clear_cell: ", pos, item)
		creator.cleared = false
	item.map_item_node.queue_free()

# @override
func is_cell_free(pos: Vector2):
	var map_item_node := MapManager.create_item_node(value_type)
	var map_item_node_rect: Rect2 = map_item_node.quadtree_item_rect()
	#if map_item_node is DoorNode:
	#	print(map_item_node, " ", pos, " ", map_item_node_rect)
	map_item_node.queue_free()
	var item = creator.Quadtree.get_item(Rect2(pos, map_item_node_rect.size))
	return not item or item.type != QuadtreeNode.Types.map_item or item.map_item_type != value_type

# @override
func can_draw_cell(pos: Vector2) -> bool:
	var map_item_node := MapManager.create_item_node(value_type)
	var map_item_node_rect: Rect2 = map_item_node.quadtree_item_rect()
	map_item_node.queue_free()
	return not creator.Quadtree.has_item(Rect2(pos, map_item_node_rect.size))
