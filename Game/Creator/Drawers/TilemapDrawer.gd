extends DrawerNode

export var tileset_type := "Wall"

# @override
func action(type: int, pos: Vector2, drawer_index: int):
	match type:
		ActionType.fill:
			return {
				"redo": [{"type": "fill_cell", "position": pos, "drawer_index": drawer_index}],
				"undo": [{"type": "clear_cell", "position": pos, "drawer_index": drawer_index}],
			}
		ActionType.clear:
			return {
				"redo": [{"type": "clear_cell", "position": pos, "drawer_index": drawer_index}],
				"undo": [{"type": "fill_cell", "position": pos, "drawer_index": drawer_index}],
			}
	return .action(type, pos, drawer_index)

# @override
func fill_cell(pos: Vector2):
	var tileset = creator.Tilesets[tileset_type]
	var cell_position = tileset.tilemap_node.world_to_map(pos)
	creator.Quadtree.add_tile(pos, tileset)
	if tileset_type == "Oneway":
		MapManager.apply_oneway_autotile(Game.map_node, cell_position.x, cell_position.y, tileset.tile + creator.get_theme())
	else:
		tileset.tilemap_node.set_cell(cell_position.x, cell_position.y, tileset.tile + creator.get_theme())
		tileset.tilemap_node.update_bitmask_area(cell_position)

# @override
func clear_cell(pos: Vector2):
	var tileset = creator.Tilesets[tileset_type]
	var cell_position = tileset.tilemap_node.world_to_map(pos)
	creator.Quadtree.erase_item(pos)
	tileset.tilemap_node.set_cell(cell_position.x, cell_position.y, TileMap.INVALID_CELL)
	tileset.tilemap_node.update_bitmask_area(cell_position)

# @override
func is_cell_free(pos: Vector2):
	var tileset = creator.Tilesets[tileset_type]
	var cell_position = tileset.tilemap_node.world_to_map(pos)
	return tileset.tilemap_node.get_cellv(cell_position) == TileMap.INVALID_CELL

# @override
func can_draw_cell(pos: Vector2) -> bool:
	return not creator.Quadtree.has_item(Rect2(pos, Vector2(MapManager.cell_size, MapManager.cell_size)))
