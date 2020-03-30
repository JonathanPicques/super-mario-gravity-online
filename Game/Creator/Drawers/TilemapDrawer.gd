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
	var tileset = creator.Tilesets[tileset_type]
	var cell_position = tileset.tilemap_node.world_to_map(pos)
	creator.Quadtree.add_tile(pos)
	tileset.tilemap_node.set_cell(cell_position.x, cell_position.y, tileset.tile)
	tileset.tilemap_node.update_bitmask_area(cell_position)

# @override
func clear_cell(pos: Vector2):
	var tileset = creator.Tilesets[tileset_type]
	var cell_position = tileset.tilemap_node.world_to_map(pos)
	creator.Quadtree.erase_item(pos)
	tileset.tilemap_node.set_cell(cell_position.x, cell_position.y, TileMap.INVALID_CELL)
	tileset.tilemap_node.update_bitmask_area(cell_position)
