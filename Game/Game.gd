extends Control
class_name GameNode

const Map := preload("res://Game/Maps/Map.tscn")
const MapsMenu := preload("res://Game/Menus/MapsMenu.tscn")
const YourMapsMenu := preload("res://Game/Menus/YourMapsMenu.tscn")
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
	# load transition nodes
	for i in range(1, 22):
		transition_nodes.append(get_node("TransitionCanvasLayer/TextureRect%d" % i))
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
func goto_select_map_scene(previous_scene = "Lobby"):
	var menu = YourMapsMenu.instance()
	menu.previous_scene = previous_scene
	yield(screen_transition_start(), "completed")
	set_scene(menu)
	yield(screen_transition_finish(), "completed")

# @impure
func goto_maps_menu_scene():
	yield(screen_transition_start(), "completed")
	set_scene(MapsMenu.instance())
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

# @async
# @impure
func screen_transition_start():
	GameTween.remove_all()
	var delay := 0.0
	for node in transition_nodes:
		GameTween.interpolate_property(node, "rect_scale", Vector2.ZERO, Vector2.ONE, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, delay)
		delay += 0.02
	GameTween.start()
	yield(GameTween, "tween_all_completed")

# @async
# @impure
func screen_transition_finish():
	GameTween.remove_all()
	var delay := 0.0
	for node in transition_nodes:
		GameTween.interpolate_property(node, "rect_scale", Vector2.ONE, Vector2.ZERO, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN, delay)
		delay += 0.02
	GameTween.start()
	yield(GameTween, "tween_all_completed")

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
