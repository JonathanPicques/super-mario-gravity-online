extends "res://Game/Maps/Map.gd"

func get_tilemap_data(tilemap_node):
	var tilemap = []
	for tile in tilemap_node.get_used_cells():
		tilemap.append([tile[0], tile[1]])
	return tilemap

func get_map_data() -> Dictionary:
	var items = []
	for item in $ObjectSlot.get_children():
		items.append(item.get_map_data())

	return {
		"name": "debug",
		"theme": "sewer",
		"flag_start": $FlagStart.get_map_data(),
		"flag_end": $FlagEnd.get_map_data(),
		"item_slot": items,
		"map": get_tilemap_data($Map),
		"sticky": get_tilemap_data($Sticky),
		"decor_back": get_tilemap_data($DecorBack),
		"decor_front": get_tilemap_data($DecorFront),
		"water": get_tilemap_data($Water)
	}

func save_map():
	var file = File.new()
	file.open("res://Maps/debug.json", File.WRITE)
	file.store_line(to_json(get_map_data()))
	file.close()



# @impure
func _ready():
	AudioManager.play_music("res://Game/Menus/Musics/The-Village.ogg")
