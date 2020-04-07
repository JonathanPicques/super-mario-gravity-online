extends Node

const SAVE_PATH := "user://settings.cfg"
const RESET_CONFIG_FILE_TO_DEFAULT := false

var values := {
	"music": 5,
	"sfx": 5,
	"minimap": true,
	"show_tuto": true
}
var config_file := ConfigFile.new()

var DB_SFX_FOR_VALUE = [-80, -35, -25, -15, -5, 0] # converts volume into decibels
var DB_MUSIC_FOR_VALUE = [-85, -50, -40, -30, -20, -10] # converts volume into decibels

# @impure
func _ready():
	if !RESET_CONFIG_FILE_TO_DEFAULT:
		load_settings()
	apply_settings()

# @impure
func load_settings():
	var error := config_file.load(SAVE_PATH)
	if error != OK:
		print("Failed to load settings file. Code %s" % error)
		return
	for key in values.keys():
		values[key] = config_file.get_value("config", key)

# @impure
func save_settings():
	for key in values.keys():
		config_file.set_value("config", key, values[key])
	config_file.save(SAVE_PATH)

# @impure
func save_info(key, value):
	config_file.set_value("info", key, value)
	config_file.save(SAVE_PATH)

# @impure
func get_info(key):
	return config_file.get_value("info", key)

# @impure
func apply_settings():
	AudioServer.set_bus_volume_db(2, DB_SFX_FOR_VALUE[values["sfx"]])
	AudioServer.set_bus_volume_db(1, DB_MUSIC_FOR_VALUE[values["music"]])
