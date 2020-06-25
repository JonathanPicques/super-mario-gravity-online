extends FiniteStateMachineStateNode

var start_tongue = false

func start_state():
	context.velocity = Vector2.ZERO
	context.start_timer(0.14)
	context.set_animation("throw_tongue")
	start_tongue = false
	if context.PlayerTongueChecker.is_colliding():
		print("Tongue collided!")
#	for area in PlayerArea2D.get_overlapping_areas():
#		if area.get_collision_layer_bit(Game.PHYSICS_LAYER_DAMAGE):
#			return

func process_state(delta: float):
	if context.is_timer_finished() and not start_tongue:
		start_tongue = true
		context.PlayerTongue.visible = true
		context.PlayerTongue.get_node("AnimationPlayer").play("extend_tongue")
		context.start_timer(0.3)
	if context.is_timer_finished() and start_tongue:
		context.PlayerTongue.visible = false
		context.apply_expulse(Vector2(context.direction, 0))
		if context.is_on_floor():
			return fsm.states.stand
		else:
			return fsm.states.fall
