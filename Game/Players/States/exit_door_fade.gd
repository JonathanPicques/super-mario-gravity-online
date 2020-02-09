extends FiniteStateMachineStateNode

func start_state():
	context.start_timer(context.DOOR_PLAYER_EXIT_WAIT)
	context.current_door_to.get_node("AnimationPlayer").play("open_door")

var _animation_started := false
func process_state(delta: float):
	if not _animation_started and context.is_timer_finished():
		context.set_animation("exit_door")
		context.PlayerSprite.visible = true
		_animation_started = true
	if _animation_started and context.is_animation_finished():
		context.current_door_to.get_node("AnimationPlayer").play("close_door")
		_animation_started = false
		return fsm.states.stand
