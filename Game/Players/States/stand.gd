extends FiniteStateMachineStateNode

func start_state():
	play_animation_stand()
	context.jumps_remaining = context.MAX_JUMPS
	context.wallslide_cancelled = false

func process_state(delta: float):
	play_animation_stand()
	context.handle_gravity(delta, context.GRAVITY_MAX_SPEED, context.GRAVITY_ACCELERATION)
	context.handle_deceleration_move(delta, context.RUN_DECELERATION)
	context.handle_last_safe_position()
	if not context.is_on_floor():
		context.set_animation("jump_to_fall")
		context.fall_jump_grace = context.FALL_JUMP_GRACE
		return fsm.states.fall
	if context.input_up_once and context.is_on_door():
		return fsm.states.enter_door
	if context.input_jump_once and context.jumps_remaining > 0 and not context.is_on_ceiling_passive():
		return fsm.states.jump
	if context.input_use and context.has_unused_power():
		return fsm.states.use_power
	if context.input_velocity.x != 0 and context.has_same_direction(context.direction, context.input_velocity.x) and not context.is_on_wall_passive():
		if context.is_animation_playing("stand"):
			context.set_animation("stand_to_run")
		return fsm.states.run
	elif context.input_velocity.x != 0 and not context.has_same_direction(context.direction, context.input_velocity.x):
		return fsm.states.floor_turn

func play_animation_stand():
	if not context.is_animation_playing("stand") and \
		not context.is_animation_playing("floor_turn") and \
		not context.is_animation_playing("run_to_stand") and \
		not context.is_animation_playing("fall_to_stand"):
		context.set_animation("stand")
