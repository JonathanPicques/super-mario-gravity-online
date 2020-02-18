extends DrawerNode

export var item_type := "ColorSwitch"

# @override
func fill_cell(pos: Vector2):
	var item := MapManager.create_item(item_type)
	item.position.x = pos.x
	item.position.y = pos.y
	creator.map_node.ObjectSlot.add_child(item)
	creator.Quadtree.add_item(item)

# @override
func clear_cell(pos: Vector2):
	creator.Quadtree.erase_item(pos).queue_free()

# @override
func is_cell_free(pos: Vector2):
	return creator.Quadtree.get_item(pos) == null
