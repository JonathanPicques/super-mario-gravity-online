extends "res://Game/Players/Player.gd"

const JUMP_STRENGTH = -150
const CEILING_KNOCKDOWN = 50
const WALL_JUMP_STRENGTH = -120
const WALL_JUMP_PUSH_STRENGTH = 80

const WALK_MAX_SPEED = 100
const WALK_ACCELERATION = 230
const WALK_DECELERATION = 250

const RUN_MAX_SPEED = 130
const RUN_ACCELERATION = 230
const RUN_DECELERATION = 290

const GRAVITY_MAX_SPEED = 430
const GRAVITY_ACCELERATION = 300

# _physics_process is called when the player node is ready.
# @driven(lifecycle)
# @impure
func _ready():
	set_state(PlayerState.stand)
	set_direction(direction)

# Luigi cannot ground pound.
func pre_ground_pound():
	return set_state(PlayerState.fall)