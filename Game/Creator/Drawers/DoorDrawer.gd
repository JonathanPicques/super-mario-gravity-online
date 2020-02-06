extends DrawerNode

func _ready():
	placeholder = MapManager.create_item("Door")
	placeholder.modulate = Color(1, 1, 1, 0.5)

# @override
func has_item(mouse_position: Vector2):
	return creator.Quadtree.get_item(mouse_position) != null

# @override
func create_item(mouse_position: Vector2):
	if !has_item(mouse_position) and placeholder.visible:
		var first_door: DoorNode = MapManager.create_item("Door")
		first_door.position = placeholder.position
		var second_door: DoorNode = MapManager.create_item("Door")
		second_door.position = placeholder.position + Vector2(32, 32)
		
		first_door.door_to_node_path = second_door.get_path()
		second_door.door_to_node_path = first_door.get_path()

		creator.map_node.ObjectSlot.add_child(first_door)
		creator.Quadtree.add_item(first_door)		
		creator.map_node.ObjectSlot.add_child(second_door)
		creator.Quadtree.add_item(second_door)


# @override
func remove_item(mouse_position: Vector2):
	var item = creator.Quadtree.erase_item(mouse_position)
	if item:
		item.queue_free()
