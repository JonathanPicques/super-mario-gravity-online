extends "res://Game/Players/Player.gd"

const JUMP_STRENGTH = -180
const CEILING_KNOCKDOWN = 50
const WALL_JUMP_STRENGTH = -120
const WALL_JUMP_PUSH_STRENGTH = 80

const WALK_MAX_SPEED = 120
const WALK_ACCELERATION = 250
const WALK_DECELERATION = 320

const RUN_MAX_SPEED = 160
const RUN_ACCELERATION = 290
const RUN_DECELERATION = 340

const GRAVITY_MAX_SPEED = 500
const GRAVITY_ACCELERATION =  500

# _physics_process is called when the player node is ready.
# @driven(lifecycle)
# @impure
func _ready():
	set_state(PlayerState.stand)
	set_direction(direction)
	BumpSFX = preload("res://Game/Players/Mario/Sounds/bump.ogg")
	JumpSFX = preload("res://Game/Players/Mario/Sounds/smb_jump.ogg")
	SkidSFX = preload("res://Game/Players/Mario/Sounds/smas_skid.ogg")
	StepSFX = preload("res://Game/Players/Mario/Sounds/step_default.ogg")
	CrouchSFX = preload("res://Game/Players/Mario/Sounds/crouch.ogg")
	WalljumpSFX = preload("res://Game/Players/Mario/Sounds/smas_kick.ogg")
	GroundPoundSFX = preload("res://Game/Players/Mario/Sounds/yi_poundbegin.ogg")
	GroundPoundFallToStandSFX = preload("res://Game/Players/Mario/Sounds/yi_poundend.ogg")