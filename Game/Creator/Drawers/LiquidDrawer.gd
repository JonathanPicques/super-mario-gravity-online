extends Node

const MAX_WATER_CELLS = 200
var count = MAX_WATER_CELLS

export var tileset_type := "Wall"

onready var placeholder = Sprite.new()

var creator: Node2D = null

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
		count = MAX_WATER_CELLS
		fill_area(ts, cell_position)

func has_item(mouse_position):
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts[0].world_to_map(mouse_position)
	return ts[0].get_cell(cell_position.x, cell_position.y) != -1

func update_item_placeholder(mouse_position):
	if placeholder:
		placeholder.position.x = MapManager.snap_value(mouse_position[0]) + MapManager.ceil_size / 2
		placeholder.position.y = MapManager.snap_value(mouse_position[1]) + MapManager.ceil_size / 2
		placeholder.visible = mouse_position.y > 32 && mouse_position.y < 256

func remove_item(mouse_position):
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts[0].world_to_map(mouse_position)
	ts[0].set_cell(cell_position.x, cell_position.y, -1)
	ts[0].update_bitmask_area(cell_position)

func fill_area(ts, cell_position):
	var wall_cell = creator.Map.get_cell(cell_position.x, cell_position.y)
	var water_cell = ts[0].get_cell(cell_position.x, cell_position.y)
	if wall_cell != -1 or water_cell != -1 or count < 0:
		return
	ts[0].set_cell(cell_position.x, cell_position.y, ts[1])
#	ts[0].update_bitmask_area(cell_position)
	count -= 1
	fill_area(ts, Vector2(cell_position.x + 1, cell_position.y))
	fill_area(ts, Vector2(cell_position.x - 1, cell_position.y))
	fill_area(ts, Vector2(cell_position.x, cell_position.y + 1))

