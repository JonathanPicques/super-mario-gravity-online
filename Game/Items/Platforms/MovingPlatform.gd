extends KinematicBody2D

enum MovingPlatformDirection {
	Vertical,
	Horizontal,
}

export var speed = 1.0
export var amplitude = 30.0
export var direction = MovingPlatformDirection.Vertical

onready var start_pos = position

var accumulator = 0

# _physics_process is called to move the platform around.
# @driven(lifecycle)
# @impure
func _physics_process(delta):
	accumulator += delta * speed
	if direction == MovingPlatformDirection.Horizontal:
		position.x = start_pos.x + cos(accumulator) * amplitude
	else:
		position.y = start_pos.y + cos(accumulator) * amplitude