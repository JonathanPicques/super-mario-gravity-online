extends Node

# TODO use icon as placeholder

export var tileset_type := "Wall"

var creator: Node2D = null

func attach_creator(obj):
	creator = obj
	
func select_item():
	pass

func unselect_item():
	pass

func create_item(mouse_position):
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts[0].world_to_map(mouse_position)
	ts[0].set_cell(cell_position.x, cell_position.y, ts[1])
	ts[0].update_bitmask_area(cell_position)

func update_item_placeholder(mouse_position):
	pass

func remove_item(mouse_position):
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts[0].world_to_map(mouse_position)
	ts[0].set_cell(cell_position.x, cell_position.y, -1)
	ts[0].update_bitmask_area(cell_position)
