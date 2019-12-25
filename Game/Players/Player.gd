extends KinematicBody2D
class_name PlayerNode

const SpriteTrail := preload("res://Game/Effects/Sprites/SpriteTrail.tscn")
const GroundDustFX := preload("res://Game/Effects/Particles/GroundDust.tscn")

onready var PlayerTimer: Timer = $Timer
onready var PlayerSprite: Sprite = $Sprite
onready var PlayerArea2D: Area2D = $Area2D
onready var PlayerObjectTimer: Timer = $ObjectTimer
onready var PlayerLifetimeTimer: Timer = $LifetimeTimer
onready var PlayerCollisionBody: CollisionShape2D = $CollisionBody
onready var PlayerCeilingChecker: RayCast2D = $CeilingChecker
onready var PlayerLeftFootChecker: RayCast2D = $LeftFootChecker
onready var PlayerRightFootChecker: RayCast2D = $RightFootChecker
onready var PlayerAnimationPlayer: AnimationPlayer = $AnimationPlayer
onready var PlayerSoundEffectPlayers := [$SoundEffects/SFX1, $SoundEffects/SFX2, $SoundEffects/SFX3, $SoundEffects/SFX4]
onready var PlayerNetworkDeadReckoning: Tween = $NetworkDeadReckoning

onready var BumpSFX: AudioStream
onready var JumpSFX: AudioStream
onready var DeathSFX: AudioStream
onready var WalljumpSFX: AudioStream
onready var Step_01_SFX: AudioStream
onready var Step_02_SFX: AudioStream

enum PlayerState {
	none, stand, run, move_turn, push_wall,
	fall, jump, expulse, wallslide, walljump,
	enter_door, enter_door_fade
	use_object,
	death, respawn,
}

enum DialogType {
	none, ready
}

const FLOOR := Vector2(0, -1) # floor direction.
const FLOOR_SNAP := Vector2(0, 5) # floor snap for slopes.
const FLOOR_SNAP_DISABLED := Vector2() # no floor snap for slopes.
const FLOOR_SNAP_DISABLE_TIME := 0.1 # time during snapping is disabled.
const FALLING_VELOCITY_THRESHOLD := 5.0 # velocity were we consider the player is falling

const NET_VIEW_INPUT_INDEX := 0
const NET_VIEW_POSITION_INDEX := 1
const NET_VIEW_VELOCITY_INDEX := 2

var player = null # player reference.

var input_up := false
var input_down := false
var input_left := false
var input_right := false
var input_run := false
var input_use := false
var input_jump := false
var input_up_once := false
var input_down_once := false
var input_left_once := false
var input_right_once := false
var input_run_once := false
var input_use_once := false
var input_jump_once := false

var SPEED_MULTIPLIER := 2
var INVINCIBILITY_SPEED_MULTIPLIER := 1.0
var PRINCE_SPEED_MULTIPLIER := 1.5

var OBJECT_TIME_SPEED := 6.0
var OBJECT_TIME_INVINCIBILITY := 6.0
var OBJECT_TIME_PRINCE = 8.0

var RUN_MAX_SPEED := 145.0
var RUN_ACCELERATION := 630.0
var RUN_DECELERATION := 690.0

var MAX_JUMPS := 2
var JUMP_STRENGTH := -350.0
var FALL_JUMP_GRACE := 0.08
var EXPULSE_STRENGTH := 580.0
var CEILING_KNOCKDOWN := 50.0
var WALL_JUMP_STRENGTH := -330.0
var WALL_JUMP_PUSH_STRENGTH := 55.0
var WALL_SLIDE_STICK_WALL_JUMP := 0.18

var GRAVITY_MAX_SPEED := 1200.0
var GRAVITY_ACCELERATION := 1300.0

const DOOR_RUN_SPEED = 40.0
const DOOR_PLAYER_FADE_DURATION = 0.5
const DOOR_SCREEN_FADE_DURATION = 0.5

const TRAIL_OBJECT_TYPES = [ObjectSpeedNode, ObjectPrinceNode] 
var has_trail := false
var has_lifetime := false
var is_invincible := false
var speed_multiplier := 1.0

var state: int = PlayerState.none
var velocity := Vector2()
var direction := 1
var disable_snap := 0.0
var velocity_prev := Vector2()
var input_velocity := Vector2()
var velocity_offset := Vector2()
var fall_jump_grace := 0.0
var jumps_remaining := MAX_JUMPS  # reset on stand or wallslide or expulse
var expulse_direction := Vector2.ZERO
var last_safe_position := Vector2()
var wallslide_cancelled := false # reset on stand or walljump

var current_door_to: DoorNode
var current_door_from: DoorNode

var active_object = null
var current_object = null
var current_object_index = null

# @impure
func _ready():
	set_state(PlayerState.respawn)
	set_dialog(DialogType.none, false)
	set_process(!!get_tree().network_peer)
	set_direction(direction)
	SkinManager.replace_skin(PlayerSprite, player.skin_id, false)

# @impure
var _net_view_index := 0
func _process(delta):
	if player.local or is_network_master():
		var net_view := []
		net_view.insert(NET_VIEW_INPUT_INDEX, int(input_up) << 0 | int(input_down) << 0x1 | int(input_left) << 0x2 | int(input_right) << 0x3 | int(input_run) << 0x4 | int(input_use) << 0x5 | int(input_jump) << 0x6)
		net_view.insert(NET_VIEW_POSITION_INDEX, position)
		net_view.insert(NET_VIEW_VELOCITY_INDEX, velocity)
		_net_view_index += 1
		rpc_unreliable("_process_network", delta, net_view, _net_view_index)

# _physics_process is called every physics tick and updates player state.
# @impure
func _physics_process(delta: float):
	process_input(delta)
	process_death(delta)
	process_object(delta)
	process_effects(delta)
	process_velocity(delta)
	process_lifetime(delta)
	match state:
		PlayerState.stand: tick_stand(delta)
		PlayerState.run: tick_run(delta)
		PlayerState.move_turn: tick_move_turn(delta)
		PlayerState.push_wall: tick_push_wall(delta)
		PlayerState.fall: tick_fall(delta)
		PlayerState.jump: tick_jump(delta)
		PlayerState.expulse: tick_expulse(delta)
		PlayerState.wallslide: tick_wallslide(delta)
		PlayerState.walljump: tick_walljump(delta)
		PlayerState.enter_door: tick_enter_door(delta)
		PlayerState.enter_door_fade: tick_enter_door_fade(delta)
		PlayerState.use_object: tick_use_object(delta)
		PlayerState.death: tick_death(delta)
		PlayerState.respawn: tick_respawn(delta)

# _process_network updates player from the given network infos.
# @impure
var _last_net_view: Array
var _last_net_view_index = 0
remote func _process_network(delta: float, net_view: Array, net_view_index: int):
	# drop if received out of order
	if _last_net_view_index > net_view_index:
		return
	_last_net_view = net_view
	_last_net_view_index = net_view_index
	# compare position to adjust for network errors
	var peer_position: Vector2 = net_view[NET_VIEW_POSITION_INDEX]
	if abs(position.x - peer_position.x) > 10 or abs(position.y - peer_position.y) > 20:
		PlayerNetworkDeadReckoning.stop_all()
		PlayerNetworkDeadReckoning.interpolate_property(self, "position", position, peer_position, delta, Tween.TRANS_LINEAR, Tween.EASE_IN)
		PlayerNetworkDeadReckoning.start()

# process_input updates player inputs from local inputs or network inputs.
# @impure
var _up := false; var _down := false; var _left := false; var _right := false
var _run := false; var _use := false; var _jump := false
func process_input(delta: float):
	if player.local or is_network_master():
		# get inputs from gamepad or keyboard
		input_up = InputManager.is_player_action_pressed(player.id, "up")
		input_left = InputManager.is_player_action_pressed(player.id, "left")
		input_down = InputManager.is_player_action_pressed(player.id, "down")
		input_right = InputManager.is_player_action_pressed(player.id, "right")
		input_run = InputManager.is_player_action_pressed(player.id, "run")
		input_use = InputManager.is_player_action_pressed(player.id, "use")
		input_jump = InputManager.is_player_action_pressed(player.id, "jump")
	elif len(_last_net_view) > 0:
		# get inputs from last net view
		input_up = bool(_last_net_view[NET_VIEW_INPUT_INDEX] & (1 << 0))
		input_down = bool(_last_net_view[NET_VIEW_INPUT_INDEX] & (1 << 1))
		input_left = bool(_last_net_view[NET_VIEW_INPUT_INDEX] & (1 << 2))
		input_right = bool(_last_net_view[NET_VIEW_INPUT_INDEX] & (1 << 3))
		input_run = bool(_last_net_view[NET_VIEW_INPUT_INDEX] & (1 << 4))
		input_use = bool(_last_net_view[NET_VIEW_INPUT_INDEX] & (1 << 5))
		input_jump = bool(_last_net_view[NET_VIEW_INPUT_INDEX] & (1 << 6))
	# compute input just pressed
	input_up_once = not _up and input_up
	input_down_once = not _down and input_down
	input_left_once = not _left and input_left
	input_right_once = not _right and input_right
	input_run_once = not _run and input_run
	input_use_once = not _use and input_use
	input_jump_once = not _jump and input_jump
	# remember we pressed these inputs last frame
	_up = input_up
	_down = input_down
	_left = input_left
	_right = input_right
	_run = input_run
	_use = input_use
	_jump = input_jump
	# compute input velocity
	input_velocity = Vector2(int(input_right) - int(input_left), int(input_down) - int(input_up))

# process_death checks if the player should die.
# @impure
func process_death(delta: float):
	if state != PlayerState.death:
		if position.y > Game.map_node.killY:
			return set_state(PlayerState.death)

# process_object resets all stats affected by objects when timer finishes
# @impure
func process_object(delta: float):
	if PlayerObjectTimer.is_stopped():
		speed_multiplier = 1.0
		if active_object:
			if active_object.has_method("reset_player"):
				active_object.reset_player()
			active_object.queue_free()
			active_object = null

# check_trail return true if the active object should yield a trail behind the player.
# @pure
func check_trail(active_object):
	for obj_type in TRAIL_OBJECT_TYPES:
		if active_object is obj_type:
			return true
	return false

# process_effects plays all sprite effects applied to the player.
# @impure
var _trail := 0.0
func process_effects(delta: float):
	var is_explused = state == PlayerState.expulse and (abs(velocity.x) > RUN_MAX_SPEED or velocity.y < 0)
	if active_object and check_trail(active_object) or is_explused or has_trail:
		_trail += delta
		if _trail > 0.05:
			var trail_node := SpriteTrail.instance()
			trail_node.trail_sprite(PlayerSprite)
			Game.map_node.PlayerSlot.add_child_below_node(self, trail_node)
			_trail -= 0.05

# process_velocity updates player position after applying velocity.
# @impure
var _was_on_floor := false
func process_velocity(delta: float):
	if disable_snap > 0:
		disable_snap = max(disable_snap - delta, 0)
	var old_position := position
	if not _was_on_floor and is_on_floor():
		for i in get_slide_count():
			var collision := get_slide_collision(i)
			if is_nearly(velocity_prev.x, 0) and is_nearly(input_velocity.x, 0) and collision.normal != FLOOR:
				velocity = Vector2()
	if is_on_floor():
		_was_on_floor = true
	else:
		_was_on_floor = false
	velocity_prev = velocity
	velocity = move_and_slide_with_snap(velocity, FLOOR_SNAP if disable_snap == 0 else FLOOR_SNAP_DISABLED, FLOOR)
	var offset := position - old_position
	velocity_offset = Vector2(
		0.0 if is_nearly(offset.x, 0) else velocity.x,
		0.0 if is_nearly(offset.y, 0) else velocity.y
	)

# process_lifetime checks if a player transformation is over.
# @impure
func process_lifetime(delta: float):
	if has_lifetime and PlayerLifetimeTimer.is_stopped():
		set_class(MultiplayerManager.PlayerClass.Frog)

# set_state changes the current Player state to the new given state.
# @impure
func set_state(new_state: int):
	state = new_state
	match state:
		PlayerState.stand: pre_stand()
		PlayerState.run: pre_run()
		PlayerState.move_turn: pre_move_turn()
		PlayerState.push_wall: pre_push_wall()
		PlayerState.fall: pre_fall()
		PlayerState.jump: pre_jump()
		PlayerState.expulse: pre_expulse()
		PlayerState.wallslide: pre_wallslide()
		PlayerState.walljump: pre_walljump()
		PlayerState.enter_door: pre_enter_door()
		PlayerState.enter_door_fade: pre_enter_door_fade()
		PlayerState.use_object: pre_use_object()
		PlayerState.death: pre_death()
		PlayerState.respawn: pre_respawn()

# set_class changes the current class (animations, properties...) of the player
# @impure
func set_class(player_class: int):
	var player_node = MultiplayerManager.create_player_node(player, player_class)
	var player_camera = Game.game_mode_node.get_player_screen_camera(player.id) if Game.game_mode_node else null
	player_node.position = position
	player_node.velocity = Vector2()
	get_parent().call_deferred("remove_child", self)
	get_parent().call_deferred("add_child", player_node)
	player_node.call_deferred("set_direction", direction)
	if player_camera:
		player_camera.set_deferred("player_node", player_node)
	call_deferred("queue_free")
	return player_node

# set_direction changes the Player direction and flips the sprite accordingly.
# @impure
func set_direction(new_direction: int):
	direction = new_direction
	PlayerSprite.scale.x = abs(PlayerSprite.scale.x) * sign(direction)

# set_animation changes the Player animation.
# @impure
func set_animation(new_animation: String, animation_position = 0.0):
	PlayerAnimationPlayer.play(new_animation)
	PlayerAnimationPlayer.seek(animation_position)

# is_animation_playing returns true if the given animation is playing.
# @impure
func is_animation_playing(animation: String) -> bool:
	return PlayerAnimationPlayer.current_animation == animation

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

# is_colliding_with_group returns true if the Player is colliding with the given group.
# @pure
func is_colliding_with_group(group: String) -> bool:
	var collision := get_slide_collision(0)
	if collision:
		return collision.collider.is_in_group(group)
	return false

# play_sound_effect plays a sound effect.
# @impure
func play_sound_effect(stream: AudioStream):
	var sound_effect_player = get_sound_effect_player()
	if sound_effect_player:
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

# screen_shake applies screen shake effect
func screen_shake():
	var camera = Game.game_mode_node.get_player_screen_camera(player.id)
	camera.get_node("ScreenShake").start_shake()

# handle_jump applies strength to jump and disable floor snapping for a little while.
# @impure
func handle_jump(strength: float):
	velocity.y = strength
	disable_snap = FLOOR_SNAP_DISABLE_TIME

# handle_expulse applies expulse_direction to send the player flying.
# @impure
func handle_expulse(strength: float):
	velocity = expulse_direction * strength
	disable_snap = FLOOR_SNAP_DISABLE_TIME
	screen_shake()

# handle_gravity applies gravity to the velocity.
# @impure
func handle_gravity(delta: float, max_speed: float, acceleration: float):
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, max_speed, delta * acceleration)
	elif velocity.x == 0 and input_velocity.x == 0:
		velocity.y = 0

# handle_walljump walljumps.
# @impure
func handle_walljump(walljump_strength: float, walljump_push_strength: float):
	velocity.y = walljump_strength
	velocity.x = walljump_push_strength
	disable_snap = FLOOR_SNAP_DISABLE_TIME

# handle_direction changes the direction depending on the input velocity.
# @impure
func handle_direction():
	var input_direction := int(sign(input_velocity.x))
	if input_direction != 0:
		set_direction(input_direction)

# handle_last_safe_position saves the last safe position.
# @impure
func handle_last_safe_position():
	if PlayerLeftFootChecker.is_colliding() and PlayerRightFootChecker.is_colliding():
		for area in PlayerArea2D.get_overlapping_areas():
			if Game.has_collision_layer_bit(area.collision_layer, Game.COLLISION_LAYER_DEATH):
				return
		last_safe_position = position

# handle_floor_move applies acceleration or deceleration depending on the input_velocity on the floor.
# @impure
func handle_floor_move(delta: float, max_speed: float, acceleration: float, deceleration: float):
	if has_same_direction(direction, input_velocity.x):
		velocity.x = get_acceleration(delta, velocity.x, max_speed * speed_multiplier, acceleration * speed_multiplier)
	else:
		handle_deceleration_move(delta, deceleration * speed_multiplier)

# handle_airborne_move applies acceleration or deceleration depending on the input_velocity while airborne.
# @impure
func handle_airborne_move(delta: float, max_speed: float, acceleration: float, deceleration: float):
	if input_velocity.x != 0:
		velocity.x = get_acceleration(delta, velocity.x, max_speed * speed_multiplier, acceleration * speed_multiplier, input_velocity.x)
	else:
		handle_deceleration_move(delta, deceleration * speed_multiplier)

# handle_deceleration_move applies deceleration.
# @impure
func handle_deceleration_move(delta: float, deceleration: float):
	velocity.x = get_deceleration(delta, velocity.x, deceleration)

# get_acceleration returns the next value after acceleration is applied.
# @pure
func get_acceleration(delta: float, value: float, max_speed: float, acceleration: float, override_direction = direction) -> float:
	return move_toward(value, max_speed * sign(override_direction), acceleration * delta)

# get_deceleration returns the next value after deceleration is applied.
# @pure
func get_deceleration(delta: float, value: float, deceleration: float) -> float:
	return move_toward(value, 0.0, deceleration * delta)

# is_nearly returns true if the first given value nearly equals the second given value.
# @pure
func is_nearly(value1: float, value2: float, epsilon = 0.001) -> bool:
	return abs(value1 - value2) < epsilon

# is_on_door returns true if there is a door behind.
# @impure
func is_on_door() -> bool:
	for collider in PlayerArea2D.get_overlapping_areas():
		if Game.has_collision_layer_bit(collider.collision_layer, Game.COLLISION_LAYER_DOOR):
			return true
	return false

# is_on_wall_passive returns true if there is a wall on the side.
# @pure
func is_on_wall_passive() -> bool:
	return test_move(transform, Vector2(direction, 0))

# is_on_ceiling_passive returns true if there is a ceiling upward.
# @pure
func is_on_ceiling_passive() -> bool:
	if PlayerCeilingChecker.is_colliding():
		var collider := PlayerCeilingChecker.get_collider()
		if collider is KinematicBody2D:
			# TODO: return true only if collider is not a one-way platform
			return false
		return false
	return false

# has_same_direction returns true if the two given numbers are non-zero and of the same sign.
# @pure
func has_same_direction(dir1: float, dir2: float) -> bool:
	return dir1 != 0 and dir2 != 0 and sign(dir1) == sign(dir2)

# has_invert_direction returns true if the two given numbers are non-zero and of the opposed sign.
# @pure
func has_invert_direction(dir1: float, dir2: float) -> bool:
	return dir1 != 0 and dir2 != 0 and sign(dir1) != sign(dir2)

###
# Player movement grounded states.
###

func pre_stand():
	set_animation("stand")
	jumps_remaining = MAX_JUMPS
	wallslide_cancelled = false

func tick_stand(delta: float):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	handle_deceleration_move(delta, RUN_DECELERATION)
	handle_last_safe_position()
	if not is_on_floor():
		fall_jump_grace = FALL_JUMP_GRACE
		return set_state(PlayerState.fall)
	if input_up_once and is_on_door():
		return set_state(PlayerState.enter_door)
	if input_jump_once and jumps_remaining > 0 and not is_on_ceiling_passive():
		return set_state(PlayerState.jump)
	if input_use and current_object:
		return set_state(PlayerState.use_object)
	if input_velocity.x != 0 and has_same_direction(direction, input_velocity.x) and not is_on_wall_passive():
		return set_state(PlayerState.run)
	elif input_velocity.x != 0 and not has_same_direction(direction, input_velocity.x):
		return set_state(PlayerState.move_turn)

func pre_run():
	set_animation("run")
	jumps_remaining = MAX_JUMPS

func tick_run(delta: float):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	handle_floor_move(delta, RUN_MAX_SPEED, RUN_ACCELERATION, RUN_DECELERATION)
	handle_last_safe_position()	
	if not is_on_floor():
		fall_jump_grace = FALL_JUMP_GRACE
		return set_state(PlayerState.fall)
	if input_up_once and is_on_door():
		return set_state(PlayerState.enter_door)
	if is_on_wall():
		return set_state(PlayerState.push_wall)
	if input_use and current_object:
		return set_state(PlayerState.use_object)
	if input_jump_once and jumps_remaining > 0 and not is_on_ceiling_passive():
		return set_state(PlayerState.jump)
	if input_velocity.x != 0 and has_invert_direction(direction, input_velocity.x):
		return set_state(PlayerState.move_turn)
	if input_velocity.x == 0 and velocity.x == 0:
		return set_state(PlayerState.stand)

func pre_move_turn():
	jumps_remaining = MAX_JUMPS

func tick_move_turn(delta: float):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	handle_floor_move(delta, RUN_MAX_SPEED, RUN_ACCELERATION, (RUN_DECELERATION) * 2.0)
	if not is_on_floor():
		set_direction(-direction)
		fall_jump_grace = FALL_JUMP_GRACE
		return set_state(PlayerState.fall)
	if input_up_once and is_on_door():
		return set_state(PlayerState.enter_door)
	if has_same_direction(direction, input_velocity.x):
		return set_state(PlayerState.run)
	if input_jump_once and not is_on_ceiling_passive():
		set_direction(-direction)
		return set_state(PlayerState.jump)
	if velocity.x == 0:
		set_direction(-direction)
		return set_state(PlayerState.run)

###
# Player movement airborne states.
###

func pre_fall():
	set_animation("fall")

func tick_fall(delta: float):
	fall_jump_grace = max(fall_jump_grace - delta, 0.0)
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	handle_direction()
	handle_airborne_move(delta, RUN_MAX_SPEED, RUN_ACCELERATION, RUN_DECELERATION)
	if is_on_floor():
		fx_hit_ground()
		fall_jump_grace = 0.0
		return set_state(PlayerState.stand)
	if is_on_wall_passive() and not input_down and (\
		(not wallslide_cancelled and is_timer_finished()) or \
		(not wallslide_cancelled and has_same_direction(direction, input_velocity.x)) or \
		(wallslide_cancelled and is_timer_finished() and has_same_direction(direction, input_velocity.x)) \
	):
		fall_jump_grace = 0.0
		return set_state(PlayerState.wallslide)
	if fall_jump_grace == 0 and jumps_remaining == MAX_JUMPS:
		jumps_remaining -= 1
	if input_jump_once and jumps_remaining > 0 and not is_on_ceiling_passive():
		fall_jump_grace = 0.0
		return set_state(PlayerState.jump)
	if input_use and current_object:
		fall_jump_grace = 0.0
		return set_state(PlayerState.use_object)

func pre_jump():
	jumps_remaining -= 1
	start_timer(0.14)
	handle_jump(JUMP_STRENGTH)
	set_animation("jump" if jumps_remaining == 1 else "double_jump")
	play_sound_effect(JumpSFX)
	if input_velocity.x != 0:
		set_direction(int(sign(input_velocity.x)))

func tick_jump(delta: float):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	handle_direction()
	handle_airborne_move(delta, RUN_MAX_SPEED, RUN_ACCELERATION, RUN_DECELERATION)
	if is_on_floor():
		return set_state(PlayerState.stand)
	if is_on_ceiling():
		velocity.y = CEILING_KNOCKDOWN
		if not is_colliding_with_group("no_ceiling_sound"):
			play_sound_effect(BumpSFX)
		return set_state(PlayerState.fall)
	if velocity.y > 0:
		return set_state(PlayerState.fall)
	if input_use and current_object:
		return set_state(PlayerState.use_object)
	if input_jump_once and jumps_remaining > 0 and is_timer_finished() and not is_on_ceiling_passive():
		return set_state(PlayerState.jump)

func pre_expulse():
	start_timer(0.14)
	set_animation("jump")
	handle_expulse(EXPULSE_STRENGTH)
	play_sound_effect(JumpSFX)
	if expulse_direction.y < 0:
		jumps_remaining = MAX_JUMPS - 1
	if int(sign(expulse_direction.x)) != 0:
		set_direction(int(sign(expulse_direction.x)))

func tick_expulse(delta: float):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	handle_direction()
	handle_airborne_move(delta, RUN_MAX_SPEED, RUN_ACCELERATION, RUN_DECELERATION)
	if is_on_floor():
		jumps_remaining = MAX_JUMPS
		if velocity.x == 0:
			return set_state(PlayerState.stand)
		if not is_animation_playing("run"):
			set_animation("run")
	if velocity.y > 0 and is_on_wall_passive() and not input_down and (\
		(not wallslide_cancelled and is_timer_finished()) or \
		(not wallslide_cancelled and has_same_direction(direction, input_velocity.x)) or \
		(wallslide_cancelled and is_timer_finished() and has_same_direction(direction, input_velocity.x)) \
	):
		return set_state(PlayerState.wallslide)
	if input_jump_once and jumps_remaining > 0 and is_timer_finished() and not is_on_ceiling_passive():
		return set_state(PlayerState.jump)

###
# Player movement wall states
###

func pre_push_wall():
	set_animation("stand")

func tick_push_wall(delta: float):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	handle_floor_move(delta, RUN_MAX_SPEED, RUN_ACCELERATION, RUN_DECELERATION)
	if not is_on_floor():
		return set_state(PlayerState.fall)
	if not is_on_wall_passive() or not has_same_direction(direction, input_velocity.x):
		return set_state(PlayerState.stand)
	if input_jump_once and not is_on_ceiling_passive():
		return set_state(PlayerState.jump)

var _stick_wall := 0.0
func pre_wallslide():
	velocity.x = 0
	velocity.y = velocity.y * 0.1
	_stick_wall = 0
	jumps_remaining = MAX_JUMPS - 1
	fx_hit_wall()
	set_animation("wallslide")

func tick_wallslide(delta: float):
	handle_gravity(delta, GRAVITY_MAX_SPEED * 0.5, GRAVITY_ACCELERATION * 0.25)
	if is_on_floor():
		fx_hit_ground()
		return set_state(PlayerState.stand)
	if not is_on_wall_passive():
		return set_state(PlayerState.fall)
	if input_down_once:
		wallslide_cancelled = true
		return set_state(PlayerState.fall)
	if input_jump_once:
		return set_state(PlayerState.walljump)
	if has_invert_direction(input_velocity.x, direction):
		_stick_wall += delta
		if _stick_wall > WALL_SLIDE_STICK_WALL_JUMP:
			set_direction(direction * -1)
			return set_state(PlayerState.fall)

func pre_walljump():
	start_timer(0.14)
	set_animation("jump")
	set_direction(-direction)
	handle_walljump(WALL_JUMP_STRENGTH, sign(direction) * WALL_JUMP_PUSH_STRENGTH)
	play_sound_effect(WalljumpSFX)
	wallslide_cancelled = false

func tick_walljump(delta: float):
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION if not input_jump else GRAVITY_ACCELERATION * 0.75)
	handle_airborne_move(delta, RUN_MAX_SPEED, RUN_ACCELERATION, RUN_DECELERATION * 0.25)
	if is_on_floor():
		return set_state(PlayerState.stand)
	if is_on_ceiling():
		velocity.y = CEILING_KNOCKDOWN
		if not is_colliding_with_group("no_ceiling_sound"):
			play_sound_effect(BumpSFX)
		return set_state(PlayerState.fall)
	if velocity.y > 0:
		return set_state(PlayerState.fall)
	if input_jump_once and jumps_remaining > 0 and is_timer_finished() and not is_on_ceiling_passive():
		return set_state(PlayerState.jump)

###
# Player interactions with door
###

func pre_enter_door():
	for collider in PlayerArea2D.get_overlapping_areas():
		if Game.has_collision_layer_bit(collider.collision_layer, Game.COLLISION_LAYER_DOOR):
			current_door_from = collider.get_parent().get_parent()
			current_door_to = current_door_from.door_to_node
			if current_door_to and current_door_from:
				if position.x == current_door_from.Target.global_position.x:
					velocity.x = 0
					return set_state(PlayerState.enter_door_fade)
				set_direction(1 if position.x < current_door_from.Target.global_position.x else -1)
				set_animation("run")
				velocity.x = sign(direction) * DOOR_RUN_SPEED
				input_velocity.x = 0
				return
	return set_state(PlayerState.stand)

func tick_enter_door(delta: float):
	if velocity.x > 0 and position.x >= current_door_from.Target.global_position.x or \
		velocity.x < 0 and position.x <= current_door_from.Target.global_position.x:
		velocity.x = 0
		return set_state(PlayerState.enter_door_fade)

func pre_enter_door_fade():
	start_timer(DOOR_PLAYER_FADE_DURATION)
	set_animation("stand")

func tick_enter_door_fade(delta):
	PlayerSprite.modulate.a = PlayerTimer.time_left / PlayerTimer.wait_time
	if is_timer_finished():
		position = current_door_to.Target.global_position
		PlayerSprite.modulate.a = 1.0
		return set_state(PlayerState.stand)

###
# Player objects
###

func get_object():
	randomize()
	current_object_index = randi() % PowersManager.Powers.size()
	current_object = PowersManager.Powers[current_object_index]["scene"].instance()

func apply_object_speed(object):
	active_object = object
	speed_multiplier = SPEED_MULTIPLIER
	PlayerObjectTimer.wait_time = OBJECT_TIME_SPEED
	PlayerObjectTimer.start()

func apply_object_prince(object):
	set_class(MultiplayerManager.PlayerClass.Prince)

func reset_object_prince(object):
	is_invincible = false
	SkinManager.replace_skin(PlayerSprite, player.skin_id, false)

func apply_object_invincibility(object):
	is_invincible = true
	active_object = object
	speed_multiplier = INVINCIBILITY_SPEED_MULTIPLIER
	SkinManager.replace_skin(PlayerSprite, player.skin_id, true)
	PlayerObjectTimer.wait_time = OBJECT_TIME_INVINCIBILITY
	PlayerObjectTimer.start()

func reset_object_invincibility(object):
	is_invincible = false
	SkinManager.replace_skin(PlayerSprite, player.skin_id, false)

func pre_use_object():
	if active_object:
		return
	current_object.global_position = $Sprite/PowerSpawn.global_position
	current_object.player_node = self
	get_parent().add_child(current_object)
	current_object = null
	current_object_index = null

func tick_use_object(delta: float):
	if not is_on_floor():
		return set_state(PlayerState.fall)
	return set_state(PlayerState.stand)

###
# Player death/respawn
###

var _death_dir := 1.0
var _death_origin := Vector2()
func apply_death(death_origin: Vector2):
	if is_invincible:
		return
	screen_shake()
	_death_dir = 1.0 if _death_origin.x > position.x else -1.0
	_death_origin = death_origin
	return set_state(PlayerState.death)

func pre_death():
	velocity = Vector2(_death_dir * -120.0, -320.0)
	start_timer(1.0)
	set_animation("death")
	play_sound_effect(DeathSFX)
	PlayerCollisionBody.set_deferred("disabled", true)

func tick_death(delta: float):
	rotation -= 2.0 * _death_dir * delta
	handle_gravity(delta, GRAVITY_MAX_SPEED, GRAVITY_ACCELERATION)
	if is_timer_finished():
		rotation = 0.0
		position = last_safe_position
		velocity = Vector2()
		return set_state(PlayerState.respawn)

func pre_respawn():
	set_animation("respawn")

func tick_respawn(delta: float):
	if is_animation_finished():
		PlayerCollisionBody.set_deferred("disabled", false)
		return set_state(PlayerState.stand)

###
# Dialogs / Crown
###

func set_dialog(dialog: int, has_crown: bool):
	match dialog:
		DialogType.none: $Dialog.visible = false
		DialogType.ready: $Dialog.visible = true
	$Crown.visible = has_crown

###
# FX / Animation driven
###

func fx_step_01():
	play_sound_effect(Step_01_SFX)
	fx_spawn_dust_particles(Vector2(position.x + 5 * direction, position.y))

func fx_step_02():
	play_sound_effect(Step_02_SFX)
	fx_spawn_dust_particles(Vector2(position.x - 5 * direction, position.y))

func fx_hit_wall():
	play_sound_effect(Step_02_SFX)
	fx_spawn_dust_particles(Vector2(position.x + 7 * direction, position.y - 12))

func fx_hit_ground():
	play_sound_effect(Step_01_SFX)
	fx_spawn_dust_particles(Vector2(position.x - 5, position.y))
	fx_spawn_dust_particles(Vector2(position.x + 5, position.y))

func fx_spawn_dust_particles(position: Vector2):
	var ground_dust_node := GroundDustFX.instance()
	ground_dust_node.position = position
	ground_dust_node.get_node("Particles2D").call_deferred("restart")
	Game.map_node.ParticleSlot.add_child(ground_dust_node)
