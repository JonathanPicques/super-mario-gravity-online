extends Node
class_name MapManagerNode

const cell_size := 16.0

const item_scenes := {
	"ColorSwitch": preload("res://Game/Items/ColorSwitch/ColorSwitch.tscn"),
	"ColorBlock": preload("res://Game/Items/ColorSwitch/ColorBlock.tscn"),
	"Door": preload("res://Game/Items/Door/Door.tscn"),
	"PowerBox": preload("res://Game/Items/PowerBox/PowerBox.tscn"),
	"SolidBlock": preload("res://Game/Items/SolidBlock/HSolidBlock.tscn"),
	"HSolidBlock": preload("res://Game/Items/SolidBlock/HSolidBlock.tscn"),
	"VSolidBlock": preload("res://Game/Items/SolidBlock/VSolidBlock.tscn"),
	"BigSolidBlock": preload("res://Game/Items/SolidBlock/BigSolidBlock.tscn"),
	"SpikeBall": preload("res://Game/Items/SpikeBall/SpikeBall.tscn"),
	"Spikes": preload("res://Game/Items/Spikes/Spike.tscn"),
	"Trampoline": preload("res://Game/Items/Trampoline/Trampoline.tscn")
}

# @pure
func snap_value(value: float) -> int:
	return int(round((value - cell_size / 2) / cell_size) * cell_size)

# @impure
func create_item(item_type: String) -> Node2D:
	return item_scenes[item_type].instance()

# fill_map_from_data fills the map given a map_data dictionary.
# @impure
func fill_map_from_data(map_node: MapNode, map_data: Dictionary):
	map_node.FlagEnd.position.x = map_data["flag_end"]["position"][0]
	map_node.FlagEnd.position.y = map_data["flag_end"]["position"][1]
	map_node.FlagStart.position.x = map_data["flag_start"]["position"][0]
	map_node.FlagStart.position.y = map_data["flag_start"]["position"][1]
	# TODO: handle oneway (use its own tilemap?)
	for tile in map_data["map"]:
		map_node.Map.set_cell(tile[0], tile[1], 15)
		map_node.Map.update_bitmask_area(Vector2(tile[0], tile[1]))
	for tile in map_data["sticky"]:
		map_node.Sticky.set_cell(tile[0], tile[1], 8)
		map_node.Sticky.update_bitmask_area(Vector2(tile[0], tile[1]))
	for tile in map_data["water"]:
		map_node.Water.set_cell(tile[0], tile[1], 16)
		map_node.Water.update_bitmask_area(Vector2(tile[0], tile[1]))
	for item_data in map_data["item_slot"]:
		var item = MapManager.create_item(item_data["type"])
		item.load_map_data(item_data)
		print("item created! ", item)
		map_node.ObjectSlot.add_child(item)
