extends DrawerNode

export var tileset_type := "Wall"

# @override
func action(pos: Vector2, drawer_index: int):
	return {
		"redo": [{"type": "fill_cell", "position": pos, "drawer_index": drawer_index}],
		"undo": [{"type": "clear_cell", "position": pos, "drawer_index": drawer_index}]
	}

# @override
func fill_cell(pos: Vector2):
	var ts = creator.Tilesets[tileset_type]
	var cell_position = ts.tilemap.world_to_map(pos)
	ts.tilemap.set_cell(cell_position.x, cell_position.y, ts.tile)
	ts.tilemap.update_bitmask_area(cell_position)
	creator.Quadtree.add_tile(pos)

# @override
func clear_cell(pos: Vector2):
	var ts = creator.Tilesets[tileset_type]
	var cell_position = ts.tilemap.world_to_map(pos)
	ts.tilemap.set_cell(cell_position.x, cell_position.y, TileMap.INVALID_CELL)
	ts.tilemap.update_bitmask_area(cell_position)
	creator.Quadtree.erase_item(pos)
