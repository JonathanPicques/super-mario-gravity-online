extends Camera2D

export var tile_map: NodePath
export var restrict_tile_map = true

# _ready is called to restrict the camera bounds to the tilemap bounds.
# @driven(lifecycle)
# @impure
func _ready():
	if restrict_tile_map:
		var tile_map_node = get_node(tile_map)
		if tile_map_node:
			var rect = Rect2()
			for tile_pos in tile_map_node.get_used_cells():
				if tile_pos.x < rect.position.x:
					rect.position.x = int(tile_pos.x)
				elif tile_pos.x > rect.end.x:
					rect.end.x = int(tile_pos.x)
				if tile_pos.y < rect.position.y:
					rect.position.y = int(tile_pos.y)
				elif tile_pos.y > rect.end.y:
					rect.end.y = int(tile_pos.y)
			limit_left = rect.position.x * tile_map_node.cell_size.x
			limit_right = (1 + rect.end.x) * tile_map_node.cell_size.x
			limit_top = rect.position.y * tile_map_node.cell_size.y
			limit_bottom = (1 + rect.end.y) * tile_map_node.cell_size.y
