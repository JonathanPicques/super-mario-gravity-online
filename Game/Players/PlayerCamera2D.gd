extends Camera2D
class_name PlayerCameraNode

export var player_node_path: NodePath
export var tile_map_node_path: NodePath

var player_id: int
var player_node: PlayerNode
var tile_map_node: TileMap
var tile_map_node_rect: Rect2

# _ready is called to restrict the camera bounds to the tilemap bounds.
# @impure
func _ready():
	# get player node
	player_node = MultiplayerManager.get_player_node(player_id)
	# get tile map node
	tile_map_node = get_node(tile_map_node_path)
	# compute tile map boundaries to set camera limits
	if tile_map_node:
		tile_map_node_rect = tile_map_node.get_used_rect()
		limit_top = int(tile_map_node_rect.position.y * tile_map_node.cell_size.y)
		limit_left = int(tile_map_node_rect.position.x * tile_map_node.cell_size.x)
		limit_right = int(tile_map_node_rect.end.x * tile_map_node.cell_size.x)
		limit_bottom = int(tile_map_node_rect.end.y * tile_map_node.cell_size.y)
	# connect listeners
	MultiplayerManager.connect("player_replaced_node", self, "on_player_replaced_node")

# _process is called on every tick to center the camera on the player.
# @impure
func _process(delta):
	if player_node.fsm.current_state_node != player_node.fsm.states.death:
		position = player_node.position

# on_player_replaced_node is called when a player changes its node (frog to prince, ...)
# @signal
# @impure
func on_player_replaced_node(player: Dictionary, new_player_node: PlayerNode, old_player_node: PlayerNode):
	if player.id == player_id:
		player_node = new_player_node
