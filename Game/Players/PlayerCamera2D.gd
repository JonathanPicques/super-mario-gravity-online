extends Camera2D

export var player_node_path: NodePath
export var tile_map_node_path: NodePath

var player_node: PlayerNode
var tile_map_node: TileMap
var tile_map_node_rect: Rect2

# _ready is called to restrict the camera bounds to the tilemap bounds.
# @impure
func _ready():
	player_node = get_node(player_node_path)
	tile_map_node = get_node(tile_map_node_path)
	if tile_map_node:
		tile_map_node_rect = tile_map_node.get_used_rect()
		limit_top = int(tile_map_node_rect.position.y * tile_map_node.cell_size.y)
		limit_left = int(tile_map_node_rect.position.x * tile_map_node.cell_size.x)
		limit_right = int(tile_map_node_rect.end.x * tile_map_node.cell_size.x)
		limit_bottom = int(tile_map_node_rect.end.y * tile_map_node.cell_size.y)

# _process is called on every tick to center the camera on the player.
# @impure
func _process(delta):
#	if player_node.state != player_node.PlayerState.death:
	position = player_node.position
