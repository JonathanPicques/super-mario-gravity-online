extends Navigation2D

onready var Tilemap: TileMap = $Tilemap

func _ready():
	var rect := Tilemap.get_used_rect()
	for x in range (0, rect.size.x):
		for y in range (0, rect.size.y):
			var pos := Vector2(x + rect.position.x, y + rect.position.y)
			if Tilemap.get_cell(pos.x, pos.y) == TileMap.INVALID_CELL:
				Tilemap.set_cell(pos.x, pos.y, 5, false, false, false, Vector2(3, 2))
