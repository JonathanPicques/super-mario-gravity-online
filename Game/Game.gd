extends Control
class_name GameNode

const Map := preload("res://Game/Maps/Map.tscn")
const MapsMenu := preload("res://Game/Menus/MapsMenu.tscn")
const HomeMenu := preload("res://Game/Menus/HomeMenu.tscn")
const LobbyMenu := preload("res://Game/Menus/LobbyMenu.tscn")
const EndGameMenu := preload("res://Game/Menus/EndGameMenu.tscn")

var map_node: MapNode
var scene_node: Node2D
var game_mode_node: GameModeNode

# _ready is called when the game node is ready.
# @driven(lifecycle)
# @impure
func _ready():
	scene_node = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
	map_node = scene_node
	VisualServer.set_default_clear_color(Color("#211F30"))

##########
# Scenes #
##########

# set_scene sets the current scene and frees the previous one.
# @impure
func set_scene(_scene_node: Node):
	if scene_node:
		get_tree().get_root().remove_child(scene_node)
		scene_node.queue_free()
	get_tree().get_root().add_child(_scene_node)
	scene_node = _scene_node

# @impure
func goto_home_menu_scene():
	set_scene(HomeMenu.instance())

# @impure
func goto_game_mode_scene(_game_mode_node: GameModeNode):
	game_mode_node = _game_mode_node
	set_scene(_game_mode_node)
	map_node = _game_mode_node.map_node

# @impure
func goto_lobby_menu_scene():
	var lobby_node := LobbyMenu.instance()
	map_node = lobby_node
	set_scene(lobby_node)

# @impure
func goto_maps_menu_scene():
	var maps_menu_node := MapsMenu.instance()
	map_node = maps_menu_node
	set_scene(maps_menu_node)

# @impure
func goto_end_game_room_menu_scene():
	var end_game_menu_node := EndGameMenu.instance()
	map_node = end_game_menu_node
	set_scene(end_game_menu_node)
