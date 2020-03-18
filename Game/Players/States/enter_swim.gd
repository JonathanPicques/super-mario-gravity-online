extends FiniteStateMachineStateNode

func start_state():
	context.set_animation("swim")
	context.PlayerSprite.z_index = -1
	context.jumps_remaining = context.MAX_JUMPS
	$Tween.stop_all()
	$Tween.interpolate_property(context, "velocity:y", null, 0.0, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
	return fsm.states.swim

func finish_state():
	context.PlayerSprite.z_index = 0
