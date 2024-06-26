extends FiniteStateMachineStateNode

func start_state():
	context.jumps_remaining -= 1
	context.start_timer(0.14)
	context.handle_jump(context.STICKY_JUMP_STRENGTH if context.is_on_sticky() else context.JUMP_STRENGTH)
	context.set_animation("jump" if context.jumps_remaining == 1 else "double_jump")
	context.play_sound_effect(context.JumpSFX)
	if context.input_velocity.x != 0:
		context.set_direction(int(sign(context.input_velocity.x)))

func process_state(delta: float):
	context.handle_gravity(delta, context.GRAVITY_MAX_SPEED, context.GRAVITY_ACCELERATION)
	context.handle_direction()
	context.handle_airborne_move(delta, context.RUN_MAX_SPEED, context.RUN_ACCELERATION, context.RUN_DECELERATION)
	if context.input_use and context.has_unused_power():
		return fsm.states.use_power
	if context.input_tongue:
		return fsm.states.tongue
	if context.is_on_floor():
		return fsm.states.stand
	if context.is_on_ceiling():
		context.velocity.y = context.CEILING_KNOCKDOWN
		context.play_sound_effect(context.BumpSFX)
		if context.is_animation_playing("jump"):
			context.set_animation("jump_to_fall")
		return fsm.states.fall
	if context.velocity.y > 0:
		if context.is_animation_playing("jump"):
			context.set_animation("jump_to_fall")
		return fsm.states.fall
	if context.input_jump_once and context.jumps_remaining > 0 and context.is_timer_finished() and not context.is_on_ceiling_passive():
		return fsm.states.jump
