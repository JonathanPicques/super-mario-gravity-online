extends Camera2D
class_name PlayerCameraNode

onready var player_id: int
onready var player_node: PlayerNode
onready var tile_map_node: TileMap
onready var tile_map_node_rect: Rect2

# _ready is called to restrict the camera bounds to the tilemap bounds.
# @impure
func _ready():
	# compute tile map boundaries to set camera limits
	if tile_map_node:
		tile_map_node_rect = tile_map_node.get_used_rect()
		limit_top = int(tile_map_node_rect.position.y * tile_map_node.cell_size.y)
		limit_left = int(tile_map_node_rect.position.x * tile_map_node.cell_size.x)
		limit_right = int(tile_map_node_rect.end.x * tile_map_node.cell_size.x)
		limit_bottom = int(tile_map_node_rect.end.y * tile_map_node.cell_size.y)
	# expand camera if the tile map is smaller than a screen
	if limit_right - limit_left < ProjectSettings.get_setting("display/window/size/width") or limit_bottom - limit_top < ProjectSettings.get_setting("display/window/size/height"):
		var start_cage_node = Game.map_node.ObjectSlot.get_node("StartCage")
		if start_cage_node:
			limit_top = start_cage_node.position.y - 512
			limit_left = start_cage_node.position.x - 512
			limit_right = start_cage_node.position.x + 512
			limit_bottom = start_cage_node.position.y + 512
	# connect listeners
	MultiplayerManager.connect("player_node_replaced", self, "on_player_node_replaced")

# _process is called on every tick to center the camera on the player.
# @impure
func _process(delta):
	if player_node.fsm.current_state_node != player_node.fsm.states.death:
		position = player_node.position

# on_player_node_replaced is called when a player changes its node (frog to prince, ...)
# @signal
# @impure
func on_player_node_replaced(player: Dictionary, new_player_node: PlayerNode, old_player_node: PlayerNode):
	if player.id == player_id:
		player_node = new_player_node
