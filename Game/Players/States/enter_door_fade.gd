extends FiniteStateMachineStateNode

func start_state():
	context.start_timer(context.DOOR_PLAYER_ENTER_WAIT)
	context.set_direction(1)
	context.current_door_from.get_node("AnimationPlayer").play("open_door")

var _animation_started := false
func process_state(delta: float):
	if not _animation_started and context.is_timer_finished():
		context.set_animation("enter_door")
		_animation_started = true
	if _animation_started and context.is_animation_finished():
		context.position = Vector2(
			context.current_door_to.Target.global_position.x + context.current_door_from.door_pivot_offset,
			context.current_door_to.Target.global_position.y
		)
		context.PlayerSprite.visible = false
		context.current_door_from.get_node("AnimationPlayer").play("close_door")
		_animation_started = false
		return fsm.states.exit_door_fade
