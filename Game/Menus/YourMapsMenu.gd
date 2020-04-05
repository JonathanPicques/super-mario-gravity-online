extends Navigation2D

const maps := [
	{
		"title": "Debug",
		"score": 0,
		"author": "rootkernel",
		"preview": "res://Game/Maps/Textures/DebugPreview.png",
		"difficulty": "easy",
		"map_scene_path": "res://Game/Maps/Debug.tscn",
	},
	{
		"title": "Rainbow garden",
		"score": 6,
		"author": "jeremtab",
		"preview": "res://Game/Maps/Textures/RainbowGardenPreview.png",
		"difficulty": "easy",
		"map_scene_path": "res://Game/Maps/RainbowGarden.tscn",
	},
	{
		"title": "Crazy tower",
		"score": 7,
		"author": "jeremtab",
		"preview": "res://Game/Maps/Textures/CrazyTowerPreview.png",
		"difficulty": "medium",
		"map_scene_path": "res://Game/Maps/CrazyTower.tscn",
	},
	{
		"title": "Spike Corridor",
		"score": 8,
		"author": "jeremtab",
		"preview": "res://Game/Maps/Textures/SpikeCorridorPreview.png",
		"difficulty": "hard",
		"map_scene_path": "res://Game/Maps/SpikesCorridor.tscn",
	}
]

onready var MapButtons := [
	$GUI/MapButton1,
	$GUI/MapButton2,
	$GUI/MapButton3,
	$GUI/MapButton4,
	$GUI/MapButton5
]

# @impure
func _ready():
	# music
	AudioManager.play_music("res://Game/Menus/Musics/Awkward-Princesss-Day-Out.ogg")
	# GUI
	$GUI/RandomMap.grab_focus()
	
	var files = MapManager.get_maps_infos()
	print(files)
	
	for i in range(0, MapButtons.size() - 1):
		if i < maps.size():
			MapButtons[i].get_node("Label").text = maps[i].title
			MapButtons[i].get_node("MapPreview").texture = load(maps[i].preview)
		else:
			MapButtons[i].get_node("Label").text = ""
			MapButtons[i].get_node("MapPreview").texture = null

# @impure
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Game.goto_lobby_menu_scene()

func _on_RandomMap_pressed():
	print("Select random map")
	Game.goto_lobby_menu_scene()

func _on_MapButton1_pressed():
	print("Select first map")
	Game.goto_lobby_menu_scene()	


func _on_MapButton2_pressed():
	print("Select map 2")
	Game.goto_lobby_menu_scene()	


func _on_MapButton3_pressed():
	print("Select map 3")
	Game.goto_lobby_menu_scene()	


func _on_MapButton4_pressed():
	print("Select map 4")
	Game.goto_lobby_menu_scene()	

func _on_MapButton5_pressed():
	print("Select map 5")
	Game.goto_lobby_menu_scene()	
	
func _on_PreviousButton_pressed():
	print("Load previous maps")

func _on_NextButton_pressed():
	print("Load next maps")
