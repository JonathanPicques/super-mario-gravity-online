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
	

	run,
	walk,
	crouch,
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
var last_time_input_down = 0.0

var velocity = Vector2()
var velocity_prev = Vector2()
var velocity_offset = Vector2()
var disable_snap = 0.0

var direction = 1

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
	last_time_input_down = max(last_time_input_down - delta, 0)
	if input_down_once:
		if last_time_input_down > 0:
			input_double_down_once = true
			last_time_input_down = 0
		last_time_input_down = INPUT_DOUBLE_TAP_THRESHOLD
	
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