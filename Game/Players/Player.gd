extends KinematicBody2D
class_name PlayerNode

signal grab_power(power_id)
signal start_power(power_id)
signal finish_power(power_id)

const SpriteTrail := preload("res://Game/Effects/Sprites/SpriteTrail.tscn")
const GroundDustFX := preload("res://Game/Effects/Particles/GroundDust.tscn")

onready var PlayerTimer: Timer = $Timer
onready var PlayerSprite: Sprite = $Sprite
onready var PlayerArea2D: Area2D = $Area2D
onready var PlayerObjectTimer: Timer = $ObjectTimer
onready var PlayerSwimChecker: RayCast2D = $SwimChecker
onready var PlayerLifetimeTimer: Timer = $LifetimeTimer
onready var PlayerCollisionBody: CollisionShape2D = $CollisionBody
onready var PlayerCeilingChecker: RayCast2D = $CeilingChecker
onready var PlayerLeftFootChecker: RayCast2D = $LeftFootChecker
onready var PlayerRightFootChecker: RayCast2D = $RightFootChecker
onready var PlayerAnimationPlayer: AnimationPlayer = $AnimationPlayer
onready var PlayerSoundEffectPlayers := [$SoundEffects/SFX1, $SoundEffects/SFX2, $SoundEffects/SFX3, $SoundEffects/SFX4]
onready var PlayerInvincibilityEffect: AnimatedSprite = $InvincibilityEffect
onready var PlayerNetworkDeadReckoning: Tween = $NetworkDeadReckoning

onready var PlayerPowerPoint := $Sprite/PowerPoint
onready var PlayerCenterPoint := $Sprite/CenterPoint
onready var PlayerBubblePoint := $Sprite/BubblePoint

onready var BumpSFX: AudioStream
onready var JumpSFX: AudioStream
onready var DeathSFX: AudioStream
onready var WalljumpSFX: AudioStream
onready var Step_01_SFX: AudioStream
onready var Step_02_SFX: AudioStream
onready var Enterwater_SFX: AudioStream
onready var Underwater_SFX: AudioStream

onready var fsm := FiniteStateMachine.new(self, $StateMachine, $StateMachine/stand)

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

var player: Dictionary # player reference.

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

var RUN_MAX_SPEED := 145.0
var RUN_ACCELERATION := 630.0
var RUN_DECELERATION := 690.0

var SWIM_MAX_SPEED := 120.0
var SWIM_ACCELERATION := 630.0
var SWIM_DECELERATION := 690.0

var MAX_JUMPS := 2
var JUMP_STRENGTH := -350.0
var FALL_JUMP_GRACE := 0.08
var EXPULSE_STRENGTH := 580.0
var CEILING_KNOCKDOWN := 50.0
var WALL_JUMP_STRENGTH := -330.0
var WALL_JUMP_PUSH_STRENGTH := 55.0
var WALL_SLIDE_STICK_WALL_JUMP := 0.18

var STICKY_MAX_SPEED := RUN_MAX_SPEED / 2.0
var STICKY_ACCELERATION := RUN_ACCELERATION / 2.0
var STICKY_DECELERATION := RUN_DECELERATION / 2.0
var STICKY_JUMP_STRENGTH := JUMP_STRENGTH / 2.0

var ANIMATION_PLAYER_PLAYBACK_SPEED := 0.8
var ANIMATION_PLAYER_PLAYBACK_VELOCITY := RUN_MAX_SPEED

var GRAVITY_MAX_SPEED := 1200.0
var GRAVITY_ACCELERATION := 1300.0

const DOOR_RUN_SPEED = 40.0
const DOOR_PLAYER_EXIT_WAIT = 0.6
const DOOR_PLAYER_ENTER_WAIT = 0.15

var velocity := Vector2()
var direction := 1
var disable_snap := 0.0
var velocity_prev := Vector2()
var input_velocity := Vector2()
var velocity_offset := Vector2()
var fall_jump_grace := 0.0
var jumps_remaining := MAX_JUMPS  # reset on stand or wallslide or expulse
var speed_multiplier := 1.0
var expulse_direction := Vector2.ZERO
var last_safe_position := Vector2()
var wallslide_cancelled := false # reset on stand or walljump

var current_door_to: DoorNode
var current_door_from: DoorNode

var kiss_the_princess = false

var has_trail := 0 # stacked
var is_invincible := 0 # stacked

var power_node: Node
var power_hud_node: Node

# @impure
func _ready():
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
	process_powers(delta)
	process_effects(delta)
	process_velocity(delta)
	fsm.process_state_machine(delta)

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
	if fsm.current_state_node != fsm.states.death and position.y > Game.map_node.killY:
		return fsm.set_state_node(fsm.states.death)

# process_powers checks if a power is active and updates it.
# @impure
func process_powers(delta: float):
	if power_node and power_node.on:
		if power_node.process_power(delta):
			emit_signal("finish_power", power_node.power_id)
			power_node.finish_power()
			power_node.on = false
			get_parent().remove_child(power_node)
			power_node.queue_free()
			power_hud_node.queue_free()
			power_node = null
			power_hud_node = null

# process_effects plays all sprite effects applied to the player.
# @impure
var _trail := 0.0
func process_effects(delta: float):
	if has_trail:
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
	# decrement snapping time if applicable
	if disable_snap > 0:
		disable_snap = max(disable_snap - delta, 0)
	# save old position
	var old_position := position
	# stop movement to avoid sloppy stutters in kinematic body
	if not _was_on_floor and is_on_floor():
		for i in get_slide_count():
			var collision := get_slide_collision(i)
			if is_nearly(velocity_prev.x, 0) and is_nearly(input_velocity.x, 0) and collision.normal != FLOOR:
				velocity = Vector2()
	# save last frame floor status
	_was_on_floor = is_on_floor()
	# save last frame velocity
	velocity_prev = velocity
	# apply movement (and disable snap for jumping)
	velocity = move_and_slide_with_snap(velocity, FLOOR_SNAP if disable_snap == 0 else FLOOR_SNAP_DISABLED, FLOOR)
	# compute real velocity offset without taking too small values into account
	var offset := position - old_position
	velocity_offset = Vector2(
		0.0 if is_nearly(offset.x, 0) else velocity.x,
		0.0 if is_nearly(offset.y, 0) else velocity.y
	)
	# scale animation player playback speed to velocity
	PlayerAnimationPlayer.playback_speed = max((velocity.length() / ANIMATION_PLAYER_PLAYBACK_VELOCITY) * ANIMATION_PLAYER_PLAYBACK_SPEED, ANIMATION_PLAYER_PLAYBACK_SPEED)

# set_transformation changes the current transformation of the player.
# @async
# @impure
func set_transformation(transformation_type: int) -> PlayerNode:
	var new_player_node: PlayerNode = MultiplayerManager.PlayerTransformations[transformation_type].instance()
	return MultiplayerManager.replace_player_node(player, new_player_node)

# set_dialog changes the dialog bubble displayed by the player.
# @impure
func set_dialog(dialog: int, has_crown: bool):
	match dialog:
		DialogType.none: $Dialog.visible = false
		DialogType.ready: $Dialog.visible = true
	$Crown.visible = has_crown

# set_direction changes the Player direction and flips the sprite accordingly.
# @impure
func set_direction(new_direction: int):
	direction = new_direction
	PlayerSprite.scale.x = abs(PlayerSprite.scale.x) * sign(direction)

# set_animation changes the Player animation.
# @impure
func set_animation(new_animation: String, play_from_frame := -1):
	if not is_animation_playing(new_animation):
		PlayerAnimationPlayer.play(new_animation)
	if play_from_frame != -1:
		var animation := PlayerAnimationPlayer.get_animation(PlayerAnimationPlayer.current_animation)
		var track_time := animation.track_get_key_time(animation.find_track("Sprite:frame"), play_from_frame)
		PlayerAnimationPlayer.play(new_animation)
		PlayerAnimationPlayer.seek(track_time, true)
		
# is_animation_playing returns true if the given animation is playing.
# @impure
func is_animation_playing(animation: String) -> bool:
	return PlayerAnimationPlayer.current_animation == animation

# is_animation_finished returns true if the animation is finished (and not looping).
# @pure
func is_animation_finished() -> bool:
	return not PlayerAnimationPlayer.is_playing()

###
# Movement helpers
###

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
	fx_shake_screen()

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
			if area.get_collision_layer_bit(Game.PHYSICS_LAYER_DAMAGE):
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
		
# handle_airborne_move applies acceleration or deceleration depending on the input_velocity while airborne.
# @impure
func handle_swim_move(delta: float, max_speed: float, acceleration: float, deceleration: float):
	if input_velocity.x != 0:
		velocity.x = get_acceleration(delta, velocity.x, max_speed * speed_multiplier, acceleration * speed_multiplier, input_velocity.x)
	else:
		velocity.x = get_deceleration(delta, velocity.x, deceleration)
	if input_velocity.y != 0:
		velocity.y = get_acceleration(delta, velocity.y, max_speed * speed_multiplier, acceleration * speed_multiplier, input_velocity.y)
	else:
		velocity.y = get_deceleration(delta, velocity.y, deceleration)

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
# @pure
func is_on_door() -> bool:
	for collider in PlayerArea2D.get_overlapping_areas():
		if collider.get_collision_layer_bit(Game.PHYSICS_LAYER_DOOR):
			return true
	return false

# is_on_sticky returns true if there is a stick on our feet.
# @pure
func is_on_sticky() -> bool:
	if PlayerLeftFootChecker.is_colliding():
		var collider = PlayerLeftFootChecker.get_collider()
		if collider.get_collision_layer_bit(Game.PHYSICS_LAYER_STICKY):
			return true
	if PlayerRightFootChecker.is_colliding():
		var collider = PlayerRightFootChecker.get_collider()
		if collider.get_collision_layer_bit(Game.PHYSICS_LAYER_STICKY):
			return true
	return false

# is_on_sticky returns true if there is a water surrounding us.
# @pure
func is_in_water() -> bool:
	if PlayerSwimChecker.is_colliding():
		var collider = PlayerSwimChecker.get_collider()
		if collider.get_collision_layer_bit(Game.PHYSICS_LAYER_WATER):
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

# has_unused_power returns true if the player is holding an unused power.
# @pure
func has_unused_power() -> bool:
	return power_node and not power_node.on

# has_same_direction returns true if the two given numbers are non-zero and of the same sign.
# @pure
func has_same_direction(dir1: float, dir2: float) -> bool:
	return dir1 != 0 and dir2 != 0 and sign(dir1) == sign(dir2)

# has_invert_direction returns true if the two given numbers are non-zero and of the opposed sign.
# @pure
func has_invert_direction(dir1: float, dir2: float) -> bool:
	return dir1 != 0 and dir2 != 0 and sign(dir1) != sign(dir2)

# start_timer starts a timer for the given duration in seconds.
# @impure
func start_timer(duration: float):
	PlayerTimer.wait_time = duration
	PlayerTimer.start()

# is_timer_finished returns true if the timer is finished.
# @pure
func is_timer_finished() -> bool:
	return PlayerTimer.is_stopped()

###
# Events
###

# grab_power is called externally when the player should grab the given power.
# @impure
# @async
func grab_power(power_id: int):
	# create power (and hud) node
	power_node = PowersManager.Powers[power_id].scene.instance()
	power_hud_node = PowersManager.Powers[power_id].hud_scene.instance()
	# link power to hud/player
	power_node.power_id = power_id
	power_node.player_node = self
	power_node.power_hud_node = power_hud_node
	power_node.global_position = PlayerPowerPoint.global_position
	# emit signal for hud to be attached to the game mode UI
	emit_signal("grab_power", power_id)
	# attach power to player
	get_parent().call_deferred("add_child", power_node)
	yield(get_tree(), "idle_frame")

# apply_death is called externally when the player should meet a fatal fate.
# @impure
var _death_dir := 1.0
var _death_origin := Vector2()
func apply_death(death_origin: Vector2):
	if is_invincible:
		return
	_death_dir = 1.0 if _death_origin.x > position.x else -1.0
	_death_origin = death_origin
	fsm.set_state_node(fsm.states.death)

# apply_expulse sends the player flying in the given direction.
# @impure
func apply_expulse(expulse_dir: Vector2):
	expulse_direction = expulse_dir
	fsm.set_state_node(fsm.states.expulse)

###
# Sound
###

# play_sound_effect plays a sound effect.
# @impure
func play_sound_effect(stream: AudioStream):
	var sound_effect_player = get_sound_effect_player()
	if sound_effect_player:
		sound_effect_player.stream = stream
		sound_effect_player.play()

# stop_sound_effect stops the given sound effect.
# @impure
func stop_sound_effect(stream: AudioStream):
	for sound_effect_player in PlayerSoundEffectPlayers:
		if sound_effect_player.stream == stream and sound_effect_player.is_playing():
			sound_effect_player.stop()

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

###
# FX / Animation driven
###

# @impure
func fx_step_01():
	play_sound_effect(Step_01_SFX)
	fx_spawn_dust_particles(Vector2(position.x + 5 * direction, position.y))

# @impure
func fx_step_02():
	play_sound_effect(Step_02_SFX)
	fx_spawn_dust_particles(Vector2(position.x - 5 * direction, position.y))

# @impure
func fx_hit_wall():
	play_sound_effect(Step_02_SFX)
	fx_spawn_dust_particles(Vector2(position.x + 7 * direction, position.y - 12))

# @impure
func fx_hit_ground():
	play_sound_effect(Step_01_SFX)
	fx_spawn_dust_particles(Vector2(position.x - 5, position.y))
	fx_spawn_dust_particles(Vector2(position.x + 5, position.y))

# @impure
func fx_enter_water(on = true):
	play_sound_effect(Enterwater_SFX)

# @impure
func fx_under_water(on = true):
	match on:
		true: play_sound_effect(Underwater_SFX)
		false: stop_sound_effect(Underwater_SFX)

# @impure
func fx_shake_screen():
	var camera =  Game.game_mode_node.get_player_screen_camera(player.id)
	camera.get_node("ScreenShake").start_shake()

# @impure
func fx_spawn_dust_particles(position: Vector2):
	var ground_dust_node := GroundDustFX.instance()
	ground_dust_node.position = position
	ground_dust_node.get_node("Particles2D").call_deferred("restart")
	Game.map_node.ParticleSlot.add_child(ground_dust_node)
