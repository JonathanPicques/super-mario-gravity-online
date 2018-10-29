extends KinematicBody2D

enum MovingPlatformDirection {
	Vertical,
	Horizontal,
}

export(float) var speed = 1
export(float) var amplitude = 30
export(MovingPlatformDirection) var direction = MovingPlatformDirection.Vertical

onready var start = position
onready var accumulator = 0

func _physics_process(delta):
	accumulator += delta * speed
	if direction == MovingPlatformDirection.Horizontal:
		position.x = start.x + cos(accumulator) * amplitude
	else:
		position.y = start.y + cos(accumulator) * amplitude