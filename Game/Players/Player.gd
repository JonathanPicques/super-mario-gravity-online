extends KinematicBody2D

onready var PlayerTimer = $"Timer"
onready var PlayerSprite = $"Sprite"
onready var PlayerEveryTimer = $"EveryTimer"
onready var PlayerWallChecker = $"WallChecker"
onready var PlayerCollisionBody = $"CollisionBody"
onready var PlayerCollisionFloor = $"CollisionFloor"
onready var PlayerAnimationPlayer = $"AnimationPlayer"
onready var PlayerSoundEffectPlayers = [$"SoundEffects/SFX1", $"SoundEffects/SFX2", $"SoundEffects/SFX3", $"SoundEffects/SFX4"]

const FLOOR = Vector2(0, -1)
const FLOOR_SNAP = Vector2(0, 1)
const FLOOR_SNAP_DISABLED = Vector2()
const FLOOR_SNAP_DISABLE_TIME = 0.1
const INPUT_DOUBLE_TAP_THRESHOLD = 0.25

enum PlayerState {
	none,
	
	stand,
	stand_turn,
	
	crouch,

	walk,
	walk_skid,
	
	run,
	run_turn,
	
	move_turn,
	push_wall,
	
	fall,
	fall_to_stand,
	
	jump,
	
	ground_pound,
	ground_pound_fall,
	ground_pound_fall_to_stand,
	
	wallslide,
	walljump
}

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
var input_double_down_once = false

var input_velocity = Vector2()
var last_time_input_down = 0

var velocity = Vector2()
var velocity_prev = Vector2()
var velocity_offset = Vector2()

var direction = 1

var disable_snap = 0

# process_input updates player inputs.
# @param(float) delta
# @impure
func process_input(delta):
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
	last_time_input_down = max(last_time_input_down - delta, 0)
	if input_down_once:
		if last_time_input_down > 0:
			input_double_down_once = true
			last_time_input_down = 0
		last_time_input_down = INPUT_DOUBLE_TAP_THRESHOLD
	
	input_velocity = Vector2(int(input_right) - int(input_left), int(input_down) - int(input_up))

# process_velocity updates position after applying velocity
# @param(float) delta
# @impure
func process_velocity(delta):
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
# @param(PlayerState) new_state
# @impure
func set_state(new_state):
	state = new_state

# set_direction changes the player direction and flips the sprite accordingly.
# @param(float) new_direction
# @impure
func set_direction(new_direction):
	direction = new_direction
	PlayerSprite.scale.x = abs(PlayerSprite.scale.x) * sign(direction)
	PlayerSprite.position.x = 9 if direction < 0 else -9
	PlayerWallChecker.cast_to.x = abs(PlayerWallChecker.cast_to.x) * sign(direction)

# set_animation changes the player animation.
# @impure
func set_animation(new_animation):
	PlayerAnimationPlayer.play(new_animation)

# is_animation_finished returns true if the animation is finished (and not looping).
# @returns(boolean)
# @pure
func is_animation_finished():
	return not PlayerAnimationPlayer.is_playing()

# start_timer starts a timer for the given duration in seconds.
# @param(float) duration
# @impure
func start_timer(duration):
	PlayerTimer.wait_time = duration
	PlayerTimer.start()

# is_timer_finished returns true if the timer is finished.
# @param(float) duration
# @pure
func is_timer_finished():
	return PlayerTimer.is_stopped()

# every_seconds returns true every given number of seconds.
# @impure
# @param(float) seconds
# @param(string) timer_tag
var _every_timer_tag = null
func every_seconds(seconds, timer_tag = "default"):
	if _every_timer_tag != timer_tag or PlayerEveryTimer.is_stopped():
		_every_timer_tag = timer_tag
		PlayerEveryTimer.wait_time = seconds
		PlayerEveryTimer.start()
		return true
	return false

# play_sound_effect plays a sound effect.
# @param(AudioStreamSample) stream
# @impure
func play_sound_effect(stream):
	var sound_effect_player = get_sound_effect_player()
	if sound_effect_player != null:
		sound_effect_player.stream = stream
		sound_effect_player.play()

# is_sound_effect_playing returns true if the given stream is playing.
# @param(AudioStreamSample) stream
# @returns(boolean)
# @pure
func is_sound_effect_playing(stream):
	for sound_effect_player in PlayerSoundEffectPlayers:
		if sound_effect_player.stream == stream and sound_effect_player.is_playing():
			return true
	return false

# get_sound_effect_player returns the next available (non-playing) audio stream for sound effects or null.
# @returns(AudioStreamPlayer3D)
# @pure
func get_sound_effect_player():
	for sound_effect_player in PlayerSoundEffectPlayers:
		if not sound_effect_player.is_playing():
			return sound_effect_player
	return null

# handle_jump jumps
# @param(float) jump_strength
# @impure
func handle_jump(jump_strength):
	velocity.y = jump_strength
	disable_snap = FLOOR_SNAP_DISABLE_TIME

# handle_walljump walljumps
# @param(float) walljump_strength
# @param(float) walljump_push_strength
# @impure
func handle_walljump(walljump_strength, walljump_push_strength):
	velocity.y = walljump_strength
	velocity.x = walljump_push_strength
	disable_snap = FLOOR_SNAP_DISABLE_TIME

# handle_gravity applies gravity to the velocity
# @param(float) delta
# @param(Vector2) max_speed
# @param(Vector2) acceleration
# @impure
func handle_gravity(delta, max_speed, acceleration):
	velocity.y = min(velocity.y + delta * acceleration.y, max_speed.y)

# handle_floor_move TODO DESCRIBE
# @param(float) delta
# @param(float) max_speed
# @param(float) acceleration
# @param(float) deceleration
# @impure
func handle_floor_move(delta, max_speed, acceleration, deceleration):
	if has_same_direction(direction, input_velocity.x):
		velocity.x = get_acceleration(delta, velocity.x, max_speed, acceleration)
	else:
		velocity.x = get_deceleration(delta, velocity.x, deceleration)

# handle_airborne_move TODO DESCRIBE
# @param(float) delta
# @param(float) max_speed
# @param(float) acceleration
# @param(float) deceleration
# @impure
func handle_airborne_move(delta, max_speed, acceleration, deceleration):
	if input_velocity.x != 0:
		velocity.x = clamp(velocity.x + delta * sign(input_velocity.x) * acceleration, -max_speed, max_speed)
	else:
		handle_deceleration_move(delta, deceleration)

# handle_deceleration_move TODO DESCRIBE
# @param(float) delta
# @param(float) deceleration
# @impure
func handle_deceleration_move(delta, deceleration):
	velocity.x = get_deceleration(delta, velocity.x, deceleration)

# get_acceleration returns the next value after acceleration is applied.
# @param(float) delta
# @param(float) value
# @param(Vector2) max_speed
# @param(Vector2) acceleration
# @pure
func get_acceleration(delta, value, max_speed, acceleration, override_direction = direction):
	return min(abs(value) + delta * acceleration, max_speed) * sign(override_direction)

# get_deceleration returns the next value after deceleration is applied.
# @param(float) delta
# @param(float) value
# @param(Vector2) acceleration
# @pure
func get_deceleration(delta, value, deceleration):
	return max(abs(value) - delta * deceleration, 0) * sign(value)

# is_nearly returns true if the first given value nearly equals the second given value.
# @param(float) value1
# @param(float) value2
# @param(float) epsilon
# @returns(boolean)
# @pure
func is_nearly(value1, value2, epsilon = 0.001):
	return abs(value1 - value2) < epsilon

# is_on_wall_passive returns true if there is a wall on the side.
# @returns(boolean)
# @~pure
func is_on_wall_passive():
	return PlayerWallChecker.is_colliding()

# has_same_direction returns true if the two given numbers are non-zero and of the same sign.
# @param(float) a
# @param(float) b
# returns(boolean)
# @pure
func has_same_direction(a, b):
	return a != 0 and b != 0 and sign(a) == sign(b)

# has_invert_direction returns true if the two given numbers are non-zero and of the opposed sign.
# @param(float) a
# @param(float) b
# returns(boolean)
# @pure
func has_invert_direction(a, b):
	return a != 0 and b != 0 and sign(a) != sign(b)