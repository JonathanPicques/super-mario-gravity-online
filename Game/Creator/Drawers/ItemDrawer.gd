extends DrawerNode

export var item_type := "ColorSwitch"

# @override
func action(pos: Vector2, drawer_index: int):
	return {
		"redo": [{"type": "fill_cell", "position": pos, "drawer_index": drawer_index}],
		"undo": [{"type": "clear_cell", "position": pos, "drawer_index": drawer_index}]
	}

# @override
func fill_cell(pos: Vector2):
	var item := MapManager.create_item(item_type)
	item.position.x = pos.x
	item.position.y = pos.y
	creator.Quadtree.add_item(item)
	creator.map_node.ObjectSlot.add_child(item)

# @override
func clear_cell(pos: Vector2):
	creator.Quadtree.erase_item(pos).queue_free()

# @override
func is_cell_free(pos: Vector2):
	var item := MapManager.create_item(item_type)
	var item_rect: Rect2 = item.quadtree_item_rect()
	item.queue_free()
	if item_type == "SolidBlock":
		print(item_rect)
	return creator.Quadtree.get_item(Rect2(pos, item_rect.size)) == null
