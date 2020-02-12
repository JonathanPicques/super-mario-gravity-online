extends DrawerNode

const MAX_WATER_CELLS := 200
var count := MAX_WATER_CELLS

export var tileset_type := "Water"

# @impure
func _ready():
	placeholder = Sprite.new()

# @override
func has_item(mouse_position: Vector2) -> bool:
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts[0].world_to_map(mouse_position)
	return ts[0].get_cell(cell_position.x, cell_position.y) != -1

# @override
func create_item(mouse_position: Vector2):
	if !has_item(mouse_position) and placeholder.visible:
		var ts = creator.tilesets[tileset_type]
		var cell_position = ts[0].world_to_map(mouse_position)
		count = MAX_WATER_CELLS
		fill_area(ts, cell_position, ts[1], cell_position.y)

# @override
func remove_item(mouse_position: Vector2):
	var ts = creator.tilesets[tileset_type]
	var cell_position = ts[0].world_to_map(mouse_position)
	count = MAX_WATER_CELLS
	fill_area(ts, cell_position, -1, cell_position.y)

# @override
func get_item_pivot():
	return Vector2(MapManager.ceil_size / 2, MapManager.ceil_size / 2)

# @override
func select_drawer():
	placeholder.texture = creator.tilesets[tileset_type][2]
	placeholder.modulate = Color(1, 1, 1, 0.5)
	.select_drawer()

# @impure
func fill_area(ts, cell_position: Vector2, value: int, top_position: int):
	var wall_cell = creator.tilesets.Wall[0].get_cell(cell_position.x, cell_position.y)
	var water_cell = ts[0].get_cell(cell_position.x, cell_position.y)
	if wall_cell != -1 or water_cell != -1 or count < 0:
		return
	ts[0].set_cell(cell_position.x, cell_position.y, value, false, false, false, Vector2(0, 0 if cell_position.y == top_position else 1))
	count -= 1
	fill_area(ts, Vector2(cell_position.x + 1, cell_position.y), value, top_position)
	fill_area(ts, Vector2(cell_position.x - 1, cell_position.y), value, top_position)
	fill_area(ts, Vector2(cell_position.x, cell_position.y + 1), value, top_position)
