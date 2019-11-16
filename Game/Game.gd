extends Control

onready var GameInput = $GameInput
onready var GameMultiplayer = $GameMultiplayer

const Map = preload("res://Game/Maps/Base/Base.tscn")
const MainMenu = preload("res://Game/Menus/MainMenu.tscn")
const CharactersMenu = preload("res://Game/Menus/CharactersMenu.tscn")

var scene = null
var skins := [
	{
		name = "Mario",
		scene_path = "res://Game/Players/Mario/Mario.tscn",
		preview_path = "res://Game/Players/Mario/Textures/Stand/stand_01.png",
	},
	{
		name = "Luigi",
		scene_path = "res://Game/Players/Luigi/Luigi.tscn",
		preview_path = "res://Game/Players/Luigi/Textures/Stand/stand_01.png",
	}
]

# _ready is called when the game node is ready.
# @driven(lifecycle)
# @impure
func _ready():
	set_scene(MainMenu.instance())
	yield(get_tree().create_timer(0.5), "timeout")
	set_scene(CharactersMenu.instance())

##########
# Scenes #
##########

# set_scene sets the current scene and frees the previous one.
# @impure
func set_scene(new_scene: Node):
	if scene != null:
		remove_child(scene)
		scene.queue_free()
	add_child(new_scene)
	scene = new_scene
