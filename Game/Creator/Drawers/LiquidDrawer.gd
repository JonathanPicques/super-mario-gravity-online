extends DrawerNode

export var tileset_type := "Water"

const MAX_WATER_CELLS := 1000

# @override
func action(pos: Vector2, drawer_index: int):
	var cell_positions := []
	var redo_fill_cell := []
	var undo_clear_cells := []
	fill_area(pos, cell_positions, pos)
	for cell_position in cell_positions:
		redo_fill_cell.push_back({"type": "fill_cell", "position": cell_position, "drawer_index": drawer_index})
		undo_clear_cells.push_back({"type": "clear_cell", "position": cell_position, "drawer_index": drawer_index})
	return {"undo": undo_clear_cells, "redo": redo_fill_cell}

# @override
func fill_cell(pos: Vector2):
	var tileset = creator.Tilesets[tileset_type]
	var cell_position = tileset.tilemap_node.world_to_map(pos)
	var x = cell_position.x
	var y = cell_position.y
	# creator.Quadtree.add_tile(pos)
	tileset.tilemap_node.set_cell(x, y, tileset.tile, false, false, false, get_autotile(tileset, cell_position.x, cell_position.y))
	if tileset.tilemap_node.get_cell(x - 1, y) != TileMap.INVALID_CELL:
		tileset.tilemap_node.set_cell(x - 1, y, tileset.tile, false, false, false, get_autotile(tileset, x - 1, y))
	if tileset.tilemap_node.get_cell(x + 1, y) != TileMap.INVALID_CELL:
		tileset.tilemap_node.set_cell(x + 1, y, tileset.tile, false, false, false, get_autotile(tileset, x + 1, y))
	if tileset.tilemap_node.get_cell(x, y + 1) != TileMap.INVALID_CELL:
		tileset.tilemap_node.set_cell(x, y + 1, tileset.tile, false, false, false, get_autotile(tileset, x, y + 1))
	

# @override
func clear_cell(pos: Vector2):
	var tileset = creator.Tilesets[tileset_type]
	var cell_position = tileset.tilemap_node.world_to_map(pos)
	# creator.Quadtree.erase_item(pos)
	tileset.tilemap_node.set_cell(cell_position.x, cell_position.y, TileMap.INVALID_CELL)

# @override
func is_cell_free(pos: Vector2) -> bool:
	var tileset = creator.Tilesets[tileset_type]
	var cell_position = tileset.tilemap_node.world_to_map(pos)
	return tileset.tilemap_node.get_cellv(cell_position) == TileMap.INVALID_CELL

# @pure
func fill_area(cell_position: Vector2, cells: Array, top_position: Vector2) -> bool:
	if cells.size() >= MAX_WATER_CELLS:
		cells.clear()
		return true
	if cell_position.y < top_position.y:
		return false
	var pos = creator.Tilesets.Wall.tilemap_node.world_to_map(cell_position)
	var wall_cell = creator.Tilesets.Wall.tilemap_node.get_cell(pos.x, pos.y)
	var water_cell = creator.Tilesets.Water.tilemap_node.get_cell(pos.x, pos.y)
	if wall_cell != TileMap.INVALID_CELL or water_cell != TileMap.INVALID_CELL:
		return false
	for cell in cells:
		if cell == cell_position:
			return false
	cells.push_back(cell_position)
	if fill_area(Vector2(cell_position.x + 16, cell_position.y), cells, top_position):
		return true
	if fill_area(Vector2(cell_position.x - 16, cell_position.y), cells, top_position):
		return true
	if fill_area(Vector2(cell_position.x, cell_position.y + 16), cells, top_position):
		return true
	if fill_area(Vector2(cell_position.x, cell_position.y - 16), cells, top_position):
		return true
	return false

# @pure
func get_autotile(tileset: Dictionary, x: int, y: int) -> Vector2: 
	return Vector2(0, 0 if tileset.tilemap_node.get_cell(x, y - 1) == TileMap.INVALID_CELL else 1)
