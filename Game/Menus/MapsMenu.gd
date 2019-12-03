extends Navigation2D

const maps := [
	{
		"title": "Debug",
		"scene": "res://Game/Maps/Base.tscn",
		"score": 0,
		"author": "anonymous",
		"difficulty": "easy"
	},
	{
		"title": "Spike Corridor",
		"scene": "res://Game/Maps/SpikesCorridor.tscn",
		"score": 8,
		"author": "jeremtab",
		"difficulty": "easy"
	},
	{
		"title": "Crazy tower",
		"scene": "res://Game/Maps/Base.tscn",
		"score": 7,
		"author": "jeremtab",
		"difficulty": "medium"
	},
	{
		"title": "Rainbow room",
		"scene": "res://Game/Maps//Base.tscn",
		"score": 6,
		"author": "jeremtab",
		"difficulty": "medium"
	}
]

func _ready():
	$MapButton1.grab_focus()

func start_game(scene_path):
	var game_mode_node = load("res://Game/Modes/Race/RaceGameMode.tscn").instance()
	game_mode_node.options = { map = scene_path }
	Game.goto_game_mode_scene(game_mode_node)
	game_mode_node.start()

func set_map_infos(index):
	$MapInfos.text = "Difficulty: %s\nAuthor: %s\nScore: %d/10" % [
		maps[index]["difficulty"],
		maps[index]["author"],
		maps[index]["score"]
	]

func _on_MapButton1_pressed(): start_game(maps[0]["scene"])
func _on_MapButton1_focus_entered(): set_map_infos(0)

func _on_MapButton2_pressed(): start_game(maps[1]["scene"])
func _on_MapButton2_focus_entered(): set_map_infos(1)

func _on_MapButton3_pressed(): start_game(maps[2]["scene"])
func _on_MapButton3_focus_entered(): set_map_infos(2)

func _on_MapButton4_pressed(): start_game(maps[3]["scene"])
func _on_MapButton4_focus_entered(): set_map_infos(3)
