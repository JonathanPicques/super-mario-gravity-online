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
	},
	{
		"title": "Custom Map",
		"score": 42,
		"author": "rootkernel & the world",
		"preview": "res://Game/Maps/Textures/SpikeCorridorPreview.png",
		"difficulty": "inferno",
		"map_scene_path": "res://Game/Maps/SpikesCorridor.tscn",
	}
]

# @impure
func _ready():
	# music
	AudioManager.play_music("res://Game/Menus/Musics/Awkward-Princesss-Day-Out.ogg")
	# GUI
	$GUI/RandomMap.grab_focus()

# @impure
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Game.goto_lobby_menu_scene()
	if Input.is_action_just_pressed("ui_accept"):
		Game.goto_lobby_menu_scene()
