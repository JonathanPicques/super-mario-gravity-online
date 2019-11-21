extends Control

onready var GameMode = null
onready var GameMultiplayer = $GameMultiplayer
onready var GameInput = $GameInput

const Map: = preload("res://Game/Maps/Base/Base.tscn")
const JoinMenu := preload("res://Game/Menus/JoinMenu.tscn")
const MainMenu := preload("res://Game/Menus/MainMenu.tscn")
const EndGameMenu := preload("res://Game/Menus/EndGameMenu.tscn")
const CharactersMenu := preload("res://Game/Menus/CharactersMenu.tscn")
const WaitingRoomMenu := preload("res://Game/Menus/WaitingRoomMenu.tscn")

var scene = null
var skins := [
	{
		name = "Mario",
		node_path = "res://Game/Players/Mario/Mario.tscn",
		preview_ready_path = "res://Game/Players/Mario/Textures/Jump/jump_01.png",
		preview_select_path = "res://Game/Players/Mario/Textures/Stand/stand_01.png",
	},
	{
		name = "Luigi",
		node_path = "res://Game/Players/Luigi/Luigi.tscn",
		preview_ready_path = "res://Game/Players/Luigi/Textures/Jump/jump_01.png",
		preview_select_path = "res://Game/Players/Luigi/Textures/Stand/stand_01.png",
	}
]

func get_skin_from_id(skin_id: int, ready: bool = false):
	return load(skins[skin_id].preview_select_path if not ready else skins[skin_id].preview_ready_path)

# _ready is called when the game node is ready.
# @driven(lifecycle)
# @impure
func _ready():
	goto_main_menu_scene()

##########
# Scenes #
##########

# set_scene sets the current scene and frees the previous one.
# @impure
func set_scene (new_scene: Node):
	if scene != null:
		remove_child(scene)
		scene.queue_free()
	add_child(new_scene)
	scene = new_scene

func goto_main_menu_scene():
	var main_menu_node := MainMenu.instance()
	set_scene(main_menu_node)

func goto_join_menu_scene():
	var join_menu_node := JoinMenu.instance()
	set_scene(join_menu_node)

func goto_game_mode_scene(game_mode_node: Node):
	GameMode = game_mode_node
	set_scene(game_mode_node)

func goto_characters_menu_scene():
	var characters_menu_node := CharactersMenu.instance()
	set_scene(characters_menu_node)

func goto_waiting_room_menu_scene():
	var waiting_room_node := WaitingRoomMenu.instance()
	set_scene(waiting_room_node)

func goto_end_game_room_menu_scene():
	var end_game_room := EndGameMenu.instance()
	set_scene(end_game_room)
