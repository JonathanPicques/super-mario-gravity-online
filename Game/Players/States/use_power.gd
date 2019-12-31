extends FiniteStateMachineStateNode

func start_state():
	context.power_node.on = true
	context.power_node.start_power()
	return fsm.states.stand
