extends FiniteStateMachineStateNode

func start_state():
	context.start_timer(0.14)
	context.set_animation("jump")
	context.set_direction(-context.direction)
	context.handle_walljump(context.WALL_JUMP_STRENGTH, sign(context.direction) * context.WALL_JUMP_PUSH_STRENGTH)
	context.play_sound_effect(context.WalljumpSFX)
	context.wallslide_cancelled = false

func process_state(delta: float):
	context.handle_gravity(delta, context.GRAVITY_MAX_SPEED, context.GRAVITY_ACCELERATION if not context.input_jump else context.GRAVITY_ACCELERATION * 0.75)
	context.handle_airborne_move(delta, context.RUN_MAX_SPEED, context.RUN_ACCELERATION, context.RUN_DECELERATION * 0.25)
	if context.is_on_floor():
		return fsm.states.stand
	if context.is_on_ceiling():
		context.velocity.y = context.CEILING_KNOCKDOWN
		context.play_sound_effect(context.BumpSFX)
		return fsm.states.fall
	if context.velocity.y > 0:
		return fsm.states.fall
	if context.input_jump_once and context.jumps_remaining > 0 and context.is_timer_finished() and not context.is_on_ceiling_passive():
		return fsm.states.jump
