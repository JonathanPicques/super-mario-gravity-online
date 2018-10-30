extends "res://Game/Players/Player.gd"

onready var BumpSFX = preload("res://Game/Players/Mario/Sounds/bump.ogg")
onready var JumpSFX = preload("res://Game/Players/Mario/Sounds/smb_jump.ogg")
onready var SkidSFX = preload("res://Game/Players/Mario/Sounds/smas_skid.ogg")
onready var StepSFX = preload("res://Game/Players/Mario/Sounds/step_default.ogg")
onready var CrouchSFX = preload("res://Game/Players/Mario/Sounds/crouch.ogg")
onready var WalljumpSFX = preload("res://Game/Players/Mario/Sounds/smas_kick.ogg")
onready var GroundPoundSFX = preload("res://Game/Players/Mario/Sounds/yi_poundbegin.ogg")
onready var GroundPoundFallToStandSFX = preload("res://Game/Players/Mario/Sounds/yi_poundend.ogg")

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

const GRAVITY_MAX_SPEED = Vector2(0, 500)
const GRAVITY_ACCELERATION = Vector2(0, 500)

var wallslide_cancelled = false # reset on stand or walljump

# _physics_process is called when the player node is ready.
# @driven(lifecycle)
# @impure
func _ready():
	set_state(PlayerState.stand)
	set_direction(direction)

# _physics_process is called every process tick and updates player state.
# @driven(lifecycle)
# @impure
func _physics_process(delta):
	process_input(delta)
	process_velocity(delta)
	match state:
		PlayerState.stand: tick_stand(delta)
		PlayerState.stand_turn: tick_stand_turn(delta)
		PlayerState.run: tick_run(delta)
		PlayerState.walk: tick_walk(delta)
		PlayerState.crouch: tick_crouch(delta)
		PlayerState.move_turn: tick_move_turn(delta)
		PlayerState.push_wall: tick_push_wall(delta)
		PlayerState.fall: tick_fall(delta)
		PlayerState.fall_to_stand: tick_fall_to_stand(delta)
		PlayerState.jump: tick_jump(delta)
		PlayerState.wallslide: tick_wallslide(delta)
		PlayerState.walljump: tick_walljump(delta)
		PlayerState.ground_pound: tick_ground_pound(delta)
		PlayerState.ground_pound_fall: tick_ground_pound_fall(delta)
		PlayerState.ground_pound_fall_to_stand: tick_ground_pound_fall_to_stand(delta)

# set_state changes the current player state to the new given state.
# @param(PlayerState) new_state
# @impure
func set_state(new_state):
	.set_state(new_state)
	match state:
		PlayerState.stand: pre_stand()
		PlayerState.stand_turn: pre_stand_turn()
		PlayerState.run: pre_run()
		PlayerState.walk: pre_walk()
		PlayerState.crouch: pre_crouch()
		PlayerState.move_turn: pre_move_turn()
		PlayerState.push_wall: pre_push_wall()
		PlayerState.fall: pre_fall()
		PlayerState.fall_to_stand: pre_fall_to_stand()
		PlayerState.jump: pre_jump()
		PlayerState.wallslide: pre_wallslide()
		PlayerState.walljump: pre_walljump()
		PlayerState.ground_pound: pre_ground_pound()
		PlayerState.ground_pound_fall: pre_ground_pound_fall()
		PlayerState.ground_pound_fall_to_stand: pre_ground_pound_fall_to_stand()

###
# Mario movement grounded states
###

func pre_stand():
	set_animation("stand")
	wallslide_cancelled = false

func tick_stand(delta):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	handle_deceleration_move(delta, WALK_MAX_SPEED)
	if not is_on_floor():
		return set_state(PlayerState.fall)
	if input_jump_once:
		return set_state(PlayerState.jump)
	if input_down:
		return set_state(PlayerState.crouch)
	if input_velocity.x != 0 and has_same_direction(direction, input_velocity.x):
		return set_state(PlayerState.walk)
	elif input_velocity.x != 0 and not has_same_direction(direction, input_velocity.x):
		return set_state(PlayerState.move_turn)

func pre_stand_turn():
	set_direction(-direction)

func tick_stand_turn(delta):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	handle_floor_move(delta, WALK_MAX_SPEED, WALK_ACCELERATION, WALK_DECELERATION)
	if not is_on_floor():
		return set_state(PlayerState.fall)
	return set_state(PlayerState.stand)

func pre_run():
	set_animation("run")

func tick_run(delta):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	handle_floor_move(delta, RUN_MAX_SPEED, RUN_ACCELERATION, RUN_DECELERATION)
	if not is_on_floor():
		return set_state(PlayerState.fall)
	if is_on_wall():
		return set_state(PlayerState.push_wall)
	if input_down:
		return set_state(PlayerState.crouch)
	if input_jump_once:
		return set_state(PlayerState.jump)
	if not input_run:
		return set_state(PlayerState.walk)
	if input_velocity.x != 0 and has_invert_direction(direction, input_velocity.x):
		return set_state(PlayerState.move_turn)
	if input_velocity.x == 0 and velocity.x == 0:
		return set_state(PlayerState.stand)
	# special effects
	if every_seconds(0.30, "run"):
		play_sound_effect(StepSFX)

func pre_walk():
	set_animation("walk")

func tick_walk(delta):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	handle_floor_move(delta, WALK_MAX_SPEED, WALK_ACCELERATION, WALK_DECELERATION)
	if not is_on_floor():
		return set_state(PlayerState.fall)
	if is_on_wall():
		return set_state(PlayerState.push_wall)
	if input_down:
		return set_state(PlayerState.crouch)
	if input_jump_once:
		return set_state(PlayerState.jump)
	if input_run:
		return set_state(PlayerState.run)
	if input_velocity.x != 0 and has_invert_direction(direction, input_velocity.x):
		return set_state(PlayerState.move_turn)
	if input_velocity.x == 0 and velocity.x == 0:
		return set_state(PlayerState.stand)
	# special effects
	if every_seconds(0.35, "walk"):
		play_sound_effect(StepSFX)

func pre_crouch():
	set_animation("crouch")
	play_sound_effect(CrouchSFX)

func tick_crouch(delta):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	handle_deceleration_move(delta, WALK_DECELERATION * 2)
	if not is_on_floor():
		return set_state(PlayerState.fall)
	if is_animation_finished() and not input_down:
		return set_state(PlayerState.stand)

func pre_move_turn():
	set_animation("skid")

func tick_move_turn(delta):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	handle_floor_move(delta, \
		WALK_MAX_SPEED if not input_run else RUN_MAX_SPEED, \
		WALK_ACCELERATION if not input_run else RUN_ACCELERATION, \
		(WALK_DECELERATION if not input_run else RUN_DECELERATION) * 2 \
	)
	if not is_on_floor():
		set_direction(-direction)
		return set_state(PlayerState.fall)
	if has_same_direction(direction, input_velocity.x):
		return set_state(PlayerState.walk)
	if input_jump_once:
		set_direction(-direction)
		return set_state(PlayerState.jump)
	if velocity.x == 0:
		set_direction(-direction)
		return set_state(PlayerState.walk)
	# special effects
	if every_seconds(0.1, "move_turn"):
		play_sound_effect(SkidSFX)

func pre_push_wall():
	set_animation("push")

func tick_push_wall(delta):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	handle_floor_move(delta, WALK_MAX_SPEED, WALK_ACCELERATION, WALK_DECELERATION)
	if not is_on_floor():
		return set_state(PlayerState.fall)
	if not is_on_wall():
		return set_state(PlayerState.stand)
	if input_jump_once:
		return set_state(PlayerState.jump)

###
# Mario movement airborne states
###

func pre_fall():
	start_timer(0.2)
	set_animation("fall")

func tick_fall(delta):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	handle_airborne_move(delta, \
		WALK_MAX_SPEED if not input_run else RUN_MAX_SPEED, \
		WALK_ACCELERATION if not input_run else RUN_ACCELERATION, \
		WALK_DECELERATION if not input_run else RUN_DECELERATION \
	)
	if is_on_floor():
		return set_state(PlayerState.fall_to_stand)
	if is_on_wall_passive() and not input_down and (\
		(not wallslide_cancelled and is_timer_finished()) or \
		(not wallslide_cancelled and has_same_direction(direction, input_velocity.x)) or \
		(wallslide_cancelled and is_timer_finished() and has_same_direction(direction, input_velocity.x))
	):
		return set_state(PlayerState.wallslide)
	if input_double_down_once:
		return set_state(PlayerState.ground_pound)

func pre_fall_to_stand():
	start_timer(0.05)
	set_animation("stand")

func tick_fall_to_stand(delta):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	handle_deceleration_move(delta, WALK_DECELERATION if not input_run else RUN_DECELERATION)
	if not is_on_floor():
		return set_state(PlayerState.fall)
	if input_jump_once:
		return set_state(PlayerState.jump)
	if is_timer_finished():
		if has_invert_direction(direction, velocity.x):
			set_direction(-direction)
		return set_state(PlayerState.stand if velocity.x == 0 else PlayerState.walk)

func pre_jump():
	handle_jump(JUMP_STRENGTH)
	set_animation("jump")
	play_sound_effect(JumpSFX)

func tick_jump(delta):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION if not input_jump else GRAVITY_ACCELERATION * 0.75)
	handle_airborne_move(delta, \
		WALK_MAX_SPEED if not input_run else RUN_MAX_SPEED, \
		WALK_ACCELERATION if not input_run else RUN_ACCELERATION, \
		WALK_DECELERATION if not input_run else RUN_DECELERATION \
	)
	if is_on_floor():
		return set_state(PlayerState.stand)
	if is_on_ceiling():
		velocity.y = CEILING_KNOCKDOWN
		if not is_colliding_with_group("no_ceiling_sound"):
			play_sound_effect(BumpSFX)
		return set_state(PlayerState.fall)
	if velocity.y > 0:
		return set_state(PlayerState.fall)
	if input_double_down_once:
		return set_state(PlayerState.ground_pound)

###
# Mario movement wall states
###

func pre_wallslide():
	velocity.y = velocity.y * 0.1
	set_animation("wallslide")

func tick_wallslide(delta):
	handle_gravity(delta, GRAVITY_MAX_SPEED * 0.5, GRAVITY_ACCELERATION * 0.25)
	if is_on_floor():
		return set_state(PlayerState.fall_to_stand)
	if not is_on_wall_passive():
		return set_state(PlayerState.fall)
	if input_down_once:
		wallslide_cancelled = true
		return set_state(PlayerState.fall)
	if input_jump_once:
		return set_state(PlayerState.walljump)

func pre_walljump():
	set_animation("jump")
	set_direction(-direction)
	handle_walljump(JUMP_STRENGTH, sign(direction) * WALL_JUMP_PUSH_STRENGTH)
	play_sound_effect(WalljumpSFX)
	wallslide_cancelled = false

func tick_walljump(delta):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION if not input_jump else GRAVITY_ACCELERATION * 0.75)
	handle_airborne_move(delta,
		WALK_MAX_SPEED if not input_run else RUN_MAX_SPEED, \
		WALK_ACCELERATION if not input_run else RUN_ACCELERATION, \
		(WALK_DECELERATION if not input_run else RUN_DECELERATION) * 0.25 \
	)
	if is_on_floor():
		return set_state(PlayerState.stand)
	if is_on_ceiling():
		velocity.y = CEILING_KNOCKDOWN
		if not is_colliding_with_group("no_ceiling_sound"):
			play_sound_effect(BumpSFX)
		return set_state(PlayerState.fall)
	if velocity.y > 0:
		return set_state(PlayerState.fall)
	if input_double_down_once:
		return set_state(PlayerState.ground_pound)

###
# Mario attack states
###

func pre_ground_pound():
	velocity.x = 0
	velocity.y = 0
	set_animation("ground_pound")
	play_sound_effect(GroundPoundSFX)

func tick_ground_pound(delta):
	if is_on_floor():
		return set_state(PlayerState.stand)
	if is_animation_finished():
		return set_state(PlayerState.ground_pound_fall)

func pre_ground_pound_fall():
	set_animation("ground_pound_fall")

func tick_ground_pound_fall(delta):
	handle_gravity(delta, GRAVITY_MAX_SPEED * 2, GRAVITY_ACCELERATION * 4)
	if is_on_floor():
		return set_state(PlayerState.ground_pound_fall_to_stand)

func pre_ground_pound_fall_to_stand():
	set_animation("ground_pound_fall_to_stand")
	play_sound_effect(GroundPoundFallToStandSFX)

func tick_ground_pound_fall_to_stand(delta):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	if not is_on_floor():
		return set_state(PlayerState.fall)
	if is_animation_finished():
		return set_state(PlayerState.stand)