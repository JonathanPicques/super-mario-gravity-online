extends FiniteStateMachineStateNode

func start_state():
	context.jumps_remaining = context.MAX_JUMPS

func process_state(delta: float):
	context.handle_gravity(delta, context.GRAVITY_MAX_SPEED, context.GRAVITY_ACCELERATION)
	context.handle_floor_move(delta, context.RUN_MAX_SPEED, context.RUN_ACCELERATION, context.RUN_DECELERATION * 2.0)
	if not context.is_on_floor():
		context.set_direction(-context.direction)
		context.fall_jump_grace = context.FALL_JUMP_GRACE
		return fsm.states.fall
	if context.input_up_once and context.is_on_door():
		return fsm.states.enter_door
	if context.has_same_direction(context.direction, context.input_velocity.x):
		return fsm.states.run
	if context.input_jump_once and not context.is_on_ceiling_passive():
		context.set_direction(-context.direction)
		return fsm.states.jump
	if context.velocity.x == 0:
		context.set_direction(-context.direction)
		return fsm.states.run
