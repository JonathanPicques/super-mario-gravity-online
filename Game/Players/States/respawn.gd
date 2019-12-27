extends FiniteStateMachineStateNode

func start_state():
	context.set_animation("respawn")

func process_state(delta: float):
	if context.is_animation_finished():
		context.PlayerCollisionBody.set_deferred("disabled", false)
		return fsm.states.stand
