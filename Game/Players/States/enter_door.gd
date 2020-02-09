extends FiniteStateMachineStateNode

func start_state():
	for collider in context.PlayerArea2D.get_overlapping_areas():
		if Game.has_collision_layer_bit(collider.collision_layer, Game.COLLISION_LAYER_DOOR):
			context.current_door_from = collider.get_parent()
			context.current_door_to = context.current_door_from.door_to_node
			if context.current_door_to and context.current_door_from:
				if context.position.x == context.current_door_from.Target.global_position.x + context.current_door_from.door_pivot_offset:
					context.velocity.x = 0
					return fsm.states.enter_door_fade
				context.set_direction(1 if context.position.x < context.current_door_from.Target.global_position.x + context.current_door_from.door_pivot_offset else -1)
				context.set_animation("run")
				context.velocity.x = sign(context.direction) * context.DOOR_RUN_SPEED
				context.input_velocity.x = 0
				return
	return fsm.states.stand

func process_state(delta: float):
	if context.velocity.x > 0 and context.position.x >= context.current_door_from.Target.global_position.x + context.current_door_from.door_pivot_offset or \
		context.velocity.x < 0 and context.position.x <= context.current_door_from.Target.global_position.x + context.current_door_from.door_pivot_offset:
		context.velocity.x = 0
		return fsm.states.enter_door_fade
