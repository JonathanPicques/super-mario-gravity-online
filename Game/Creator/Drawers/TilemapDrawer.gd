extends DrawerNode

export var tileset_type := "Wall"

# @override
func fill_cell(pos: Vector2):
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts.tilemap.world_to_map(pos)
	ts.tilemap.set_cell(cell_position.x, cell_position.y, ts.tile)
	ts.tilemap.update_bitmask_area(cell_position)

# @override
func clear_cell(pos: Vector2):
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts.tilemap.world_to_map(pos)
	ts.tilemap.set_cell(cell_position.x, cell_position.y, -1)
	ts.tilemap.update_bitmask_area(cell_position)

# @override
func is_cell_free(pos: Vector2):
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts.tilemap.world_to_map(pos)
	return ts.tilemap.get_cell(cell_position.x, cell_position.y) == -1
