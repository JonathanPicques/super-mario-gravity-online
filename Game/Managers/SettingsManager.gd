extends Node

const SAVE_PATH := "user://settings.cfg"

var values := {
	"music": true,
	"sounds": true,
	"minimap": true
}
var config_file := ConfigFile.new()

# @impure
func _ready():
	load_settings()

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
