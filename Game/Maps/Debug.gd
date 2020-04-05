extends "res://Game/Maps/Map.gd"

# @impure
func _ready():
	AudioManager.play_music("res://Game/Menus/Musics/The-Village.ogg")
	save_map("Debug", "", "sewer")
