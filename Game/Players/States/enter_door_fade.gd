extends FiniteStateMachineStateNode

func start_state():
	context.start_timer(context.DOOR_PLAYER_FADE_DURATION)
	context.set_animation("enter_door")
	context.current_door_from.get_node("AnimationPlayer").play("open_door")

func process_state(delta: float):
	context.PlayerSprite.modulate.a = context.PlayerTimer.time_left / context.PlayerTimer.wait_time
	if context.is_timer_finished():
		context.position = context.current_door_to.Target.global_position
		context.PlayerSprite.modulate.a = 1.0
		context.current_door_from.get_node("AnimationPlayer").play("close_door")
		return fsm.states.stand
