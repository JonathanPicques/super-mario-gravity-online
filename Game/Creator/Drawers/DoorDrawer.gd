extends Node

var placeholder: Node2D = null
var creator: CreatorGameModeNode = null

func _ready():
	placeholder = MapManager.create_item("Door")
	placeholder.modulate = Color(1, 1, 1, 0.5)

func attach_creator(obj):
	creator = obj

func select_item():
	creator.CurrentItemSlot.add_child(placeholder)

func unselect_item():
	creator.CurrentItemSlot.remove_child(placeholder)

func get_offset():
	return 0

func create_item(mouse_position):
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


func has_item(mouse_position):
	return false # TODO: Use quadtree

func remove_item(mouse_position):
	var item = creator.Quadtree.erase_item(mouse_position)
	if item:
		print("item = ", item)
		yield(get_tree(), "idle_frame")
		item.queue_free() # is it actually working???

func get_item(mouse_position):
	return creator.Quadtree.get_item(mouse_position)
