extends FiniteStateMachineStateNode

func start_state():
	context.set_animation("stand")
	context.jumps_remaining = context.MAX_JUMPS
	context.wallslide_cancelled = false

func process_state(delta: float):
	context.handle_gravity(delta, context.GRAVITY_MAX_SPEED, context.GRAVITY_ACCELERATION)
	context.handle_deceleration_move(delta, context.RUN_DECELERATION)
	context.handle_last_safe_position()
	if not context.is_on_floor():
		context.fall_jump_grace = context.FALL_JUMP_GRACE
		return fsm.states.fall
	if context.input_up_once and context.is_on_door():
		return fsm.states.enter_door
	if context.input_jump_once and context.jumps_remaining > 0 and not context.is_on_ceiling_passive():
		return fsm.states.jump
	if context.input_velocity.x != 0 and context.has_same_direction(context.direction, context.input_velocity.x) and not context.is_on_wall_passive():
		return fsm.states.run
	elif context.input_velocity.x != 0 and not context.has_same_direction(context.direction, context.input_velocity.x):
		return fsm.states.move_turn
