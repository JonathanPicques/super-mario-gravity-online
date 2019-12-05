extends Navigation2D
class_name MapNode

onready var Map: TileMap = $Map
onready var FlagEnd: Node2D = $FlagEnd
onready var FlagStart: Node2D = $FlagStart
onready var PlayerSlot: Node2D = $PlayerSlot
onready var ParticleSlot: Node2D = $ParticleSlot

# _ready fills the empty map cells with navigable tiles.
# @impure
func _ready():
	var rect := Map.get_used_rect()
	for x in range (0, rect.size.x):
		for y in range (0, rect.size.y):
			var pos := Vector2(x + rect.position.x, y + rect.position.y)
			if Map.get_cell(int(pos.x), int(pos.y)) == TileMap.INVALID_CELL:
				Map.set_cell(int(pos.x), int(pos.y), 5, false, false, false, Vector2(3, 2))
