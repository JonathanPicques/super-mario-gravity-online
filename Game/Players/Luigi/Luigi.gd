extends "res://Game/Players/Player.gd"

# _ready is called when the player node is ready.
# @driven(lifecycle)
# @impure
func _ready():
	set_state(PlayerState.stand)
	set_direction(direction)

	JUMP_STRENGTH = -150
	CEILING_KNOCKDOWN = 50
	WALL_JUMP_STRENGTH = -120
	WALL_JUMP_PUSH_STRENGTH = 80

	WALK_MAX_SPEED = 100
	WALK_ACCELERATION = 230
	WALK_DECELERATION = 250

	RUN_MAX_SPEED = 130
	RUN_ACCELERATION = 230
	RUN_DECELERATION = 290

	GRAVITY_MAX_SPEED = 430
	GRAVITY_ACCELERATION = 300

# Luigi cannot ground pound.
func pre_ground_pound():
	return set_state(PlayerState.fall)