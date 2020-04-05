extends Node
class_name MapManagerNode

const cell_size := 16.0

const item_scenes := {
	"Door": preload("res://Game/Items/Door/Door.tscn"),
	"Spikes": preload("res://Game/Items/Spikes/Spikes.tscn"),
	"FlagEnd": preload("res://Game/Items/Flags/FlagEnd.tscn"),
	"PowerBox": preload("res://Game/Items/PowerBox/PowerBox.tscn"),
	"SpikeBall": preload("res://Game/Items/SpikeBall/SpikeBall.tscn"),
	"StartCage": preload("res://Game/Items/StartCage/StartCage.tscn"),
	"FlagStart": preload("res://Game/Items/Flags/FlagStart.tscn"),
	"ColorBlock": preload("res://Game/Items/ColorSwitch/ColorBlock.tscn"),
	"SolidBlock": preload("res://Game/Items/SolidBlock/HSolidBlock.tscn"),
	"Trampoline": preload("res://Game/Items/Trampoline/Trampoline.tscn"),
	"ColorSwitch": preload("res://Game/Items/ColorSwitch/ColorSwitch.tscn"),
	"HSolidBlock": preload("res://Game/Items/SolidBlock/HSolidBlock.tscn"),
	"VSolidBlock": preload("res://Game/Items/SolidBlock/VSolidBlock.tscn"),
	"BigSolidBlock": preload("res://Game/Items/SolidBlock/BigSolidBlock.tscn"),
}

# @pure
func snap_value(value: float) -> int:
	return int(round((value - cell_size / 2) / cell_size) * cell_size)

# @impure
func create_item_node(item_type: String) -> Node2D:
	return item_scenes[item_type].instance()

# fill_map_from_data fills the map given a map_data dictionary.
# @impure
func fill_map_from_data(map_node: MapNode, map_data: Dictionary):
	for tile in map_data["wall"]:
		map_node.Wall.set_cell(tile[0], tile[1], 15)
		map_node.Wall.update_bitmask_area(Vector2(tile[0], tile[1]))
	for tile in map_data["water"]:
		var x = tile[0]
		var y = tile[1]
		map_node.Water.set_cell(tile[0], tile[1], 16)
		if map_node.Water.get_cell(x - 1, y) != TileMap.INVALID_CELL:
			map_node.Water.set_cell(x - 1, y, 16, false, false, false, get_autotile(map_node.Water, x - 1, y))
		if map_node.Water.get_cell(x + 1, y) != TileMap.INVALID_CELL:
			map_node.Water.set_cell(x + 1, y, 16, false, false, false, get_autotile(map_node.Water, x + 1, y))
		if map_node.Water.get_cell(x, y + 1) != TileMap.INVALID_CELL:
			map_node.Water.set_cell(x, y + 1, 16, false, false, false, get_autotile(map_node.Water, x, y + 1))
		map_node.Water.update_bitmask_area(Vector2(tile[0], tile[1]))
	for tile in map_data["oneway"]:
		map_node.Oneway.set_cell(tile[0], tile[1], 9)
	for tile in map_data["sticky"]:
		map_node.Sticky.set_cell(tile[0], tile[1], 8)
		map_node.Sticky.update_bitmask_area(Vector2(tile[0], tile[1]))
		# TODO: oneway autotiling
	for item_data in map_data["item_slot"]:
		var item_node := create_item_node(item_data["type"])
		item_node.load_map_data(item_data)
		map_node.ObjectSlot.add_child(item_node)
	for door_data in map_data["door_slot"]:
		var door_node = create_item_node(door_data["type"])
		map_node.DoorSlot.add_child(door_node)
	yield(get_tree(), "idle_frame")
	var i = 0
	for door_node in map_node.DoorSlot.get_children():
		door_node.load_map_data(map_data["door_slot"][i])
		i += 1

# TODO: generic code!!!
func get_autotile(tilemap: TileMap, x: int, y: int) -> Vector2: 
	return Vector2(0, 0 if tilemap.get_cell(x, y - 1) == TileMap.INVALID_CELL else 1)
