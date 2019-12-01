extends Control
class_name GameModeNode

onready var Game = get_node("/root/Game")
onready var MapSlot: Node2D = $SplitScreenContainer/RowContainer1/ColumnContainer1/Control1/ViewportContainer1/Viewport1/MapSlot

onready var Viewport1 = $SplitScreenContainer/RowContainer1/ColumnContainer1/Control1/ViewportContainer1/Viewport1
onready var Viewport2 = $SplitScreenContainer/RowContainer1/ColumnContainer1/Control2/ViewportContainer2/Viewport2
onready var Viewport3 = $SplitScreenContainer/RowContainer2/ColumnContainer2/Control3/ViewportContainer3/Viewport3
onready var Viewport4 = $SplitScreenContainer/RowContainer2/ColumnContainer2/Control4/ViewportContainer4/Viewport4

const PlayerCamera := preload("res://Game/Players/PlayerCamera2D.tscn")

signal item_color_switch_trigger(color)

# options available in _ready.
# warning-ignore:unused_class_variable
export var options = {}

# start is called when the game mode starts.
# @abstract
func start():
	pass

# setup the split screen depending on the number of players.
# @impure
func setup_split_screen():
	var player_count = Game.GameMultiplayer.get_local_player_count() # Game.GameMultiplayer.players.size()
	match player_count:
		1: 
			$SplitScreenContainer/RowContainer2.visible = false
			$SplitScreenContainer/RowContainer1/ColumnContainer1/Control2.visible = false
		2: 
			$SplitScreenContainer/RowContainer2.visible = false
		3: 
			$SplitScreenContainer/RowContainer2/ColumnContainer2/Control4.visible = false
	Viewport2.world_2d = Viewport1.world_2d
	Viewport3.world_2d = Viewport1.world_2d
	Viewport4.world_2d = Viewport1.world_2d

# add a camera compatible with split screen for the given player.
# @impure
func add_player_screen_camera(player_id: int, player_node_path: NodePath):
	var player_camera_scene = PlayerCamera.instance()
	player_camera_scene.player_node_path = player_node_path
	player_camera_scene.tile_map_node_path = MapSlot.get_node("Map").Tilemap.get_path()
	match player_id:
		0: Viewport1.add_child(player_camera_scene)
		1: Viewport2.add_child(player_camera_scene)
		2: Viewport3.add_child(player_camera_scene)
		3: Viewport4.add_child(player_camera_scene)

# add a camera compatible with split screen for the given player.
# @impure
func remove_player_screen_camera(player_id: int):
	match player_id:
		0:
			var camera_node = Viewport1.get_node("PlayerCamera2D")
			if camera_node:
				camera_node.queue_free()
		1:
			var camera_node = Viewport2.get_node("PlayerCamera2D")
			if camera_node:
				camera_node.queue_free()
		2:
			var camera_node = Viewport3.get_node("PlayerCamera2D")
			if camera_node:
				camera_node.queue_free()
		3:
			var camera_node = Viewport4.get_node("PlayerCamera2D")
			if camera_node:
				camera_node.queue_free()

# trigger color switch for the given color.
# @impure
func item_color_switch_trigger(color: int):
	print("emit signal item_color_switch_trigger ", color)
	emit_signal("item_color_switch_trigger", color)
