extends FiniteStateMachineStateNode

func start_state():
	context.start_timer(context.DOOR_PLAYER_FADE_DURATION)
	context.set_animation("stand")

func process_state(delta: float):
	context.PlayerSprite.modulate.a = context.PlayerTimer.time_left / context.PlayerTimer.wait_time
	if context.is_timer_finished():
		context.position = context.current_door_to.Target.global_position
		context.PlayerSprite.modulate.a = 1.0
		return fsm.states.stand
