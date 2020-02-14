extends Node
class_name HistoryNode

# transaction = {type: string, mouse_position: Vector2, drawer: int}

var transactions := []
var transaction_index = -1

onready var creator = Game.game_mode_node

func add_transaction(transaction):
	match transaction.type:
		"create":
			creator.Drawers[transaction.drawer].create_item(transaction.mouse_position)
		"remove":
			creator.remove_item(transaction.mouse_position)
	transaction_index = transactions.size()
	transactions.append(transaction)

func undo():
	if transaction_index == -1:
		return
	var t = transactions[transaction_index]
	match t.type:
		"create":
			creator.remove_item(t.mouse_position)
		"remove":
			creator.Drawers[t.drawer].create_item(t.mouse_position)
	transaction_index -= 1

func redo():
	if transaction_index == transactions.size() - 1:
		return
	var t = transactions[transaction_index]
	match t.type:
		"create":
			creator.Drawers[t.drawer].create_item(t.mouse_position)
		"remove":
			creator.remove_item(t.mouse_position)
	transaction_index += 1
