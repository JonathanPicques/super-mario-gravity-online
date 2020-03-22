extends DrawerNode

export var tileset_type := "Water"

# @override
func action(pos: Vector2, drawer_index: int):
	var redo_fill_cell := []
	var undo_clear_cells := []
	var cell_positions := get_filled_cell_positions(pos)
	for cell_position in cell_positions:
		redo_fill_cell.push_back({"type": "fill_cell", "position": cell_position, "drawer_index": drawer_index})
		undo_clear_cells.push_back({"type": "clear_cell", "position": cell_position, "drawer_index": drawer_index})
	return {"undo": undo_clear_cells, "redo": redo_fill_cell}

# @override
func fill_cell(pos: Vector2):
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts.tilemap.world_to_map(pos)
	ts.tilemap.set_cell(cell_position.x, cell_position.y, ts.tile, false, false, false, Vector2(0, 0))

# @override
func clear_cell(pos: Vector2):
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts.tilemap.world_to_map(pos)
	ts.tilemap.set_cell(cell_position.x, cell_position.y, TileMap.INVALID_CELL, false, false, false, Vector2(0, 0))

# @override
func is_cell_free(pos: Vector2) -> bool:
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts.tilemap.world_to_map(pos)
	return ts.tilemap.get_cellv(cell_position) == TileMap.INVALID_CELL

# @pure
func get_filled_cell_positions(cell_position: Vector2, count = 200) -> Array:
	var cells := []
	
	# scan left and down to fill all tiles but walls
	for x in range(cell_position.x, cell_position.x - 20, -1):
		for y in range(cell_position.y, cell_position.y + 20):
			if is_cell_free_of_wall(x, y) and is_cell_free_of_water(x, y):
				cells.push_back(Vector2(x, y))
			else:
				y = cell_position.y + 20 # break
				
	# scan right and down to fill all tiles but walls
	for x in range(cell_position.x, cell_position.x + 20):
		for y in range(cell_position.y, cell_position.y + 20):
			if is_cell_free_of_wall(x, y) and is_cell_free_of_water(x, y):
				cells.push_back(Vector2(x, y))
			else:
				y = cell_position.y + 20 # break
	
	return cells

# @pure
func is_cell_free_of_wall(x: int, y: int) -> bool:
	return creator.tilesets.Wall.tilemap.get_cell(x, y) == TileMap.INVALID_CELL

# @pure
func is_cell_free_of_water(x: int, y: int) -> bool:
	return creator.tilesets.Water.tilemap.get_cell(x, y) == TileMap.INVALID_CELL
