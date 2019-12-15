extends Navigation2D

const maps := [
	{
		"title": "Debug",
		"score": 0,
		"author": "rootkernel",
		"difficulty": "easy",
		"map_scene_path": "res://Game/Maps/Debug.tscn",
		"preview": "res://Game/Maps/Textures/DebugPreview.png",
	},
	{
		"title": "Rainbow garden",
		"score": 6,
		"author": "jeremtab",
		"difficulty": "easy",
		"map_scene_path": "res://Game/Maps/RainbowGarden.tscn",
		"preview": "res://Game/Maps/Textures/RainbowGardenPreview.png",
	},
	{
		"title": "Crazy tower",
		"score": 7,
		"author": "jeremtab",
		"difficulty": "medium",
		"map_scene_path": "res://Game/Maps/CrazyTower.tscn",
		"preview": "res://Game/Maps/Textures/CrazyTowerPreview.png",
	},
	{
		"title": "Spike Corridor",
		"score": 8,
		"author": "jeremtab",
		"difficulty": "hard",
		"map_scene_path": "res://Game/Maps/SpikesCorridor.tscn",
		"preview": "res://Game/Maps/Textures/SpikeCorridorPreview.png",
	}
]

# @impure
func _ready():
	# music
	if SettingsManager.values["music"] == true:
		AudioManager.play_music("res://Game/Menus/Musics/RPG-Battle-Climax-2.ogg")
	# GUI
	$GUI/MapButton1.grab_focus()
	$Icons/KeyGamepadCancel.visible = MultiplayerManager.get_lead_player().input_device_id == 1
	$Icons/KeyKeyboardCancel.visible = MultiplayerManager.get_lead_player().input_device_id == 0

# @impure
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Game.goto_lobby_menu_scene()
		MultiplayerManager.finish_playing()

# @impure
func start_game(map_scene_path: String):
	Game.goto_game_mode_scene("res://Game/Modes/Race/RaceGameMode.tscn", { map = map_scene_path })

# @impure
func set_map_infos(index):
	$GUI/MapInfos.text = "Difficulty: %s\nAuthor: %s\nRaiting: %d/10" % [
		maps[index]["difficulty"],
		maps[index]["author"],
		maps[index]["score"]
	]
	$GUI/TextureRect.texture = load(maps[index]["preview"])

# block_input is used to avoid calling start_game multiple times.
var block_input := false

# @signal
# @impure
func _on_MapButton1_pressed(): 
	if not block_input:
		block_input = true
		start_game(maps[0]["map_scene_path"])

# @signal
# @impure
func _on_MapButton1_focus_entered():
	set_map_infos(0)

# @signal
# @impure
func _on_MapButton2_pressed():
	if not block_input:
		block_input = true
		start_game(maps[1]["map_scene_path"])

# @signal
# @impure
func _on_MapButton2_focus_entered():
	set_map_infos(1)

# @signal
# @impure
func _on_MapButton3_pressed():
	if not block_input:
		block_input = true
		start_game(maps[2]["map_scene_path"])

# @signal
# @impure
func _on_MapButton3_focus_entered():
	set_map_infos(2)

# @signal
# @impure
func _on_MapButton4_pressed():
	if not block_input:
		block_input = true
		start_game(maps[3]["map_scene_path"])

# @signal
# @impure
func _on_MapButton4_focus_entered():
	set_map_infos(3)
