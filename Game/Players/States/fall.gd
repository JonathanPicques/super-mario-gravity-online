extends FiniteStateMachineStateNode

func start_state():
	play_animation_fall()

func process_state(delta: float):
	play_animation_fall()
	context.fall_jump_grace = max(context.fall_jump_grace - delta, 0.0)
	context.handle_gravity(delta, context.GRAVITY_MAX_SPEED, context.GRAVITY_ACCELERATION)
	context.handle_direction()
	context.handle_airborne_move(delta, context.RUN_MAX_SPEED, context.RUN_ACCELERATION, context.RUN_DECELERATION)
	if context.is_in_water():
		return fsm.states.enter_swim
	if context.is_on_floor():
		context.fx_hit_ground()
		context.set_animation("fall_to_stand")
		context.fall_jump_grace = 0.0
		return fsm.states.stand
	if context.is_on_wall_passive() and not context.input_down and (\
		(not context.wallslide_cancelled and context.is_timer_finished()) or \
		(not context.wallslide_cancelled and context.has_same_direction(context.direction, context.input_velocity.x)) or \
		(context.wallslide_cancelled and context.is_timer_finished() and context.has_same_direction(context.direction, context.input_velocity.x)) \
	):
		context.fall_jump_grace = 0.0
		return fsm.states.wallslide
	if context.fall_jump_grace == 0 and context.jumps_remaining == context.MAX_JUMPS:
		context.jumps_remaining -= 1
	if context.input_use and context.has_unused_power():
		return fsm.states.use_power
	if context.input_jump_once and context.jumps_remaining > 0 and not context.is_on_ceiling_passive():
		context.fall_jump_grace = 0.0
		return fsm.states.jump

func play_animation_fall():
	if not context.is_animation_playing("fall") and \
		not context.is_animation_playing("jump_to_fall"):
		context.set_animation("fall")
