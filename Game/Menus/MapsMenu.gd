extends Navigation2D

const maps := [
	{
		"title": "Debug",
		"score": 0,
		"author": "anonymous",
		"difficulty": "easy",
		"map_scene_path": "res://Game/Maps/Debug.tscn",
	},
	{
		"title": "Spike Corridor",
		"score": 8,
		"author": "jeremtab",
		"difficulty": "easy",
		"map_scene_path": "res://Game/Maps/SpikesCorridor.tscn",
	},
	{
		"title": "Crazy tower",
		"score": 7,
		"author": "jeremtab",
		"difficulty": "medium",
		"map_scene_path": "res://Game/Maps/CrazyTower.tscn",
	},
	{
		"title": "Rainbow garden",
		"score": 6,
		"author": "jeremtab",
		"difficulty": "medium",
		"map_scene_path": "res://Game/Maps/RainbowGarden.tscn",
	}
]

# @impure
func _ready():
	$KeyCancel.visible = GameMultiplayer.get_lead_player().input_device_id == 0
	$MapButton1.grab_focus()
	$KeyCtrlCancel.visible = GameMultiplayer.get_lead_player().input_device_id == 0

# @impure
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Game.goto_lobby_menu_scene()
		GameMultiplayer.finish_playing()

# @impure
func start_game(map_scene_path: String):
	return Game.goto_game_mode_scene("res://Game/Modes/Race/RaceGameMode.tscn", { map = map_scene_path })

# @impure
func set_map_infos(index):
	$MapInfos.text = "Difficulty: %s\nAuthor: %s\nScore: %d/10" % [
		maps[index]["difficulty"],
		maps[index]["author"],
		maps[index]["score"]
	]

# @signal
# @impure
func _on_MapButton1_pressed(): start_game(maps[0]["map_scene_path"])
# @signal
# @impure
func _on_MapButton1_focus_entered(): set_map_infos(0)

# @signal
# @impure
func _on_MapButton2_pressed(): start_game(maps[1]["map_scene_path"])
# @signal
# @impure
func _on_MapButton2_focus_entered(): set_map_infos(1)

# @signal
# @impure
func _on_MapButton3_pressed(): start_game(maps[2]["map_scene_path"])
# @signal
# @impure
func _on_MapButton3_focus_entered(): set_map_infos(2)

# @signal
# @impure
func _on_MapButton4_pressed(): start_game(maps[3]["map_scene_path"])
# @signal
# @impure
func _on_MapButton4_focus_entered(): set_map_infos(3)
