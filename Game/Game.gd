extends Control
class_name GameNode

const Map := preload("res://Game/Maps/Base.tscn")
const MapsMenu := preload("res://Game/Menus/MapsMenu.tscn")
const HomeMenu := preload("res://Game/Menus/HomeMenu.tscn")
const LobbyMenu := preload("res://Game/Menus/LobbyMenu.tscn")
const EndGameMenu := preload("res://Game/Menus/EndGameMenu.tscn")
const WaitingMenu := preload("res://Game/Menus/WaitingMenu.tscn")

var scene = null
var game_mode_node: GameModeNode

# _ready is called when the game node is ready.
# @driven(lifecycle)
# @impure
func _ready():
	scene = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
	VisualServer.set_default_clear_color(Color("#211F30"))

##########
# Scenes #
##########

# set_scene sets the current scene and frees the previous one.
# @impure
func set_scene(new_scene: Node):
	if scene:
		get_tree().get_root().remove_child(scene)
		scene.queue_free()
	get_tree().get_root().add_child(new_scene)
	scene = new_scene

# @impure
func goto_home_menu_scene():
	set_scene(HomeMenu.instance())

# @impure
func goto_game_mode_scene(_game_mode_node: Node):
	game_mode_node = _game_mode_node
	set_scene(_game_mode_node)

# @impure
func goto_lobby_menu_scene():
	set_scene(LobbyMenu.instance())

# @impure
func goto_waiting_menu_scene():
	set_scene(WaitingMenu.instance())

# @impure
func goto_maps_menu_scene():
	set_scene(MapsMenu.instance())

# @impure
func goto_end_game_room_menu_scene():
	set_scene(EndGameMenu.instance())
