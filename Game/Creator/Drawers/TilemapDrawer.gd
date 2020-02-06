extends DrawerNode

export var tileset_type := "Wall"

# @impure
func _ready():
	placeholder = Sprite.new()

# @override
func has_item(mouse_position: Vector2):
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts[0].world_to_map(mouse_position)
	return ts[0].get_cell(cell_position.x, cell_position.y) != -1

# @override
func create_item(mouse_position: Vector2):
	if !has_item(mouse_position) and placeholder.visible:
		var ts = creator.tilesets[tileset_type]
		var cell_position = ts[0].world_to_map(mouse_position)
		ts[0].set_cell(cell_position.x, cell_position.y, ts[1])
		ts[0].update_bitmask_area(cell_position)

# @override
func remove_item(mouse_position: Vector2):
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts[0].world_to_map(mouse_position)
	ts[0].set_cell(cell_position.x, cell_position.y, -1)
	ts[0].update_bitmask_area(cell_position)

# @override
func get_item_pivot():
	return Vector2(MapManager.ceil_size / 2, MapManager.ceil_size / 2)

# @override
func select_drawer():
	placeholder.texture = creator.tilesets[tileset_type][2]
	placeholder.modulate = Color(1, 1, 1, 0.5)
	.select_drawer()
