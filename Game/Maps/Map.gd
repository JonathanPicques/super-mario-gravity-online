extends Navigation2D
class_name MapNode

onready var Map: TileMap = $Map
onready var Water: TileMap = $Map
onready var Sticky: TileMap = $Map

onready var FlagEnd: Node2D = $FlagEnd
onready var FlagStart: Node2D = $FlagStart
onready var ObjectSlot: Node2D = $ObjectSlot
onready var PlayerSlot: Node2D = $PlayerSlot
onready var ParticleSlot: Node2D = $ParticleSlot
onready var ParallaxSlot: Node2D = $ParallaxSlot

var killY := 3000.0

# _ready fills the empty map cells with navigable tiles.
# @impure
func _ready():
	var rect := Map.get_used_rect()
	# compute map kill-Y
	killY = rect.position.y * Map.cell_size.y + rect.size.y * Map.cell_size.y + 64.0
	# fill tilemap with navigable cells.
	for x in range (0, rect.size.x):
		for y in range (0, rect.size.y):
			var pos := Vector2(x + rect.position.x, y + rect.position.y)
			if Map.get_cell(int(pos.x), int(pos.y)) == TileMap.INVALID_CELL:
				pass # Map.set_cell(int(pos.x), int(pos.y), 5, false, false, false, Vector2(3, 2))
