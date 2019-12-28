extends Object
class_name FiniteStateMachine

var states := {}
var context: Node
var next_state_node: Node
var current_state_node: Node

func _init(_context: Node, _parent_state_node: Node, _initial_state_node: Node):
	context = _context
	for i in range (0, _parent_state_node.get_child_count()):
		var state_node := _parent_state_node.get_child(i)
		state_node.fsm = self
		state_node.context = _context
		states[state_node.name] = state_node
	set_state_node(_initial_state_node)

func set_state_node(state_node: Node):
	if current_state_node:
		current_state_node.finish_state()
	current_state_node = state_node
	var change_state_node = current_state_node.start_state()
	if change_state_node:
		set_state_node(change_state_node)

func process_state_machine(delta: float):
	var change_state_node = current_state_node.process_state(delta)
	if change_state_node:
		set_state_node(change_state_node)
