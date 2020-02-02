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

func update_item_placeholder(mouse_position):
	if placeholder:
		placeholder.position.x = MapManager.snap_value(mouse_position[0])
		placeholder.position.y = MapManager.snap_value(mouse_position[1])
		
		var local_mouse_position = get_viewport().get_mouse_position()
		placeholder.visible = creator.HUDQuadtree.get_item(local_mouse_position) == null

func create_item(mouse_position):
	if !has_item(mouse_position) and placeholder.visible:
		var item = MapManager.create_item(item_type)
		item.position = placeholder.position
		creator.ObjectSlot.add_child(item)
		creator.Quadtree.add_item(item)

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
