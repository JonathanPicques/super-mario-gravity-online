extends FiniteStateMachineStateNode

func start_state():
	context.set_animation("swim")

func process_state(delta: float):
	context.disable_snap = 1.0
	context.handle_swim_move(delta, context.SWIM_MAX_SPEED, context.SWIM_ACCELERATION, context.SWIM_DECELERATION)
	context.handle_last_safe_position()
	context.handle_direction()
	if not context.is_in_water():
		return fsm.states.jump
