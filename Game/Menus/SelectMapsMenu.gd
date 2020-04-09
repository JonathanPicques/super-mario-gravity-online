extends Navigation2D

onready var MapButtons := [
	$GUI/MapButton1,
	$GUI/MapButton2,
	$GUI/MapButton3,
	$GUI/MapButton4,
	$GUI/MapButton5
]
var map_infos = []
var page_index = 0
var current_tab = "Maps"

# @impure
func _ready():
	# music
	AudioManager.play_music("res://Game/Menus/Musics/Awkward-Princesss-Day-Out.ogg")
	# GUI
	$GUI/RandomMapButton.grab_focus()
	$GUI/RandomMapButton/Label.text = "Random"
	$GUI/RandomMapButton.apply_random(true)
	
	map_infos = MapManager.get_maps_infos(true) # load admin maps
	load_map_buttons()

func load_map_buttons():
	for i in range(0, MapButtons.size()):
		if i + page_index * 5 < map_infos.size():
			var map_info = map_infos[i + page_index * 5]
			MapButtons[i].get_node("Label").text = map_info.name
			MapButtons[i].get_node("Preview").texture = load("res://Maps/" + map_info["filename"].get_basename() + ".png")
		else:
			MapButtons[i].get_node("Label").text = ""
			MapButtons[i].get_node("Preview").texture = null

# @impure
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Game.goto_lobby_menu_scene()

func _on_RandomMapButton_pressed():
	MapManager.current_map = "Random" if current_tab == "Maps" else "YourRandom"
	Game.goto_lobby_menu_scene()	

func _on_MapButton1_pressed():
	if 0 > map_infos.size() - 1:
		return
	MapManager.current_map = map_infos[0]["filename"]
	Game.goto_lobby_menu_scene()	

func _on_MapButton2_pressed():
	if 1 > map_infos.size() - 1:
		return
	MapManager.current_map = map_infos[1]["filename"]
	Game.goto_lobby_menu_scene()	

func _on_MapButton3_pressed():
	if 2 > map_infos.size() - 1:
		return
	MapManager.current_map = map_infos[2]["filename"]
	Game.goto_lobby_menu_scene()	

func _on_MapButton4_pressed():
	if 3 > map_infos.size() - 1:
		return
	MapManager.current_map = map_infos[3]["filename"]
	Game.goto_lobby_menu_scene()	

func _on_MapButton5_pressed():
	if 4 > map_infos.size() - 1:
		return
	MapManager.current_map = map_infos[4]["filename"]
	Game.goto_lobby_menu_scene()	
	
func _on_PreviousButton_pressed():
	if page_index == 0:
		print("No previous maps'")
		return
	page_index -= 1
	print("loading previous maps...")
	load_map_buttons()

func _on_NextButton_pressed():
	if (page_index + 1) * 5 >= map_infos.size():
		print("No next maps...")
		return
	print("Load next maps...")
	page_index += 1
	load_map_buttons()




func _on_Tab_pressed():
	current_tab = "Maps"
	map_infos = MapManager.get_maps_infos(true) # load admin maps
	$GUI/RandomMapButton.apply_random(true)
	load_map_buttons()


func _on_Tab2_pressed():
	current_tab = "YourMaps"
	map_infos = MapManager.get_maps_infos(false) # load user maps
	$GUI/RandomMapButton.apply_random(false)
	$GUI/RandomMapButton/Label.text = "Random" if map_infos.size() > 0 else ""
	load_map_buttons()
