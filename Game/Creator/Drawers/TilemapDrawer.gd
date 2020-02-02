extends Node

export var tileset_type := "Wall"

onready var placeholder = Sprite.new()

var creator: GameModeNode = null

func attach_creator(obj):
	creator = obj
	placeholder.texture = creator.tilesets[tileset_type][2]
	placeholder.modulate = Color(1, 1, 1, 0.5)
	
func select_item():
	creator.CurrentItemSlot.add_child(placeholder)

func unselect_item():
	creator.CurrentItemSlot.remove_child(placeholder)

func create_item(mouse_position):
	if !has_item(mouse_position) and placeholder.visible:
		var ts = creator.tilesets[tileset_type]
		var cell_position = ts[0].world_to_map(mouse_position)
		ts[0].set_cell(cell_position.x, cell_position.y, ts[1])
		ts[0].update_bitmask_area(cell_position)

func has_item(mouse_position):
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts[0].world_to_map(mouse_position)
	return ts[0].get_cell(cell_position.x, cell_position.y) != -1

func update_item_placeholder(mouse_position):
	if placeholder:
		placeholder.position.x = MapManager.snap_value(mouse_position[0]) + MapManager.ceil_size / 2
		placeholder.position.y = MapManager.snap_value(mouse_position[1]) + MapManager.ceil_size / 2
		var local_mouse_position = get_viewport().get_mouse_position()
		placeholder.visible = creator.HUDQuadtree.get_item(local_mouse_position) == null

func remove_item(mouse_position):
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts[0].world_to_map(mouse_position)
	ts[0].set_cell(cell_position.x, cell_position.y, -1)
	ts[0].update_bitmask_area(cell_position)
