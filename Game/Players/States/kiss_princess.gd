extends FiniteStateMachineStateNode

func start_state():
	context.velocity = Vector2.ZERO
	context.start_timer(0.84)
	context.set_animation("frog_to_prince")
	print("Start kiss_princess")

func process_state(delta: float):
	if context.is_timer_finished():
		context.kiss_the_princess = false
		return fsm.states.stand
#		var new_player_node = yield(context.set_transformation(MultiplayerManager.PlayerTransformationType.Prince), "completed")
#		new_player_node.has_trail = 0
#		new_player_node.speed_multiplier = 1.0
