extends Control
class_name GameNode

# warning-ignore:unused_class_variable
onready var GameMode = null
# warning-ignore:unused_class_variable
onready var GameInput = $GameInput
# warning-ignore:unused_class_variable
onready var GameMultiplayer = $GameMultiplayer
# warning-ignore:unused_class_variable
onready var GameConst = $GameConst

const Map: = preload("res://Game/Maps/Base/Base.tscn")
const JoinMenu := preload("res://Game/Menus/JoinMenu.tscn")
const HomeMenu := preload("res://Game/Maps/Home/Home.tscn")
const LobbyMenu := preload("res://Game/Maps/Lobby/Lobby.tscn")
const EndGameMenu := preload("res://Game/Maps/EndGame/EndGame.tscn")
const WaitingRoomMenu := preload("res://Game/Menus/WaitingRoomMenu.tscn")

var scene = null

# _ready is called when the game node is ready.
# @driven(lifecycle)
# @impure
func _ready():
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
	var home_menu_node := HomeMenu.instance()
	set_scene(home_menu_node)

# @impure
func goto_join_menu_scene():
	var join_menu_node := JoinMenu.instance()
	set_scene(join_menu_node)

# @impure
func goto_game_mode_scene(game_mode_node: Node):
	GameMode = game_mode_node
	set_scene(game_mode_node)

# @impure
func goto_lobby_menu_scene():
	var characters_menu_node := LobbyMenu.instance()
	set_scene(characters_menu_node)

# @impure
func goto_waiting_room_menu_scene():
	var waiting_room_node := WaitingRoomMenu.instance()
	set_scene(waiting_room_node)

# @impure
func goto_end_game_room_menu_scene():
	var end_game_room := EndGameMenu.instance()
	set_scene(end_game_room)
