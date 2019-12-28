extends Node

const SAVE_PATH := "user://settings.cfg"
const RESET_CONFIG_FILE_TO_DEFAULT := false

var values := {
	"music": 0,
	"sfx": 0,
	"minimap": true,
	"show_tuto": true
}
var config_file := ConfigFile.new()

var DB_FOR_VALUE = [-80, -45, -35, -25, -15, 0] # converts volume into decibels

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

func apply_settings():
	AudioServer.set_bus_volume_db(1, DB_FOR_VALUE[values["music"]])
	AudioServer.set_bus_volume_db(2, DB_FOR_VALUE[values["sfx"]])
