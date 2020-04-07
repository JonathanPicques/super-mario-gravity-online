extends Control
class_name GameNode

var ADMIN = false # Set to true to show and edit system map in creator

const Map := preload("res://Game/Maps/Map.tscn")
const OpenMapsMenu := preload("res://Game/Menus/OpenMapsMenu.tscn")
const SelectMapsMenu := preload("res://Game/Menus/SelectMapsMenu.tscn")
const HomeMenu := preload("res://Game/Menus/HomeMenu.tscn")
const LobbyMenu := preload("res://Game/Menus/LobbyMenu.tscn")
const EndGameMenu := preload("res://Game/Menus/EndGameMenu.tscn")
const SettingsMenu := preload("res://Game/Menus/SettingsMenu.tscn")

onready var GameTween: Tween = $TransitionCanvasLayer/Tween
onready var GameTransitionCanvasLayer: CanvasLayer = $TransitionCanvasLayer

var is_over := false
var map_node: MapNode
var scene_node: Node
var game_mode_node: GameModeNode
var transition_nodes := []

# _ready is called when the game node is ready.
# @impure
func _ready():
	scene_node = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
	# if the opened scene is a map
	if scene_node is MapNode:
		map_node = scene_node

##########
# Scenes #
##########

# set_scene sets the current scene and frees the previous one.
# _scene_node can either be a map, menu or game mode
# @impure
func set_scene(_scene_node: Node):
	if scene_node:
		get_tree().get_root().remove_child(scene_node)
		scene_node.queue_free()
	if _scene_node is MapNode:
		map_node = _scene_node
		game_mode_node = null
	scene_node = _scene_node
	get_tree().get_root().add_child(_scene_node)
	scene_node = _scene_node
	if _scene_node is GameModeNode:
		map_node = null
		game_mode_node = _scene_node

# @impure
func goto_home_menu_scene():
	yield(screen_transition_start(), "completed")
	set_scene(HomeMenu.instance())
	yield(screen_transition_finish(), "completed")

# @impure
func goto_game_mode_scene(game_mode_scene_path: String, options: Dictionary):
	Game.is_over = false
	game_mode_node = load(game_mode_scene_path).instance()
	game_mode_node.options = options
	yield(screen_transition_start(), "completed")
	set_scene(game_mode_node)
	yield(game_mode_node.init(), "completed")
	game_mode_node.start()
	yield(screen_transition_finish(), "completed")

# @impure
func goto_creator_scene():
	goto_game_mode_scene("res://Game/Creator/Creator.tscn", {})

# @impure
func goto_lobby_menu_scene():
	yield(screen_transition_start(), "completed")
	set_scene(LobbyMenu.instance())
	yield(screen_transition_finish(), "completed")

# @impure
func goto_select_map_scene():
	yield(screen_transition_start(), "completed")
	set_scene(SelectMapsMenu.instance())
	yield(screen_transition_finish(), "completed")

# @impure
func goto_open_map_scene():
	yield(screen_transition_start(), "completed")
	set_scene(OpenMapsMenu.instance())
	yield(screen_transition_finish(), "completed")


# @impure
func goto_end_game_menu_scene():
	yield(screen_transition_start(), "completed")
	set_scene(EndGameMenu.instance())
	yield(screen_transition_finish(), "completed")

# @impure
func goto_settings_menu_scene():
	yield(screen_transition_start(), "completed")
	set_scene(SettingsMenu.instance())
	yield(screen_transition_finish(), "completed")

##
# Transition
##

const TRANSITION_DURATION = 0.5

# @async
# @impure
func screen_transition_start():
	$TransitionCanvasLayer/ColorRect.visible = true
	GameTween.remove_all()
	GameTween.interpolate_property($TransitionCanvasLayer/ColorRect, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), TRANSITION_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
	GameTween.start()
	yield(GameTween, "tween_all_completed")

# @async
# @impure
func screen_transition_finish():
	GameTween.remove_all()
	GameTween.interpolate_property($TransitionCanvasLayer/ColorRect, "color", Color(0, 0, 0, 1), Color(0, 0, 0, 0), TRANSITION_DURATION, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	GameTween.start()
	yield(GameTween, "tween_all_completed")
	$TransitionCanvasLayer/ColorRect.visible = false

##
# Physics layers
##

const PHYSICS_LAYER_SOLID := 0
const PHYSICS_LAYER_PLAYER := 1
const PHYSICS_LAYER_ENEMY := 2
const PHYSICS_LAYER_DOOR := 3
const PHYSICS_LAYER_POWER := 4
const PHYSICS_LAYER_OBJECT := 5
const PHYSICS_LAYER_DAMAGE := 6
const PHYSICS_LAYER_STICKY := 7
const PHYSICS_LAYER_WATER := 8
