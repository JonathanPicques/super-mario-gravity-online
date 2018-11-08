extends "res://Game/Players/Player.gd"

# _ready is called when the player node is ready.
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

	JUMP_STRENGTH = -180
	CEILING_KNOCKDOWN = 50
	WALL_JUMP_STRENGTH = -120
	WALL_JUMP_PUSH_STRENGTH = 80

	WALK_MAX_SPEED = 120
	WALK_ACCELERATION = 250
	WALK_DECELERATION = 320
	
	RUN_MAX_SPEED = 160
	RUN_ACCELERATION = 290
	RUN_DECELERATION = 340

	GRAVITY_MAX_SPEED = 500
	GRAVITY_ACCELERATION = 500