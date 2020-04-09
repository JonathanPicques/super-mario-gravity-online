extends Navigation2D

onready var MapButtons := [
	$GUI/MapButton0,
	$GUI/MapButton1,
	$GUI/MapButton2,
	$GUI/MapButton3,
	$GUI/MapButton4,
	$GUI/MapButton5
]

var map_infos = []
var page_index = 0

# @impure
func _ready():
	# music
	AudioManager.play_music("res://Game/Menus/Musics/Awkward-Princesss-Day-Out.ogg")
	# GUI
	MapButtons[0].grab_focus()
	map_infos = MapManager.get_maps_infos(false)
	if Game.ADMIN:
		map_infos += MapManager.get_maps_infos(true)
	load_map_buttons()

func load_map_buttons():
	for i in range(0, MapButtons.size()):
		if i + page_index * MapButtons.size() < map_infos.size():
			var map_info = map_infos[i + page_index * MapButtons.size()]
			MapButtons[i].get_node("Label").text = map_info.name
			MapButtons[i].get_node("Preview").texture = load("res://Maps/" + map_info["filename"].get_basename() + ".png")
		else:
			MapButtons[i].get_node("Label").text = ""
			MapButtons[i].get_node("Preview").texture = null

# @impure
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Game.goto_lobby_menu_scene()

func open_map(index):
	if index > map_infos.size() - 1:
		return
	MapManager.current_map = map_infos[index]["filename"]
	SettingsManager.save_info("creatorMap", MapManager.current_map)
	Game.goto_creator_scene()

func _on_MapButton0_pressed(): open_map(0)
func _on_MapButton1_pressed(): open_map(1)
func _on_MapButton2_pressed(): open_map(2)
func _on_MapButton3_pressed(): open_map(3)
func _on_MapButton4_pressed(): open_map(4)
func _on_MapButton5_pressed(): open_map(5)
	
func _on_PreviousButton_pressed():
	if page_index == 0:
		print("No previous maps'")
		return
	page_index -= 1
	print("loading previous maps...")
	load_map_buttons()

func _on_NextButton_pressed():
	if (page_index + 1) * MapButtons.size() >= map_infos.size():
		print("No next maps...")
		return
	print("Load next maps...")
	page_index += 1
	load_map_buttons()



func _on_NewButton_pressed():
	MapManager.current_map = "Default.json"
	Game.goto_creator_scene()
