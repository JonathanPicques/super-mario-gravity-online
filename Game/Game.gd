extends Control
class_name GameNode

# warning-ignore:unused_class_variable
onready var GameMode = null
# warning-ignore:unused_class_variable
onready var GameConst = $GameConst
# warning-ignore:unused_class_variable
onready var GameInput = $GameInput
# warning-ignore:unused_class_variable
onready var GameMultiplayer = $GameMultiplayer

const Map := preload("res://Game/Maps/Base.tscn")
const MapsMenu := preload("res://Game/Menus/MapsMenu.tscn")
const HomeMenu := preload("res://Game/Menus/HomeMenu.tscn")
const LobbyMenu := preload("res://Game/Menus/LobbyMenu.tscn")
const EndGameMenu := preload("res://Game/Menus/EndGameMenu.tscn")
const WaitingMenu := preload("res://Game/Menus/WaitingMenu.tscn")

var scene = null

# _ready is called when the game node is ready.
# @driven(lifecycle)
# @impure
func _ready():
	VisualServer.set_default_clear_color(Color("#211F30"))
	goto_home_menu_scene()

##########
# Scenes #
##########

# set_scene sets the current scene and frees the previous one.
# @impure
func set_scene(new_scene: Node):
	if scene:
		remove_child(scene)
		scene.queue_free()
	add_child(new_scene)
	scene = new_scene

# @impure
func goto_home_menu_scene():
	var node := HomeMenu.instance()
	set_scene(node)

# @impure
func goto_game_mode_scene(game_mode_node: Node):
	GameMode = game_mode_node
	set_scene(game_mode_node)

# @impure
func goto_lobby_menu_scene():
	var node := LobbyMenu.instance()
	set_scene(node)

# @impure
func goto_waiting_menu_scene():
	var node := WaitingMenu.instance()
	set_scene(node)

# @impure
func goto_maps_menu_scene():
	var node := MapsMenu.instance()
	set_scene(node)

# @impure
func goto_end_game_room_menu_scene():
	var node := EndGameMenu.instance()
	set_scene(node)
