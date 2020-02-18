extends Node
class_name HistoryNode

onready var creator = Game.game_mode_node

var undos := []
var redos := []
var transactions := []

func exec(step):
	match step.type:
		"fill_cell": creator.Drawers[step.drawer_index].fill_cell(step.pos)
		"clear_cell": creator.Drawers[step.drawer_index].clear_cell(step.pos)

func start():
	transactions.append([])

func push_step(redo, undo):
	exec(redo)
	transactions[transactions.size() - 1].append({"redo": redo, "undo": undo})

func commit():
	var last_transaction: Array = transactions.pop_back()
	if last_transaction.empty():
		return
	var command := {"redo": [], "undo": []}
	for step in last_transaction:
		command.redo.append(step.redo)
	var last_transaction_reversed = last_transaction.duplicate()
	last_transaction_reversed.invert()
	for step in last_transaction_reversed:
		command.undo.append(step.undo)
	if transactions.size() > 0:
		transactions[transactions.size() - 1].append(command)
	else:
		redos.clear()
		undos.append(command)

func undo():
	assert(transactions.empty())
	var step = undos.pop_back()
	for u in step.undo:
		exec(u)
	redos.append(step)

func redo():
	assert(transactions.empty())
	var step = redos.pop_back()
	for r in step.redo:
		exec(r)
	undos.append(step)

func can_undo() -> bool:
	return not undos.empty()

func can_redo() -> bool:
	return not redos.empty()
