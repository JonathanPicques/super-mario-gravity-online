extends FiniteStateMachineStateNode

func start_state():
	context.set_animation("stand")

func process_state(delta: float):
	context.handle_gravity(delta, context.GRAVITY_MAX_SPEED, context.GRAVITY_ACCELERATION)
	context.handle_floor_move(delta, context.RUN_MAX_SPEED, context.RUN_ACCELERATION, context.RUN_DECELERATION)
	if not context.is_on_floor():
		return fsm.states.fall
	if not context.is_on_wall_passive() or not context.has_same_direction(context.direction, context.input_velocity.x):
		return fsm.states.stand
	if context.input_jump_once and not context.is_on_ceiling_passive():
		return fsm.states.jump
