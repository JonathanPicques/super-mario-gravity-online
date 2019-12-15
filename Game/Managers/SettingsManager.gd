extends Node

const SAVE_PATH = "res://settings.cfg"

var values = {
	"music": true,
	"sounds": true,
	"minimap": true
}

var config_file = ConfigFile.new()

func _ready():
	load_settings()

func load_settings():
	var error = config_file.load(SAVE_PATH)
	if error != OK:
		print("Failed to load settings file. Code %s" % error)
		return []
	print("Loading settings...")
	for key in values.keys():
		values[key] = config_file.get_value("config", key)
		print(key, " = ", values[key])
	print("... Done!")

func save_settings():
	print("Saving settings...")
	for key in values.keys():
		config_file.set_value("config", key, values[key])
		print(key, " = ", values[key])
	config_file.save(SAVE_PATH)
	print("... Done!")
