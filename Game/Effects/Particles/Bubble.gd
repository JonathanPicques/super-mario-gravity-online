extends Sprite

onready var WaterTilemap : TileMap = Game.map_node.Water

var acc := 0.0
var dir := 1.0
var speed := 3.0
var amplitude := 6.0
var initial_x := 0.0

func _ready():
	dir = sign(rand_range(-1.0, 1.0))
	initial_x = position.x

func _process(delta):
	# check if the bubble is still in water
	var bubble_in_water_pos := WaterTilemap.world_to_map(Vector2(global_position.x, global_position.y - 4))
	if WaterTilemap.get_cell(bubble_in_water_pos.x, bubble_in_water_pos.y) == TileMap.INVALID_CELL:
		queue_free()
	# move the bubble up with a sine wave
	position.x = initial_x + sin(acc * speed) * dir * amplitude
	position.y -= 50 * delta
	acc += delta
