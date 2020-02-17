extends DrawerNode

var item_type := "SpikeBall"

func _ready():
	placeholder = MapManager.create_item(item_type)
	placeholder.modulate = Color(1, 1, 1, 0.5)

# @override
func has_item(mouse_position: Vector2):
	return creator.Quadtree.get_item(mouse_position) != null

# @override
func create_item(mouse_position: Vector2):
	if placeholder.visible and creator.Quadtree.get_item(mouse_position) == null:
		var item := MapManager.create_item(item_type)
		item.position.x = MapManager.snap_value(mouse_position.x)
		item.position.y = MapManager.snap_value(mouse_position.y)
		creator.map_node.ObjectSlot.add_child(item)
		creator.Quadtree.add_item(item)

# @override
func remove_item(mouse_position: Vector2):
	var item = creator.Quadtree.erase_item(mouse_position)
	if item:
		item.queue_free()
