extends FiniteStateMachineStateNode

func start_state():
	context.power_node.on = true
	context.power_node.start_power()
	context.emit_signal("start_power", context.power_node.power_id)
	return fsm.states.stand
