extends Node
class_name MapManagerNode

const cell_size := 16.0

var current_map := {"name": "Random", "admin": true}

const item_scenes := {
	"Door": preload("res://Game/Items/Door/Door.tscn"),
	"Spikes": preload("res://Game/Items/Spikes/Spikes.tscn"),
	"FlagEnd": preload("res://Game/Items/Flags/FlagEnd.tscn"),
	"PowerBox": preload("res://Game/Items/PowerBox/PowerBox.tscn"),
	"SpikeBall": preload("res://Game/Items/SpikeBall/SpikeBall.tscn"),
	"StartCage": preload("res://Game/Items/StartCage/StartCage.tscn"),
	"ColorBlock": preload("res://Game/Items/ColorSwitch/ColorBlock.tscn"),
	"SolidBlock": preload("res://Game/Items/SolidBlock/HSolidBlock.tscn"),
	"Trampoline": preload("res://Game/Items/Trampoline/Trampoline.tscn"),
	"ColorSwitch": preload("res://Game/Items/ColorSwitch/ColorSwitch.tscn"),
	"HSolidBlock": preload("res://Game/Items/SolidBlock/HSolidBlock.tscn"),
	"VSolidBlock": preload("res://Game/Items/SolidBlock/VSolidBlock.tscn"),
	"BigSolidBlock": preload("res://Game/Items/SolidBlock/BigSolidBlock.tscn"),
}

const item_thumbnails := {
	"Spikes": [preload("res://Game/Items/Spikes/Textures/SpikeIcon.png")],
	"PowerBox": [preload("res://Game/Items/PowerBox/Textures/PowerboxIcon.png")],
	"SpikeBall": [preload("res://Game/Items/SpikeBall/Textures/SpikeBall.png")],
	"ColorBlock": [
		preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOffAmber.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOffAmethyst.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOffDiamond.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOffEmerald.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOffQuartz.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOffRuby.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOnAmber.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOnAmethyst.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOnDiamond.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOnEmerald.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOnQuartz.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOnRuby.png")
	],
	"ColorSwitch": [
		preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOffAmber.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOffAmethyst.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOffDiamond.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOffEmerald.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOffQuartz.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOffRuby.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOnAmber.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOnAmethyst.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOnDiamond.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOnEmerald.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOnQuartz.png"),
		preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOnRuby.png")
	],
	"Trampoline": [preload("res://Game/Items/Spikes/Textures/SpikeIcon.png")],
}

onready var Backgrounds1 := [
	preload("res://Game/Maps/Textures/GardenBackground1.png"),
	preload("res://Game/Maps/Textures/CastleBackground1.png"),
	preload("res://Game/Maps/Textures/SewerBackground1.png"),
]

onready var Backgrounds2 := [
	preload("res://Game/Maps/Textures/GardenBackground2.png"),
	preload("res://Game/Maps/Textures/CastleBackground2.png"),
	preload("res://Game/Maps/Textures/SewerBackground2.png"),
]

onready var Backgrounds3 := [
	preload("res://Game/Maps/Textures/GardenBackground3.png"),
	preload("res://Game/Maps/Textures/CastleBackground3.png"),
	preload("res://Game/Maps/Textures/SewerBackground3.png"),
]

# @pure
func snap_value(value: float) -> int:
	return int(round((value - cell_size / 2) / cell_size) * cell_size)

# @pure
func snap_position(vec: Vector2) -> Vector2:
	return Vector2(snap_value(vec.x), snap_value(vec.y))

# @impure
func create_item_node(item_type: String) -> Node2D:
	return item_scenes[item_type].instance()

func get_item_thumbnail(item_type: String, variation: int) -> Texture:
	return item_thumbnails[item_type][variation]

func is_default():
	return current_map["name"] == "Default.json" and current_map["admin"] == true

# load_current_map loads the given map into the game mode.
# @impure
# @async
func load_current_map():
	var map_to_load = current_map
	if current_map["name"] == "Random":
		var map_files = _list_files_in_directory("res://Maps/", ".json", ["Default.json"])
		map_to_load = {"name": map_files[randi() % map_files.size()], "admin": true}
	elif current_map["name"] == "YourRandom":
		var map_files = _list_files_in_directory("user://Maps/", ".json")
		map_to_load = {"name": map_files[randi() % map_files.size()], "admin": true}		
	Game.map_node = load("res://Game/Maps/Map.tscn").instance()
	# add map to game mode tree
	Game.game_mode_node.MapSlot.add_child(Game.map_node)
	# load map data
	var map_json = load_map_json(map_to_load)

	# fill map
	yield(MapManager.fill_map_from_data(Game.map_node, map_json), "completed")
	
	# init map
	Game.map_node.init()

func load_map_json(map_info: Dictionary) -> Dictionary:
	var prefix := "res://Maps/" if map_info["admin"] == true else "user://Maps/"
	var map_path: String = prefix + map_info["name"]
	var file := File.new()
	var open_result := file.open(map_path, File.READ)
	if open_result != OK:
		print("failed to load map %s" % map_path) # TODO: find a better way to handle errors
		assert(false)
	var result = parse_json(file.get_line())
	file.close()
	return result

# fill_map_from_data fills the map given a map_data dictionary.
# @impure
# @async
func fill_map_from_data(map_node: MapNode, map_data: Dictionary):
	var tile_type = {
		"garden": 0,
		"castle": 1,
		"sewer": 2
	}
	var parallax_node = map_node.get_node("ParallaxSlot")
	if parallax_node == null: # If the game is already loaded, change parallax directly from viewport
		parallax_node = Game.game_mode_node.get_node("GridContainer/Control1/ViewportContainer1/Viewport1/ParallaxSlot")
	if parallax_node != null:
		parallax_node.get_node("ParallaxBackground/Background/Sprite").texture = Backgrounds3[tile_type[map_data["theme"]]]
		parallax_node.get_node("ParallaxBackground/Background2/Sprite").texture = Backgrounds2[tile_type[map_data["theme"]]]
		parallax_node.get_node("ParallaxBackground/Background3/Sprite").texture = Backgrounds1[tile_type[map_data["theme"]]]
		if map_data["theme"] != "garden":
			parallax_node.get_node("ParallaxBackground/Background3").visible = false
	# TODO: handle decor back
	for tile in map_data["decor_back"]:
		map_node.DecorBack.set_cell(tile[0], tile[1], 5 + tile_type[map_data["theme"]])
		map_node.DecorBack.update_bitmask_area(Vector2(tile[0], tile[1]))
	for tile in map_data["wall"]:
		map_node.Wall.set_cell(tile[0], tile[1], tile_type[map_data["theme"]])
		map_node.Wall.update_bitmask_area(Vector2(tile[0], tile[1]))
	for tile in map_data["water"]:
		apply_water_autotile(map_node, tile[0], tile[1])
	for tile in map_data["oneway"]:
		apply_oneway_autotile(map_node, tile[0], tile[1], 8 + tile_type[map_data["theme"]])
	for tile in map_data["sticky"]:
		map_node.Sticky.set_cell(tile[0], tile[1], 8)
		map_node.Sticky.update_bitmask_area(Vector2(tile[0], tile[1]))
	for item_data in map_data["item_slot"]:
		var item_node := create_item_node(item_data["type"])
		item_node.load_map_data(item_data)
		map_node.ObjectSlot.add_child(item_node)
	for door_data in map_data["door_slot"]:
		var door_node = create_item_node(door_data["type"])
		door_node.name = door_data["name"]
		map_node.DoorSlot.add_child(door_node)
	var i := 0
	for door_node in map_node.DoorSlot.get_children():
		door_node.load_map_data(map_data["door_slot"][i])
		i += 1
	yield(get_tree(), "idle_frame")


func apply_water_autotile(map_node, x, y):
	map_node.Water.set_cell(x, y, 16, false, false, false, get_water_tile(map_node, x, y))
	if map_node.Water.get_cell(x - 1, y) != TileMap.INVALID_CELL:
		map_node.Water.set_cell(x - 1, y, 16, false, false, false, get_water_tile(map_node, x - 1, y))
	if map_node.Water.get_cell(x + 1, y) != TileMap.INVALID_CELL:
		map_node.Water.set_cell(x + 1, y, 16, false, false, false, get_water_tile(map_node, x + 1, y))
	if map_node.Water.get_cell(x, y + 1) != TileMap.INVALID_CELL:
		map_node.Water.set_cell(x, y + 1, 16, false, false, false, get_water_tile(map_node, x, y + 1))

func get_water_tile(map_node: MapNode, x: int, y: int) -> Vector2: 
	return Vector2(0, 0 if map_node.Water.get_cell(x, y - 1) == TileMap.INVALID_CELL else 1)

func apply_oneway_autotile(map_node, x, y, tile_type):
	map_node.Oneway.set_cell(x, y, tile_type, false, false, false, get_oneway_tile(map_node, x, y))
	if map_node.Oneway.get_cell(x - 1, y) != TileMap.INVALID_CELL:
		map_node.Oneway.set_cell(x - 1, y, tile_type, false, false, false, get_oneway_tile(map_node, x - 1, y))
	if map_node.Oneway.get_cell(x + 1, y) != TileMap.INVALID_CELL:
		map_node.Oneway.set_cell(x + 1, y, tile_type, false, false, false, get_oneway_tile(map_node, x + 1, y))

func get_oneway_tile(map_node: MapNode, x: int, y: int) -> Vector2:
	if map_node.Oneway.get_cell(x - 1, y) == TileMap.INVALID_CELL and map_node.Wall.get_cell(x - 1, y) == TileMap.INVALID_CELL:
		return Vector2(0, 0)
	if map_node.Oneway.get_cell(x + 1, y) == TileMap.INVALID_CELL and map_node.Wall.get_cell(x + 1, y) == TileMap.INVALID_CELL:
		return Vector2(2, 0)
	return Vector2(1, 0)


func get_maps_infos(is_admin=true) -> Array:
	var result = []
	var prefix = "res://Maps/" if is_admin else "user://Maps/"
	var map_files = _list_files_in_directory(prefix, ".json", ["Default.json"])
	for map_file in map_files:
		var map_json = load_map_json({
			"name": map_file,
			"admin": is_admin
		})
		result.append({
			"filename": map_file,
			"name": map_json["name"],
			"description": map_json["description"],
			"theme": map_json["theme"],
			"admin": is_admin
		})
	return result

# @private
func _list_files_in_directory(path, extension, to_skip=[]):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.ends_with(extension) and not to_skip.has(file):
			files.append(file)

	dir.list_dir_end()
	return files
