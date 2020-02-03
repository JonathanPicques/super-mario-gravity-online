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

func remove_item(mouse_position):
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts[0].world_to_map(mouse_position)
	ts[0].set_cell(cell_position.x, cell_position.y, -1)
	ts[0].update_bitmask_area(cell_position)
