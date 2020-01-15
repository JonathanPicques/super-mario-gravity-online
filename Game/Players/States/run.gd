extends FiniteStateMachineStateNode

func start_state():
	play_animation_run(true)
	context.jumps_remaining = context.MAX_JUMPS

func process_state(delta: float):
	play_animation_run(false)
	context.handle_gravity(delta, context.GRAVITY_MAX_SPEED, context.GRAVITY_ACCELERATION)
	context.handle_floor_move(delta,
		context.STICKY_MAX_SPEED if context.is_on_sticky() else context.RUN_MAX_SPEED,
		context.STICKY_ACCELERATION if context.is_on_sticky() else context.RUN_ACCELERATION,
		context.STICKY_DECELERATION if context.is_on_sticky() else context.RUN_DECELERATION)
	context.handle_last_safe_position()
	if not context.is_on_floor():
		context.fall_jump_grace = context.FALL_JUMP_GRACE
		return fsm.states.fall
	if context.input_up_once and context.is_on_door():
		return fsm.states.enter_door
	if context.is_on_wall():
		return fsm.states.push_wall
	if context.input_use and context.has_unused_power():
		return fsm.states.use_power
	if context.input_jump_once and context.jumps_remaining > 0 and not context.is_on_ceiling_passive():
		return fsm.states.jump
	if context.input_velocity.x != 0 and context.has_invert_direction(context.direction, context.input_velocity.x):
		return fsm.states.floor_turn
	if context.input_velocity.x == 0 and context.velocity.x == 0:
		if context.is_animation_playing("run"):
			context.set_animation("run_to_stand")
		return fsm.states.stand

func play_animation_run(from_beginning: bool):
	if not context.is_animation_playing("run") and \
		not context.is_animation_playing("floor_turn") and \
		not context.is_animation_playing("fall_to_stand") and \
		not context.is_animation_playing("stand_to_run"):
		context.set_animation("run", -1 if from_beginning else 4)
