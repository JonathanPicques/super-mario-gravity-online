extends DrawerNode

const MAX_WATER_CELLS := 200

export var value_type := "Water"

func _ready():
	print("Liquid icon")
#	$Icon.texture = MapManager.get_item_thumbnail(value_type, 0)

# @override
func action(type: int, pos: Vector2, drawer_index: int):
	match type:
		ActionType.fill:
			var cell_positions := []
			var redo_fill_cells := []
			var undo_clear_cells := []
			fill_area(pos, cell_positions, pos)
			for cell_position in cell_positions:
				redo_fill_cells.push_back({"type": "fill_cell", "position": cell_position, "drawer_index": drawer_index})
				undo_clear_cells.push_back({"type": "clear_cell", "position": cell_position, "drawer_index": drawer_index})
			return {"undo": undo_clear_cells, "redo": redo_fill_cells}
		ActionType.clear:
			var cell_positions := []
			var undo_fill_cells := []
			var redo_clear_cells := []
			clear_area(pos, cell_positions)
			for cell_position in cell_positions:
				undo_fill_cells.push_back({"type": "fill_cell", "position": cell_position, "drawer_index": drawer_index})
				redo_clear_cells.push_back({"type": "clear_cell", "position": cell_position, "drawer_index": drawer_index})
			return {"undo": undo_fill_cells, "redo": redo_clear_cells}
	return .action(type, pos, drawer_index)

# @override
func fill_cell(pos: Vector2):
	var tileset = creator.Tilesets[value_type]
	var cell_position = tileset.tilemap_node.world_to_map(pos)
	var x = cell_position.x
	var y = cell_position.y
	# TODO: handle other liquid than water
	MapManager.apply_water_autotile(Game.map_node, x, y)
	# creator.Quadtree.add_tile(pos, tileset)
#	tileset.tilemap_node.set_cell(x, y, tileset.tile, false, false, false, MapManager.get_autotile(tileset.tilemap_node, cell_position.x, cell_position.y))
#	if tileset.tilemap_node.get_cell(x - 1, y) != TileMap.INVALID_CELL:
#		tileset.tilemap_node.set_cell(x - 1, y, tileset.tile, false, false, false, MapManager.get_autotile(tileset.tilemap_node, x - 1, y))
#	if tileset.tilemap_node.get_cell(x + 1, y) != TileMap.INVALID_CELL:
#		tileset.tilemap_node.set_cell(x + 1, y, tileset.tile, false, false, false, MapManager.get_autotile(tileset.tilemap_node, x + 1, y))
#	if tileset.tilemap_node.get_cell(x, y + 1) != TileMap.INVALID_CELL:
#		tileset.tilemap_node.set_cell(x, y + 1, tileset.tile, false, false, false, MapManager.get_autotile(tileset.tilemap_node, x, y + 1))

# @override
func clear_cell(pos: Vector2):
	var tileset = creator.Tilesets[value_type]
	var cell_position = tileset.tilemap_node.world_to_map(pos)
	# creator.Quadtree.erase_item(pos)
	tileset.tilemap_node.set_cell(cell_position.x, cell_position.y, TileMap.INVALID_CELL)

# @override
func is_cell_free(pos: Vector2) -> bool:
	var tileset = creator.Tilesets[value_type]
	var cell_position = tileset.tilemap_node.world_to_map(pos)
	return tileset.tilemap_node.get_cellv(cell_position) == TileMap.INVALID_CELL

# @override
func can_draw_cell(pos: Vector2) -> bool:
	var tileset = creator.Tilesets[value_type]
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
func clear_area(cell_position: Vector2, cells: Array):
	var pos = creator.Tilesets.Wall.tilemap_node.world_to_map(cell_position)
	var water_cell = creator.Tilesets.Water.tilemap_node.get_cell(pos.x, pos.y)
	if water_cell == TileMap.INVALID_CELL:
		return
	for cell in cells:
		if cell == cell_position:
			return
	cells.push_back(cell_position)
	clear_area(Vector2(cell_position.x + 16, cell_position.y), cells)
	clear_area(Vector2(cell_position.x - 16, cell_position.y), cells)
	clear_area(Vector2(cell_position.x, cell_position.y + 16), cells)
	clear_area(Vector2(cell_position.x, cell_position.y - 16), cells)
