extends Control
class_name GameNode

const Map := preload("res://Game/Maps/Map.tscn")
const MapsMenu := preload("res://Game/Menus/MapsMenu.tscn")
const HomeMenu := preload("res://Game/Menus/HomeMenu.tscn")
const LobbyMenu := preload("res://Game/Menus/LobbyMenu.tscn")
const EndGameMenu := preload("res://Game/Menus/EndGameMenu.tscn")
const SettingsMenu := preload("res://Game/Menus/SettingsMenu.tscn")

onready var GameTween: Tween = $TransitionCanvasLayer/Tween
onready var GameTransitionCanvasLayer: CanvasLayer = $TransitionCanvasLayer

var is_over := false
var map_node: MapNode
var scene_node: Node2D
var game_mode_node: GameModeNode
var transition_nodes := []

# _ready is called when the game node is ready.
# @impure
func _ready():
	scene_node = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
	map_node = scene_node
	for i in range(1, 22):
		transition_nodes.append(get_node("TransitionCanvasLayer/TextureRect%d" % i))

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
		game_mode_node = null
	scene_node = _scene_node
	get_tree().get_root().add_child(_scene_node)
	scene_node = _scene_node
	if _scene_node is GameModeNode:
		map_node = _scene_node.map_node
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
# Collision layers
##

const COLLISION_LAYER_SOLID := 1 << 0
const COLLISION_LAYER_PLAYER := 1 << 1
const COLLISION_LAYER_DOOR := 1 << 3
const COLLISION_LAYER_DAMAGE := 1 << 6
const COLLISION_LAYER_STICKY := 1 << 7

# has_collision_layer_bit returns true if collision_layer has the given collision_layer_bit.
# @pure
func has_collision_layer_bit(collision_layer: int, collision_layer_bit: int) -> bool:
	return (collision_layer_bit & collision_layer) == collision_layer_bit
