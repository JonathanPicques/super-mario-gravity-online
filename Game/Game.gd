extends Control
class_name GameNode

const Map := preload("res://Game/Maps/Map.tscn")
const MapsMenu := preload("res://Game/Menus/MapsMenu.tscn")
const HomeMenu := preload("res://Game/Menus/HomeMenu.tscn")
const LobbyMenu := preload("res://Game/Menus/LobbyMenu.tscn")
const EndGameMenu := preload("res://Game/Menus/EndGameMenu.tscn")

onready var GameTween: Tween = $TransitionCanvasLayer/Tween
onready var TransitionColorRects = []

var map_node: MapNode
var scene_node: Node2D
var game_mode_node: GameModeNode

# _ready is called when the game node is ready.
# @impure
func _ready():
	scene_node = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
	map_node = scene_node
	VisualServer.set_default_clear_color(Color("#211F30"))
	for i in range(1, 39):
		TransitionColorRects.append(get_node("TransitionCanvasLayer/ColorRect%d" % i))

##########
# Scenes #
##########

# set_scene sets the current scene and frees the previous one.
# @impure
func set_scene(_scene_node: Node):
	if scene_node:
		get_tree().get_root().remove_child(scene_node)
		scene_node.queue_free()
	if _scene_node is MapNode:
		map_node = _scene_node
	scene_node = _scene_node
	get_tree().get_root().add_child(_scene_node)
	scene_node = _scene_node
	if _scene_node is GameModeNode:
		map_node = _scene_node.map_node

# @impure
func goto_home_menu_scene():
	yield(screen_transition_start(), "completed")
	set_scene(HomeMenu.instance())
	yield(screen_transition_finish(), "completed")

# @impure
func goto_game_mode_scene(game_mode_scene_path: String, options: Dictionary):
	game_mode_node = load(game_mode_scene_path).instance()
	game_mode_node.options = options
	yield(screen_transition_start(), "completed")
	set_scene(game_mode_node)
	game_mode_node.start()
	yield(screen_transition_finish(), "completed")

# @impure
func goto_lobby_menu_scene():
	yield(screen_transition_start(), "completed")
	set_scene(LobbyMenu.instance())
	yield(screen_transition_finish(), "completed")

# @impure
func goto_maps_menu_scene():
	yield(screen_transition_start(), "completed")
	set_scene(MapsMenu.instance())
	yield(screen_transition_finish(), "completed")

# @impure
func goto_end_game_room_menu_scene():
	yield(screen_transition_start(), "completed")
	set_scene(EndGameMenu.instance())
	yield(screen_transition_finish(), "completed")

##
# Transition
##

# @async
# @impure
func screen_transition_start():
	GameTween.remove_all()
	var delay = 0.0
	for rect in TransitionColorRects:
		GameTween.interpolate_property(rect, "rect_scale", null, Vector2.ONE, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN, delay)
		delay += 0.01

	GameTween.start()
	yield(GameTween, "tween_all_completed")

# @async
# @impure
func screen_transition_finish():
	GameTween.remove_all()
	var delay = 0.0
	for rect in TransitionColorRects:
		GameTween.interpolate_property(rect, "rect_scale", null, Vector2.ZERO, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT, delay)
		delay += 0.01
	GameTween.start()
	yield(GameTween, "tween_all_completed")
