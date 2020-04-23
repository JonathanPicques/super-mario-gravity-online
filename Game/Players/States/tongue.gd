extends FiniteStateMachineStateNode

func start_state():
	context.velocity = Vector2.ZERO
	context.start_timer(0.3)
	context.set_animation("fall")
	context.PlayerTongue.visible = true
	context.PlayerTongue.get_node("AnimationPlayer").play("extend_tongue")
	if context.PlayerTongueChecker.is_colliding():
		print("Tongue collided!")
#	for area in PlayerArea2D.get_overlapping_areas():
#		if area.get_collision_layer_bit(Game.PHYSICS_LAYER_DAMAGE):
#			return

func process_state(delta: float):
	if context.is_timer_finished():
		context.PlayerTongue.visible = false
		context.apply_expulse(Vector2(context.direction, 0))
		if context.is_on_floor():
			return fsm.states.stand
		else:
			return fsm.states.fall
