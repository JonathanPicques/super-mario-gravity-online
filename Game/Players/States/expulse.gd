extends FiniteStateMachineStateNode

func start_state():
	context.has_trail = true
	context.start_timer(0.14)
	context.set_animation("jump")
	context.handle_expulse(context.EXPULSE_STRENGTH)
	# play_sound_effect(JumpSFX)
	if context.expulse_direction.y < 0:
		context.jumps_remaining = context.MAX_JUMPS - 1
	if int(sign(context.expulse_direction.x)) != 0:
		context.set_direction(int(sign(context.expulse_direction.x)))

func process_state(delta: float):
	context.handle_gravity(delta, context.GRAVITY_MAX_SPEED, context.GRAVITY_ACCELERATION)
	context.handle_direction()
	context.handle_airborne_move(delta, context.RUN_MAX_SPEED, context.RUN_ACCELERATION, context.RUN_DECELERATION)
	if context.is_on_floor():
		context.jumps_remaining = context.MAX_JUMPS
		if context.velocity.x == 0:
			return fsm.states.stand
		if not context.is_animation_playing("run"):
			context.set_animation("run")
	if context.velocity.y > 0 and context.is_on_wall_passive() and not context.input_down and (\
		(not context.wallslide_cancelled and context.is_timer_finished()) or \
		(not context.wallslide_cancelled and context.has_same_direction(context.direction, context.input_velocity.x)) or \
		(context.wallslide_cancelled and context.is_timer_finished() and context.has_same_direction(context.direction, context.input_velocity.x)) \
	):
		return fsm.states.wallslide
	if context.input_jump_once and context.jumps_remaining > 0 and context.is_timer_finished() and not context.is_on_ceiling_passive():
		return fsm.states.jump

func finish_state():
	context.has_trail = false
