extends Node

export var item_type := "ColorSwitch"

var current_item: Node2D = null
var creator: Node2D = null

func attach_creator(obj):
	creator = obj

func select_item():
	current_item = MapManager.create_item(item_type)
	current_item.modulate = Color(1, 1, 1, 0.5)
	creator.CurrentItemSlot.add_child(current_item)

func unselect_item():
	creator.CurrentItemSlot.remove_child(current_item)
	current_item.queue_free()

func update_item_placeholder(mouse_position):
	if current_item:
		current_item.position.x = MapManager.snap_value(mouse_position[0])
		current_item.position.y = MapManager.snap_value(mouse_position[1])
	if mouse_position.y < 32 || mouse_position.y > 256:
		current_item.visible = false
	else:
		current_item.visible = true

func create_item(mouse_position):
	if current_item.visible:
		var item = MapManager.create_item(item_type)
		item.position = current_item.position
		creator.ObjectSlot.add_child(item)

func remove_item(mouse_position):
	var item = get_item(mouse_position)
	if item:
		print("item = ", item)

func get_item(mouse_position):
	var space_state = creator.get_world_2d().direct_space_state
	var result = space_state.intersect_ray(Vector2(0, 0), mouse_position)
	if result.has("collider"):
		return result.collider
	return null
