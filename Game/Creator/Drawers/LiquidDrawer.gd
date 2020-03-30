extends DrawerNode

export var tileset_type := "Water"

const MAX_WATER_CELLS := 1000

# @override
func action(pos: Vector2, drawer_index: int):
	var cell_positions := []
	var redo_fill_cell := []
	var undo_clear_cells := []
	fill_area(pos, cell_positions)
	for cell_position in cell_positions:
		redo_fill_cell.push_back({"type": "fill_cell", "position": cell_position, "drawer_index": drawer_index})
		undo_clear_cells.push_back({"type": "clear_cell", "position": cell_position, "drawer_index": drawer_index})
	return {"undo": undo_clear_cells, "redo": redo_fill_cell}

func get_autotile(ts, x, y) -> Vector2: 
	return Vector2(0, 0 if ts.tilemap.get_cell(x, y - 1) == TileMap.INVALID_CELL else 1)

# @override
func fill_cell(pos: Vector2):
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts.tilemap.world_to_map(pos)
	var x = cell_position.x
	var y = cell_position.y
	ts.tilemap.set_cell(x, y, ts.tile, false, false, false, get_autotile(ts, cell_position.x, cell_position.y))
	if ts.tilemap.get_cell(x - 1, y) != TileMap.INVALID_CELL:
		ts.tilemap.set_cell(x - 1, y, ts.tile, false, false, false, get_autotile(ts, x - 1, y))
	if ts.tilemap.get_cell(x + 1, y) != TileMap.INVALID_CELL:
		ts.tilemap.set_cell(x + 1, y, ts.tile, false, false, false, get_autotile(ts, x + 1, y))
	if ts.tilemap.get_cell(x, y + 1) != TileMap.INVALID_CELL:
		ts.tilemap.set_cell(x, y + 1, ts.tile, false, false, false, get_autotile(ts, x, y + 1))

# @override
func clear_cell(pos: Vector2):
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts.tilemap.world_to_map(pos)
	ts.tilemap.set_cell(cell_position.x, cell_position.y, TileMap.INVALID_CELL)
	ts.tilemap.update_bitmask_area(cell_position)

# @override
func is_cell_free(pos: Vector2) -> bool:
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts.tilemap.world_to_map(pos)
	return ts.tilemap.get_cellv(cell_position) == TileMap.INVALID_CELL

# @pure
func fill_area(cell_position: Vector2, cells: Array) -> bool:
	if cells.size() >= MAX_WATER_CELLS:
		cells.clear()
		return true
	var pos = creator.tilesets.Wall.tilemap.world_to_map(cell_position)
	var wall_cell = creator.tilesets.Wall.tilemap.get_cell(pos.x, pos.y)
	var water_cell = creator.tilesets.Water.tilemap.get_cell(pos.x, pos.y)
	if wall_cell != TileMap.INVALID_CELL or water_cell != TileMap.INVALID_CELL:
		return false
	for cell in cells:
		if cell == cell_position:
			return false
	cells.push_back(cell_position)
	if fill_area(Vector2(cell_position.x + 16, cell_position.y), cells):
		return true
	if fill_area(Vector2(cell_position.x - 16, cell_position.y), cells):
		return true
	if fill_area(Vector2(cell_position.x, cell_position.y + 16), cells):
		return true
	return false
