extends Control
class_name GameModeNode

const PlayerCamera := preload("res://Game/Players/PlayerCamera2D.tscn")

onready var MapSlot: MapNode = $GridContainer/Control1/ViewportContainer1/Viewport1/MapSlot
onready var Viewport1: Viewport = $GridContainer/Control1/ViewportContainer1/Viewport1
onready var Viewport2: Viewport = $GridContainer/Control2/ViewportContainer2/Viewport2
onready var Viewport3: Viewport = $GridContainer/Control3/ViewportContainer3/Viewport3
onready var Viewport4: Viewport = $GridContainer/Control4/ViewportContainer4/Viewport4

signal item_color_switch_trigger(color)

# options available in _ready.
# warning-ignore:unused_class_variable
export var options = {}

# map node
var map_node: MapNode

# start is called when the game mode starts.
# @abstract
func start():
	pass

# setup the split screen depending on the number of players.
# @impure
func setup_split_screen():
	var player_count := GameMultiplayer.get_local_player_count()
	
	# dezoom if there is more than 1 screen
	if player_count > 1:
		var pixel_ratio := 2
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP_WIDTH, Vector2(512 * pixel_ratio, 288 * pixel_ratio), 1)
	
	match player_count:
		1: 
			$GridContainer/Control2.visible = false
			$GridContainer/Control3.visible = false
			$GridContainer/Control4.visible = false
		2: 
			$GridContainer/Control3.visible = false
			$GridContainer/Control4.visible = false
			$GridContainer.margin_left = 256
			$GridContainer.margin_right = -256
		3: 
			$GridContainer/Control4.visible = false
	Viewport2.world_2d = Viewport1.world_2d
	Viewport3.world_2d = Viewport1.world_2d
	Viewport4.world_2d = Viewport1.world_2d

func get_player_screen_camera(player_id):
	match player_id:
		0: return Viewport1.get_node("PlayerCamera2D")
		1: return Viewport2.get_node("PlayerCamera2D")
		2: return Viewport3.get_node("PlayerCamera2D")
		3: return Viewport4.get_node("PlayerCamera2D")

# add a camera compatible with split screen for the given player.
# @impure
func add_player_screen_camera(player_id: int, player_node_path: NodePath):
	var player_camera_scene = PlayerCamera.instance()
	player_camera_scene.player_node_path = player_node_path
	player_camera_scene.tile_map_node_path = MapSlot.get_node("Map").Map.get_path()
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
	emit_signal("item_color_switch_trigger", color)


func _on_GameMode_tree_exiting():
	# reset zoom
	var pixel_ratio := 1
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP_WIDTH, Vector2(512 * pixel_ratio, 288 * pixel_ratio), 1)

