extends Node

export var item_type := "ColorSwitch"

var placeholder: Node2D = null
var creator: Node2D = null

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
		placeholder.visible = mouse_position.y > 32 && mouse_position.y < 256

func create_item(mouse_position):
	if placeholder.visible:
		var item = MapManager.create_item(item_type)
		item.position = placeholder.position
		creator.ObjectSlot.add_child(item)
		creator.quadtree_append(item)

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
