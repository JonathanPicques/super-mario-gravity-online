extends KinematicBody2D

signal block_hit

onready var start_pos = position

export var speed = 10.0
export var amplitude = 5.0

var active = false
var accumulator = 0
var number_hits = 0

# _physics_process moves the block upside and down after hit.
# @driven(lifecycle)
# @impure
func _physics_process(delta: float):
	if active:
		accumulator += speed * delta
		position.y = start_pos.y - sin(accumulator) * amplitude
		if accumulator >= PI:
			active = false
			position = start_pos
			accumulator = 0

# on_block_hit is called when a body collides with the block.
# @driven(signal)
# @impure
func on_block_hit(body: PhysicsBody2D):
	active = true
	number_hits += 1
	on_hit(body)
	emit_signal("block_hit")

# on_hit is called when this block is hit.
# @pure
func on_hit(body: PhysicsBody2D):
	pass