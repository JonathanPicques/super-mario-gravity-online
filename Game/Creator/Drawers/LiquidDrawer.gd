extends DrawerNode

const MAX_WATER_CELLS := 200
var count := MAX_WATER_CELLS

export var tileset_type := "Water"

# @override
func fill_cell(pos: Vector2):
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts.tilemap.world_to_map(pos)
	count = MAX_WATER_CELLS
	fill_area(ts, cell_position, ts.tile, cell_position.y)

# @override
func clear_cell(pos: Vector2):
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts.tilemap.world_to_map(pos)
	count = MAX_WATER_CELLS
	fill_area(ts, cell_position, -1, cell_position.y)

# @override
func is_cell_free(pos: Vector2) -> bool:
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts.tilemap.world_to_map(pos)
	return ts.tilemap.get_cell(cell_position.x, cell_position.y) == -1

# @impure
func fill_area(ts, cell_position: Vector2, value: int, top_position: int):
	var wall_cell = creator.tilesets.Wall.tilemap.get_cell(cell_position.x, cell_position.y)
	var water_cell = ts.tilemap.get_cell(cell_position.x, cell_position.y)
	if wall_cell != -1 or water_cell != -1 or count < 0:
		return
	ts.tilemap.set_cell(cell_position.x, cell_position.y, value, false, false, false, Vector2(0, 0 if cell_position.y == top_position else 1))
	count -= 1
	fill_area(ts, Vector2(cell_position.x + 1, cell_position.y), value, top_position)
	fill_area(ts, Vector2(cell_position.x - 1, cell_position.y), value, top_position)
	fill_area(ts, Vector2(cell_position.x, cell_position.y + 1), value, top_position)
