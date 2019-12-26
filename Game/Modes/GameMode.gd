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

# @impure
func set_pixel_ratio(pixel_ratio: float):
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP_WIDTH, Vector2(512 * pixel_ratio, 288 * pixel_ratio), 1)
	Game.GameTransitionCanvasLayer.scale = Vector2(pixel_ratio, pixel_ratio)
	$Popup.rect_scale = Vector2(pixel_ratio, pixel_ratio)

# setup_split_screen splits the screen between local players.
# @impure
func setup_split_screen():
	var player_count := MultiplayerManager.get_local_player_count()
	# dezoom if there is more than 1 screen
	if player_count > 1:
		set_pixel_ratio(2.0)
	# clone parallax for each screen
	var parallax_node = Game.map_node.ParallaxSlot
	Game.map_node.remove_child(parallax_node)
	# adjust split screen layout
	match player_count:
		1:
			Viewport1.add_child(parallax_node.duplicate())
			$GridContainer/Control2.visible = false
			$GridContainer/Control3.visible = false
			$GridContainer/Control4.visible = false
			$GridContainer/Control1.rect_size = Vector2(512, 288)
			$GridContainer/Control1.rect_min_size = Vector2(512, 288)
		2: 
			Viewport1.add_child(parallax_node.duplicate())
			Viewport2.add_child(parallax_node.duplicate())
			$GridContainer.margin_left = 256
			$GridContainer.margin_right = -256
			$GridContainer/Control3.visible = false
			$GridContainer/Control4.visible = false
			Viewport2.world_2d = Viewport1.world_2d
		3: 
			Viewport1.add_child(parallax_node.duplicate())
			Viewport2.add_child(parallax_node.duplicate())
			Viewport3.add_child(parallax_node.duplicate())
			$GridContainer.columns = 2
			$GridContainer/Control4.visible = false
			Viewport2.world_2d = Viewport1.world_2d
			Viewport3.world_2d = Viewport1.world_2d
		4:
			Viewport1.add_child(parallax_node.duplicate())
			Viewport2.add_child(parallax_node.duplicate())
			Viewport3.add_child(parallax_node.duplicate())
			Viewport4.add_child(parallax_node.duplicate())
			$GridContainer.columns = 2
			Viewport2.world_2d = Viewport1.world_2d
			Viewport3.world_2d = Viewport1.world_2d
			Viewport4.world_2d = Viewport1.world_2d
	# clear map parallax
	parallax_node.queue_free()

# apply_split_screen_effect toggles the wave distort effect for the given player.
# @impure
func apply_split_screen_effect(player_id: int, wave: bool):
	match player_id:
		0: Viewport1.get_parent().material.set_shader_param("enabled", 1 if wave else 0)
		1: Viewport2.get_parent().material.set_shader_param("enabled", 1 if wave else 0)
		2: Viewport3.get_parent().material.set_shader_param("enabled", 1 if wave else 0)
		3: Viewport4.get_parent().material.set_shader_param("enabled", 1 if wave else 0)

# get_player_screen_camera returns 
# @pure
func get_player_screen_camera(player_id: int):
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

# @impure
func _on_GameMode_tree_exiting():
	set_pixel_ratio(1.0)

##
# Popup
##

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_popup(!$Popup.visible)

func toggle_popup(is_open):
	$Popup/ContinueButton.grab_focus()
	$Popup.visible = is_open

# block_input is used to avoid calling finish_playing multiple times.
var block_input := false
	
func _on_ContinueButton_pressed():
	$Popup.visible = false

func _on_HomeButton_pressed():
	if not block_input:
		block_input = true
		MultiplayerManager.finish_playing()
		Game.goto_home_menu_scene()
