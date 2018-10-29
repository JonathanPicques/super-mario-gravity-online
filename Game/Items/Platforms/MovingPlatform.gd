extends KinematicBody2D

enum MovingPlatformDirection {
	Vertical,
	Horizontal,
}

export(float) var speed = 1
export(float) var amplitude = 30
export(MovingPlatformDirection) var direction = MovingPlatformDirection.Vertical

onready var start_pos = position

var accumulator = 0

func _physics_process(delta):
	accumulator += delta * speed
	if direction == MovingPlatformDirection.Horizontal:
		position.x = start_pos.x + cos(accumulator) * amplitude
	else:
		position.y = start_pos.y + cos(accumulator) * amplitude