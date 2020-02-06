extends Node

export var item_type := "ColorSwitch"

var placeholder: Node2D = null
var creator: GameModeNode = null

func _ready():
	placeholder = MapManager.create_item(item_type)
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
	print("Before ", creator.Quadtree.get_item(mouse_position) == null)
	if creator.Quadtree.get_item(mouse_position) == null and placeholder.visible:
		var item = MapManager.create_item(item_type)
		print("Create ", item_type, " ", creator.Quadtree.items.size(), " ", creator.Quadtree.get_item(mouse_position) == null)
		item.position.x = MapManager.snap_value(mouse_position.x)
		item.position.y = MapManager.snap_value(mouse_position.y)
		creator.map_node.ObjectSlot.add_child(item)
		creator.Quadtree.add_item(item)

func has_item(mouse_position):
	return get_item(mouse_position) != null

func remove_item(mouse_position):
	var item = creator.Quadtree.erase_item(mouse_position)
	if item:
		item.queue_free()

func get_item(mouse_position):
	return creator.Quadtree.get_item(mouse_position)
