extends DrawerNode

export var item_type := "SpikeBall"

# @override
func fill_cell(pos: Vector2):
	var item := MapManager.create_item(item_type)
	item.position.x = MapManager.snap_value(pos.x)
	item.position.y = MapManager.snap_value(pos.y)
	creator.map_node.ObjectSlot.add_child(item)
	creator.Quadtree.add_item(item)

# @override
func clear_cell(pos: Vector2):
	creator.Quadtree.erase_item(pos).queue_free()

# @override
func is_cell_free(pos: Vector2):
	var item := MapManager.create_item(item_type)
	var item_rect: Rect2 = item.quadtree_item_rect()
	item.queue_free()
	return creator.Quadtree.get_item(Rect2(pos, item_rect.size)) == null
