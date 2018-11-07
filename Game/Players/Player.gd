extends KinematicBody2D

onready var PlayerTimer: Timer = $"Timer"
onready var PlayerSprite: Sprite = $"Sprite"
onready var PlayerEveryTimer: Timer = $"EveryTimer"
onready var PlayerWallChecker: RayCast2D = $"WallChecker"
onready var PlayerCollisionBody: CollisionShape2D = $"CollisionBody"
onready var PlayerAnimationPlayer: AnimationPlayer = $"AnimationPlayer"
onready var PlayerSoundEffectPlayers = [$"SoundEffects/SFX1", $"SoundEffects/SFX2", $"SoundEffects/SFX3", $"SoundEffects/SFX4"]

onready var BumpSFX: AudioStream
onready var JumpSFX: AudioStream
onready var SkidSFX: AudioStream
onready var StepSFX: AudioStream
onready var CrouchSFX: AudioStream
onready var WalljumpSFX: AudioStream
onready var GroundPoundSFX: AudioStream
onready var GroundPoundFallToStandSFX: AudioStream

enum PlayerState {
	none,
	stand, stand_turn,
	run, walk, crouch, move_turn, push_wall,
	fall, fall_to_stand, jump,
	ground_pound, ground_pound_fall, ground_pound_fall_to_stand,
	wallslide, walljump
}

const FLOOR = Vector2(0, -1)
const FLOOR_SNAP = Vector2(0, 1)
const FLOOR_SNAP_DISABLED = Vector2()
const FLOOR_SNAP_DISABLE_TIME = 0.1
const INPUT_DOUBLE_TAP_THRESHOLD = 0.25

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

var state = PlayerState.none

var input_up = false
var input_run = false
var input_down = false
var input_left = false
var input_jump = false
var input_right = false
var input_up_once = false
var input_run_once = false
var input_down_once = false
var input_left_once = false
var input_jump_once = false
var input_right_once = false
var input_down_last_time = 0.0
var input_double_down_once = false

var velocity = Vector2()
var velocity_prev = Vector2()
var input_velocity = Vector2()
var velocity_offset = Vector2()
var disable_snap = 0.0

var direction = 1
var wallslide_cancelled = false # reset on stand or walljump

# _physics_process is called every process tick and updates player state.
# @driven(lifecycle)
# @impure
func _physics_process(delta: float):
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

# process_input updates player inputs.
# @impure
func process_input(delta: float):
	input_up = Input.is_action_pressed("player_0_up")
	input_run = Input.is_action_pressed("player_0_run")
	input_down = Input.is_action_pressed("player_0_down")
	input_left = Input.is_action_pressed("player_0_left")
	input_jump = Input.is_action_pressed("player_0_jump")
	input_right = Input.is_action_pressed("player_0_right")
	
	input_up_once = Input.is_action_just_pressed("player_0_up")
	input_run_once = Input.is_action_just_pressed("player_0_run")
	input_down_once = Input.is_action_just_pressed("player_0_down")
	input_left_once = Input.is_action_just_pressed("player_0_left")
	input_jump_once = Input.is_action_just_pressed("player_0_jump")
	input_right_once = Input.is_action_just_pressed("player_0_right")
	
	input_double_down_once = false
	input_down_last_time = max(input_down_last_time - delta, 0)
	if input_down_once:
		if input_down_last_time > 0:
			input_double_down_once = true
			input_down_last_time = 0
		input_down_last_time = INPUT_DOUBLE_TAP_THRESHOLD
	
	input_velocity = Vector2(int(input_right) - int(input_left), int(input_down) - int(input_up))

# process_velocity updates position after applying velocity.
# @impure
func process_velocity(delta: float):
	if disable_snap > 0:
		disable_snap = max(disable_snap - delta, 0)
	var old_position = position
	velocity_prev = velocity
	velocity = move_and_slide_with_snap(velocity, FLOOR_SNAP if disable_snap == 0 else FLOOR_SNAP_DISABLED, FLOOR)
	var offset = position - old_position
	velocity_offset = Vector2(
		0 if is_nearly(offset.x, 0) else velocity.x,
		0 if is_nearly(offset.y, 0) else velocity.y
	)

# set_state changes the current player state to the new given state.
# @impure
func set_state(new_state: int):
	state = new_state
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

# set_direction changes the player direction and flips the sprite accordingly.
# @impure
func set_direction(new_direction: int):
	direction = new_direction
	PlayerSprite.scale.x = abs(PlayerSprite.scale.x) * sign(direction)
	PlayerSprite.position.x = 9 if direction < 0 else -9
	PlayerWallChecker.cast_to.x = abs(PlayerWallChecker.cast_to.x) * sign(direction)

# set_animation changes the player animation.
# @impure
func set_animation(new_animation: String):
	PlayerAnimationPlayer.play(new_animation)

# is_animation_finished returns true if the animation is finished (and not looping).
# @pure
func is_animation_finished() -> bool:
	return not PlayerAnimationPlayer.is_playing()

# start_timer starts a timer for the given duration in seconds.
# @impure
func start_timer(duration: float):
	PlayerTimer.wait_time = duration
	PlayerTimer.start()

# is_timer_finished returns true if the timer is finished.
# @pure
func is_timer_finished() -> bool:
	return PlayerTimer.is_stopped()

# every_seconds returns true every given number of seconds.
# @impure
var _every_timer_tag = null
func every_seconds(seconds: float, timer_tag = "default") -> bool:
	if _every_timer_tag != timer_tag or PlayerEveryTimer.is_stopped():
		_every_timer_tag = timer_tag
		PlayerEveryTimer.wait_time = seconds
		PlayerEveryTimer.start()
		return true
	return false

# play_sound_effect plays a sound effect.
# @impure
func play_sound_effect(stream: AudioStream):
	var sound_effect_player = get_sound_effect_player()
	if sound_effect_player != null:
		sound_effect_player.stream = stream
		sound_effect_player.play()

# is_sound_effect_playing returns true if the given stream is playing.
# @pure
func is_sound_effect_playing(stream: AudioStream) -> bool:
	for sound_effect_player in PlayerSoundEffectPlayers:
		if sound_effect_player.stream == stream and sound_effect_player.is_playing():
			return true
	return false

# get_sound_effect_player returns the next available (non-playing) audio stream for sound effects or null.
# @pure
func get_sound_effect_player() -> AudioStreamPlayer2D:
	for sound_effect_player in PlayerSoundEffectPlayers:
		if not sound_effect_player.is_playing():
			return sound_effect_player
	return null

# is_colliding_with_group returns true if the player is colliding with the given group.
# @pure
func is_colliding_with_group(group: String) -> bool:
	var collision = get_slide_collision(0)
	if collision:
		return collision.collider.is_in_group(group)
	return false

# handle_jump jumps.
# @impure
func handle_jump(jump_strength: float):
	velocity.y = jump_strength
	disable_snap = FLOOR_SNAP_DISABLE_TIME

# handle_walljump walljumps.
# @impure
func handle_walljump(walljump_strength: float, walljump_push_strength: float):
	velocity.y = walljump_strength
	velocity.x = walljump_push_strength
	disable_snap = FLOOR_SNAP_DISABLE_TIME

# handle_gravity applies gravity to the velocity.
# @impure
func handle_gravity(delta: float, max_speed: float, acceleration: float):
	velocity.y = min(velocity.y + delta * acceleration, max_speed)

# handle_floor_move applies acceleration or deceleration depending on the input_velocity on the floor.
# @impure
func handle_floor_move(delta: float, max_speed: float, acceleration: float, deceleration: float):
	if has_same_direction(direction, input_velocity.x):
		velocity.x = get_acceleration(delta, velocity.x, max_speed, acceleration)
	else:
		velocity.x = get_deceleration(delta, velocity.x, deceleration)

# handle_airborne_move applies acceleration or deceleration depending on the input_velocity while airborne.
# @impure
func handle_airborne_move(delta: float, max_speed: float, acceleration: float, deceleration: float):
	if input_velocity.x != 0:
		velocity.x = clamp(velocity.x + delta * sign(input_velocity.x) * acceleration, -max_speed, max_speed)
	else:
		handle_deceleration_move(delta, deceleration)

# handle_deceleration_move applies deceleration.
# @impure
func handle_deceleration_move(delta: float, deceleration: float):
	velocity.x = get_deceleration(delta, velocity.x, deceleration)

# get_acceleration returns the next value after acceleration is applied.
# @pure
func get_acceleration(delta: float, value: float, max_speed: float, acceleration: float, override_direction = direction) -> float:
	return min(abs(value) + delta * acceleration, max_speed) * sign(override_direction)

# get_deceleration returns the next value after deceleration is applied.
# @pure
func get_deceleration(delta: float, value: float, deceleration: float) -> float:
	return max(abs(value) - delta * deceleration, 0) * sign(value)

# is_nearly returns true if the first given value nearly equals the second given value.
# @pure
func is_nearly(value1: float, value2: float, epsilon = 0.001) -> bool:
	return abs(value1 - value2) < epsilon

# is_on_wall_passive returns true if there is a wall on the side.
# @pure
func is_on_wall_passive() -> bool:
	return PlayerWallChecker.is_colliding()

# has_same_direction returns true if the two given numbers are non-zero and of the same sign.
# @pure
func has_same_direction(dir1: float, dir2: float) -> bool:
	return dir1 != 0 and dir2 != 0 and sign(dir1) == sign(dir2)

# has_invert_direction returns true if the two given numbers are non-zero and of the opposed sign.
# @pure
func has_invert_direction(dir1: float, dir2: float) -> bool:
	return dir1 != 0 and dir2 != 0 and sign(dir1) != sign(dir2)

###
# Player movement grounded states
###

func pre_stand():
	set_animation("stand")
	wallslide_cancelled = false

func tick_stand(delta: float):
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

func tick_stand_turn(delta: float):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	handle_floor_move(delta, WALK_MAX_SPEED, WALK_ACCELERATION, WALK_DECELERATION)
	if not is_on_floor():
		return set_state(PlayerState.fall)
	return set_state(PlayerState.stand)

func pre_run():
	set_animation("run")

func tick_run(delta: float):
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

func tick_walk(delta: float):
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

func tick_crouch(delta: float):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	handle_deceleration_move(delta, WALK_DECELERATION * 2)
	if not is_on_floor():
		return set_state(PlayerState.fall)
	if is_animation_finished() and not input_down:
		return set_state(PlayerState.stand)

func pre_move_turn():
	set_animation("skid")

func tick_move_turn(delta: float):
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

func tick_push_wall(delta: float):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	handle_floor_move(delta, WALK_MAX_SPEED, WALK_ACCELERATION, WALK_DECELERATION)
	if not is_on_floor():
		return set_state(PlayerState.fall)
	if not is_on_wall():
		return set_state(PlayerState.stand)
	if input_jump_once:
		return set_state(PlayerState.jump)

###
# Player movement airborne states
###

func pre_fall():
	start_timer(0.2)
	set_animation("fall")

func tick_fall(delta: float):
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

func tick_fall_to_stand(delta: float):
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

func tick_jump(delta: float):
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
# Player movement wall states
###

func pre_wallslide():
	velocity.y = velocity.y * 0.1
	set_animation("wallslide")

func tick_wallslide(delta: float):
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

func tick_walljump(delta: float):
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
# Player attack states
###

func pre_ground_pound():
	velocity.x = 0
	velocity.y = 0
	set_animation("ground_pound")
	play_sound_effect(GroundPoundSFX)

func tick_ground_pound(delta: float):
	if is_on_floor():
		return set_state(PlayerState.stand)
	if is_animation_finished():
		return set_state(PlayerState.ground_pound_fall)

func pre_ground_pound_fall():
	set_animation("ground_pound_fall")

func tick_ground_pound_fall(delta: float):
	handle_gravity(delta, GRAVITY_MAX_SPEED * 2, GRAVITY_ACCELERATION * 4)
	if is_on_floor():
		return set_state(PlayerState.ground_pound_fall_to_stand)

func pre_ground_pound_fall_to_stand():
	set_animation("ground_pound_fall_to_stand")
	play_sound_effect(GroundPoundFallToStandSFX)

func tick_ground_pound_fall_to_stand(delta: float):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	if not is_on_floor():
		return set_state(PlayerState.fall)
	if is_animation_finished():
		return set_state(PlayerState.stand)