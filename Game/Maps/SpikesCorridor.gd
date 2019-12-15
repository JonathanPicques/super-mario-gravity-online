extends "res://Game/Maps/Map.gd"

# @impure
func _ready():
	if SettingsManager.values["music"] == true:
		AudioManager.play_music("res://Game/Menus/Musics/The-Village.ogg")
