extends Navigation2D
class_name MapNode

onready var Wall: TileMap = $Wall
onready var Water: TileMap = $Water
onready var Oneway: TileMap = $Oneway
onready var Sticky: TileMap = $Sticky

onready var FlagEnd: Node2D = $FlagEnd
onready var FlagStart: Node2D = $FlagStart
onready var StartCage: Node2D = $StartCage
onready var ObjectSlot: Node2D = $ObjectSlot
onready var DoorSlot: Node2D = $DoorSlot
onready var PlayerSlot: Node2D = $PlayerSlot
onready var ParticleSlot: Node2D = $ParticleSlot
onready var ParallaxSlot: Node2D = $ParallaxSlot

var killY := 3000.0

func get_tilemap_data(tilemap_node):
	var tilemap = []
	for tile in tilemap_node.get_used_cells():
		tilemap.append([tile[0], tile[1]])
	return tilemap

func get_map_data(name, description, theme) -> Dictionary:
	var items = []
	for item in $ObjectSlot.get_children():
		print(item)
		items.append(item.get_map_data())
	var doors = []
	for door in $DoorSlot.get_children():
		doors.append(door.get_map_data())
	
	return {
		"name": name,
		"description": description,
		"theme": theme,
		"item_slot": items,
		"door_slot": doors,
		"wall": get_tilemap_data($Wall),
		"sticky": get_tilemap_data($Sticky),
		"decor_back": get_tilemap_data($DecorBack),
		"decor_front": get_tilemap_data($DecorFront),
		"oneway": get_tilemap_data($Oneway),
		"water": get_tilemap_data($Water)
	}

func save_map(name, description, theme):
	var file = File.new()
	file.open("res://Maps/" + name + ".json", File.WRITE)
	file.store_line(to_json(get_map_data(name, description, theme)))
	file.close()

# _ready fills the empty map cells with navigable tiles.
# @impure
func _ready():
	var rect := Wall.get_used_rect()
	# compute map kill-Y
	killY = rect.position.y * Wall.cell_size.y + rect.size.y * Wall.cell_size.y + 64.0
	# fill tilemap with navigable cells.
	for x in range (0, rect.size.x):
		for y in range (0, rect.size.y):
			var pos := Vector2(x + rect.position.x, y + rect.position.y)
			if Wall.get_cell(int(pos.x), int(pos.y)) == TileMap.INVALID_CELL:
				pass # Map.set_cell(int(pos.x), int(pos.y), 5, false, false, false, Vector2(3, 2)) # TODO: FIND ANOTHER WAY FOR PERFORMANCE
