extends Navigation2D

onready var MapButtons := [
	$GUI/MapButton1,
	$GUI/MapButton2,
	$GUI/MapButton3,
	$GUI/MapButton4,
	$GUI/MapButton5
]

var map_infos = []

# @impure
func _ready():
	# music
	AudioManager.play_music("res://Game/Menus/Musics/Awkward-Princesss-Day-Out.ogg")
	# GUI
	$GUI/RandomMap.grab_focus()
	
	map_infos = MapManager.get_maps_infos()
	
	for i in range(0, MapButtons.size() - 1):
		if i < map_infos.size():
			MapButtons[i].get_node("Label").text = map_infos[i].name
			MapButtons[i].get_node("MapPreview").texture = load("res://Game/Maps/Textures/DebugPreview.png")
		else:
			MapButtons[i].get_node("Label").text = ""
			MapButtons[i].get_node("MapPreview").texture = null

# @impure
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Game.goto_lobby_menu_scene()

func _on_RandomMap_pressed():
	MapManager.current_map = "Random"
	Game.goto_lobby_menu_scene()

func _on_MapButton1_pressed():
	MapManager.current_map = map_infos[0]["filename"]
	Game.goto_lobby_menu_scene()	


func _on_MapButton2_pressed():
	MapManager.current_map = map_infos[1]["filename"]
	Game.goto_lobby_menu_scene()	


func _on_MapButton3_pressed():
	MapManager.current_map = map_infos[2]["filename"]
	Game.goto_lobby_menu_scene()	


func _on_MapButton4_pressed():
	MapManager.current_map = map_infos[3]["filename"]
	Game.goto_lobby_menu_scene()	

func _on_MapButton5_pressed():
	MapManager.current_map = map_infos[4]["filename"]
	Game.goto_lobby_menu_scene()	
	
func _on_PreviousButton_pressed():
	print("Load previous maps")

func _on_NextButton_pressed():
	print("Load next maps")
