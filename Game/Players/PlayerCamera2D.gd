extends Camera2D

export var player_node_path: NodePath
export var tile_map_node_path: NodePath

export var restrict_tile_map := true

var player_node = null

# _ready is called to restrict the camera bounds to the tilemap bounds.
# @driven(lifecycle)
# @impure
func _ready():
	player_node = get_node(player_node_path)
	if restrict_tile_map:
		var tile_map_node = get_node(tile_map_node_path)
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

# _process is called on every tick to center the camera on the player.
# @driven(lifecycle)
# @impure
func _process(delta):
	if player_node.state != player_node.PlayerState.death:
		position = player_node.position
