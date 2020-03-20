extends Node2D

onready var WaterTilemap: TileMap = Game.map_node.Water
onready var BubbleAnimatedSprite: AnimatedSprite = $AnimatedSprite
onready var BubbleAnimationPlayer: AnimationPlayer = $AnimationPlayer

enum State { appearing, floating, exploding }

var APPEAR_SPEED := 45.0 + rand_range(0.0, 5.0)
var FLOATING_SPEED := 65.0 + rand_range(0.0, 8.0)

var acc := 0.0
var dir := 1.0
var state: int = State.appearing
var initial_x := 0.0
var amplitude := 6.0

# @impure
func _ready():
	dir = sign(rand_range(-1.0, 1.0))
	initial_x = position.x
	BubbleAnimatedSprite.play("appear")

# @impure
func _process(delta: float):
	# move the bubble up with a sine wave
	if state == State.appearing or state == State.floating:
		acc += delta
		position.x = initial_x + sin(acc) * dir * amplitude
		position.y -= (APPEAR_SPEED if state == State.appearing else FLOATING_SPEED) * delta
	# make the bubble explode when leaving water
	var bubble_in_water_pos := WaterTilemap.world_to_map(Vector2(global_position.x, global_position.y - 14.0))
	if WaterTilemap.get_cell(bubble_in_water_pos.x, bubble_in_water_pos.y) == TileMap.INVALID_CELL:
		state = State.exploding
		BubbleAnimatedSprite.play("explode")
		BubbleAnimatedSprite.offset = Vector2(0, -10)
		BubbleAnimatedSprite.self_modulate.a = 1.0
		BubbleAnimationPlayer.stop()

# @signal
# @impure
func on_bubble_animation_finished():
	match BubbleAnimatedSprite.animation:
		"appear": state = State.floating
		"explode": queue_free()
